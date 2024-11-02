//
//  HansRefresher.h
//  HansServer
//
//  Created by jia yu on 2024/2/14.
//

#import <UIKit/UIKit.h>
typedef void (^HansRefresher_Completion) (BOOL success);

NS_ASSUME_NONNULL_BEGIN
@interface HansRefresher:UIControl
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)init NS_UNAVAILABLE;
-(id)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
-(id)initWithFrame:(CGRect)frame primaryAction:(UIAction * __nullable )primaryAction NS_UNAVAILABLE;



-(void)endRefreshing;
-(id)initWithBlock:(HansRefresher_Completion __nullable )completion;
@end
NS_ASSUME_NONNULL_END
