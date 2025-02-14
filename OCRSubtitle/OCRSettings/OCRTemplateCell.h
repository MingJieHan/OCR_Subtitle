//
//  OCRTemplateCell.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import <UIKit/UIKit.h>
#import "OCRTemplateCollectionView.h"
#import "OCRSetting.h"

@class OCRTemplateCell;
typedef void (^OCRTemplateCell_MoreAction) (OCRTemplateCell * _Nonnull cell);
typedef void (^OCRTemplateCell_RemoveAction) (OCRTemplateCell * _Nonnull cell);

NS_ASSUME_NONNULL_BEGIN
@interface OCRTemplateCell : UICollectionViewCell
@property (nonatomic) OCRSetting *item;
@property (nonatomic) OCRTemplateCell_MoreAction moreHandler;
@property (nonatomic) OCRTemplateCell_RemoveAction removeHandler;
@end
NS_ASSUME_NONNULL_END
