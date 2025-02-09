//
//  OCRTemplateCollectionView.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import "OCRTemplateCollectionView.h"
#import "OCRTemplateCell.h"
#import "OCRSubtitleManage.h"
static NSString * const reuseIdentifier = @"OCRTemplateIdentifier";

@interface OCRTemplateCollectionView()<UICollectionViewDataSource,UICollectionViewDelegate>{
    NSMutableArray <OCRSetting *>*templates;
    UIEdgeInsets blockEdge;
    CGSize blockSize;
    float minimumLineSpacing;
    float minimumInteritemSpacing;
}
@end

@implementation OCRTemplateCollectionView
@synthesize openHandler, editHandler;

-(id)initWithFrame:(CGRect)frame{
    UICollectionViewFlowLayout *collectionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self = [super initWithFrame:frame collectionViewLayout:collectionFlowLayout];
    if (self){
        templates = [OCRSubtitleManage.shared existSettings];
        if (0 == templates.count){
            OCRSetting *demoSetting = [OCRSetting wanruSetting];
            OCRSetting *o = [OCRSubtitleManage.shared createOCRSetting];
            o.image = demoSetting.image;
            o.videoWidth = demoSetting.videoWidth;
            o.videoHeight = demoSetting.videoHeight;
            o.subtitleLanguages = demoSetting.subtitleLanguages;
            o.textColor = demoSetting.textColor;
            o.borderColor = demoSetting.borderColor;
            o.passTopRate = demoSetting.passTopRate;
            o.heightRate = demoSetting.heightRate;
            o.rate = demoSetting.rate;
            [o save];
            
            templates = [OCRSubtitleManage.shared existSettings];
        }
        self.dataSource = self;
        self.delegate = self;
        [self registerClass:[OCRTemplateCell class] forCellWithReuseIdentifier:reuseIdentifier];
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    float targetBlockWidth = 0.f;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //iPad
        blockEdge = UIEdgeInsetsMake(0.f, 24.f, 0.f, 24.f);
        minimumInteritemSpacing = 12.f;
        float contentWidth = self.frame.size.width - blockEdge.left - blockEdge.right;
        int row = (int)contentWidth/(int)(minimumInteritemSpacing + 332.f);
        float availableWith = contentWidth - (row - 1) * (minimumInteritemSpacing + 2.f);
        targetBlockWidth = availableWith/row;
    }else{
        //iPhone
        blockEdge = UIEdgeInsetsMake(0.f, 2.f, 0.f, 2.f);;
        minimumInteritemSpacing = 0.f;
        targetBlockWidth = self.frame.size.width-4.f;
    }
    minimumLineSpacing = 40.f;
    if (blockSize.width != targetBlockWidth){
        blockSize = CGSizeMake(targetBlockWidth, 200.f);
        [self reloadData];
    }
}

-(void)moreButtonAction:(OCRTemplateCell *)cell{
    if (editHandler){
        editHandler(cell.item);
    }
    return;
}

-(void)openIndexPath:(OCRTemplateCell *)cell{
    if (openHandler){
        openHandler(cell.item);
    }
    return;
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return templates.count;
}

- (OCRTemplateCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OCRTemplateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.item = [templates objectAtIndex:indexPath.row];
    cell.moreHandler = ^(OCRTemplateCell * _Nonnull cell) {
        [self moreButtonAction:cell];
    };
    return cell;
}



#pragma mark <UICollectionViewDelegate>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return blockSize;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return minimumLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return minimumInteritemSpacing;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return blockEdge;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    OCRTemplateCell *cell = [self cellForItemAtIndexPath:indexPath];
    [self openIndexPath:cell];
    return;
}

@end
