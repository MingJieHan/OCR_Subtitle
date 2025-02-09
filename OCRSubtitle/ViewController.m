//
//  ViewController.m
//  LoadText
//
//  Created by jia yu on 2024/10/25.
//

#import "ViewController.h"
#import <Vision/Vision.h>
#import "OCRManageSegment.h"
#import <HansServer/HansServer.h>
#import "OCRGetImageFromVideo.h"
#import "OCRGetTextFromImage.h"
#import "OCRImagePreprocessing.h"
#import "OCRGetSampleBuffersFromVideo.h"
#import "OCRSetting.h"
#import "OCRProgressViewController.h"
#import "OCRTemplateCollectionView.h"
#import "OCRHistoryCollectionView.h"
#import "OCRSubtitleManage.h"

#define MAXIMUM_THREAD 4    //How many thread for get Text from image.

@interface ViewController ()<UIDocumentPickerDelegate,UIDocumentBrowserViewControllerDelegate>{
    UIHansButton *debugButton;
    NSDate *startDate;
    NSURL *videoURL;
    OCRProgressViewController *progressVC;
    
    
    NSMutableArray <NSNumber *>*debugGetImagesFromVideo;  //从视频中提取图片， 值是 提取图片的时间值,单位ms
    NSMutableArray <NSThread *> *threads;
    
    OCRGetSampleBuffersFromVideo *bufferFromVideo;
    NSMutableArray <OCRImagePreprocessing *>*imagePre;   ///图片预处理
    NSMutableArray <OCRGetTextFromImage *>*textFromImage;   //图片提取文字
    
    BOOL loadVideoCompleted;
    VNFeaturePrintObservation *lastObservation;
    OCRSetting *setting;
    
    OCRTemplateCollectionView *templateView;
    OCRHistoryCollectionView *historyView;
    UILabel *verLabel;
    UIImage *thumbnailCGImage;
}

@end

@implementation ViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"Home:%@", NSHomeDirectory());
    progressVC = [[OCRProgressViewController alloc] init];
    
    debugButton = [[UIHansButton alloc] initWithFrame:CGRectMake( 0.f,self.view.frame.size.height-50.f, 200.f, 50.f)];
    debugButton.enabled = YES;
    debugButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin;
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"files" ofType:@"png"]];
    [debugButton setImage:image forState:UIControlStateNormal];
    [debugButton setTitle:NSLocalizedString(@"Debug", nil)
                      forState:UIControlStateNormal];
    [debugButton addTarget:self action:@selector(debugAction) forControlEvents:UIControlEventTouchUpInside];
    [debugButton setBackgroundColor:[UIHans blue] forState:UIControlStateNormal];
    [debugButton setBackgroundColor:[UIHans blueHighlighted] forState:UIControlStateHighlighted];
    [self.view addSubview:debugButton];
    
    ViewController * __strong strongSelf = self;
    float y = 400.f;
    templateView = [[OCRTemplateCollectionView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, y)];
    templateView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    templateView.openHandler = ^(OCRSetting * _Nonnull selectedSetting) {
        self->setting = selectedSetting;
        [strongSelf selectFileAction];
    };
    templateView.editHandler = ^(OCRSetting * _Nonnull selectedSetting) {
        [strongSelf editSetting:selectedSetting];
    };
    [self.view addSubview:templateView];
    
    y += 10.f;
    historyView = [[OCRHistoryCollectionView alloc] initWithFrame:CGRectMake(0.f, y, self.view.frame.size.width, self.view.frame.size.height-y-40.f)];
    historyView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    historyView.shareHandler = ^(OCRHistory * _Nonnull history) {
        [strongSelf moreActionWith:history];
    };
    historyView.openHandler = ^(OCRHistory * _Nonnull history) {
        [strongSelf openFile:history.file];
    };
    [self.view addSubview:historyView];
    
    
    verLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, self.view.frame.size.height-40.f, self.view.frame.size.width, 30.f)];
    verLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    verLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:12.f];
    verLabel.textAlignment = NSTextAlignmentCenter;
    verLabel.text = [NSString stringWithFormat:@"OCR Subtitle ver:%@ buile:%@", UIHans.appVersion, UIHans.appBuildVersion];
    [self.view addSubview:verLabel];
    
    y = CGRectGetMaxY(debugButton.frame)+20.f;
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10.f, y, self.view.frame.size.width-20.f, self.view.frame.size.height-y-40.f)];
    l.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    l.numberOfLines = 10;
    l.text = @"字幕文字颜色纯白、黑色边框不少于 “60”， 字体大小不可变、字幕居中、所在上下位置不动、不可用渐入渐出特效。";
