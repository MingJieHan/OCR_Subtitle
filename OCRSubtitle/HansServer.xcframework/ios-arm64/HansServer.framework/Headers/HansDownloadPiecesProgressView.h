//
//  UIPiecesProgressView.h
//  mget
//
//  Created by jia yu on 2024/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface HansDownloadPiecesProgressView:UIView
@property (nonatomic) NSArray <NSNumber *>*states;
@property (nonatomic) UIColor *completedColor;
@property (nonatomic) UIColor *failedColor;
@property (nonatomic) UIColor *runningColor;
@property (nonatomic) UIColor *waitingColor;
@property (nonatomic) CGSize blockSize;             //30x30 is default
@property (nonatomic) CGFloat blockCornerRadius;           //defautl is 3.f
@property (nonatomic) UIEdgeInsets blockEdge;       //UIEdgeInsetsMake(5, 10, 10, 15);
@property (nonatomic) CGFloat minimumLineSpacing;       //default is 10.f 行间距
@property (nonatomic) CGFloat minimumInteritemSpacing;   //default is 10.f 列间距
-(id)init NS_UNAVAILABLE;
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

-(id)initWithFrame:(CGRect)frame;
-(void)animatedTo:(NSInteger)index;
@end
NS_ASSUME_NONNULL_END
