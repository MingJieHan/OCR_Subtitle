//
//  OCRImage.m
//  LoadText
//
//  Created by jia yu on 2024/10/27.
//

#import "OCRImagePreprocessing.h"
#define UN_SPREAD_FLAG 0
#define SPREAD_FLAG 1

#define MAXIMUM_IMAGE_SIZE 1920
@interface OCRImagePreprocessing(){
    CGSize imageSize;
    unsigned char *rawData;
    unsigned short **map;
    NSMutableArray *waitingSpreadPoints;
    NSUInteger bytesPerPixel;
    NSUInteger bytesPerRow;
    NSMutableArray *points;
    NSUInteger minumim;
    NSUInteger maximum;
    NSUInteger replaceValue;
    NSDate *startDate;
}
@end

@implementation OCRImagePreprocessing
@synthesize regionOfInterest;

+(CGImageRef)createBlackOrWhite:(CGImageRef)image withGate:(NSUInteger)gate{
    if (nil == image){
        return nil;
    }
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    NSUInteger bytesPerPixel = 1;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    unsigned char *rawData = (unsigned char*) calloc(width * height * 8, sizeof(unsigned char));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, 0);
    CGRect rect = CGRectMake(0.f, 0.f, width, height);
    CGContextDrawImage(context, rect, image);
    
//    CGImageRef grayImage = CGBitmapContextCreateImage(context);
    
    for (int x =0;x<width;x++){
        for (int y=0;y<height;y++){
            NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
            CGFloat v = rawData[byteIndex];
            //黑色 0 - 255 白色
//            NSLog(@"X:%d Y:%d V=%.1f", x, y, v);
            if (v < gate){
                rawData[byteIndex] = 0;
//                CGFloat r = rawData[byteIndex];
//                NSLog(@"X:%d Y:%d R=%.1f", x, y, r);
            }else{
                rawData[byteIndex] = 255;
            }
        }
    }
    
    CGImageRef blackImage = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(rawData);
    return blackImage;
}

-(NSUInteger)byteIndexWithX:(NSInteger)x Y:(NSInteger)y{
    return 4 * (bytesPerRow * y) + 4 * x * bytesPerPixel;
}

-(BOOL)colorSpreadWithByteIndex:(NSUInteger)byteIndex{
    unsigned short R = rawData[byteIndex];
    unsigned short G = rawData[byteIndex+1];
    unsigned short B = rawData[byteIndex+2];
    if ( (R >= minumim && R <= maximum)
        || (G >= minumim && G <= maximum)
        || (B >= minumim && B <= maximum)){
        if ((float)(R + G + B)/minumim < 2.5f){
            //虽然有一个颜色值在可延展范围内，但总体颜色还是太暗，判断为黑色框在视频中的误差，仍不可延展
            return NO;
        }
        //该位置的RGB值，有一个在可延展范围内，可以延展
        return YES;
    }
    return NO;
}

-(void)spread{
//    NSLog(@"work %ld point.", points.count);
    for (NSValue *v in points){
        CGPoint point = [v CGPointValue];
        NSInteger x = point.x;
        NSInteger y = point.y;
        if (x < 0){
            continue;
        }
        if (y < 0){
            continue;
        }
        if (x >= imageSize.width){
            continue;
        }
        if (y >= imageSize.height){
            continue;
        }
        
        NSUInteger byteIndex = [self byteIndexWithX:x Y:y];
        BOOL needSpread = [self colorSpreadWithByteIndex:byteIndex];
        if (needSpread){
            rawData[byteIndex] = 0;
            rawData[byteIndex+1] = 0;
            rawData[byteIndex+2] = 0;
            rawData[byteIndex+3] = 255;
            
            if ([self needSpreadForX:x-1 Y:y]){
//                NSLog(@"向左");
                map[x-1][y] = SPREAD_FLAG;
                [waitingSpreadPoints addObject:[NSValue valueWithCGPoint:CGPointMake(x-1, y)]];
            }
            
            if ([self needSpreadForX:x+1 Y:y]){
//                NSLog(@"向右");
                map[x+1][y] = SPREAD_FLAG;
                [waitingSpreadPoints addObject:[NSValue valueWithCGPoint:CGPointMake(x+1, y)]];
            }
            
            if ([self needSpreadForX:x Y:y-1]){
//                NSLog(@"向上");
                map[x][y-1] = SPREAD_FLAG;
                [waitingSpreadPoints addObject:[NSValue valueWithCGPoint:CGPointMake(x, y-1)]];
            }
            
            if ([self needSpreadForX:x Y:y+1]){
//                NSLog(@"向下");
                map[x][y+1] = SPREAD_FLAG;
                [waitingSpreadPoints addObject:[NSValue valueWithCGPoint:CGPointMake(x, y+1)]];
            }
        }
    }
    
    [points removeAllObjects];
    if (waitingSpreadPoints.count > 0){
        [points addObjectsFromArray:waitingSpreadPoints];
        [waitingSpreadPoints removeAllObjects];
    }
    return;
}

