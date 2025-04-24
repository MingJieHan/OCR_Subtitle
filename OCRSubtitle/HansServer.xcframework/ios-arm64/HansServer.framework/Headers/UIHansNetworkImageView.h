//
//  UIHansImageView.h
//  HansServer
//
//  Created by jia yu on 2024/1/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIHansNetworkImageView : UIImageView
-(id)init NS_UNAVAILABLE;
-(id)initWithImage:(nullable UIImage *)image NS_UNAVAILABLE;
-(id)initWithCoder:(nullable NSCoder *)coder NS_UNAVAILABLE;
-(id)initWithImage:(nullable UIImage *)image highlightedImage:(nullable UIImage *)highlightedImage  NS_UNAVAILABLE;

-(id)initWithFrame:(CGRect)frame;
@property (nonatomic, nullable) NSString *url;
@property (nonatomic, nonnull) UIImage *emptyImage;  //default is account back image.
@end
NS_ASSUME_NONNULL_END
