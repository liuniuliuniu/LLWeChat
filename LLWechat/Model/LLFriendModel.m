//
//  LLFriendModel.m
//  LLWechat
//
//  Created by liushaohua on 2017/7/21.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLFriendModel.h"

@implementation LLFriendModel

-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.userId      = dic[@"userId"];
        self.userName    = dic[@"userName"];
        self.photo       = dic[@"photo"];
        self.phoneNO     = dic[@"phoneNO"];
        
    }
    return self;
}


@end
