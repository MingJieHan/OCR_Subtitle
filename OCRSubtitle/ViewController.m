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
#import "OCRAreaSelectViewController.h"
#import "OCRTemplateTableViewController.h"

#define MAXIMUM_THREAD 4    //How many thread for get Text from image.

@interface ViewController ()<UIDocumentPickerDelegate,UIDocumentBrowserViewControllerDelegate,UIDocumentInteractionControllerDelegate>{
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
    
    NSArray <OCRSetting *>*availableTemplatesForTheVideo;
    float templateViewWidth;
}

@end

@implementation ViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"Home:%@", NSHomeDirectory());
    self.view.backgroundColor = [UIColor whiteColor];
    progressVC = [[OCRProgressViewController alloc] init];
    
    ViewController * __strong strongSelf = self;
    float y = 400.f;
    templateViewWidth = 130.f;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        templateViewWidth = 145.f;
    }
    templateView = [[OCRTemplateCollectionView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-templateViewWidth, 60.f, templateViewWidth, self.view.frame.size.height-100.f)];
    templateView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin;
    templateView.openHandler = ^(OCRSetting * _Nonnull selectedSetting) {
        [strongSelf hiddenTemplates:nil];
        self->setting = selectedSetting;
        [strongSelf selectFileAction];
    };
    templateView.editHandler = ^(OCRSetting * _Nonnull selectedSetting) {
        [strongSelf hiddenTemplates:nil];
        [strongSelf showTemplateDetailWithSetting:selectedSetting];
    };
    [self.view addSubview:templateView];
    UISwipeGestureRecognizer *rightSwipe1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenTemplates:)];
    rightSwipe1.direction = UISwipeGestureRecognizerDirectionRight;
    [templateView addGestureRecognizer:rightSwipe1];
    
    UIView *separateView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-templateViewWidth, 60.f, 2.f, self.view.frame.size.height-120.f)];
    separateView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleHeight;
    separateView.backgroundColor = templateColor;
    separateView.layer.shadowColor = templateColor.CGColor;
    separateView.layer.shadowOffset = CGSizeMake(2.f, 1.f);
    separateView.layer.shadowRadius = 2.f;
    separateView.layer.shadowOpacity = 0.4f;
    [self.view addSubview:separateView];
    
    y += 10.f;
    historyView = [[OCRHistoryCollectionView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height-40.f)];
    historyView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    historyView.shareHandler = ^(OCRHistory * _Nonnull history) {
        [strongSelf hiddenTemplates:nil];
        [strongSelf moreActionWith:history];
    };
    historyView.openHandler = ^(OCRHistoryCell * _Nonnull historyCell) {
        [strongSelf hiddenTemplates:nil];
        if (nil == historyCell.item){
            self->setting = nil;
            [strongSelf selectFileAction];
        }else{
            [strongSelf openExistOCRHistory:historyCell];
        }
    };
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showTemplates:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [historyView addGestureRecognizer:leftSwipe];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenTemplates:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [historyView addGestureRecognizer:rightSwipe];
    [self.view addSubview:historyView];
    
    verLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, self.view.frame.size.height-40.f, self.view.frame.size.width, 30.f)];
    verLabel.backgroundColor = [UIColor clearColor];
    verLabel.textColor = [UIHans gray];
    verLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    verLabel.font = [UIFont fontWithName:@"PingFangSC-Light" size:10.f];
    verLabel.textAlignment = NSTextAlignmentCenter;
    verLabel.text = [NSString stringWithFormat:@"OCR Subtitle Version:%@ Build:%@", UIHans.appVersion, UIHans.appBuildVersion];
    [self.view addSubview:verLabel];

    y = CGRectGetMaxY(historyView.frame) - 3.f;
    UIImageView *shadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, y, self.view.frame.size.width, 4.f)];
    shadowView.backgroundColor = [UIColor clearColor];
    shadowView.image = [[UIImage alloc] initWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"shadow" ofType:@"png"]];
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:shadowView];

