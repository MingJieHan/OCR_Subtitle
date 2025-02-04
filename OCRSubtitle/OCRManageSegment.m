//
//  OCRManageSegment.m
//  LoadText
//
//  Created by jia yu on 2024/10/25.
//

#import "OCRManageSegment.h"
#include <pthread.h>

static OCRManageSegment *staticOCRManageSegment;
@interface OCRManageSegment(){
    pthread_mutex_t mutex;
    NSMutableArray <OCRSegment *>*segments;
    NSMutableArray *buffers;
}

@end


@implementation OCRManageSegment

-(id)init{
    self = [super init];
    if (self){
        pthread_mutex_init(&mutex, nil);
        segments = [[NSMutableArray alloc] init];
    }
    return self;
}

+(OCRManageSegment *)shared{
    if (nil == staticOCRManageSegment){
        staticOCRManageSegment = [[OCRManageSegment alloc] init];
    }
    return staticOCRManageSegment;
}

-(BOOL)saveSegments{
    BOOL success = [OCRSegment archivedSave:segments];
    return success;
}

-(BOOL)loadSegments{
    segments = [OCRSegment unarchivedLastSegments];
    return YES;
}

-(void)add:(OCRSegment *)segment withSubtitleImage:(CGImageRef)subtitleCGImage withSource:(CGImageRef)subtitleSourceCGImage{
    pthread_mutex_lock(&mutex);
    [segment buildObservationWithCGImage:subtitleCGImage withSource:subtitleSourceCGImage];
    [segments addObject:segment];
    pthread_mutex_unlock(&mutex);
}

-(void)clear{
    pthread_mutex_lock(&mutex);
    [segments removeAllObjects];
    [OCRSegment clearImages];
    pthread_mutex_unlock(&mutex);
}

//return 00:00:18,032
-(NSString *)SRTtimeFormat:(float)fromSeconds{
    NSInteger hours,minutes,seconds;
    seconds = (NSInteger)fromSeconds;
    NSInteger lessSecond = 1000 * (fromSeconds - seconds);
    minutes = seconds/60;
    hours = minutes/60;
    minutes = minutes%60;
    seconds = seconds%60;
    return [[NSString alloc] initWithFormat:@"%02ld:%02ld:%02ld,%03ld", hours,minutes,seconds,lessSecond];
}

-(NSString *)exportSRTPartFrom:(OCRSegment *)beginSeg
                            to:(OCRSegment * _Nullable)endSeg
                     withIndex:(NSInteger)index
                     tolerance:(NSUInteger)tolerance{
    if (nil == beginSeg){
        NSLog(@"exportSRTPartFrom beginSeg can NOT nil.");
        return @"";
    }
    
    if (nil != endSeg && endSeg.t <= beginSeg.t){
        NSLog(@"Warning: time of endseg less than begin seg.");
    }
    
    NSMutableString *res = [[NSMutableString alloc] init];
    [res appendFormat:@"%ld\n", index];
    
    float beginT = beginSeg.t - tolerance/1000.f;
    if (beginT < 0.f){
        beginT = 0.f;
    }
    float endT = beginSeg.t + tolerance/1000.f;
    if (nil != endSeg){
        endT = endSeg.t + tolerance/1000.f;
    }
    [res appendFormat:@"%@ --> %@\n",
     [self SRTtimeFormat:beginT],
     [self SRTtimeFormat:endT]];

    NSString *str = beginSeg.string;
    [res appendString:str];
    return res;
}

