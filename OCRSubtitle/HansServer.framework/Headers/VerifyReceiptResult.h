//
//  VerifyReceiptResult.h
//  SportsHR
//
//  Created by jia yu on 2022/5/9.
//

#import <Foundation/Foundation.h>
#import <HansServer/VerifyReceiptObject.h>

// https://developer.apple.com/documentation/appstorereceipts/status
typedef NS_ENUM(int, AppReceiptStatus) {
    AppReceiptStatus_OK = 0,
    AppReceiptStatus_NOT_POST = 21000,      //The request to the App Store was not made using the HTTP POST request method.
    AppReceiptStatus_No_Longer = 21001,     //This status code is no longer sent by the App Store.
    AppReceiptStatus_ISSUE = 21002,     //The data in the receipt-data property was malformed or the service experienced a temporary issue. Try again.
    AppReceiptStatus_Unauthenticated = 21003,  //The receipt could not be authenticated.
    AppReceiptStatus_Shared_Secret_Failed = 21004,  //The shared secret you provided does not match the shared secret on file for your account.
    AppReceiptStatus_Server_Unable = 21005,  //The receipt server was temporarily unable to provide the receipt. Try again.
    AppReceiptStatus_Expired = 21006,  //This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response. Only returned for iOS 6-style transaction receipts for auto-renewable subscriptions.
    AppReceiptStatus_Test = 21007,  //This receipt is from the test environment, but it was sent to the production environment for verification.
    AppReceiptStatus_Production = 21008,  //This receipt is from the production environment, but it was sent to the test environment for verification.
    AppReceiptStatus_Internal_Error = 21009,  //Internal data access error. Try again later.
    AppReceiptStatus_No_User = 21010  //The user account cannot be found or has been deleted.
};

typedef NS_ENUM(int, AppReceiptEnvironment) {
    AppReceiptEnvironment_Sandbox = 1,
    AppReceiptEnvironment_aaa = 2
};


NS_ASSUME_NONNULL_BEGIN
@interface VerifyReceiptResult : NSObject
@property (nonatomic,readonly) AppReceiptStatus status;
@property (nonatomic,readonly) AppReceiptEnvironment environment;
@property (nonatomic,readonly) NSString *auto_renew_product_id;
@property (nonatomic,readonly) BOOL auto_renew_status;
@property (nonatomic,readonly) NSString *original_transaction_id;
@property (nonatomic,readonly) NSString *product_id;
@property (nonatomic,readonly) NSArray <VerifyReceiptObject *>*latest_receipt;

-(BOOL)isAvailableFor:(NSArray <NSString *>*)productIDsArray;
@end
NS_ASSUME_NONNULL_END