//坐标点X，Y，是否可以延展？ 可以 return YES。
-(BOOL)needSpreadForX:(NSInteger)x Y:(NSInteger)y{
    if (x < 0){
        return NO;
    }
    if (y < 0){
        return NO;
    }
    if (x >= imageSize.width){
        return NO;
    }
    if (y >= imageSize.height){
        return NO;
    }
    
    unsigned short v = map[x][y];
    if (v == SPREAD_FLAG){
        return NO;
    }
    
    //如果相邻的左右点，都不符合延展要求，则此位置不延展
    if (x > 1 && x < imageSize.width-1){
        NSUInteger leftIndex = [self byteIndexWithX:x-1 Y:y];
        NSUInteger rightIndex = [self byteIndexWithX:x+1 Y:y];
        BOOL left = [self colorSpreadWithByteIndex:leftIndex];
        BOOL right = [self colorSpreadWithByteIndex:rightIndex];
        if (NO == left && NO == right){
            return NO;
        }
    }
    
    //如果相邻的上下点，都不符合延展要求，则此位置不延展
    if (y > 1 && y < imageSize.height-1){
        NSUInteger topIndex = [self byteIndexWithX:x Y:y-1];
        NSUInteger bottomIndex = [self byteIndexWithX:x Y:y+1];
        BOOL top = [self colorSpreadWithByteIndex:topIndex];
        BOOL bottom = [self colorSpreadWithByteIndex:bottomIndex];
        if (NO == top && NO == bottom){
            return NO;
        }
    }
    return YES;
}

-(CGImageRef)createSpreadCGImageFrom:(CGImageRef)image
                        scopeMinumim:(NSUInteger)_min
                             maximum:(NSUInteger)_max
                        replaceValue:(NSUInteger)_value
                                gate:(NSUInteger)gate{
    if (nil == image){
        return nil;
    }
    
    minumim = _min;
    maximum = _max;
    replaceValue = _value;
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    imageSize = CGSizeMake(width, height);
    
    bytesPerPixel = 1;
    bytesPerRow = bytesPerPixel * width;
    rawData = (unsigned char *) calloc(width * height * 4 * 8, sizeof(unsigned char));
    
    CGRect workingPlace;
    if (regionOfInterest.size.width > 0 && regionOfInterest.size.height > 0){
        //有关注的处理区域
        /*
         regionOfInterest 是从左下角开始的百分比
         workingPlace 是从坐上角开始的坐标数值
         */
        workingPlace = CGRectMake(width * regionOfInterest.origin.x,
                                  height * (1.f - regionOfInterest.origin.y - regionOfInterest.size.height),
                                  width * regionOfInterest.size.width,
                                  height * regionOfInterest.size.height);
        for (int i=0;i<width;i++){
            for (int j=0;j<height;j++){
                map[i][j] = SPREAD_FLAG;
            }
        }
        //只标记需要扫描的区域为未扫描
        for (int x=workingPlace.origin.x;x<workingPlace.origin.x+workingPlace.size.width;x++){
            for (int y=workingPlace.origin.y;y<workingPlace.origin.y+workingPlace.size.height;y++){
                map[x][y] = UN_SPREAD_FLAG;
            }
        }
    }else{
        //整张图片处理,所有位置点，都标记为需要处理
        for (int i=0;i<width;i++){
            for (int j=0;j<height;j++){
                map[i][j] = UN_SPREAD_FLAG;
            }
        }
    }

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, 8, 4 * bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    if (nil == context){
        NSLog(@"stop here.");
    }
    CGRect rect = CGRectMake(0.f, 0.f, width, height);
    CGContextDrawImage(context, rect, image);
    
    //设置蔓延寻找的起点
    waitingSpreadPoints = [[NSMutableArray alloc] init];
    points = [[NSMutableArray alloc] init];
    if (regionOfInterest.size.width > 0 && regionOfInterest.size.height > 0){
        //有关注区时，从关注区上边和下边，同时开始
        for (int x=workingPlace.origin.x;x<(workingPlace.origin.x+workingPlace.size.width);x++){
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, workingPlace.origin.y)]];
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, workingPlace.origin.y+workingPlace.size.height-1)]];
        }
    }else{
        //无关注特定区时，从图片上下两个边开始
        for (int x=0;x<imageSize.width-1;x++){
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, 0)]];
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, imageSize.height-1)]];
        }
    }

    while (points.count > 0) {
        [self spread];
    }
    
