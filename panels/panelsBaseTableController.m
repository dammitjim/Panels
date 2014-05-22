//
//  panelsBaseTableController.m
//  panels
//
//  Created by James A Hill on 08/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "panelsBaseTableController.h"
#import "panelsCollectionTableController.h"
#import "panelsAddComicTableController.h"
#import "panelsComicCell.h"
#import "panelsCollectionCell.h"
#import "SWRevealViewController.h"
#import "panelsReaderViewController.h"

@interface panelsBaseTableController () <SWRevealViewControllerDelegate, UIAlertViewDelegate>

//@property (strong, nonatomic) IBOutlet UIButton *addComicButton;
@property (strong, nonatomic, retain) ComicShelf *shelf;
@property (strong, nonatomic) UITapGestureRecognizer *cancelSidebar;
@property (nonatomic) BOOL interactable;
@property (strong, nonatomic) NSArray *topLevelShelf;
@property (strong, nonatomic) Comic *comicToBeDeleted;
@property (strong, nonatomic) NSIndexPath *pathToBeDeleted;
@property (strong, nonatomic) UIView *itemStash;
@property (strong, nonatomic) UILabel *stashCount;
@property (nonatomic) SystemSoundID swooshSound;
@property (nonatomic) SystemSoundID swooshSound2;
@property (nonatomic) SystemSoundID releaseSound;
@property (nonatomic) SystemSoundID alertSound;
@property (nonatomic) SystemSoundID confirmSound;
@property (nonatomic) SystemSoundID denySound;
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) Collection *collectionToBeRemoved;
@end

@implementation panelsBaseTableController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
//        self.navigationItem.title = @"Panels";
        
    }
    return self;
}
- (BOOL)shouldAutorotate
{
    return NO;
}

