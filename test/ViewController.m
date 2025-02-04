//
//  ViewController.m
//  test
//
//  Created by jia yu on 2024/11/6.
//

#import "ViewController.h"
#import <Vision/Vision.h>
#import "TTT.h"
@interface ViewController ()

@end

@implementation ViewController
-(UIImage *)imageFromString:(NSString *)str{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 1920.f, 60.f)];
    l.text = str;
    l.textColor = [UIColor whiteColor];
    l.textAlignment = NSTextAlignmentCenter;
    l.font = [UIFont fontWithName:@"PingFangSC-Regular" size:48.f];
    l.backgroundColor = [UIColor clearColor];
    
    UIGraphicsBeginImageContext(l.bounds.size);
    [l.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


-(VNFeaturePrintObservation *)observeFromImage:(nullable CGImageRef)cgImage{
    NSDictionary *opt = [NSDictionary dictionary];
    VNImageRequestHandler *handler2 = [[VNImageRequestHandler alloc] initWithCGImage:cgImage options:opt];
    VNGenerateImageFeaturePrintRequest *request2 = [[VNGenerateImageFeaturePrintRequest alloc] init];
    NSError *error = nil;
    BOOL success = [handler2 performRequests:@[request2] error:&error];
    if (NO == success){
        return nil;
    }
    VNFeaturePrintObservation *obs = request2.results.firstObject;
    return obs;
}

-(void)compareString:(NSString *)str1 withString:(NSString *)str2{
    UIImage *i1 = [self imageFromString:str1];
    UIImage *i2 = [self imageFromString:str2];
    VNFeaturePrintObservation *obs1 = [self observeFromImage:i1.CGImage];
    VNFeaturePrintObservation *obs2 = [self observeFromImage:i2.CGImage];
    float distance;
    NSError *error = nil;
    [obs1 computeDistance:&distance toFeaturePrintObservation:obs2 error:&error];
    NSLog(@"%@ compare: %@", str1, str2);
    if (distance > 0.35f){
        NSLog(@"不同 %.5f", distance);
    }else{
        NSLog(@"相同 %.5f", distance);
    }
    NSLog(@"\n");
    
    
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obs1 requiringSecureCoding:YES error:&error];

    NSError *error1 = nil;
    VNFeaturePrintObservation *obs4 = [NSKeyedUnarchiver unarchivedObjectOfClass:[VNFeaturePrintObservation class] fromData:data error:&error1];
    
    [obs4 computeDistance:&distance toFeaturePrintObservation:obs2 error:&error];
    NSLog(@"%@ compare: %@", str1, str2);
    if (distance > 0.35f){
        NSLog(@"不同 %.5f", distance);
    }else{
        NSLog(@"相同 %.5f", distance);
    }
    NSLog(@"\n");
    return;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *arrayFrom = [[NSMutableArray alloc] init];
    for (int i=0;i<100;i++){
        TTT *tSource = [[TTT alloc] init];
        tSource.str = [[NSString alloc] initWithFormat:@"个视频 %d 中截获的一张", i];
        [arrayFrom addObject:tSource];
    }
    
    NSError *error = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arrayFrom requiringSecureCoding:YES error:&error];
    
    NSSet *set = [NSSet setWithArray:@[[NSMutableArray class],[TTT class]]];
    NSMutableArray *resultArray = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:data error:&error];
//    NSArray *resultArray = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSArray class] fromData:data error:&error];
    if (error){
        NSLog(@"%@", error.localizedDescription);
    }
    NSLog(@"%@", resultArray);
    
    return;

    NSDate *s = NSDate.date;
    NSArray *a1 = @[@"从这个视频中截获的一张图",@"你看有飞鸟",@"电池给我",@"就在天花上对吧",@"其缴纳工伤保险的具体方式",@"使工份职工得到及时救治",@"职业病危窖职工发生工伤时"];
    NSArray *a2 = @[@"从这个视频中截获的二张图",@"你看有飞乌",@"甩池给我",@"就在天花板上对吧",@"其缴纳亚伤保险的具体方式",@"使工伤职工得到及时救治",@"职业病危害职工发生工伤时"];

    
    for (NSUInteger index = 0; index<a1.count; index ++){
        [self compareString:[a1 objectAtIndex:index] withString:[a2 objectAtIndex:index]];
    }
    NSTimeInterval t = [NSDate.date timeIntervalSinceDate:s];
    NSLog(@"Usage:%.5f", t);

    return;
    NSString *file = [NSHomeDirectory() stringByAppendingString:@"/Documents/abc.png"];
//    [UIImagePNGRepresentation(i) writeToFile:file atomically:YES];
    NSLog(@"File:%@", file);
    
//    UIImage *i1 = [[UIImage alloc] initWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"test1" ofType:@"png"]];
    UIImage *i1 = [self imageFromString:@"职业病危害职工发生工伤时"];
//    UIImage *i2 = [[UIImage alloc] initWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"test2" ofType:@"png"]];
//    UIImage *i2 = [self imageFromString:@"职业病危"];
    UIImage *i2 = [self imageFromString:@"职业病危窖职工发生工伤时"];
    
    
    VNFeaturePrintObservation *obs1 = [self observeFromImage:i1.CGImage];
    VNFeaturePrintObservation *obs2 = [self observeFromImage:i2.CGImage];

    
    float distance;
    [obs1 computeDistance:&distance toFeaturePrintObservation:obs2 error:&error];
    if (distance > 0.3f){
        NSLog(@"不同 %.5f", distance);
    }else{
        NSLog(@"相同 %.5f", distance);
    }
    return;
}


@end
