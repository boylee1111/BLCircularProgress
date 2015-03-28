//
//  SinusoidalAnimationAlgorithm.m
//  BLCircularProgress
//
//  Created by Boyi on 3/28/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import "SinusoidalAnimationAlgorithm.h"

@implementation SinusoidalAnimationAlgorithm

- (CGFloat)easeInCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    return -changeInValue * cos(currentTime / duration * (M_PI / 2)) + changeInValue + startValue;
}

- (CGFloat)easeOutCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    return changeInValue * sin(currentTime / duration * (M_PI / 2)) + startValue;
}

- (CGFloat)easeInOutWithCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    return -changeInValue / 2 * (cos(M_PI * currentTime / duration) - 1) + startValue;
}

@end
