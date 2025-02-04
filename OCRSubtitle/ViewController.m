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

#import "OCRProgressViewController.h"

#define MAXIMUM_THREAD 4    //How many thread for get Text from image.

@interface ViewController ()<UIDocumentPickerDelegate,UIDocumentBrowserViewControllerDelegate>{
    UIHansButton *selectFileButton;
    NSDate *startDate;
    UIAlertController *progressAlert;
    
    OCRProgressViewController *progressVC;
    NSURL *videoURL;
    CGRect regionOfInterest;
    
    NSMutableArray <NSNumber *>*debugGetImagesFromVideo;  //从视频中提取图片， 值是 提取图片的时间值,单位ms
    NSArray *subtitleLanguages;
    float minimumTextHeight;
    
    NSMutableArray <NSThread *>*threads;
//    OCRGetImageFromVideo *imageFromVideo;   //视频提取图片
    OCRGetSampleBuffersFromVideo *bufferFromVideo;
    NSMutableArray <OCRImagePreprocessing *>*imagePre;   ///图片预处理
    NSMutableArray <OCRGetTextFromImage *>*textFromImage;   //图片提取文字
    BOOL loadVideoCompleted;
    
    int rateSampling;           //保留的样本率
    NSUInteger tolerance;       //SRT 时间输出的准许差
    
    
    VNFeaturePrintObservation *lastObservation;
}

@end

@implementation ViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    progressVC = [[OCRProgressViewController alloc] init];
    
    selectFileButton = [[UIHansButton alloc] initWithFrame:CGRectMake( (self.view.frame.size.width-200.f)/2.f,
                                                                      200.f+30.f, 200.f, 60.f)];
    selectFileButton.enabled = YES;
    selectFileButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"files" ofType:@"png"]];
    [selectFileButton setImage:image forState:UIControlStateNormal];
    [selectFileButton setTitle:NSLocalizedString(@"Media from \"Files\"", nil)
                      forState:UIControlStateNormal];
    [selectFileButton addTarget:self action:@selector(selectFileAction) forControlEvents:UIControlEventTouchUpInside];
    [selectFileButton setBackgroundColor:[UIHans blue] forState:UIControlStateNormal];
    [selectFileButton setBackgroundColor:[UIHans blueHighlighted] forState:UIControlStateHighlighted];
    [self.view addSubview:selectFileButton];
    
    float y = CGRectGetMaxY(selectFileButton.frame)+20.f;
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10.f, y, self.view.frame.size.width-20.f, self.view.frame.size.height-y-40.f)];
    l.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    l.numberOfLines = 10;
    l.text = @"字幕文字颜色纯白、黑色边框不少于 “60”， 字体大小不可变、字幕居中、所在上下位置不动、不可用渐入渐出特效。";
    [self.view addSubview:l];
    
    //    Video size 888 x 1920
        //通过忽略很小的字， 去掉了视频1:46秒位置，字幕文字前面的 24小字
    //    float minimumTextHeight = 30.f/1490.f;
    //    NSString *subtitleLanguage = @"zh-Hans";
    //    regionOfInterest = CGRectMake(0.f, 125.f/1774.f, 1.f, 120.f/1774.f);

    //Video size 1920 x 1080
    minimumTextHeight = 42.f/1080.f;
    subtitleLanguages = @[@"zh-Hans", @"en-US"];  //支持简体中文和英文
        
        //for 牛
    //    regionOfInterest = CGRectMake(0.1f, 30.f/1080.f, 0.8f, 80.f/1080.f);
    
    // for Eva
    regionOfInterest = CGRectMake(0.1f, 104.f/1080.f, 0.8f, 80.f/1080.f);
    
    //Test
//    regionOfInterest = CGRectMake(0.0f, 0.f, 1.f, 1.f);
    
    
    rateSampling = 3;tolerance = 50;   //30fps的视频 每3张图，取1张，图间隔100ms，公差为50ms
//    rateSampling = 1;tolerance = 15;   //30fps的视频 每张图都参与，图间隔30ms，公差为15ms
    
    textFromImage = [[NSMutableArray alloc] init];
    imagePre = [[NSMutableArray alloc] init];
    for (int i=0;i<MAXIMUM_THREAD;i++){
        OCRGetTextFromImage *o = [[OCRGetTextFromImage alloc] initWithLanguage:subtitleLanguages
                                                withMinimumTextHeight:minimumTextHeight
                                                withRegionOfInterest:regionOfInterest];
        [textFromImage addObject:o];
        OCRImagePreprocessing *imagePreObject = [[OCRImagePreprocessing alloc] initWithRegionOfInterest:regionOfInterest];
        [imagePre addObject:imagePreObject];
    }
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

-(void)pickupURLs:(NSArray <NSURL *>*)urls{
    videoURL = urls.firstObject;
    [self presentViewController:progressVC animated:NO completion:^{
        [self startWork];
    }];
    return;
}

