//
//  OCRSegment.m
//  LoadText
//
//  Created by jia yu on 2024/10/25.
//

#import "OCRSegment.h"
#define LAST_SEGMENTS_FILE @"lastSegments.dat"

#define KEY_OCRSegment_Time @"time"
#define KEY_OCRSegment_Confidence @"confidence"
#define KEY_OCRSegment_String @"string"
#define KEY_OCRSegment_X @"x"
#define KEY_OCRSegment_Y @"y"
#define KEY_OCRSegment_Width @"width"
#define KEY_OCRSegment_Height @"height"
#define KEY_OCRSegment_SourceImageFile @"sourceImageFile"
#define KEY_SourceImage_Observation @"SourceObservation"

@implementation OCRSegment
@synthesize string;
@synthesize confidence;
@synthesize x,y,width,height;
@synthesize t;
@synthesize fingerPrintImageFile;
@synthesize fingerPrintObservation;

+ (BOOL)supportsSecureCoding {
    return TRUE;
}

-(id)initWithVNRecognized:(VNRecognizedText *)textObject{
    self = [super init];
    if (self){
        string = textObject.string;
        if ([string isEqualToString:@"可以预览一下"]){
            NSLog(@"debug");
        }
        confidence = textObject.confidence;
        NSError *boundError = nil;
        VNRectangleObservation *observer = [textObject boundingBoxForRange:NSMakeRange(0, string.length) error:&boundError];
        x = observer.boundingBox.origin.x;
        y = observer.boundingBox.origin.y;
        width = observer.boundingBox.size.width;
        height = observer.boundingBox.size.height;
    }
    return self;
}

-(NSDictionary *)dictionary{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[NSNumber numberWithFloat:x] forKey:KEY_OCRSegment_X];
    [dict setValue:[NSNumber numberWithFloat:y] forKey:KEY_OCRSegment_Y];
    [dict setValue:[NSNumber numberWithFloat:width] forKey:KEY_OCRSegment_Width];
    [dict setValue:[NSNumber numberWithFloat:height] forKey:KEY_OCRSegment_Height];
    [dict setValue:string forKey:KEY_OCRSegment_String];
    [dict setValue:[NSNumber numberWithFloat:confidence] forKey:KEY_OCRSegment_Confidence];
    [dict setValue:[NSNumber numberWithFloat:t] forKey:KEY_OCRSegment_Time];
    [dict setValue:fingerPrintImageFile forKey:KEY_OCRSegment_SourceImageFile];
    return dict;
}

-(id)initWithDictionary:(NSDictionary *)dict{
    self = [super init];
    if (self){
        string = [dict valueForKey:KEY_OCRSegment_String];
        confidence = [[dict valueForKey:KEY_OCRSegment_Confidence] floatValue];
        t = [[dict valueForKey:KEY_OCRSegment_Time] floatValue];
        x = [[dict valueForKey:KEY_OCRSegment_X] floatValue];
        y = [[dict valueForKey:KEY_OCRSegment_Y] floatValue];
        width = [[dict valueForKey:KEY_OCRSegment_Width] floatValue];
        height = [[dict valueForKey:KEY_OCRSegment_Height] floatValue];
        fingerPrintImageFile = [dict valueForKey:KEY_OCRSegment_SourceImageFile];
    }
    return self;
}

-(BOOL)isInRect:(CGRect)scopeRect{
    CGRect locationRect = CGRectMake(x, y, width, height);
    BOOL contain = CGRectContainsRect(scopeRect, locationRect);
//    if ([string containsString:@"可以一目"]){
//        NSLog(@"debug");
//    }
    return contain;
}

-(BOOL)removeLastWords:(NSArray <NSString *>*)array{
    NSString *lastWord = [string substringFromIndex:string.length-1];
    for (NSString *target in array){
        if ([target isEqualToString:lastWord]){
            string = [string substringToIndex:string.length-1];
            return YES;
        }
    }
    return NO;
}

-(float)centerOffset{
    float res = x - (1.f - width)/2.f;
    return res;
}

-(void)buildObservationWithImage:(CGImageRef)fingerPrintImage andOrient:(UIImageOrientation)orientation{
    fingerPrintObservation = [self observeWithImage:fingerPrintImage];
    return;
}

