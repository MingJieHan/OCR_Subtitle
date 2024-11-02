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

-(id)initWithVideoURL:(NSURL *)videoURL;

//value is ms for CMTimeMake
-(BOOL)getImageWithValue:(int64_t)value withHandler:(void (^)(CGImageRef))completionHandler;
-(CMTimeValue)durationValue;
@end
NS_ASSUME_NONNULL_END
