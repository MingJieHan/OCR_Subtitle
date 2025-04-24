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
#import "HansBorderLabel.h"
#import "SCRResultAnimatedLabel.h"

@interface OCRProgressViewController (){
    UIImageView *currentImageView;
    HansProgressBarView *progressView;
    NSTimer *animateControlTimer;
    HansBorderLabel *titleLabel;
    NSDate *startDate;
    UILabel *usedTimeLabel;
    UILabel *requiredTimeLabel;
    HansBorderLabel *noticeLabel;
    CGRect scanningRect;
    
    OCRScanningView *scanningView;
}
@end

@implementation OCRProgressViewController
@synthesize storageImageView;
@synthesize progress;
@synthesize image,imageOrientation;
@synthesize gottedString;
@synthesize gottedStringColor,gottedStringBorderColor,gottedStringBorderWidth;
@synthesize passTopRate,heightRate;

#pragma mark - System
-(id)init{
    self = [super init];
    if (self){
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.view.backgroundColor = [UIColor whiteColor];
        float y = 0.f;

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(60.f, 70.f, self.view.frame.size.width-120.f, self.view.frame.size.height-190.f)];
        }else{
            currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.f, 100.f, self.view.frame.size.width-20.f, self.view.frame.size.height-250.f)];
        }
        currentImageView.backgroundColor= [UIHans colorFromHEXString:@"F5F5F5"];
        currentImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        currentImageView.layer.masksToBounds = YES;
        currentImageView.layer.cornerRadius = 8.f;
        currentImageView.contentMode = UIViewContentModeScaleAspectFit;
        currentImageView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:currentImageView];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            titleLabel = [[HansBorderLabel alloc] initWithFrame:CGRectMake(10.f, 40.f, self.view.frame.size.width-20.f, 40.f)];
        }else{
            titleLabel = [[HansBorderLabel alloc] initWithFrame:CGRectMake(10.f, 80.f, self.view.frame.size.width-20.f, 40.f)];
        }
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24.f];
        titleLabel.text = NSLocalizedString(@"Scanning video and OCR subtitle.", nil);
        titleLabel.fontColor = [UIHans colorFromHEXString:@"FFDE1F"];
        titleLabel.borderColor = [UIHans gray];
        titleLabel.layer.shadowColor = [UIHans gray].CGColor;
        titleLabel.layer.shadowOffset = CGSizeMake(1.f, 2.f);
        titleLabel.layer.shadowRadius = 0.2f;
        titleLabel.layer.shadowOpacity = 0.7f;
        [self.view addSubview:titleLabel];
        
        y = CGRectGetMaxY(currentImageView.frame)+1.f;
        progressView = [[HansProgressBarView alloc] initWithFrame:CGRectMake(10.f, y, self.view.frame.size.width-20.f, 40.f)];
        progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:progressView];
        
        y = CGRectGetMaxY(progressView.frame) + 5.f;
        usedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.f, y, 300.f, 20.f)];
        usedTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        usedTimeLabel.textAlignment = NSTextAlignmentLeft;
        usedTimeLabel.text = @"--:--";
        usedTimeLabel.font = [UIFont fontWithName:@"Menlo" size:18.f];
        usedTimeLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:usedTimeLabel];
        
        requiredTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-320.f, y, 300.f, 20.f)];
        requiredTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        requiredTimeLabel.textAlignment = NSTextAlignmentRight;
        requiredTimeLabel.text = @"--:--";
        requiredTimeLabel.font = usedTimeLabel.font;
        requiredTimeLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:requiredTimeLabel];
        
        y = CGRectGetMaxY(progressView.frame) + 8.f;
        noticeLabel = [[HansBorderLabel alloc] initWithFrame:CGRectMake(10.f, self.view.frame.size.height-60.f, self.view.frame.size.width-20.f, 40.f)];
        noticeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        noticeLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14.f];
        noticeLabel.text = NSLocalizedString(@"Do not close this page or lock the screen.",nil);
        noticeLabel.textAlignment = NSTextAlignmentCenter;
        noticeLabel.fontColor = [UIHans red];
        noticeLabel.borderColor = [UIHans gray];
        [self.view addSubview:noticeLabel];

        scanningView = [[OCRScanningView alloc] init];
        [self.view addSubview:scanningView];

        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            storageImageView = [[SCRStorageImageView alloc] initWithFrame:CGRectMake(30.f, 80.f, 120.f, 120.f)];
        }else{
            storageImageView = [[SCRStorageImageView alloc] initWithFrame:CGRectMake(30.f, 80.f, 100.f, 100.f)];
        }
        storageImageView.autoresizingMask = UIViewAutoresizingNone;
        storageImageView.layer.masksToBounds = YES;
        storageImageView.layer.cornerRadius = 5.f;
        storageImageView.contentMode = UIViewContentModeScaleAspectFit;
        storageImageView.backgroundColor = [UIHans colorFromHEXString:@"E5E5E5"];
        storageImageView.userInteractionEnabled = YES;
        storageImageView.image = [[UIImage alloc] initWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"storage" ofType:@"png"]];
        [self.view addSubview:storageImageView];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        [storageImageView addGestureRecognizer:pan];
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated{
    [animateControlTimer invalidate];
    animateControlTimer = nil;
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    startDate = [NSDate date];
    animateControlTimer = [NSTimer scheduledTimerWithTimeInterval:2.6f repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self animating];
    }];
    [animateControlTimer fire];
    return;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    BOOL needMove = NO;
    CGPoint targetCenter = storageImageView.center;
    if (targetCenter.x > self.view.frame.size.width - storageImageView.frame.size.width/2.f){
        needMove = YES;
        targetCenter.x  = self.view.frame.size.width - storageImageView.frame.size.width/2.f;
    }
    if (targetCenter.y > self.view.frame.size.height - storageImageView.frame.size.height/2.f){
        needMove = YES;
        targetCenter.y = self.view.frame.size.height - storageImageView.frame.size.height/2.f;
    }
    if (needMove){
        [UIView animateWithDuration:0.2 animations:^{
            [self->storageImageView setCenter:targetCenter];
        }];
    }
    return;
}

