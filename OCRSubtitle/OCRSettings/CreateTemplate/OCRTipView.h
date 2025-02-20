//
//  OCRTipView.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface OCRTipView : UIView
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)init NS_UNAVAILABLE;

-(id)initWithFrame:(CGRect)frame;
-(void)showWithTitle:(NSString *)title withText:(NSString *)text;
-(void)hiddenTip;
@end
NS_ASSUME_NONNULL_END
