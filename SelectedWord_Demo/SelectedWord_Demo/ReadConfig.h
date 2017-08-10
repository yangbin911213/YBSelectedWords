//
//  ReadConfig.h
//  SelectedWord_Demo
//
//  Created by yangbin on 2017/7/14.
//  Copyright © 2017年 yangbin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ReadConfig : NSObject

@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat lineSpace;
@property (nonatomic, strong) UIColor *fontColor;
@property (nonatomic, strong) UIColor *theme;
@property (nonatomic, assign) CGFloat readViewTopMargin; // 上边距
@property (nonatomic, assign) CGFloat readViewLeftMargin; // 左边距

+(instancetype)shareInstance;

@end
