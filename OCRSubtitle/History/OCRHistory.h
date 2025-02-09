//
//  OCRHistory.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN
@interface OCRHistory : NSManagedObject
@property (nonatomic) NSString *file;
@property (nonatomic) NSDate *completedDate;
@property (nonatomic) float usageSeconds;

@property (nonatomic) NSString *srtInfo;
@property (nonatomic) NSString *videoFileName;
@property (nonatomic) NSData *thumbnailImageData;
@property (nonatomic) float sampleRate;
@property (nonatomic) NSString *languageString;
-(BOOL)save;

+(id)demo;
@end
NS_ASSUME_NONNULL_END
