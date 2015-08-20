//
//  LHShareManager.m
//  gift
//
//  Created by 李允 on 15/8/18.
//  Copyright (c) 2015年 ZhuLuTianXia. All rights reserved.
//

#import "LHShareManager.h"
#import "LHHandleQQ.h"

#import "WeiboSDK.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>

#define kRedirectURI    @"http://www.sina.com"

@interface LHShareManager ()<WeiboSDKDelegate,WXApiDelegate,TencentSessionDelegate>
@property (nonatomic, copy) void (^WBCallback)(WBBaseResponse *);
@property (nonatomic, copy) void (^WXCallback)(BaseResp *);

@property (nonatomic, strong) LHHandleQQ *handleQQ;
@property (nonatomic, strong) TencentOAuth *qqOAuth;
@end
@implementation LHShareManager
IMPLEMENT_SHARED_INSTANCE(LHShareManager);

- (void)configShareInfo {
    [WeiboSDK registerApp:@"0000000000"];
#ifdef DEBUG
    [WeiboSDK enableDebugMode:YES];
#else
    [WeiboSDK enableDebugMode:NO];
#endif
    
    [WXApi registerApp:@"wx2jdjdj33j3j3j3j"];
    self.qqOAuth = [[TencentOAuth alloc] initWithAppId:@"0000000000" andDelegate:self];
}

- (void)handleURL:(NSURL *)url {
    [WeiboSDK handleOpenURL:url delegate:self];
    [WXApi handleOpenURL:url delegate:self];
    [QQApiInterface handleOpenURL:url delegate:self.handleQQ];
}

#pragma mark - QQ
- (void)shareToQQ:(NSString *)title content:(NSString *)content url:(NSString *)url image:(NSString *)imageURL target:(QQTarget)scene callback:(void (^)(QQBaseResp *response))callback {
    self.handleQQ.QQCallback = callback;
    if (title.length > 200) {
        title = [title substringToIndex:199];
    }
    
    if (content.length > 50) {
        content = [content substringToIndex:49];
    }
    //分享图预览图URL地址
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:url]
                                title: title
                                description:content
                                previewImageURL:[NSURL URLWithString:imageURL]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    //将内容分享到qq
    if (scene == QQTargetSession) {
        [QQApiInterface sendReq:req];
    } else {
        //将内容分享到qzone
        [QQApiInterface SendReqToQZone:req];
    }
}

#pragma mark TencentSessionDelegate
- (void)tencentDidNotLogin:(BOOL)cancelled {
    
}

- (void)tencentDidNotNetWork {
    
}

- (void)tencentDidLogin {
    
}

- (void)tencentDidLogout {
    
}
#pragma mark - 微信
- (void)shareToWX:(NSString *)title content:(NSString *)content url:(NSString *)url image:(UIImage *)image target:(WXTarget)scene callback:(void (^)(BaseResp *response))callback {
    self.WXCallback = callback;
    
    WXMediaMessage *message = [WXMediaMessage message];
    
    if (title.length > 200) {
        title = [title substringToIndex:199];
    }
    message.title = title;
    
    if (content.length > 50) {
        content = [content substringToIndex:49];
    }
    message.description = content;
    
    CGImageRef cgRef = image.CGImage;
    CGImageRef imageRef = CGImageCreateWithImageInRect(cgRef, CGRectMake((image.size.width - image.size.height)/2,0, image.size.height, image.size.height));
    image = [UIImage imageWithCGImage:imageRef];
    image = [self makeThumbnailFromImage:image scale:128/image.size.height];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    while (imageData.length >= 32*1000) {
        image = [self makeThumbnailFromImage:image scale:0.9];
        imageData = UIImageJPEGRepresentation(image, 1.0);
    }
    [message setThumbImage:image];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    
    req.scene = scene==WXTargetSession?WXSceneSession:(scene==WXTargetTimeLine?WXSceneTimeline:WXSceneFavorite);
    
    [WXApi sendReq:req];
}

#pragma mark WXApiDelegate
- (void)onReq:(BaseReq *)req {}

- (void)onResp:(BaseResp *)resp {
    if (self.WXCallback) {
        self.WXCallback(resp);
    }
}



#pragma mark - 微博
- (void)shareToWeibo:(NSString *)content image:(UIImage *)image userInfo:(NSDictionary *)userInfo callback:(void (^)(WBBaseResponse *response))callback {
    self.WBCallback = callback;
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = kRedirectURI;
    authRequest.scope = @"all";
    WBMessageObject *message = [[WBMessageObject alloc] init];
    
    message.text = content;
    WBImageObject *imageOb = [[WBImageObject alloc] init];
    imageOb.imageData = UIImagePNGRepresentation(image);
    message.imageObject = imageOb;
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:nil];
    request.userInfo = userInfo;
    [WeiboSDK sendRequest:request];
}

#pragma mark WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request {}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    if (self.WBCallback) {
        self.WBCallback(response);
    }
}


#pragma mark 图片压缩
- (UIImage *)makeThumbnailFromImage:(UIImage *)srcImage scale:(double)imageScale {
    UIImage *thumbnail = nil;
    CGSize imageSize = CGSizeMake(srcImage.size.width * imageScale, srcImage.size.height * imageScale);
    if (srcImage.size.width != imageSize.width || srcImage.size.height != imageSize.height) {
        UIGraphicsBeginImageContext(imageSize);
        CGRect imageRect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
        [srcImage drawInRect:imageRect];
        thumbnail = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else {
        thumbnail = srcImage;
    }
    return thumbnail;
}

#pragma mark lazy
- (LHHandleQQ *)handleQQ {
    if (!_handleQQ) {
        _handleQQ = [[LHHandleQQ alloc] init];
    }
    return _handleQQ;
}
@end