//OCR 特别的判定字符串相同函数
//[seg.string isEqualToString:firstSeg.string]
-(BOOL)sameOCRString:(NSString *)str1 withStr2:(NSString *)str2{
    if ([str1 isEqualToString:str2]){
        return YES;
    }
    NSString *s1 = [str1 stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *s2 = [str2 stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [[s1 lowercaseString] isEqualToString:[s2 lowercaseString]];
}

-(BOOL)makeSRT:(NSString *)srtFile withTolerance:(NSUInteger)tolerance{
    
    //排序
    [segments sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        OCRSegment *seg1 = obj1;
        OCRSegment *seg2 = obj2;
        if (seg1.t > seg2.t){
            return NSOrderedDescending;
        }
        if (seg1.t == seg2.t){
            return NSOrderedSame;
        }
        return NSOrderedAscending;
    }];
        
    //检查在相同的时间点，是否存在多个字幕
    NSMutableArray *removeArray = [[NSMutableArray alloc] init];
    OCRSegment *previousSeg = nil;
    for (OCRSegment *seg in segments){
        if (nil == previousSeg){
            previousSeg = seg;
            continue;
        }
        if (seg.t == previousSeg.t){
            NSLog(@"Warning: more than 1 seg show in same time.");
            [removeArray addObject:previousSeg];
        }
        previousSeg = seg;
    }
    if (removeArray.count > 0){
        NSLog(@"remove %ld items because same time.", removeArray.count);
        [segments removeObjectsInArray:removeArray];
    }
    NSLog(@"%ld items after remove same time item.", segments.count);
    
    NSMutableString *result = [[NSMutableString alloc] init];
    NSInteger index = 1;
    
    OCRSegment *firstSeg = nil;
    OCRSegment *lastSeg = nil;
    for (OCRSegment *seg in segments){
        if (nil == firstSeg){
            firstSeg = seg;
            continue;
        }

        if ([self sameOCRString:seg.string withStr2:firstSeg.string]){
            //遇到了相同字符串的
            lastSeg = seg;
            continue;
        }
        
        float distance = [seg distanceWith:lastSeg];
        float source_distance = [seg sourceDistanceWith:lastSeg];
        if (distance < 0.3f){
            NSLog(@"处理后 图片相似性判定为相同字符串:\n%@\n%@", seg.string, lastSeg.string);
            //判定为相同字符串的
            lastSeg = seg;
            continue;
        }

        if (source_distance < 0.3f){
            NSLog(@"原图片相似性判定为相同字符串:\n%@\n%@", seg.string, lastSeg.string);
            //判定为相同字符串的
            lastSeg = seg;
            continue;
        }
        
        //遇到不同字符串输出
        NSString *srtString = [self exportSRTPartFrom:firstSeg to:lastSeg withIndex:index tolerance:tolerance];
        [result appendString:srtString];
        [result appendString:@"\n\n"];
        index ++;
        firstSeg = seg;
        lastSeg = nil;
    }
    
    //append write last seg
    NSString *lastSRTString = [self exportSRTPartFrom:firstSeg to:lastSeg withIndex:index tolerance:tolerance];
    [result appendString:lastSRTString];
    [result appendString:@"\n\n"];
    
    
    NSLog(@"Res:%@", result);
    NSError *error = nil;
    BOOL success = [result writeToFile:srtFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error){
        NSLog(@"Write srt file error:%@", error.localizedDescription);
        return NO;
    }
    return success;
}

-(BOOL)filterWithScopeRect:(CGRect)scopeRect{
    NSLog(@"%ld item will worked.", segments.count);
    NSMutableArray *removeArray = [[NSMutableArray alloc] init];
    for (OCRSegment *seg in segments) {
        if ([seg isInRect:scopeRect]){
            NSLog(@"keep this seg.");
        }else{
            [removeArray addObject:seg];
        }
    }
    if (removeArray.count > 0){
        [segments removeObjectsInArray:removeArray];
    }
    NSLog(@"%ld items after remove outside scope rect.", segments.count);
    return YES;
}
-(BOOL)filterWithTail:(NSArray <NSString *>*)removeArray{
    for (OCRSegment *seg in segments){
        [seg removeLastWords:removeArray];
    }
    return YES;
}

-(void)testString:(NSString *)testString{
    for (OCRSegment *seg in segments){
        if ([seg.string containsString:testString]){
            NSLog(@"Debug for %@", testString);
        }
    }
}

-(NSUInteger)appendSample:(CMSampleBufferRef)sample{
    pthread_mutex_lock(&mutex);
    if (nil == buffers){
        buffers = [[NSMutableArray alloc] init];
    }
    SampleObject *o = [[SampleObject alloc] initWithSample:sample];
    [buffers addObject:o];
    NSUInteger count = buffers.count;
    pthread_mutex_unlock(&mutex);
    return count;
}

-(SampleObject * _Nullable)getWaitingSample{
    pthread_mutex_lock(&mutex);
    SampleObject *res = buffers.firstObject;
    [buffers removeObject:res];
    pthread_mutex_unlock(&mutex);
    return res;
}

-(NSUInteger)numOfCurrentSamples{
    pthread_mutex_lock(&mutex);
    NSUInteger count = buffers.count;
    pthread_mutex_unlock(&mutex);
    return count;
}
@end
