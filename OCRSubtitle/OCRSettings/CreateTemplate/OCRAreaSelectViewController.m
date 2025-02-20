
//
//  OCRAreaSelectViewController.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/10.
//

#import "OCRAreaSelectViewController.h"
#import <Vision/Vision.h>
#import "OCRGetImageFromVideo.h"
#import "OCRGetTextFromImage.h"
#import "OCRLanguagesTableViewController.h"
#import <HansServer/HansServer.h>
#import "OCRTipView.h"

#import "AreaSelectButton.h"
#import "AreaSubtitleTipView.h"



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
        self.title = NSLocalizedString(@"Creating Template", nil);
        self.view.backgroundColor = [UIHans colorFromHEXString:@"EFEEF6"];
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
        scrollV.backgroundColor = self.view.backgroundColor;
        [self.view addSubview:scrollV];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 6.f;
        [scrollV addSubview:imageView];
        
        float leftSpace = 5.f;
        float leftWidth = 130.f;
        y = CGRectGetMaxY(scrollV.frame)+3.f;
        x = 2 * leftSpace + leftWidth;
        languageLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftSpace, y, leftWidth, 30.f)];
        languageLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        languageLabel.textColor = [UIColor blackColor];
        languageLabel.backgroundColor = [UIColor clearColor];
        languageLabel.text = NSLocalizedString(@"Subtitle Language:",nil);
        [self.view addSubview:languageLabel];
        currentLanguageButton = [[UIHansButton alloc] initWithFrame:CGRectMake(x, y, self.view.frame.size.width-x-leftSpace, 30.f)];
        currentLanguageButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
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
        timeLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        timeLabel.textColor = [UIColor blackColor];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.text = NSLocalizedString(@"Thumbnail Time:",nil);
        [self.view addSubview:timeLabel];
        progressSelectorView = [[UISlider alloc] initWithFrame:CGRectMake(x, y, self.view.frame.size.width-x-leftSpace, 30.f)];
        progressSelectorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        [progressSelectorView addTarget:self action:@selector(thumbnailChanged:) forControlEvents:UIControlEventTouchUpInside];
        progressSelectorView.maximumValue = 1.f;
        progressSelectorView.minimumValue = 0.f;
        [self.view addSubview:progressSelectorView];

        y = CGRectGetMaxY(progressSelectorView.frame)+5.f;
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftSpace, y, leftWidth, 30.f)];
        nameLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.text = NSLocalizedString(@"Template Name:",nil);
        [self.view addSubview:nameLabel];
        currentNameButton = [[UIHansButton alloc] initWithFrame:CGRectMake(x, y, self.view.frame.size.width-x-leftSpace, 30.f)];
        currentNameButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
        currentNameButton.enabled = YES;
        currentNameButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12.f];
        [currentNameButton setTitle:suggestName forState:UIControlStateNormal];
        [currentNameButton addTarget:self action:@selector(nameButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [currentNameButton setBackgroundColor:[UIHans green] forState:UIControlStateNormal];
        [currentNameButton setBackgroundColor:[UIHans greenHighlighted] forState:UIControlStateHighlighted];
        currentNameButton.layer.borderColor = [UIColor grayColor].CGColor;
        currentNameButton.layer.borderWidth = 1.f;
        [self.view addSubview:currentNameButton];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            tipView = [[OCRTipView alloc] initWithFrame:CGRectMake(0.f, -100.f, self.view.frame.size.width, 100.f)];
        }else{
            tipView = [[OCRTipView alloc] initWithFrame:CGRectMake(0.f, -130.f, self.view.frame.size.width, 130.f)];
        }
        [self.view addSubview:tipView];
        
        cancelButton = [[UIHansButton alloc] initWithFrame:CGRectMake(5.f, 50.f, 60.f, 40.f)];
        [cancelButton setTitle:NSLocalizedString(@"Cancel",nil) forState:UIControlStateNormal];
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
    [self refreshThumbnailImage];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshThumbnailImage];
        });
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
            [self refreshThumbnailImage];
        });
    }];
}

