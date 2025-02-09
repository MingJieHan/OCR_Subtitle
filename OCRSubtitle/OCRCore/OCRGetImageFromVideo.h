//
//  OCRGetImageFromVideo.h
//  LoadText
//
//  Created by jia yu on 2024/10/26.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface OCRGetImageFromVideo : NSObject
-(id)init NS_UNAVAILABLE;

//init only.
-(id)initWithVideoURL:(NSURL *)videoURL;

//return Image at value, Value is ms for CMTimeMake
/*
 Notice this way is slow for get all images in video.
 OCRGetSampleBuffersFromVideo is get all images from first.
 */
-(BOOL)getImageWithValue:(int64_t)value withHandler:(void (^)(CGImageRef))completionHandler;

//return duration for the video.
-(CMTimeValue)durationValue;
@end
NS_ASSUME_NONNULL_END
