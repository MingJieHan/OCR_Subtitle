//
//  NSDjangoAppleUserObject.h
//  django
//
//  Created by Han Mingjie on 2020/12/11.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
@interface HansServerUserObject : NSObject
@property (nonatomic,readonly) NSString *accountID;
@property (nonatomic,readonly) NSString *username;
@property (nonatomic) NSString *firstName;
@property (nonatomic) NSString *lastName;
@property (nonatomic) NSString *email;
@property (nonatomic,readonly) BOOL email_verify;
@property (nonatomic) NSString *nickName;
@property (nonatomic) NSString *mobile;
@property (nonatomic,readonly) BOOL mobile_verify;
@property (nonatomic) NSString *whatup;
@property (nonatomic) NSData *face;
@property (nonatomic,readonly) NSDate * _Nullable lastSigninDate;
@property (nonatomic,readonly) NSString * _Nullable expireString;
@property (nonatomic,readonly) NSString * _Nullable token;
@property (nonatomic,readonly) NSString * _Nullable sessionID;
@property (nonatomic,readonly) NSDate * _Nullable expireDate;
@property (nonatomic,readonly) NSMutableArray <NSDictionary *>*devicesArray;

-(id)initWithDictionary:(NSDictionary *)dict response:(NSDictionary * _Nullable )responseDictionary;

-(BOOL)isDjangoUser;
-(BOOL)isAppleIDUser;

/*
 return nil when the nickName and firstName and lastName and email are empty.
 */
-(NSString * _Nullable )description;


/*
 return user object when signin success before and Not Signout.
 */
+(HansServerUserObject * _Nullable )loadCachedUser;
+(void)cleanCachedUser; //call it when signout
-(void)cachedUser;  //create cached for this user, it is replace other user.
@end
NS_ASSUME_NONNULL_END