//    [self.view addSubview:l];

    NSArray *languages = [OCRGetTextFromImage sortedAvailableLanguages];
    for (NSString *descriptString in languages){
        NSLog(@"%@", descriptString);
    }
}

-(void)openFile:(NSString *)file{
    NSURL *url = [NSURL fileURLWithPath:file];
    UIDocumentInteractionController *c = [UIDocumentInteractionController interactionControllerWithURL:url];
    c.delegate = UIHans.defaultUIHans;
    BOOL opend = [c presentPreviewAnimated:YES];
    return;
}

-(void)moreActionWith:(OCRHistory *)anHistory{
    [historyView removeObject:anHistory];
    return;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
//    [self debugGetImagesFromVideo];

//    [self debugPreprocessingImage];
    
//    [self debugGetTextFromImage];

//    [OCRManageSegment.shared loadSegments];
//    [self makeSRT];

//    Vladlen Koltun

//    [self debugForMoreThread];
    
//    UIHansAboutViewController *v = [[UIHansAboutViewController alloc] init];
//    v.handler = ^(NSURL * _Nonnull url) {
//        
//    };
//    [UIHans.currentVC presentViewController:v animated:YES completion:nil];    
}

-(void)selectFileAction{
    UIDocumentPickerViewController *picker = nil;
    NSArray *types = @[@"mp4", @"mov"];
    NSMutableArray *utTypes = [[NSMutableArray alloc] init];
    for (NSString *tString in types){
        UTType *type = [UTType typeWithTag:tString tagClass:UTTagClassFilenameExtension conformingToType:nil];
        [utTypes addObject:type];
    }
    types = utTypes;
    if (@available(macCatalyst 14, *)) {
        UIDocumentBrowserViewController *b = [[UIDocumentBrowserViewController alloc] initForOpeningContentTypes:types];
        b.allowsPickingMultipleItems = NO;
        b.allowsDocumentCreation = NO;
        b.delegate = self;
        [UIHans.currentVC presentViewController:b animated:YES completion:nil];
        return;
    }else{
        picker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:types];
    }
    
    picker.allowsMultipleSelection = NO;
    picker.delegate = self;
    [UIHans.currentVC presentViewController:picker animated:YES completion:nil];
    return;
}

-(void)editSetting:(OCRSetting *)editSetting{
    return;
}

-(void)pickupURLs:(NSArray <NSURL *>*)urls{
    videoURL = urls.firstObject;
    [self presentViewController:progressVC animated:NO completion:^{
        self->progressVC.gottedStringBorderColor = self->setting.borderColor;
        self->progressVC.gottedStringBorderWidth = 3.f;
        self->progressVC.passTopRate = self->setting.passTopRate;
        self->progressVC.heightRate = self->setting.heightRate;
        [self startWork];
    }];
    return;
}

