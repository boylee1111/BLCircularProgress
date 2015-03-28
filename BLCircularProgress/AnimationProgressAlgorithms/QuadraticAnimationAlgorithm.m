//
//  QuadraticAnimationAlgorithm.m
//  BLCircularProgress
//
//  Created by Boyi on 3/28/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import "QuadraticAnimationAlgorithm.h"

@implementation QuadraticAnimationAlgorithm

- (CGFloat)easeInCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    currentTime /= duration;
    return changeInValue * currentTime * currentTime + startValue;
}

- (CGFloat)easeOutCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    currentTime /= duration;
    return -changeInValue * currentTime * (currentTime - 2) + startValue;
}

- (CGFloat)easeInOutWithCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    currentTime /= duration / 2;
    if (currentTime < 1) {
        return changeInValue / 2 * currentTime * currentTime + startValue;
    }
    currentTime--;
    return -changeInValue / 2 * (currentTime * (currentTime - 2) - 1) + startValue;
}

@end
