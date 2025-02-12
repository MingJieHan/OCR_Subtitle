//
//  OCRGetImageFromVideo.m
//  LoadText
//
//  Created by jia yu on 2024/10/26.
//

#import "OCRGetImageFromVideo.h"
@interface OCRGetImageFromVideo(){
    AVAsset *ass;
    AVAssetImageGenerator *generator;    
}
@end

@implementation OCRGetImageFromVideo
-(CMTimeValue)durationValue{
    return ass.duration.value;
}

-(id)initWithVideoURL:(NSURL *)videoURL{
    self = [super init];
    if (self){
        if (nil == videoURL){
            NSLog(@"OCRGetImageFromVideo initWithVideoURL: videoURL is nil.");
            return nil;
        }
        ass = [AVAsset assetWithURL:videoURL];
        if (nil == ass){
            NSLog(@"OCRGetImageFromVideo AVAsset video failed.");
            return nil;
        }
        if (0 == ass.duration.value){
            NSLog(@"OCRGetImageFromVideo AVAsset video duration is 0, it is may without AccessingSecurityScopedResource");
            return nil;
        }
        generator = [[AVAssetImageGenerator alloc] initWithAsset:ass];
        if (nil == generator){
            return nil;
        }
        generator.appliesPreferredTrackTransform = YES;
        //AVAssetImageGeneratorApertureModeCleanAperture
        //AVAssetImageGeneratorApertureModeProductionAperture
        //AVAssetImageGeneratorApertureModeEncodedPixels
        generator.apertureMode = AVAssetImageGeneratorApertureModeProductionAperture;
    }
    return self;
}

-(BOOL)getImageWithValue:(int64_t)value withHandler:(void (^)(CGImageRef))completionHandler{
    if (value > ass.duration.value){
        return NO;
    }
    CMTime thumbTime = CMTimeMake(value, ass.duration.timescale);
    if (value > 50){
        generator.requestedTimeToleranceAfter = CMTimeMake(value-50, ass.duration.timescale);
    }
    generator.requestedTimeToleranceBefore = CMTimeMake(value+50, ass.duration.timescale);
    if (@available(iOS 16.0, *)) {
        [generator generateCGImageAsynchronouslyForTime:thumbTime completionHandler:^(CGImageRef  _Nullable image, CMTime actualTime, NSError * _Nullable error) {
            if (error){
                NSLog(@"CGImageAsynchronous failed:%@", error.localizedDescription);
                completionHandler(nil);
                return;
            }
            NSLog(@"%.2f", (float)actualTime.value/(float)actualTime.timescale);
            completionHandler(image);
        }];
    } else {
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [generator copyCGImageAtTime:thumbTime actualTime:&actualTime error:&error];
        NSLog(@"%.2f", (float)actualTime.value/actualTime.timescale);
        completionHandler(image);
    }
    return YES;
}
@end