-(void)OCRSampleInThread:(SampleObject *)sample threadNum:(int)threadIndex{
    CGImageRef sourceCGImage = [sample createCGImage];
    CGImageRef predImage = [[imagePre objectAtIndex:threadIndex] createSpreadCGImageFrom:sourceCGImage
                                        textColor:setting.textColor
                                    textTolerances:0.1f
                                        boardColor:setting.borderColor
                                    boardTolerances:0.2f];
    CGImageRef subtitleSourceImage = [[imagePre objectAtIndex:threadIndex] createRegionOfInterestImageFromFullImage:sourceCGImage];
    if (nil == subtitleSourceImage){
        NSLog(@"Stop debug.");
        return;
    }
    CGImageRef subtitleImage = [[imagePre objectAtIndex:threadIndex] createRegionOfInterestImageFromFullImage:predImage];
    if (nil == subtitleImage){
        NSLog(@"Stop debug.");
        return;
    }
//    VNFeaturePrintObservation *obs = [[imagePre objectAtIndex:threadIndex] observationWithCGImage:subtitleImage];
//    if (nil == lastObservation){
//        lastObservation = obs;
//    }else{
//        float distance = 1.f;
//        NSError *error = nil;
//        BOOL success = [lastObservation computeDistance:&distance toFeaturePrintObservation:obs error:&error];
//        if (distance > 0.35){
//            NSLog(@"与前不同 :%.5f", distance);
//        }else{
//            NSLog(@"与前相同 :%.5f", distance);
//        }
//        lastObservation = obs;
//    }
    
// 重载入测试开始
//    UIImage *i = [[UIImage alloc] initWithCGImage:subtitleSourceImage];
//    NSString *file = [[NSString alloc] initWithFormat:@"%@/Documents/Buffer_%d.png", NSHomeDirectory(),threadIndex];
//    [NSFileManager.defaultManager removeItemAtPath:file error:nil];
//    [UIImagePNGRepresentation(i) writeToFile:file atomically:YES];
//    UIImage *readed = [[UIImage alloc] initWithContentsOfFile:file];
//重载入测试结束
    progressVC.image = sourceCGImage;
    
    [[textFromImage objectAtIndex:threadIndex] OCRImage:predImage
                                          withImageTime:[sample imageTime]
                                                handler:^(NSArray<OCRSegment *> * _Nonnull results) {
        for (OCRSegment *seg in results){
            if (seg.confidence <= 0.4f){
                NSLog(@"信心不足 %.2f, 丢弃:%@",seg.confidence, seg.string);
                continue;
            }
            float err = fabsf([seg centerOffset]);
            if (err >= 0.02f){
                //此种处理方法，基于字幕文字在视频左右居中的假设。
                NSLog(@"文字不在正中间，丢弃: %@", seg.string);
                continue;
            }
            NSLog(@"%.2f sec:%@", seg.t, seg.string);
            self->progressVC.gottedString = seg.string;
//            NSString *debugString = @"职亚个人不缴纳工伤保险费";
//            if ([seg.string isEqualToString:debugString]){
//                [self saveCGImage:cgImage withName:[NSString stringWithFormat:@"%.2f_source_%@", seg.t, seg.string]];
//                [self saveCGImage:predImage withName:[NSString stringWithFormat:@"%.2f_pred_%@", seg.t, seg.string]];
//                NSLog(@"Debug text");
//            }
            self->thumbnailCGImage = [[UIImage alloc] initWithCGImage:sourceCGImage];
            [OCRManageSegment.shared add:seg withSubtitleImage:subtitleImage withSource:subtitleSourceImage];
        }
        float progress = [sample imageTime]/(self->bufferFromVideo.duration.value/self->bufferFromVideo.duration.timescale);
        self->progressVC.progress = progress;
    }];
    CGImageRelease(subtitleImage);
    CGImageRelease(subtitleSourceImage);
    CGImageRelease(sourceCGImage);
    CGImageRelease(predImage);
}

-(void)saveCGImage:(CGImageRef)cgImage withName:(NSString *)name{
    UIImage *i = [[UIImage alloc] initWithCGImage:cgImage];
    NSString *file = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@.png", name];
    [NSFileManager.defaultManager removeItemAtPath:file error:nil];
    [UIImagePNGRepresentation(i) writeToFile:file atomically:YES];
    return;
}

-(void)OCRTextThread:(NSNumber *)threadNum{
    int num = [threadNum intValue];
    NSLog(@"Thread %d start.", num);
    while (YES) {
        SampleObject *sample = [OCRManageSegment.shared getWaitingSample];
        if (nil == sample){
            if (loadVideoCompleted){
                return;
            }
            [NSThread sleepForTimeInterval:0.1];
        }else{
            [self OCRSampleInThread:sample threadNum:num];
        }
    }
}

