//
//  GottedTextLabel.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import "HansBorderLabel.h"

@interface HansBorderLabel(){
    
}
@end

@implementation HansBorderLabel
@synthesize borderColor;
@synthesize borderWidth;
@synthesize fontColor;

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        self.textAlignment = NSTextAlignmentCenter;
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        self.adjustsFontSizeToFitWidth = YES;
        self.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24.f];
        borderColor = [UIColor blackColor];
        borderWidth = 3.f;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    CGSize shadowOffset = self.shadowOffset;
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, borderWidth);
    CGContextSetLineJoin(c, kCGLineJoinRound);

    CGContextSetTextDrawingMode(c, kCGTextStroke);
    if (nil == borderColor){
        self.textColor = [UIColor clearColor];
    }else{
        self.textColor = borderColor;
    }
    [super drawTextInRect:rect];

    CGContextSetTextDrawingMode(c, kCGTextFill);
    if (nil == fontColor){
        self.textColor = [UIColor clearColor];
    }else{
        self.textColor = fontColor;
    }
    self.shadowOffset = CGSizeMake(0, 0);
    [super drawTextInRect:rect];
    
    self.shadowOffset = shadowOffset;
    return;
}

-(void)setBorderColor:(UIColor *)_borderColor{
    borderColor = _borderColor;
    [self setNeedsDisplay];
    return;
}

-(void)setFontColor:(UIColor *)_fontColor{
    fontColor = _fontColor;
    [self setNeedsDisplay];
}

@end
