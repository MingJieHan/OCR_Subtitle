//
//  SCRSetting.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/6.
//

#import <AVKit/AVKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN
@interface OCRSetting : NSManagedObject
@property (nonatomic) NSDate *createDate;
@property (nonatomic) NSDate *modifieDate;
@property (nonatomic) NSDate *useDate;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *note;
@property (nonatomic) UIImage * _Nullable image;
@property (nonatomic) NSNumber *videoWidth;
@property (nonatomic) NSNumber *videoHeight;
@property (nonatomic) NSArray * _Nullable subtitleLanguages;
@property (nonatomic) UIColor * _Nullable textColor;
@property (nonatomic) UIColor * _Nullable borderColor;
@property (nonatomic) float passTopRate;    //0.f - 1.f;   视频上部略过的高度占视频总高的比例
@property (nonatomic) float heightRate;     //0.2;  字幕最大高度
@property (nonatomic) int rate;             //每秒取图片的数量

-(CGRect)regionOfInterest;      //从左下角开始，与OC其他位置计算不同
-(float)minimumFrameSpacing;    //Unit is S
-(NSUInteger)tolerance;         //SRT 时间输出的准许差 Unit is mS
-(NSString *)languageString;

+(id)wanruSetting;
+(id)demo1Setting;

-(BOOL)save;
-(void)initDatas;
@end
NS_ASSUME_NONNULL_END
