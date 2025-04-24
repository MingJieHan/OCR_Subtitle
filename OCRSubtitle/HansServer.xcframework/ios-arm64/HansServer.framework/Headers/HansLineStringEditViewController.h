//
//  LineStringEditViewController.h
//  iOSWithDjango
//
//  Created by jia yu on 2020/12/30.
//

#import <UIKit/UIKit.h>
#import <HansServer/HansServer.h>

typedef void (^LineStringEditViewController_Done_Handler)(BOOL changed, NSString * _Nullable value);

NS_ASSUME_NONNULL_BEGIN
@interface HansLineStringEditViewController : UIViewController
@property (nonatomic) LineStringEditViewController_Done_Handler handler;
@property (nonatomic) NSString *defaultValue;
@end
NS_ASSUME_NONNULL_END
