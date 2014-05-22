//
//  panelsCollectionTableController.m
//  panels
//
//  Created by James A Hill on 08/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "panelsCollectionTableController.h"
#import "panelsComicCell.h"
#import "panelsReaderViewController.h"

@interface panelsCollectionTableController () <UIAlertViewDelegate>
@property (strong, nonatomic, retain) ComicShelf *shelf;
@property (strong, nonatomic) Collection *comicCollection;
@property (strong, nonatomic) NSMutableArray *comics;
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
@end

@implementation panelsCollectionTableController

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


- (BOOL)shouldAutorotate
{
    return NO;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (ComicShelf *) shelf {
    if(!_shelf) _shelf = [[ComicShelf alloc] init];
    return _shelf;
}

- (NSMutableArray *) comics {
    if(!_comics) _comics = [[NSMutableArray alloc] initWithArray:[self.shelf getComicsByCollection:self.comicCollection]];
    return _comics;
}

- (void)setCollectionTo:(Collection *)inputCollection {
    self.comicCollection = inputCollection;
    self.navigationItem.title = self.comicCollection.title;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    [self.shelf getWholeShelf];
    self.navigationController.navigationBar.topItem.title = @"";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 28, 28)];
//    [button setTitle:@"Disband" forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"delete-icon-orange.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(removeCollection: ) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.itemStash = [self.navigationController.view viewWithTag:200];
    self.stashCount = (UILabel *)[self.itemStash viewWithTag:201];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self buildStash];
    [self createSoundId];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.itemStash removeFromSuperview];
}

- (void)removeCollection:(id)sender {
    if(![self.defaults boolForKey:@"settingsSound"]) {
        AudioServicesPlaySystemSound(self.alertSound);
    }
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to delete this collection?" message:@"The comics will be moved to the top level" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
    [alert setTag:2];
    [alert show];
    
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
        [self.shelf moveItemsToCollection:self.comicCollection];
        self.itemStash.hidden = YES;
        self.comics = (NSMutableArray *)[self.shelf getComicsByCollection:self.comicCollection];
        if(![self.defaults boolForKey:@"settingsSound"]) {
            AudioServicesPlaySystemSound(self.releaseSound);
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    self.navigationController.title = [self.comicCollection title];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName : [UIColor blackColor]
                                                                    };
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.shelf getWholeShelf];
    [self.tableView reloadData];
    
    [self.navigationController.view addSubview:self.itemStash];
    
    self.stashCount.text = [NSString stringWithFormat:@"%d", [self.shelf getMoveItemsCount]];
    if([self.stashCount.text intValue]>0) {
        self.itemStash.hidden = NO;
    }
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
    return [[self.shelf getComicsByCollection:self.comicCollection] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"comicCell";
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    @autoreleasepool {
        panelsComicCell *cell = (panelsComicCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        Comic *theComic = [self.comics objectAtIndex:indexPath.row];
        if([[theComic isTrashed] intValue]!=1) {
            UIImage *cover = [UIImage imageWithData:[theComic cover]];
            [cell setComicTitle:theComic.title];
            [cell setComicVolume:theComic.volumeNumber];
            if(cover) {
                [cell setComicImage:cover];
            } else {
                NSLog(@"No data bro for: %@", [theComic title]);
            }
            
            [cell setComicPageProgress:theComic.totalPages atPage:theComic.pagesRead isCompleted:[[theComic completed] boolValue]];
            
            UITapGestureRecognizer *deleteTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteComic: )];
            UIButton *deleteButton = (UIButton *)[cell viewWithTag:107];
            [deleteButton addGestureRecognizer:deleteTap];
            
            UITapGestureRecognizer *moveTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moveComic:)];
            UIButton *moveButton = (UIButton *)[cell viewWithTag:108];
            [moveButton addGestureRecognizer:moveTap];
            
            [cell.contentView addGestureRecognizer:tapGesture];
        }
        return cell;
            
    }
}

