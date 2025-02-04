//
//  OCRProgressViewController.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface OCRProgressViewController : UIViewController
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)initWithNibName:(NSString * _Nullable )nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil NS_UNAVAILABLE;


@property (nonatomic) float progress;
@property (nonatomic) CGImageRef image;
@end
NS_ASSUME_NONNULL_END
