//
//  SampleObject.h
//  LoadText
//
//  Created by jia yu on 2024/10/31.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN
@interface SampleObject : NSObject
-(id)init NS_UNAVAILABLE;
@property (nonatomic,readonly) CGAffineTransform transform;

-(id)initWithSample:(CMSampleBufferRef)sample withTransform:(CGAffineTransform)transform;

-(CGImageRef)createCGImage;
-(float)imageTime;
@end
NS_ASSUME_NONNULL_END
