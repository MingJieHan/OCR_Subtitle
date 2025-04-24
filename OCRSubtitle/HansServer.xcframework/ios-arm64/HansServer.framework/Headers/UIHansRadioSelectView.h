//
//  UIHansRadioSelectTableView.h
//  HansServer
//
//  Created by jia yu on 2022/7/31.
//

#import <UIKit/UIKit.h>

@class UIHansRadioSelectView;
typedef void (^UIHansRadioSelectTableView_Handler) (UIHansRadioSelectView * _Nonnull view, NSString * _Nonnull selectedString, NSUInteger selectedIndex);

@interface UIHansRadioSelectView : UIView
@property (nonatomic) UILabel * _Nonnull titleLabel;
@property (nonatomic) UIHansRadioSelectTableView_Handler _Nullable handler;

-(id _Nullable )initWithFrame:(CGRect)frame
             title:(NSString * _Nonnull )title
             items:(NSArray <NSString *>* _Nonnull )items
                     selected:(NSUInteger)selectedIndex;


@end
