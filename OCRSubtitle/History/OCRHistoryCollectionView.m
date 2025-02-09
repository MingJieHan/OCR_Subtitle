//
//  OCRHistoryCollectionView.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import "OCRHistoryCollectionView.h"
#import "OCRHistoryCell.h"
#import "OCRSubtitleManage.h"

static NSString * const reuseIdentifier = @"OCRHistoryIdentifier";

@interface OCRHistoryCollectionView()<UICollectionViewDataSource,UICollectionViewDelegate>{
    NSMutableArray <OCRHistory *>*historys;
    UIEdgeInsets blockEdge;
    CGSize blockSize;
    float minimumLineSpacing;
    float minimumInteritemSpacing;

}
@end

@implementation OCRHistoryCollectionView
@synthesize shareHandler, openHandler;

-(id)initWithFrame:(CGRect)frame{
    UICollectionViewFlowLayout *collectionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self = [super initWithFrame:frame collectionViewLayout:collectionFlowLayout];
    if (self){
        historys = [OCRSubtitleManage.shared existHistorys];        
        
//        historys = [[NSMutableArray alloc] init];
//        NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
//        NSArray *files = [NSFileManager.defaultManager contentsOfDirectoryAtPath:path error:nil];
//        
//        for (NSString *file in files){
//            if (![[[file pathExtension] lowercaseString] isEqualToString:@"txt"]){
//                continue;
//            }
//            OCRHistory *item = [[OCRHistory alloc] init];
//            item.file = [path stringByAppendingPathComponent:file];
//            NSDictionary *dict = [NSFileManager.defaultManager attributesOfItemAtPath:item.file error:nil];
//            item.completedDate = [dict valueForKey:NSFileModificationDate];
//            item.usageSeconds = 45.3f;
//            [historys addObject:item];
//        }
        self.dataSource = self;
        self.delegate = self;
        [self registerClass:[OCRHistoryCell class] forCellWithReuseIdentifier:reuseIdentifier];
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
        int row = (int)contentWidth/(int)(minimumInteritemSpacing + 220.f);
        float availableWith = contentWidth - (row - 1) * (minimumInteritemSpacing + 2.f);
        targetBlockWidth = availableWith/row;
    }else{
        //iPhone
        blockEdge = UIEdgeInsetsMake(0.f, 2.f, 0.f, 2.f);;
        minimumInteritemSpacing = 0.f;
        targetBlockWidth = (self.frame.size.width-8.f)/2.f;
    }
    minimumLineSpacing = 40.f;
    if (blockSize.width != targetBlockWidth){
        blockSize = CGSizeMake(targetBlockWidth, 200.f);
        [self reloadData];
    }
}

-(void)moreButtonAction:(OCRHistoryCell *)cell{
    if (shareHandler){
        shareHandler(cell.item);
    }
    return;
}

-(void)openIndexPath:(OCRHistoryCell *)cell{
    if (openHandler){
        openHandler(cell.item);
    }
    return;
}

-(void)addObject:(OCRHistory *)anOCRHistory{
    [self performBatchUpdates:^{
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
        [historys insertObject:anOCRHistory atIndex:0];
        [self insertItemsAtIndexPaths:@[index]];
    } completion:^(BOOL finished) {
        
    }];
    return;
}

-(void)removeObject:(OCRHistory *)anOCRHistory{
    [self performBatchUpdates:^{
        NSInteger nn = [self->historys indexOfObject:anOCRHistory];
        [self->historys removeObject:anOCRHistory];
        NSIndexPath *index = [NSIndexPath indexPathForRow:nn inSection:0];
        [self deleteItemsAtIndexPaths:@[index]];
    } completion:^(BOOL finished) {
        
    }];
    return;
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return historys.count;
}

- (OCRHistoryCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OCRHistoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.item = [historys objectAtIndex:indexPath.row];
    cell.moreHandler = ^(OCRHistoryCell * _Nonnull cell) {
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
    OCRHistoryCell *cell = [self cellForItemAtIndexPath:indexPath];
    [self openIndexPath:cell];
    return;
}
@end
