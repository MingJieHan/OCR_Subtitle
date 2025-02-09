//
//  OCRTemplateCell.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import <UIKit/UIKit.h>
#import "OCRSetting.h"
@class OCRTemplateCell;
typedef void (^OCRTemplateCell_MoreAction) (OCRTemplateCell * _Nonnull cell);

NS_ASSUME_NONNULL_BEGIN
@interface OCRTemplateCell : UICollectionViewCell
@property (nonatomic) OCRSetting *item;
@property (nonatomic) OCRTemplateCell_MoreAction moreHandler;

@end
NS_ASSUME_NONNULL_END
