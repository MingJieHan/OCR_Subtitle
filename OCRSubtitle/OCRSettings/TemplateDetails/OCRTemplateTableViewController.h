//
//  OCRTemplateTableViewController.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/11.
//

#import <UIKit/UIKit.h>
@class OCRSetting,OCRTemplateTableViewController;
typedef void (^OCRTemplateTableViewController_Changed) (OCRTemplateTableViewController * _Nonnull vc);

NS_ASSUME_NONNULL_BEGIN
@interface OCRTemplateTableViewController : UITableViewController
@property (nonatomic,readonly) OCRSetting *setting;
@property (nonatomic) OCRTemplateTableViewController_Changed changedHandler;
-(id)initWithSetting:(OCRSetting *)setting;



-(id)init NS_UNAVAILABLE;
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
-(id)initWithNibName:(NSString * _Nullable )nibNameOrNil bundle:(NSBundle * _Nullable )nibBundleOrNil NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
