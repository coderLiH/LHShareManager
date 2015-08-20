//
//  LHHandleQQ.h
//  gift
//
//  Created by 李允 on 15/8/19.
//  Copyright (c) 2015年 ZhuLuTianXia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/QQApiInterface.h>

@interface LHHandleQQ : NSObject <QQApiInterfaceDelegate>
@property (nonatomic, copy) void (^QQCallback)(QQBaseResp *);
@end
