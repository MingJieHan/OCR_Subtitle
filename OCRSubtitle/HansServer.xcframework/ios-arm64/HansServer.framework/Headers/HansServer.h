//
//  HansServer.h
//  HansServer
//
//  Created by jia yu on 2021/7/19.
//

#import <Foundation/Foundation.h>

#pragma mark - Hans Category
#import <HansServer/NSHansCategory.h>

#pragma mark - Hans Account
#import <HansServer/HansServerHandler.h>
#import <HansServer/HansRequestManager.h>
#import <HansServer/HansCache.h>
#import <HansServer/HansServerUserObject.h>
#import <HansServer/HansServerHtmlResultObject.h>

#pragma mark - Hans Base Tools
#import <HansServer/NSDjangoUTCConvert.h>
#import <HansServer/UIHans.h>
#import <HansServer/HansImageTools.h>
#import <HansServer/UIContactHansLabel.h>
#import <HansServer/UIHansJSONViewController.h>
#import <HansServer/UIWallPaperManageViewController.h>
#import <HansServer/HansWKWebView.h>
#import <HansServer/UIHansAboutViewController.h>
#import <HansServer/UIHansSwitchTableViewCell.h>
#import <HansServer/UIHansCheckBoxTableViewCell.h>
#import <HansServer/UIHansRadioTableViewCell.h>
#import <HansServer/UIHansSelectLabel.h>
#import <HansServer/UIHansMutableSelectView.h>
#import <HansServer/UIHansRadioSelectView.h>
#import <HansServer/UIHansTableViewFooterView.h>
#import <HansServer/UIHansRadioSelectViewController.h>
#import <HansServer/UIHansMutableSelectViewController.h>
#import <HansServer/UIHansBlurEffect.h>
#import <HansServer/UIHansEffectDemoViewController.h>
#import <HansServer/UIHansButton.h>
#import <HansServer/UIButton+Hans.h>
#import <HansServer/UIHansSwitchView.h>
#import <HansServer/HansOfflineView.h>
#import <HansServer/HansRefresher.h>
#import <HansServer/HansLocal.h>
#import <HansServer/HansProgressBarView.h>
#import <HansServer/HansEmailTextField.h>
#import <HansServer/AboutHansButton.h>

#pragma mark - NetWork
#import <HansServer/UIHansNetworkImageView.h>

#pragma mark - Piece download
#import <HansServer/HansDownloadWithPiece.h>
#import <HansServer/HansDownloadPiecesProgressView.h>
#import <HansServer/HansPiecesProgressViewController.h>

#pragma mark - Hans Account Views
#import <HansServer/HansSignUpViewController.h>
#import <HansServer/HansForgotPasswordViewController.h>
#import <HansServer/HansLoginViewController.h>
#import <HansServer/HansAccountDetailTableViewController.h>

#pragma mark - Hans Edit
#import <HansServer/HansLineStringEditViewController.h>
#import <HansServer/HansManyLineStringEditViewController.h>
#import <HansServer/HansInputFloatViewController.h>
#import <HansServer/HansSelectOneTableViewController.h>
#import <HansServer/HansInformationViewController.h>
#import <HansServer/UISelectImageView.h>

#pragma mark - VerifyAppleStoreReceipt
#import <HansServer/VerifyAppleStoreReceipt.h>
#import <HansServer/VerifyReceiptObject.h>
#import <HansServer/VerifyReceiptResult.h>

#pragma mark - Voice
// [HansDetectorMuteSwitch.shared detectMuteWithHandler:^(BOOL mute) {
//     if (mute){
//         NSLog(@"iPhone Muted");
//     }else{
//         NSLog(@"iPhone No mute.");
//     }
// }];
#import <HansServer/HansDetectorMuteSwitch.h>
#import <HansServer/HansVoiceSplitedObject.h>
#import <HansServer/HansVoiceTools.h>

extern float HansServerVersion;         //1.2 etc
extern NSInteger HansServerBuildNumber; //3453 etc

#define HansServerIdentifier @"com.hanmingjie.HansServer"
#define Current_User_Changed_Notification_Name @"Current_User_Changed_Notification_Name"
#define Current_Network_Changed_Notification_Name @"Current_Network_Changed_Notification_Name"
#define HANS_SERVER_ERROR_KEY @"error"

extern NSBundle * _Nonnull HansServerBundle;
//NSLocalizedStringFromTableInBundle(@"Loading...", @"HansServer", HansServerBundle, nil);

NS_ASSUME_NONNULL_BEGIN
@interface HansServer : NSObject
@property (nonatomic) NSString *server;         //ip.ip.ip.ip or www.domain.com
@property (nonatomic) NSInteger port;           //default is 80
@property (nonatomic) BOOL requestHttps;        //default is NO
@property (nonatomic) BOOL isDevelopmentToken;  //default is NO
@property (nonatomic) NSString *bundleIdentifierForToken;   //
@property (nonatomic) NSString *userAgent;      //default is @"Hans WebKit"
@property (nonatomic) NSString *verifyAppendKey;    //服务器通讯校验计算额外Key， default is Hans

