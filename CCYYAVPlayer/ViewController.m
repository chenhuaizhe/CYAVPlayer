//
//  ViewController.m
//  CCYYAVPlayer
//
//  Created by CY on 15/11/26.
//  Copyright © 2015年 chenyuan. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

//点击按钮进入到视频播放页面
- (IBAction)showMovie:(UIButton *)sender {
    
    PlayerViewController *pvc = [PlayerViewController new];
    pvc.videoURLString = @"http://v.iseeyoo.cn/video/2010/10/25/2a9f0f4e-e035-11df-9117-001e0bbb2442_001.mp4";
    [self presentViewController:pvc animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
