//
//  AreaSubtitleTipView.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/18.
//

#import "AreaSubtitleTipView.h"

@interface AreaSubtitleTipView(){
    CGPoint targetCenter;
    NSTimer *animateTimer;
}
@end

@implementation AreaSubtitleTipView
-(id)initWithCenter:(CGPoint)center withScale:(CGFloat)scale{
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"hand" ofType:@"png"]];
    self = [super initWithImage:image];
    if (self){
        targetCenter = center;
        [self setFrame:CGRectMake(0.f, 0.f, image.size.width, image.size.height)];
        self.alpha = 1.f;
    }
    return self;
}

-(void)animateStart{
    [self setCenter:CGPointMake(targetCenter.x + 22.f, targetCenter.y - 60)];
    animateTimer = [NSTimer scheduledTimerWithTimeInterval:2.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [UIView animateWithDuration:1.f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alpha = 1.f;
            self.transform = CGAffineTransformMakeScale(1.3f, 1.3f);
        } completion:^(BOOL finished) {
            
        }];
        [UIView animateWithDuration:1.f delay:1.1f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformMakeScale(1.f, 1.f);
        } completion:^(BOOL finished) {
            
        }];
    }];
    [animateTimer fire];
}

-(void)animateStop{
    [animateTimer invalidate];
    animateTimer = nil;
}
@end
