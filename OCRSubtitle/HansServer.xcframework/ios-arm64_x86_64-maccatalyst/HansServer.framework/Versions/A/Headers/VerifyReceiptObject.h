//
//  VerifyReceiptObject.h
//  SportsHR
//
//  Created by jia yu on 2022/5/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface VerifyReceiptObject : NSObject
@property (nonatomic,readonly) NSDate *expiredDate;
@property (nonatomic,readonly) NSString *productID;
@property (nonatomic,readonly) NSInteger transactionId;
@property (nonatomic,readonly) NSDate *purchaseDate;
@property (nonatomic,readonly) NSInteger originalTransactionId;
@property (nonatomic,readonly) NSDate *originalPurchaseDate;


-(BOOL)isAvailableFor:(NSArray <NSString *>*)productIDsArray;
@end
NS_ASSUME_NONNULL_END
