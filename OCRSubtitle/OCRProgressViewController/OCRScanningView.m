//
//  OCRScanningView.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/9.
//

#import "OCRScanningView.h"

@interface OCRScanningView(){
    UIView *lineView;
}
@end

@implementation OCRScanningView
-(id)init{
    self = [super init];
    if (self){
//        self.backgroundColor = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:0.8];
        self.backgroundColor = [UIColor clearColor];
        self.layer.borderWidth = 2.f;
        self.layer.borderColor = [UIColor yellowColor].CGColor;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 3.f;
        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, 4.f, self.frame.size.height)];
        lineView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        lineView.backgroundColor = [UIColor greenColor];
        [self addSubview:lineView];
        
        [self animated];
    }
    return self;
}

-(void)animated{
    float duration = 2.13f;
    float space = 0.1f;
    [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
        [self->lineView setFrame:CGRectMake(self.frame.size.width, 0.f,
                                            self->lineView.frame.size.width,
                                            self->lineView.frame.size.height)];
    } completion:^(BOOL finished) {
        
    }];
    [UIView animateWithDuration:duration delay:duration+space options:UIViewAnimationOptionCurveLinear animations:^{
        [self->lineView setFrame:CGRectMake(0.f, 0.f,
                                            self->lineView.frame.size.width,
                                            self->lineView.frame.size.height)];
    } completion:^(BOOL finished) {
        [self performSelector:@selector(animated) withObject:nil afterDelay:space];
    }];
    return;
}

@end
