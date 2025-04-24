//
//  UIHansButton.h
//  HansServer
//
//  Created by jia yu on 2024/1/10.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UIHansButtonStyle) {
    UIHansButtonStyle_Red,      //for warning button
    UIHansButtonStyle_Blue,     //for target button
    UIHansButtonStyle_Gray      //for Cancel
};

NS_ASSUME_NONNULL_BEGIN
@interface UIHansButton : UIButton
-(id)init NS_UNAVAILABLE;
-(id)initWithFrame:(CGRect)frame primaryAction:(nullable UIAction *)primaryAction NS_UNAVAILABLE;
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
+(id)buttonWithType:(UIButtonType)buttonType NS_UNAVAILABLE;

-(id)initWithFrame:(CGRect)frame;

-(id)initWithFrame:(CGRect)frame style:(UIHansButtonStyle)blueStyle;
@end
NS_ASSUME_NONNULL_END
