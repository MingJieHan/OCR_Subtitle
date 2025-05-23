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

//是否检查字幕居中，开启后，丢弃不居中的字幕。这样做可以提高准确性，但要求字幕生成市，必须选择字幕居中。
@property (nonatomic) BOOL checkSubtitleCenter;

//开启调试模式，此模式下速度会慢一些，但会存储过程中的文件，如提取文字的局部图片等
@property (nonatomic) BOOL debugMode;   //default is NO

-(CGRect)regionOfInterest;      //从左下角开始，与OC其他位置计算不同
-(float)minimumFrameSpacing;    //Unit is S
-(NSUInteger)tolerance;         //SRT 时间输出的准许差 Unit is mS
-(NSString *)languageString;

+(id)default_1Setting;
+(id)default_2Setting;

-(BOOL)save;
-(void)initDatas;
@end
NS_ASSUME_NONNULL_END
