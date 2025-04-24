//
//  HansLocal.h
/* test
    NSString *res = [HansLocal dominantLocalWithString:@"于婉茹"];
    NSString *r = [HansLocal mixedDescriptionLocalIdentifier:res];
    NSString *ddd = [HansLocal systemDescriptionLocalIdentifier:res];
    NSString *ccc = [HansLocal targetLocalIdentifierDescription:res];
 */
//
//  Created by MingJie Han on 2024/11/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface HansLocal : NSObject
//return language Code.
+(NSString * _Nullable)languageCodeWithLocalIdentifier:(NSString * _Nonnull)identifier;

//return country code.
+(NSString * _Nullable)countryCodeWithLocalIdentifier:(NSString * _Nonnull)identifier;

//return description with system language.
+(NSString * _Nullable)systemDescriptionLocalIdentifier:(NSString *)identifier;


//return description with target local language.
+(NSString * _Nullable)targetLocalIdentifierDescription:(NSString *)identifier;

//return "Chinese (简体中文)" for "zh-Hans-CN"
//return "English (English)" for "en-CN"
+(NSString * _Nullable)mixedDescriptionLocalIdentifier:(NSString *)identifier;


//return suggest local identifier with domainantString.
//return nil when error.
+(NSString * _Nullable)dominantLocalWithString:(NSString *)dominantString;
@end
NS_ASSUME_NONNULL_END
