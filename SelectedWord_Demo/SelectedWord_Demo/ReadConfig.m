//
//  ReadConfig.m
//  SelectedWord_Demo
//
//  Created by yangbin on 2017/7/14.
//  Copyright © 2017年 yangbin. All rights reserved.
//

#import "ReadConfig.h"

@implementation ReadConfig

+(instancetype)shareInstance
{
    static ReadConfig *readConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        readConfig = [[ReadConfig alloc] init];
        
    });
    return readConfig;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _lineSpace = 10.0f;
        _fontSize = 14.0f;
        _fontColor = [UIColor blackColor];
        _theme = [UIColor whiteColor];
        _readViewTopMargin = 7.50f;
        _readViewLeftMargin = 12.0f;
        
    }
    return self;
}

@end
