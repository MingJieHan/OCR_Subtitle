//
//  HansSelectOneTableViewController.h
//  HansServer
//
//  Created by jia yu on 2021/8/8.
//

/*

 HansSelectOneTableViewController *v = [[HansSelectOneTableViewController alloc] init];
 v.title = @"Select One";
 v.defaultString = @"Abc";
 v.selectArray = @[@"123", @"224", @"4qewr", @"525", @"ccc", @"123", @"224", @"4qewr", @"525", @"ccc", @"123", @"224", @"4qewr", @"525", @"ccc", @"Abc", @"rrr", @"zoo"];
 v.handler = ^(BOOL changed, NSString * _Nullable value) {
     if (changed){
         NSLog(@"new value is:%@", value);
     }
 };
 [self.navigationController pushViewController:v animated:YES];
 return;
 
 */
#import <UIKit/UIKit.h>
typedef void (^HansSelectOneTableViewController_Handler)(BOOL changed, NSString * _Nullable value);

NS_ASSUME_NONNULL_BEGIN
@interface HansSelectOneTableViewController : UITableViewController
@property (nonatomic) NSArray <NSString *>*selectArray;
@property (nonatomic) NSString *defaultString;
@property (nonatomic) HansSelectOneTableViewController_Handler handler;

@property (nonatomic) CGFloat rowHeight;    //default is 44.
@property (nonatomic) UITableViewCellStyle cellStyle;   //defautl is UITableViewCellStyleDefault
@property (nonatomic) NSArray <NSString *>*selectDetailArray;       //option default is nil
@property (nonatomic) NSArray <UIImage *>*selectImageArray;         //option default is nil
@end
NS_ASSUME_NONNULL_END
