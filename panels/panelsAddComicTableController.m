//
//  panelsAddComicTableController.m
//  panels
//
//  Created by James A Hill on 09/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "panelsAddComicTableController.h"
#import "SVProgressHUD.h"

@interface panelsAddComicTableController ()
@property (strong, nonatomic) ComicShelf *shelf;
@property (strong, nonatomic) RARHandler *rarHandler;
@property (strong, nonatomic) NSArray *cbrFiles;
@property BOOL hasScanned;
@end

@implementation panelsAddComicTableController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (NSArray *) cbrFiles {
    if(!_cbrFiles) _cbrFiles = [[NSArray alloc] init];
    return _cbrFiles;
}

- (RARHandler *) rarHandler {
    if(!_rarHandler) _rarHandler = [[RARHandler alloc] init];
    return _rarHandler;
}

- (ComicShelf *) shelf {
    if(!_shelf) _shelf = [[ComicShelf alloc] init];
    return _shelf;
}

- (IBAction)goButtonPushed:(id)sender {
    [self processFile];
}

- (NSArray *)scanForNewFiles {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    NSArray *cbrFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.cbr'"]];
    return cbrFiles;
}

//-(void)processFile:(NSString *)fileName {
//    NSMutableString *str = [[NSMutableString alloc] initWithString:fileName];
//    
//    NSRegularExpression *regex = [NSRegularExpression
//                                  regularExpressionWithPattern:@"\\(.+?\\)"
//                                  options:NSRegularExpressionCaseInsensitive
//                                  error:NULL];
//    
//    [regex replaceMatchesInString:str
//                          options:0
//                            range:NSMakeRange(0, [str length])
//                     withTemplate:@""];
//    NSLog(@"%@", str);
//    NSString *titleParameter = [self getTitle:str];
//    NSString *collectionTitle = titleParameter;
////    NSString *collectionTitle = @"";
//    NSNumber *volumeNumber = [self getVolumeNumber:str];
//    [self.shelf addComicToShelfWithParameters:titleParameter withVolume:(NSNumber *)volumeNumber withPath:(NSString *)fileName inCollection:(NSString *)collectionTitle];
//    [self.rarHandler decompressURL:fileName forTitle:titleParameter forVolume:volumeNumber];
//}

-(void)processFile {
    // Runs in seperate thread
    // long-running code
    [SVProgressHUD showWithStatus:@"Importing comics" maskType:SVProgressHUDMaskTypeBlack];
    int count = [self.cbrFiles count];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // long-running code
        for( int i = 0 ; i < count ; i++) {
            @autoreleasepool {
                // do work
                NSURL *url = [self.cbrFiles objectAtIndex:i];
                NSLog(@"%@", url);
                //    NSLog(@"%@", [url path]);
                NSString *urlString = [[NSString alloc] initWithString:url.lastPathComponent];
                NSLog(@"%@", urlString);
                NSMutableString *str = [[NSMutableString alloc] initWithString:urlString];
                
                NSRegularExpression *regex = [NSRegularExpression
                                              regularExpressionWithPattern:@"\\(.+?\\)"
                                              options:NSRegularExpressionCaseInsensitive
                                              error:NULL];
                
                [regex replaceMatchesInString:str
                                      options:0
                                        range:NSMakeRange(0, [str length])
                                 withTemplate:@""];
                NSLog(@"%@", str);
                NSString *titleParameter = [self getTitle:str];
                NSString *collectionTitle = titleParameter;
                //    NSString *collectionTitle = @"";
                NSNumber *volumeNumber = [self getVolumeNumber:str];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD setStatus:[NSString stringWithFormat:@"Importing %@ #%@, do not exit.", titleParameter, [volumeNumber stringValue]]];
                });
                [self.shelf addComicToShelfWithParameters:titleParameter withVolume:(NSNumber *)volumeNumber withPath:(NSString *)urlString inCollection:(NSString *)collectionTitle];
                [self.rarHandler decompressURL:urlString forTitle:titleParameter forVolume:volumeNumber];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showSuccessWithStatus:@"Comics imported!"];
        });
    });
}

-(NSNumber *)getVolumeNumber:(NSString *)fileName {
    
    NSString *volumeString = [[fileName componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                           componentsJoinedByString:@""];
    NSNumber *volumeNumber = [[NSNumber alloc]initWithInt:[volumeString integerValue]];
    NSLog(@"Volume Number: %@", volumeNumber);
    return volumeNumber;
    
}

-(NSString *)getTitle:(NSString *)fileName {
    
//    #warning ADD CODE HERE TO REMOVE SPECIAL CHARACTERS
    
    NSMutableString *title = [[NSMutableString alloc] initWithString:fileName];
    [title deleteCharactersInRange:NSMakeRange([fileName length]-4, 4)];
    NSString *removeWhiteSpace = [title stringByReplacingOccurrencesOfString:@"[ ]+"
                                                                withString:@" "
                                                                   options:NSRegularExpressionSearch
                                                                     range:NSMakeRange(0, title.length)];
    NSString *noWhiteSpace = [removeWhiteSpace stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *final = [[noWhiteSpace componentsSeparatedByCharactersInSet: [[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@" "];
    NSString *trimmedString = [final stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"Title: %@", trimmedString);
    return trimmedString;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Import Comics";
    self.cbrFiles = [self scanForNewFiles];
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
    NSLog(@"%lu",(unsigned long)[self.cbrFiles count]);
    return [self.cbrFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"addingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSURL *url = [self.cbrFiles objectAtIndex:indexPath.row];
    NSString *urlString = [[NSString alloc] initWithString:url.lastPathComponent];
    NSLog(@"%@", urlString);
    NSMutableString *str = [[NSMutableString alloc] initWithString:urlString];
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"\\(.+?\\)"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:NULL];
    
    [regex replaceMatchesInString:str
                          options:0
                            range:NSMakeRange(0, [str length])
                     withTemplate:@""];
    NSLog(@"%@", str);
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *volumeLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:102];
    nameLabel.text = urlString;
    volumeLabel.text = [NSString stringWithFormat:@"Volume: %@", [[self getVolumeNumber:str] stringValue]];
    titleLabel.text = [self getTitle:str];
    // Configure the cell...
    
    return cell;
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
