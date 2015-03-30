//
//  BLCircularProgressView.m
//  BLCircularProgress
//
//  Created by Boyi on 3/25/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import <tgmath.h>

#import "BLCircularProgressView.h"

#import "SimpleLinearAnimationAlgorithm.h"
#import "QuadraticAnimationAlgorithm.h"
#import "CubicAnimationAlgorithm.h"
#import "QuarticAnimationAlgorithm.h"
#import "QuinticAnimationAlgorithm.h"
#import "SinusoidalAnimationAlgorithm.h"
#import "ExponentialAnimationAlgorithm.h"
#import "CircularAnimationAlgorithm.h"

#define DEGREES_TO_RADIANS(degree)  ((degree) / 180.0 * M_PI)
#define RADIANS_TO_DEGRESS(radian)  ((radian) * 180.0 / M_PI)
#define SQR(x)                      ((x) * (x))

#define PROGRESS_UPDATE_ANIMATION_FRAMES_PER_SECOND 80.f
#define SHIFT_PERCENTAGE_WHEN_OUT_OF_BOARD 0.05
#define SHIFT_VALUE_WHEN_OUT_OF_BOARD(progressDiff) (progressDiff * SHIFT_PERCENTAGE_WHEN_OUT_OF_BOARD)

typedef NS_ENUM(NSInteger, SlideStatus) {
    SlideStatusNone = 0,
    SlideStatusInBorder = 1,
    SlideStatusOutOfBorderFromMinimumValue = 2,
    SlideStatusOutOfBorderFromMaximumValue = 3
};

@interface BLCircularProgressView () {
    SlideStatus currentSlideStatus; // Determine current slide status when touching
    CGPoint center;                 // Center of cirle
    CGFloat radius;                 // radius of circle
    CGFloat circleWidth;            // width of circle
    
    NSInteger currentSegmentNumber; // current segment number, total value is PROGRESS_UPDATE_ANIMATION_SEGMENT_NUMBER
    CGFloat startProgressValue;     // record start value while updating progress with animation
    CGFloat progressUpdateDiff;     // record change value while updating progress with animation
    
    id <AnimationProgressAlgorithm> animationProgressAlgorithm;
}

@end

@implementation BLCircularProgressView

+ (void)initialize {
    if (self == [BLCircularProgressView class]) {
        id appearance = [self appearance];
        
        [appearance setMaxProgress:100.f];
        [appearance setMinProgress:0.f];
        [appearance setMaximaProgress:100.0f];
        [appearance setMinimaProgress:0.0f];
        
        [appearance setClockwise:YES];
        [appearance setStartAngle:0.0f];
        [appearance setThicknessRadio:0.2f];
        [appearance setProgressAnimationDuration:0.8f];
        [appearance setAnimationAlgorithm:AnimationAlgorithmCubic];
        [appearance setAnimationType:AnimationTypeEaseInEaseOut];
        
        [appearance setTouchResponseOuterShiftValue:5];
        [appearance setTouchResponseInnerShiftValue:5];
        
        [appearance setProgressFillColor:nil];
        [appearance setProgressTopGradientColor:[UIColor colorWithRed:.992156863 green:.929411765 blue:.866666667 alpha:1.f]];
        [appearance setProgressBottomGradientColor:[UIColor colorWithRed:.97254902 green:.764705882 blue:.568627451 alpha:1.f]];
        
        [appearance setBackgroundColor:[UIColor clearColor]];
    }
}

- (void)updateStartAngleWithDefaultValue:(CircularProgressStartAngle)circularProgressStartAngle {
    switch (circularProgressStartAngle) {
        case CircularProgressStartAngleNorth:
            self.startAngle = 270.f;
            break;
        case CircularProgressStartAngleEast:
            self.startAngle = 0.f;
            break;
        case CircularProgressStartAngleSouth:
            self.startAngle = 90.f;
            break;
        case CircularProgressStartAngleWest:
            self.startAngle = 180.f;
            break;
    }
}

