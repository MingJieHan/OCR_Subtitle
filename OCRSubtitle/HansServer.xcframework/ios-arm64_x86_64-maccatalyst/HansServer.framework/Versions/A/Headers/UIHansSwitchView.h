//
//  UIHansSwitchView.h
//  HansServer
//
//  Created by jia yu on 2022/7/29.
//

#import <UIKit/UIKit.h>

@class UIHansSwitchView;
typedef void (^UIHansSwitchView_Handler) (UIHansSwitchView * _Nonnull view, BOOL on);


@interface UIHansSwitchView : UIView
-(nonnull id)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
-(nullable id)initWithCoder:(nullable NSCoder *)coder NS_UNAVAILABLE;

@property (nonatomic) UIHansSwitchView_Handler _Nullable handler;
@property (nonatomic) BOOL on;

@property (nonatomic) UIColor * _Nonnull onColor;
@property (nonatomic) UIColor * _Nonnull offColor;
@property (nonatomic) UILabel * _Nonnull onLabel;
@property (nonatomic) UILabel * _Nonnull offLabel;
@end

