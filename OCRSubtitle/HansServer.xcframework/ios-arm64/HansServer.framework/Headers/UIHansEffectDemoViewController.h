//
//  UIHansEffDemoViewController.h
//  HansServer
//
//  Created by jia yu on 2022/8/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIHansEffectDemoViewController : UIViewController
@property (nonatomic) UILabel *label;

-(void)style:(UIBlurEffectStyle)style withTitle:(NSString *)name radius:(float)radius;
@end
NS_ASSUME_NONNULL_END
