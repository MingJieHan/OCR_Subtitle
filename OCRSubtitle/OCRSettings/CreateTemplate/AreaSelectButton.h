//
//  AreaSelectButton.h
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/10.
//

#import <UIKit/UIKit.h>
#import <Vision/Vision.h>

NS_ASSUME_NONNULL_BEGIN

@interface AreaSelectButton : UIButton
-(id)initWithRectangleObservation:(VNRectangleObservation *)observation
                         withSize:(CGSize)size
                       withString:(NSString *)string;
@property (nonatomic,readonly) VNRectangleObservation *observation;
@property (nonatomic,readonly) CGSize size;
@property (nonatomic,readonly) BOOL isSubtitle;
@property (nonatomic,readonly) NSString *string;

-(float)passTopRate;
-(float)heightRate;
@end

NS_ASSUME_NONNULL_END
