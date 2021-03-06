//
//  QuarticAnimationAlgorithm.m
//  BLCircularProgress
//
//  Created by Boyi on 3/28/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import "QuarticAnimationAlgorithm.h"

@implementation QuarticAnimationAlgorithm

- (CGFloat)easeInCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    currentTime /= duration;
    return changeInValue * currentTime * currentTime * currentTime * currentTime + startValue;
}

- (CGFloat)easeOutCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    currentTime /= duration;
    currentTime--;
    return -changeInValue * (currentTime * currentTime * currentTime * currentTime - 1) + startValue;
}

- (CGFloat)easeInOutWithCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    currentTime /= duration / 2;
    if (currentTime < 1) {
        return changeInValue / 2 * currentTime * currentTime * currentTime * currentTime + startValue;
    }
    currentTime -= 2;
    return -changeInValue / 2 * (currentTime * currentTime * currentTime * currentTime - 2) + startValue;
}

@end
