//
//  AreaSubtitleTipView.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface AreaSubtitleTipView : UIImageView
-(id)initWithCenter:(CGPoint)center withScale:(CGFloat)scale;
-(void)animateStart;
-(void)animateStop;

-(id)init NS_UNAVAILABLE;
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
-(id)initWithImage:(nullable UIImage *)image NS_UNAVAILABLE;
-(id)initWithImage:(nullable UIImage *)image highlightedImage:(nullable UIImage *)highlightedImage NS_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
