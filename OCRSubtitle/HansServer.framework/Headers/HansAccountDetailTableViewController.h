//
//  UIAccountDetailTableViewController.h
//  iOSWithDjango
//
//  Created by jia yu on 2020/12/26.
//

#import <UIKit/UIKit.h>
#import <HansServer/HansServer.h>

NS_ASSUME_NONNULL_BEGIN
@interface HansAccountDetailTableViewController : UITableViewController
@property (nonatomic) HansServerUserObject *user;
-(void)newFaceAction:(UITableViewCell *)fromCell;
@end
NS_ASSUME_NONNULL_END
