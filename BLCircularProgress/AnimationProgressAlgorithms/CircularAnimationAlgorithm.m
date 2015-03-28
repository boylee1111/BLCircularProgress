//
//  CircularAnimationAlgorithm.m
//  BLCircularProgress
//
//  Created by Boyi on 3/28/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import "CircularAnimationAlgorithm.h"

@implementation CircularAnimationAlgorithm

- (CGFloat)easeInCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    currentTime /= duration;
    return -changeInValue * (sqrt(1 - currentTime * currentTime) - 1) + startValue;
}

- (CGFloat)easeOutCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    currentTime /= duration;
    currentTime--;
    return changeInValue * sqrt(1 - currentTime * currentTime) + startValue;
}

- (CGFloat)easeInOutWithCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    currentTime /= duration / 2;
    if (currentTime < 1) {
        return -changeInValue / 2 * (sqrt(1 - currentTime * currentTime) - 1) + startValue;
    }
    currentTime -= 2;
    return changeInValue / 2 * (sqrt(1 - currentTime * currentTime) + 1) + startValue;
}

@end
