//
//  ManyLineStringEditViewController.h
//  iOSWithDjango
//
//  Created by jia yu on 2020/12/31.
//


/*
 
 HansManyLineStringEditViewController *v = [[HansManyLineStringEditViewController alloc] init];
 v.defaultValue = @"abc";
 v.handler = ^(BOOL changed, NSString * _Nullable value) {
     return;
 };
 
 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:v];
 [self presentViewController:nav animated:YES completion:nil];
 
//    [self.navigationController pushViewController:v animated:YES];
 
 */
#import <UIKit/UIKit.h>
typedef void (^ManyLineStringEditViewController_Done_Handler)(BOOL changed, NSString * _Nullable value);

NS_ASSUME_NONNULL_BEGIN
@interface HansManyLineStringEditViewController : UIViewController
@property (nonatomic) ManyLineStringEditViewController_Done_Handler handler;
@property (nonatomic) NSString *defaultValue;
@end
NS_ASSUME_NONNULL_END
