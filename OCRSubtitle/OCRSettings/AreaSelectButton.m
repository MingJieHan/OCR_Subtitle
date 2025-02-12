//
//  AreaSelectButton.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/10.
//

#import "AreaSelectButton.h"

@interface AreaSelectButton(){
    CGPoint topLeft;
    CGPoint topRight;
    CGPoint bottomLeft;
    CGPoint bottomRight;
    CGFloat minX;
    CGFloat minY;
    CGFloat maxX;
    CGFloat maxY;
}
@end

@implementation AreaSelectButton
@synthesize observation;
@synthesize size;

-(id)initWithRectangleObservation:(VNRectangleObservation *)_observation withSize:(CGSize)_size{
    self = [super init];
    if (self){
        size = _size;
        self.layer.borderColor = [UIColor greenColor].CGColor;
        self.layer.borderWidth = 2.f;
        self.layer.cornerRadius = 4.f;
//        self.layer.masksToBounds = YES;
        
        observation = _observation;
        topLeft = CGPointMake(observation.topLeft.x * size.width, (1.f- observation.topLeft.y) * size.height);
        topRight = CGPointMake(observation.topRight.x * size.width, (1.f- observation.topRight.y) * size.height);
        bottomLeft = CGPointMake(observation.bottomLeft.x * size.width, (1.f- observation.bottomLeft.y) * size.height);
        bottomRight = CGPointMake(observation.bottomRight.x * size.width, (1.f- observation.bottomRight.y) * size.height);
        
        minX = topLeft.x;
        if (topRight.x < minX){
            minX = topRight.x;
        }
        if (bottomLeft.x < minX){
            minX = bottomLeft.x;
        }
        if (bottomRight.x < minX){
            minX = bottomRight.x;
        }
        
        minY = topLeft.y;
        if (topRight.y < minY){
            minY = topRight.y;
        }
        if (bottomLeft.y < minY){
            minY = bottomLeft.y;
        }
        if (bottomRight.y < minY){
            minY = bottomRight.y;
        }
        
        
        maxX = topLeft.x;
        if (topRight.x > maxX){
            maxX = topRight.x;
        }
        if (bottomLeft.x > maxX){
            maxX = bottomLeft.x;
        }
        if (bottomRight.x > maxX){
            maxX = bottomRight.x;
        }
        
        maxY = topLeft.y;
        if (topRight.y > maxY){
            maxY = topRight.y;
        }
        if (bottomLeft.y > maxY){
            maxY = bottomLeft.y;
        }
        if (bottomRight.y > maxY){
            maxY = bottomRight.y;
        }
        CGRect rect = CGRectMake(minX,
                                 minY,
                                 maxX-minX,
                                 maxY-minY);
        [self setFrame:rect];
    }
    return self;
}

-(float)passTopRate{
    return minY/size.height;
}

-(float)heightRate{
    return (maxY - minY)/size.height;
}

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, nil, topLeft.x - minX, topLeft.y - minY);
    CGPathAddLineToPoint(path, nil, topRight.x - minX, topRight.y - minY);
    CGPathAddLineToPoint(path, nil, bottomRight.x - minX, bottomRight.y - minY);
    CGPathAddLineToPoint(path, nil, bottomLeft.x - minX, bottomLeft.y - minY);
    CGPathAddLineToPoint(path, nil, topLeft.x - minX, topLeft.y - minY);
    CGPathCloseSubpath(path);
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.8f green:0.1 blue:0.1 alpha:0.5].CGColor);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGPathRelease(path);
    return;
}
@end
