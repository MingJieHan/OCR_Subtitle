//
//  HansWKWebView.h
//  HansServer
//
//  Created by jia yu on 2024/1/26.
//

#import <WebKit/WebKit.h>

/*
 [assertion] Error acquiring assertion: <Error Domain=RBSServiceErrorDomain Code=1 "(originator doesn't have entitlement com.apple.runningboard.assertions.webkit AND originator doesn't have entitlement com.apple.multitasking.systemappassertions)" UserInfo={NSLocalizedFailureReason=(originator doesn't have entitlement com.apple.runningboard.assertions.webkit AND originator doesn't have entitlement com.apple.multitasking.systemappassertions)}>
 
 -> Goto Menu menu -> Scheme -> Edit Scheme -> It comes up with popup -> Select "Run" - -> Select "Arguments" -> Then Environment Variables -> after this click on "+" button set "OS_ACTIVITY_MODE = disable"
 
 https://stackoverflow.com/questions/69902932/error-acquiring-assertions-what-is-that
 */

NS_ASSUME_NONNULL_BEGIN
@protocol HansWKWebViewDelegate;
@interface HansWKWebView : WKWebView
-(id)initWithDelegate:(id <HansWKWebViewDelegate>)delegate;
-(void)playVideo;
-(void)stopPlayingVideo;

-(id)init NS_UNAVAILABLE;
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
-(id)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration NS_UNAVAILABLE;
@end

@protocol HansWKWebViewDelegate <NSObject>
-(void)webView:(HansWKWebView *)webView withError:(NSError *)error;

@optional
-(void)videoHasPlaying;
-(void)videoRealSRC:(NSString *)video_src;
-(void)videoHasPauseOrStoped;
@end

NS_ASSUME_NONNULL_END
