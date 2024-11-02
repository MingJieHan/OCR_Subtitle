//
//  OCRSegment.m
//  LoadText
//
//  Created by jia yu on 2024/10/25.
//

#import "OCRSegment.h"

#define KEY_OCRSegment_Time @"time"
#define KEY_OCRSegment_Confidence @"confidence"
#define KEY_OCRSegment_String @"string"
#define KEY_OCRSegment_X @"x"
#define KEY_OCRSegment_Y @"y"
#define KEY_OCRSegment_Width @"width"
#define KEY_OCRSegment_Height @"height"

@implementation OCRSegment
@synthesize string;
@synthesize confidence;
@synthesize x,y,width,height;
@synthesize t;

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
@end
