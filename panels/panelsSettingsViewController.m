//
//  panelsSettingsViewController.m
//  panels
//
//  Created by James A Hill on 08/04/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "panelsSettingsViewController.h"
#import "SWRevealViewController.h"

@interface panelsSettingsViewController () <SWRevealViewControllerDelegate>
@property (nonatomic) BOOL interactable;
@property (strong, nonatomic) UITapGestureRecognizer *cancelSidebar;
@property (strong, nonatomic) NSUserDefaults *defaults;
@end

@implementation panelsSettingsViewController

-(NSUserDefaults *)defaults {
    if(!_defaults) _defaults = [NSUserDefaults standardUserDefaults];
    return _defaults;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // SideBar config
    self.interactable = YES;
    //    NSLog(@"%lu",(unsigned long)[[self.shelf getWholeShelf] count]);
    self.revealViewController.delegate = self;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.revealViewController.rearViewRevealWidth = 250;
    self.cancelSidebar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:self.cancelSidebar];

    // Bar Buttons
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"row.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openMenu: ) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 28, 28)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UISwitch *firstSwitch = (UISwitch *)[self.view viewWithTag:101];
    [firstSwitch setOn:[self.defaults boolForKey:@"settingsStampComics"]];
    [firstSwitch addTarget:self action:@selector(moveStampToggle: ) forControlEvents:UIControlEventTouchUpInside];
    
    UISwitch *secondSwitch = (UISwitch *)[self.view viewWithTag:102];
    [secondSwitch setOn:[self.defaults boolForKey:@"settingsDefaultFirst"]];
    [secondSwitch addTarget:self action:@selector(defaultFirstToggle: ) forControlEvents:UIControlEventTouchUpInside];
    
    UISwitch *thirdSwitch = (UISwitch *)[self.view viewWithTag:103];
    [thirdSwitch setOn:[self.defaults boolForKey:@"settingsNotifications"]];
    [thirdSwitch addTarget:self action:@selector(notificationsToggle: ) forControlEvents:UIControlEventTouchUpInside];
    
    UISwitch *fourthSwitch = (UISwitch *)[self.view viewWithTag:104];
    [fourthSwitch setOn:[self.defaults boolForKey:@"settingsMarkRead"]];
    [fourthSwitch addTarget:self action:@selector(markReadToggle: ) forControlEvents:UIControlEventTouchUpInside];
    
    UISwitch *fifthSwitch = (UISwitch *)[self.view viewWithTag:105];
    [fifthSwitch setOn:[self.defaults boolForKey:@"settingsSound"]];
    [fifthSwitch addTarget:self action:@selector(soundToggle: ) forControlEvents:UIControlEventTouchUpInside];
}

- (void)moveStampToggle:(id)sender {
    UISwitch *aSwitch = (UISwitch *)sender;
    [self.defaults setBool:[aSwitch isOn] forKey:@"settingsStampComic"];
    [self.defaults synchronize];
    NSLog(@"Toggle trash: %hhd", [aSwitch isOn]);
}

- (void)defaultFirstToggle:(id)sender {
    UISwitch *aSwitch = (UISwitch *)sender;
    [self.defaults setBool:[aSwitch isOn] forKey:@"settingsDefaultFirst"];
    [self.defaults synchronize];
    NSLog(@"Toggle first: %hhd", [aSwitch isOn]);
}

- (void)notificationsToggle:(id)sender {
    UISwitch *aSwitch = (UISwitch *)sender;
    [self.defaults setBool:[aSwitch isOn] forKey:@"settingsNotifications"];
    [self.defaults synchronize];
    NSLog(@"Toggle notifications: %hhd", [aSwitch isOn]);
}

- (void)markReadToggle:(id)sender {
    UISwitch *aSwitch = (UISwitch *)sender;
    [self.defaults setBool:[aSwitch isOn] forKey:@"settingsMarkRead"];
    [self.defaults synchronize];
    NSLog(@"Toggle mark read: %hhd", [aSwitch isOn]);
}

- (void)soundToggle:(id)sender {
    UISwitch *aSwitch = (UISwitch *)sender;
    [self.defaults setBool:[aSwitch isOn] forKey:@"settingsSound"];
    [self.defaults synchronize];
    NSLog(@"Toggle sound: %hhd", [aSwitch isOn]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
        // self.view.userInteractionEnabled = YES;
        self.interactable = YES;
    } else {
        // self.view.userInteractionEnabled = NO;
        self.interactable = NO;
        self.cancelSidebar.enabled = YES;
    }
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
        // self.view.userInteractionEnabled = YES;
        self.interactable = YES;
    } else {
        // self.view.userInteractionEnabled = NO;
        self.interactable = NO;
        self.cancelSidebar.enabled = YES;
    }
}

- (void)handleTapFrom: (UITapGestureRecognizer *)sender
{
    
    // If the menu is not active
    if(self.interactable) {
    } else {
        
        // If menu is active any tap outside the menu will cancel the menu
        [self.revealViewController revealToggle:self.view];
        
    }
}

- (void)openMenu:(id)sender
{
    [self.revealViewController revealToggle:self.view];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