-(void)showProgress:(float)progress withString:(NSString *)string{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->progressAlert.title = string;
        self->progressAlert.message = [[NSString alloc] initWithFormat:@"%.2f%%", progress * 100.f];
    });
    return;
}

-(void)OCRSampleInThread:(SampleObject *)sample threadNum:(int)threadIndex{
    CGImageRef sourceCGImage = [sample createCGImage];
    CGImageRef predImage = [[imagePre objectAtIndex:threadIndex] createSpreadCGImageFrom:sourceCGImage
                                        textColor:[UIColor whiteColor]
                                        textTolerances:0.1f
                                        boardColor:[UIColor blackColor]
                                    boardTolerances:0.2f];

    CGImageRef subtitleSourceImage = [[imagePre objectAtIndex:threadIndex] createRegionOfInterestImageFromFullImage:sourceCGImage];
    CGImageRef subtitleImage = [[imagePre objectAtIndex:threadIndex] createRegionOfInterestImageFromFullImage:predImage];
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
//    UIImage *i = [[UIImage alloc] initWithCGImage:predImage];
//    NSString *file = [[NSString alloc] initWithFormat:@"%@/Documents/Buffer_%d.png", NSHomeDirectory(),threadIndex];
//    [NSFileManager.defaultManager removeItemAtPath:file error:nil];
//    [UIImagePNGRepresentation(i) writeToFile:file atomically:YES];
//    UIImage *readed = [[UIImage alloc] initWithContentsOfFile:file];
//重载入测试结束
    progressVC.image = predImage;
    
    [[textFromImage objectAtIndex:threadIndex] OCRImage:predImage withImageTime:[sample imageTime] handler:^(NSArray<OCRSegment *> * _Nonnull results) {
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
//            NSString *debugString = @"职亚个人不缴纳工伤保险费";
//            if ([seg.string isEqualToString:debugString]){
//                [self saveCGImage:cgImage withName:[NSString stringWithFormat:@"%.2f_source_%@", seg.t, seg.string]];
//                [self saveCGImage:predImage withName:[NSString stringWithFormat:@"%.2f_pred_%@", seg.t, seg.string]];
//                NSLog(@"Debug text");
//            }
            [OCRManageSegment.shared add:seg withSubtitleImage:subtitleImage withSource:subtitleSourceImage];
        }
        float progress = [sample imageTime]/(self->bufferFromVideo.duration.value/self->bufferFromVideo.duration.timescale);
        self->progressVC.progress = progress;
        [self showProgress:progress withString:@""];
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
    int sampleNum = 0;
    while (NO == loadVideoCompleted) {
        if (self->bufferFromVideo.ready){
            CMSampleBufferRef sampleBuffer = [self->bufferFromVideo copyNextBuffer];
            if (nil == sampleBuffer){
                loadVideoCompleted = YES;
                break;
            }
            sampleNum ++;
            if (0 != sampleNum%rateSampling){
                CFRelease(sampleBuffer);
                sampleBuffer = nil;
                continue;
            }
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

-(void)startWork{
    [UIApplication.sharedApplication setIdleTimerDisabled:YES];
    
    //从头开始
    int minute = 0;
    int second = 0;
    minute = 10;
    second = 59;
    
    [OCRManageSegment.shared clear];
    [videoURL startAccessingSecurityScopedResource];
    NSLog(@"start load images.");
    [self showProgress:0.f withString:@"提取视频中的图片"];
    
    startDate = NSDate.date;
    float start = minute * 60 + second;
//    bufferFromVideo = [[OCRGetSampleBuffersFromVideo alloc] initWithVideoURL:videoURL withBegin:start withEnd:start+20.f];
    bufferFromVideo = [[OCRGetSampleBuffersFromVideo alloc] initWithVideoURL:videoURL];
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
//    [progressAlert dismissViewControllerAnimated:YES completion:^{
//        [OCRManageSegment.shared saveSegments];
//        [self makeSRT];
//    }];
//    return;
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
    
    [OCRManageSegment.shared makeSRT:file withTolerance:tolerance];
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
                OCRImagePreprocessing *imageThreadPre = [[OCRImagePreprocessing alloc] initWithRegionOfInterest:self->regionOfInterest];
                CGImageRef resImage = [imageThreadPre createSpreadCGImageFrom:image.CGImage
                                                                    textColor:[UIColor whiteColor]
                                                               textTolerances:0.1f
                                                                   boardColor:[UIColor blackColor]
                                                              boardTolerances:0.2f];
//                                                                 scopeMinumim:50
//                                                                      maximum:255
//                                                                 replaceValue:0
//                                                                         gate:200];
                OCRGetTextFromImage *textFromImageThread = [[OCRGetTextFromImage alloc] initWithLanguage:self->subtitleLanguages
                                                                                   withMinimumTextHeight:self->minimumTextHeight
                                                                                    withRegionOfInterest:self->regionOfInterest];
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
