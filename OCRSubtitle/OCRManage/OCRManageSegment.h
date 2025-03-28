//
//  OCRManageSegment.h
//  LoadText
//
//  Created by jia yu on 2024/10/25.
//

#import <Foundation/Foundation.h>
#import "OCRSegment.h"
#import "SampleObject.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface OCRManageSegment : NSObject
+(OCRManageSegment *)shared;

-(BOOL)saveSegments;
-(BOOL)loadSegments;

-(NSUInteger)numOfSegments;
-(void)addSegment:(OCRSegment *)segment withfingerPrintImage:(CGImageRef)fingerPrintImage withImageOrientation:(UIImageOrientation)orientation;
-(void)clear;

//Tolerance 字幕准许的差
-(BOOL)makeSRT:(NSString *)srtFile withTolerance:(NSUInteger)step;

-(BOOL)filterWithScopeRect:(CGRect)scopeRect;
-(BOOL)filterWithTail:(NSArray <NSString *>*)removeArray;
-(void)testString:(NSString *)testString;


//Mutex thread, return object in line
-(NSUInteger)appendSample:(CMSampleBufferRef)ciImage withTransform:(CGAffineTransform)transform;
//Mutex thread
-(SampleObject * _Nullable)getWaitingSample;
//Mutex thread
-(NSUInteger)numOfCurrentSamples;
@end
NS_ASSUME_NONNULL_END