//    y = CGRectGetMaxY(debugButton.frame)+20.f;
//    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10.f, y, self.view.frame.size.width-20.f, self.view.frame.size.height-y-40.f)];
//    l.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//    l.numberOfLines = 10;
//    l.text = @"字幕文字颜色纯白、黑色边框不少于 “60”， 字体大小不可变、字幕居中、所在上下位置不动、不可用渐入渐出特效。";
//    [self.view addSubview:l];

//    NSArray *languages = [OCRGetTextFromImage sortedAvailableLanguages];
//    for (NSString *descriptString in languages){
//        NSLog(@"%@", descriptString);
//    }
}

OCRHistoryCell *openingCell;
-(void)openExistOCRHistory:(OCRHistoryCell * _Nonnull)historyCell{
    NSString *fullPathFile = [historyCell.item reWriteSRTInfo];
    UIView *thumbnail = [historyCell snapshotViewAfterScreenUpdates:NO];
    CGRect rect = [historyView convertRect:historyCell.frame toView:self.view];
    [thumbnail setFrame:rect];
    [self.view addSubview:thumbnail];
    [UIView animateWithDuration:0.6 animations:^{
        [thumbnail setFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, self.view.frame.size.height)];
        thumbnail.alpha = 0.f;
    } completion:^(BOOL finished) {
        [thumbnail removeFromSuperview];
    }];
    openingCell = historyCell;
    if (fullPathFile){
        UIDocumentInteractionController *b = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:fullPathFile]];
        if (nil == b){
            NSLog(@"UIDocumentInteractionController init failed.");
            return;
        }
        b.delegate = self;
        [b presentPreviewAnimated:YES];
    }
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

UIDocumentBrowserViewController *documentBrowserVC;
-(void)cancelFileSelectAction:(id)sender{
    [documentBrowserVC dismissViewControllerAnimated:YES completion:nil];
    return;
}

-(void)selectFileAction{
    NSArray *types = @[@"mp4", @"mov"];
    NSMutableArray *utTypes = [[NSMutableArray alloc] init];
    for (NSString *tString in types){
        UTType *type = [UTType typeWithTag:tString tagClass:UTTagClassFilenameExtension conformingToType:nil];
        [utTypes addObject:type];
    }
    types = utTypes;
    documentBrowserVC = [[UIDocumentBrowserViewController alloc] initForOpeningContentTypes:types];
    if (nil == setting){
        documentBrowserVC.title = NSLocalizedString(@"Select a video for scan subtitles.", nil);
    }else{
        documentBrowserVC.title = [NSString stringWithFormat:NSLocalizedString(@"Select video dimensions %dx%d, Template:%@.",nil),
                                   [setting.videoWidth intValue],
                                   [setting.videoHeight intValue],
                                   setting.name];
    }
    documentBrowserVC.allowsPickingMultipleItems = NO;
    documentBrowserVC.allowsDocumentCreation = NO;
    documentBrowserVC.delegate = self;
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelFileSelectAction:)];
    documentBrowserVC.additionalTrailingNavigationBarButtonItems = @[cancelButtonItem];
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:documentBrowserVC];
    documentBrowserVC.navigationItem.rightBarButtonItem = cancelButtonItem;
    [UIHans.currentVC presentViewController:n animated:YES completion:nil];
    return;
}

-(void)beginGotTextWorking{
    [self presentViewController:progressVC animated:NO completion:^{
        self->progressVC.gottedStringBorderColor = self->setting.borderColor;
        self->progressVC.gottedStringBorderWidth = 3.f;
        self->progressVC.passTopRate = self->setting.passTopRate;
        self->progressVC.heightRate = self->setting.heightRate;
        [self startWork];
    }];
}

