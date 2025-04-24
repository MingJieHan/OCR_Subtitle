//
//  HansRequestManage.h
//  iOSWithDjango
//
//  Created by jia yu on 2021/2/20.
//



#import <Foundation/Foundation.h>
typedef void (^HansRequestManager_Complete_Handler)(NSData * _Nullable data, BOOL updated, NSString * _Nullable error);


NS_ASSUME_NONNULL_BEGIN
@interface HansRequestManager : NSObject
@property (nonatomic) NSString *userAgent;               //default is @"Hans WebKit"
@property (nonatomic) BOOL printLog;                     //打印Debug信息，default is NO
+(HansRequestManager *)defaultHansRequestManager;
//request data for urlString
-(NSData *)request:(NSString *)urlString withHandler:(HansRequestManager_Complete_Handler)completeHandler;

//return nil when NO cache
-(NSData *)cached:(NSString *)urlString;


//remove cache for must update url
-(BOOL)removeCacheForUrl:(NSString *)urlString;

//cancel the request immiditeally
-(BOOL)cancelRequestForUrl:(NSString *)urlString;
@end
NS_ASSUME_NONNULL_END



