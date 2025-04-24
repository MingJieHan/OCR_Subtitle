//
//  UIHansAboutViewController.h
//  HansServer
//
//  Created by jia yu on 2022/9/29.
//

#import <UIKit/UIKit.h>

/*
 UIHansAboutViewController *v = [[UIHansAboutViewController alloc] init];
 v.handler = ^(NSURL * _Nonnull url) {
     [UIApplication.sharedApplication openURL:url options:@{} completionHandler:^(BOOL success) {
                 
     }];
 };
 [[UIHans currentVC] presentViewController:v animated:YES completion:nil];
 */

typedef void (^UIHansAboutViewController_Handler) (NSURL * _Nonnull url);

@interface UIHansAboutViewController : UIViewController
@property (nonatomic) UIHansAboutViewController_Handler _Nonnull handler;
@end
