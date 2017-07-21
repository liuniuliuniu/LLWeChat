//
//  LLPictureView.m
//  LLWechat
//
//  Created by liushaohua on 2017/7/21.
//  Copyright © 2017年 liushaohua. All rights reserved.
//

#import "LLPictureView.h"
#import "UIImageView+WebCache.h"



@implementation LLPictureView

- (instancetype)initWithFrame:(CGRect)frame dataSource:(NSArray *)dataSource completeBlock:(TapBlcok )tapBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        for (NSUInteger i=0; i<dataSource.count; i++) {
            UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(0+([LLPictureView imageWidth]+kPicture_GAP)*(i%3),floorf(i/3.0)*([LLPictureView imageHeight]+kPicture_GAP),[LLPictureView imageWidth], [LLPictureView imageHeight])];
            
            if ([dataSource[i] isKindOfClass:[UIImage class]]) {
                iv.image = dataSource[i];
            }else if ([dataSource[i] isKindOfClass:[NSString class]]){
                [iv sd_setImageWithURL:[NSURL URLWithString:dataSource[i]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
            }else if ([dataSource[i] isKindOfClass:[NSURL class]]){
                [iv sd_setImageWithURL:dataSource[i] placeholderImage:[UIImage imageNamed:@"placeholder"]];
            }
            self.dataSource = dataSource;
            self.tapBlock = tapBlock;// 一定要给self.tapBlock赋值
            iv.userInteractionEnabled = YES;//默认关闭NO，打开就可以接受点击事件
            iv.tag = i;
            [self addSubview:iv];
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageAction:)];
            [iv addGestureRecognizer:singleTap];
        }
    }
    return self;
}

-(void)LLPictureView:(LLPictureView *)pictureView DataSource:(NSArray *)dataSource completeBlock:(TapBlcok)tapBlock{
    
    for (NSUInteger i=0; i<dataSource.count; i++) {
        UIImageView *iv = [UIImageView new];
        if ([dataSource[i] isKindOfClass:[UIImage class]]) {
            iv.image = dataSource[i];
        }else if ([dataSource[i] isKindOfClass:[NSString class]]){
            [iv sd_setImageWithURL:[NSURL URLWithString:dataSource[i]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }else if ([dataSource[i] isKindOfClass:[NSURL class]]){
            [iv sd_setImageWithURL:dataSource[i] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }
        pictureView.dataSource = dataSource;
        pictureView.tapBlock = tapBlock;
        iv.userInteractionEnabled = YES;//默认关闭NO，打开就可以接受点击事件
        iv.tag = i;
        [pictureView addSubview:iv];
        //九宫格的布局
        CGFloat  Direction_X = (([LLPictureView imageWidth]+kPicture_GAP)*(i%3));
        CGFloat  Direction_Y  = (floorf(i/3.0)*([LLPictureView imageHeight]+kPicture_GAP));
        
        [iv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kPicture_GAP).offset(Direction_X);
            make.top.mas_equalTo(kPicture_GAP).offset(Direction_Y);
            make.size.mas_equalTo(CGSizeMake([LLPictureView imageWidth], [LLPictureView imageHeight]));
        }];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:pictureView action:@selector(tapImageAction:)];
        [iv addGestureRecognizer:singleTap];
    }
}


#pragma mark 配置图片的宽高
+(CGFloat)imageWidth{
    return ([UIScreen mainScreen].bounds.size.width-(2*kGAP+kAvatar_Size)*2)/3;
}
+(CGFloat)imageHeight{
    return ([UIScreen mainScreen].bounds.size.width-(2*kGAP+kAvatar_Size)*2)/3;
}

-(void)tapImageAction:(UITapGestureRecognizer *)tap{
    UIImageView *tapView = (UIImageView *)tap.view;
    
    SDPhotoBrowser *photoBrowser = [SDPhotoBrowser new];
    photoBrowser.delegate = self;
    photoBrowser.currentImageIndex = tapView.tag;
    photoBrowser.imageCount = _dataSource.count;
    photoBrowser.sourceImagesContainerView = self;
    [photoBrowser show];
    
    
    if (self.tapBlock) {
        self.tapBlock(tapView.tag,self.dataSource,self.indexpath);
    }
}

#pragma mark - SDPhotoBrowserDelegate

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSString *urlString = self.dataSource[index];
    return [NSURL URLWithString:urlString];
}
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    UIImageView *imageView = self.subviews[index];
    return imageView.image;
}



@end
