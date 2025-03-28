//
//  OCRImage.h
//  LoadText
//
//  Created by jia yu on 2024/10/27.
//

#import <UIKit/UIKit.h>
#import <Vision/Vision.h>

NS_ASSUME_NONNULL_BEGIN
@interface OCRImagePreprocessing : NSObject
@property (nonatomic) CGSize imageSize;
-(id)init;

-(id)initWithRegionOfInterest:(CGRect)interestRect;

//将image转换为灰度图后，大于gate值存为255; 小于gate存为0;
//Warning: please call CGImageRelease() for release return image.
+(CGImageRef)createBlackOrWhite:(CGImageRef)image withGate:(NSUInteger)gate;

/*
 只提取图片中的字幕函数
 此函数适合于白色字幕，并由黑色边框包裹的图片
 工作过程是从一点开始，如果该点灰度值大于min， 并且小于max， 则把该像素置为value。
 之后，循环处理该点上下左右的4个点。
 建议的参数为 min = 10， max = 255， value = 0; 这样就把所有浅色，并连接着的点全处理为了黑色。
 遇到黑色边框时，将停止蔓延即边框黑色值，小于 10.
 
 最后，白色字包裹的中间，仍有一些像素为图片背景色，通过gate参数，将这些背景像素全部填充为value
 */
-(CGImageRef)createSpreadCGImageFrom:(CGImageRef)image
                     withOrientation:(UIImageOrientation)orientation
                           textColor:(UIColor *)textColor
                      textTolerances:(float)textTolerances
                          boardColor:(UIColor *)boardColor
                     boardTolerances:(float)boardTolerances;


/*
 regionOfInterest 非常重要的参数，用于描述扫描区域在图片中的位置
 regionOfInterest的坐标起点为左下角，不是右上角！！
 regionOfInterest的数值为0 - 1，即所占图像宽度的比例
 */
@property (nonatomic,readonly) CGRect regionOfInterest;

-(VNFeaturePrintObservation *)observationWithCGImage:(CGImageRef)image;
@end
NS_ASSUME_NONNULL_END
