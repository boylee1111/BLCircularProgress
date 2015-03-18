//
//  CircularProgressView.m
//  GF2
//
//  Created by Boyi on 10/18/13.
//  Copyright (c) 2013 TAC. All rights reserved.
//

#import "CircularProgressView.h"

#define RGB(r, g, b) \
[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBA(r, g, b, a) \
[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define ToRad(deg)      ((deg) / 180.0 * M_PI)
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )
#define POINT_DISTANCE(point1, point2) sqrt(SQR(point2.x - point1.x) + SQR(point2.y - point1.y))
#define TWO_ANGLE_DISTANCE(fromAngle, toAngle) MIN(abs(fromAngle - toAngle), abs(360.0f - fromAngle + toAngle));

@implementation CircularProgressView {
    BOOL        isDragging;
    NSInteger   slideMode; // 当用户滑动超过背词范围时，停止更新。0代表正常；1代表从最小处滑动超出范围；2代表从最大值处滑动超出范围
    CGPoint     center;
    CGFloat     radius;
    CGFloat     circleWidth;
}

+ (void)initialize
{
    if (self == [CircularProgressView class])
    {
        id appearance = [self appearance];
        
        [appearance setShowText:NO];
        [appearance setRoundedHead:NO];
        [appearance setShowShadow:NO];
        
        [appearance setThicknessRatio:0.18f];
        [appearance setMinProgress:0.0f];
        [appearance setMaxProgress:1.0f];
        
        [appearance setInnerBackgroundColor:nil];
        [appearance setOuterBackgroundColor:nil];
        
        [appearance setTextColor:[UIColor blackColor]];
        [appearance setFont:[UIFont systemFontOfSize:10]];
        [appearance setProgressFillColor:nil];
        
        [appearance setProgressTopGradientColor:RGB(253, 237, 221)];
        [appearance setProgressBottomGradientColor:RGB(248, 195, 145)];
        
        [appearance setBackgroundColor:[UIColor clearColor]];
    }
}

- (id)init
{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
    return self;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    // Calculate position of the circle
    CGFloat progressAngle = _progress * -360.0 - 90;
    center = CGPointMake(rect.size.width / 2.0f, rect.size.height / 2.0f);
    radius = MIN(rect.size.width, rect.size.height) / 2.0f - 1;
    circleWidth = radius * _thicknessRatio;
    
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
    
    if (_innerBackgroundColor)
    {
        // Fill innerCircle with innerBackgroundColor
        UIBezierPath *innerCircle = [UIBezierPath bezierPathWithArcCenter:center
                                                                   radius:radius - circleWidth
                                                               startAngle:2*M_PI
                                                                 endAngle:0.0
                                                                clockwise:YES];
        
        [_innerBackgroundColor setFill];
        
        [innerCircle fill];
    }
    
    if (_outerBackgroundColor)
    {
        // Fill outerCircle with outerBackgroundColor
        UIBezierPath *outerCircle = [UIBezierPath bezierPathWithArcCenter:center
                                                                   radius:radius
                                                               startAngle:0.0
                                                                 endAngle:2*M_PI
                                                                clockwise:NO];
        [outerCircle addArcWithCenter:center
                               radius:radius - circleWidth
                           startAngle:2*M_PI
                             endAngle:0.0
                            clockwise:YES];
        
        [_outerBackgroundColor setFill];
        
        [outerCircle fill];
    }
    
    if (_showShadow)
    {
        // Draw shadows
        CGFloat locations[5] = { 0.0f, 0.33f, 0.66f, 1.0f };
        NSArray *gradientColors = @[
                                    (id)[[UIColor colorWithWhite:0.5 alpha:0.1] CGColor],
                                    (id)[[UIColor colorWithWhite:0.0 alpha:1.0] CGColor],
                                    (id)[[UIColor colorWithWhite:0.0 alpha:1.0] CGColor],
                                    (id)[[UIColor colorWithWhite:0.5 alpha:0.1] CGColor],
                                    ];
        
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(rgb, (__bridge CFArrayRef)gradientColors, locations);
        CGContextDrawRadialGradient(context, gradient, center, radius - circleWidth - 1, center, radius + 1, 0);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(rgb);
    }
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPath];
    [shadowPath appendPath:[UIBezierPath bezierPathWithArcCenter:center
                                                          radius:radius + 1
                                                      startAngle:ToRad(-90)
                                                        endAngle:ToRad(progressAngle)
                                                       clockwise:NO]];
    [shadowPath addArcWithCenter:center
                          radius:radius - circleWidth - 1
                      startAngle:ToRad(progressAngle)
                        endAngle:ToRad(-90)
                       clockwise:YES];
    [RGBA(0.0f, 0.0f, 0.0f, 0.06f) setFill];
    [shadowPath fill];
    
//    if (_showText && _textColor)
//    {
//        NSString *progressString = [NSString stringWithFormat:@"%.0f", _progress * 100.0];
//        
//        CGFloat fontSize = radius;
//        UIFont *font = [_font fontWithSize:fontSize];
//        
//        CGFloat diagonal = 2 * (radius - circleWidth);
//        CGFloat edge = diagonal / sqrtf(2);
//        
//        CGFloat actualFontSize;
//        CGSize maximumSize = CGSizeMake(edge, edge);
//        CGSize expectedSize = [progressString sizeWithFont:font
//                                               minFontSize:5.0
//                                            actualFontSize:&actualFontSize
//                                                  forWidth:maximumSize.width
//                                             lineBreakMode:NSLineBreakByWordWrapping];
//        
//        if (actualFontSize < fontSize)
//        {
//            font = [font fontWithSize:actualFontSize];
//            expectedSize = [progressString sizeWithFont:font
//                                            minFontSize:5.0
//                                         actualFontSize:&actualFontSize
//                                               forWidth:maximumSize.width
//                                          lineBreakMode:NSLineBreakByWordWrapping];
//        }
//        
//        CGPoint origin = CGPointMake(center.x - expectedSize.width / 2.0, center.y - expectedSize.height / 2.0);
//        
//        [_textColor setFill];
//        
//        [progressString drawAtPoint:origin forWidth:expectedSize.width withFont:font lineBreakMode:NSLineBreakByWordWrapping];
//    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    
    [path appendPath:[UIBezierPath bezierPathWithArcCenter:center
                                                    radius:radius
                                                startAngle:ToRad(-90)
                                                  endAngle:ToRad(progressAngle)
                                                 clockwise:NO]];
    
    if (_roundedHead && _progress != 0)
    {
        CGPoint point;
        point.x = (cos(ToRad(progressAngle)) * (radius - circleWidth/2)) + center.x;
        point.y = (sin(ToRad(progressAngle)) * (radius - circleWidth/2)) + center.y;
        
        [path addArcWithCenter:point
                        radius:circleWidth/2
                    startAngle:ToRad(progressAngle)
                      endAngle:ToRad(270.0 + progressAngle - 90.0)
                     clockwise:NO];
    }
    
    [path addArcWithCenter:center
                    radius:radius - circleWidth
                startAngle:ToRad(progressAngle)
                  endAngle:ToRad(-90)
                 clockwise:YES];
    
    //    if (_roundedHead)
    //    {
    //        CGPoint point;
    //        point.x = (cos(ToRad(-90)) * (radius - circleWidth/2)) + center.x;
    //        point.y = (sin(ToRad(-90)) * (radius - circleWidth/2)) + center.y;
    //
    //        [path addArcWithCenter:point
    //                        radius:circleWidth/2
    //                    startAngle:ToRad(90)
    //                      endAngle:ToRad(-90)
    //                     clockwise:NO];
    //    }
    
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

- (void)setProgress:(double)progress
{
    _progress = MIN(self.maxProgress, MAX(self.minProgress, progress));
    
    [self setNeedsDisplay];
}

#pragma mark - UIAppearance

- (void)setShowText:(NSInteger)showText
{
    _showText = showText;
    
    [self setNeedsDisplay];
}

- (void)setRoundedHead:(NSInteger)roundedHead
{
    _roundedHead = roundedHead;
    
    [self setNeedsDisplay];
}

- (void)setShowShadow:(NSInteger)showShadow
{
    _showShadow = showShadow;
    
    [self setNeedsDisplay];
}

- (void)setThicknessRatio:(CGFloat)thickness
{
    _thicknessRatio = MIN(MAX(0.0f, thickness), 1.0f);
    
    [self setNeedsDisplay];
}

- (void)setMaxProgress:(CGFloat)maxProgress
{
    _maxProgress = maxProgress;
    
    [self setNeedsDisplay];
}

- (void)setMinProgress:(CGFloat)minProgress
{
    _minProgress = minProgress;
    
    [self setNeedsDisplay];
}

- (void)setInnerBackgroundColor:(UIColor *)innerBackgroundColor
{
    _innerBackgroundColor = innerBackgroundColor;
    
    [self setNeedsDisplay];
}

- (void)setOuterBackgroundColor:(UIColor *)outerBackgroundColor
{
    _outerBackgroundColor = outerBackgroundColor;
    
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    
    [self setNeedsDisplay];
}

- (void)setProgressFillColor:(UIColor *)progressFillColor
{
    _progressFillColor = progressFillColor;
    
    [self setNeedsDisplay];
}

- (void)setProgressTopGradientColor:(UIColor *)progressTopGradientColor
{
    _progressTopGradientColor = progressTopGradientColor;
    
    [self setNeedsDisplay];
}

- (void)setProgressBottomGradientColor:(UIColor *)progressBottomGradientColor
{
    _progressBottomGradientColor = progressBottomGradientColor;
    
    [self setNeedsDisplay];
}

#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    isDragging = NO;
    slideMode = 0;
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (POINT_DISTANCE(touchLocation, center) < radius &&
        POINT_DISTANCE(touchLocation, center) > radius - circleWidth - 5) {
        isDragging = YES;
    } else {
        isDragging = NO;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    CGFloat angle = AngleFromNorth(center, touchLocation, NO) - 360.0;
    if (angle > -90.0f) angle -= 360.0f;
    CGFloat progressTmp = (angle + 90.0f) / -360.0f;
    
    if (isDragging && slideMode == 0) {
        CGFloat maxProgressAngle = self.maxProgress * -360.0f - 90.0f;
        CGFloat minProgressAngle = self.minProgress * -360.0f - 90.0f;
        CGFloat toMaxProgressAngle = TWO_ANGLE_DISTANCE(maxProgressAngle, angle);
        CGFloat toMinProgressAngle = TWO_ANGLE_DISTANCE(minProgressAngle, angle);
        if (progressTmp <= self.maxProgress && progressTmp >= self.minProgress) [self setProgress:progressTmp];
        else {
            if (toMaxProgressAngle >= toMinProgressAngle) {
                self.progress = self.minProgress;
                slideMode = 1;
            }
            else {
                self.progress = self.maxProgress;
                slideMode = 2;
            }
        }
    } else if (isDragging && slideMode == 1) {
        if (progressTmp >= self.minProgress && progressTmp < self.minProgress + 0.05f) slideMode = 0;
    } else if (isDragging && slideMode == 2) {
        if (progressTmp <= self.maxProgress && progressTmp > self.maxProgress - 0.05f) slideMode = 0;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    isDragging = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    isDragging = NO;
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
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}

@end
