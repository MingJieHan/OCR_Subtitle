//
//  UIHansRadioSelectViewController.h
//  HansServer
//
//  Created by jia yu on 2022/8/1.
//

#import <UIKit/UIKit.h>


@class UIHansRadioSelectViewController;
typedef void (^UIHansRadioSelectViewController_Handler) (UIHansRadioSelectViewController * _Nonnull vc, NSString * _Nonnull selectedString, NSUInteger selectedIndex);

@interface UIHansRadioSelectViewController : UIViewController
-(id _Nullable )initWithCoder:(NSCoder * _Nullable)coder NS_UNAVAILABLE;
-(id _Nullable )init NS_UNAVAILABLE;
-(nonnull id)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

@property (nonatomic) UIButton * _Nonnull closeButton;
@property (nonatomic) UIHansRadioSelectViewController_Handler _Nullable handler;

-(id _Nullable )initWithTitle:(NSString * _Nonnull )title items:(NSArray * _Nonnull )items selected:(NSUInteger)selectIndex;

-(void)showFrom:(UIViewController * _Nonnull )fromViewController;
@end
