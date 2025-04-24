//
//  HansDownloadWithPiece.h
//  HansServer
//
//  Created by jia yu on 2024/1/12.
//

#import <Foundation/Foundation.h>

//HansDownloadWithPiece Demo
//NSString *targetFile = [NSHomeDirectory() stringByAppendingString:@"/Documents/abc.mp4"];
//downloader = [[HansDownloadWithPiece alloc] initWithURL:@"https://hr.hanmingjie.com/static/2/080zh2cwWhY_19.mp4" withTargeFilePathName:targetFile withHandler:^(BOOL success) {
//    if (success){
//        [self->downloader actionWithHandler:^(NSString *completedFilePathName) {
//            NSLog(@"Download completed.");
//        }withProgressHandler:^(float progress) {
//            NSLog(@"Download progress: %.1f %%", progress * 100.f);
//        }];
//    }else{
//        NSLog(@"init failed.");
//    }
//}];

@class HansDownloadPiecesProgressView;
typedef NS_ENUM(NSInteger, HansDownloadState) {
    HansDownloadState_Waiting = 0,
    HansDownloadState_Running = 1,
    HansDownloadState_Completed = 2,
    HansDownloadState_Failed = 3
};
@class HansDownloadWithPiece;
typedef void (^HansDownloadInitedHandler) (HansDownloadWithPiece * _Nonnull worker,
                                           BOOL initedSuccess,
                                           NSString * _Nullable errorString);
typedef void (^HansDownloadCompletedHandler) (NSString * _Nonnull completedFilePathName);
typedef void (^HansDownloadProgressHandler) (float progress);


@interface HansDownloadWithPiece : NSObject
+(void)removeAllUncompletedFiles:(NSString * _Nonnull )path;
+(nullable NSArray <NSString *>*)scanUnCompletedTasks:(NSString * _Nonnull)path;
+(nonnull NSString *)existUncompletedTaskFileFromFileName:(NSString * _Nonnull)filePathName;
+(NSInteger)lastPieceSizeWithTargetFile:(NSString * _Nonnull)targetFile;

@property (nonatomic, readonly) NSString * _Nonnull sourceURL;
@property (nonatomic, readonly) NSInteger fileSize;
@property (nonatomic, readonly) NSMutableArray <NSNumber *> * _Nonnull pieces; //HansDownloadState
@property (nonatomic, readonly) HansDownloadPiecesProgressView * _Nonnull progressView;
@property (nonatomic, readonly) float progress;
@property (nonatomic, readonly) NSInteger maxThreadNum;
@property (nonatomic, readonly) NSInteger pieceSize;

-(nullable instancetype)init NS_UNAVAILABLE;

//numOfThread is 20, and pieceSize is 512 * 1024
-(nullable instancetype)initWithURL:(nonnull NSString *)url
        withTargeFilePathName:(nonnull NSString *)filePathName
        withHandler:(nonnull HansDownloadInitedHandler)handler;

-(nullable instancetype)initWithURL:(nonnull NSString *)url
      withThread:(NSInteger)numOfThread
    withPieceSize:(NSInteger)pieceSize
        withTargeFilePathName:(nonnull NSString *)filePathName
        withHandler:(nonnull HansDownloadInitedHandler)handler;

-(nullable instancetype)initWithURL:(nonnull NSString *)url
      withThread:(NSInteger)numOfThread
    withPieceSize:(NSInteger)pieceSize
      withHeaders:(nullable NSDictionary *)headersDict
        withTargeFilePathName:(nonnull NSString *)filePathName
        withHandler:(nonnull HansDownloadInitedHandler)handler;

//after init, play this function.
-(BOOL)actionWithHandler:(nonnull HansDownloadCompletedHandler)handler
    withProgressHandler:(nullable HansDownloadProgressHandler)progressHandler;

-(void)cancel;
@end
