//
//  ViewController.m
//  BLCircularProgress
//
//  Created by Boyi on 3/18/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import "ViewController.h"
#import "BLCircularProgressView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.circularProgress.clockwise = NO;
    self.circularProgress.startAngle = 30.f;
    self.circularProgress.progress = 20.f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
