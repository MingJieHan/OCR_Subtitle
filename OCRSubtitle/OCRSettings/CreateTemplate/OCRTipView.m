//
//  OCRTipView.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/14.
//

#import "OCRTipView.h"
#import <HansServer/HansServer.h>

@interface OCRTipView(){
    UILabel *tipTitleLabel;
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
        
        //space 70pix for the cancel button
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            tipTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.f, 23.f, frame.size.width-130.f, 40.f)];
            tipTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:28.f];
        }else{
            tipTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.f, 53.f, frame.size.width-130.f, 24.f)];
            tipTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:20.f];
        }
        tipTitleLabel.textAlignment = NSTextAlignmentCenter;
        tipTitleLabel.adjustsFontSizeToFitWidth = YES;
        tipTitleLabel.textColor = [UIColor whiteColor];
        tipTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:tipTitleLabel];
        
        float y = CGRectGetMaxY(tipTitleLabel.frame) + 3;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.f, y, frame.size.width-70.f, 40.f)];
            tipLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.f];
            tipLabel.numberOfLines = 1;
        }else{
            tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.f, y, frame.size.width-70.f, 34.f)];
            tipLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12.f];
            tipLabel.numberOfLines = 2;
        }
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.adjustsFontSizeToFitWidth = YES;
        tipLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
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

-(void)showWithTitle:(NSString *)title withText:(NSString *)text;{
    tipTitleLabel.text = title;
    tipLabel.text = text;
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
