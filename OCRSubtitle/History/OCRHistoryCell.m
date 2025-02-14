//
//  OCRHistoryCell.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import "OCRHistoryCell.h"
#import "CreateOCRView.h"
#import "ExistOCRView.h"
#import <HansServer/HansServer.h>

@interface OCRHistoryCell(){
    CreateOCRView *createView;
    ExistOCRView *itemView;
    
    UIHansButton *removeButton;
}
@end

@implementation OCRHistoryCell
@synthesize item;
@synthesize removeHandler;

-(void)setHighlighted:(BOOL)highlighted{
    if (highlighted){
        if (nil == item){
            [createView clickAnimated];
        }else{
            [itemView clickAnimated];
        }
    }
    [super setHighlighted:highlighted];
}

-(void)checkItems{
    self.backgroundColor = [UIColor clearColor];
    if (nil == createView){
        createView = [[CreateOCRView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height)];
        [self addSubview:createView];
    }
    
    if (nil == itemView){
        itemView = [[ExistOCRView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height)];
        [self addSubview:itemView];
    }

    if (nil == removeButton){
        removeButton = [[UIHansButton alloc] initWithFrame:CGRectMake(self.frame.size.width-40.f, 0.f, 40.f, 40.f)];
        removeButton.enabled = YES;
        removeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [removeButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"delete" ofType:@"png"]] forState:UIControlStateNormal];
        [removeButton setImage:[UIImage imageWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"delete_disable" ofType:@"png"]] forState:UIControlStateDisabled];
        [removeButton setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
        [removeButton setBackgroundColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [removeButton addTarget:self action:@selector(removeAction) forControlEvents:UIControlEventTouchUpInside];
        removeButton.backgroundColor = [UIColor clearColor];
        [itemView addSubview:removeButton];
    }
    return;
}

-(void)removeAction{
    if (removeHandler){
        removeHandler(self);
    }
}

-(void)setItem:(OCRHistory *)_item{
    item = _item;
    [self checkItems];
    if (nil == item){
        createView.alpha = 1.f;
        [self bringSubviewToFront:createView];
        itemView.alpha = 0.f;
    }else{
        itemView.item = item;
        itemView.alpha = 1.f;
        [self bringSubviewToFront:itemView];
        createView.alpha = 0.f;
    }
    return;
}

@end