-(void)pickupURLs:(NSArray <NSURL *>*)urls{
    videoURL = urls.firstObject;
    if (nil != setting){
        //从模版位置点击进来，有选择的模版。
        [self beginGotTextWorking];
        return;
    }
    
    availableTemplatesForTheVideo = [templateView availableSettingForVideo:videoURL];
    if (nil == availableTemplatesForTheVideo || 0 == availableTemplatesForTheVideo.count){
        UIAlertController *v = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No Available Template",nil)
                                                                   message:NSLocalizedString(@"Video dimsnsion must same with template.",nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *create = [UIAlertAction actionWithTitle:NSLocalizedString(@"Create Template",nil)
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
            [self createTemplateWithVideo:self->videoURL];
        }];
        [v addAction:create];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
        [v addAction:cancel];
        [self presentViewController:v animated:YES completion:nil];
        return;
    }
    
    //发现了可用的模版，可以选择某个模版执行，也可创建新的，或者取消
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%ld available template.\n select template start scan video.", nil),
                         availableTemplatesForTheVideo.count];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Next Step?", nil)
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    for (OCRSetting *s in availableTemplatesForTheVideo){
        UIAlertAction *action = [UIAlertAction actionWithTitle:s.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            for (OCRSetting *tt in self->availableTemplatesForTheVideo){
                if ([tt.name isEqualToString:action.title]){
                    self->setting = tt;
                    [self beginGotTextWorking];
                    break;
                }
            }
        }];
        [alert addAction:action];
    }
    UIAlertAction *create = [UIAlertAction actionWithTitle:NSLocalizedString(@"Create Template", nil)
                                                     style:UIAlertActionStyleDestructive
                                                   handler:^(UIAlertAction * _Nonnull action) {
        [self createTemplateWithVideo:self->videoURL];
        return;
    }];
    [alert addAction:create];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
    return;
}

