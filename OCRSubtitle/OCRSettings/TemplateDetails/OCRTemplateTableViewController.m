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
#define CELL_KEY_SubtitleCenter @"CELL_KEY_SubtitleCenter"
#define CELL_KEY_DEBUGMODE @"CELL_KEY_DEBUGMODE"


@interface OCRTemplateTableViewController ()<UIColorPickerViewControllerDelegate>{
    UILabel *rateLabel;
    UISlider *rateSlider;
    UIColorPickerViewController *textColorPicker;
    UIColorPickerViewController *borderColorPicker;
    HansBorderLabel *textDemoLabel;
    HansBorderLabel *borderDemoLabel;
    UIHansSwitchView *subtitleCenterView;
    UIHansSwitchView *debugModeSwitch;
    BOOL changed;
}
@end

@implementation OCRTemplateTableViewController
@synthesize setting;
@synthesize changedHandler;

#pragma mark - System
-(id)initWithSetting:(OCRSetting *)_setting{
    self = [super initWithStyle:UITableViewStyleInsetGrouped];
    if (self){
        setting = _setting;
        changed = NO;
        self.title = NSLocalizedString(@"Template Editing", nil);
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
        rateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d t/S", nil), setting.rate];
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
    v.title = NSLocalizedString(@"Template Name", nil);
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
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:return CELL_KEY_NAME;
                case 1:return CELL_KEY_LANGUAGES;
                case 2:return CELL_KEY_RATE;
                default:
                    break;
            }
            break;}
        case 1:{
            switch (indexPath.row) {
                case 0:return CELL_KEY_TextColor;
                case 1:return CELL_KEY_BorderColor;
                case 2:return CELL_KEY_SubtitleCenter;
                default:
                    break;
            }
            break;
        }
        case 2:{
            switch (indexPath.row) {
                case 0:return CELL_KEY_DEBUGMODE;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    return @"";
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 3;
        case 1:
            return 3;
        case 2:
            return 1;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self identifierWith:indexPath];
    OCRTemplateTableViewController * __strong strongSelf = self;
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
    }else if ([identifier isEqualToString:CELL_KEY_SubtitleCenter]){
        cell.textLabel.text = NSLocalizedString(@"Subtitle Alignment", nil);
        cell.detailTextLabel.text = NSLocalizedString(@"Center", nil);
        if (nil == subtitleCenterView){
            subtitleCenterView = [[UIHansSwitchView alloc] init];
            [subtitleCenterView setFrame:CGRectMake((cell.frame.size.width - 90.f), 5.f, 80.f, 35.f)];
            subtitleCenterView.onLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.f];
            subtitleCenterView.onLabel.text = NSLocalizedString(@"On", nil);
            subtitleCenterView.offLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.f];
            subtitleCenterView.offLabel.text = NSLocalizedString(@"Off", nil);
            subtitleCenterView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            subtitleCenterView.handler = ^(UIHansSwitchView * _Nonnull view, BOOL on) {
                strongSelf->setting.checkSubtitleCenter = strongSelf->subtitleCenterView.on;
                strongSelf->changed = YES;
                return;
            };
            [cell addSubview:subtitleCenterView];
        }
        subtitleCenterView.on = setting.checkSubtitleCenter;
    }else if ([identifier isEqualToString:CELL_KEY_DEBUGMODE]){
        cell.textLabel.text = NSLocalizedString(@"Debug Mode", nil);
        cell.detailTextLabel.text = @"";
        if (nil == debugModeSwitch){
            debugModeSwitch = [[UIHansSwitchView alloc] init];
            [debugModeSwitch setFrame:CGRectMake((cell.frame.size.width - 90.f), 5.f, 80.f, 35.f)];
            debugModeSwitch.onLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.f];
            debugModeSwitch.onLabel.text = NSLocalizedString(@"On", nil);
            debugModeSwitch.offLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.f];
            debugModeSwitch.offLabel.text = NSLocalizedString(@"Off", nil);
            debugModeSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            debugModeSwitch.handler = ^(UIHansSwitchView * _Nonnull view, BOOL on) {
                strongSelf->setting.debugMode = strongSelf->debugModeSwitch.on;
                strongSelf->changed = YES;
            };
            [cell addSubview:debugModeSwitch];
        }
        debugModeSwitch.on = setting.debugMode;
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
    switch (section) {
        case 0:
            return [NSString stringWithFormat:NSLocalizedString(@"Video dimensions: %d x %d ONLY.\nCreate at:%@", nil),
                    [setting.videoWidth intValue],
                    [setting.videoHeight intValue],
                    [setting.createDate stringValue]];
        case 1:{
            NSString *a = NSLocalizedString(@"It is recommended that when the video resolution is higher than 1920x1080, after setting the text color and border color, the background image of the scan area will be filled during scanning to further improve the result quality.",nil);
            NSString *b = NSLocalizedString(@"Discard scanned text results that are not centered.", nil);
            return [NSString stringWithFormat:@"%@\n%@", a, b];}
        case 2:
            return NSLocalizedString(@"In order to improve this App, a small amount of storage space is used to store the scanning process information.",nil);
        default:
            break;
    }
    return @"";
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return NSLocalizedString(@"Basic:", nil);
        case 1:
            return NSLocalizedString(@"Advanced:",nil);
        case 2:
            return NSLocalizedString(@"Developer:",nil);
        default:
            break;
    }
    return @"";
}
@end
