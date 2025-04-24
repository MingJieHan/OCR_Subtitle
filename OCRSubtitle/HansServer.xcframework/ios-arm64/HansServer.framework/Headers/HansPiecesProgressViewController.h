//
//  HansPiecesProgressViewController.h
//  HansServer
//
//  Created by jia yu on 2024/2/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class HansDownloadPiecesProgressView;
@class HansDownloadWithPiece;
@class HansPiecesProgressViewController;
typedef void (^HansPiecesProgressViewController_Handler) (HansPiecesProgressViewController *viewController, BOOL downloadSuccess);


// 1024 > size > 10
typedef NS_ENUM(NSInteger, HansPieceSize) {
    HansPieceSize_WiFi = 512 * 1024,           //512 KB per piece
    HansPieceSize_5G = 20 * 1024               //20 KB per piece
};

@interface HansPiecesProgressViewController : UIViewController
@property (nonatomic, readonly) HansDownloadWithPiece *downloader;
@property (nonatomic, nullable) HansPiecesProgressViewController_Handler handler;
@property (nonatomic, readonly) UILabel *titleLabel;

-(id)init NS_UNAVAILABLE;
-(id)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
-(id)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;

-(id)initWithMediaURL:(NSString *)mediaURL withTargetFilePathName:(NSString *)targetFilePathName;

-(BOOL)canContinueDownload;
-(BOOL)continueDownload;

-(BOOL)start;
-(BOOL)startWith:(HansPieceSize)pieceSize;

@end

NS_ASSUME_NONNULL_END
