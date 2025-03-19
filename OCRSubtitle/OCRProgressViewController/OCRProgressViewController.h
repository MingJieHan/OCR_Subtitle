//
//  OCRProgressViewController.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/3.
//

#import <UIKit/UIKit.h>
#import "SCRStorageImageView.h"

NS_ASSUME_NONNULL_BEGIN
@interface OCRProgressViewController : UIViewController
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)initWithNibName:(NSString * _Nullable )nibNameOrNil bundle:(NSBundle * _Nullable)nibBundleOrNil NS_UNAVAILABLE;

@property (nonatomic) float progress;           //float 0.f -> 1.f;
@property (nonatomic) CGImageRef image;         //
@property (nonatomic) NSString *gottedString;   //Animate string.
@property (nonatomic,readonly) SCRStorageImageView *storageImageView;    //for animated target

@property (nonatomic) UIColor *gottedStringColor;
@property (nonatomic) UIColor *gottedStringBorderColor;
@property (nonatomic) float gottedStringBorderWidth;

@property (nonatomic) float passTopRate;
@property (nonatomic) float heightRate;
@end
NS_ASSUME_NONNULL_END
