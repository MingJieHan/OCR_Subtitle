//
//  OCRGetTextFromImage.h
//  LoadText
//
//  Created by jia yu on 2024/10/26.
//

#import <Foundation/Foundation.h>
#import <Vision/Vision.h>
#import "OCRSegment.h"

typedef void (^OCRGetTextFromImage_Handler) (NSArray <OCRSegment *> * _Nonnull results);

NS_ASSUME_NONNULL_BEGIN
@interface OCRGetTextFromImage : NSObject
/*
 NSArray *languages = [OCRGetTextFromImage availableLanguages];
 for (NSString *languageIdentifier in languages){
     NSString *descriptString = [OCRGetTextFromImage stringForLanguageCode:languageIdentifier];
     NSLog(@"%@: %@", languageIdentifier, descriptString);
 }
 */
+(NSArray <NSString *>*)availableLanguages;

//return 当前系统，最接近的OCR语言。
+(NSString *)systemSupportedRecognitionLanguage;


//[OCRGetTextFromImage stringForLanguageCode:@"zh-Hans"];
+(NSString *)stringForLanguageCode:(NSString *)languageIdentifier;

+(NSArray *)sortedAvailableLanguages;

-(id)init NS_UNAVAILABLE;

-(id)initWithLanguage:(NSArray<NSString *> *)subtitleLanguages
    withMinimumTextHeight:(float)minimumHeight
    withRegionOfInterest:(CGRect)regionRect;

-(void)OCRImage:(CGImageRef)image withOrientation:(CGImagePropertyOrientation)orientation
        withImageTime:(NSTimeInterval)imageTime
            handler:(OCRGetTextFromImage_Handler)completeHandler;
@end
NS_ASSUME_NONNULL_END
