//
//  OCRProgressViewController.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/3.
//

#import "OCRProgressViewController.h"
#import <HansServer/HansServer.h>

@interface OCRProgressViewController (){
    UIImageView *currentImageView;
    HansProgressBarView *progressView;
    UILabel *titleLabel;
    NSDate *startDate;
    UILabel *usedTimeLabel;
    UILabel *requiredTimeLabel;
    UILabel *noticeLabel;
}
@end

@implementation OCRProgressViewController
@synthesize progress;
@synthesize image;

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
        int sec = (int)second;
        int minute = sec/60;
        sec = sec%60;
        self->usedTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minute, sec];
        
        float requiredSecond = second/self->progress - second;
        sec = (int)requiredSecond;
        minute = sec/60;
        sec = sec%60;
        self->requiredTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minute, sec];
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
        [self.view addSubview:currentImageView];
        
        progressView = [[HansProgressBarView alloc] initWithFrame:CGRectMake(10.f, (self.view.frame.size.height-40.f)/2.f, self.view.frame.size.width-20.f, 40.f)];
        progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
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
        progressView.backgroundColor = [UIColor redColor];
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
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    startDate = [NSDate date];
    return;
}

@end
