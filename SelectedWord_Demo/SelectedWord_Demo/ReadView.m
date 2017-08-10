//
//  ReadView.m
//  SelectedWord_Demo
//
//  Created by yangbin on 2017/7/14.
//  Copyright © 2017年 yangbin. All rights reserved.
//

#import "ReadView.h"
#import "MagnifierView.h"
#import "ReadParser.h"
#import "ReadShareView.h"

#define ViewSize(view)  (view.frame.size)

@interface ReadView ()

@property (nonatomic,strong) MagnifierView *magnifierView;

@end

@implementation ReadView

{
    NSRange _selectRange;
    NSRange _calRange;
    NSArray *_pathArray;
    
    UIPanGestureRecognizer *_pan;
    //滑动手势有效区间
    CGRect _leftRect;
    CGRect _rightRect;
    
    CGRect _menuRect;
    //是否进入选择状态
    BOOL _selectState;
    BOOL _direction; //滑动方向  (0---左侧滑动 1 ---右侧滑动)
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addGestureRecognizer:({
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
            longPress;
        })];
        
        [self addGestureRecognizer:({
            UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
            pan;
            
        })];
    }
    return self;
}

#pragma mark - DRAW

- (void)drawRect:(CGRect)rect {
    
    if (!_frameRef) {
        return;
    }
    // 将文字画到画板上
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(ctx, CGAffineTransformIdentity);
    CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGRect leftDot,rightDot = CGRectZero;
    _menuRect = CGRectZero;
    [self drawSelectedPath:_pathArray LeftDot:&leftDot RightDot:&rightDot];
    CTFrameDraw(_frameRef, ctx);

//    if (_imageArray.count) {
//        for (LSYImageData * imageData in self.imageArray) {
//            UIImage *image = [UIImage imageWithContentsOfFile:imageData.url];
//            CFRange range = CTFrameGetVisibleStringRange(_frameRef);
//            
//            if (image&&(range.location<=imageData.position&&imageData.position<=(range.length + range.location))) {
//                [self fillImagePosition:imageData];
//                if (imageData.position==(range.length + range.location)) {
//                    if ([self showImage]) {
//                        CGContextDrawImage(ctx, imageData.imageRect, image.CGImage);
//                    }
//                    else{
//                        
//                    }
//                }
//                else{
//                    CGContextDrawImage(ctx, imageData.imageRect, image.CGImage);
//                }
//            }
//        }
//    }
    
    [self drawDotWithLeft:leftDot right:rightDot];

}

#pragma mark  PRIVATE METHOD

- (void)longPress:(UILongPressGestureRecognizer *)longPress {
    
    [self hiddenMenu];

    NSLog(@"-----------longPress----------");
    CGPoint point = [longPress locationInView:self];
    // 手指点击的位置要减去开始设置的画布内边距
    CGPoint finalPoint = CGPointMake(point.x - 12, point.y - 7.5);
    NSLog(@"---==%.2f-----==%.2f",finalPoint.x,finalPoint.y);
    if (longPress.state == UIGestureRecognizerStateBegan || longPress.state == UIGestureRecognizerStateChanged) {
        CGRect rect = [ReadParser parserRectWithPoint:finalPoint range:&_selectRange frameRef:_frameRef];

        self.magnifierView.touchPoint = finalPoint;

        if (!CGRectEqualToRect(rect, CGRectZero)) {
            _pathArray = @[NSStringFromCGRect(rect)];
            [self setNeedsDisplay];
            
    }
}
    
    if (longPress.state == UIGestureRecognizerStateEnded) {
        [self hiddenMagnifier];
        if (!CGRectEqualToRect(_menuRect, CGRectZero)) {
            [self showMenu];
        }
    }
}

