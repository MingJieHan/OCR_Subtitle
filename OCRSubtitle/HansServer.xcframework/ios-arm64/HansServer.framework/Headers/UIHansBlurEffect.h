//
//  UIHansBlurEffect.h
//  vhStressECG
//
//  Created by jia yu on 2022/8/3.
//

#import <UIKit/UIKit.h>

@interface UIBlurEffect (Protected)
@property (nonatomic,readonly) id effectSettings;
@end


@interface UIHansBlurEffect : UIBlurEffect
+ (UIBlurEffect *)effectWithStyle:(UIBlurEffectStyle)style radius:(float)radius;
@end
