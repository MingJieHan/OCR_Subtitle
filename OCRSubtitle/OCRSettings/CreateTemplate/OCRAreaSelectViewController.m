
//
//  OCRAreaSelectViewController.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/10.
//

#import "OCRAreaSelectViewController.h"
#import <Vision/Vision.h>
#import "OCRGetImageFromVideo.h"
#import "AreaSelectButton.h"
#import "OCRGetTextFromImage.h"
#import "OCRLanguagesTableViewController.h"
#import <HansServer/HansServer.h>
#import "OCRTipView.h"

@interface OCRAreaSelectViewController ()<UIScrollViewDelegate>{
    NSURL *videoURL;
    UIHansButton *cancelButton;
    OCRGetImageFromVideo *getImage;
    VNRecognizeTextRequest *request;
    VNImageRequestHandler *imageRequest;
    UIScrollView *scrollV;
    UIImageView *imageView;
    UILabel *timeLabel;
    UISlider *progressSelectorView;
    BOOL sliderTouched;     //调整过缩略图位置
    BOOL languageSelected;  //OCR语言设置过了
    NSInteger numberOfAreaButton;     //区域按钮数量
    BOOL includeSubtitleAreaButton;   //按钮中是否包含正确的Subtitle按钮
    UILabel *languageLabel;
    UIHansButton *currentLanguageButton;
    UILabel *nameLabel;
    UIHansButton *currentNameButton;
    OCRTipView *tipView;
}

@end

@implementation OCRAreaSelectViewController
@synthesize suggestName;
@synthesize videoSize,passTopRate,heightRate;
@synthesize handler;
@synthesize thumbnailImage;
@synthesize scaningLanguageIdentifier;


