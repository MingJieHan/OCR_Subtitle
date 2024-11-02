//
//  UIHansMutableSelectTableView.h
//  HansServer
//
//  Created by jia yu on 2022/7/31.
//

#import <UIKit/UIKit.h>

@class UIHansMutableSelectView;
typedef void (^UIHansMutableSelectTableView_Handler) (UIHansMutableSelectView * _Nonnull view,
                                                      NSString * _Nonnull item,
                                                      BOOL checked);

@interface UIHansMutableSelectView : UIView
@property (nonatomic) UILabel * _Nonnull titleLabel;
@property (nonatomic) UIHansMutableSelectTableView_Handler _Nullable handler;

-(id _Nullable )initWithFrame:(CGRect)frame
             title:(NSString * _Nonnull )title
             items:(NSArray <NSString *>* _Nonnull )items
            onOffs:(NSArray <NSNumber *>* _Nonnull )onOffs;
@end
