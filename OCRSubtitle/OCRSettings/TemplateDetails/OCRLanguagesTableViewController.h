//
//  OCRLanguagesTableViewController.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/11.
//

#import <UIKit/UIKit.h>

@class OCRLanguagesTableViewController;
typedef void (^OCRLanguagesTableViewController_SaveHandler) (OCRLanguagesTableViewController * _Nonnull vc);

NS_ASSUME_NONNULL_BEGIN
@interface OCRLanguagesTableViewController : UITableViewController
@property (nonatomic) NSMutableArray *selectedLanguages;
@property (nonatomic) OCRLanguagesTableViewController_SaveHandler saveHandler;
@property (nonatomic) BOOL oneLanguageOnly; //default is NO;
-(id)init;



-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)initWithStyle:(UITableViewStyle)style NS_UNAVAILABLE;
-(id)initWithNibName:(NSString * _Nullable)nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