//HansServer sent notification while currentUser changed.
@property (nonatomic) HansServerUserObject * _Nullable currentUser;
@property (nonatomic,readonly) BOOL isIniting;  //return true when login, who etc.
@property (nonatomic) BOOL netWorkAvailable;

+(HansServer *)shareServer;

-(void)thisDeviceNotificationToken:(NSData *)token;

-(NSString *)buildURL:(NSString *)urlPath;

-(void)request:(NSString *)urlpath withHandler:(HansServer_Request_Handler)handler;

-(void)postURL:(NSString *)urlpath with:(NSDictionary *)dict withHandler:(HansServer_Request_Handler)handler;

/*
 Not work at UIApplicationStateBackground
*/
-(NSURLSessionDataTask * _Nullable )postManyDataURL:(NSString *)urlpath body:(NSDictionary *)bodyDictionary  withHandler:(HansServer_Request_Handler)post_handler withProgress:(HansServer_Progress)progressHandler;

-(NSURLSessionDataTask * _Nullable )postDataURL:(NSString *)urlpath data:(NSData *)data fileName:(NSString *)filename datakey:(NSString *)datatag withHandler:(HansServer_Request_Handler)handler withProgress:(HansServer_Progress)progressHandler;

//return NSDjangoAppleUserObject when success.
//return nil when not login etc.
-(void)who:(HansServer_Who_Handler)handler;

-(BOOL)loginUserName:(NSString *)username password:(NSString *)password WithHandler:(HansServer_Login_Handler)handler;

-(BOOL)signupUserName:(NSString *)username password:(NSString *)password WithHandler:(HansServer_Login_Handler)handler;

-(void)logoutWithHandler:(HansServer_Logout_Handler)handler;

-(BOOL)resetPassowrd:(NSString *)email withHandler:(HansServer_Request_Handler)handler;

//load apple user's information, user will be create when userID NOT exist in server
-(BOOL)hansiOSUserLoad:(NSString *)userID accessToken:(NSString * _Nullable)accessToken refreshToken:(NSString * _Nullable)refreshToken firstName:(NSString * _Nullable)firstName lastName:(NSString *_Nullable)lastName email:(NSString * _Nullable)email withHandler:(HansServer_Login_Handler)loginHandler;

//更新用户的信息，value 是更新的结果，key是更新的
-(void)updateUserString:(NSString *)value forKey:(NSString *)key;

//更新用户头像
-(void)updateUserFace:(NSData *)faceData;

//提示其他用户
-(BOOL)notificationUserID:(NSString *)userID withTitle:(NSString *)title text:(NSString * _Nullable )text;

//
-(BOOL)loadUserFace:(NSString *)userID withHandler:(HansServer_UserFace_Handler)handler;

-(BOOL)canRegisterUserName:(NSString *)tryUserName withHandler:(HansServer_Check_Username_Handler)handler;

-(BOOL)registerUserName:(NSString *)username password:(NSString *)password handler:(HansServer_Register_Handler)handler;

/*
 delete user
 */
-(BOOL)deletionUserwithHandler:(HansServer_Deletion_Handler)handler;


//for Share Extension App groups.
// set django account in main app
//return success
-(BOOL)shareExtensionUpdateAppGroupsIdentifier:(NSString *)appGroupsIdentifier;

//load django account in Share Extersion app
//return Load_ShareExtension_Result
-(Load_ShareExtension_Result)shareExtensionLoadAppGroupsIdentifier:(NSString *)appGroupsIdentifier withHandler:(HansServer_Login_Handler)handler;

//return Dictionary about Account
-(NSDictionary *)accountDictionaryForWatchOS;
/*
 -(void)startWCSessionForWatchOS{
     WCSession.defaultSession.delegate = self;
     [WCSession.defaultSession activateSession];
 }

 #pragma mark - WCSessionDelegate
 - (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error __IOS_AVAILABLE(9.3) __WATCHOS_AVAILABLE(2.2){
     if (NO == [session isPaired]){
         NSLog(@"No paired watch.");
         return;
     }
     
     if (NO == session.watchAppInstalled){
         NSLog(@"Watch not install iosWithDjango!");
         return;
     }
     
     BOOL reach = [session isReachable];
     if (NO == reach){
         NSLog(@"WCSession NOT reachable.");
     }
     return;
 }

 -(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler{
     NSString *order = [message valueForKey:@"Order"];
     if ([order isEqualToString:@"Account"]){
         replyHandler([HansServer.shareServer accountDictionaryForWatchOS]);
         return;
     }
     replyHandler([NSDictionary dictionary]);
     return;
 }
 */
@end
NS_ASSUME_NONNULL_END
