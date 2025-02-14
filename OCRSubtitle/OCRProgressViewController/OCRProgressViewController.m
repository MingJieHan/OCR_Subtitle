//
//  OCRProgressViewController.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/3.
//

#import "OCRProgressViewController.h"
#import <HansServer/HansServer.h>
#import "HansBorderLabel.h"
#import "OCRScanningView.h"
@interface OCRProgressViewController (){
    UIImageView *currentImageView;
    UIImageView *resultImageView;
    HansProgressBarView *progressView;
    UILabel *titleLabel;
    NSDate *startDate;
    UILabel *usedTimeLabel;
    UILabel *requiredTimeLabel;
    UILabel *noticeLabel;
    CGRect scanningRect;
    
    OCRScanningView *scanningView;
}
@end

@implementation OCRProgressViewController
@synthesize progress;
@synthesize image;
@synthesize gottedString;
@synthesize gottedStringColor,gottedStringBorderColor,gottedStringBorderWidth;
@synthesize passTopRate,heightRate;

-(void)setGottedString:(NSString *)_gottedString{
    if ([gottedString isEqualToString:_gottedString]){
        return;
    }
    gottedString = _gottedString;
    dispatch_async(dispatch_get_main_queue(), ^{
        HansBorderLabel *gottedStringLabel = [[HansBorderLabel alloc] initWithFrame:self->scanningRect];
        if (nil == self->gottedStringBorderColor){
            gottedStringLabel.borderColor = [UIColor blackColor];
        }else{
            gottedStringLabel.borderColor = self->gottedStringBorderColor;
        }
        if (nil == self->gottedStringColor){
            gottedStringLabel.fontColor = [UIColor whiteColor];
        }else{
            gottedStringLabel.fontColor = self->gottedStringColor;
        }
        gottedStringLabel.borderWidth = self->gottedStringBorderWidth;
        gottedStringLabel.text = self->gottedString;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view addSubview:gottedStringLabel];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.5 delay:0.3f options:UIViewAnimationOptionCurveLinear animations:^{
                gottedStringLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
                [gottedStringLabel setCenter:self->resultImageView.center];
            } completion:^(BOOL finished) {
                [gottedStringLabel removeFromSuperview];
            }];
        }];
        return;
    });
    return;
}

-(void)setProgress:(float)_progress{
    if (progress == _progress){
        return;
    }
    progress = _progress;
    self->progressView.progress = progress;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (nil == self->startDate){
            self->startDate = NSDate.date;
        }
        float second = [NSDate.date timeIntervalSinceDate:self->startDate];
        self->usedTimeLabel.text = [NSString stringWithSecond:second];
        float requiredSecond = second/self->progress - second;
        self->requiredTimeLabel.text = [NSString stringWithSecond:requiredSecond];
    });
    return;
}

-(void)setImage:(CGImageRef)_image{
    if (image == _image){
        return;
    }
    image = _image;
    dispatch_async(dispatch_get_main_queue(), ^{
        self->currentImageView.image = [[UIImage alloc] initWithCGImage:self->image];
        float scaleWidth = self->currentImageView.image.size.width/self->currentImageView.frame.size.width;
        float scaleHeight = self->currentImageView.image.size.height/self->currentImageView.frame.size.height;
        float seekX = 0.f;
        float seekY = 0.f;
        if (scaleHeight < scaleWidth){
            //横版
            seekY = (self->currentImageView.frame.size.height - self->currentImageView.image.size.height / scaleWidth)/2.f;
        }else{
            //竖版
            seekX = (self->currentImageView.frame.size.width - self->currentImageView.image.size.width / scaleHeight)/2.f;
        }
//        NSLog(@"seekX: %.2f", seekX);
//        NSLog(@"seekY: %.2f", seekY);
        CGRect rect = CGRectMake(seekX,
                                 seekY + (self->currentImageView.frame.size.height - 2.f * seekY) * self->passTopRate,
                                 self->currentImageView.frame.size.width - 2.f * seekX,
                                 (self->currentImageView.frame.size.height - 2.f * seekY) * self->heightRate);
        self->scanningRect = [self->currentImageView convertRect:rect toView:self.view];
        [self->scanningView setFrame:self->scanningRect];
    });
    return;
}

-(void)cancelAction{
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
}

-(id)init{
    self = [super init];
    if (self){
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.view.backgroundColor = [UIColor whiteColor];

        currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.f, 10.f, self.view.frame.size.width-20.f, self.view.frame.size.height-20.f)];
        currentImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        currentImageView.layer.masksToBounds = YES;
        currentImageView.layer.cornerRadius = 8.f;
        currentImageView.contentMode = UIViewContentModeScaleAspectFit;
        currentImageView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:currentImageView];
        
        progressView = [[HansProgressBarView alloc] initWithFrame:CGRectMake(10.f, (self.view.frame.size.height-40.f)/2.f, self.view.frame.size.width-20.f, 40.f)];
        progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        progressView.backgroundColor = [UIColor redColor];
        [self.view addSubview:progressView];
        
        noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, self.view.frame.size.height-60.f, self.view.frame.size.width-20.f, 40.f)];
        noticeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        noticeLabel.text = @"OCR video ... Do not close this page or lock the screen.";
        noticeLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:noticeLabel];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 40.f, self.view.frame.size.width-20.f, 40.f)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:24.f];
        titleLabel.text = @"Scanning video and OCR text.";
        titleLabel.textColor = [UIColor blackColor];
        [self.view addSubview:titleLabel];
        
        float y = CGRectGetMaxY(progressView.frame) + 5.f;
        usedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.f, y, 300.f, 20.f)];
        usedTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        usedTimeLabel.textAlignment = NSTextAlignmentLeft;
        usedTimeLabel.text = @"--:--";
        usedTimeLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:usedTimeLabel];
        
        requiredTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-320.f, y, 300.f, 20.f)];
        requiredTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        requiredTimeLabel.textAlignment = NSTextAlignmentRight;
        requiredTimeLabel.text = @"--:--";
        requiredTimeLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:requiredTimeLabel];
        
        resultImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.f, self.view.frame.size.height-50.f, 40.f, 40.f)];
        resultImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
        resultImageView.layer.masksToBounds = YES;
        resultImageView.layer.cornerRadius = 2.f;
        resultImageView.contentMode = UIViewContentModeScaleAspectFit;
        resultImageView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:resultImageView];
        
        scanningView = [[OCRScanningView alloc] init];
        [self.view addSubview:scanningView];
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    startDate = [NSDate date];
    return;
}

@end
