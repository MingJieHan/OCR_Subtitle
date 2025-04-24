//
//  UIHansTableViewFooterView.h
//  HansServer
//
//  Created by jia yu on 2022/8/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIHansTableViewFooterView : UIView
@property (nonatomic) UILabel *label;

+(CGFloat)heightFor:(NSString *)string width:(float)width;

-(id)initWithString:(NSString *)string width:(float)width;
@end
NS_ASSUME_NONNULL_END
