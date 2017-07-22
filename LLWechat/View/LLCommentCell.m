//
//  LLCommentCell.m
//  LLWechat
//
//  Created by liushaohua on 2017/7/21.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLCommentCell.h"
#import "LLCommentModel.h"

@interface LLCommentCell ()

@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation LLCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = NO;
        self.contentLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.contentLabel];
        self.contentLabel.backgroundColor  = [UIColor clearColor];
        self.contentLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - kGAP-kAvatar_Size - 2*kGAP;
        self.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.font = [UIFont systemFontOfSize:13.0];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.contentView);
            make.top.mas_equalTo(self.contentView).offset(7.0);//cell上部距离为3.0个间隙
        }];
        self.backgroundColor = [UIColor clearColor];
        self.hyb_lastViewInCell = self.contentLabel;
        self.hyb_bottomOffsetToCell = 0.0;//cell底部距离为3.0个间隙                
    }
    return self;
}


- (void)configCellWithLikeUsers:(NSArray *)likeUsers {
    NSString *allString = @"";
    for (NSString *name in likeUsers) {
        allString = [NSString stringWithFormat:@"%@,%@",allString,name];
    }
    self.contentLabel.text = [allString substringFromIndex:1];
}


- (void)configCellWithModel:(LLCommentModel *)model {
    NSString *str  = nil;
    if (![model.commentByUserName isEqualToString:@""]) {
        str= [NSString stringWithFormat:@"%@回复%@：%@",
              model.commentUserName, model.commentByUserName, model.commentText];
    }else{
        str= [NSString stringWithFormat:@"%@：%@",
              model.commentUserName, model.commentText];
    }
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:str];
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor blueColor]
                 range:NSMakeRange(0, model.commentUserName.length)];
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor blueColor]
                 range:NSMakeRange(model.commentUserName.length + 2, model.commentByUserName.length)];
    self.contentLabel.attributedText = text;
}





@end
