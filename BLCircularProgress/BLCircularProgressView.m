//
//  BLCircularProgressView.m
//  BLCircularProgress
//
//  Created by Boyi on 3/25/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import <tgmath.h>

#import "BLCircularProgressView.h"

#define RGBA(r, g, b, a)            [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define RGB(r, g, b)                RGBA(r, g, b, 1.0)

#define DEGREES_TO_RADIANS(degree)  ((degree) / 180.0 * M_PI)
#define RADIANS_TO_DEGRESS(radian)  ((radian) * 180.0 / M_PI)
#define SQR(x)                      ((x) * (x))

#define TWO_POINT_DISTANCE(point1, point2) sqrt(SQR(point2.x - point1.x) + SQR(point2.y - point1.y))
#define TWO_ANGLE_DISTANCE(fromAngle, toAngle) MIN(abs(fromAngle - toAngle), abs(360.0f - fromAngle + toAngle));

typedef NS_ENUM(NSInteger, SlideStatus) {
    SlideStatusInBorder,
    SlideStatusOutOfBorderFromMinimumValue,
    SlideStatusOutOfBorderFromMaximumValue
};

@interface BLCircularProgressView () {
    SlideStatus currentSlideStatus;
}

@end

@implementation BLCircularProgressView

+ (void)initialize {
    if (self == [BLCircularProgressView class]) {
        id appearance = [self appearance];
        
        [appearance setRoundedHead:NO];
        [appearance setShowShadow:YES];
        [appearance setClockwise:YES];
        [appearance setStartAngle:0.0f];
        [appearance setThickness:0.25f];
        
        [appearance setProgressFillColor:nil];
        [appearance setProgressTopGradientColor:RGB(253, 237, 221)];
        [appearance setProgressBottomGradientColor:RGB(248, 195, 145)];
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

- (void)assignDefaultValue {
    self.maxProgress = 100.0f;
    self.minProgress = 0.0f;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    // Calculate position of the circle
    CGFloat progressAngle;
    if (_clockwise) {
        progressAngle = _progress / _maxProgress * 360.f + _startAngle;
    } else {
        progressAngle = 360.f - _progress / _maxProgress * 360.f + _startAngle;
    }
    CGPoint center = CGPointMake(rect.size.width / 2.0f, rect.size.height / 2.0f);
    CGFloat radius = MIN(rect.size.width, rect.size.height) / 2.0f - 1;
    CGFloat circleWidth = radius * _thickness;
    
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
    _progress = MIN(self.maxProgress, MAX(self.minProgress, progress));
    [self setNeedsDisplay];
}

- (void)setMaxProgress:(CGFloat)maxProgress {
    _maxProgress = maxProgress;
    [self setNeedsDisplay];
}

- (void)setMinProgress:(CGFloat)minProgress {
    _minProgress = minProgress;
    [self setNeedsDisplay];
}

#pragma mark Appearance

- (void)setRoundedHead:(NSInteger)roundedHead {
    _roundedHead = roundedHead;
    [self setNeedsDisplay];
}

- (void)setShowShadow:(NSInteger)showShadow {
    _showShadow = showShadow;
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

- (void)setThickness:(CGFloat)thickness {
    _thickness = thickness;
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
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(circularProgressViewDidFinishTouching:)]) {
        [self.delegate circularProgressViewDidFinishTouching:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

#pragma mark - Helper Methods

//Sourcecode from Apple example clockControl
//Calculate the direction in degrees from a center point to an arbitrary position.
static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x - p1.x, p2.y - p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y, v.x);
    result = RADIANS_TO_DEGRESS(radians);
    return (result >= 0 ? result : result + 360.0);
}

@end
