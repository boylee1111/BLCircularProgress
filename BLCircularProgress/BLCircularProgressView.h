//
//  BLCircularProgressView.h
//  BLCircularProgress
//
//  Created by Boyi on 3/25/15.
//  Copyright (c) 2015 boyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLCircularProgressView;

@protocol BLCircularProgressViewDelegate <NSObject>

@optional
- (void)circularProgressView:(BLCircularProgressView *)circularProgressView didBeginTouchingWithProgress:(CGFloat)progress;
- (void)circularProgressView:(BLCircularProgressView *)circularProgressView touchingWithProgress:(CGFloat)progress;
- (void)circularProgressView:(BLCircularProgressView *)circularProgressView didFinishTouchingWithProgress:(CGFloat)progress;
- (void)circularProgressView:(BLCircularProgressView *)circularProgressView didCancelTouchingWithProgress:(CGFloat)progress;

@end

@interface BLCircularProgressView : UIView

@property (nonatomic) CGFloat progress;

@property (nonatomic) CGFloat maxProgress UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat minProgress UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat maximaProgress UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat minimaProgress UI_APPEARANCE_SELECTOR;

@property (nonatomic) NSInteger roundedHead UI_APPEARANCE_SELECTOR;
@property (nonatomic) NSInteger showShadow UI_APPEARANCE_SELECTOR;
@property (nonatomic) NSInteger clockwise UI_APPEARANCE_SELECTOR;

@property (nonatomic) CGFloat startAngle UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat thicknessRadio UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIColor *progressFillColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *progressTopGradientColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *progressBottomGradientColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, assign) id <BLCircularProgressViewDelegate> delegate;

@end