-(void)getVideoThread{
    loadVideoCompleted = NO;
    float lastSecond = -1.f;
    while (NO == loadVideoCompleted) {
        if (self->bufferFromVideo.ready){
            CMSampleBufferRef sampleBuffer = [self->bufferFromVideo copyNextBuffer];
            if (nil == sampleBuffer){
                loadVideoCompleted = YES;
                break;
            }
            
            CMTime t = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            float theSecond = (float)t.value/(float)t.timescale;
            
            if (theSecond - lastSecond < [setting minimumFrameSpacing]){
                CFRelease(sampleBuffer);
                sampleBuffer = nil;
                continue;
            }
            lastSecond = theSecond;
            
            [OCRManageSegment.shared appendSample:sampleBuffer];
            while ([OCRManageSegment.shared numOfCurrentSamples] > 20) {
                [NSThread sleepForTimeInterval:0.1];
            }
        }else{
            [NSThread sleepForTimeInterval:0.000001];
        }
    }
    NSTimeInterval t = [NSDate.date timeIntervalSinceDate:self->startDate];
    NSLog(@"Load images completed and usage: %.2f sec.", t);
    return;
}

-(void)exceptStopWithErrorString:(NSString *)string{
    [progressVC dismissViewControllerAnimated:YES completion:^{
        [self->videoURL stopAccessingSecurityScopedResource];
        [UIApplication.sharedApplication setIdleTimerDisabled:NO];
        [UIHans alertTitle:@"Error" withMessage:string];
    }];
    return;
}

-(void)startWork{
    [UIApplication.sharedApplication setIdleTimerDisabled:YES];
    
    [OCRManageSegment.shared clear];
    [videoURL startAccessingSecurityScopedResource];
    NSLog(@"start load images.");
    
    startDate = NSDate.date;
    bufferFromVideo = [[OCRGetSampleBuffersFromVideo alloc] initWithVideoURL:videoURL];
    if (bufferFromVideo.videoSize.width != setting.videoWidth || bufferFromVideo.videoSize.height != setting.videoHeight){
        //Warning for different size with setting.
        float vRate = bufferFromVideo.videoSize.width/bufferFromVideo.videoSize.height;
        float sRate = (float)setting.videoWidth/(float)setting.videoHeight;
        NSString *errorString = nil;
        if (vRate == sRate){
            //视频宽高比例相同
        }else{
            //视频宽高比例不同
        }
        errorString = [NSString stringWithFormat:@"Template size is %ld x %ld, but video size is %.0f x %.0f", setting.videoWidth, setting.videoHeight, bufferFromVideo.videoSize.width, bufferFromVideo.videoSize.height];
        [self exceptStopWithErrorString:errorString];
        return;
    }
    
    if (textFromImage){
        [textFromImage removeAllObjects];
    }else{
        textFromImage = [[NSMutableArray alloc] init];
    }
    if (imagePre){
        [imagePre removeAllObjects];
    }else{
        imagePre = [[NSMutableArray alloc] init];
    }
    for (int i=0;i<MAXIMUM_THREAD;i++){
        OCRGetTextFromImage *o = [[OCRGetTextFromImage alloc] initWithLanguage:setting.subtitleLanguages
                                                         withMinimumTextHeight:setting.heightRate
                                                          withRegionOfInterest:[setting regionOfInterest]];
        [textFromImage addObject:o];
        
        OCRImagePreprocessing *imagePreObject = [[OCRImagePreprocessing alloc] initWithRegionOfInterest:[setting regionOfInterest]];
        [imagePre addObject:imagePreObject];
    }
    
    [NSThread detachNewThreadWithBlock:^{
        [self getVideoThread];
    }];
    threads = [[NSMutableArray alloc] init];
    for (int i=0;i<MAXIMUM_THREAD;i++){
        NSThread *a = [[NSThread alloc] initWithTarget:self selector:@selector(OCRTextThread:) object:[NSNumber numberWithInt:i]];
        [a start];
        [threads addObject:a];
    }
    
    [NSThread detachNewThreadWithBlock:^{
        //checking for completed.
        BOOL wait = YES;
        while (wait) {
            [NSThread sleepForTimeInterval:0.2];
            wait = NO;
            for (NSThread *a in self->threads){
                if (NO == [a isFinished]){
                    wait = YES;
                    break;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self completedInMainThread];
        });
    }];
    return;
}

