//
//  BLCircularProgressView.m
//  BLCircularProgress
//
//  Created by Boyi on 3/25/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import <tgmath.h>

#import "BLCircularProgressView.h"

#define DEGREES_TO_RADIANS(degree)  ((degree) / 180.0 * M_PI)
#define RADIANS_TO_DEGRESS(radian)  ((radian) * 180.0 / M_PI)
#define SQR(x)                      ((x) * (x))

#define TWO_POINT_DISTANCE(point1, point2) (sqrt(SQR((point2.x) - (point1.x)) + SQR((point2.y) - (point1.y))))
#define TWO_ANGLE_DISTANCE(fromAngle, toAngle) (MIN(abs((fromAngle) - (toAngle)), abs(360.0f - (fromAngle) + (toAngle))));

#define PROGRESS_UPDATE_ANIMATION_DURATION 0.4
#define PROGRESS_UPDATE_ANIMATION_SEGMENT_NUMBER 100
#define SHIFT_PERCENTAGE_WHEN_OUT_OF_BOARD 0.05
#define SHIFT_VALUE_WHEN_OUT_OF_BOARD(progressDiff) (progressDiff * SHIFT_PERCENTAGE_WHEN_OUT_OF_BOARD)

typedef NS_ENUM(NSInteger, SlideStatus) {
    SlideStatusNone,
    SlideStatusInBorder,
    SlideStatusOutOfBorderFromMinimumValue,
    SlideStatusOutOfBorderFromMaximumValue
};

@interface BLCircularProgressView () {
    SlideStatus currentSlideStatus;
    CGPoint center;
    CGFloat radius;
    CGFloat circleWidth;
    NSInteger currentSegmentNumber;
    
    CGFloat startProgressValue;
    CGFloat progressUpdateDiff;
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
        
        [appearance setRoundedHead:NO];
        [appearance setClockwise:YES];
        [appearance setStartAngle:0.0f];
        [appearance setThicknessRadio:0.25f];
        
        [appearance setTouchResponseOuterShiftValue:5];
        [appearance setTouchResponseInnerShiftValue:5];
        
        [appearance setProgressFillColor:nil];
        [appearance setProgressTopGradientColor:[UIColor colorWithRed:.992156863 green:.929411765 blue:.866666667 alpha:1.f]];
        [appearance setProgressBottomGradientColor:[UIColor colorWithRed:.97254902 green:.764705882 blue:.568627451 alpha:1.f]];
        
        [appearance setBackgroundColor:[UIColor clearColor]];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self assignDefaultValue];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self assignDefaultValue];
    }
    return self;
}

- (void)updateProgress:(CGFloat)newProgress withAnimation:(BOOL)animated completion:(void (^)(BOOL))completion {
    newProgress = MIN(self.maximaProgress, MAX(self.minimaProgress, newProgress));
    startProgressValue = self.progress;
    progressUpdateDiff = newProgress - startProgressValue;
    currentSegmentNumber = 0;
    self.userInteractionEnabled = NO;
    [NSTimer scheduledTimerWithTimeInterval:PROGRESS_UPDATE_ANIMATION_DURATION / PROGRESS_UPDATE_ANIMATION_SEGMENT_NUMBER target:self selector:@selector(updateProgress:) userInfo:completion repeats:YES];
}

