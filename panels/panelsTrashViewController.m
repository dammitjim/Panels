//
//  panelsTrashViewController.m
//  panels
//
//  Created by James A Hill on 01/04/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "panelsTrashViewController.h"
#import "SWRevealViewController.h"
#import "ComicShelf.h"
#import "AudioToolbox/AudioToolbox.h"

@interface panelsTrashViewController () <SWRevealViewControllerDelegate, UIAlertViewDelegate>
@property (nonatomic) BOOL interactable;
@property (strong, nonatomic) UITapGestureRecognizer *cancelSidebar;
@property (strong, nonatomic) NSArray *trashBin;
@property (strong, nonatomic) ComicShelf *shelf;
@property (strong, nonatomic) NSIndexPath *indexToDelete;
@property (nonatomic) SystemSoundID alertSound;
@property (nonatomic) SystemSoundID confirmSound;
@property (nonatomic) SystemSoundID denySound;
@property (nonatomic) SystemSoundID woosh;
@property (strong, nonatomic) NSUserDefaults *defaults;
@end

@implementation panelsTrashViewController

- (ComicShelf *) shelf {
    if(!_shelf) _shelf = [[ComicShelf alloc] init];
    return _shelf;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSUserDefaults *)defaults {
    if(!_defaults) _defaults = [NSUserDefaults standardUserDefaults];
    return _defaults;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // SideBar config
    self.interactable = YES;
    //    NSLog(@"%lu",(unsigned long)[[self.shelf getWholeShelf] count]);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
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
    
    UIButton *button2 =  [UIButton buttonWithType:UIButtonTypeSystem];
//    [button2 setImage:[UIImage imageNamed:@"trash-icon.png"] forState:UIControlStateNormal];
    [button2 setTitle:@"Empty" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(trashEm: ) forControlEvents:UIControlEventTouchUpInside];
    [button2 setFrame:CGRectMake(0, 0, 50, 60)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button2];
    
    [self.shelf getWholeShelf];
    self.trashBin = [self.shelf getAllDeleted];
    NSLog(@"%d", [self.trashBin count]);
    
    [self createSoundId];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.trashBin count];
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

- (void)trashEm: (UITapGestureRecognizer *)sender {
    if(![self.defaults boolForKey:@"settingsSound"]) {
        AudioServicesPlaySystemSound(self.alertSound);
    }
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure you want to clear the trash? This is irreversible unless you reimport."] message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    [alert show];
}

- (void)openMenu:(id)sender
{
    [self.revealViewController revealToggle:self.view];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trashCell" forIndexPath:indexPath];
    
    Comic *aComic = [self.trashBin objectAtIndex:indexPath.row];
    UILabel *title = (UILabel *)[cell viewWithTag:101];
    UILabel *volume = (UILabel *)[cell viewWithTag:102];
    UIButton *recover = (UIButton *)[cell viewWithTag:103];
    
    title.text = [aComic title];
    volume.text = [[aComic volumeNumber] stringValue];
    
    UITapGestureRecognizer *recoverTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recoverComic: )];
    [recover addGestureRecognizer:recoverTap];
    
    // Configure the cell...
    return cell;
}

- (void)handleSwipe: (id)sender {
    NSLog(@"Hey, you swiped");
}

- (void)recoverComic: (id)sender {
    NSLog(@"Hey you want to recover");
    CGPoint p = [sender locationInView:[self tableView]];
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:p];
    self.indexToDelete = indexPath;
    [self.shelf setComicTrashed:[self.trashBin objectAtIndex:indexPath.row] trashIt:NO];
    [self.shelf getWholeShelf];
    self.trashBin = [self.shelf getAllDeleted];
    NSLog(@"%d", [self.trashBin count]);
    if(![self.defaults boolForKey:@"settingsSound"]) {
        AudioServicesPlaySystemSound(self.woosh);
    }
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1 ) {
        if(![self.defaults boolForKey:@"settingsSound"]) {
            AudioServicesPlaySystemSound(self.confirmSound);
        }
        for(int i = 0 ; i < [self.trashBin count] ; i++) {
            [self.shelf removeComic:[self.trashBin objectAtIndex:i]];
        }
        self.trashBin = [self.shelf getAllDeleted];
        [self.tableView reloadData];
        
    } else {
        if(![self.defaults boolForKey:@"settingsSound"]) {
            AudioServicesPlaySystemSound(self.denySound);
        }
    }
}

- (void) createSoundId
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"alert" ofType:@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundPath])
    {
        NSURL* soundPathURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundPathURL, &_alertSound);
    }
    
    soundPath = [[NSBundle mainBundle] pathForResource:@"confirm" ofType:@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundPath])
    {
        NSURL* soundPathURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundPathURL, &_confirmSound);
    }
    
    soundPath = [[NSBundle mainBundle] pathForResource:@"short_whoosh1" ofType:@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundPath])
    {
        NSURL* soundPathURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundPathURL, &_woosh);
    }
    
    soundPath = [[NSBundle mainBundle] pathForResource:@"deny" ofType:@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundPath])
    {
        NSURL* soundPathURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundPathURL, &_denySound);
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
