//
//  panelsCollectionTableController.m
//  panels
//
//  Created by James A Hill on 08/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "panelsCollectionTableController.h"
#import "panelsComicCell.h"

@interface panelsCollectionTableController ()
@property (strong, nonatomic, retain) ComicShelf *shelf;
@property (strong, nonatomic) Collection *comicCollection;
@property (strong, nonatomic) NSArray *comics;
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

- (ComicShelf *) shelf {
    if(!_shelf) _shelf = [[ComicShelf alloc] init];
    return _shelf;
}

- (NSArray *) comics {
    if(!_comics) _comics = [[NSArray alloc] initWithArray:[self.shelf getComicsByCollection:self.comicCollection]];
    return _comics;
}

- (void)setCollectionTo:(Collection *)inputCollection {
    self.comicCollection = inputCollection;
    //self.navigationItem.title = self.comicCollection.title;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return [self.comics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"comicCell";
    @autoreleasepool {
        panelsComicCell *cell = (panelsComicCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        Comic *theComic = [self.comics objectAtIndex:indexPath.row];
    
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
        return cell;
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
