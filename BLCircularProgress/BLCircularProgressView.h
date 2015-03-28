//
//  BLCircularProgressView.h
//  BLCircularProgress
//
//  Created by Boyi on 3/25/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AnimationProgressAlgorithm.h"

@class BLCircularProgressView;

@protocol BLCircularProgressViewDelegate <NSObject>

@optional
- (void)circularProgressView:(BLCircularProgressView *)circularProgressView didBeganTouchesWithProgress:(CGFloat)progress;
- (void)circularProgressView:(BLCircularProgressView *)circularProgressView didMovedTouchesWithProgress:(CGFloat)progress;
- (void)circularProgressView:(BLCircularProgressView *)circularProgressView didEndedTouchesWithProgress:(CGFloat)progress;
- (void)circularProgressView:(BLCircularProgressView *)circularProgressView didCancelledTouchesWithProgress:(CGFloat)progress;

- (void)circularProgressView:(BLCircularProgressView *)circularProgressView didBeganAnimationWithProgress:(CGFloat)progress;
- (void)circularProgressView:(BLCircularProgressView *)circularProgressView didDuringAnimationWithProgress:(CGFloat)progress;
- (void)circularProgressView:(BLCircularProgressView *)circularProgressView didEndedAnimationWithProgress:(CGFloat)progress;


@end

@interface BLCircularProgressView : UIView

@property (nonatomic) CGFloat progress;

@property (nonatomic) CGFloat maxProgress UI_APPEARANCE_SELECTOR; // Max value of progress
@property (nonatomic) CGFloat minProgress UI_APPEARANCE_SELECTOR; // Min value of progress
@property (nonatomic) CGFloat maximaProgress UI_APPEARANCE_SELECTOR; // Maxima value of progress, smaller than or equal to maxProgress
@property (nonatomic) CGFloat minimaProgress UI_APPEARANCE_SELECTOR; // Minima value of progress, larger than or equal to minProgress

// UI_APPEARANCE_SELECTOR doesn't support BOOL before iOS 8
@property (nonatomic) NSInteger clockwise UI_APPEARANCE_SELECTOR; // Whether cloackwise
@property (nonatomic) CGFloat startAngle UI_APPEARANCE_SELECTOR; // Start angle value, will be flipped as angle larger than or equal to 0, smaller than 360
@property (nonatomic) CGFloat thicknessRadio UI_APPEARANCE_SELECTOR; // Represent the scale percentage of circle width and radius, e.g. radius * thicknessRadio = circle width
@property (nonatomic) CGFloat progressAnimationDuration UI_APPEARANCE_SELECTOR; // Duration while update progress with animation
@property (nonatomic) AnimationAlgorithm animationAlgorithm UI_APPEARANCE_SELECTOR; // Different calculation algorithm animation
@property (nonatomic) AnimationType animationType UI_APPEARANCE_SELECTOR; // Different animation type, ease in, ease out, and both

@property (nonatomic) CGFloat touchResponseOuterShiftValue UI_APPEARANCE_SELECTOR; // Extend touching response scale from circle outer border
@property (nonatomic) CGFloat touchResponseInnerShiftValue UI_APPEARANCE_SELECTOR; // Extend touching response scale from circle inner border

@property (nonatomic, strong) UIColor *progressFillColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *progressTopGradientColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *progressBottomGradientColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) id <BLCircularProgressViewDelegate> delegate;

// !!!: implement via NSTimer, accuracy problem
- (void)animateProgress:(CGFloat)newProgress completion:(void (^)(CGFloat))completion;

@end
