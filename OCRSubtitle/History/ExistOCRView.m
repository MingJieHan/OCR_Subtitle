//
//  ExistOCRView.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/13.
//

#import "ExistOCRView.h"
#import <HansServer/HansServer.h>
@interface ExistOCRView(){
    UIImageView *bView;
    UILabel *nameLabel;
    UILabel *completedLabel;
    UILabel *usageLabel;
}
@end

@implementation ExistOCRView
@synthesize item;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 6.f;
        float y = 0.f;
        
        bView = [[UIImageView alloc] initWithFrame:CGRectMake(3.f, 2.f, self.frame.size.width-6.f, self.frame.size.height * 0.75)];
        bView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        bView.layer.cornerRadius = 4.f;
        bView.layer.masksToBounds = YES;
        bView.layer.borderColor = [UIHans colorFromHEXString:@"E5E5E5"].CGColor;
        bView.layer.borderWidth = 2.f;
        bView.backgroundColor = [UIColor clearColor];
        bView.contentMode = UIViewContentModeScaleAspectFit;
        bView.userInteractionEnabled = YES;
        [self addSubview:bView];
        
        y = CGRectGetMaxY(bView.frame) + 5.f;
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.f, y, self.frame.size.width-40.f, 18.f)];
        nameLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14.f];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIHans black];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:nameLabel];
        
        y = CGRectGetMaxY(nameLabel.frame);
        completedLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.f, y, self.frame.size.width-10.f, 18.f)];
        completedLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10.f];
        completedLabel.textAlignment = NSTextAlignmentCenter;
        completedLabel.backgroundColor = [UIColor clearColor];
        completedLabel.textColor = [UIHans gray];
        [self addSubview:completedLabel];
        
        y = CGRectGetMaxY(completedLabel.frame);
        usageLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.f, y, self.frame.size.width-10.f, 18.f)];
        usageLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f];
        usageLabel.adjustsFontSizeToFitWidth = YES;
//        [self addSubview:usageLabel];
    }
    return self;
}

+(NSString *)stringWithDate:(NSDate *)date withStyle:(NSDateFormatterStyle)style{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeZone:NSTimeZone.localTimeZone];
    [df setLocale:NSLocale.currentLocale];
    [df setTimeStyle:style];
    [df setDateStyle:style];
    return [df stringFromDate:date];
}

-(void)setItem:(OCRHistory *)_item{
    item = _item;
    if (item.thumbnailImageData){
        bView.image = [[UIImage alloc] initWithData:item.thumbnailImageData];
    }else{
        bView.image = nil;
    }
    nameLabel.text = [item.file lastPathComponent];
    completedLabel.text = [item.completedDate stringValue];
    usageLabel.text = [NSString stringWithFormat:@"Usage: %.0f sec", item.usageSeconds];
}

-(void)clickAnimated{
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundColor = [UIHans colorFromHEXString:@"EFEEF6"];
        self.layer.borderWidth = 3.f;
        self.layer.borderColor = [UIHans colorFromHEXString:@"FD8206"].CGColor;
    } completion:^(BOOL finished) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 0.f;
    }];
    return;
}
@end
