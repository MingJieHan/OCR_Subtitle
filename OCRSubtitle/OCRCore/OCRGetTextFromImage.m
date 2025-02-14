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

/*
    [[NSLocale preferredLanguages] objectAtIndex:0] 结果 可能不在
    [OCRGetTextFromImage availableLanguages] 返回的结果中，
 如 en-CN 在中国区设置系统为英文
 支持的OCR语言描述为 en-US 因此
 首先在 availableLanguages 全匹配，如果找到，则返回
 然后，去掉国家码后再次匹配查找，如找到则返回
 最后，返回 availableLanguages 的第一个
 */
+(NSString *)systemSupportedRecognitionLanguage{
    NSString *systemLanguageIdentifier = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSArray <NSString *>* availableLanguages = [OCRGetTextFromImage availableLanguages];
    for (NSString *an in availableLanguages){
        if ([an isEqualToString:systemLanguageIdentifier]){
            return systemLanguageIdentifier;
        }
    }
    
    NSString *systemLanguageOnly = [OCRGetTextFromImage removeCountryCodeForLanguageIdentifier:systemLanguageIdentifier];
    for (NSString *an in availableLanguages){
        NSString *anWithoutCountryCode = [OCRGetTextFromImage removeCountryCodeForLanguageIdentifier:an];
        if ([anWithoutCountryCode isEqualToString:systemLanguageOnly]){
            return an;
        }
    }
    return availableLanguages.firstObject;
}

+(NSString *)removeCountryCodeForLanguageIdentifier:(NSString *)identifier{
    NSDictionary *dict = [NSLocale componentsFromLocaleIdentifier:identifier];
    NSString *countryCode = [dict valueForKey:@"kCFLocaleCountryCodeKey"];
//    NSString *scriptCode = [dict valueForKey:@"kCFLocaleScriptCodeKey"];
//    NSString *localLanguageCode = [dict valueForKey:@"kCFLocaleLanguageCodeKey"];
    
    if (countryCode && countryCode.length > 0){
        NSString *tryString = [@"-" stringByAppendingString:countryCode];
        return [identifier stringByReplacingOccurrencesOfString:tryString withString:@""];
    }
    return identifier;
}


+(NSString *)stringForLanguageCode:(NSString *)languageIdentifier{
//    NSString *language = [NSLocale.systemLocale localizedStringForLanguageCode:languageIdentifier];
    NSDictionary *dict = [NSLocale componentsFromLocaleIdentifier:languageIdentifier];
    NSString *countryCode = [dict valueForKey:@"kCFLocaleCountryCodeKey"];
    NSString *scriptCode = [dict valueForKey:@"kCFLocaleScriptCodeKey"];
    NSString *localLanguageCode = [dict valueForKey:@"kCFLocaleLanguageCodeKey"];
    
    NSString *scriptString = nil;
    if (scriptCode){
        scriptString = [NSLocale.systemLocale localizedStringForScriptCode:scriptCode];
    }
    
    NSString *languageString = nil;
    if (localLanguageCode){
        languageString = [NSLocale.systemLocale localizedStringForLanguageCode:localLanguageCode];
    }
    
    NSString *countryString = nil;
    if (countryCode){
        countryString = [NSLocale.systemLocale localizedStringForCountryCode:countryCode];
    }
    
    if (countryString){
        return [NSString stringWithFormat:@"%@ (%@)", languageString, countryString];
    }
    if (scriptString){
        return [NSString stringWithFormat:@"%@ (%@)", languageString, scriptString];
    }
    return languageString;
}


+(NSArray *)sortedAvailableLanguages{
    NSMutableArray *res = [[NSMutableArray alloc] init];
    for (NSString *iii in [OCRGetTextFromImage availableLanguages]){
        [res addObject:[OCRGetTextFromImage stringForLanguageCode:iii]];
    }
    [res sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *str1 = obj1;
        NSString *str2 = obj2;
        return [str1 compare:str2];
    }];
    return res;
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