-(void)OCRSampleInThread:(SampleObject *)sample threadNum:(int)threadIndex{
    CGImageRef sourceCGImage = [sample createCGImage];
    OCRImagePreprocessing *imageWorker = [imagePre objectAtIndex:threadIndex];
    
    CGImageRef predImage = nil;
    
    if (setting.textColor && setting.borderColor){
        predImage = [imageWorker createSpreadCGImageFrom:sourceCGImage
                                        textColor:setting.textColor
                                    textTolerances:0.1f
                                        boardColor:setting.borderColor
                                    boardTolerances:0.2f];
    }else{
        imageWorker.imageSize = CGSizeMake([setting.videoWidth integerValue], [setting.videoHeight integerValue]);
    }
    
    CGImageRef subtitleSourceImage = nil;
    subtitleSourceImage = [imageWorker createRegionOfInterestImageFromFullImage:sourceCGImage];
    if (nil == subtitleSourceImage){
        NSLog(@"Stop debug.");
        return;
    }
    
    CGImageRef subtitleImage = nil;
    if (predImage){
        subtitleImage = [imageWorker createRegionOfInterestImageFromFullImage:predImage];
    }
    
// 重载入测试开始
//    UIImage *i = [[UIImage alloc] initWithCGImage:subtitleSourceImage];
//    NSString *file = [[NSString alloc] initWithFormat:@"%@/Documents/Buffer_%d.png", NSHomeDirectory(),threadIndex];
//    [NSFileManager.defaultManager removeItemAtPath:file error:nil];
//    [UIImagePNGRepresentation(i) writeToFile:file atomically:YES];
//    UIImage *readed = [[UIImage alloc] initWithContentsOfFile:file];
//重载入测试结束
    progressVC.image = sourceCGImage;
    
    CGImageRef scanImage = predImage;
    if (nil == scanImage){
        scanImage = sourceCGImage;
    }
    [[textFromImage objectAtIndex:threadIndex] OCRImage:scanImage
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
            [OCRManageSegment.shared add:seg
                       withSubtitleImage:subtitleImage
                              withSource:subtitleSourceImage];
        }
        float progress = [sample imageTime]/(self->bufferFromVideo.duration.value/self->bufferFromVideo.duration.timescale);
        if (progress > 1.f){
            progress = 1.f;
        }
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

-(void)showTemplateDetailWithSetting:(OCRSetting *)setting{
    OCRTemplateTableViewController *ttVc = [[OCRTemplateTableViewController alloc] initWithSetting:setting];
    ttVc.changedHandler = ^(OCRTemplateTableViewController * _Nonnull vc) {
        [self->templateView refreshSetting:vc.setting];
        return;
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ttVc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

-(void)createTemplateWithVideo:(NSURL *)targetVideoURL{
    OCRAreaSelectViewController *v = [[OCRAreaSelectViewController alloc] initWithVideo:targetVideoURL];
    v.modalPresentationStyle = UIModalPresentationFullScreen;
    v.handler = ^(OCRAreaSelectViewController * _Nonnull vc) {
        OCRSetting *newSetting = [OCRSubtitleManage.shared createOCRSetting];
        newSetting.name = vc.suggestName;
        newSetting.image = vc.thumbnailImage;
        newSetting.videoWidth = [NSNumber numberWithFloat:vc.videoSize.width];
        newSetting.videoHeight = [NSNumber numberWithFloat:vc.videoSize.height];
        newSetting.passTopRate = vc.passTopRate;
        newSetting.heightRate = vc.heightRate;
        newSetting.subtitleLanguages = @[vc.scaningLanguageIdentifier];
        [newSetting save];
        
        [self->templateView reloadData];
        
        //Scan subtitle for video with new setting
        self->setting = newSetting;
        self->videoURL = targetVideoURL;
        [self beginGotTextWorking];
        
        //show new created template.
//        [self showTemplateDetailWithSetting:newSetting];
    };
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:v];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
    return;
}

-(void)exceptStopWithErrorString:(NSString *)string{
    [progressVC dismissViewControllerAnimated:YES completion:^{
        [self->videoURL stopAccessingSecurityScopedResource];
        [UIApplication.sharedApplication setIdleTimerDisabled:NO];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error",nil)
                                                                       message:string
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *create = [UIAlertAction actionWithTitle:NSLocalizedString(@"Create Template",nil)
                                                         style:UIAlertActionStyleDestructive
                                                       handler:^(UIAlertAction * _Nonnull action) {
            [self createTemplateWithVideo:self->videoURL];
        }];
        [alert addAction:create];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
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
    if (bufferFromVideo.videoSize.width != [setting.videoWidth floatValue]
        || bufferFromVideo.videoSize.height != [setting.videoHeight floatValue]){
        //Warning for different size with setting.
        float vRate = bufferFromVideo.videoSize.width/bufferFromVideo.videoSize.height;
        float sRate = [setting.videoWidth floatValue]/[setting.videoHeight floatValue];
        NSString *errorString = nil;
        if (vRate == sRate){
            //视频宽高比例相同
        }else{
            //视频宽高比例不同
        }
        errorString = [NSString stringWithFormat:NSLocalizedString(@"Template %@ size is %ld x %ld,\nBut selected video is %.0f x %.0f", nil),
                       setting.name,
                       [setting.videoWidth longValue],
                       [setting.videoHeight longValue],
                       bufferFromVideo.videoSize.width,
                       bufferFromVideo.videoSize.height];
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

UIView *storagedView;
UIView *cellView;
-(void)completedInMainThread{
    [UIApplication.sharedApplication setIdleTimerDisabled:NO];
    [videoURL stopAccessingSecurityScopedResource];
    
    NSUInteger numOfSamples = [OCRManageSegment.shared numOfSegments];
    if (0 == numOfSamples){
        [progressVC dismissViewControllerAnimated:YES completion:^{
            //没有提取到任何Subtitle，可能是选择了错误的模版。
            NSString *message = NSLocalizedString(@"The template used for scanning is incorrect, and no subtitles were found.", nil);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"NO Subtitle", nil)
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:okay];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }];
        return;
    }
    
    //存储动画第一步，将扫描进度界面的存储视图，移动到屏幕中间
    float animateStep1Duration = 0.3f;
    CGRect storageViewRect = [progressVC.view convertRect:progressVC.storageImageView.frame toView:self.view];
    storagedView = [progressVC.storageImageView snapshotViewAfterScreenUpdates:NO];
    [storagedView setFrame:storageViewRect];
    [self.view addSubview:storagedView];
    [UIView animateWithDuration:animateStep1Duration animations:^{
        [storagedView setCenter:self.view.center];
    }];
    //存储动画第一步 结束
    
    [progressVC dismissViewControllerAnimated:YES completion:^{
        [OCRManageSegment.shared saveSegments];
        [self makeSRT];
    }];
    return;
}

-(void)makeSRT{
    [OCRManageSegment.shared filterWithTail:@[@"）"]];
    
    NSString *name = [[videoURL lastPathComponent] stringByDeletingPathExtension];
    if (nil == name){
        name = @"Debug";
    }
    NSString *file = [[NSString alloc] initWithFormat:@"%@.srt.txt", name];
    NSString *fullPathFile = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", file];
    if ([NSFileManager.defaultManager fileExistsAtPath:fullPathFile]){
        [NSFileManager.defaultManager removeItemAtPath:fullPathFile error:nil];
    }
    [OCRManageSegment.shared makeSRT:fullPathFile withTolerance:[setting tolerance]];
    
    OCRHistory *item = [OCRSubtitleManage.shared createOCRResult];
    item.file = file;
    item.videoFileName = name;
    NSError *error = nil;
    item.srtInfo = [[NSString alloc] initWithContentsOfFile:fullPathFile encoding:NSUTF8StringEncoding error:&error];
    if (error){
        NSLog(@"write SRT result failed:%@", error.localizedDescription);
    }
    item.completedDate = NSDate.date;
    item.usageSeconds = [NSDate.date timeIntervalSinceDate:startDate];
    item.thumbnailImageData = UIImageJPEGRepresentation(thumbnailCGImage, 0.7);
    item.sampleRate = setting.rate;
    item.languageString = [setting languageString];
    [item save];
    [historyView insertAnHistory:item withCompleted:^(OCRHistoryCell * _Nonnull cell) {
        CGRect fromRect = [self->historyView convertRect:cell.frame toView:self.view];
        //存储动画第二步， 将存储结果视图，渐变为新生成Cell视图
        float animateStep2Duration = 0.8f;
        float animateStep3Duration = 0.6f;
        cellView = [cell snapshotViewAfterScreenUpdates:NO];
        [cellView setFrame:storagedView.frame];
        cellView.alpha = 0.f;
        [self.view addSubview:cellView];
        [UIView animateWithDuration:animateStep2Duration delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
            storagedView.alpha = 0.f;
            cellView.alpha = 1.f;
        } completion:^(BOOL finished) {
            
        }];
        //存储动画第二步 结束
        
        //存储动画第三步， 将Cell视图，从中间位置移动到正确位置
        [UIView animateWithDuration:animateStep3Duration delay:animateStep2Duration options:UIViewAnimationOptionCurveEaseOut animations:^{
            [cellView setFrame:fromRect];
        } completion:^(BOOL finished) {
            [cellView removeFromSuperview];
            cellView = nil;
            [storagedView removeFromSuperview];
            storagedView = nil;
            
            //动画结束后，开启Share界面
            [UIHans shareFile:fullPathFile withName:name withExtName:@"txt"
                     withSize:CGSizeMake(400.f, 300.f)
                withArrowView:self->historyView
                withArrowFrom:fromRect];
        }];
        //存储动画第三步， 结束
    }];
    if (setting){
        setting.useDate = NSDate.date;
        [setting save];
        [templateView scrollsToTop];
        [templateView reloadData];
    }
}

-(void)showTemplates:(id)sender{
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3 delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self->historyView setFrame:CGRectMake(-self->templateViewWidth, self->historyView.frame.origin.y, self->historyView.frame.size.width, self->historyView.frame.size.height)];
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
    }];
    return;
}

-(void)hiddenTemplates:(id)sender{
    if (0.f == historyView.frame.origin.x){
        return;
    }
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3 delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self->historyView setFrame:CGRectMake(0.f, self->historyView.frame.origin.y, self->historyView.frame.size.width, self->historyView.frame.size.height)];
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
    }];
    return;
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


#pragma mark - UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller NS_SWIFT_UI_ACTOR{
    return self;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller{
    return [historyView convertRect:openingCell.frame toView:self.view];;
}

- (nullable UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller{
    return openingCell;
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
    
    [historyView insertAnHistory:item withCompleted:^(OCRHistoryCell * _Nonnull cell) {
        
    }];
    return;
}
@end
