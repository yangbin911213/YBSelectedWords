//
//  ReadView.h
//  SelectedWord_Demo
//
//  Created by yangbin on 2017/7/14.
//  Copyright © 2017年 yangbin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>


@interface ReadView : UIView

@property (nonatomic,assign) CTFrameRef frameRef;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSArray *imageArray;
//@property (nonatomic,strong) id<LSYReadViewControllerDelegate>delegate;
-(void)cancelSelected;
@end
