//
//  OCRHistory.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import "OCRHistory.h"
#import "OCRSubtitleManage.h"
@implementation OCRHistory
@synthesize file;
@synthesize completedDate;
@synthesize usageSeconds;
@synthesize srtInfo;
@synthesize videoFileName;
@synthesize thumbnailImageData;
@synthesize sampleRate,languageString;

-(BOOL)save{
    return [OCRSubtitleManage.shared save];
}

+(id)demo{
    OCRHistory *res = [[OCRHistory alloc] init];
    return res;
}

@end
