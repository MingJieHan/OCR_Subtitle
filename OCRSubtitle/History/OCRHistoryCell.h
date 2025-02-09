//
//  OCRHistoryCell.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import <UIKit/UIKit.h>
#import "OCRHistory.h"

@class OCRHistoryCell;
typedef void (^OCRHistoryCell_MoreAction) (OCRHistoryCell * _Nonnull cell);

NS_ASSUME_NONNULL_BEGIN
@interface OCRHistoryCell : UICollectionViewCell
@property (nonatomic) OCRHistory *item;
@property (nonatomic) OCRHistoryCell_MoreAction moreHandler;
@end
NS_ASSUME_NONNULL_END
