//
//  AnimationProgressAlgorithm.h
//  BLCircularProgress
//
//  Created by Boyi on 3/28/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(NSInteger, AnimationAlgorithm) {
    AnimationAlgorithmSimpleLinear,
    AnimationAlgorithmQuadratic,
    AnimationAlgorithmCubic,
    AnimationAlgorithmQuartic,
    AnimationAlgorithmQuintic,
    AnimationAlgorithmSinusoidal,
    AnimationAlgorithmExponential,
    AnimationAlgorithmCircular
};

typedef NS_ENUM(NSInteger, AnimationType) {
    AnimationTypeEaseIn,
    AnimationTypeEaseOut,
    AnimationTypeEaseInEaseOut
};

@protocol AnimationProgressAlgorithm <NSObject>

@required
- (CGFloat)easeInCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration;
- (CGFloat)easeOutCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration;
- (CGFloat)easeInOutWithCurrentTime:(CGFloat)currentTime startValue:(CGFloat)startValue changeInValue:(CGFloat)changeInValue duration:(CGFloat)duration;

@end
