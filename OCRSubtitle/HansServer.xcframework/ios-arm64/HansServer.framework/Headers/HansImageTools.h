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

//Warning caller need CGImageRelease() the result.
//selectRect 是获取区域的坐标，Warning: 坐标起点为左下角，不是右上角！！， 坐标的值是百分比，不是像素数
//selectRect.width 数值是图像宽度的百分比
//selectRect.height 数值是图像高度的百分比
+(CGImageRef)createRegionOfInterestImageFromFullImage:(CGImageRef)spreadCGImage
                                       withTargetRect:(CGRect)selectRect
                                      withOrientation:(UIImageOrientation)orientation;

//return part of image, in rect.
//rect 单位为像素数，起点为左上角，与UIkit中保持一致
+(UIImage *)imageRect:(CGRect)rect from:(UIImage *)image;


+(void)saveImageFromSampleBuffer:(CMSampleBufferRef)buf intoFile:(NSString *)filename;
+(void)saveImageFromCVImageBuffer:(CVImageBufferRef)imageBuffer intoFile:(NSString *)filename;

+(CGImageRef)adjustRed:(CGImageRef)cgImage withRate:(float)rate;

+(CGImageRef)rotateCGImage:(CGImageRef)imageRef withOrientation:(UIImageOrientation)orientation;

//return Image orientation when gotted image from video, Example take video is landscapte.
+(UIImageOrientation)imageOrientionFromVideoTransform:(CGAffineTransform)txf;

//return UIImageOrientation 转化为 CGImageOrientation 用于文字识别、图像处理等函数输入
+(CGImagePropertyOrientation)CGOrientationFromUIImageOrientation:(UIImageOrientation)imageOrientation;
@end
NS_ASSUME_NONNULL_END


@interface UIImage (Crop)
//Return inputImage show in size result.
-(UIImage * _Nonnull)imageByCroppingWithSize:(CGSize)size;

-(NSString * _Nonnull )savePNGIntoFile:(NSString * _Nonnull )filename;
-(NSString * _Nonnull )saveJPEGIntoFile:(NSString * _Nonnull )filename;
@end