- (void)updateProgress:(NSTimer *)timer {
    currentSegmentNumber++;
    if (currentSegmentNumber >= PROGRESS_UPDATE_ANIMATION_SEGMENT_NUMBER) {
        currentSegmentNumber = 0;
        self.userInteractionEnabled = YES;
        void (^completion)(BOOL) = [timer userInfo];
        if (completion != nil) {
            completion(YES);
        }
        [timer invalidate];
        return ;
    }
    CGFloat currentProgress = [self quadraticEaseInOutWithCurrentTime:PROGRESS_UPDATE_ANIMATION_DURATION / PROGRESS_UPDATE_ANIMATION_SEGMENT_NUMBER * currentSegmentNumber startValue:startProgressValue changeInValue:progressUpdateDiff duration:PROGRESS_UPDATE_ANIMATION_DURATION];
    self.progress = currentProgress;
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
    
    if (_roundedHead && _progress != 0)
    {
        CGPoint point;
        point.x = (cos(DEGREES_TO_RADIANS(progressAngle)) * (radius - circleWidth/2)) + center.x;
        point.y = (sin(DEGREES_TO_RADIANS(progressAngle)) * (radius - circleWidth/2)) + center.y;
        
        [path addArcWithCenter:point
                        radius:circleWidth/2
                    startAngle:DEGREES_TO_RADIANS(progressAngle)
                      endAngle:DEGREES_TO_RADIANS(270.0 + progressAngle - 90.0)
                     clockwise:NO];
    }
    
    [path addArcWithCenter:center
                    radius:radius - circleWidth
                startAngle:DEGREES_TO_RADIANS(progressAngle)
                  endAngle:DEGREES_TO_RADIANS(_startAngle)
                 clockwise:!_clockwise];
    
    if (_roundedHead)
    {
        CGPoint point;
        point.x = (cos(DEGREES_TO_RADIANS(_startAngle)) * (radius - circleWidth / 2)) + center.x;
        point.y = (sin(DEGREES_TO_RADIANS(_startAngle)) * (radius - circleWidth / 2)) + center.y;
        
        [path addArcWithCenter:point
                        radius:circleWidth / 2
                    startAngle:DEGREES_TO_RADIANS(progressAngle)
                      endAngle:DEGREES_TO_RADIANS(progressAngle)
                     clockwise:_clockwise];
    }
    
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

- (void)setRoundedHead:(NSInteger)roundedHead {
    _roundedHead = roundedHead;
    [self setNeedsDisplay];
}

- (void)setClockwise:(NSInteger)clockwise {
    _clockwise = clockwise;
    [self setNeedsDisplay];
}

- (void)setStartAngle:(CGFloat)startAngle {
    _startAngle = fmod(startAngle, 360.f);
    [self setNeedsDisplay];
}

- (void)setThicknessRadio:(CGFloat)thicknessRadio {
    _thicknessRadio = thicknessRadio;
    [self setNeedsDisplay];
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
    if (TWO_POINT_DISTANCE(touchLocation, center) < radius + self.touchResponseOuterShiftValue &&
        TWO_POINT_DISTANCE(touchLocation, center) > radius - circleWidth - self.touchResponseInnerShiftValue) {
        currentSlideStatus = SlideStatusInBorder;
    }
    
    if ([self.delegate respondsToSelector:@selector(circularProgressView:didBeginTouchingWithProgress:)]) {
        [self.delegate circularProgressView:self didBeginTouchingWithProgress:self.progress];
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
    
    if ([self.delegate respondsToSelector:@selector(circularProgressView:touchingWithProgress:)]) {
        [self.delegate circularProgressView:self touchingWithProgress:self.progress];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    currentSlideStatus = SlideStatusNone;
    if ([self.delegate respondsToSelector:@selector(circularProgressView:didFinishTouchingWithProgress:)]) {
        [self.delegate circularProgressView:self didFinishTouchingWithProgress:self.progress];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    currentSlideStatus = SlideStatusNone;
    if ([self.delegate respondsToSelector:@selector(circularProgressView:didCancelTouchingWithProgress:)]) {
        [self.delegate circularProgressView:self didCancelTouchingWithProgress:self.progress];
    }
}

#pragma mark - Helper Methods

- (void)assignDefaultValue {
    currentSlideStatus = SlideStatusNone;
}

- (CGFloat)quadraticEaseInOutWithCurrentTime:(CGFloat)time startValue:(CGFloat)start changeInValue:(CGFloat)change duration:(CGFloat)duration {
    time /= duration / 2;
    if (time < 1) return change / 2 * time * time * time + start;
    time -= 2;
    return change / 2 * (time * time * time + 2) + start;
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
