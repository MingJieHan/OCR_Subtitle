//
//  SCRResultAnimatedLabel.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/21.
//

#import "SCRResultAnimatedLabel.h"

@implementation SCRResultAnimatedLabel
@synthesize targetCenter;
@synthesize completedHandler;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.borderColor = [UIColor blackColor];
        self.borderWidth = 3.f;
        self.fontColor = [UIColor whiteColor];
        self.text = @"SCRResultAnimatedLabel";
        self.alpha = 0.f;
    }
    return self;
}


-(void)startAnimateWithTargetCenter:(CGPoint)_center{
    [UIView animateWithDuration:0.3
                          delay:0.f
                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.5
                              delay:0.3f
                            options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
            self.transform = CGAffineTransformMakeScale(0.1, 0.1);
            [self setCenter:_center];
        } completion:^(BOOL finished) {
            [self completedAnimatedAnLabel];
            [self removeFromSuperview];
        }];
    }];
}


-(void)setTargetCenter:(CGPoint)_targetCenter{
    targetCenter = _targetCenter;
    [self.layer removeAllAnimations];
    
    [UIView animateWithDuration:1.3f
                          delay:0.f
                        options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        [self setCenter:self->targetCenter];
    } completion:^(BOOL finished) {
        
    }];
}

-(void)completedAnimatedAnLabel{
    if (completedHandler){
        completedHandler(self);
    }
}
@end
