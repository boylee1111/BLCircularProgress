//
//  SimpleLinearAnimationAlgorithm.m
//  BLCircularProgress
//
//  Created by Boyi on 3/28/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import "SimpleLinearAnimationAlgorithm.h"

@implementation SimpleLinearAnimationAlgorithm

- (CGFloat)easeInCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    return changeInValue * currentTime / duration + startValue;
}

- (CGFloat)easeOutCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    return changeInValue * currentTime / duration + startValue;
}

- (CGFloat)easeInOutWithCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration {
    return changeInValue * currentTime / duration + startValue;
}

@end
