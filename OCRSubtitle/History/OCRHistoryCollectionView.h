//
//  OCRHistoryCollectionView.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import <UIKit/UIKit.h>
#import "OCRHistory.h"

typedef void (^OCRHistoryCollectionView_OpenAction) (OCRHistory * _Nonnull history);
typedef void (^OCRHistoryCollectionView_ShareAction) (OCRHistory * _Nonnull history);


NS_ASSUME_NONNULL_BEGIN
@interface OCRHistoryCollectionView : UICollectionView
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)init NS_UNAVAILABLE;
-(id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout NS_UNAVAILABLE;

-(id)initWithFrame:(CGRect)frame;
@property (nonatomic) OCRHistoryCollectionView_OpenAction openHandler;
@property (nonatomic) OCRHistoryCollectionView_ShareAction shareHandler;

-(void)addObject:(OCRHistory *)anOCRHistory;
-(void)removeObject:(OCRHistory *)anOCRHistory;
@end
NS_ASSUME_NONNULL_END
