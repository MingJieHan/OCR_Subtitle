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
    UIColor *textColor = self.textColor;
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, borderWidth);
    CGContextSetLineJoin(c, kCGLineJoinRound);

      CGContextSetTextDrawingMode(c, kCGTextStroke);
      self.textColor = borderColor;
      [super drawTextInRect:rect];

      CGContextSetTextDrawingMode(c, kCGTextFill);
      self.textColor = textColor;
      self.shadowOffset = CGSizeMake(0, 0);
      [super drawTextInRect:rect];

      self.shadowOffset = shadowOffset;
}

@end
