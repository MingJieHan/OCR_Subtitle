//
//  UIHansMutableSelectViewController.h
//  HansServer
//
//  Created by jia yu on 2022/8/8.
//

#import <UIKit/UIKit.h>

@class UIHansMutableSelectViewController;
typedef void (^UIHansMutableSelectViewController_Handler) (UIHansMutableSelectViewController * _Nonnull vc, NSArray * _Nonnull onOffs);


NS_ASSUME_NONNULL_BEGIN
@interface UIHansMutableSelectViewController : UIViewController
@property (nonatomic) UIButton * _Nonnull closeButton;
@property (nonatomic) UIHansMutableSelectViewController_Handler _Nullable handler;

-(id _Nullable )initWithTitle:(NSString * _Nonnull )title items:(NSArray * _Nonnull )items onOffs:(NSArray <NSNumber *>*)onOffs;

-(void)showFrom:(UIViewController * _Nonnull )fromViewController;
@end
NS_ASSUME_NONNULL_END
