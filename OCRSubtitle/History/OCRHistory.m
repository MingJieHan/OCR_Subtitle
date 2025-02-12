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

-(NSString *)reWriteSRTInfo{
    if (nil == self.srtInfo || 0 == self.srtInfo.length){
        NSLog(@"SRT Info is empty.");
        return nil;
    }
    NSString *fullPathFile = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", self.file];
    if ([NSFileManager.defaultManager fileExistsAtPath:fullPathFile]){
        [NSFileManager.defaultManager removeItemAtPath:fullPathFile error:nil];
    }
    NSError *error = nil;
    BOOL success = [self.srtInfo writeToFile:fullPathFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error || NO == success){
        NSLog(@"Warning: Write SRT String into file failed.");
        return nil;
    }
    return fullPathFile;
}
@end
