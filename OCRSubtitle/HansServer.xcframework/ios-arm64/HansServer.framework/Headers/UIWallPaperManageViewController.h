//
//  UIWallPaperManageViewController.h
//  HansServer
//
//  Created by jia yu on 2024/7/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIWallPaperManageViewController : UIViewController
-(id)init NS_UNAVAILABLE;
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

+(UIWallPaperManageViewController *)shared;
-(UIImage *)wallImageWithIndex:(NSInteger)index;
@end
NS_ASSUME_NONNULL_END
