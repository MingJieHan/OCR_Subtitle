//
//  SCRSetting.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/6.
//

#import "OCRSetting.h"
#import "OCRGetTextFromImage.h"
#import "OCRSubtitleManage.h"
#import <HansServer/HansServer.h>

#define SPACE_STRING @"|"

@implementation OCRSetting
@synthesize image, imageData;
@synthesize videoWidth,videoHeight;
@synthesize subtitleLanguages,subtitleLanguageString;
@synthesize passTopRate,heightRate;
@synthesize textColor, borderColor;
@synthesize textColorString,borderColorString;
@synthesize rate;

-(CGRect)regionOfInterest{
    return CGRectMake(0.f, 1.f-passTopRate-heightRate, 1.f, heightRate);
}

-(float)minimumFrameSpacing{
    return 1.f/rate;
}

-(NSUInteger)tolerance{
    float res = 1000.f * [self minimumFrameSpacing]/2.f;
    return (NSUInteger)res;
}

-(NSString *)languageString{
    NSMutableString *res = [[NSMutableString alloc] init];
    for (NSString *identifier in subtitleLanguages){
        NSString *script = [OCRGetTextFromImage stringForLanguageCode:identifier];
        if (res.length > 1){
            [res appendString:@" & "];
        }
        [res appendString:script];
    }
    return res;
}

+(id)wanruSetting{
    OCRSetting *setting = [OCRSubtitleManage.shared createOCRSetting];
    setting.videoWidth = 1920;
    setting.videoHeight = 1080;
    setting.rate = 10.f;
    setting.heightRate = 80.f/1080.f;
    setting.passTopRate = (1080.f - 104.f - 80.f)/1080.f;
    setting.borderColor = [UIColor blackColor];
    setting.textColor = [UIColor whiteColor];
    setting.subtitleLanguages = @[@"zh-Hans", @"en-US"];  //支持简体中文和英文
    [setting save];
    return setting;
}

+(id)demo1Setting{
    OCRSetting *setting = [OCRSubtitleManage.shared createOCRSetting];
    setting.videoWidth = 720;
    setting.videoHeight = 1280;
    setting.rate = 10.f;
    setting.heightRate = 60.f/1280.f;
    setting.passTopRate = 630.f/1280.f;
    setting.borderColor = [UIColor blackColor];
    setting.textColor = [UIColor whiteColor];
    setting.subtitleLanguages = @[@"zh-Hans"];
    [setting save];
    return setting;
}


-(BOOL)save{
    if (image){
        self.imageData = UIImageJPEGRepresentation(image, 0.7);
    }else{
        self.imageData = nil;
    }
    if (self.subtitleLanguages){
        NSMutableString *res = [[NSMutableString alloc] init];
        for (NSString *str in self.subtitleLanguages){
            if (res.length > 0){
                [res appendString:SPACE_STRING];
            }
            [res appendString:str];
        }
        self.subtitleLanguageString = res;
    }else{
        self.subtitleLanguageString = nil;
    }
    if (self.textColor){
        self.textColorString = [UIHans colorConvertString:self.textColor];
    }else{
        self.textColorString = nil;
    }
    if (self.borderColor){
        self.borderColorString = [UIHans colorConvertString:self.borderColor];
    }else{
        self.borderColorString = nil;
    }
    return [OCRSubtitleManage.shared save];
}

-(void)initDatas{
    if (self.imageData){
        self.image = [[UIImage alloc] initWithData:self.imageData];
    }
    if (self.subtitleLanguageString){
        self.subtitleLanguages = [self.subtitleLanguageString componentsSeparatedByString:SPACE_STRING];
    }
    if (self.textColorString){
        self.textColor = [UIHans colorFrom:self.textColorString];
    }
    if (self.borderColorString){
        self.borderColor = [UIHans colorFrom:self.borderColorString];
    }
    return;
}
@end
