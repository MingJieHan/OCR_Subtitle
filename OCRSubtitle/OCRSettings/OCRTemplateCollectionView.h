//
//  OCRTemplateCollectionView.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/7.
//

#import <UIKit/UIKit.h>
#import "OCRSetting.h"

typedef void (^OCRTemplateCollectionView_OpenAction) (OCRSetting * _Nonnull setting);
typedef void (^OCRTemplateCollectionView_EditAction) (OCRSetting * _Nonnull setting);

NS_ASSUME_NONNULL_BEGIN
@interface OCRTemplateCollectionView : UICollectionView
@property (nonatomic) OCRTemplateCollectionView_OpenAction openHandler;
@property (nonatomic) OCRTemplateCollectionView_EditAction editHandler;

-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)init NS_UNAVAILABLE;
-(id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout NS_UNAVAILABLE;

-(id)initWithFrame:(CGRect)frame;
-(void)refreshSetting:(OCRSetting *)setting;
-(NSArray <OCRSetting *>* _Nullable )availableSettingForVideo:(NSURL *)targetVideoURL;
@end
NS_ASSUME_NONNULL_END
