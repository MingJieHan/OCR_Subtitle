//
//  OCRTemplateTableViewController.m
//  OCR_Subtitle
//
//  Created by jia yu on 2025/2/11.
//

#import "OCRTemplateTableViewController.h"
#import "OCRLanguagesTableViewController.h"
#import "OCRSetting.h"
#import "HansBorderLabel.h"
#import "OCRGetTextFromImage.h"
#import <HansServer/HansServer.h>

#define CELL_KEY_NAME @"CELL_KEY_NAME"
#define CELL_KEY_LANGUAGES @"CELL_KEY_LANGUAGES"
#define CELL_KEY_RATE @"CELL_KEY_RATE"
#define CELL_KEY_TextColor @"CELL_KEY_TextColor"
#define CELL_KEY_BorderColor @"CELL_KEY_BorderColor"

@interface OCRTemplateTableViewController ()<UIColorPickerViewControllerDelegate>{
    UILabel *rateLabel;
    UISlider *rateSlider;
    UIColorPickerViewController *textColorPicker;
    UIColorPickerViewController *borderColorPicker;
    HansBorderLabel *textDemoLabel;
    HansBorderLabel *borderDemoLabel;
    BOOL changed;
}
@end

@implementation OCRTemplateTableViewController
@synthesize setting;
@synthesize changedHandler;

#pragma mark - System
-(id)initWithSetting:(OCRSetting *)_setting{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self){
        setting = _setting;
        changed = NO;
        if (nil == setting.name){
            self.title = @"Unname";
        }else{
            self.title = setting.name;
        }
    }
    return self;
}
-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
}

#pragma mark - My Functions
-(void)openLanguages{
    OCRLanguagesTableViewController *v = [[OCRLanguagesTableViewController alloc] init];
    v.selectedLanguages = [[NSMutableArray alloc] initWithArray:setting.subtitleLanguages];
    v.saveHandler = ^(OCRLanguagesTableViewController * _Nonnull vc) {
        self->setting.subtitleLanguages = vc.selectedLanguages;
        self->changed = YES;
        [self->setting save];
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
    };
    [self.navigationController pushViewController:v animated:YES];
}

-(void)close{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self->changed && self->changedHandler){
            self->changedHandler(self);
        }
    }];
}

-(void)rateChanged:(id)sender{
    setting.rate = (int)rateSlider.value;
    if (rateLabel){
        rateLabel.text = [NSString stringWithFormat:@"%d t/S", setting.rate];
    }
    changed = YES;
    [setting save];
    return;
}

- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)viewController{
    return;
}
-(void)closeColorSelector{
    changed = YES;
    [setting save];
    if (textDemoLabel){
        textDemoLabel.fontColor = setting.textColor;
        textDemoLabel.borderColor = setting.borderColor;
    }
    if (borderDemoLabel){
        borderDemoLabel.fontColor = setting.textColor;
        borderDemoLabel.borderColor = setting.borderColor;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    return;
}

-(void)cleanTextColor:(id)sender{
    setting.textColor = nil;
    [self closeColorSelector];
    return;
}
-(void)saveTextColor:(id)sender{
    setting.textColor = textColorPicker.selectedColor;
    [self closeColorSelector];
    return;
}
-(void)setTextColor{
    textColorPicker = [[UIColorPickerViewController alloc] init];
    textColorPicker.view.backgroundColor = [UIColor whiteColor];
    textColorPicker.selectedColor = setting.textColor;
    textColorPicker.modalInPresentation = NO;
    textColorPicker.delegate = self;
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveTextColor:)];
    UIBarButtonItem *cleanItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(cleanTextColor:)];
    textColorPicker.navigationItem.rightBarButtonItems = @[saveItem, cleanItem];
    textColorPicker.title = @"Text Color";
    [self.navigationController pushViewController:textColorPicker animated:YES];
    return;
}

-(void)cleanBorderColor:(id)sender{
    setting.borderColor = nil;
    [self closeColorSelector];
    return;
}
-(void)saveBorderColor:(id)sender{
    setting.borderColor = borderColorPicker.selectedColor;
    [self closeColorSelector];
    return;
}
-(void)setBorderColor{
    borderColorPicker = [[UIColorPickerViewController alloc] init];
    borderColorPicker.view.backgroundColor = [UIColor whiteColor];
    borderColorPicker.selectedColor = setting.borderColor;
    borderColorPicker.modalInPresentation = NO;
    borderColorPicker.delegate = self;
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveBorderColor:)];
    UIBarButtonItem *cleanItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(cleanBorderColor:)];
    borderColorPicker.navigationItem.rightBarButtonItems = @[saveItem,cleanItem];
    borderColorPicker.title = @"Border Color";
    [self.navigationController pushViewController:borderColorPicker animated:YES];
    return;
}

