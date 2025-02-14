//
//  OCRTemplateCell.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import "OCRTemplateCell.h"
#import "HansBorderLabel.h"
#import <HansServer/HansServer.h>

@interface OCRTemplateCell(){
    UIImageView *backImageView;
    UILabel *nameLabel;
    UILabel *sizeLabel;
    UILabel *languageLabel;
    UILabel *rateLabel;
    HansBorderLabel *fontLabel;
    UIView *scanView;
    UIButton *infoButton;
    UIHansButton *removeButton;
}
@end

@implementation OCRTemplateCell
@synthesize item;
@synthesize moreHandler;
@synthesize removeHandler;

-(void)checkItem{
    if (nil == backImageView){
        self.backgroundColor = templateColor;
        self.layer.cornerRadius = 6.f;
        self.layer.masksToBounds = YES;
        self.layer.shadowColor = [UIHans gray].CGColor;
        self.layer.shadowOffset = CGSizeMake(2.f, 2.f);
        float y = 0.f;
        
        backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height-32.f)];
        backImageView.contentMode = UIViewContentModeScaleAspectFit;
        backImageView.backgroundColor = [UIHans lightestGray];
        backImageView.layer.masksToBounds = YES;
        backImageView.layer.cornerRadius = 3.f;
        [self addSubview:backImageView];
        UILongPressGestureRecognizer *l = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
        [self addGestureRecognizer:l];
        
        y = CGRectGetMaxY(backImageView.frame)+1.f;
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, y, self.frame.size.width, 16.f)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.textColor = [UIHans colorFromHEXString:@"0A0A0A"];
        nameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f];
        nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:nameLabel];
        
        y = CGRectGetMaxY(nameLabel.frame);
        sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, y, self.frame.size.width, 14.f)];
        sizeLabel.textAlignment = NSTextAlignmentCenter;
        sizeLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:10.f];
        sizeLabel.textColor = [UIHans gray];
        sizeLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:sizeLabel];
        
        languageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 25.f, self.frame.size.width-15.f, 16.f)];
//        [self addSubview:languageLabel];
        
        rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 45.f, self.frame.size.width-15.f, 16.f)];
//        [self addSubview:rateLabel];
        
        scanView = [[UIView alloc] init];
        scanView.backgroundColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:0.6];
//        [backImageView addSubview:scanView];
        
        fontLabel = [[HansBorderLabel alloc] initWithFrame:CGRectMake(10.f, 50.f, self.frame.size.width-20.f, 30.f)];
        fontLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24.f];
        fontLabel.text = @"字幕样本";
//        [self addSubview:fontLabel];
        
        infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [infoButton setFrame:CGRectMake(0.f, 0.f, 30.f, 30.f)];
        [infoButton addTarget:self action:@selector(infoButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:infoButton];
        
        removeButton = [[UIHansButton alloc] initWithFrame:CGRectMake(self.frame.size.width-35.f, -5.f, 40.f, 40.f)];
        removeButton.enabled = YES;
        removeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
        [removeButton addTarget:self action:@selector(removeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [removeButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"delete" ofType:@"png"]] forState:UIControlStateNormal];
        [removeButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"delete_disable" ofType:@"png"]] forState:UIControlStateDisabled];
        [removeButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [removeButton setBackgroundColor:[UIColor grayColor] forState:UIControlStateHighlighted];
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

-(void)longPressed:(id)sender{
    NSLog(@"Long pressed.");
    [self infoButtonAction];
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
    nameLabel.text = item.name;
    
    sizeLabel.text = [NSString stringWithFormat:@"Dimensions: %dx%d", [item.videoWidth intValue] , [item.videoHeight intValue]];
    languageLabel.text = [item languageString];
    [scanView setFrame:CGRectMake(0.f, item.passTopRate * backImageView.frame.size.height, backImageView.frame.size.width, item.heightRate * self.frame.size.height)];
    
    fontLabel.textColor = item.textColor;
    fontLabel.borderColor = item.borderColor;
    fontLabel.borderWidth = 3.f;
    rateLabel.text = [NSString stringWithFormat:@"Sample Rate:%d times/second", item.rate];
    return;
}
@end
