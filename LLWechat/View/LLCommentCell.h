//
//  LLCommentCell.h
//  LLWechat
//
//  Created by liushaohua on 2017/7/21.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LLCommentModel;

@interface LLCommentCell : UITableViewCell

///处理点赞的人列表
- (void)configCellWithLikeUsers:(NSArray *)likeUsers;
///处理评论的文字（包括xx回复yy）
- (void)configCellWithModel:(LLCommentModel *)model;

@end
