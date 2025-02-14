//
//  AreaSelectButton.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/10.
//

#import "AreaSelectButton.h"
#import <HansServer/HansServer.h>
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
@synthesize string;
@synthesize isSubtitle;

-(id)initWithRectangleObservation:(VNRectangleObservation *)_observation
                         withSize:(CGSize)_size
                       withString:(NSString *)_string{
    self = [super init];
    if (self){
        size = _size;
        string = _string;
        self.backgroundColor = [UIColor clearColor];
//        self.layer.masksToBounds = YES;
        
        observation = _observation;
        isSubtitle = [self isSubtitle];
        self.enabled = isSubtitle;
        if (isSubtitle){
            self.layer.borderColor = [UIHans colorFromHEXString:@"FACC0B"].CGColor;
            self.layer.borderWidth = 5.f;
            self.layer.cornerRadius = 4.f;
        }else{
            self.layer.borderColor = [UIHans colorFromHEXString:@"2B963D"].CGColor;
            self.layer.borderWidth = 2.f;
            self.layer.cornerRadius = 4.f;
        }
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
        CGRect rect = CGRectMake(minX,minY,
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

-(BOOL)isSubtitle{
    if (fabs(observation.topLeft.y - observation.topRight.y) > 0.01f){
//        NSLog(@"%@ 上沿不平.", self.string);
        return NO;
    }
    if (fabs(observation.topLeft.x - observation.bottomLeft.x) > 0.01f){
//        NSLog(@"%@ 左侧不平.", self.string);
        return NO;
    }
    if (fabs(observation.topRight.x - observation.bottomRight.x) > 0.01f){
//        NSLog(@"%@ 右侧不平.", self.string);
        return NO;
    }
    if (fabs(observation.bottomLeft.y - observation.bottomRight.y) > 0.01f){
//        NSLog(@"%@ 下沿不平.", self.string);
        return NO;
    }
    
    float spaceRight = 1.f - observation.topRight.x;
    float aaa = fabs(spaceRight - observation.topLeft.x);
    if ( aaa > 0.2){
//        NSLog(@"不居中 %@: %.2f", string, aaa);
        return NO;
    }
    
//    NSLog(@"Subtitle %@: %.2f", string, aaa);
    return YES;
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
    if (isSubtitle){
        CGContextSetFillColorWithColor(context, [UIHans colorFromHEXString:@"2B68EB" withAlpha:0.7].CGColor);
//        NSLog(@"%@ True.", string);
    }else{
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.4f green:0.4 blue:0.4 alpha:0.2].CGColor);
//        NSLog(@"%@ False.", string);
    }
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGPathRelease(path);
    return;
}
@end
