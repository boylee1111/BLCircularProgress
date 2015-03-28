//
//  ExponentialAnimationAlgorithm.m
//  BLCircularProgress
//
//  Created by Boyi on 3/28/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import "ExponentialAnimationAlgorithm.h"

@implementation ExponentialAnimationAlgorithm

- (CGFloat)easeInCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    return changeInValue * pow(2, 10 * (currentTime / duration - 1)) + startValue;
}

- (CGFloat)easeOutCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    return changeInValue * (-pow(2, -10 * currentTime / duration) + 1) + startValue;
}

- (CGFloat)easeInOutWithCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    currentTime /= duration / 2;
    if (currentTime < 1) {
        return changeInValue / 2 * pow(2, 10 * (currentTime - 1)) + startValue;
    }
    currentTime--;
    return changeInValue / 2 * (-pow(2, -10 * currentTime) + 2) + startValue;
}

@end
