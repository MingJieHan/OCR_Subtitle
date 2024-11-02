//
//  OCRSegment.h
//  LoadText
//
//  Created by jia yu on 2024/10/25.
//

#import <Foundation/Foundation.h>
#import <Vision/Vision.h>

NS_ASSUME_NONNULL_BEGIN
@interface OCRSegment : NSObject
-(id)init NS_UNAVAILABLE;
@property (nonatomic, readonly) NSString *string;
@property (nonatomic, readonly) float confidence;
@property (nonatomic, readonly) float x;
@property (nonatomic, readonly) float y;
@property (nonatomic, readonly) float width;
@property (nonatomic, readonly) float height;
@property (nonatomic) NSTimeInterval t;

-(id)initWithVNRecognized:(VNRecognizedText *)textObject;
-(NSDictionary *)dictionary;

-(id)initWithDictionary:(NSDictionary *)dict;
-(BOOL)isInRect:(CGRect)scopeRect;
-(BOOL)removeLastWords:(NSArray <NSString *>*)array;

//返回文字在正中间的便宜率 -0.5 -> 0.5
-(float)centerOffset;
@end
NS_ASSUME_NONNULL_END
