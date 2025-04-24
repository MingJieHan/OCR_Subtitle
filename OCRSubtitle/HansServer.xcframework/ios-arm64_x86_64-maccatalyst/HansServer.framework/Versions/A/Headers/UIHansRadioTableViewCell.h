//
//  UIHansRadioTableViewCell.h
//  HansServer
//
//  Created by jia yu on 2022/7/29.
//

#import <UIKit/UIKit.h>

@class UIHansRadioTableViewCell;
typedef void (^UIHansRadioTableViewCell_Handler) (UIHansRadioTableViewCell * _Nonnull cell, BOOL checked);

NS_ASSUME_NONNULL_BEGIN
@interface UIHansRadioTableViewCell : UITableViewCell
@property (nonatomic) UIHansRadioTableViewCell_Handler _Nullable handler;
@property (nonatomic) BOOL checked;
@property (nonatomic) NSString * _Nonnull text;

-(id)initWithReuseIdentifier:(NSString *)identifier;

@property (nonatomic) UILabel *textLabel;
@property (nonatomic) UIImageView *stateImageView;
@end
NS_ASSUME_NONNULL_END