-(void)setName{
    HansLineStringEditViewController *v = [[HansLineStringEditViewController alloc] init];
    v.title = @"Template Name";
    v.defaultValue = setting.name;
    v.handler = ^(BOOL _changed, NSString * _Nullable value) {
        if (_changed){
            self->setting.name = value;
            [self->setting save];
            self.title = self->setting.name;
            NSIndexPath *nameIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[nameIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            self->changed = _changed;
        }
        [self.navigationController popViewControllerAnimated:YES];
    };
    [self.navigationController pushViewController:v animated:YES];
    return;
}

-(NSString *)identifierWith:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:return CELL_KEY_NAME;
        case 1:return CELL_KEY_LANGUAGES;
        case 2:return CELL_KEY_RATE;
        case 3:return CELL_KEY_TextColor;
        case 4:return CELL_KEY_BorderColor;
        default:
            break;
    }
    return @"ccc";
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self identifierWith:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
    }
    if ([identifier isEqualToString:CELL_KEY_LANGUAGES]){
        cell.textLabel.text = NSLocalizedString(@"Languages:",nil);
        cell.detailTextLabel.text = [OCRGetTextFromImage stringForLanguageCode:setting.subtitleLanguages.firstObject];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if ([identifier isEqualToString:CELL_KEY_RATE]){
        cell.textLabel.text = NSLocalizedString(@"Sample rate:",nil);
        if (nil == rateLabel){
            rateLabel = cell.detailTextLabel;
            rateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d t/S",nil), setting.rate];
        }
        if (nil == rateSlider){
            rateSlider = [[UISlider alloc] initWithFrame:CGRectMake(170.f, 18.f, cell.frame.size.width-190.f, 10.f)];
            rateSlider.minimumValue = 1.f;
            rateSlider.maximumValue = 10.f;
            rateSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [rateSlider addTarget:self action:@selector(rateChanged:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:rateSlider];
        }
        rateSlider.value = setting.rate;
    }else if ([identifier isEqualToString:CELL_KEY_TextColor]){
        cell.textLabel.text = NSLocalizedString(@"Text Color:",nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (nil == textDemoLabel){
            textDemoLabel = [[HansBorderLabel alloc] initWithFrame:CGRectMake(cell.frame.size.width-130.f, 7.f, 90.f, 30.f)];
            textDemoLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            textDemoLabel.backgroundColor = [UIHans colorFromHEXString:@"B3FCC8"];
            textDemoLabel.layer.masksToBounds = YES;
            textDemoLabel.layer.cornerRadius = 3.f;
            textDemoLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24.f];
            textDemoLabel.text = NSLocalizedString(@"Text",nil);
            [cell addSubview:textDemoLabel];
        }
        textDemoLabel.fontColor = setting.textColor;
        textDemoLabel.borderColor = setting.borderColor;
    }else if ([identifier isEqualToString:CELL_KEY_BorderColor]){
        cell.textLabel.text = NSLocalizedString(@"Border Color:",nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (nil == borderDemoLabel){
            borderDemoLabel = [[HansBorderLabel alloc] initWithFrame:CGRectMake(cell.frame.size.width-130.f, 7.f, 90.f, 30.f)];
            borderDemoLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            borderDemoLabel.backgroundColor = [UIHans colorFromHEXString:@"B3FCC8"];
            borderDemoLabel.layer.masksToBounds = YES;
            borderDemoLabel.layer.cornerRadius = 3.f;
            borderDemoLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:24.f];
            borderDemoLabel.text = NSLocalizedString(@"Border",nil);
            [cell addSubview:borderDemoLabel];
        }
        borderDemoLabel.fontColor = setting.textColor;
        borderDemoLabel.borderColor = setting.borderColor;
    }else if ([identifier isEqualToString:CELL_KEY_NAME]){
        cell.textLabel.text = NSLocalizedString(@"Name:", nil);
        cell.detailTextLabel.text = setting.name;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = [self identifierWith:indexPath];
    if ([identifier isEqualToString:CELL_KEY_LANGUAGES]){
        [self openLanguages];
    }else if ([identifier isEqualToString:CELL_KEY_TextColor]){
        [self setTextColor];
    }else if ([identifier isEqualToString:CELL_KEY_BorderColor]){
        [self setBorderColor];
    }else if ([identifier isEqualToString:CELL_KEY_NAME]){
        [self setName];
    }
    return;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return [NSString stringWithFormat:NSLocalizedString(@"Video dimensions: %d x %d ONLY.\nCreate at:%@", nil),
            [setting.videoWidth intValue],
            [setting.videoHeight intValue],
            [setting.createDate stringValue]];
}
@end