+(void)cleanDebugImages{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:@"images"];
    NSArray *files = [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:nil];
    for (NSString *file in files){
        [NSFileManager.defaultManager removeItemAtPath:[path stringByAppendingPathComponent:file] error:nil];
    }
    return;
}

-(VNFeaturePrintObservation *)observeWithImage:(CGImageRef)cgImage{
    NSDictionary *opt = [NSDictionary dictionary];
    VNImageRequestHandler *handler2 = [[VNImageRequestHandler alloc] initWithCGImage:cgImage options:opt];
    VNGenerateImageFeaturePrintRequest *request2 = [[VNGenerateImageFeaturePrintRequest alloc] init];
    NSError *error = nil;
    BOOL success = [handler2 performRequests:@[request2] error:&error];
    if (NO == success){
        return nil;
    }
    VNFeaturePrintObservation *obs = request2.results.firstObject;
    return obs;
}

-(VNFeaturePrintObservation *)observefingerPrint{
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:fingerPrintImageFile];
    return [self observeWithImage:image.CGImage];
}

-(float)fingerPrintDistanceWith:(OCRSegment *)otherSegment{
    float distance = 1.f;
    [fingerPrintObservation computeDistance:&distance toFeaturePrintObservation:otherSegment.    fingerPrintObservation error:nil];
    return distance;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@", self.string];
}

#pragma mark - NSSecureCoding
- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeObject:string forKey:KEY_OCRSegment_String];
    [coder encodeFloat:confidence forKey:KEY_OCRSegment_Confidence];
    [coder encodeFloat:t forKey:KEY_OCRSegment_Time];
    [coder encodeFloat:x forKey:KEY_OCRSegment_X];
    [coder encodeFloat:y forKey:KEY_OCRSegment_Y];
    [coder encodeFloat:width forKey:KEY_OCRSegment_Width];
    [coder encodeFloat:height forKey:KEY_OCRSegment_Height];
    [coder encodeObject:fingerPrintObservation forKey:KEY_SourceImage_Observation];
    [coder encodeObject:fingerPrintImageFile forKey:KEY_OCRSegment_SourceImageFile];
    return;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    self = [super init];
    if (self){
        string = [coder decodePropertyListForKey:KEY_OCRSegment_String];
        confidence = [coder decodeFloatForKey:KEY_OCRSegment_Confidence];
        t = [coder decodeFloatForKey:KEY_OCRSegment_Time];
        x = [coder decodeFloatForKey:KEY_OCRSegment_X];
        y = [coder decodeFloatForKey:KEY_OCRSegment_Y];
        width = [coder decodeFloatForKey:KEY_OCRSegment_Width];
        height = [coder decodeFloatForKey:KEY_OCRSegment_Height];
        fingerPrintObservation = [coder decodeObjectForKey:KEY_SourceImage_Observation];
        fingerPrintImageFile = [coder decodeObjectForKey:KEY_OCRSegment_SourceImageFile];
    }
    return self;
}

#pragma mark - Archiver
+(BOOL)archivedSave:(NSMutableArray <OCRSegment *>*)arrayFrom{
    NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    file = [file stringByAppendingPathComponent:LAST_SEGMENTS_FILE];

    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arrayFrom requiringSecureCoding:YES error:&error];
    if (error){
        NSLog(@"archivedArray error:%@", error.localizedDescription);
        return NO;
    }
    
    if ([NSFileManager.defaultManager fileExistsAtPath:file]){
        [NSFileManager.defaultManager removeItemAtPath:file error:&error];
        if (error){
            NSLog(@"archivedArray remove exist data file error:%@", error.localizedDescription);
        }
    }
    return [data writeToFile:file atomically:YES];
}

+(NSMutableArray <OCRSegment *>*)unarchivedLastSegments{
    NSString *file = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    file = [file stringByAppendingPathComponent:LAST_SEGMENTS_FILE];
    NSData *data = [[NSData alloc] initWithContentsOfFile:file];
    if (nil == data){
        return nil;
    }
    NSError *error = nil;
    NSSet *set = [NSSet setWithArray:@[[NSMutableArray class], [OCRSegment class], [VNFeaturePrintObservation class]]];
    NSMutableArray *resultArray = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:data error:&error];
    if (error){
        NSLog(@"Unarchived error:%@", error.localizedDescription);
    }
    return resultArray;
}
@end
