//
//  UIHansLabel.h
//  HansServer
//
//  Created by jia yu on 2022/7/29.
//

#import <UIKit/UIKit.h>
@class UIHansSelectLabel;
typedef void (^UIHansSelectLabel_Handler) (UIHansSelectLabel * _Nonnull label, BOOL selected);

@interface UIHansSelectLabel : UIView
@property (nonatomic) UIHansSelectLabel_Handler _Nullable handler;
@property (nonatomic) BOOL selected;
@property (nonatomic) UIColor * _Nonnull boardSelectedColor;
@property (nonatomic) UIColor * _Nonnull textSelectedColor;
@property (nonatomic) UIColor * _Nonnull bgSelectedColor;
@property (nonatomic) UIColor * _Nonnull boardColor;
@property (nonatomic) UIColor * _Nonnull textColor;
@property (nonatomic) UIColor * _Nonnull bgColor;
@property (nonatomic) NSString * _Nonnull string;

-(id _Nullable )initWithText:(NSString * _Nonnull)string withSelect:(BOOL)selected;

-(CGFloat)width;
@end

