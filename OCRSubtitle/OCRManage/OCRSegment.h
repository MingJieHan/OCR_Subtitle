//
//  OCRSegment.h
//  LoadText
//
//  Created by jia yu on 2024/10/25.
//

#import <Foundation/Foundation.h>
#import <Vision/Vision.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface OCRSegment : NSObject <NSSecureCoding>
-(id)init NS_UNAVAILABLE;
@property (nonatomic, readonly) NSString *string;
@property (nonatomic, readonly) float confidence;
@property (nonatomic, readonly) float x;
@property (nonatomic, readonly) float y;
@property (nonatomic, readonly) float width;
@property (nonatomic, readonly) float height;
@property (nonatomic) NSTimeInterval t;
@property (nonatomic, readonly) VNFeaturePrintObservation *sourceImageObservation;
@property (nonatomic, readonly) VNFeaturePrintObservation *predImageObservation;

@property (nonatomic, readonly) NSString *subtitleImageFile;
@property (nonatomic, readonly) NSString *subtitleSourceImageFile;

-(id)initWithVNRecognized:(VNRecognizedText *)textObject;
-(NSDictionary *)dictionary;

//-(id)initWithDictionary:(NSDictionary *)dict;
-(BOOL)isInRect:(CGRect)scopeRect;
-(BOOL)removeLastWords:(NSArray <NSString *>*)array;

//返回文字在正中间的便宜率 -0.5 -> 0.5
-(float)centerOffset;
-(VNFeaturePrintObservation *)observePredImage;
-(VNFeaturePrintObservation *)observeSourceImage;

//return 完全相同 0.f -> 1.f 不同，建议 > 0.35时，判定为字幕更换了
-(float)distanceWith:(OCRSegment *)otherSegment;
-(float)sourceDistanceWith:(OCRSegment *)otherSegment;

-(void)buildObservationWithCGImage:(CGImageRef)subtitleCGImage
                        withSource:(CGImageRef)subtitleSourceCGImage
                         saveDebug:(BOOL)savePNGFile
              withImageOrientation:(UIImageOrientation)orientation;
+(void)clearImages;

#pragma mark - Archiver
+(BOOL)archivedSave:(NSMutableArray <OCRSegment *>*)arrayFrom;
+(NSMutableArray <OCRSegment *> *)unarchivedLastSegments;
@end
NS_ASSUME_NONNULL_END
