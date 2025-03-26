//
//  OCRGetBuffersFromVideo.m
//  LoadText
//
//  Created by jia yu on 2024/10/31.
//

#import "OCRGetSampleBuffersFromVideo.h"
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>
#import "OCRSubtitleManage.h"

@interface OCRGetSampleBuffersFromVideo(){
    AVAssetReader *assetReader;
    AVAssetReaderTrackOutput *readerVideoTrackOutput;
    float begin;
    float end;
}
@end

@implementation OCRGetSampleBuffersFromVideo
@synthesize duration;
@synthesize timeRange;
@synthesize ready;
@synthesize videoSize;
@synthesize videoTransform;

-(id)initWithVideoURL:(NSURL *)videoURL{
    return [[OCRGetSampleBuffersFromVideo alloc] initWithVideoURL:videoURL withBegin:0.f withEnd:99999999.f];
}

-(id)initWithVideoURL:(NSURL *)videoURL withBegin:(float)_start withEnd:(float)_end{
    self = [super init];
    if (self){
        if (nil == videoURL){
            return nil;
        }
        begin = _start;
        end = _end;
        ready = NO;
        
        NSDictionary* options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:(id)AVURLAssetPreferPreciseDurationAndTimingKey];
        // 将url对应的内容载入到url资产中
        AVURLAsset* inputAsset = [[AVURLAsset alloc] initWithURL:videoURL options:options];
        duration = inputAsset.duration;
        
        AVAssetTrack *videoTrack = [inputAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        videoTransform = videoTrack.preferredTransform;
        videoSize = videoTrack.naturalSize;
        
        __weak typeof(self) weakSelf = self;
        [inputAsset loadValuesAsynchronouslyForKeys:[NSArray arrayWithObject:@"tracker"] completionHandler:^{
            // 异步载入完毕之后进行判断
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError* error = nil;
                AVKeyValueStatus valueStatus = [inputAsset statusOfValueForKey:@"tracker" error:&error];
                if (valueStatus != AVKeyValueStatusLoaded) {
                    NSLog(@"load failed %@", error);
                    return;
                }
                [weakSelf processWithAsset:inputAsset];
            });
        }];
    }
    return self;
}

//return nil when finish.
- (CMSampleBufferRef)copyNextBuffer {
    if (nil == assetReader){
        return nil;
    }
    CMSampleBufferRef sampleBufferRef = nil;
    if (readerVideoTrackOutput) {
        sampleBufferRef = [readerVideoTrackOutput copyNextSampleBuffer];
    }
    
    if (assetReader && assetReader.status == AVAssetReaderStatusCompleted) {
        assetReader = nil;
        readerVideoTrackOutput = nil;
    }
    return sampleBufferRef;
}

- (void)processWithAsset:(AVAsset *)asset{
    NSError* error = nil;
    // 通过url资产创建资产reader
    assetReader = [AVAssetReader assetReaderWithAsset:asset error:&error];
    
    // 由于是要每一帧的进行读取并且是全部读取，则需要设置为kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
    NSDictionary* outputSettings = [NSDictionary dictionaryWithObject:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    // 创建资产reader追踪
    // [asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] 返回对应的track
    readerVideoTrackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] outputSettings:outputSettings];
    
    // 将追踪器加入到资产reader
    [assetReader addOutput:readerVideoTrackOutput];
    
    CMTime startTime = CMTimeMake(begin * asset.duration.timescale, asset.duration.timescale);
    CMTime duration = CMTimeMake((end - begin) * asset.duration.timescale, asset.duration.timescale);
    timeRange = CMTimeRangeMake(startTime, duration);
    assetReader.timeRange = timeRange;
    
    // 开始读
    if (![assetReader startReading]) {
        NSLog(@"error startreading %@", asset);
    }
    ready = YES;
}

-(CGSize)sizeAfterOrientation{
    UIImageOrientation oriention = [OCRSubtitleManage imageOrientionFromCGAffineTransform:videoTransform];
    if (oriention == UIImageOrientationLeft || oriention == UIImageOrientationRight){
        return CGSizeMake(videoSize.height, videoSize.width);
    }
    return videoSize;
}
@end
