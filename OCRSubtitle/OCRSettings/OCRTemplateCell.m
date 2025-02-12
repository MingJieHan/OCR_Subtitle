//
//  OCRTemplateCell.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import "OCRTemplateCell.h"
#import "HansBorderLabel.h"
@interface OCRTemplateCell(){
    UIImageView *backImageView;
    UILabel *sizeLabel;
    UILabel *languageLabel;
    UILabel *rateLabel;
    HansBorderLabel *fontLabel;
    UIView *scanView;
    UIButton *infoButton;
    UIButton *removeButton;
}
@end

@implementation OCRTemplateCell
@synthesize item;
@synthesize moreHandler;
@synthesize removeHandler;

-(void)checkItem{
    if (nil == backImageView){
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
        
        backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1.f, 1.f, self.frame.size.width-2.f, self.frame.size.height-2.f)];
        backImageView.backgroundColor = [UIColor lightGrayColor];
        backImageView.layer.masksToBounds = YES;
        backImageView.layer.cornerRadius = 3.f;
        [self addSubview:backImageView];
        
        sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 5.f, self.frame.size.width-15.f, 16.f)];
        [self addSubview:sizeLabel];
        
        languageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 25.f, self.frame.size.width-15.f, 16.f)];
        [self addSubview:languageLabel];
        
        rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 45.f, self.frame.size.width-15.f, 16.f)];
        [self addSubview:rateLabel];
        
        scanView = [[UIView alloc] init];
        scanView.backgroundColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:0.6];
        [backImageView addSubview:scanView];
        
        fontLabel = [[HansBorderLabel alloc] initWithFrame:CGRectMake(10.f, 50.f, self.frame.size.width-20.f, 30.f)];
        fontLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24.f];
        fontLabel.text = @"字幕样本";
        [self addSubview:fontLabel];
        
        infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [infoButton setFrame:CGRectMake(self.frame.size.width-40.f, 0.f, 40.f, 40.f)];
        infoButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [infoButton addTarget:self action:@selector(infoButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:infoButton];
        
        removeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-40.f, 60.f, 40.f, 40.f)];
        removeButton.backgroundColor = [UIColor blueColor];
        removeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [removeButton addTarget:self action:@selector(removeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:removeButton];
    }
    return;
}

-(void)removeButtonAction{
    if (removeHandler){
        removeHandler(self);
    }
    return;
}
-(void)infoButtonAction{
    if (moreHandler){
        moreHandler(self);
    }
    return;
}

-(void)setItem:(OCRSetting *)_item{
    if (item == _item){
        return;
    }
    item = _item;
    [self checkItem];
    backImageView.image = item.image;
    sizeLabel.text = [NSString stringWithFormat:@"Dimensions: %d x %d", [item.videoWidth intValue] , [item.videoHeight intValue]];
    languageLabel.text = [item languageString];
    [scanView setFrame:CGRectMake(0.f, item.passTopRate * backImageView.frame.size.height, backImageView.frame.size.width, item.heightRate * self.frame.size.height)];
    
    fontLabel.textColor = item.textColor;
    fontLabel.borderColor = item.borderColor;
    fontLabel.borderWidth = 3.f;
    rateLabel.text = [NSString stringWithFormat:@"Sample Rate:%d times/second", item.rate];
    return;
}
@end