- (void)deleteComic:(id)sender {
    NSLog(@"So I heard you want to delete a comic");
    
    CGPoint p = [sender locationInView:[self tableView]];
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:p];
    self.pathToBeDeleted = indexPath;
//    self.comics = [self.shelf getComicsByCollection:self.comicCollection];
    Comic *theComic = [self.comics objectAtIndex:indexPath.row];
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Are you sure you want to delete %@ #%d", [theComic title], [[theComic volumeNumber] intValue]] message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
//    [alert setTag:1];
//    [alert show];
    self.comicToBeDeleted = theComic;
    [self.shelf setComicTrashed:self.comicToBeDeleted trashIt:true];
    if(![self.defaults boolForKey:@"settingsSound"]) {
        AudioServicesPlaySystemSound(self.swooshSound2);
    }
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.pathToBeDeleted]
                          withRowAnimation:UITableViewRowAnimationLeft];
    self.comics = (NSMutableArray *)[self.shelf getComicsByCollection:self.comicCollection];
    NSLog(@"Count: %lu", (unsigned long)[self.comics count]);
    [self.tableView reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag == 1) {
        [self.shelf removeComic:self.comicToBeDeleted];
        
        self.comics = (NSMutableArray *)[self.shelf getComicsByCollection:self.comicCollection];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.pathToBeDeleted]
                              withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView reloadData];
    } else {
        if(buttonIndex==1) {
            if(![self.defaults boolForKey:@"settingsSound"]) {
                AudioServicesPlaySystemSound(self.confirmSound);
            }
            [self.shelf removeCollection:self.comicCollection];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            if(![self.defaults boolForKey:@"settingsSound"]) {
                AudioServicesPlaySystemSound(self.denySound);
            }
        }
    }
}
/**
 *  Handles table cells being tapped
 *
 *  @param sender - the recognizer that was sent
 */
- (void)handleTapFrom: (UITapGestureRecognizer *)sender
{
    
    // Calculates which cell was pressed by it's position in the view
    CGPoint p = [sender locationInView:[self tableView]];
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:p];
    
    if(indexPath != nil) {
        
        // If it's a comic segue to the reader view
        [self performSegueWithIdentifier:@"pushToReader" sender:indexPath];
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"pushToReader"]) {
        NSLog(@"Pushing to reader");
        NSIndexPath *indexPath = sender;
        panelsReaderViewController *dest = [segue destinationViewController];
        Comic *toBeSent = [self.shelf getItemFromCollection:self.comicCollection atIndex:(int)indexPath.row];
//        Comic *toBeSent = [self.shelf getItemFromShelfAtIndex:(int)indexPath.row];
        [dest setComicToBeRead:toBeSent];
    }
    
}

-(void)moveComic:(id)sender {
    NSLog(@"Hey lets move a comic!");
    
    CGPoint p = [sender locationInView:[self tableView]];
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:p];
    Comic *theComic = [self.shelf getItemFromCollection:self.comicCollection atIndex:(int)indexPath.row];
    
    NSLog(@"Moving comic at index: %d", (int)indexPath.row);
    
    [self.shelf addItemToMover:theComic];
    if(![self.defaults boolForKey:@"settingsSound"]) {
        AudioServicesPlaySystemSound(self.swooshSound);
    }
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                          withRowAnimation:UITableViewRowAnimationRight];
    [self.shelf getWholeShelf];
    self.comics = (NSMutableArray *)[self.shelf getComicsByCollection:self.comicCollection];
    [self.tableView reloadData];
    self.stashCount.text = [NSString stringWithFormat:@"%d",[self.shelf getMoveItemsCount]];
    self.itemStash.hidden = NO;
    
}

-(void)stashHold:(id)sender {
    NSLog(@"Holding");
    [self.shelf clearMover];
    self.itemStash.hidden = YES;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
