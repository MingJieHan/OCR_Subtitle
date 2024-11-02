//
//  LoginViewController.h
//  HansServer
//
//  Created by jia yu on 2021/7/20.
//

#import <UIKit/UIKit.h>
#import <HansServer/HansServerHandler.h>


/*
 HansLoginViewController *loginViewController = [HansLoginViewController alloc] init];
 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
 nav.modalPresentationStyle = UIModalPresentationFullScreen;
 if (@available(iOS 13.0, *)) {
     UINavigationBarAppearance *bar = [[UINavigationBarAppearance alloc] init];
     bar.backgroundColor = [UIColor whiteColor];
     bar.backgroundEffect = nil;
     nav.navigationBar.scrollEdgeAppearance = bar;
     nav.navigationBar.standardAppearance = bar;
 } else {
     nav.navigationBar.tintColor = [UIColor blueColor];
 }
 nav.navigationBar.translucent = NO;
 [self presentViewController:nav animated:YES completion:nil];
 */


NS_ASSUME_NONNULL_BEGIN
@interface HansLoginViewController : UIViewController
@property (nonatomic) UIView *titleView;
@property (nonatomic) UIColor *boardColor;
@property (nonatomic) UIColor *boardCurrentColor;
@property (nonatomic) UIColor *signatureColor;
@property (nonatomic) UIColor *loginColor;
@property (nonatomic) NSString *companyName;
@property (nonatomic) NSString *serviceURLString;       //default is /static/TermsOfService.pdf
@property (nonatomic) NSString *policyURLString;        //default is /static/PrivacyPolicy.pdf
@property (nonatomic) HansServer_Login_Handler loginHandler;


-(id)init NS_UNAVAILABLE;
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)initWithNibName:(NSString * __nullable)nibNameOrNil bundle:(NSBundle * __nullable )nibBundleOrNil NS_UNAVAILABLE;

+(HansLoginViewController *)shareWithHandler:(HansServer_Login_Handler)loginHandler;
@end
NS_ASSUME_NONNULL_END
