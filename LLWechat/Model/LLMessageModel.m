//
//  LLMessageModel.m
//  LLWechat
//
//  Created by liushaohua on 2017/7/21.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLMessageModel.h"


@implementation LLMessageModel


-(NSMutableArray *)commentModelArray{
    if (_commentModelArray==nil) {
        _commentModelArray = [NSMutableArray array];
    }
    return _commentModelArray;
}

-(NSMutableArray *)messageSmallPics{
    if (_messageSmallPics==nil) {
        _messageSmallPics = [NSMutableArray array];
    }
    return _messageSmallPics;
}

-(NSMutableArray *)messageBigPics{
    if (_messageBigPics==nil) {
        _messageBigPics = [NSMutableArray array];
    }
    return _messageBigPics;
}
-(NSMutableArray *)likeUsers{
    if (_likeUsers==nil) {
        _likeUsers = [NSMutableArray array];
    }
    return _likeUsers;
}



-(instancetype)initWithDic:(NSDictionary *)dic{
    self = [super init];
    if (self) {
        self.cid                = dic[@"cid"];
        self.shouldUpdateCache  = NO;
        self.message_id         = dic[@"message_id"];
        self.message            = dic[@"message"];
        self.timeTag            = dic[@"timeTag"];
        self.message_type       = dic[@"message_type"];
        self.userId             = dic[@"userId"];
        self.userName           = dic[@"userName"];
        self.likeUsers          = dic[@"likeUsers"];
        self.photo              = dic[@"photo"];
        self.messageSmallPics   = dic[@"messageSmallPics"];
        self.messageBigPics     = dic[@"messageBigPics"];
        for (NSDictionary *eachDic in dic[@"commentMessages"] ) {
            LLCommentModel *commentModel = [[LLCommentModel alloc] initWithDic:eachDic];
            [self.commentModelArray addObject:commentModel];
        }
    }
    return self;
}


@end
