//
//  SCRStorageImageView.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SCRStorageImageView : UIImageView
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)init NS_UNAVAILABLE;
-(id)initWithImage:(nullable UIImage *)image NS_UNAVAILABLE;
-(id)initWithImage:(nullable UIImage *)image highlightedImage:(nullable UIImage *)highlightedImage NS_UNAVAILABLE;

-(id)initWithFrame:(CGRect)frame;
-(void)receivedAnimate;
@end
NS_ASSUME_NONNULL_END
