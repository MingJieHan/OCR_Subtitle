//
//  NSDateABC.h
//  HansServer
//
//  Created by jia yu on 2025/2/13.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDateHansCategory)
//current local with localTimeZone for NSDate string.
- (NSString *)stringValue;    //return as NSDateFormatterShortStyle
- (NSString *)stringValueWithStyle:(NSDateFormatterStyle)style;
@end

@interface NSString (NSStringHansCategory)
//return string as 02:13 or 5:06:09
+(NSString *)stringWithSecond:(float)second;
@end
