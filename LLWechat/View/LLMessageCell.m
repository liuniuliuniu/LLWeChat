//
//  LLMessageCell.m
//  LLWechat
//
//  Created by liushaohua on 2017/7/21.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLMessageCell.h"
#import "LLMessageModel.h"
#import "WMPlayer.h"
#import "LLCopyLabel.h"

@interface LLMessageCell ()<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) LLCopyLabel *descLabel;
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIButton *commentBtn;
@property (nonatomic, strong) WMPlayer *wmplayer;
@property (nonatomic, strong) LLMessageModel *messageModel;
@property (nonatomic, copy) NSIndexPath *indexPath;
@end

@implementation LLMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    self.selectionStyle = NO;
    
    
    self.headImageView = [[UIImageView alloc] init];
    self.headImageView.backgroundColor = [UIColor whiteColor];
    self.headImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.headImageView];
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(kGAP);
        make.width.height.mas_equalTo(kAvatar_Size);
    }];
    
    self.nameLabel = [UILabel new];
    [self.contentView addSubview:self.nameLabel];
    self.nameLabel.textColor = [UIColor colorWithRed:(54/255.0) green:(71/255.0) blue:(121/255.0) alpha:0.9];
    self.nameLabel.preferredMaxLayoutWidth = KScreenWidth - kGAP-kAvatar_Size - 2*kGAP-kGAP;
    self.nameLabel.numberOfLines = 0;
    self.nameLabel.font = [UIFont systemFontOfSize:14.0];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImageView.mas_right).offset(10);
        make.top.mas_equalTo(self.headImageView);
        make.right.mas_equalTo(-kGAP);
    }];
    
    self.descLabel = [LLCopyLabel new];
    self.descLabel.backgroundColor = [UIColor whiteColor];
//    UITapGestureRecognizer *tapText = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapText:)];
    
    UIGestureRecognizer * longPressText = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    
    [self.descLabel addGestureRecognizer:longPressText];
    [self.contentView addSubview:self.descLabel];
    self.descLabel.preferredMaxLayoutWidth = KScreenWidth - kGAP-kAvatar_Size ;
    
    /*
     NSLineBreakByWordWrapping = 0,         // Wrap at word boundaries, default
     NSLineBreakByCharWrapping,     // Wrap at character boundaries
     NSLineBreakByClipping,     // Simply clip 裁剪从前面到后面显示多余的直接裁剪掉
     
     文字过长 button宽度不够时: 省略号显示位置...
     NSLineBreakByTruncatingHead,   // Truncate at head of line: "...wxyz" 前面显示
     NSLineBreakByTruncatingTail,   // Truncate at tail of line: "abcd..." 后面显示
     NSLineBreakByTruncatingMiddle  // Truncate middle of line:  "ab...yz" 中间显示省略号
     */
    
    self.descLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.descLabel.numberOfLines = 0;
    self.descLabel.font = [UIFont systemFontOfSize:13.0];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.nameLabel);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(kGAP);
    }];
    
    
    
    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreBtn setTitle:@"全文" forState:UIControlStateNormal];
    [self.moreBtn setTitle:@"收起" forState:UIControlStateSelected];
    [self.moreBtn setTitleColor:[UIColor colorWithRed:92/255.0 green:140/255.0 blue:193/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.moreBtn setTitleColor:[UIColor colorWithRed:92/255.0 green:140/255.0 blue:193/255.0 alpha:1.0] forState:UIControlStateSelected];
    
    
    self.moreBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    self.moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.moreBtn.selected = NO;
    [self.moreBtn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.moreBtn];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.descLabel);
        make.top.mas_equalTo(self.descLabel.mas_bottom);
    }];

    self.pictureView = [LLPictureView new];
    [self.contentView addSubview:self.pictureView];
    
    [self.pictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.moreBtn);
        make.top.equalTo(self.moreBtn.mas_bottom).offset(kGAP);
    }];
    
    
    self.commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.commentBtn.backgroundColor = [UIColor whiteColor];
    [self.commentBtn setTitle:@"评论" forState:UIControlStateNormal];
    [self.commentBtn setTitle:@"评论" forState:UIControlStateSelected];
    [self.commentBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.commentBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.commentBtn.layer.borderWidth = 1;
    self.commentBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [self.commentBtn setImage:[UIImage imageNamed:@"commentBtn"] forState:UIControlStateNormal];
    [self.commentBtn setImage:[UIImage imageNamed:@"commentBtn"] forState:UIControlStateSelected];
    
    [self.commentBtn addTarget:self action:@selector(commentAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.commentBtn];
    self.commentBtn.layer.cornerRadius = 24/2;
    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.descLabel);
        make.top.mas_equalTo(self.pictureView.mas_bottom).offset(kGAP);
        make.width.mas_equalTo(55);
        make.height.mas_equalTo(24);
    }];
    
    
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.scrollEnabled = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:NSClassFromString(@"LLCommentCell") forCellReuseIdentifier:@"LLCommentCell"];
    
    UIImage *image = [UIImage imageNamed:@"LikeCmtBg"];
    image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
    self.tableView.backgroundView = [[UIImageView alloc]initWithImage:image];
    [self.contentView addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.pictureView);
        make.top.mas_equalTo(self.commentBtn.mas_bottom).offset(kGAP);
        make.right.mas_equalTo(-kGAP);
    }];
    self.tableView.separatorStyle = NO;
    
    // 最后一个的
    self.hyb_lastViewInCell = self.tableView;
    self.hyb_bottomOffsetToCell = kGAP;
    
}

