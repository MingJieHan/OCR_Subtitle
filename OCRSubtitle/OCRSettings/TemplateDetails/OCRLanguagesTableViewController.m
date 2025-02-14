//
//  OCRLanguagesTableViewController.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/11.
//

#import "OCRLanguagesTableViewController.h"
#import "OCRGetTextFromImage.h"


@interface OCRLanguagesTableViewController (){
    NSArray *availableLanguages;
}
@end

@implementation OCRLanguagesTableViewController
@synthesize selectedLanguages;
@synthesize saveHandler;
@synthesize oneLanguageOnly;

#pragma mark - System
-(id)init{
    self = [super init];
    if (self){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction)];
        availableLanguages = [OCRGetTextFromImage availableLanguages];
        NSLog(@"Available:%@", availableLanguages);
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - MyFunctions
-(void)setSelectedLanguages:(NSMutableArray *)_selectedLanguages{
    selectedLanguages = _selectedLanguages;
    
    //remove NOT exist language identifiers.
    NSMutableArray *removeErrorLanguageIdentifiers = [[NSMutableArray alloc] init];
    for (NSString *lI in selectedLanguages){
        if (![availableLanguages containsObject:lI]){
            [removeErrorLanguageIdentifiers addObject:lI];
        }
    }
    if (removeErrorLanguageIdentifiers.count > 0){
        [selectedLanguages removeObjectsInArray:removeErrorLanguageIdentifiers];
    }
    return;
}

-(void)saveAction{
    [self.navigationController popViewControllerAnimated:YES];
    if (saveHandler){
        saveHandler(self);
    }
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return availableLanguages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"Cell_Languages";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString *languageIdentifier = [availableLanguages objectAtIndex:indexPath.row];
    cell.textLabel.text = [OCRGetTextFromImage stringForLanguageCode:languageIdentifier];
    BOOL selected = NO;
    for (NSString *abc in selectedLanguages){
        if ([abc isEqualToString:languageIdentifier]){
            selected = YES;
            break;
        }
    }
    if (selected){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (UITableViewCellAccessoryCheckmark == cell.accessoryType){
        //Cancel this language.
        [selectedLanguages removeObject:[availableLanguages objectAtIndex:indexPath.row]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        return;
    }
    //select this language
    if (oneLanguageOnly){
        [selectedLanguages removeAllObjects];
    }
    [selectedLanguages addObject:[availableLanguages objectAtIndex:indexPath.row]];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    if (oneLanguageOnly){
        [self saveAction];
    }
    return;
}

@end
