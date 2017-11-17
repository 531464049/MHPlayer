//
//  ViewController.m
//  MHPlayerMaster
//
//  Created by 马浩 on 2017/11/17.
//  Copyright © 2017年 HuZhang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    MHPlayerView * player = [MHPlayerView sharedPlayerView];
    [player initFrame:CGRectMake(0, 64, Screen_WIDTH, Screen_WIDTH/16*9) videoUrl:@"http://120.25.226.186:32812/resources/videos/minion_01.mp4"];
    [self.view addSubview:player];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
