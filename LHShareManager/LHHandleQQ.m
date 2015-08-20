//
//  LHHandleQQ.m
//  gift
//
//  Created by 李允 on 15/8/19.
//  Copyright (c) 2015年 ZhuLuTianXia. All rights reserved.
//

#import "LHHandleQQ.h"

@implementation LHHandleQQ
#pragma mark QQApiInterfaceDelegate
- (void)isOnlineResponse:(NSDictionary *)response {}
- (void)onReq:(QQBaseReq *)req {}
- (void)onResp:(QQBaseResp *)resp {
    if (self.QQCallback) {
        self.QQCallback(resp);
    }
}
@end
