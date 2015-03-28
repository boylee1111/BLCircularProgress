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
    self.circularProgress.clockwise = YES;
    self.circularProgress.startAngle = 30.f;
    self.circularProgress.maxProgress = 100.f;
    self.circularProgress.minProgress = -100.f;
    self.circularProgress.maximaProgress = 90;
    self.circularProgress.minimaProgress = -90.0f;
    self.circularProgress.progress = -30.f;
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateProgress {
    CGFloat randomValue = [self randomFloatBetween:-100 and:100];
    [self.circularProgress updateProgress:randomValue withAnimation:YES completion:^(BOOL finished) {
        NSLog(@"finished, randomvalue = %f", randomValue);
    }];
}

- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

@end