-(NSUserDefaults *)defaults {
    if(!_defaults) _defaults = [NSUserDefaults standardUserDefaults];
    return _defaults;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (NSArray *) topLevelShelf {
    if(!_topLevelShelf) _topLevelShelf = [[NSArray alloc] init];
    return _topLevelShelf;
}

- (ComicShelf *) shelf {
    if(!_shelf) _shelf = [[ComicShelf alloc] init];
    return _shelf;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self.shelf description];
    [self.shelf resetMovingItems];

    self.topLevelShelf = [self.shelf getWholeShelf];
    self.interactable = YES;
//    NSLog(@"%lu",(unsigned long)[[self.shelf getWholeShelf] count]);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.revealViewController.delegate = self;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.revealViewController.rearViewRevealWidth = 250;
    self.cancelSidebar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:self.cancelSidebar];
    self.cancelSidebar.enabled = NO;
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"row.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openMenu: ) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 28, 28)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [addButton setFrame:CGRectMake(0, 0, 28, 28)];
    [addButton addTarget:self action:@selector(addCollection: ) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    
    [self buildStash];
    
    [self createSoundId];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear base");
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationItem.title = @"Collection";
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName : [UIColor blackColor]
                                                                    };
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.topLevelShelf = [self.shelf getWholeShelf];
    [self.tableView reloadData];
    [self.shelf description];
    self.interactable = YES;
    //    NSLog(@"%lu",(unsigned long)[[self.shelf getWholeShelf] count]);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.revealViewController.delegate = self;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.revealViewController.rearViewRevealWidth = 250;
    self.cancelSidebar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:self.cancelSidebar];
    self.cancelSidebar.enabled = NO;
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"row.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openMenu: ) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 28, 28)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [self.navigationController.view addSubview:self.itemStash];
    
    self.stashCount.text = [NSString stringWithFormat:@"%d", [self.shelf getMoveItemsCount]];
    if([self.stashCount.text intValue]>0) {
        NSLog(@"%d", [self.stashCount.text intValue]);
        self.itemStash.hidden = NO;
    } else {
        self.itemStash.hidden = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.itemStash removeFromSuperview];
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
    return [[self.shelf getWholeShelf] count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    
    // Sets cell identifier depending on the shelf item recieved
    if([[self.shelf getItemFromShelfAtIndex:(int)indexPath.row] isKindOfClass:[Comic class]]) {
        CellIdentifier = @"comicCell";
    } else {
        CellIdentifier = @"collectionCell";
    }
    
    // Creates tap recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    
    // Configure the cell...
    if([[self.shelf getItemFromShelfAtIndex:(int)indexPath.row] isKindOfClass:[Comic class]]) {
        
        Comic *theComic = [self.shelf getItemFromShelfAtIndex:(int)indexPath.row];
        if([[theComic isTrashed] intValue]!=1) {
            panelsComicCell *cell = (panelsComicCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if(cell == nil) {
                
                cell = [[panelsComicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
            }
            
            // Only want to list comics that aren't part of a collection
            if(!theComic.isPartOf) {
                
                NSLog(@"The title is: %@", theComic.title);
                NSLog(@"%@", [[theComic title] class]);
                UIImage *cover = [UIImage imageWithData:[theComic cover]];
                
                // Fixes bug where on import comics sometimes don't assign covers correctly
                if(cover==NULL) {
                    //NSLog(@"Null");
                    [self reloadCoverImage:theComic];
                }
                
                [cell setComicTitle:[theComic title]];
                [cell setComicVolume:[theComic volumeNumber]];
                [cell setComicImage:cover];
                [cell setComicPageProgress:[theComic totalPages] atPage:[theComic pagesRead] isCompleted:[[theComic completed] boolValue]];
                
                UITapGestureRecognizer *deleteTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteComic: )];
                UIButton *deleteButton = (UIButton *)[cell viewWithTag:107];
                [deleteButton addGestureRecognizer:deleteTap];
                
                UITapGestureRecognizer *moveTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveComic:)];
                UIButton *moveButton = (UIButton *)[cell viewWithTag:108];
                [moveButton addGestureRecognizer:moveTap];
                
                [cell.contentView addGestureRecognizer:tapGesture];
                return cell;
                
            } else {
                NSLog(@"Comic is part of collection");
            }
        }

    } else {
        
        // Collection
        Collection *theCollection = [self.topLevelShelf objectAtIndex:(int)indexPath.row];
        panelsCollectionCell *cell = (panelsCollectionCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(cell==nil) {
            
            cell = [[panelsCollectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        
        NSArray *covers = [self.shelf getComicsByCollection:theCollection];
        
        if([covers count]>0) {
            
            [cell setNeedsDisplay];
            [cell clearSubviews];
            [cell setCollectionImageView:theCollection];
            
        }
        
        [cell setCollectionTitle:[theCollection title]];
        [cell setCollectionFileCount:[covers count]];
        [cell setCollectionFileProgress:theCollection];
        [cell.contentView addGestureRecognizer:tapGesture];
        [cell.contentView addGestureRecognizer:longPress];
        
        return cell;
    }
    return 0;
}

- (void)reloadCoverImage:(Comic *) comicToBeReloaded{
    NSLog(@"Reloading cover image for comic %@ #%@" ,[comicToBeReloaded title], [comicToBeReloaded volumeNumber]);
    [self.shelf addCoverToComic:comicToBeReloaded];
}

- (void)deleteComic:(id)sender {
//    NSLog(@"So I heard you want to delete a comic");
    
    CGPoint p = [sender locationInView:[self tableView]];
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:p];
    self.pathToBeDeleted = indexPath;
    Comic *theComic = [self.shelf getItemFromShelfAtIndex:(int)indexPath.row];
    
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure you want to delete %@ #%d", [theComic title], [[theComic volumeNumber] intValue]] message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
//    [alert show];
    self.comicToBeDeleted = theComic;
    [self.shelf setComicTrashed:self.comicToBeDeleted trashIt:true];
    if(![self.defaults boolForKey:@"settingsSound"]) {
        AudioServicesPlaySystemSound(self.swooshSound2);
    }
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.pathToBeDeleted]
                          withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView reloadData];
}

