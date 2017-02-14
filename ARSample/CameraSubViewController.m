//
//  CameraSubViewController.m
//  ARSample
//
//  Created by hirauchi.shinichi on 2017/02/14.
//  Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//

#import "CameraSubViewController.h"

@interface CameraSubViewController ()

@end

@implementation CameraSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    // 画面回転を抑止する
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    while ([currentDevice isGeneratingDeviceOrientationNotifications])
        [currentDevice endGeneratingDeviceOrientationNotifications];
    
    return UIInterfaceOrientationMaskPortrait;
}



@end
