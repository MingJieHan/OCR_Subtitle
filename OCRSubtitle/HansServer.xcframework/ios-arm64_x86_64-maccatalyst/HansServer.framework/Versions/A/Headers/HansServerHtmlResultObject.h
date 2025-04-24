//
//  HansServerHtmlResultObject.h
//  HansServer
//
//  Created by jia yu on 2021/7/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface HansServerHtmlResultObject:NSObject
@property (nonatomic,readonly) BOOL success;
@property (nonatomic,readonly) NSString * _Nullable errString;
@property (nonatomic,readonly) NSArray * _Nullable resultsArray;
@property (nonatomic,readonly) NSString * _Nullable moreResultsURL;
@property (nonatomic,readonly) NSString * _Nullable resultString;
-(id)initWithHtml:(NSString *)html;
@end
NS_ASSUME_NONNULL_END
