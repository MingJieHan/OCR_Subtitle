//
//  HansVoiceSplitedObject.h
//  HansServer
//
//  Created by jia yu on 2024/8/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface HansVoiceSplitedObject : NSObject
@property (nonatomic) NSURL *url;
@property (nonatomic) float duration;
@property (nonatomic) float timeStamp;
@end
NS_ASSUME_NONNULL_END
