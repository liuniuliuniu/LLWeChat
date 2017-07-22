//
//  LLCopyLabel.m
//  LLWechat
//
//  Created by liushaohua on 2017/7/22.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLCopyLabel.h"

@implementation LLCopyLabel

- (instancetype)init{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuControllerWillHide) name:UIMenuControllerWillHideMenuNotification object:nil];
    }
    return self;
}


- (void)menuControllerWillHide{
    self.backgroundColor = [UIColor whiteColor];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:) || action == @selector(paste:) || action == @selector(customAction:));
}

#pragma mark - UIResponderStandardEditActions

- (void)copy:(id)sender {
    [[UIPasteboard generalPasteboard] setString:self.text];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)paste:(id)sender {
    NSString *toBePastedString = [[UIPasteboard generalPasteboard] string];
    self.text = toBePastedString;
    self.backgroundColor = [UIColor whiteColor];
}

- (void)customAction:(id)sender {
    NSLog(@"%s",__FUNCTION__);
    self.backgroundColor = [UIColor whiteColor];
}

- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];

}


@end