#pragma mark -My
-(void)setGottedString:(NSString *)_gottedString{
    if ([gottedString isEqualToString:_gottedString]){
        return;
    }
    gottedString = _gottedString;
    dispatch_async(dispatch_get_main_queue(), ^{
        SCRResultAnimatedLabel *gottedStringLabel = [[SCRResultAnimatedLabel alloc] initWithFrame:self->scanningRect];
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
        gottedStringLabel.completedHandler = ^(SCRResultAnimatedLabel * _Nonnull label) {
            [self->storageImageView receivedAnimate];
        };
        [self.view addSubview:gottedStringLabel];
        [gottedStringLabel startAnimateWithTargetCenter:self->storageImageView.center];
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
        self->currentImageView.image = [[UIImage alloc] initWithCGImage:self->image scale:1.f orientation:self->imageOrientation];
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

-(void)panGestureRecognizer:(UIPanGestureRecognizer *)recognizer{
    CGPoint translation = [recognizer translationInView:storageImageView.superview];
    CGPoint targetCenter = CGPointMake(recognizer.view.center.x + translation.x,
                                     recognizer.view.center.y + translation.y);
    if (targetCenter.x < storageImageView.frame.size.width/2.f){
        targetCenter.x = storageImageView.frame.size.width/2.f;
    }
    if (targetCenter.x > self.view.frame.size.width-storageImageView.frame.size.width/2.f){
        targetCenter.x = self.view.frame.size.width-storageImageView.frame.size.width/2.f;
    }
    if (targetCenter.y < storageImageView.frame.size.height/2.f){
        targetCenter.y = storageImageView.frame.size.height/2.f;
    }
    if (targetCenter.y > self.view.frame.size.height - storageImageView.frame.size.height/2.f){
        targetCenter.y = self.view.frame.size.height-storageImageView.frame.size.height/2.f;
    }
    storageImageView.center = targetCenter;
    for (UIView * v in self.view.subviews){
        if ([v isKindOfClass:[SCRResultAnimatedLabel class]]){
            SCRResultAnimatedLabel *label = (SCRResultAnimatedLabel *)v;
            label.targetCenter = storageImageView.center;
        }
    }
    [recognizer setTranslation:CGPointMake(0.f, 0.f) inView:storageImageView.superview];
    return;
}

-(void)animating{
    [UIView animateWithDuration:1.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self->titleLabel.fontColor = [UIHans red];
        self->titleLabel.transform = CGAffineTransformMakeScale(1.5, 1.5);
        self->noticeLabel.fontColor = [UIHans redHighlighted];
        self->noticeLabel.transform = CGAffineTransformMakeScale(1.5, 1.5);
    } completion:^(BOOL finished) {
    }];
    [NSTimer scheduledTimerWithTimeInterval:1.3f repeats:NO block:^(NSTimer * _Nonnull timer) {
        [UIView animateWithDuration:1.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
            self->titleLabel.fontColor = [UIHans colorFromHEXString:@"FFDE1F"];
            self->titleLabel.transform = CGAffineTransformMakeScale(1.f, 1.f);
            self->noticeLabel.fontColor = [UIHans red];
            self->noticeLabel.transform = CGAffineTransformMakeScale(1.f, 1.f);
        } completion:^(BOOL finished) {
                
        }];
    }];
}

@end
