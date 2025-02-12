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


@interface OCRAreaSelectViewController ()<UIScrollViewDelegate>{
    NSURL *videoURL;
    OCRGetImageFromVideo *getImage;
    VNRecognizeTextRequest *request;
    VNImageRequestHandler *imageRequest;
    UIScrollView *scrollV;
    UIImageView *imageView;
    UISlider *progressSelectorView;
    UIButton *currentLanguageButton;
}

@end

@implementation OCRAreaSelectViewController
@synthesize suggestName;
@synthesize videoSize,passTopRate,heightRate;
@synthesize handler;
@synthesize thumbnailImage;
@synthesize scaningLanguageIdentifier;

-(id)initWithVideo:(NSURL *)_videoURL{
    self = [super init];
    if (self){
        videoURL = _videoURL;
        suggestName = [[videoURL lastPathComponent] stringByDeletingPathExtension];
        
        self.modalInPresentation = YES;
        [videoURL startAccessingSecurityScopedResource];
        getImage = [[OCRGetImageFromVideo alloc] initWithVideoURL:videoURL];
        
        request = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull res,
                        NSError * _Nullable error) {
            [self OCRResult:res withError:error];
        }];
        
        scaningLanguageIdentifier = [[NSLocale preferredLanguages] objectAtIndex:0];
        request.recognitionLanguages = @[scaningLanguageIdentifier];

        scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
        scrollV.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        scrollV.delegate = self;
        scrollV.backgroundColor = [UIColor orangeColor];
        [self.view addSubview:scrollV];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [scrollV addSubview:imageView];
        
        
        progressSelectorView = [[UISlider alloc] initWithFrame:CGRectMake(0.f, 180.f, self.view.frame.size.width, 30.f)];
        [progressSelectorView addTarget:self action:@selector(thumbnailChanged:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:progressSelectorView];
        
        NSLog(@"%@", [NSLocale preferredLanguages]);
        //        request.recognitionLanguages = @[@"zh-Hans", @"en-US"];
        //        [OCRGetTextFromImage availableLanguages];
        //        [OCRGetTextFromImage sortedAvailableLanguages].firstObject;
        //        @[@"zh-Hans", @"en-US"];
        currentLanguageButton = [[UIButton alloc] initWithFrame:CGRectMake(10.f, 100.f, 220.f, 60.f)];
        currentLanguageButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12.f];
        [currentLanguageButton setTitle:[OCRGetTextFromImage stringForLanguageCode:scaningLanguageIdentifier] forState:UIControlStateNormal];
        [currentLanguageButton addTarget:self action:@selector(scanLanguageChangeAction) forControlEvents:UIControlEventTouchUpInside];
        currentLanguageButton.layer.borderColor = [UIColor blueColor].CGColor;
        currentLanguageButton.layer.borderWidth = 1.5f;
        [self.view addSubview:currentLanguageButton];

    }
    return self;
}

-(void)scanLanguageChangeAction{
    OCRLanguagesTableViewController *v = [[OCRLanguagesTableViewController alloc] init];
    v.selectedLanguages = [[NSMutableArray alloc] initWithArray:@[scaningLanguageIdentifier]];
    v.saveHandler = ^(OCRLanguagesTableViewController * _Nonnull vc) {
        self->scaningLanguageIdentifier = vc.selectedLanguages.firstObject;
        [self->currentLanguageButton setTitle:[OCRGetTextFromImage stringForLanguageCode:self->scaningLanguageIdentifier] forState:UIControlStateNormal];
        self->request.recognitionLanguages = @[self->scaningLanguageIdentifier];
        [self scanImage];
    };
    [self.navigationController pushViewController:v animated:YES];
    return;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    progressSelectorView.value = 0.1f;
    [self thumbnailChanged:nil];
}

-(void)thumbnailChanged:(id)sender{
    int64_t target = progressSelectorView.value * [getImage durationValue];
    [self getImageWithTime:target];
    return;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
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
        self->imageView.image = self->thumbnailImage;
        self->scrollV.contentSize = self->thumbnailImage.size;
        [self->imageView setFrame:CGRectMake(0.f, 0.f,
                                             self->thumbnailImage.size.width,
                                             self->thumbnailImage.size.height)];
        videoSize = thumbnailImage.size;
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
    
    NSArray <VNRecognizedTextObservation *> *observaters = request.results;
    for (VNRecognizedTextObservation *item in observaters){
        NSArray <VNRecognizedText*> * texts = [item topCandidates:10];
        for (VNRecognizedText *text in texts){
            if (text.string.length < 2){
                continue;
            }
            if (text.confidence < 0.3){
                continue;
            }
            NSLog(@"%@", text.string);
            NSRange range = NSMakeRange(0, text.string.length);
            VNRectangleObservation *observation = [text boundingBoxForRange:range error:&error];
            AreaSelectButton *button = [[AreaSelectButton alloc] initWithRectangleObservation:observation withSize:imageView.image.size];
            [button addTarget:self action:@selector(selectAreaAction:) forControlEvents:UIControlEventTouchUpInside];
            [imageView addSubview:button];
        }
    }
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

-(void)viewWillAppear:(BOOL)animated{
    [videoURL stopAccessingSecurityScopedResource];
    [super viewWillAppear:animated];
}
#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return imageView;
}
@end
