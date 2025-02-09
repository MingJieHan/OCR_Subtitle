//
//  GottedTextLabel.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface HansBorderLabel : UILabel
-(id)init NS_UNAVAILABLE;
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

-(id)initWithFrame:(CGRect)frame;

@property (nonatomic) UIColor *borderColor;
@property (nonatomic) float borderWidth;
@end
NS_ASSUME_NONNULL_END
