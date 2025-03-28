//
//  OCRSubtitleManage.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/8.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@class OCRHistory;
@class OCRSetting;

NS_ASSUME_NONNULL_BEGIN
@interface OCRSubtitleManage : NSObject
+(OCRSubtitleManage *)shared;

-(NSMutableArray *)existHistorys;

-(OCRHistory *)createOCRResult;

-(NSMutableArray *)existSettings;
-(OCRSetting *)createOCRSetting;

-(BOOL)save;
-(BOOL)removeItem:(NSManagedObject *)item;

@end
NS_ASSUME_NONNULL_END
