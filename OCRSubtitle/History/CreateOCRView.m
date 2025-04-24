//
//  CreateOCRView.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/13.
//

#import "CreateOCRView.h"
#import <HansServer/HansServer.h>
@interface CreateOCRView(){
    UILabel *addLabel;
    UILabel *textLabel;
}
@end

@implementation CreateOCRView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 6.f;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        addLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.f, 16.f, frame.size.width-36.f, frame.size.height * 0.5+6.f)];
        addLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        addLabel.backgroundColor = [UIColor whiteColor];
        addLabel.textColor = [UIHans colorFromHEXString:@"FD8206"];
        addLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:64.f];
        addLabel.text = @"+";
        addLabel.layer.masksToBounds = YES;
        addLabel.layer.cornerRadius = 6.f;
        addLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:addLabel];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, frame.size.height * 0.75, frame.size.width, 40.f)];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = addLabel.textColor;
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f];
        textLabel.text = NSLocalizedString(@"Scan Video", nil);
        [self addSubview:textLabel];
    }
    return self;
}


-(void)clickAnimated{
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [UIHans colorFromHEXString:@"EFEEF6"];
        self.layer.borderWidth = 3.f;
        self.layer.borderColor = self->addLabel.textColor.CGColor;
    } completion:^(BOOL finished) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 0.f;
    }];
    return;
}
@end
