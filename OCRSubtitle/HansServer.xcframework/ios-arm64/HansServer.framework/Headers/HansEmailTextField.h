//
//  HansEmailTextField.h
//  HansServer
//
//  Created by jia yu on 2021/7/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HansEmailTextField : UITextField
@property (nonatomic) UIColor *boardColor;
@property (nonatomic) UIColor *boardCurrentColor;
-(BOOL)completed;
@end

NS_ASSUME_NONNULL_END
