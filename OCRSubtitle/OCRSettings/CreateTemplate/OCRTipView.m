//
//  OCRTipView.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/14.
//

#import "OCRTipView.h"
#import <HansServer/HansServer.h>

@interface OCRTipView(){
    UILabel *tipLabel;
    UIButton *closeButton;
}
@end


@implementation OCRTipView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIHans colorFromHEXString:@"FDBD0D"];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.f, 2.f);
        tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(125.f, 60.f, frame.size.width-130.f, frame.size.height-80.f)];
        tipLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12.f];
        tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tipLabel.numberOfLines = 4;
        [self addSubview:tipLabel];
        
        UISwipeGestureRecognizer *ges = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction:)];
        ges.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:ges];
        
        closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.f, frame.size.height-16.f, frame.size.width, 16.f)];
        closeButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [closeButton setTitle:@"^" forState:UIControlStateNormal];
        closeButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Meidum" size:12.f];
        [closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
    }
    return self;
}

-(void)gestureAction:(id)sender{
    [self hiddenTip];
    return;
}

-(void)closeButtonAction:(id)sender{
    [self hiddenTip];
    return;
}

-(void)showWithString:(NSString *)string{
    tipLabel.text = string;
    [UIView animateWithDuration:0.6f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self setFrame:CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height)];
    } completion:^(BOOL finished) {
        
    }];
    return;
}

-(void)hiddenTip{
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setFrame:CGRectMake(0.f, -self.frame.size.height, self.frame.size.width, self.frame.size.height)];
    } completion:^(BOOL finished) {

    }];
}
@end
