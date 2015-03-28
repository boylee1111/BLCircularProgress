//
//  ViewController.h
//  BLCircularProgress
//
//  Created by Boyi on 3/18/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCircularProgressView;

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet BLCircularProgressView *circularProgress;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

@end

