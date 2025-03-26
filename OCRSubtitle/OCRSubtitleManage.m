//
//  OCRSubtitleManage.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/8.
//

#import "OCRSubtitleManage.h"
#import "OCRHistory.h"
#import "OCRSetting.h"
#import "OCRGetTextFromImage.h"

#define ENTITY_NAME_HISTORY_DATA @"OCRHistory"
#define ENTITY_NAME_SETTING_DATA @"OCRSetting"


static OCRSubtitleManage *staticOCRSubtitleManage;

@interface OCRSubtitleManage(){
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}
@end

@implementation OCRSubtitleManage

-(id)init{
    self = [super init];
    if (self){
        NSString *store_string = [NSHomeDirectory() stringByAppendingString:@"/Documents/OCRSubtitleData.sqlite"];
        NSURL *storeURL = [NSURL fileURLWithPath:store_string];
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"OCRSubtitleData" withExtension:@"momd"];
        managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        
        NSError *error = nil;
        NSPersistentStore *persistentStore = nil;
        if (nil == persistentStore){
            persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error];
            if (nil == persistentStore || error){
                NSLog(@"place store error.");
                return nil;
            }
        }
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
        [managedObjectContext persistentStoreCoordinator];
    }
    return self;
}

+(OCRSubtitleManage *)shared{
    if (nil == staticOCRSubtitleManage){
        staticOCRSubtitleManage = [[OCRSubtitleManage alloc] init];
    }
    return staticOCRSubtitleManage;
}

-(NSMutableArray *)existHistorys{
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME_HISTORY_DATA inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"completedDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
//    NSPredicate *p = [NSPredicate predicateWithFormat:@"(book == %@ AND chapter=%ld AND section >= %ld AND section <= %ld)", bookName, chapter, fromSection, toSection];
//    [fetchRequest setPredicate:p];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error filtering search: %@", [error description]);
        return nil;
    }
    return [[NSMutableArray alloc] initWithArray:fetchedObjects];
}

-(OCRHistory *)createOCRResult{
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME_HISTORY_DATA inManagedObjectContext:managedObjectContext];
    OCRHistory *result = [[OCRHistory alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
    return result;
}

-(void)initSettings{
    [OCRSetting default_1Setting];
    [OCRSetting default_2Setting];
    return;
}
-(NSMutableArray *)existSettings{
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME_SETTING_DATA inManagedObjectContext:managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"useDate" ascending:NO];
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"modifieDate" ascending:NO];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor2,sortDescriptor1,sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
//    NSPredicate *p = [NSPredicate predicateWithFormat:@"(book == %@ AND chapter=%ld AND section >= %ld AND section <= %ld)", bookName, chapter, fromSection, toSection];
//    [fetchRequest setPredicate:p];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"Error filtering search: %@", [error description]);
        return nil;
    }
    if (0 == fetchedObjects.count){
        [self initSettings];
        return [self existSettings];
    }
    NSMutableArray *results = [[NSMutableArray alloc] initWithArray:fetchedObjects];
    for (OCRSetting *res in results){
        [res initDatas];
    }
    return results;
}

-(OCRSetting *)createOCRSetting{
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME_SETTING_DATA inManagedObjectContext:managedObjectContext];
    OCRSetting *result = [[OCRSetting alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
    result.createDate = NSDate.date;
    result.rate = 5;
    return result;
}

-(BOOL)save{
    return [managedObjectContext save:nil];;
}

-(BOOL)removeItem:(NSManagedObject *)item{
    [managedObjectContext deleteObject:item];
    return [self save];
}


+(UIImageOrientation)imageOrientionFromCGAffineTransform:(CGAffineTransform)txf{
    UIImageOrientation oriention = UIImageOrientationUp;
    if (txf.a == 0 && txf.b == 1.0 && txf.c == -1.0 && txf.d == 0) {
        oriention = UIImageOrientationRight;
    }
    if (txf.a == 0 && txf.b == -1.0 && txf.c == 1.0 && txf.d == 0) {
        oriention = UIImageOrientationLeft;
    }
    if (txf.a == 1.0 && txf.b == 0 && txf.c == 0 && txf.d == 1.0) {
        oriention = UIImageOrientationUp;
    }
    if (txf.a == -1.0 && txf.b == 0 && txf.c == 0 && txf.d == -1.0) {
        oriention = UIImageOrientationDown;
    }
    return oriention;
}
@end