-(void)completedInMainThread{
    [UIApplication.sharedApplication setIdleTimerDisabled:NO];
    [videoURL stopAccessingSecurityScopedResource];
    
    [progressVC dismissViewControllerAnimated:YES completion:^{
        [OCRManageSegment.shared saveSegments];
        [self makeSRT];
    }];
    return;
}

-(void)debugAction{
    OCRHistory *item = [OCRSubtitleManage.shared createOCRResult];
    item.file = @"test";
    item.videoFileName = @"name";
    item.srtInfo = @"info";
    item.completedDate = NSDate.date;
    item.usageSeconds = [NSDate.date timeIntervalSinceDate:startDate];
    item.thumbnailImageData = nil;
    item.sampleRate = 10;
    item.languageString = @"zh-Hans";
    [item save];
    
    [historyView addObject:item];
    return;
}

-(void)makeSRT{
    [OCRManageSegment.shared filterWithTail:@[@"）"]];
    
    NSString *name = [[videoURL lastPathComponent] stringByDeletingPathExtension];
    if (nil == name){
        name = @"Debug";
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:NSLocale.currentLocale];
    [df setTimeZone:NSTimeZone.systemTimeZone];
    [df setDateFormat:@"yyyyMMdd_HHmmss"];
    NSString *file = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@_%@.srt.txt", [df stringFromDate:NSDate.date], name];
    
    [OCRManageSegment.shared makeSRT:file withTolerance:[setting tolerance]];
    

    OCRHistory *item = [OCRSubtitleManage.shared createOCRResult];
    item.file = file;
    item.videoFileName = name;
    item.srtInfo = [[NSString alloc] initWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    item.completedDate = NSDate.date;
    item.usageSeconds = [NSDate.date timeIntervalSinceDate:startDate];
    item.thumbnailImageData = UIImageJPEGRepresentation(thumbnailCGImage, 0.7);
    item.sampleRate = setting.rate;
    item.languageString = setting.languageString;
    [item save];
    
    [historyView addObject:item];
    
    [UIHans shareFile:file];
    
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller
        didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls API_AVAILABLE(ios(11.0)){
    [controller dismissViewControllerAnimated:YES completion:^{
        [self pickupURLs:urls];
    }];
    return;
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller{
    return;
}

- (void)documentBrowser:(UIDocumentBrowserViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *> *)documentURLs API_AVAILABLE(ios(12.0)){
    [controller dismissViewControllerAnimated:YES completion:^{
        [self pickupURLs:documentURLs];
    }];
    return;
}


#pragma mark - Debug Functions

-(void)debugGetImagesFromVideo{
    //getImages 初始化后，同样选择视频文件，程序将只保存特定ms位置的图片，到Documents目录下
    debugGetImagesFromVideo = [[NSMutableArray alloc] init];
    [debugGetImagesFromVideo addObject:@117500];
    [debugGetImagesFromVideo addObject:@117550];
    [debugGetImagesFromVideo addObject:@117600];
    return;
}

//load OCR.bundle and scan all images.
-(void)debugGetTextFromImage{
    [NSThread detachNewThreadWithBlock:^{
        NSBundle *b = [[NSBundle alloc] initWithPath:[NSBundle.mainBundle pathForResource:@"OCR" ofType:@"bundle"]];
        if (nil == b){
            return;
        }
        NSString *path = [b resourcePath];
        NSArray *array = [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:nil];
        for (NSString *name in array){
            NSString *file = [path stringByAppendingPathComponent:name];
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:file];
            [[self->textFromImage objectAtIndex:0] OCRImage:image.CGImage withImageTime:100.1f handler:^(NSArray<OCRSegment *> * _Nonnull results) {
                for (OCRSegment *seg in results){
                    NSLog(@"Debug image result:%@ in %@", seg.string, name);
//                        [OCRManageSegment.shared add:seg];
                }
            }];
        }
    }];
    return;
}

-(void)debugPreprocessingImage{
    [NSThread detachNewThreadWithBlock:^{
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"test" ofType:@"png"]];
        [[self->textFromImage objectAtIndex:0] OCRImage:image.CGImage withImageTime:0.1 handler:^(NSArray<OCRSegment *> * _Nonnull results) {
            for (OCRSegment *seg in results){
                NSLog(@"直接提取：%@", seg.string);
            }
        }];
        
        CGImageRef resImage = [[self->imagePre objectAtIndex:0] createSpreadCGImageFrom:image.CGImage
                                                    textColor:[UIColor whiteColor]
                                                textTolerances:0.1f
                                                    boardColor:[UIColor blackColor]
                                                boardTolerances:0.2f];
//                                                         scopeMinumim:50
//                                                              maximum:255
//                                                         replaceValue:0
//                                                                 gate:200];
        UIImage *newImage = [[UIImage alloc] initWithCGImage:resImage];
        NSString *file = [NSHomeDirectory() stringByAppendingString:@"/Documents/swap.png"];
        [NSFileManager.defaultManager removeItemAtPath:file error:nil];
        [UIImagePNGRepresentation(newImage) writeToFile:file atomically:YES];

        [[self->textFromImage objectAtIndex:0] OCRImage:resImage withImageTime:0.1 handler:^(NSArray<OCRSegment *> * _Nonnull results) {
            for (OCRSegment *seg in results){
                NSLog(@"预处理后：%@", seg.string);
            }
        }];
        CGImageRelease(resImage);
        
        image = [[UIImage alloc] initWithContentsOfFile:file];
        [[self->textFromImage objectAtIndex:0] OCRImage:image.CGImage withImageTime:0.1 handler:^(NSArray<OCRSegment *> * _Nonnull results) {
            for (OCRSegment *seg in results){
                NSLog(@"预处理，且重载入：%@", seg.string);
            }
        }];
        
        NSLog(@"image saved.");

        return;
    }];
}

