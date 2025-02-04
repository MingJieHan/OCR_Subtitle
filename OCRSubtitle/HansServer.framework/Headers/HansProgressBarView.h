//
//  HansProgressBarView.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface HansProgressBarView:UIView
@property (nonatomic) UIColor *completedColor;
@property (nonatomic) UIColor *unCompletedColor;
@property (nonatomic) UIColor *boardColor;
@property (nonatomic) UIFont *progressFont;
@property (nonatomic) float progress;


-(id)init NS_UNAVAILABLE;
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

-(id)initWithFrame:(CGRect)frame;
@end
NS_ASSUME_NONNULL_END
