//
//  OCRHistoryCell.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import <UIKit/UIKit.h>
#import "OCRHistory.h"

@class OCRHistoryCell;
typedef void (^OCRHistoryCell_RemoveAction) (OCRHistoryCell * _Nonnull cell);

NS_ASSUME_NONNULL_BEGIN
@interface OCRHistoryCell : UICollectionViewCell
@property (nonatomic) OCRHistory * _Nullable item;
@property (nonatomic) OCRHistoryCell_RemoveAction removeHandler;
@end
NS_ASSUME_NONNULL_END
