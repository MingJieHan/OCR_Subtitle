//
//  SCRStorageImageView.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/21.
//

#import "SCRStorageImageView.h"
#import <HansServer/HansServer.h>
@interface SCRStorageImageView(){
    
}
@end

@implementation SCRStorageImageView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        
    }
    return self;
}

-(void)receivedAnimate{
    UIView *receiveView = [[UIView alloc] initWithFrame:CGRectMake(13.f, self.frame.size.height/2.f-1.f, self.frame.size.width-26.f, 2.2f)];
    receiveView.autoresizingMask = UIViewAutoresizingNone;
    receiveView.layer.masksToBounds = YES;
    receiveView.layer.cornerRadius = 1.f;
    receiveView.backgroundColor = [UIHans colorFromHEXString:@"2A943C"];
    [self addSubview:receiveView];
    
    [UIView animateWithDuration:0.5f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        [receiveView setCenter:CGPointMake(self.frame.size.width/2.f, self.frame.size.height-2.f)];
    }completion:^(BOOL finished) {
        if (finished){
            [receiveView removeFromSuperview];
        }
    }];
    return;
}
@end