- (void)pan:(UIPanGestureRecognizer *)pan {
    
    
    CGPoint point = [pan locationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
        [self showMagnifier];
        self.magnifierView.touchPoint = point;
        if (CGRectContainsPoint(_rightRect, point)||CGRectContainsPoint(_leftRect, point)) {
            if (CGRectContainsPoint(_leftRect, point)) {
                _direction = NO;   //从左侧滑动
            }
            else{
                _direction=  YES;    //从右侧滑动
            }
            _selectState = YES;
        }
        if (_selectState) {
            NSArray *path = [ReadParser parserRectsWithPoint:point range:&_selectRange frameRef:_frameRef paths:_pathArray direction:_direction];
            _pathArray = path;
            [self setNeedsDisplay];
        }
        
    }
    if (pan.state == UIGestureRecognizerStateEnded) {
        [self hiddenMagnifier];
        _selectState = NO;
        if (!CGRectEqualToRect(_menuRect, CGRectZero)) {
            [self showMenu];
        }
    }

}

-(void)showMenu
{
        [self becomeFirstResponder];

        UIMenuController *menuController = [UIMenuController sharedMenuController];
    
    // 方法不断调用，menu就会一闪一闪的不断显示，需要对此进行判断
    if (menuController.isMenuVisible) {
        
        return;
    }
    
        UIMenuItem *menuItemCopy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(menuCopy:)];
        UIMenuItem *menuItemNote = [[UIMenuItem alloc] initWithTitle:@"笔记" action:@selector(menuNote:)];
        UIMenuItem *menuItemShare = [[UIMenuItem alloc] initWithTitle:@"分享" action:@selector(menuShare:)];
        NSArray *menus = @[menuItemCopy,menuItemNote,menuItemShare];
        [menuController setMenuItems:menus];
        [menuController setTargetRect:CGRectMake(CGRectGetMidX(_menuRect), ViewSize(self).height-CGRectGetMidY(_menuRect), CGRectGetHeight(_menuRect), CGRectGetWidth(_menuRect)) inView:self];
        [menuController setMenuVisible:YES animated:YES];
        
    
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    //    NSLog(@"%@",NSStringFromSelector(action));
    
    if(action == @selector(menuCopy:) || action == @selector(menuNote:) || action == @selector(menuShare:)) return YES;
    return NO;
}


-(void)hiddenMenu
{
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
}


-(void)cancelSelected
{
    if (_pathArray) {
        _pathArray = nil;
        [self hiddenMenu];
        [self setNeedsDisplay];
    }
    
}

#pragma mark Menu Function
-(void)menuCopy:(id)sender
{
    [self hiddenMenu];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    [pasteboard setString:[_content substringWithRange:_selectRange]];

    NSLog(@"成功复制以下内容%@",pasteboard.string);
    
}

- (void)menuNote:(id)sender {
    
    
    
}

- (void)menuShare:(id)sender {
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];

    [pasteboard setString:[_content substringWithRange:_selectRange]];

    ReadShareView *shareView = [[ReadShareView alloc] initWithFrame:CGRectMake(0, 667, self.frame.size.width, 667)];

    [shareView addGestureRecognizer:({
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissShareImage:)];
        tap;
        
    })];
    
    [self addSubview:shareView];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        shareView.frame = CGRectMake(0, 0, shareView.frame.size.width, shareView.frame.size.height);
        [shareView createShareImage:pasteboard.string];
        
    } completion:^(BOOL finished) {
        
        [self gestureEdit:NO];

    }];
    
}

- (void)dismissShareImage:(UITapGestureRecognizer *)tap {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        tap.view.frame = CGRectMake(0, 667, self.frame.size.width, 667);
    } completion:^(BOOL finished) {
        
        [tap.view removeFromSuperview];
        [self gestureEdit:YES];

    }];
    
}

- (void)gestureEdit:(BOOL)isEdit {
    
            for (UIGestureRecognizer *ges in self.gestureRecognizers) {
                if ([ges isKindOfClass:[UIPanGestureRecognizer class]]) {
                    ges.enabled = isEdit;
                    break;
                }
            }
            for (UIGestureRecognizer *ges in self.gestureRecognizers) {
                if ([ges isKindOfClass:[UILongPressGestureRecognizer class]]) {
                    ges.enabled = isEdit;
                    break;
                }
            }
    
}

#pragma mark - TEXT->IMAGE

