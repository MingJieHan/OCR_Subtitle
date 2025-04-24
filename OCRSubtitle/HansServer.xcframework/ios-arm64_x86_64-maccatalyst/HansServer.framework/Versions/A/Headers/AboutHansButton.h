//
//  AboutHansButton.h
//  MagicCut
//
//  Created by Hans on 2025/4/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface AboutHansButton : UIButton
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
-(id)initWithFrame:(CGRect)frame primaryAction:(UIAction * _Nullable )primaryAction NS_UNAVAILABLE;

@property (nonatomic) NSBundle *aboutHansBundle;
@property (nonatomic) NSBundle *bundleInFramework;
@property (nonatomic, readonly) UIBarButtonItem *barButton;
-(id)init;
+(AboutHansButton *)shareButton;

-(NSString *)appleID;
-(NSString *)onlineHelp;
-(NSString *)copyRights;
-(NSArray <NSDictionary *>*)hrefs;
@end
NS_ASSUME_NONNULL_END
