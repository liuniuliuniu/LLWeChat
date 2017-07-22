//
//  LLCommentViewController.m
//  LLWechat
//
//  Created by liushaohua on 2017/7/21.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLCommentViewController.h"

#import "LLMessageModel.h"
#import "LLMessageCell.h"

#import "ChatKeyBoard.h"
#import "FaceSourceManager.h"

#import "ChatToolBarItem.h"
#import "FaceThemeModel.h"


@interface LLCommentViewController ()<ChatKeyBoardDelegate, ChatKeyBoardDataSource,UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate,LLMessageCellDelegate>

// 键盘
@property (nonatomic, strong) ChatKeyBoard *chatKeyBoard;
@property (nonatomic, assign) CGFloat history_Y_offset;//记录table的offset.y
@property (nonatomic, assign) CGFloat seletedCellHeight;//记录点击cell的高度，高度由代理传过来
@property (nonatomic, assign) BOOL isShowKeyBoard;//记录点击cell的高度，高度由代理传过来

// 专门用来回复选中的cell的Model
@property(nonatomic, strong)LLCommentModel *replyTheSelectedCellModel;

@property (nonatomic, assign) BOOL needUpdateOffset;//控制是否刷新table的offset

@property (nonatomic,copy)NSIndexPath *currentIndexPath;

@end

@implementation LLCommentViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        
        
        //注册键盘出现NSNotification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification object:nil];
        
        
        //注册键盘隐藏NSNotification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification object:nil];

    }
    
    return self;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"朋友圈";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[YYFPSLabel alloc]initWithFrame:CGRectMake(0, 5, 60, 30)]];
    
    [self dealData];
    
    UIImageView * backgroundImageView= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 260)];
    backgroundImageView.image = [UIImage imageNamed:@"background.jpeg"];
    self.tableView.tableHeaderView = backgroundImageView;
    
    [self registerCellWithClass:@"LLMessageCell" tableView:self.tableView];

    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).with.offset(-kNavbarHeight);
    }];
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LLMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LLMessageCell" forIndexPath:indexPath];    
    cell.delegate = self;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    __weak __typeof(self) weakSelf= self;
    __weak __typeof(tableView) weakTable= tableView;
    __weak __typeof(window) weakWindow= window;
    
    __block LLMessageModel *model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configCellWithModel:model indexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.MoreBtnClickBlock = ^(UIButton *moreBtn,NSIndexPath * indexPath)
    {
        if (self.isShowKeyBoard) {
            [self.view endEditing:YES];
            return ;
        }
        
        [weakSelf.chatKeyBoard keyboardDownForComment];
        weakSelf.chatKeyBoard.placeHolder = nil;
        model.isExpand = !model.isExpand;
        model.shouldUpdateCache = YES;
        [weakTable reloadData];
                
    };
    
    
    //评论
    cell.CommentBtnClickBlock = ^(UIButton *commentBtn,NSIndexPath * indexPath)
    {
        
        if (self.isShowKeyBoard) {
            [self.view endEditing:YES];
            return ;
        }
        
        //不是点击cell进行回复，则置空replayTheSeletedCellModel，因为这个时候是点击评论按钮进行评论，不是回复某某某
        self.replyTheSelectedCellModel = nil;
        weakSelf.seletedCellHeight = 0.0;
        weakSelf.needUpdateOffset = YES;
        weakSelf.chatKeyBoard.placeHolder = [NSString stringWithFormat:@"评论 %@",model.userName];
        weakSelf.history_Y_offset = [commentBtn convertRect:commentBtn.bounds toView:weakWindow].origin.y;
        weakSelf.currentIndexPath = indexPath;
        [weakSelf.chatKeyBoard keyboardUpforComment];
    };
    

    
    
    //点击九宫格
    cell.tapImageBlock = ^(NSInteger index,NSArray *dataSource,NSIndexPath *indexpath){
        if (self.isShowKeyBoard) {
            [self.view endEditing:YES];
            return ;
        }
        [weakSelf.chatKeyBoard keyboardDownForComment];
    };
    
    
    
    //点击文字
    cell.TapTextBlock=^(UILabel *desLabel){
        if (self.isShowKeyBoard) {
            [self.view endEditing:YES];
            return ;
        }
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:desLabel.text delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    };
        
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    LLMessageModel *messageModel = [self.dataSource objectAtIndex:indexPath.row];
    
    CGFloat h = [LLMessageCell hyb_heightForTableView:tableView config:^(UITableViewCell *sourceCell) {
        
        LLMessageCell *cell = (LLMessageCell *)sourceCell;
        [cell configCellWithModel:messageModel indexPath:indexPath];
        
        
    } cache:^NSDictionary *{
        
        NSDictionary *cache = @{kHYBCacheUniqueKey : messageModel.cid,
                                kHYBCacheStateKey  : @"",
                                kHYBRecalculateForStateKey : @(messageModel.shouldUpdateCache)};
        messageModel.shouldUpdateCache = NO;
        return cache;
        
    }];
    return h;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isShowKeyBoard) {
        [self.view endEditing:YES];
    }
}


#pragma mark - passCellHeightWithModel
-(void)passCellHeight:(CGFloat)cellHeight commentModel:(LLCommentModel *)commentModel commentCell:(LLCommentCell *)commentCell messageCell:(LLMessageCell *)messageCell{
    if (self.isShowKeyBoard) {
        [self.view endEditing:YES];
        return ;
    }
    self.needUpdateOffset = YES;
    self.replyTheSelectedCellModel = commentModel;
    self.currentIndexPath = [self.tableView indexPathForCell:messageCell];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.chatKeyBoard.placeHolder = [NSString stringWithFormat:@"回复 %@",commentModel.commentUserName];
    self.history_Y_offset = [commentCell convertRect:commentCell.bounds toView:window].origin.y;
    self.seletedCellHeight = cellHeight;
    [self.chatKeyBoard keyboardUpforComment];
}