-(void)debugForMoreThread{
    startDate = NSDate.date;
    NSLog(@"Start:%@", startDate);
    for (int i=0;i<3;i++){
        [NSThread detachNewThreadWithBlock:^{
            int threadNum = i;
            NSInteger loop = 100;
            while (loop > 0) {
                UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"test" ofType:@"png"]];
                OCRImagePreprocessing *imageThreadPre = [[OCRImagePreprocessing alloc] initWithRegionOfInterest:[self->setting regionOfInterest]];
                CGImageRef resImage = [imageThreadPre createSpreadCGImageFrom:image.CGImage
                                                                    textColor:[UIColor whiteColor]
                                                               textTolerances:0.1f
                                                                   boardColor:[UIColor blackColor]
                                                              boardTolerances:0.2f];
//                                                                 scopeMinumim:50
//                                                                      maximum:255
//                                                                 replaceValue:0
//                                                                         gate:200];
                OCRGetTextFromImage *textFromImageThread = [[OCRGetTextFromImage alloc] initWithLanguage:self->setting.subtitleLanguages
                                                                                   withMinimumTextHeight:self->setting.heightRate
                                                                                    withRegionOfInterest:[self->setting regionOfInterest]];
                [textFromImageThread OCRImage:resImage withImageTime:0.1 handler:^(NSArray<OCRSegment *> * _Nonnull results) {
                    for (OCRSegment *seg in results){
                        NSLog(@"%@", seg.string);
                    }
                }];
                CGImageRelease(resImage);
                NSLog(@"Thread %d run loop:%ld", threadNum, loop--);
            }
            NSTimeInterval usage = [NSDate.date timeIntervalSinceDate:self->startDate];
            NSLog(@"End Thread:%d at %@ Usage:%.2f", threadNum, NSDate.date, usage);
            return;
        }];
    }
}

@end
