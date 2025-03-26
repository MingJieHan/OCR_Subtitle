//
//  HansImageTools.h
//  HansServer
//
//  Created by Hans on 2025/3/26.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface HansImageTools : NSObject
//return SampleBuffer, Warning: need release the return.
+(CMSampleBufferRef)createSampleBufferFromPixelBuffer:(CVPixelBufferRef)pixelBuffer frameTime:(CMTime)frameTime;

//return PixelBuffer, Warning : need call CVPixelBufferRelease for release the return
+(CVPixelBufferRef)createPixelBufferFromCGImage: (CGImageRef)image flipVertical:(BOOL)flipVer flipHorizontal:(BOOL)flipHor;


+(void)saveImageFromSampleBuffer:(CMSampleBufferRef)buf intoFile:(NSString *)filename;
+(void)saveImageFromCVImageBuffer:(CVImageBufferRef)imageBuffer intoFile:(NSString *)filename;

+(CGImageRef)adjustRed:(CGImageRef)cgImage withRate:(float)rate;

+(CGImageRef)rotateCGImage:(CGImageRef)imageRef withOrientation:(UIImageOrientation)orientation;
@end
NS_ASSUME_NONNULL_END


@interface UIImage (Crop)
//Return inputImage show in size result.
-(UIImage * _Nonnull)imageByCroppingWithSize:(CGSize)size;

-(NSString * _Nonnull )savePNGIntoFile:(NSString * _Nonnull )filename;
-(NSString * _Nonnull )saveJPEGIntoFile:(NSString * _Nonnull )filename;
@end
