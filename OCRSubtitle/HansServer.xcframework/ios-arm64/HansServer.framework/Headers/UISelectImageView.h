//
//  UISelectImageView.h
//  vhECGSmart
//
//  Created by Han Mingjie on 2020/3/3.
//  Copyright © 2020 MingJie Han. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol UISelectImageViewDelegate;
@interface UISelectImageView : UIView{
    id <UISelectImageViewDelegate> delegate;
    id image_target;
    CGFloat target_aspect_ratio;        //target image width/height
    BOOL rounded_mask;
}
@property (nonatomic) id <UISelectImageViewDelegate> delegate;
@property (nonatomic) id image_target;
@property (nonatomic) CGFloat target_aspect_ratio;
@property (nonatomic) BOOL rounded_mask;
-(void)selectImage;
-(void)takeImage;
@end

@protocol UISelectImageViewDelegate <NSObject>
@required;
-(void)selectedImage:(UISelectImageView *)selecter withImage:(NSData * __nullable)imageData;

@end
NS_ASSUME_NONNULL_END
