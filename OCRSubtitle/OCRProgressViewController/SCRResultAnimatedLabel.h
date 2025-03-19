//
//  SCRResultAnimatedLabel.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/21.
//

#import "HansBorderLabel.h"

@class SCRResultAnimatedLabel;
typedef void (^SCRResultAnimatedLabel_AnimateCompleted) (SCRResultAnimatedLabel * _Nonnull label);

NS_ASSUME_NONNULL_BEGIN
@interface SCRResultAnimatedLabel : HansBorderLabel
@property (nonatomic) CGPoint targetCenter;
@property (nonatomic) SCRResultAnimatedLabel_AnimateCompleted completedHandler;

-(id)initWithFrame:(CGRect)frame;
-(void)startAnimateWithTargetCenter:(CGPoint)targetCenter;

@end
NS_ASSUME_NONNULL_END
