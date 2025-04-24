//
//  VerifyAppleStoreReceipt.h
//  SportsHR
//
//  Created by jia yu on 2022/5/8.
//
// https://developer.apple.com/documentation/appstorereceipts

#import <Foundation/Foundation.h>
#import <HansServer/VerifyReceiptResult.h>

typedef void (^VerifyAppleStoreReceipt_completion) (VerifyReceiptResult * _Nonnull result);

NS_ASSUME_NONNULL_BEGIN
@interface VerifyAppleStoreReceipt : NSObject
@property (nonatomic) NSString * _Nonnull specificSharedSecret;
+(VerifyAppleStoreReceipt *)shared;

-(void)verify:(NSData * _Nonnull)data withCompletion:(VerifyAppleStoreReceipt_completion)completion;
@end
NS_ASSUME_NONNULL_END