-(void)moveComic:(id)sender {
    NSLog(@"Hey lets move a comic!");

    CGPoint p = [sender locationInView:[self tableView]];
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:p];
    Comic *theComic = [self.shelf getItemFromShelfAtIndex:(int)indexPath.row];
    [self.shelf addItemToMover:theComic];
    if(![self.defaults boolForKey:@"settingsSound"]) {
        AudioServicesPlaySystemSound(self.swooshSound);
    }
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationRight];
    [self.shelf getWholeShelf];
    [self.tableView reloadData];
    self.stashCount.text = [NSString stringWithFormat:@"%d",[self.shelf getMoveItemsCount]];
    self.itemStash.hidden = NO;
    
    
}

-(void)longPress: (UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Long press");
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Rename", nil];
        
        CGPoint p = [sender locationInView:[self tableView]];
        NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:p];
        self.collectionToBeRemoved = [self.shelf getItemFromShelfAtIndex:(int)indexPath.row];
        
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    NSLog(@"The %@ button was tapped.", [actionSheet buttonTitleAtIndex:buttonIndex]);
    if(buttonIndex==0) {
//        NSLog(@"Delete pressed");
        [self.shelf removeCollection:self.collectionToBeRemoved];
        [self.tableView reloadData];
        
    } else if(buttonIndex==1) {
//        NSLog(@"Rename pressed");
    }
}


/**
 *  Handles table cells being tapped
 *
 *  @param sender - the recognizer that was sent
 */
- (void)handleTapFrom: (UITapGestureRecognizer *)sender
{
    
    // If the menu is not active
    if(self.interactable) {
        
        // Calculates which cell was pressed by it's position in the view
        CGPoint p = [sender locationInView:[self tableView]];
        NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:p];
        
        if(indexPath != nil) {
            
            // If it's part of a collection segue to the collection view table
            if([[self.shelf getItemFromShelfAtIndex:(int)indexPath.row] isKindOfClass:[Collection class]]) {
                
                [self performSegueWithIdentifier:@"pushToCollection" sender:indexPath];
                
            } else {
                
                // If it's a comic segue to the reader view
                
                [self performSegueWithIdentifier:@"pushToReader" sender:indexPath];
            }
        }
    } else {
        
        // If menu is active any tap outside the menu will cancel the menu
        [self.revealViewController revealToggle:self.view];
        
    }
}

- (void)moveItem:(id)sender {

}

- (void)openMenu:(id)sender
{
    [self.revealViewController revealToggle:self.view];
}

- (void)addCollection:(id)sender {
//    NSLog(@"Hey buddy you want to add a collection ok cool");
    if(![self.defaults boolForKey:@"settingsSound"]) {
        AudioServicesPlaySystemSound(self.alertSound);
    }
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add Collection" message:@"Enter Collection Title" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert setTag:1];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1) {
        NSLog(@"Entered: %@ at index %ld",[[alertView textFieldAtIndex:0] text], (long)buttonIndex);
        if(buttonIndex==1) {
            if(![self.defaults boolForKey:@"settingsSound"]) {
                AudioServicesPlaySystemSound(self.confirmSound);
            }
            [self.shelf addCollectionToShelfWithTitle:[[alertView textFieldAtIndex:0] text]];
            self.topLevelShelf = [self.shelf getWholeShelf];
            [self.tableView reloadData];
        } else {
            if(![self.defaults boolForKey:@"settingsSound"]) {
                AudioServicesPlaySystemSound(self.denySound);
            }
        }
    } else {
        if(buttonIndex == 1 ) {
//            [self.shelf removeComic:self.comicToBeDeleted];

        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"pushToCollection"]) {
        NSIndexPath *indexPath = sender;
        Collection *toBeSent = [self.shelf getItemFromShelfAtIndex:(int)indexPath.row];
        panelsCollectionTableController *dest = [segue destinationViewController];
        [dest setCollectionTo:toBeSent];
    }
    if([[segue identifier] isEqualToString:@"pushToAdd"]) {
       // NSLog(@"Pushing to add comic");
        panelsAddComicTableController *dest = [segue destinationViewController];
        [dest setShelf:self.shelf];
    }
    if([[segue identifier] isEqualToString:@"pushToReader"]) {
        NSLog(@"Pushing to reader");
        NSIndexPath *indexPath = sender;
        panelsReaderViewController *dest = [segue destinationViewController];
        Comic *toBeSent = [self.shelf getItemFromShelfAtIndex:(int)indexPath.row];
        [dest setComicToBeRead:toBeSent];
    }
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

