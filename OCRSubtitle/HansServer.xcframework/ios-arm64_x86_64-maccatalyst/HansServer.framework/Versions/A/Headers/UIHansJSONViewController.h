//
//  UIHansDictionaryViewController.h
//  HansServer
//
//  Created by jia yu on 2024/9/19.
//

#import <UIKit/UIKit.h>
@class UIHansJSONViewController;
typedef void (^UIHansJSONViewController_closeHandler) (UIHansJSONViewController * _Nonnull vc);
typedef void (^UIHansJSONViewController_openURLHandler) (UIHansJSONViewController * _Nonnull vc, NSString * _Nonnull url);

NS_ASSUME_NONNULL_BEGIN
@interface UIHansJSONViewController : UITableViewController
- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(nullable NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle * )nibBundleOrNil NS_UNAVAILABLE;
- (nonnull instancetype)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;

+(UIBarButtonItem *)barButtonWithTarget:(nullable id)target action:(nullable SEL)action;
-(instancetype _Nullable)initWithDictionary:(NSDictionary * _Nonnull)dict;
-(nullable instancetype)initWithArray:(nonnull NSArray *)array;

@property (nonatomic) UIHansJSONViewController_closeHandler _Nullable closeHandler;
@property (nonatomic) UIHansJSONViewController_openURLHandler _Nullable openURLHandler;

@end
NS_ASSUME_NONNULL_END
