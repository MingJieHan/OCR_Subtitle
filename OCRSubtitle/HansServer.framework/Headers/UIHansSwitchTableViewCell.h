//
//  UIHansSwitchTableViewCell.h
//  HansServer
//
//  Created by jia yu on 2022/7/29.
//

#import <UIKit/UIKit.h>

@class UIHansSwitchTableViewCell;
typedef void (^UIHansSwitchTableViewCell_Handler) (UIHansSwitchTableViewCell * _Nonnull cell, BOOL on);


@class UIHansSwitchView;
@interface UIHansSwitchTableViewCell : UITableViewCell
@property (nonatomic) UIHansSwitchTableViewCell_Handler _Nullable handler;
@property (nonatomic) BOOL on;
@property (nonatomic) NSString * _Nonnull text;

-(_Nullable id)initWithReuseIdentifier:(NSString * _Nonnull )identifier;

@property (nonatomic) UILabel * _Nonnull textLabel;
@property (nonatomic) UIHansSwitchView * _Nonnull sView;
@end

