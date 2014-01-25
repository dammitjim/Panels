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

@interface panelsBaseTableController ()

@property (strong, nonatomic) IBOutlet UIButton *addComicButton;
@property (strong, nonatomic, retain) ComicShelf *shelf;
@end

@implementation panelsBaseTableController

- (IBAction)addComicWasClicked:(id)sender {
    //NSLog(@"Hey you tried to add a comic!");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Add Comic or Collection"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Add New Collection",
                                                                        @"Scan For Comics",
                                                                        nil];
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:@"Add New Collection"]) {
        NSLog(@"Add new collection clicked");
    }
    if ([buttonTitle isEqualToString:@"Scan For Comics"]) {
        //NSLog(@"Scan For Comics pressed");
        [self performSegueWithIdentifier:@"pushToAdd" sender:0];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.navigationItem.title = @"Panels";
        
    }
    return self;
}

- (ComicShelf *) shelf {
    if(!_shelf) _shelf = [[ComicShelf alloc] init];
    return _shelf;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.shelf description];
//    NSLog(@"%lu",(unsigned long)[[self.shelf getWholeShelf] count]);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    [self.shelf getWholeShelf];
    [self.tableView reloadData];
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
    return [self.shelf getTotalItems];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    if([[self.shelf getItemFromShelfAtIndex:(int)indexPath.row] isKindOfClass:[Comic class]]) {
//        NSLog(@"It's a comic");
        CellIdentifier = @"comicCell";
    } else {
//        NSLog(@"It's a collection");
        CellIdentifier = @"collectionCell";
    }
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    @autoreleasepool {
        if([[self.shelf getItemFromShelfAtIndex:(int)indexPath.row] isKindOfClass:[Comic class]]) {
            Comic *theComic = [self.shelf getItemFromShelfAtIndex:(int)indexPath.row];
            panelsComicCell *cell = (panelsComicCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if(!theComic.isPartOf) {
                NSMutableString *filePathBuilder = [[NSMutableString alloc] initWithString:@""];
                [filePathBuilder appendFormat:@"%@/", [theComic title]];
                [filePathBuilder appendFormat:@"%@/", [theComic volumeNumber]];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString *outputPath = [documentsDirectory stringByAppendingPathComponent:filePathBuilder ];
                NSMutableString *finalFilePath = [[NSMutableString alloc] initWithString:outputPath];
                [finalFilePath appendString:@"/cover.jpg"];
                [cell setComicTitle:theComic.title];
                [cell setComicVolume:theComic.volumeNumber];
                [cell setComicImage:[UIImage imageWithContentsOfFile:finalFilePath]];
                [cell.contentView addGestureRecognizer:tapGesture];
                return cell;
            } else {
                NSLog(@"Comic is part of collection");
            }
        } else {
    //        NSLog(@"It's a collection");
            Collection *theCollection = [self.shelf getItemFromShelfAtIndex:(int)indexPath.row];
            panelsCollectionCell *cell = (panelsCollectionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            NSLog(@"Hey this is a: %@", [theCollection title]);
            NSLog(@"In row: %ld", (long)indexPath.row);
            [cell setCollectionTitle:[theCollection title]];
            [cell setCollectionImageView:theCollection];
            [cell.contentView addGestureRecognizer:tapGesture];
            return cell;
        }
    }
    return 0;
}

- (void)handleTapFrom: (UITapGestureRecognizer *)sender
{
//    NSLog(@"Handling tap");
    CGPoint p = [sender locationInView:[self tableView]];
    NSIndexPath *indexPath = [[self tableView] indexPathForRowAtPoint:p];
    if(indexPath != nil) {
        if([[self.shelf getItemFromShelfAtIndex:(int)indexPath.row] isKindOfClass:[Collection class]]) {
            [self performSegueWithIdentifier:@"pushToCollection" sender:indexPath];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"pushToCollection"]) {
        NSIndexPath *indexPath = sender;
//        NSLog(@"%ld", (long)indexPath.row);
        Collection *toBeSent = [self.shelf getItemFromShelfAtIndex:(int)indexPath.row];
        panelsCollectionTableController *dest = [segue destinationViewController];
        [dest setCollectionTo:toBeSent];
    }
    if([[segue identifier] isEqualToString:@"pushToAdd"]) {
        NSLog(@"Pushing to add comic");
        panelsAddComicTableController *dest = [segue destinationViewController];
        [dest setShelf:self.shelf];
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
