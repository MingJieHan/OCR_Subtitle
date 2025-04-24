//
//  NSDetectorMuteSwitch.h
//  SportsHR
//
//  Created by jia yu on 2022/4/17.
//

#import <Foundation/Foundation.h>

/*
 DEMO
 
 #import <HansServer/HansServer.h>
 
 [HansDetectorMuteSwitch.shared detectMuteWithHandler:^(BOOL mute) {
     if (mute){
         NSLog(@"Muted");
     }else{
         NSLog(@"No mute.");
     }
 }];
 */

NS_ASSUME_NONNULL_BEGIN
typedef void (^HansDetectorMuteSwitch_Handler) (BOOL mute);
@interface HansDetectorMuteSwitch : NSObject
+(HansDetectorMuteSwitch *)shared;

-(void)detectMuteWithHandler:(HansDetectorMuteSwitch_Handler)handler;
@end
NS_ASSUME_NONNULL_END
