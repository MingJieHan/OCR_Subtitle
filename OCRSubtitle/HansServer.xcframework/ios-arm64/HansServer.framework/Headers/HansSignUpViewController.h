//
//  SignUpViewController.h
//  HansServer
//
//  Created by jia yu on 2021/7/20.
//

#import <UIKit/UIKit.h>
#import <HansServer/HansServerHandler.h>

NS_ASSUME_NONNULL_BEGIN
@interface HansSignUpViewController : UIViewController
@property (nonatomic) UIView *titleView;
@property (nonatomic) UIColor *boardColor;
@property (nonatomic) UIColor *boardCurrentColor;
@property (nonatomic) UIColor *signatureColor;
@property (nonatomic) NSString *companyName;
@property (nonatomic) NSString *serviceURLString;
@property (nonatomic) NSString *policyURLString;
@property (nonatomic) HansServer_Login_Handler signupHandler;
@end

NS_ASSUME_NONNULL_END
