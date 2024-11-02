//
//  SampleObject.m
//  LoadText
//
//  Created by jia yu on 2024/10/31.
//

#import "SampleObject.h"
#import <CoreImage/CoreImage.h>
@interface SampleObject(){
    CMSampleBufferRef buffer;
    CMTime t;
    CVImageBufferRef imageBuffer;
}
@end

@implementation SampleObject
-(id)initWithSample:(CMSampleBufferRef)sample{
    self = [super init];
    if (self){
        buffer = sample;
        imageBuffer = CMSampleBufferGetImageBuffer(sample);
        t = CMSampleBufferGetPresentationTimeStamp(sample);
    }
    return self;
}

-(CGImageRef)createCGImage{
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CIImage *c = [CIImage imageWithCVImageBuffer:imageBuffer];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:c fromRect:CGRectMake(0.f, 0.f, width, height)];
    return cgImage;
}

-(float)imageTime{
    return (float)t.value/t.timescale;
}

-(void)dealloc{
    CFRelease(buffer);
    buffer = NULL;
}
@end