- (void)moreAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (self.MoreBtnClickBlock) {
        self.MoreBtnClickBlock(sender,self.indexPath);
    }
    
}


- (void)commentAction:(UIButton *)sender{
    if (self.CommentBtnClickBlock) {
        self.CommentBtnClickBlock(sender,self.indexPath);
    }
}


- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer{
    
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [recognizer.view becomeFirstResponder];
        
        UILabel *lbl = (UILabel *)recognizer.view;
        
        lbl.backgroundColor = [UIColor lightGrayColor];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        
        // add a custom menu item
        UIMenuItem *customItem = [[UIMenuItem alloc] initWithTitle:@"Custom" action:@selector(customAction:)];
        menuController.menuItems = [NSArray arrayWithObject:customItem];
        
        [menuController setTargetRect:recognizer.view.frame inView:recognizer.view.superview];
        [menuController setMenuVisible:YES animated:YES];        
    }
}

- (void)configCellWithModel:(LLMessageModel *)model indexPath:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    
    self.nameLabel.text = model.userName;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.photo] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    self.messageModel = model;
    NSMutableParagraphStyle *muStyle = [[NSMutableParagraphStyle alloc]init];
    muStyle.lineSpacing = 3;//设置行间距离
    muStyle.alignment = NSTextAlignmentLeft;//对齐方式

    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:model.message];
    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(0, attrString.length)];
    
