//
//  LLMessageCell.h
//  LLWechat
//
//  Created by liushaohua on 2017/7/21.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLPictureView.h"
#import "LLCommentCell.h"

@class LLMessageCell;
@class LLMessageModel;

@protocol LLMessageCellDelegate <NSObject>

- (void)reloadCellHeightForModel:(LLMessageModel *)model atIndexPath:(NSIndexPath *)indexPath;

- (void)passCellHeight:(CGFloat )cellHeight commentModel:(LLCommentModel *)commentModel   commentCell:(LLCommentCell *)commentCell messageCell:(LLMessageCell *)messageCell;

@end


@interface LLMessageCell : UITableViewCell

@property(nonatomic, strong)LLPictureView *pictureView;

/**
 *  评论按钮的block
 */
@property (nonatomic, copy)void(^CommentBtnClickBlock)(UIButton *commentBtn,NSIndexPath * indexPath);

/**
 *  更多按钮的block
 */
@property (nonatomic, copy)void(^MoreBtnClickBlock)(UIButton *moreBtn,NSIndexPath * indexPath);


/**
 *  TapBlcok
 */
@property (nonatomic, copy)TapBlcok  tapImageBlock;

/**
 *  点击文字的block
 */
@property (nonatomic, copy)void(^TapTextBlock)(UILabel *desLabel);

@property (nonatomic, weak) id<LLMessageCellDelegate> delegate;

- (void)configCellWithModel:(LLMessageModel *)model indexPath:(NSIndexPath *)indexPath;



@end
