//
//  HansCache.h
//

#import <Foundation/Foundation.h>

//#import "HansCacheResult.h"

NS_ASSUME_NONNULL_BEGIN
@class HansCacheResult;
@interface HansCache : NSObject
+(HansCache *)shareHansCache;

//remove all cached data
-(BOOL)clean;

//remove tmp dir only.
-(BOOL)cleanTemporaryDirectory;

//remove the data for key
-(BOOL)removeCacheForKey:(NSString *)key;

//return bytes
-(long long)cacheSize;

//return size with String
-(NSString *)cacheSizeString;

//return data for the key
-(HansCacheResult * _Nullable )loadDataForKey:(NSString * _Nonnull)key;

//save data into cache
-(BOOL)saveDataForKey:(NSString * _Nonnull)key data:(NSData * _Nonnull)data etag:(NSString *)etag modified:(NSString *)modified expire:(NSInteger)seconds;

//Refresh cached data expire time.
-(BOOL)refreshExpire:(NSInteger)seconds forKey:(NSString * _Nonnull)key;
@end
NS_ASSUME_NONNULL_END
