//
//  OCRGetTextFromImage.m
//  LoadText
//
//  Created by jia yu on 2024/10/26.
//

#import "OCRGetTextFromImage.h"

@interface OCRGetTextFromImage(){
    VNRecognizeTextRequest *request;
    NSTimeInterval currentImageTime;
    OCRGetTextFromImage_Handler handler;
    VNImageRequestHandler *imageRequest;
}
@end

@implementation OCRGetTextFromImage

+(NSArray <NSString *>*)availableLanguages{
    VNRecognizeTextRequest *re = [[VNRecognizeTextRequest alloc] init];
    NSError *error = nil;
    NSArray<NSString *> * results = [re supportedRecognitionLanguagesAndReturnError:&error];
    return results;
}

-(id)initWithLanguage:(NSArray<NSString *> *)subtitleLanguages
    withMinimumTextHeight:(float)minimumHeight
    withRegionOfInterest:(CGRect)regionRect{
    self = [super init];
    if (self){
        request = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request,
                        NSError * _Nullable error) {
            [self OCRResult:request withError:error];
        }];
        
        // Configure for running in real time.
        request.recognitionLevel = VNRequestTextRecognitionLevelAccurate;
        
        //通过忽略很小的字， 去掉了视频1:46秒位置，字幕文字前面的 24小字
        request.minimumTextHeight = minimumHeight;
        
        NSError *error = nil;
        NSArray *availableLanguages = [request supportedRecognitionLanguagesAndReturnError:&error];
        if (error){
            NSLog(@"E:%@", error.localizedDescription);
        }

        for (NSString *requestLanguage in subtitleLanguages){
            BOOL available = NO;
            for (NSString *t in availableLanguages){
                if ([t isEqualToString:requestLanguage]){
                    available = YES;
                    break;
                }
            }
            if (NO == available){
                NSLog(@"不可识别的语种%@", requestLanguage);
                return nil;
            }
        }
        
        request.recognitionLanguages = subtitleLanguages;
        
        // slows recognition.
        request.usesLanguageCorrection = NO;
        if (@available(iOS 16.0, *)) {
            request.automaticallyDetectsLanguage = NO;
        }
        
        request.regionOfInterest = regionRect;
    }
    return self;
}

-(void)OCRResult:(VNRequest * _Nonnull)request withError:(NSError * _Nullable)error{
    if (error){
        NSLog(@"VNRequest CompletionHandler with Error:%@", error.localizedDescription);
    }
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSArray <VNRecognizedTextObservation *> *observaters = request.results;
    for (VNRecognizedTextObservation *item in observaters){
        NSArray <VNRecognizedText*> * texts = [item topCandidates:10];
        for (VNRecognizedText *text in texts){
            OCRSegment *seg = [[OCRSegment alloc] initWithVNRecognized:text];
            seg.t = currentImageTime;
            [results addObject:seg];
        }
    }
    if (handler){
        handler(results);
    }
    return;
}

-(void)OCRImage:(CGImageRef)image withImageTime:(NSTimeInterval)imageTime handler:(OCRGetTextFromImage_Handler)_completeHandler{
    handler = _completeHandler;
    currentImageTime = imageTime;
    NSMutableDictionary *opt = [[NSMutableDictionary alloc] init];
    imageRequest = [[VNImageRequestHandler alloc] initWithCGImage:image options:opt];
    
    NSError *error = nil;
    BOOL success = [imageRequest performRequests:@[self->request] error:&error];
    if (NO == success){
        NSLog(@"Debug imageRequest failed.");
    }
    if (error){
        NSLog(@"Debug performRequests Error:%@", error.localizedDescription);
    }
    return;
}

@end
