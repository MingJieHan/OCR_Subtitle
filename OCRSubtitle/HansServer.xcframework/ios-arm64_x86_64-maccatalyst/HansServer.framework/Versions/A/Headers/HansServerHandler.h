//
//  HansServerHandler.h
//  iOSWithDjango
//
//  Created by jia yu on 2021/7/21.
//

#ifndef HansServerHandler_h
#define HansServerHandler_h
@class HansServerUserObject;
typedef void (^HansServer_Login_Handler)(BOOL success, HansServerUserObject * _Nullable user, NSString * _Nullable error);
typedef void (^HansServer_Logout_Handler)(BOOL success, NSString * _Nullable error);

typedef void (^HansServer_Request_Handler)(NSString * _Nullable html,
                                           NSDictionary * _Nullable responseDictionary,
                                           NSString * _Nullable error);
typedef void (^HansServer_Progress)(double progess);
typedef void (^HansServer_Who_Handler)(HansServerUserObject * _Nullable user, NSString * _Nullable error);
typedef void (^HansServer_Check_Username_Handler) (BOOL available);
typedef void (^HansServer_Register_Handler) (HansServerUserObject * _Nullable user);
typedef void (^HansServer_Deletion_Handler) (BOOL success, NSString * _Nullable error);
typedef void (^HansServer_UserFace_Handler) (NSData * _Nullable faceData);



typedef NS_ENUM(NSInteger, Load_ShareExtension_Result) {
    Load_ShareExtension_Result_NoInformation = 5,           //NO update share extension in main app
    Load_ShareExtension_Result_Login_isRunning = 6,         //Login is runing now.
    Load_ShareExtension_Result_Login_Aleady = 7,            //已经登录了
    Load_ShareExtension_Result_Completed = 8                //正在载入group账号信息
};
#endif /* HansServerHandler_h */