- (UIImage *)createShareImage:(NSString *)str {
    
    // 不要使用UIGraphicsBeginImageContext，不然图片会模糊
    
    UIImage *image = [UIImage imageNamed:@"123.jpg"];
    CGSize imageSize = CGSizeMake(image.size.width, image.size.height - 40);  // 画布大小
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    [image drawAtPoint:CGPointMake(0, 0)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawPath(context, kCGPathStroke);
    
    [str drawInRect:CGRectMake(0, 0, imageSize.width - 100, imageSize.height - 40) withAttributes:[ReadParser parserAttribute:[ReadConfig shareInstance]]];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
  
}

#pragma mark - Magnifier

-(void)showMagnifier
{
    if (!_magnifierView) {
        self.magnifierView = [[MagnifierView alloc] init];
        self.magnifierView.readView = self;
        [self addSubview:self.magnifierView];
    }
}

-(void)hiddenMagnifier
{
    if (_magnifierView) {
        [self.magnifierView removeFromSuperview];
        self.magnifierView = nil;
    }
}

#pragma mark  Draw Selected Path

-(void)drawSelectedPath:(NSArray *)array LeftDot:(CGRect *)leftDot RightDot:(CGRect *)rightDot{
    if (!array.count) {
        _pan.enabled = NO;
//        if ([self.delegate respondsToSelector:@selector(readViewEndEdit:)]) {
//            [self.delegate readViewEndEdit:nil];
//        }
        return;
    }
//    if ([self.delegate respondsToSelector:@selector(readViewEditeding:)]) {
//        [self.delegate readViewEditeding:nil];
//    }
    _pan.enabled = YES;
    CGMutablePathRef _path = CGPathCreateMutable();
    [[UIColor cyanColor] setFill];
    for (int i = 0; i < [array count]; i++) {
        CGRect rect = CGRectFromString([array objectAtIndex:i]);
        CGPathAddRect(_path, NULL, rect);
        if (i == 0) {
            *leftDot = rect;
            _menuRect = rect;
        }
        if (i == [array count]-1) {
            *rightDot = rect;
        }

    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddPath(ctx, _path);
    CGContextFillPath(ctx);
    CGPathRelease(_path);
    
}

-(void)drawDotWithLeft:(CGRect)Left right:(CGRect)right
{
    if (CGRectEqualToRect(CGRectZero, Left) || (CGRectEqualToRect(CGRectZero, right))){
        return;
    }
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGMutablePathRef _path = CGPathCreateMutable();
    [[UIColor orangeColor] setFill];
    CGPathAddRect(_path, NULL, CGRectMake(CGRectGetMinX(Left)-2, CGRectGetMinY(Left),2, CGRectGetHeight(Left)));
    CGPathAddRect(_path, NULL, CGRectMake(CGRectGetMaxX(right), CGRectGetMinY(right),2, CGRectGetHeight(right)));
    CGContextAddPath(ctx, _path);
    CGContextFillPath(ctx);
    CGPathRelease(_path);
    CGFloat dotSize = 15;
    _leftRect = CGRectMake(CGRectGetMinX(Left)-dotSize/2-10, ViewSize(self).height-(CGRectGetMaxY(Left)-dotSize/2-10)-(dotSize+20), dotSize+20, dotSize+20);
    _rightRect = CGRectMake(CGRectGetMaxX(right)-dotSize/2-10,ViewSize(self).height- (CGRectGetMinY(right)-dotSize/2-10)-(dotSize+20), dotSize+20, dotSize+20);
    CGContextDrawImage(ctx,CGRectMake(CGRectGetMinX(Left)-dotSize/2, CGRectGetMaxY(Left)-dotSize/2, dotSize, dotSize),[UIImage imageNamed:@"r_drag-dot"].CGImage);
    CGContextDrawImage(ctx,CGRectMake(CGRectGetMaxX(right)-dotSize/2, CGRectGetMinY(right)-dotSize/2, dotSize, dotSize),[UIImage imageNamed:@"r_drag-dot"].CGImage);
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)setFrameRef:(CTFrameRef)frameRef
{
    if (_frameRef != frameRef) {
        if (_frameRef) {
            CFRelease(_frameRef);
            _frameRef = nil;
        }
        _frameRef = frameRef;
    }
}
-(void)dealloc
{
    if (_frameRef) {
        CFRelease(_frameRef);
        _frameRef = nil;
    }
}
@end
