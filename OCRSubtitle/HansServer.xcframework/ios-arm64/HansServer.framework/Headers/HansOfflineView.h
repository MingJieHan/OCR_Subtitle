//
//  HansOfflineView.h
//  HansServer
//
//  Created by jia yu on 2024/2/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface HansOfflineView : UIView
@property (nonatomic,readonly) UIImageView *imageView;
@property (nonatomic,readonly) UILabel *titleLabel;
@property (nonatomic,readonly) UILabel *textLabel;

-(id)init NS_UNAVAILABLE;
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

//Warning default alpha is 0.
-(id)initWithFrame:(CGRect)frame;
@end
NS_ASSUME_NONNULL_END
