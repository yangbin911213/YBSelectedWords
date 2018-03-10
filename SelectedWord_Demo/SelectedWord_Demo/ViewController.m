//
//  ViewController.m
//  SelectedWord_Demo
//
//  Created by yangbin on 2017/7/14.
//  Copyright © 2017年 yangbin. All rights reserved.
//

#import "ViewController.h"
#import "ReadView.h"
#import "ReadConfig.h"
#import "ReadParser.h"

@interface ViewController ()<UIGestureRecognizerDelegate>

// 显示的内容
@property (nonatomic, copy) NSString *content;
// 文本视图
@property (nonatomic, strong) ReadView *readView;


@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _content = @"《民调局异闻录》全集(1-6部全)【精校版】\r\n\r\n作者：耳东水寿(陈涛)\r\n\r\n【由Zei8.com贼吧网[Zei8.com 贼吧电子书]整理，版权归作者或出版社所有，本站仅提供预览，如侵犯您的权益，请联系本站删除。】\r\n\r\n《民调局异闻录第一部：苗乡巫祖》\r\n\r\n内容简介\r\n\r\n一九八七年，大火后的大兴安岭发现一具长着獠牙的活焦尸，解放军官兵在付出巨大代价后才将其制服，由沈辣的三叔沈援朝负责押送回北京。运送途中，焦尸再次复活，危急之时，一名神秘白发人出现，轻松便把复活的焦尸消灭掉。\r\n\r\n十几年后，天生阴阳眼的沈辣参军，被选入特种部队。在一次随队追剿毒枭的任务中，误入云南边境的一个神秘山洞；山洞内远古祭祀干尸纷纷复活，向沈辣小队发动疯狂攻击。这时，神秘白发人再次出现，将沈辣等人救出。\r\n";
    // lalall
    
    [self prefersStatusBarHidden];
    [self.view setBackgroundColor:[ReadConfig shareInstance].theme];
    [self.view addSubview:self.readView];
    
    [self.view addGestureRecognizer:({
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showToolMenu)];
        tap.delegate = self;
        tap;
    })];
    
    // 1223124142jfsjf
    
    // 看；方式开发；拉克丝；开发fsfsfsdfsfsdfsdfsd
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showToolMenu {
    
    [self.readView cancelSelected];
}

- (ReadView *)readView {
    
    if (!_readView) {
        _readView = [[ReadView alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width , self.view.frame.size.height-60 )];
        ReadConfig *config = [ReadConfig shareInstance];
        
        _readView.frameRef = [ReadParser parserContent:_content config:config bouds:CGRectMake(12,7.5, _readView.frame.size.width - 24, _readView.frame.size.height - 15)];
        _readView.content = _content;
//        _readView.delegate = self;
    }
    return _readView;
}

@end
