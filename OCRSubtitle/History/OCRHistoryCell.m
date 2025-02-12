//
//  OCRHistoryCell.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import "OCRHistoryCell.h"

@interface OCRHistoryCell(){
    UIImageView *bView;
    UILabel *nameLabel;
    UIButton *shareButton;
    UILabel *completedLabel;
    UILabel *usageLabel;
}
@end

@implementation OCRHistoryCell
@synthesize item;
@synthesize moreHandler;

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (self.selected){
        bView.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.7];
    }else{
        bView.backgroundColor  = [UIColor lightGrayColor];
    }
}

-(void)checkItems{
    if (nil == nameLabel){
        self.backgroundColor = [UIColor clearColor];
        bView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height)];
        bView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        bView.layer.cornerRadius = 3.f;
        bView.layer.masksToBounds = YES;
        bView.backgroundColor = [UIColor lightGrayColor];
        bView.contentMode = UIViewContentModeScaleAspectFill;
        bView.userInteractionEnabled = YES;
        [self addSubview:bView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.f, 3.f, bView.frame.size.width-10.f, 18.f)];
        nameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        [bView addSubview:nameLabel];
        
        completedLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.f, 23.f, bView.frame.size.width-10.f, 18.f)];
        completedLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f];
        completedLabel.adjustsFontSizeToFitWidth = YES;
        [bView addSubview:completedLabel];
        
        usageLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.f, 43.f, bView.frame.size.width-10.f, 18.f)];
        usageLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f];
        usageLabel.adjustsFontSizeToFitWidth = YES;
        [bView addSubview:usageLabel];
        
        shareButton = [[UIButton alloc] initWithFrame:CGRectMake(bView.frame.size.width-40.f, 0.f, 40.f, 40.f)];
        shareButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
        shareButton.backgroundColor = [UIColor blueColor];
        [bView addSubview:shareButton];
    }
    return;
}

-(void)shareAction{
    if (moreHandler){
        moreHandler(self);
    }
}

-(void)setItem:(OCRHistory *)_item{
    item = _item;
    [self checkItems];

    if (nil == item){
        bView.image = nil;
        shareButton.alpha = 0.f;
        nameLabel.text = @"+ New Subtitle";
        completedLabel.text = @"";
        usageLabel.text = @"";
    }else{
        if (item.thumbnailImageData){
            bView.image = [[UIImage alloc] initWithData:item.thumbnailImageData];
        }else{
            bView.image = nil;
        }
        shareButton.alpha = 1.f;
        nameLabel.text = [item.file lastPathComponent];
        completedLabel.text = [NSString stringWithFormat:@"OCR At:%@",item.completedDate];
        usageLabel.text = [NSString stringWithFormat:@"Usage: %.0f sec", item.usageSeconds];
    }
    return;
}
@end
