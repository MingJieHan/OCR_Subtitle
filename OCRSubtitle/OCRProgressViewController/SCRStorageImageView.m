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
    float x = self.frame.size.width * 230.f/621.f;
    float width = self.frame.size.width * 154.f/621.f;
    float startY = self.frame.size.height * 377.f/726.f;
    float endY = self.frame.size.height * 532.f/726.f;
    UIView *receiveView = [[UIView alloc] initWithFrame:CGRectMake(x, startY, width, 2.2f)];
    receiveView.autoresizingMask = UIViewAutoresizingNone;
    receiveView.layer.masksToBounds = YES;
    receiveView.layer.cornerRadius = 1.f;
    receiveView.backgroundColor = [UIHans colorFromHEXString:@"2A943C"];
    [self addSubview:receiveView];
    
    [UIView animateWithDuration:0.5f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [receiveView setCenter:CGPointMake(self.frame.size.width/2.f, endY)];
        receiveView.backgroundColor = [UIHans colorFromHEXString:@"7D8090"];
    }completion:^(BOOL finished) {
        if (finished){
            [receiveView removeFromSuperview];
        }
    }];
    return;
}
@end
