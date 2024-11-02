//
//  NSDjangoUTCConvert.h
//  iOSWithDjango
//
//  Created by jia yu on 2020/12/26.
//

#import <Foundation/Foundation.h>
/*
 convert data string from server to local date time.
 */

NS_ASSUME_NONNULL_BEGIN
@interface NSDjangoUTCConvert : NSObject
+(NSDate *)djangoDateString:(NSString *)dateString;
@end
NS_ASSUME_NONNULL_END
