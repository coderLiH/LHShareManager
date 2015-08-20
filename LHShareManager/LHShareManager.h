//
//  LHShareManager.h
//  gift
//
//  Created by 李允 on 15/8/18.
//  Copyright (c) 2015年 ZhuLuTianXia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WBBaseResponse,BaseResp,QQBaseResp;

typedef NS_ENUM(NSUInteger, WXTarget) {
    WXTargetSession,    // 聊天
    WXTargetTimeLine,   // 朋友圈
    WXTargetFav         // 收藏
};


typedef NS_ENUM(NSUInteger, QQTarget) {
    QQTargetSession,    // 聊天
    QQTargetZone        // QQ空间
};


@interface LHShareManager : NSObject
DECLARE_SHARED_INSTANCE(LHShareManager);
- (void)configShareInfo;

- (void)handleURL:(NSURL *)url;

/**
 *  分享到qq
 *
 *  @param title    标题
 *  @param content  内容
 *  @param url      url
 *  @param imageURL 图片url
 *  @param scene    方式(qq、空间)
 *  @param callback 回调
 */
- (void)shareToQQ:(NSString *)title content:(NSString *)content url:(NSString *)url image:(NSString *)imageURL target:(QQTarget)scene callback:(void (^)(QQBaseResp *response))callback;

/**
 *  分享到微信
 *
 *  @param title    标题
 *  @param content  内容
 *  @param url      url
 *  @param image    图片,无需压缩
 *  @param scene    目标(聊天、朋友圈、收藏)
 *  @param callback 回调
 */
- (void)shareToWX:(NSString *)title content:(NSString *)content url:(NSString *)url image:(UIImage *)image target:(WXTarget)scene callback:(void (^)(BaseResp *response))callback;
/**
 *  分享到微薄
 *
 *  @param content  内容
 *  @param image    图片
 *  @param userInfo 回调时的信息
 *  @param callback 回调
 */
- (void)shareToWeibo:(NSString *)content image:(UIImage *)image userInfo:(NSDictionary *)userInfo callback:(void (^)(WBBaseResponse *response))callback;
@end