- (void)animateProgress:(CGFloat)newProgress completion:(void (^)(CGFloat))completion {
    newProgress = MIN(self.maximaProgress, MAX(self.minimaProgress, newProgress));
    startProgressValue = self.progress;
    progressUpdateDiff = newProgress - startProgressValue;
    currentSegmentNumber = 0;
    self.userInteractionEnabled = NO;
    currentSlideStatus = SlideStatusNone;
    [NSTimer scheduledTimerWithTimeInterval:1 / PROGRESS_UPDATE_ANIMATION_FRAMES_PER_SECOND target:self selector:@selector(updateProgress:) userInfo:completion repeats:YES];
    
    if ([self.delegate respondsToSelector:@selector(circularProgressView:didBeganAnimationWithProgress:)]) {
        [self.delegate circularProgressView:self didBeganAnimationWithProgress:self.progress];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    // Calculate position of the circle
    CGFloat progressAngle;
    if (_clockwise) {
        progressAngle = (_progress - _minProgress) / (_maxProgress - _minProgress) * 360.f + _startAngle;
    } else {
        progressAngle = 360.f - (_progress - _minProgress) / (_maxProgress - _minProgress) * 360.f + _startAngle;
    }
    center = CGPointMake(rect.size.width / 2.0f, rect.size.height / 2.0f);
    radius = MIN(rect.size.width, rect.size.height) / 2.0f - 1;
    circleWidth = radius * _thicknessRadio;
    
    self.backgroundColor = [UIColor clearColor];
    
    CGRect square;
    if (rect.size.width > rect.size.height)
    {
        square = CGRectMake((rect.size.width - rect.size.height) / 2.0, 0.0, rect.size.height, rect.size.height);
    }
    else
    {
        square = CGRectMake(0.0, (rect.size.height - rect.size.width) / 2.0, rect.size.width, rect.size.width);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    
    [path appendPath:[UIBezierPath bezierPathWithArcCenter:center
                                                    radius:radius
                                                startAngle:DEGREES_TO_RADIANS(_startAngle)
                                                  endAngle:DEGREES_TO_RADIANS(progressAngle)
                                                 clockwise:_clockwise]];
    
    [path addArcWithCenter:center
                    radius:radius - circleWidth
                startAngle:DEGREES_TO_RADIANS(progressAngle)
                  endAngle:DEGREES_TO_RADIANS(_startAngle)
                 clockwise:!_clockwise];
    
    [path closePath];
    
    if (_progressFillColor)
    {
        [_progressFillColor setFill];
        [path fill];
    }
    else if (_progressTopGradientColor && _progressBottomGradientColor)
    {
        [path addClip];
        
        NSArray *backgroundColors = @[
                                      (id)[_progressTopGradientColor CGColor],
                                      (id)[_progressBottomGradientColor CGColor],
                                      ];
        CGFloat backgroudColorLocations[2] = { 0.0f, 1.0f };
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        CGGradientRef backgroundGradient = CGGradientCreateWithColors(rgb, (__bridge CFArrayRef)(backgroundColors), backgroudColorLocations);
        CGContextDrawLinearGradient(context,
                                    backgroundGradient,
                                    CGPointMake(0.0f, square.origin.y),
                                    CGPointMake(0.0f, square.size.height),
                                    0);
        CGGradientRelease(backgroundGradient);
        CGColorSpaceRelease(rgb);
    }
    
    CGContextRestoreGState(context);
}

#pragma mark - Setter

- (void)setProgress:(CGFloat)progress {
    _progress = MIN(_maximaProgress, MAX(_minimaProgress, progress));
    [self setNeedsDisplay];
}

#pragma mark Appearance

- (void)setMaxProgress:(CGFloat)maxProgress {
    _maxProgress = maxProgress;
    [self setNeedsDisplay];
}

- (void)setMinProgress:(CGFloat)minProgress {
    _minProgress = minProgress;
    [self setNeedsDisplay];
}

- (void)setMaximaProgress:(CGFloat)maximaProgress {
    _maximaProgress =  MIN(maximaProgress, _maxProgress);
    [self setNeedsDisplay];
}

- (void)setMinimaProgress:(CGFloat)minimaProgress {
    _minimaProgress = MAX(minimaProgress, _minProgress);
    [self setNeedsDisplay];
}

- (void)setClockwise:(NSInteger)clockwise {
    _clockwise = clockwise;
    [self setNeedsDisplay];
}

- (void)setStartAngle:(CGFloat)startAngle {
    _startAngle = fmod(startAngle, 360.f);
    if (_startAngle < 0) {
        _startAngle += 360.f;
    }
    [self setNeedsDisplay];
}

- (void)setThicknessRadio:(CGFloat)thicknessRadio {
    _thicknessRadio = thicknessRadio;
    [self setNeedsDisplay];
}

- (void)setAnimationAlgorithm:(AnimationAlgorithm)animationAlgorithm {
    _animationAlgorithm = animationAlgorithm;
    [self setAnimationProgressAlgorithmWithAnimationAlgorithm:_animationAlgorithm];
}

- (void)setProgressFillColor:(UIColor *)progressFillColor {
    _progressFillColor = progressFillColor;
    [self setNeedsDisplay];
}

- (void)setProgressTopGradientColor:(UIColor *)progressTopGradientColor {
    _progressTopGradientColor = progressTopGradientColor;
    [self setNeedsDisplay];
}

- (void)setProgressBottomGradientColor:(UIColor *)progressBottomGradientColor {
    _progressBottomGradientColor = progressBottomGradientColor;
    [self setNeedsDisplay];
}

#pragma mark - Touches Event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    if (TwoPointAbsoluteDistance(touchLocation, center) < radius + self.touchResponseOuterShiftValue &&
        TwoPointAbsoluteDistance(touchLocation, center) > radius - circleWidth - self.touchResponseInnerShiftValue) {
        currentSlideStatus = SlideStatusInBorder;
    }

    if ([self.delegate respondsToSelector:@selector(circularProgressView:didBeganTouchesWithProgress:)]) {
        [self.delegate circularProgressView:self didBeganTouchesWithProgress:self.progress];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    CGPoint touchLocation = [[touches anyObject] locationInView:self];
    CGFloat angle = fmod(AngleFromNorth(center, touchLocation), 360.f);
    CGFloat angleDistanceFromStart = TwoAngleAbsoluteDistance(_startAngle, angle, _clockwise);
    CGFloat progressTmp = (_maxProgress - _minProgress) * angleDistanceFromStart / 360.f + _minProgress;
    
    switch (currentSlideStatus) {
        case SlideStatusNone:
            return ;
            break;
        case SlideStatusInBorder: {
            CGFloat maximaProgressAngle = (self.maximaProgress - self.minProgress) / (self.maxProgress - self.minProgress) * 360.f + self.startAngle;
            CGFloat minimaProgressAngle = (self.minimaProgress - self.minProgress) / (self.maxProgress - self.minProgress) * 360.f + self.startAngle;
            CGFloat toMaximaProgressAngle = TwoAngleAbsoluteDistance(angle, maximaProgressAngle, self.clockwise);
            CGFloat toMinimaProgressAngle = TwoAngleAbsoluteDistance(angle, minimaProgressAngle, !self.clockwise);
            if (progressTmp < self.maximaProgress && progressTmp > self.minimaProgress) {
                self.progress = progressTmp;
            } else {
                if (toMaximaProgressAngle <= toMinimaProgressAngle) {
                    self.progress = self.minimaProgress;
                    currentSlideStatus = SlideStatusOutOfBorderFromMinimumValue;
                } else {
                    self.progress = self.maximaProgress;
                    currentSlideStatus = SlideStatusOutOfBorderFromMaximumValue;
                }
            }
        }
            break;
        case SlideStatusOutOfBorderFromMinimumValue:
            if (progressTmp >= self.minimaProgress && progressTmp < self.minimaProgress + SHIFT_VALUE_WHEN_OUT_OF_BOARD(self.maxProgress - self.minProgress)) {
                currentSlideStatus = SlideStatusInBorder;
            }
            break;
        case SlideStatusOutOfBorderFromMaximumValue:
            if (progressTmp <= self.maximaProgress && progressTmp > self.maximaProgress - SHIFT_VALUE_WHEN_OUT_OF_BOARD(self.maxProgress - self.minProgress)) {
                currentSlideStatus = SlideStatusInBorder;
            }
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(circularProgressView:didMovedTouchesWithProgress:)]) {
        [self.delegate circularProgressView:self didMovedTouchesWithProgress:self.progress];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    currentSlideStatus = SlideStatusNone;
    
    if ([self.delegate respondsToSelector:@selector(circularProgressView:didEndedTouchesWithProgress:)]) {
        [self.delegate circularProgressView:self didEndedTouchesWithProgress:self.progress];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    currentSlideStatus = SlideStatusNone;
    
    if ([self.delegate respondsToSelector:@selector(circularProgressView:didCancelledTouchesWithProgress:)]) {
        [self.delegate circularProgressView:self didCancelledTouchesWithProgress:self.progress];
    }
}

#pragma mark - Helper Methods

- (void)setAnimationProgressAlgorithmWithAnimationAlgorithm:(AnimationAlgorithm)animationAlgorithm {
    switch (animationAlgorithm) {
        case AnimationAlgorithmSimpleLinear:
            animationProgressAlgorithm = [[SimpleLinearAnimationAlgorithm alloc] init];
            break;
        case AnimationAlgorithmQuadratic:
            animationProgressAlgorithm = [[QuadraticAnimationAlgorithm alloc] init];
            break;
        case AnimationAlgorithmCubic:
            animationProgressAlgorithm = [[CubicAnimationAlgorithm alloc] init];
            break;
        case AnimationAlgorithmQuartic:
            animationProgressAlgorithm = [[QuarticAnimationAlgorithm alloc] init];
            break;
        case AnimationAlgorithmQuintic:
            animationProgressAlgorithm = [[QuinticAnimationAlgorithm alloc] init];
            break;
        case AnimationAlgorithmSinusoidal:
            animationProgressAlgorithm = [[SinusoidalAnimationAlgorithm alloc] init];
            break;
        case AnimationAlgorithmExponential:
            animationProgressAlgorithm = [[ExponentialAnimationAlgorithm alloc] init];
            break;
        case AnimationAlgorithmCircular:
            animationProgressAlgorithm = [[CircularAnimationAlgorithm alloc] init];
            break;
    }
}

- (void)updateProgress:(NSTimer *)timer {
    currentSegmentNumber++;
    if (currentSegmentNumber >= (PROGRESS_UPDATE_ANIMATION_FRAMES_PER_SECOND * self.progressAnimationDuration)) {
        currentSegmentNumber = 0;
        self.userInteractionEnabled = YES;
        void (^completion)(BOOL) = [timer userInfo];
        if (completion != nil) {
            completion(self.progress);
        }
        [timer invalidate];
        
        if ([self.delegate respondsToSelector:@selector(circularProgressView:didEndedAnimationWithProgress:)]) {
            [self.delegate circularProgressView:self didEndedAnimationWithProgress:self.progress];
        }
        return ;
    }
    CGFloat currentProgress = self.progress;
    switch (self.animationType) {
        case AnimationTypeEaseIn:
            currentProgress = [animationProgressAlgorithm easeInCurrentTime:currentSegmentNumber / PROGRESS_UPDATE_ANIMATION_FRAMES_PER_SECOND startValue:startProgressValue changeInValue:progressUpdateDiff duration:self.progressAnimationDuration];
            break;
        case AnimationTypeEaseOut:
            currentProgress = [animationProgressAlgorithm easeOutCurrentTime:currentSegmentNumber / PROGRESS_UPDATE_ANIMATION_FRAMES_PER_SECOND startValue:startProgressValue changeInValue:progressUpdateDiff duration:self.progressAnimationDuration];
            break;
        case AnimationTypeEaseInEaseOut:
            currentProgress = [animationProgressAlgorithm easeInOutWithCurrentTime:currentSegmentNumber / PROGRESS_UPDATE_ANIMATION_FRAMES_PER_SECOND startValue:startProgressValue changeInValue:progressUpdateDiff duration:self.progressAnimationDuration];
            break;
    }
    self.progress = currentProgress;
    
    if ([self.delegate respondsToSelector:@selector(circularProgressView:didDuringAnimationWithProgress:)]) {
        [self.delegate circularProgressView:self didDuringAnimationWithProgress:self.progress];
    }
}

static inline CGFloat TwoPointAbsoluteDistance(CGPoint point1, CGPoint point2) {
    return (sqrt(SQR((point2.x) - (point1.x)) + SQR((point2.y) - (point1.y))));
}

static inline CGFloat TwoAngleAbsoluteDistance(CGFloat fromAngle, CGFloat toAngle, BOOL clockwise) {
    fromAngle = fmod(fromAngle, 360.f);
    toAngle = fmod(toAngle, 360.f);
    CGFloat angleDifference = toAngle - fromAngle;
    angleDifference = clockwise ? angleDifference : - angleDifference;
    angleDifference = fmod(angleDifference, 360.f);
    if (angleDifference < 0) angleDifference += 360.f;
    return angleDifference;
}

static inline CGFloat AngleFromNorth(CGPoint p1, CGPoint p2) {
    CGPoint v = CGPointMake(p2.x - p1.x, p2.y - p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y, v.x);
    result = RADIANS_TO_DEGRESS(radians);
    return (result >= 0 ? result : result + 360.0);
}

@end
