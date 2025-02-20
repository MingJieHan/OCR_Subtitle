//
//  OCRHistoryCollectionView.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import "OCRHistoryCollectionView.h"
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
@synthesize firstHistoryCellRect;

-(id)initWithFrame:(CGRect)frame{
    UICollectionViewFlowLayout *collectionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    collectionFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self = [super initWithFrame:frame collectionViewLayout:collectionFlowLayout];
    if (self){
        self.backgroundColor = [UIColor whiteColor];
        historys = [OCRSubtitleManage.shared existHistorys];
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
        blockEdge = UIEdgeInsetsMake(20.f, 24.f, 20.f, 24.f);
        minimumInteritemSpacing = 12.f;
        float contentWidth = self.frame.size.width - blockEdge.left - blockEdge.right;
        int row = (int)contentWidth/(int)(minimumInteritemSpacing + 220.f);
        float availableWith = contentWidth - (row - 1) * (minimumInteritemSpacing + 2.f);
        targetBlockWidth = availableWith/row;
    }else{
        //iPhone
        blockEdge = UIEdgeInsetsMake(20.f, 2.f, 20.f, 2.f);;
        minimumInteritemSpacing = 3.f;
        targetBlockWidth = (self.frame.size.width - 12.f)/2.f;
    }
    minimumLineSpacing = 20.f;
    if (blockSize.width != targetBlockWidth){
        blockSize = CGSizeMake(targetBlockWidth, 200.f);
        [self reloadData];
    }
}

-(void)reloadData{
    [super reloadData];
    if (self->historys.count > 0){
        OCRHistoryCell *cell = [self cellForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        self->firstHistoryCellRect = [cell convertRect:cell.frame toView:self];
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
        self.userInteractionEnabled = NO;
        [NSTimer scheduledTimerWithTimeInterval:0.3f repeats:NO block:^(NSTimer * _Nonnull timer) {
            self->openHandler(cell);
            self.userInteractionEnabled = YES;
        }];
    }
    return;
}

-(void)insertAnHistory:(OCRHistory *)anOCRHistory withCompleted:(InsertHistory_Completed)completed{
    [self performBatchUpdates:^{
        [historys insertObject:anOCRHistory atIndex:0];
        
        //The first cell is Add view, so the second cell is.
        NSIndexPath *index = [NSIndexPath indexPathForRow:1 inSection:0];
        [self insertItemsAtIndexPaths:@[index]];
    } completion:^(BOOL finished) {
        OCRHistoryCell *cell = [self cellForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        completed(cell);
    }];
    return;
}

-(void)removeObject:(OCRHistory *)anOCRHistory{
    [self performBatchUpdates:^{
        NSInteger nn = [self->historys indexOfObject:anOCRHistory];
        [self->historys removeObject:anOCRHistory];
        NSIndexPath *index = [NSIndexPath indexPathForRow:nn+1 inSection:0];
        [self deleteItemsAtIndexPaths:@[index]];
    } completion:^(BOOL finished) {
        [OCRSubtitleManage.shared removeItem:anOCRHistory];
    }];
    return;
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1 + historys.count;
}

- (OCRHistoryCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OCRHistoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (0 == indexPath.row){
        //new history
        cell.item = nil;
    }else{
        cell.item = [historys objectAtIndex:indexPath.row-1];
    }
    cell.removeHandler = ^(OCRHistoryCell * _Nonnull cell) {
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