- (void)reloadCellHeightForModel:(LLMessageModel *)model atIndexPath:(NSIndexPath *)indexPath{
    model.shouldUpdateCache = YES;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}




#pragma mark - 加载数据
-(void)dealData{
    self.dataSource = [[NSMutableArray alloc]init];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"json"]]];
    NSDictionary *JSONDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    for (NSDictionary *eachDic in JSONDic[@"data"][@"rows"]) {
        LLMessageModel *messageModel = [[LLMessageModel alloc] initWithDic:eachDic];
        [self.dataSource addObject:messageModel];
    }
}


#pragma mark - 键盘的处理

- (NSArray<ChatToolBarItem *> *)chatKeyBoardToolbarItems
{
    ChatToolBarItem *item1 = [ChatToolBarItem barItemWithKind:kBarItemFace normal:@"face" high:@"face_HL" select:@"keyboard"];
    
    return @[item1];
    
}

- (NSArray<FaceThemeModel *> *)chatKeyBoardFacePanelSubjectItems
{
    return [FaceSourceManager loadFaceSource];
}


-(ChatKeyBoard *)chatKeyBoard{
    if (_chatKeyBoard==nil) {
        _chatKeyBoard =[ChatKeyBoard keyBoardWithNavgationBarTranslucent:YES];
        _chatKeyBoard.delegate = self;
        _chatKeyBoard.dataSource = self;
        _chatKeyBoard.keyBoardStyle = KeyBoardStyleComment;
        _chatKeyBoard.allowVoice = NO;
        _chatKeyBoard.allowMore = NO;
        _chatKeyBoard.allowSwitchBar = NO;
        _chatKeyBoard.placeHolder = @"评论";
        [self.view addSubview:_chatKeyBoard];
        [self.view bringSubviewToFront:_chatKeyBoard];
    }
    return _chatKeyBoard;
}


//  键盘评论的代理方法
- (void)chatKeyBoardSendText:(NSString *)text{
    LLMessageModel *messageModel = [self.dataSource objectAtIndex:self.currentIndexPath.row];
    messageModel.shouldUpdateCache = YES;
    
    //创建一个新的CommentModel,并给相应的属性赋值，然后加到评论数组的最后，reloadData
    LLCommentModel *commentModel = [[LLCommentModel alloc]init];
    commentModel.commentUserName = @"奥卡姆剃须刀";
    commentModel.commentUserId = @"274";
    commentModel.commentPhoto = @"http://q.qlogo.cn/qqapp/1104706859/189AA89FAADD207E76D066059F924AE0/100";
    commentModel.commentByUserName = self.replyTheSelectedCellModel?self.replyTheSelectedCellModel.commentUserName:@"";
    commentModel.commentId = [NSString stringWithFormat:@"%i",[self getRandomNumber:100 to:1000]];
    commentModel.commentText = text;
    [messageModel.commentModelArray addObject:commentModel];
    
    messageModel.shouldUpdateCache = YES;
    [self reloadCellHeightForModel:messageModel atIndexPath:self.currentIndexPath];
    [self.chatKeyBoard keyboardDownForComment];
    self.chatKeyBoard.placeHolder = nil;
    
    
}
- (void)chatKeyBoardFacePicked:(ChatKeyBoard *)chatKeyBoard faceStyle:(NSInteger)faceStyle faceName:(NSString *)faceName delete:(BOOL)isDeleteKey{
    NSLog(@"%@",faceName);
}
- (void)chatKeyBoardAddFaceSubject:(ChatKeyBoard *)chatKeyBoard{
    NSLog(@"%@",chatKeyBoard);
}
- (void)chatKeyBoardSetFaceSubject:(ChatKeyBoard *)chatKeyBoard{
    NSLog(@"%@",chatKeyBoard);
    
}

#pragma mark keyboardWillShow
- (void)keyboardWillShow:(NSNotification *)notification
{
    self.isShowKeyBoard = YES;
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    __block  CGFloat keyboardHeight = [aValue CGRectValue].size.height;
    if (keyboardHeight==0) {
        //解决搜狗输入法三次调用此方法的bug、
        //        IOS8.0之后可以安装第三方键盘，如搜狗输入法之类的。
        //        获得的高度都为0.这是因为键盘弹出的方法:- (void)keyBoardWillShow:(NSNotification *)notification需要执行三次,你如果打印一下,你会发现键盘高度为:第一次:0;第二次:216:第三次:282.并不是获取不到高度,而是第三次才获取真正的高度.
        return;
    }
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    CGFloat delta = 0.0;
    if (self.seletedCellHeight){//点击某行，进行回复某人
        delta = self.history_Y_offset - ([UIApplication sharedApplication].keyWindow.bounds.size.height - keyboardHeight-self.seletedCellHeight-kChatToolBarHeight);
    }else{//点击评论按钮
        delta = self.history_Y_offset - ([UIApplication sharedApplication].keyWindow.bounds.size.height - keyboardHeight-kChatToolBarHeight-24-10);//24为评论按钮高度，10为评论按钮上部的5加评论按钮下部的5
    }
    CGPoint offset = self.tableView.contentOffset;
    offset.y += delta;
    if (offset.y < 0) {
        offset.y = 0;
    }
    if (self.needUpdateOffset) {
        [self.tableView setContentOffset:offset animated:YES];
    }
}
#pragma mark
#pragma mark keyboardWillHide
- (void)keyboardWillHide:(NSNotification *)notification {
    self.isShowKeyBoard = NO;
    self.needUpdateOffset = NO;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"CommentViewController dealloc");
}




@end
