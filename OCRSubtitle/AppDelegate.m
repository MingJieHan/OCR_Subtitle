//
//  AppDelegate.m
//  LoadText
//
//  Created by jia yu on 2024/10/25.
//

#import "AppDelegate.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

-(void)newScan{
    [ViewController.shared scanVideoFromMenuInCatalyst];
    return;
}

-(void)buildMenuWithBuilder:(id<UIMenuBuilder>)builder{
    [builder removeMenuForIdentifier:UIMenuHelp];       //删除help菜单
    [builder removeMenuForIdentifier:UIMenuEdit];       //删除编辑菜单
    [builder removeMenuForIdentifier:UIMenuView];       //
    [builder removeMenuForIdentifier:UIMenuFormat];     //

    UIKeyCommand *commandOpen = [UIKeyCommand commandWithTitle:@"Scan Video" image:nil action:@selector(newScan) input:@"S" modifierFlags:UIKeyModifierCommand propertyList:nil];
    UIMenu *m = [UIMenu menuWithTitle:@"" image:nil identifier:nil options:UIMenuOptionsDisplayInline children:@[commandOpen]];
    [builder insertChildMenu:m atStartOfMenuForIdentifier:UIMenuFile];
    return;
    
    /*
    superVH = [[NSUserDefaults.standardUserDefaults valueForKey:SUPER_VH_SWITCH_KEY] boolValue];
    
//    UIMenuIdentifier patientsID = @"PatientMenuIdentifier";
    commandPatients = [UIKeyCommand commandWithTitle:@"Patients" image:nil action:@selector(patientsMenuAction) input:@"P" modifierFlags:UIKeyModifierCommand propertyList:nil];
    UIMenuIdentifier schemeID = @"SchemeMenuIdentifier";
    UIMenu *menuScheme = nil;
    if (superVH){
        UIKeyCommand *commandHistory = [UIKeyCommand commandWithTitle:@"Last Opend" image:nil action:@selector(openHistory) input:@"L" modifierFlags:UIKeyModifierCommand propertyList:nil];
        menuScheme = [UIMenu menuWithTitle:@"Scheme" image:nil identifier:schemeID options:UIMenuOptionsDisplayInline children:@[commandPatients,commandHistory]];
    }else{
        menuScheme = [UIMenu menuWithTitle:@"Scheme" image:nil identifier:schemeID options:UIMenuOptionsDisplayInline children:@[commandPatients]];
    }
    [builder insertChildMenu:menuScheme atStartOfMenuForIdentifier:UIMenuFile];

    UIMenuIdentifier testerID = @"TesterMenuIdentifier";
    if (superVH){
        UIKeyCommand *commandOpen = [UIKeyCommand commandWithTitle:@"Open" image:nil action:@selector(openExistvhStressTestECG) input:@"O" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *commandTester = [UIKeyCommand commandWithTitle:@"Tester" image:nil action:@selector(testerMenuAction) input:@"T" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *menuHome = [UIKeyCommand commandWithTitle:@"Home Folder" image:nil action:@selector(homeMenuAction) input:@"H" modifierFlags:UIKeyModifierCommand propertyList:nil];
        menuShowStaticConfirmViewCommand = [UIKeyCommand commandWithTitle:@"Show Static" image:nil action:@selector(showStaticConfirmViewAction) input:@"S" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *menuExportPretestECGs = [UIKeyCommand commandWithTitle:@"Export Pretest ECG" image:nil action:@selector(exportPretestECGs) input:@"E0" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *menuExportDeepbreathingECGs = [UIKeyCommand commandWithTitle:@"Export Deepbreathing ECG" image:nil action:@selector(exportDeepbreathingECGs) input:@"E1" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *menuExportWarmupECGs = [UIKeyCommand commandWithTitle:@"Export Warmup ECG" image:nil action:@selector(exportWarmupECGs) input:@"E2" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *menuExportRunningECGs = [UIKeyCommand commandWithTitle:@"Export Running ECG" image:nil action:@selector(exportRunningECGs) input:@"E3" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIKeyCommand *menuRepairStressTests = [UIKeyCommand commandWithTitle:@"Repair PredHR zero" image:nil action:@selector(repairMaxPredHRZero) input:@"R1" modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIMenu *menuTester = [UIMenu menuWithTitle:@"Tester" image:nil identifier:testerID options:UIMenuOptionsDisplayInline children:@[commandOpen,commandTester,menuHome,menuShowStaticConfirmViewCommand,
            menuExportPretestECGs,menuExportDeepbreathingECGs,menuExportWarmupECGs,menuExportRunningECGs,menuRepairStressTests]];
        [builder insertChildMenu:menuTester atStartOfMenuForIdentifier:UIMenuFile];
    }
    
    if (nil == commandPreference){
        UIMenuIdentifier preferenceID = @"vhPreference";
        commandPreference = [UIKeyCommand commandWithTitle:@"Preferences" image:nil action:@selector(preferenceSettingsAction) input:@"," modifierFlags:UIKeyModifierCommand propertyList:nil];
        UIMenu *menuPreference = [UIMenu menuWithTitle:@"Preference" image:nil identifier:preferenceID options:UIMenuOptionsDisplayInline children:@[commandPreference]];
        [builder insertSiblingMenu:menuPreference afterMenuForIdentifier:UIMenuAbout];
    }

    //remove system preferences.
    UIMenu *systemM = [builder menuForIdentifier:UIMenuPreferences];
    if (systemM){
        [builder removeMenuForIdentifier:UIMenuPreferences];
    }
    
    
    //Debug
//    [builder removeMenuForIdentifier:UIMenuView];
//    [builder removeMenuForIdentifier:UIMenuFullscreen];
    
    
    //在 UIMenuFile 后面，加入主菜单项目 Menu Group
//    UIMenuIdentifier groupID = @"groupmenuidentifier";
//    UIKeyCommand *command2 = [UIKeyCommand commandWithTitle:@"ACC" image:nil action:@selector(acc) input:@"D" modifierFlags:UIKeyModifierShift propertyList:nil];
//    UIMenu *m = [UIMenu menuWithTitle:@"Menu Group" image:nil identifier:groupID options:UIMenuOptionsDestructive children:@[command2]];
//    [builder insertSiblingMenu:m afterMenuForIdentifier:UIMenuFile];

    
    //在Menu Group 中，在加上2个菜单
//    UIMenuIdentifier myID = @"MyMenuIdentifier";
//    UIKeyCommand *command = [UIKeyCommand commandWithTitle:@"Hans" image:nil action:@selector(abc) input:@"h" modifierFlags:UIKeyModifierShift propertyList:nil];
//    UIKeyCommand *command1 = [UIKeyCommand commandWithTitle:@"Abcd" image:nil action:@selector(abcd) input:@"C" modifierFlags:UIKeyModifierControl propertyList:nil];
//    UIMenu *menu = [UIMenu menuWithTitle:@"open" image:nil identifier:myID options:UIMenuOptionsDisplayInline children:@[command,command1]];
//    [builder insertChildMenu:menu atStartOfMenuForIdentifier:groupID];

    //带子菜单列表的项目
//    UIKeyCommand *command3 = [UIKeyCommand commandWithTitle:@"Hans" image:nil action:@selector(add) input:@"f" modifierFlags:UIKeyModifierCommand|UIKeyModifierShift propertyList:nil];
//    UIMenu *m1 = [UIMenu menuWithTitle:@"Groups" image:nil identifier:@"ddd" options:UIMenuOptionsDisplayInline children:@[command3]];
//    [builder insertChildMenu:m1 atStartOfMenuForIdentifier:myID];
    */
    
    /*
     input 快捷键不可重复
     action 目标也不可以重复
     否则加不上
     */
    return;
}
@end
