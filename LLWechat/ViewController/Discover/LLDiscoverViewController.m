//
//  LLDiscoverViewController.m
//  LLWechat
//
//  Created by liushaohua on 2017/7/21.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLDiscoverViewController.h"
#import "LLCommentViewController.h"

@interface LLDiscoverViewController ()

@end

@implementation LLDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    LLCommentViewController *vc = [LLCommentViewController new];
    [self.navigationController pushViewController:vc animated:YES];

}


@end
