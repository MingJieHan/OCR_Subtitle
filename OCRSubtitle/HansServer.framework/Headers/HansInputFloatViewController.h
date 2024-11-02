//
//  HansInputFloatViewController.h
//  HansEditingViewController
//
//  Created by jia yu on 2021/7/4.
//


/*
 
 HansInputFloatViewController *v = [[HansInputFloatViewController alloc] initWithFloat:4.5];
 v.bitAfter = 1;
 v.bitBefore = 2;
 v.unitName = @"Sec";
 v.handler = ^(float resultValue) {
     
 };
//    HansManyLineStringEditViewController *v = [[HansManyLineStringEditViewController alloc] init];
//    v.defaultValue = @"abc";
//    v.handler = ^(BOOL changed, NSString * _Nullable value) {
//        return;
//    };
 
 UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:v];
 [self presentViewController:nav animated:YES completion:nil];
//    [self.navigationController pushViewController:v animated:YES];
 
 */


#import <UIKit/UIKit.h>

typedef void (^HansInputFloatViewController_Handler) (float resultValue);

NS_ASSUME_NONNULL_BEGIN
@interface HansInputFloatViewController : UIViewController
@property (nonatomic,readonly) float value;
@property (nonatomic) NSUInteger bitBefore; //Contral bits before ".", defautl is 2
@property (nonatomic) NSUInteger bitAfter;  //Contral bits after ".", default is 0
@property (nonatomic) HansInputFloatViewController_Handler handler;
@property (nonatomic) NSString *unitName;   //unitName is showed with last bit, default is @""
-(id)initWithFloat:(float)value;

@end
NS_ASSUME_NONNULL_END


