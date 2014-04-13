//
//  panelsReadingListViewController.m
//  panels
//
//  Created by James A Hill on 10/04/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "panelsReadingListViewController.h"
#import "SWRevealViewController.h"
#import "panelsReaderViewController.h"
#import "ComicShelf.h"

@interface panelsReadingListViewController () <SWRevealViewControllerDelegate, UIAlertViewDelegate>
@property (nonatomic) BOOL interactable;
@property (strong, nonatomic) UITapGestureRecognizer *cancelSidebar;
@property (strong, nonatomic) ComicShelf *shelf;
@property (strong, nonatomic) NSArray *unreadItems;

@end

@implementation panelsReadingListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSArray *) unreadItems {
    if(!_unreadItems) _unreadItems = [[NSArray alloc] init];
    return _unreadItems;
}

- (ComicShelf *) shelf {
    if(!_shelf) _shelf = [[ComicShelf alloc] init];
    return _shelf;
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = @"Reading List";
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName : [UIColor blackColor]
                                                                    };
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // SideBar config
    NSLog(@"It loaded");
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    [self.shelf getWholeShelf];
    self.unreadItems = [self.shelf getAllUnread];
    NSLog(@"%d", [self.unreadItems count]);
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
    return [self.unreadItems count];
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
        // Calculates which cell was pressed by it's position in the view
        CGPoint p = [sender locationInView:[self tableView]];
        NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:p];
        
        if(indexPath != nil) {
                
            // If it's a comic segue to the reader view
            [self performSegueWithIdentifier:@"pushToReader" sender:indexPath];
            
        }
    } else {
        
        // If menu is active any tap outside the menu will cancel the menu
        [self.revealViewController revealToggle:self.view];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"pushToReader"]) {
        NSLog(@"Pushing to reader");
        NSIndexPath *indexPath = sender;
        panelsReaderViewController *dest = [segue destinationViewController];
        Comic *toBeSent = [self.unreadItems objectAtIndex:indexPath.row];
        [dest setComicToBeRead:toBeSent];
    }
}

- (void)trashEm: (UITapGestureRecognizer *)sender {
//    AudioServicesPlaySystemSound(self.alertSound);
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure you want to clear the trash? This is irreversible unless you reimport."] message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
//    [alert show];
}

- (void)openMenu:(id)sender
{
    [self.revealViewController revealToggle:self.view];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"comicCell" forIndexPath:indexPath];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    // Configure the cell...
    UILabel *title = (UILabel *)[cell viewWithTag:101];
    UILabel *volumeNumber = (UILabel *)[cell viewWithTag:102];
    UIButton *button = (UIButton *)[cell viewWithTag:103];
    
    Comic *aComic = [self.unreadItems objectAtIndex:indexPath.row];
    
    title.text = [aComic title];
    volumeNumber.text = [[aComic volumeNumber] stringValue];
    
    UITapGestureRecognizer *recoverTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(markRead: )];
    [button addGestureRecognizer:recoverTap];

    [cell addGestureRecognizer:tapGesture];
    return cell;
}

- (void)markRead: (id)sender {
    NSLog(@"You want to mark it as read bro");
    CGPoint p = [sender locationInView:[self tableView]];
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:p];
    
    Comic *aComic = [self.unreadItems objectAtIndex:indexPath.row];
    [self.shelf setComicCompleted:aComic];
    [self.shelf getWholeShelf];
    
    self.unreadItems = [self.shelf getAllUnread];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView reloadData];
}

- (void)swiped: (id)sender {
    NSLog(@"Y'all swiped");
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