#pragma mark - System
-(id)initWithVideo:(NSURL *)_videoURL{
    self = [super init];
    if (self){
        videoURL = _videoURL;
        self.title = @"Creating Template";
        self.view.backgroundColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
        
        float x = 0.f;
        float y = 0.f;
        suggestName = [[videoURL lastPathComponent] stringByDeletingPathExtension];
        if (suggestName.length > 20){
            suggestName = [suggestName substringToIndex:20];
        }
        
        self.modalInPresentation = YES;
        [videoURL startAccessingSecurityScopedResource];
        getImage = [[OCRGetImageFromVideo alloc] initWithVideoURL:videoURL];
        
        request = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull res,
                        NSError * _Nullable error) {
            [self OCRResult:res withError:error];
        }];
        
        scaningLanguageIdentifier = [OCRGetTextFromImage systemSupportedRecognitionLanguage];
        request.recognitionLanguages = @[scaningLanguageIdentifier];
        
        scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height-190.f)];
        scrollV.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        scrollV.delegate = self;
        scrollV.minimumZoomScale = 0.5;
        scrollV.maximumZoomScale = 5.f;
        scrollV.backgroundColor = [UIHans colorFromHEXString:@"EFEEF6"];
        [self.view addSubview:scrollV];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 6.f;
        [scrollV addSubview:imageView];
        
        float leftSpace = 5.f;
        float leftWidth = 130.f;
        y = CGRectGetMaxY(scrollV.frame);
        x = 2 * leftSpace + leftWidth;
        languageLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftSpace, y, leftWidth, 30.f)];
        languageLabel.textColor = [UIColor blackColor];
        languageLabel.backgroundColor = [UIColor clearColor];
        languageLabel.text = @"Scan Language:";
        [self.view addSubview:languageLabel];
        currentLanguageButton = [[UIHansButton alloc] initWithFrame:CGRectMake(x, y, self.view.frame.size.width-x-leftSpace, 30.f)];
        currentLanguageButton.enabled = YES;
        currentLanguageButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12.f];
        [currentLanguageButton setTitle:[OCRGetTextFromImage stringForLanguageCode:scaningLanguageIdentifier] forState:UIControlStateNormal];
        [currentLanguageButton addTarget:self action:@selector(scanLanguageChangeAction) forControlEvents:UIControlEventTouchUpInside];
        [currentLanguageButton setBackgroundColor:[UIHans blue] forState:UIControlStateNormal];
        [currentLanguageButton setBackgroundColor:[UIHans blueHighlighted] forState:UIControlStateHighlighted];
        currentLanguageButton.layer.borderColor = [UIColor grayColor].CGColor;
        currentLanguageButton.layer.borderWidth = 1.f;
        [self.view addSubview:currentLanguageButton];
        
        y = CGRectGetMaxY(currentLanguageButton.frame)+5.f;
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftSpace, y, leftWidth, 30.f)];
        timeLabel.textColor = [UIColor blackColor];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.text = @"Time:";
        [self.view addSubview:timeLabel];
        progressSelectorView = [[UISlider alloc] initWithFrame:CGRectMake(x, y, self.view.frame.size.width-x-leftSpace, 30.f)];
        [progressSelectorView addTarget:self action:@selector(thumbnailChanged:) forControlEvents:UIControlEventTouchUpInside];
        progressSelectorView.maximumValue = 1.f;
        progressSelectorView.minimumValue = 0.f;
        [self.view addSubview:progressSelectorView];

        y = CGRectGetMaxY(progressSelectorView.frame)+5.f;
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftSpace, y, leftWidth, 30.f)];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.text = @"Template Name:";
        [self.view addSubview:nameLabel];
        currentNameButton = [[UIHansButton alloc] initWithFrame:CGRectMake(x, y, self.view.frame.size.width-x-leftSpace, 30.f)];
        currentNameButton.enabled = YES;
        currentNameButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12.f];
        [currentNameButton setTitle:suggestName forState:UIControlStateNormal];
        [currentNameButton addTarget:self action:@selector(nameButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [currentNameButton setBackgroundColor:[UIHans green] forState:UIControlStateNormal];
        [currentNameButton setBackgroundColor:[UIHans greenHighlighted] forState:UIControlStateHighlighted];
        currentNameButton.layer.borderColor = [UIColor grayColor].CGColor;
        currentNameButton.layer.borderWidth = 1.f;
        [self.view addSubview:currentNameButton];
        
        tipView = [[OCRTipView alloc] initWithFrame:CGRectMake(0.f, -120.f, self.view.frame.size.width, 120.f)];
        [self.view addSubview:tipView];
        
        cancelButton = [[UIHansButton alloc] initWithFrame:CGRectMake(5.f, 50.f, 60.f, 40.f)];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setBackgroundColor:[UIColor orangeColor] forState:UIControlStateNormal];
        cancelButton.enabled = YES;
        [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cancelButton];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    sliderTouched = NO;
    languageSelected = NO;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (nil == imageView.image){
        progressSelectorView.value = 0.1f;
        [self thumbnailChanged:nil];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [videoURL stopAccessingSecurityScopedResource];
    [super viewWillDisappear:animated];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    UIEdgeInsets edg = self.view.safeAreaInsets;
    [scrollV setFrame:CGRectMake(edg.left, edg.top, self.view.frame.size.width-edg.left-edg.right, self.view.frame.size.height-edg.top-edg.bottom-190.f)];
    return;
}

#pragma mark - MyFunctions
-(void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)scanLanguageChangeAction{
    OCRLanguagesTableViewController *v = [[OCRLanguagesTableViewController alloc] init];
    v.selectedLanguages = [[NSMutableArray alloc] initWithArray:@[scaningLanguageIdentifier]];
    v.oneLanguageOnly = YES;
    v.saveHandler = ^(OCRLanguagesTableViewController * _Nonnull vc) {
        self->languageSelected = YES;
        self->scaningLanguageIdentifier = vc.selectedLanguages.firstObject;
        [self->currentLanguageButton setTitle:[OCRGetTextFromImage stringForLanguageCode:self->scaningLanguageIdentifier] forState:UIControlStateNormal];
        self->request.recognitionLanguages = @[self->scaningLanguageIdentifier];
        [self scanImage];
    };
    [self.navigationController pushViewController:v animated:YES];
    return;
}

-(void)nameButtonAction{
    HansLineStringEditViewController *v = [[HansLineStringEditViewController alloc] init];
    v.title = @"Template Name";
    v.defaultValue = suggestName;
    v.handler = ^(BOOL changed, NSString * _Nullable value) {
        self->suggestName = value;
        [self->currentNameButton setTitle:self->suggestName forState:UIControlStateNormal];
        self.navigationController.navigationBarHidden = YES;
        [self.navigationController popViewControllerAnimated:YES];
    };
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:v animated:YES];
    return;
}

-(void)thumbnailChanged:(id)sender{
    if (sender == progressSelectorView){
        sliderTouched = YES;
        [tipView hiddenTip];
    }
    int64_t target = progressSelectorView.value * [getImage durationValue];
    [self getImageWithTime:target];
    return;
}

-(void)getImageWithTime:(int64_t)t{
    [getImage getImageWithValue:t withHandler:^(CGImageRef _Nonnull imageRef) {
        self->thumbnailImage = [[UIImage alloc] initWithCGImage:imageRef];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scanImage];
        });
    }];
}