//    t = [NSDate.date timeIntervalSinceDate:startDate];
//    NSLog(@"B Usage %.2f sec", t);

    //不够纯白，就改为黑色。
//    for (int x =0;x<width;x++){
//        for (int y=0;y<height;y++){
//            NSUInteger byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
//            CGFloat v = rawData[byteIndex];
//            //纯黑色 0 -> 纯白色 255
//            if (v < gate){
//                rawData[byteIndex] = replaceValue;
//            }
//        }
//    }

    BOOL fill = YES;   //将文字中间的镂空部位，去掉颜色改为透明
    if (fill){
        for (int x=workingPlace.origin.x;x<workingPlace.origin.x+workingPlace.size.width;x++){
            for (int y=workingPlace.origin.y;y<workingPlace.origin.y+workingPlace.size.height;y++){
                NSUInteger byteIndex = (4 * bytesPerRow * y) + 4 * x * bytesPerPixel;
                unsigned short R = rawData[byteIndex];
                unsigned short G = rawData[byteIndex+1];
                unsigned short B = rawData[byteIndex+2];
                unsigned short A = rawData[byteIndex+3];
                if (R < minumim && G < minumim && B < minumim && A > 220){
                    //黑边改透明
                    rawData[byteIndex] = 0;
                    rawData[byteIndex+1] = 0;
                    rawData[byteIndex+2] = 0;
                    rawData[byteIndex+3] = 255;
                }else if (R > gate && G > gate && B > gate){
                    //黑边包裹的白色字内容
                }else{
                    //字笔画包裹的镂空部位
                    rawData[byteIndex] = 0;
                    rawData[byteIndex+1] = 0;
                    rawData[byteIndex+2] = 0;
                    rawData[byteIndex+3] = 255;
                }
            }
        }
    }
    
    CGImageRef spreadImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(rawData);
    return spreadImage;
}

-(id)init{
    return [[OCRImagePreprocessing alloc] initWithRegionOfInterest:CGRectZero];
}

-(id)initWithRegionOfInterest:(CGRect)interestRect{
    self = [super init];
    if (self){
        regionOfInterest = interestRect;
        map = malloc(MAXIMUM_IMAGE_SIZE * sizeof(unsigned short *));
        for (int i=0;i<MAXIMUM_IMAGE_SIZE;i++){
            unsigned short *row = malloc(MAXIMUM_IMAGE_SIZE * sizeof(unsigned short));
            for (int j=0;j<MAXIMUM_IMAGE_SIZE;j++){
                row[j] = 13;
            }
            map[i] = row;
        }
    }
    return self;
}

-(void)dealloc{
    for (int i=0;i<MAXIMUM_IMAGE_SIZE;i++){
        free(map[i]);
    }
    free(map);
}

@end
