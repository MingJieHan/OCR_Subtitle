//
//  ExistOCRView.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/13.
//

#import <UIKit/UIKit.h>
#import "OCRHistory.h"

NS_ASSUME_NONNULL_BEGIN
@interface ExistOCRView : UIView
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)init NS_UNAVAILABLE;

@property (nonatomic) OCRHistory * _Nonnull item;
-(id)initWithFrame:(CGRect)frame;
-(void)clickAnimated;
@end
NS_ASSUME_NONNULL_END