-(void)scanImage{
    if (thumbnailImage){
        videoSize = thumbnailImage.size;
        
        //改放大系数
        float scaleX = scrollV.frame.size.width/thumbnailImage.size.width;
        float scaleY = scrollV.frame.size.height/thumbnailImage.size.height;
        scrollV.minimumZoomScale = scaleX;
        CGPoint offset = CGPointMake(0.f, (thumbnailImage.size.height * scaleX - scrollV.frame.size.height)/2.f);
        if (scaleY < scaleX){
            scrollV.minimumZoomScale = scaleY;
            offset = CGPointMake((thumbnailImage.size.width * scaleY - scrollV.frame.size.width)/2.f, 0.f);
        }
        [scrollV setZoomScale:scrollV.minimumZoomScale animated:YES];
        [scrollV setContentOffset:offset animated:YES];
        
        //设置新的缩略图
        imageView.image = thumbnailImage;
        CGRect rect = CGRectMake(0.f, 0.f,
                                 self->thumbnailImage.size.width * scrollV.zoomScale,
                                 self->thumbnailImage.size.height * scrollV.zoomScale);
        scrollV.contentSize = rect.size;
        [imageView setFrame:rect];
    }else{
        imageView.image = nil;
        return;
    }

    NSMutableDictionary *opt = [[NSMutableDictionary alloc] init];
    imageRequest = [[VNImageRequestHandler alloc] initWithCGImage:thumbnailImage.CGImage options:opt];
    
    NSError *error = nil;
    BOOL success = [imageRequest performRequests:@[request] error:&error];
    if (NO == success){
        NSLog(@"Debug imageRequest failed.");
    }
    if (error){
        NSLog(@"Debug performRequests Error:%@", error.localizedDescription);
    }
}

-(void)OCRResult:(VNRequest * _Nonnull)request withError:(NSError * _Nullable)error{
    if (error){
        NSLog(@"VNRequest CompletionHandler with Error:%@", error.localizedDescription);
    }
    for (UIView *v in imageView.subviews){
        if ([v isKindOfClass:[AreaSelectButton class]]){
            [v removeFromSuperview];
        }
    }
    
    numberOfAreaButton = 0;
    includeSubtitleAreaButton = NO;
    
    NSArray <VNRecognizedTextObservation *> *observaters = request.results;
    for (VNRecognizedTextObservation *item in observaters){
        NSInteger requestAreadNum = 10;
        NSArray <VNRecognizedText*> * texts = [item topCandidates:requestAreadNum];
        if (requestAreadNum == texts.count){
            //返回数量，与请求识别数量相同时，大概率是因为识别的语言错误
            continue;
        }
        for (VNRecognizedText *text in texts){
            if (text.string.length < 2){
                continue;
            }
            if (text.confidence < 0.3){
                continue;
            }
            numberOfAreaButton ++;
            NSRange range = NSMakeRange(0, text.string.length);
            VNRectangleObservation *observation = [text boundingBoxForRange:range error:&error];
            AreaSelectButton *button = [[AreaSelectButton alloc] initWithRectangleObservation:observation
                                                                                     withSize:imageView.image.size
                                                                                   withString:text.string];
            [button addTarget:self action:@selector(selectAreaAction:) forControlEvents:UIControlEventTouchUpInside];
            [imageView addSubview:button];
            if (button.isSubtitle){
                includeSubtitleAreaButton = YES;
            }
        }
    }
    [self animateTipView];
    return;
}

-(void)animateTipView{
    NSLog(@"%ld 区域按钮", numberOfAreaButton);
    /*
     1. 无 AreaButton 0 == numberOfAreaButton 即没有任何文字被识别到， 提示 “选择识别的语言，拖动到有字幕的视频位置”
        1.1 sliderTouched  无需提示视频位置
        1.2 languageSelected 无需语言选择
     2. includeSubtitleAreaButton is True 提示 "点击缩略图中的字幕按钮，即可完成Template"
     */
    NSString *tipString = nil;
    if (includeSubtitleAreaButton){
        tipString = @" ** 点击缩略图中的字幕框, 完成模版创建 ** ";
    }else{
        if (0 == numberOfAreaButton){
            tipString = @" ** 选择缩略图中字幕的识别语言 ** ";
        }else{
            if (includeSubtitleAreaButton){
                tipString = @" ** 点击缩略图中的字幕框, 完成模版创建 ** ";
            }else{
                tipString = @" ** 然后拖动时间条改变缩略图内容，缩略图中要包括字幕 ** ";
            }
        }
    }
    [tipView showWithString:tipString];
    return;
}

-(void)selectAreaAction:(id)sender{
    if (![sender isKindOfClass:[AreaSelectButton class]]){
        return;
    }
    AreaSelectButton *button = (AreaSelectButton *)sender;
    passTopRate = [button passTopRate];
    heightRate = [button heightRate];
    [self dismissViewControllerAnimated:YES completion:^{
        if (self->handler){
            self->handler(self);
        }
    }];
    return;
}


#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return imageView;
}
@end