- (void)buildStash {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    // Calculate the y axis position of the bar, take the height and subtract it from any current view on the stage to determine the position of the bottom of the page, then subtract the height of the view to be added to place it on screen
    float y = screenBounds.size.height- [UIApplication sharedApplication].statusBarFrame.size.height - 40;
    
    self.itemStash = [[UIView alloc] initWithFrame:CGRectMake(260, y, 50, 50)];
    
    self.itemStash.tag = 200;
    
    self.itemStash.backgroundColor = [UIColor blackColor];
    self.itemStash.opaque = NO;
    self.itemStash.alpha = 0.95;
    self.itemStash.layer.cornerRadius = 10;
    self.itemStash.layer.masksToBounds = YES;
    UITapGestureRecognizer *tapStash = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(releaseStash: )];
    [self.itemStash addGestureRecognizer:tapStash];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(stashHold: )];
    
    [longPress setMinimumPressDuration:0.5];
    [longPress requireGestureRecognizerToFail:tapStash];
    
    [self.itemStash addGestureRecognizer:longPress];
    
    self.stashCount.tag = 201;
    
    self.stashCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.stashCount.textColor = [UIColor whiteColor];
    self.stashCount.textAlignment = NSTextAlignmentCenter;
    self.stashCount.text = [NSString stringWithFormat:@"%d", [self.shelf getMoveItemsCount]];
    
    [self.navigationController.view addSubview:self.itemStash];
    [self.itemStash addSubview:self.stashCount];
    
    if([self.stashCount.text intValue]>0) {
        
        [self.itemStash setHidden:NO];
        
    } else {
        
        [self.itemStash setHidden:YES];
        
    }
}

-(void)releaseStash:(id)sender {
    NSLog(@"Ya'll want to release the stash");
    NSLog(@"%@", self.navigationController.visibleViewController.view.description);
    if(self.navigationController.visibleViewController==self) {
        [self.shelf moveItemsToBase];
        self.itemStash.hidden = YES;
//            [self.shelf getWholeShelf];
        if(![self.defaults boolForKey:@"settingsSound"]) {
            AudioServicesPlaySystemSound(self.releaseSound);
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)stashHold:(id)sender {
    NSLog(@"Holding");
    [self.shelf clearMover];
    self.itemStash.hidden = YES;
    [self.shelf getWholeShelf];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

- (void) createSoundId
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"short_whoosh1" ofType:@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundPath])
    {
        NSURL* soundPathURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundPathURL, &_swooshSound);
    }
    
    soundPath = [[NSBundle mainBundle] pathForResource:@"whoosh2" ofType:@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundPath])
    {
        NSURL* soundPathURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundPathURL, &_swooshSound2);
    }
    soundPath = [[NSBundle mainBundle] pathForResource:@"short_whoosh" ofType:@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundPath])
    {
        NSURL* soundPathURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundPathURL, &_releaseSound);
    }
    soundPath = [[NSBundle mainBundle] pathForResource:@"alert" ofType:@"wav"];
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
    soundPath = [[NSBundle mainBundle] pathForResource:@"deny" ofType:@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundPath])
    {
        NSURL* soundPathURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundPathURL, &_denySound);
    }
}
// Override to support conditional editing of the table view.
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Return NO if you do not want the specified item to be editable.
//    return YES;
//}
//
//
//
//// Override to support editing the table view.
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        // Delete the row from the data source
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//    }
//}

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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
