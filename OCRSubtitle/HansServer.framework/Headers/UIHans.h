//
//  UIHans.h
//  HansServer
//
//  Created by jia yu on 2021/10/13.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIHans : NSObject
+(UIHans *)defaultUIHans;

/*
 return current ViewController for presentViewController etc.
 */
+(UIViewController *)currentVC;

+(void)alertTitle:(NSString * _Nonnull )title
    withMessage:(NSString * _Nullable )message
      withHandler:(void (^ __nullable)(UIAlertAction *action))handler NS_EXTENSION_UNAVAILABLE_IOS("");

+(void)alertTitle:(NSString * _Nonnull )title withMessage:(NSString * _Nullable )message NS_EXTENSION_UNAVAILABLE_IOS("");

+(void)alertSystemSettings NS_EXTENSION_UNAVAILABLE_IOS("");

//Open ViewController with Content for previewURL as in Files.
+(BOOL)alertPreviewWithURL:(NSURL *)previewURL;

/*
 Colors Tools
 UIColor to NSString
 NSString to UIColor
 */
+(NSString *)colorConvertString:(UIColor * _Nonnull)color;
+(UIColor * _Nullable )colorFrom:(NSString * _Nonnull)colorString;

+(UIColor * _Nullable)colorFromHEXString:(NSString * _Nonnull)rgb;
+(UIColor * _Nullable)colorFromHEXString:(NSString * _Nonnull)rgb withAlpha:(float)alpha;

+(UIColor * _Nonnull)white;
+(UIColor * _Nonnull)black;
+(UIColor * _Nonnull)gray;
+(UIColor * _Nonnull)lightGray;
+(UIColor * _Nonnull)lightestGray;

+(UIColor * _Nonnull)red;               //
+(UIColor * _Nonnull)redHighlighted;    //

+(UIColor * _Nonnull)blue;
+(UIColor * _Nonnull)blueHighlighted;

+(UIColor * _Nonnull)green;
+(UIColor * _Nonnull)greenHighlighted;

#pragma mark - Play Video
//play end  currentPlayingSeconds > duration

//Turn ON Project’s  Settings->Signing&Capabilities->Background Modes->Audio, Airplay, and Picture in Picture.
+(NSError *)playLocalVideo:(NSString *)localVideoFilePathName
    withHandler:(void (^ __nullable)(int currentPlayingSeconds))playingHandler API_AVAILABLE(macos(13.0), ios(16.0), tvos(16.0), watchos(9.0));

+(NSError *)playLocalVideo:(NSString *)localVideoFilePathName;

+(NSError *)playLocalVideo:(NSString *)localVideoFilePathName
            withRate:(float)rate
        withHandler:(void (^ __nullable)(int currentPlayingSeconds))playingHandler API_AVAILABLE(macos(13.0), ios(16.0), tvos(16.0), watchos(9.0));

+(NSError *)playLocalVideo:(NSString *)localVideoFilePathName
            withRate:(float)rate
          withBeginSeconds:(int)beginSeconds
        withHandler:(void (^ __nullable)(int currentPlayingSeconds))playingHandler;

+(NSError *)playLocalVideo:(NSString *)localVideoFilePathName withRate:(float)rate API_AVAILABLE(macos(13.0), ios(16.0), tvos(16.0), watchos(9.0));

+(CMTime)thumbnailImageForVideoURL:(NSString *)videoURL 
                 completionHandler:(void (^)(UIImage *))completionHandler;

+(BOOL)thumbnailForVideoURL:(NSURL *)videoURL
                   withSeek:(float)seekSeconds
                   withSize:(CGSize)requestSize
          completionHandler:(void (^)(UIImage *))completionHandler;

+(BOOL)imagesFromVideoURL:(NSURL *)videoURL
                   withSeek:(float)seekSeconds
        completionHandler:(void (^)(NSArray <UIImage *>*))completionHandler;
#pragma mark - Other
+ (NSError *)shareFile:(NSString *)file;
+ (NSError *)shareFile:(NSString *)file withName:(NSString *)fileName;
+ (NSError *)shareFile:(NSString *)file
              withName:(NSString *)fileName
           withExtName:(NSString *)extName
              withSize:(CGSize)popSize
         withArrowView:(UIView * _Nullable )sourceView
         withArrowFrom:(CGRect)fromRect;

+ (NSError *)shareFile:(NSString *)file withName:(NSString *)fileName withExtName:(NSString *)extName;
+ (NSURL *)createLinkForFile:(NSURL *)fileURL withName:(NSString *)fileName withExtName:(NSString *)extName;

//return Num of files.
+(NSInteger)emptyTemporaryDirectory;

+(NSString *)deviceInfo;

+(NSInteger)tryAlertRateApp:(NSString *)appName;

//return 1 MB;  2 GB; etc
+(NSString *)stringFileSize:(NSInteger)fileSize;

//return 23:34
+(NSString *)stringDuration:(NSInteger)seconds;

+(NSString *)urlEncodeWord:(NSString *)word;

+(NSString *)appVersion;
+(NSString *)appBuildVersion;

+(void)adjustLineSpace:(float)lineSpacing forView:(UITextView *)textView;

//Input like @"&ldquo;&#22914;&#26524;&#26377;&#20154;&#29486;&#32032;&#31085;&#32473;&#32822;";
//Return like @"如果有人献素祭给耶"
+(NSString *)replaceHTMLCodes:(NSString *)text;

+(UIImage *)buildSnapShotInto:(NSString *)file forView:(UIView *)sourceView;

//从照片库中选择照片后，照片文件中有方向描述，所以方向正确。但进行照片内容的局部获取时，方向有错误，本函数是用于修正方向问题的。
+(UIImage *)fixOrientation:(UIImage *)aImage;

//返回aImage左转后的结果
+(UIImage *)rotate_left:(UIImage *)aImage;


//return YES when Running in Macalyst
+(BOOL)isCatalystMacIdiom;
@end
NS_ASSUME_NONNULL_END
