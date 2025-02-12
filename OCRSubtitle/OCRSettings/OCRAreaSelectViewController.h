//
//  OCRAreaSelectViewController.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/10.
//

#import <UIKit/UIKit.h>


@class OCRAreaSelectViewController;
typedef void (^OCRAreaSelectViewController_CloseHandler) (OCRAreaSelectViewController * _Nonnull vc);

NS_ASSUME_NONNULL_BEGIN
@interface OCRAreaSelectViewController:UIViewController
-(id)initWithVideo:(NSURL *)videoURL;
@property (nonatomic) OCRAreaSelectViewController_CloseHandler handler;
@property (nonatomic,readonly) NSString *suggestName;
@property (nonatomic,readonly) UIImage *thumbnailImage;
@property (nonatomic,readonly) CGSize videoSize;
@property (nonatomic,readonly) float passTopRate;
@property (nonatomic,readonly) float heightRate;
@property (nonatomic,readonly) NSString *scaningLanguageIdentifier;
@end
NS_ASSUME_NONNULL_END
