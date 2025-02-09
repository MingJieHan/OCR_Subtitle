//
//  OCRGetBuffersFromVideo.h
//  LoadText
//
//  Created by jia yu on 2024/10/31.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN
@interface OCRGetSampleBuffersFromVideo : NSObject
@property (nonatomic,readonly) CMTime duration;
@property (nonatomic,readonly) CMTimeRange timeRange;
@property (nonatomic,readonly) BOOL ready;
@property (nonatomic,readonly) CGSize videoSize;
-(id)init NS_UNAVAILABLE;

-(id)initWithVideoURL:(NSURL *)videoURL;

-(id)initWithVideoURL:(NSURL *)videoURL withBegin:(float)start withEnd:(float)end;

//return nil when finish.
-(CMSampleBufferRef)copyNextBuffer;
@end
NS_ASSUME_NONNULL_END