-(void)refreshThumbnailImage{
    if (thumbnailImage){
        scrollV.maximumZoomScale = 10.f;
        scrollV.minimumZoomScale = 0.5f;
        [scrollV setZoomScale:1.f animated:NO];
        scrollV.backgroundColor = [UIColor clearColor];
        videoSize = thumbnailImage.size;
        
        //改放大系数
        float scaleX = scrollV.frame.size.width/thumbnailImage.size.width;
        float scaleY = scrollV.frame.size.height/thumbnailImage.size.height;
        CGPoint offset = CGPointZero;
        if (scaleY < scaleX){
            //竖版视频
            scrollV.minimumZoomScale = scaleY;
            scrollV.maximumZoomScale = scaleY;
            offset = CGPointMake((thumbnailImage.size.width * scaleY - scrollV.frame.size.width)/2.f, 0.f);
        }else{
            //横向视频
            scrollV.minimumZoomScale = scaleX;
            scrollV.maximumZoomScale = scaleX;
            offset = CGPointMake(0.f, (thumbnailImage.size.height * scaleX - scrollV.frame.size.height)/2.f);
        }
        
        //设置新的缩略图
        imageView.image = thumbnailImage;
        [imageView setFrame:CGRectMake(0.f, 0.f, thumbnailImage.size.width, thumbnailImage.size.height)];
        scrollV.contentSize = thumbnailImage.size;

//        NSLog(@"Offset X=%.2f, Y=%.2f", offset.x, offset.y);
        [scrollV setZoomScale:scrollV.minimumZoomScale animated:NO];
        [scrollV setContentOffset:offset animated:NO];
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
    for (UIView *v in self.view.subviews){
        if ([v isKindOfClass:[AreaSubtitleTipView class]]){
            [v removeFromSuperview];
        }
    }
    for (UIView *v in imageView.subviews){
        if ([v isKindOfClass:[AreaSelectButton class]]){
            [v removeFromSuperview];
        }
    }
    
    numberOfAreaButton = 0;
    includeSubtitleAreaButton = NO;
    NSMutableArray <VNRecognizedText *>*resultsWithRepeated = [[NSMutableArray alloc] init];
    
    for (VNRecognizedTextObservation *item in request.results){
        NSInteger requestAreadNum = 20;
        NSArray <VNRecognizedText*> * texts = [item topCandidates:requestAreadNum];
        for (VNRecognizedText *text in texts){
            if (text.string.length < 2){
                //
                continue;
            }
            if (text.confidence < 0.3){
                //
                continue;
            }
            [resultsWithRepeated addObject:text];
        }
    }
    
    // remove text object with same location
    NSMutableArray <VNRecognizedText *>*resultsNoRepeat = [[NSMutableArray alloc] init];
    NSMutableArray *existPoints = [[NSMutableArray alloc] init];
    [resultsWithRepeated sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        //First sort by confidence
        VNRecognizedText *text1 = obj1;
        VNRecognizedText *text2 = obj2;
        if (text1.confidence > text2.confidence){
            return NSOrderedAscending;
        }
        if (text1.confidence < text2.confidence){
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    
    for (VNRecognizedText *text in resultsWithRepeated){
        error = nil;
        NSRange range = NSMakeRange(0, text.string.length);
        VNRectangleObservation *observation = [text boundingBoxForRange:range error:&error];
        BOOL isExistPoint = NO;
        for (NSValue *v in existPoints){
            CGFloat distance = [self distancePoint:[v CGPointValue] other:observation.topLeft];
            if (distance < 0.005){
                isExistPoint = YES;
                break;
            }
        }
        if (NO == isExistPoint){
            [existPoints addObject:[NSValue valueWithCGPoint:observation.topLeft]];
            [resultsNoRepeat addObject:text];
        }else{
            //topLeft 相同，此识别结果丢弃
        }
    }
    
    //Create Area select buttons.
    for (VNRecognizedText *text in resultsNoRepeat){
        NSRange range = NSMakeRange(0, text.string.length);
        VNRectangleObservation *observation = [text boundingBoxForRange:range error:&error];
        numberOfAreaButton ++;
        
//        NSLog(@"Found:%@ %.6f %.6f %.3f", text.string, observation.topLeft.x, observation.topLeft.y, text.confidence);
        AreaSelectButton *button = [[AreaSelectButton alloc] initWithRectangleObservation:observation
                                                                                 withSize:imageView.image.size
                                                                               withString:text.string];
        [button addTarget:self action:@selector(selectAreaAction:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:button];
        if (button.isSubtitle
            && NO == includeSubtitleAreaButton){//只需要一个Subtitle提示界面
            includeSubtitleAreaButton = YES;
            
            CGPoint fouceCenter = [imageView convertPoint:button.center toView:self.view];
            AreaSubtitleTipView *cc = [[AreaSubtitleTipView alloc] initWithCenter:fouceCenter withScale:scrollV.zoomScale];
            [self.view addSubview:cc];
            [cc animateStart];
        }
    }
    [self animateTipView];
    return;
}

-(CGFloat)distancePoint:(CGPoint)p1 other:(CGPoint)p2{
    CGFloat xDist = (p2.x - p1.x);
    CGFloat yDist = (p2.y - p1.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

-(void)animateTipView{
    NSString *tipTitleString = @"";
    NSString *tipTextString = @"";
    if (includeSubtitleAreaButton){
        tipTitleString = NSLocalizedString(@"Congratulations!", nil);
        tipTextString = NSLocalizedString(@"** Click on the subtitle box below to complete the template creation. **", nil);
    }else{
        if (languageSelected){
            tipTitleString = NSLocalizedString(@"Without Subtitle", nil);
            tipTextString = NSLocalizedString(@"** Drag the timeline below to change the video thumbnail, including subtitles. **", nil);
        }else{
            tipTitleString = NSLocalizedString(@"NOT Found", nil);
            tipTextString = NSLocalizedString(@"** Select the language to recognize subtitles. **", nil);
        }
    }
    [tipView showWithTitle:tipTitleString withText:tipTextString];
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