//    [attrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, attrString.length)];//下划线
    [attrString addAttribute:NSParagraphStyleAttributeName value:muStyle range:NSMakeRange(0, attrString.length)];
    self.descLabel.attributedText = attrString;
    
    self.descLabel.highlightedTextColor = [UIColor blackColor];//设置文本高亮显示颜色，与highlighted一起使用。
    self.descLabel.highlighted = YES; //高亮状态是否打开
    self.descLabel.enabled = YES;//设置文字内容是否可变
    self.descLabel.userInteractionEnabled = YES;//设置标签是否忽略或移除用户交互。默认为NO
    
    
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:13.0],NSParagraphStyleAttributeName:muStyle};
    
    CGFloat h = [model.message boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - kGAP-kAvatar_Size - 2*kGAP, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.height+0.5;
    
    if (h<=60) {
        [self.moreBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.descLabel);
            make.top.mas_equalTo(self.descLabel.mas_bottom);
            make.size.mas_equalTo(CGSizeMake(0, 0));
        }];
    }else{
        
        [self.moreBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.descLabel);
            make.top.mas_equalTo(self.descLabel.mas_bottom);
        }];
    }
    
    
    if (model.isExpand) {//展开
        [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.nameLabel);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(kGAP);
            make.height.mas_equalTo(h);
        }];
    }else{//闭合
        [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.nameLabel);
            make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(kGAP);
            make.height.mas_lessThanOrEqualTo(60);
        }];
    }
    self.moreBtn.selected = model.isExpand;
    
    
    CGFloat picV_height = 0.0;
    CGFloat picV_width = 0.0;
    if (model.messageBigPics.count>0&&model.messageBigPics.count<=3) {
        picV_height = [LLPictureView imageHeight];
        picV_width  = (model.messageBigPics.count)*([LLPictureView imageWidth]+kPicture_GAP)-kPicture_GAP;
    }else if (model.messageBigPics.count>3&&model.messageBigPics.count<=6){
        picV_height = 2*([LLPictureView imageHeight]+kPicture_GAP)-kPicture_GAP;
        picV_width  = 3*([LLPictureView imageWidth]+kPicture_GAP)-kPicture_GAP;
    }else  if (model.messageBigPics.count>6&&model.messageBigPics.count<=9){
        picV_height = 3*([LLPictureView imageHeight]+kPicture_GAP)-kPicture_GAP;
        picV_width  = 3*([LLPictureView imageWidth]+kPicture_GAP)-kPicture_GAP;
    }
    ///解决图片复用问题
    [self.pictureView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    ///布局九宫格
    [self.pictureView LLPictureView:self.pictureView DataSource:model.messageBigPics completeBlock:^(NSInteger index, NSArray *dataSource, NSIndexPath *indexpath) {
        if (self.tapImageBlock) {
            self.tapImageBlock(index, dataSource, self.indexPath);
        }
    }];
    
    [self.pictureView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.moreBtn);
        make.top.mas_equalTo(self.moreBtn.mas_bottom).offset(kPicture_GAP);
        make.size.mas_equalTo(CGSizeMake(picV_width, picV_height));
    }];
    
    
    CGFloat tableViewHeight = 0;
    for (LLCommentModel *commentModel in model.commentModelArray) {
        CGFloat cellHeight = [LLCommentCell hyb_heightForTableView:self.tableView config:^(UITableViewCell *sourceCell) {
            LLCommentCell *cell = (LLCommentCell *)sourceCell;
            [cell configCellWithModel:commentModel];
        } cache:^NSDictionary *{
            return @{kHYBCacheUniqueKey : commentModel.commentId,
                     kHYBCacheStateKey : @"",
                     kHYBRecalculateForStateKey : @(YES)};
        }];
        tableViewHeight += cellHeight;
    }
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tableViewHeight+30);
    }];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView reloadData];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LLCommentCell" forIndexPath:indexPath];
    if (self.messageModel.likeUsers.count) {
        if (indexPath.row==0) {
            [cell configCellWithLikeUsers:self.messageModel.likeUsers];
            return cell;
        }
    }
    
    NSInteger index = self.messageModel.likeUsers.count?(indexPath.row-1):(indexPath.row);
    LLCommentModel *model = [self.messageModel.commentModelArray objectAtIndex:index];
    [cell configCellWithModel:model];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.messageModel.commentModelArray.count;
    if (self.messageModel.likeUsers.count) {
        return count+1;
    }
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.messageModel.likeUsers.count) {
        if (indexPath.row==0) {
            return 30;
        }
    }
    
    NSInteger index = self.messageModel.likeUsers.count?(indexPath.row-1):(indexPath.row);
    
    LLCommentModel *model = [self.messageModel.commentModelArray objectAtIndex:index];
    CGFloat cell_height = [LLCommentCell hyb_heightForTableView:self.tableView config:^(UITableViewCell *sourceCell) {
        LLCommentCell *cell = (LLCommentCell *)sourceCell;
        [cell configCellWithModel:model];
    } cache:^NSDictionary *{
        NSDictionary *cache = @{kHYBCacheUniqueKey : model.commentId,
                                kHYBCacheStateKey : @"",
                                kHYBRecalculateForStateKey : @(NO)};
        // model.shouldUpdateCache = NO;
        return cache;
    }];
    return cell_height;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.indexPath = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.messageModel.likeUsers.count) {
        if (indexPath.row==0) {
            return;
        }
    }
    NSInteger index = self.messageModel.likeUsers.count?(indexPath.row-1):(indexPath.row);
    LLCommentModel *commentModel = [self.messageModel.commentModelArray objectAtIndex:index];
    CGFloat cell_height = [LLCommentCell hyb_heightForTableView:self.tableView config:^(UITableViewCell *sourceCell) {
        
        LLCommentCell *cell = (LLCommentCell *)sourceCell;
        
        [cell configCellWithModel:commentModel];
        
    } cache:^NSDictionary *{
        NSDictionary *cache = @{kHYBCacheUniqueKey : commentModel.commentId,
                                kHYBCacheStateKey : @"",
                                kHYBRecalculateForStateKey : @(NO)};
        //        model.shouldUpdateCache = NO;
        return cache;
    }];
    
    if ([self.delegate respondsToSelector:@selector(passCellHeight:commentModel:commentCell:messageCell:)]) {
        LLCommentCell *commetCell =  (LLCommentCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        [self.delegate passCellHeight:cell_height commentModel:commentModel commentCell:commetCell messageCell:self];
        
    }
    
}




@end
