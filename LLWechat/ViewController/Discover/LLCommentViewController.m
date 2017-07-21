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
    commentModel.commentUserName = @"文明";
    commentModel.commentUserId = @"274";
    commentModel.commentPhoto = @"http://q.qlogo.cn/qqapp/1104706859/189AA89FAADD207E76D066059F924AE0/100";
    commentModel.commentByUserName = self.replyTheSelectedCellModel?self.replyTheSelectedCellModel.commentUserName:@"";
    commentModel.commentId = [NSString stringWithFormat:@"%i",[self getRandomNumber:100 to:1000]];
    commentModel.commentText = text;
    [messageModel.commentModelArray addObject:commentModel];
    
    messageModel.shouldUpdateCache = YES;
//    [self reloadCellHeightForModel:messageModel atIndexPath:self.currentIndexPath];
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


@end
