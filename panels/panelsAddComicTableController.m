//
//  panelsAddComicTableController.m
//  panels
//
//  Created by James A Hill on 09/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "panelsAddComicTableController.h"
#import "SVProgressHUD.h"
#import "SWRevealViewController.h"
#import "Comic.h"
#import "AudioToolbox/AudioToolbox.h"

@interface panelsAddComicTableController () <SWRevealViewControllerDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (strong, nonatomic) ComicShelf *shelf;
@property (strong, nonatomic) RARHandler *rarHandler;
@property (strong, nonatomic) NSArray *cbrFiles;
@property (strong, nonatomic) UITapGestureRecognizer *cancelSidebar;
@property (strong, nonatomic) NSArray *topLevelShelf;
@property (strong, nonatomic) NSMutableArray *collectionTexts;
@property (strong, nonatomic) UIToolbar *accessoryView;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UITextView *currentEditable;
@property (strong, nonatomic) NSIndexPath *currentRow;
@property (strong, nonatomic) NSMutableArray *collectionNames;

@property (nonatomic) SystemSoundID swooshSound;
@property (nonatomic) SystemSoundID swooshSound2;
@property (nonatomic) SystemSoundID releaseSound;
@property (nonatomic) SystemSoundID alertSound;
@property (nonatomic) SystemSoundID confirmSound;
@property (nonatomic) SystemSoundID denySound;
@property (nonatomic) SystemSoundID notification;

@property (strong, nonatomic) NSUserDefaults *defaults;

@property BOOL hasScanned;
@property BOOL hasFinished;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
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

// Lazy instantiations

- (NSMutableArray *) collectionNames {
    if(!_collectionNames) _collectionNames = [[NSMutableArray alloc] init];
    return _collectionNames;
}

- (NSArray *) topLevelShelf {
    if(!_topLevelShelf) _topLevelShelf = [self.shelf getCollectionsForPicker:@""];
    return _topLevelShelf;
}

- (UIPickerView *) pickerView {
    if(!_pickerView) _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(600, 0, 320, 50)];
    return _pickerView;
}

- (NSArray *) cbrFiles {
    if(!_cbrFiles) _cbrFiles = [[NSArray alloc] init];
    return _cbrFiles;
}

- (NSMutableArray *) collectionTexts {
    if(!_collectionTexts) _collectionTexts = [[NSMutableArray alloc] initWithCapacity:[self.cbrFiles count]];
    return _collectionTexts;
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
    // If there are comics to be added process the files
    if([self.cbrFiles count]>0) {
//        for (int i = 0; i < [self.collectionTexts count]; i++) {
//            NSLog(@"Item %@ at index %i", [self.collectionTexts objectAtIndex:i], i);
//        }
        [self processFile];
    } else {
        // Display no comics founds error
        if(![self.defaults boolForKey:@"settingsSound"]) {
            AudioServicesPlaySystemSound(self.alertSound);
        }
        UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"No comics!" message: @"Please add some in iTunes" delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
        [someError show];
    }
}

- (NSArray *)scanForNewFiles {
    // Gets root paths
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Gets all directories and .cbr files
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    NSArray *cbrFiles = [dirFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.cbr'"]];
    return cbrFiles;
}

-(void)processFile {
    
    // Runs in seperate thread
    [SVProgressHUD showWithStatus:@"Importing comics" maskType:SVProgressHUDMaskTypeBlack];
    int count = (int)[self.cbrFiles count];
    self.hasFinished = NO;
    
    // Dispatches task to the GCD
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // long-running code
        for( int i = 0 ; i < count ; i++) {
            @autoreleasepool {
                self.hasFinished = NO;
                
                // Gets file url
                NSURL *url = [self.cbrFiles objectAtIndex:i];
                
                // Converts url to string
                NSString *urlString = [[NSString alloc] initWithString:url.lastPathComponent];
                
                // Casts string to mutable for formatting
                NSMutableString *str = [[NSMutableString alloc] initWithString:urlString];
                
                // Removes special characters
                NSRegularExpression *regex = [NSRegularExpression
                                              regularExpressionWithPattern:@"\\(.+?\\)"
                                              options:NSRegularExpressionCaseInsensitive
                                              error:NULL];
                
                [regex replaceMatchesInString:str
                                      options:0
                                        range:NSMakeRange(0, [str length])
                                 withTemplate:@""];
                
                NSString *collectionTitle = nil;
                
                // If it's part of a collection, set the collection title
                if(![[self.collectionTexts objectAtIndex:i ] isEqualToString:@"None"]) {
                    collectionTitle = [self.collectionTexts objectAtIndex:i];
                    NSLog(@"Adding to collection");
                }
                
                NSLog(@"%@", collectionTitle);
                
                // Get title from the string by pulling out relevant characters
                NSString *titleParameter = [self getTitle:str];
                
                //    NSString *collectionTitle = @"";
                // Get volume number
                NSNumber *volumeNumber = [self getVolumeNumber:str];
                
                // Update status message every iteration through the loop
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD setStatus:[NSString stringWithFormat:@"Importing %@ #%@, do not exit.", titleParameter, [volumeNumber stringValue]]];
                });
                
                // Decompress and add comic to the shelf
                int fileExtracted = [self.rarHandler decompressURL:urlString forTitle:titleParameter forVolume:volumeNumber];
                Comic *aComic = [self.shelf addComicToShelfWithParameters:titleParameter withVolume:(NSNumber *)volumeNumber withPath:(NSString *)urlString inCollection:(NSString *)collectionTitle withPageCount:fileExtracted];
                
                // Boolean callback
                self.hasFinished = [self.shelf addCoverToComic:aComic];
                if(![self.defaults boolForKey:@"settingsSound"]) {
                    AudioServicesPlaySystemSound(self.swooshSound);
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // Waits for confirmation that the final cover has been added
            if(self.hasFinished) {
                NSLog(@"Finished import");
                [SVProgressHUD showSuccessWithStatus:@"Comics imported!"];
                if(![self.defaults boolForKey:@"settingsSound"]) {
                    AudioServicesPlaySystemSound(self.notification);
                }
                self.cbrFiles = [self scanForNewFiles];
                [self.tableView reloadData];
            }
        });
    });
}

-(NSNumber *)getVolumeNumber:(NSString *)fileName {
    
    #define ACCEPTABLE_CHARACTERS @"123456789."
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
    NSMutableString *title = [[NSMutableString alloc] initWithString:fileName];
    [title deleteCharactersInRange:NSMakeRange([fileName length]-4, 4)];
    // Removes all but integers and then casts it to a string
    
    NSString *volumeString = [[title componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];

    NSNumber *volumeNumber = [[NSNumber alloc]initWithDouble:[volumeString doubleValue]];
    NSLog(@"Volume number: %@", volumeNumber);
    return volumeNumber;
    
}

-(NSString *)getTitle:(NSString *)fileName {
    
//    #warning ADD CODE HERE TO REMOVE SPECIAL CHARACTERS
    
    NSMutableString *title = [[NSMutableString alloc] initWithString:fileName];
    
    // Deletes file extension
    [title deleteCharactersInRange:NSMakeRange([fileName length]-4, 4)];
    
    NSString *noWhammies = [[title componentsSeparatedByCharactersInSet: [[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@" "];
    
    // Removes whitespace and trims string
    NSString *removeWhiteSpace = [noWhammies stringByReplacingOccurrencesOfString:@"[ ]+"
                                                                withString:@" "
                                                                   options:NSRegularExpressionSearch
                                                                     range:NSMakeRange(0, title.length)];
    
    NSString *noWhiteSpace = [removeWhiteSpace stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *final = [[noWhiteSpace componentsSeparatedByCharactersInSet: [[NSCharacterSet letterCharacterSet] invertedSet]] componentsJoinedByString:@" "];
    
    NSString *trimmedString = [final stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
    return trimmedString;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Import Comics";
    
    // Scans for any new files since last time view loaded
    self.cbrFiles = [self scanForNewFiles];
    
    // Side menu customization
    self.revealViewController.delegate = self;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.revealViewController.rearViewRevealWidth = 250;
    self.cancelSidebar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:self.cancelSidebar];
    self.cancelSidebar.enabled = NO;
    
    // Side menu button customization
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"row.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openMenu: ) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 28, 28)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    // Pickerview for selecting collections
    self.pickerView.delegate = self;
    [self.view addSubview:self.pickerView];
    [self.pickerView  reloadAllComponents];
    
    // Get collections that can be added to
    [self fillCollectionsArray];
    [self createSoundId];
//    textField.inputAccessoryView == accessoryView;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName : [UIColor blackColor]
                                                                    };
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
}

- (void)fillCollectionsArray {
    for (int i = 0; i<[self.cbrFiles count]; i++) {
        
        // Gets title of current item and formats it
        NSURL *url = [self.cbrFiles objectAtIndex:i];
        NSString *urlString = [[NSString alloc] initWithString:url.lastPathComponent];
        NSMutableString *str = [[NSMutableString alloc] initWithString:urlString];
        
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"\\(.+?\\)"
                                      options:NSRegularExpressionCaseInsensitive
                                      error:NULL];
        
        [regex replaceMatchesInString:str
                              options:0
                                range:NSMakeRange(0, [str length])
                         withTemplate:@""];
        
        // Adds collection to array
        [self.collectionTexts insertObject:[self getTitle:str] atIndex:i];
    }
}

- (void)doneTapped: (UITapGestureRecognizer *)sender {
//    NSLog(@"%ld",(long)[self.pickerView selectedRowInComponent:0]);
    [self.view endEditing:YES];
    NSUInteger someNumber = [self.pickerView selectedRowInComponent:0];
    self.currentEditable.text = [self.topLevelShelf objectAtIndex:someNumber];
    [self.collectionTexts replaceObjectAtIndex:self.currentRow.row withObject:self.currentEditable.text];
}
- (void)cancelTapped: (UITapGestureRecognizer *)sender {
    //    NSLog(@"%ld",(long)[self.pickerView selectedRowInComponent:0]);
    [self.view endEditing:YES];
}

- (void)handleTapFrom: (UITapGestureRecognizer *)sender
{
    [self.revealViewController revealToggle:self.view];
}

- (void)openMenu:(id)sender
{
    [self.revealViewController revealToggle:self.view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
        self.view.userInteractionEnabled = YES;
//        self.interactable = YES;
    } else {
        self.view.userInteractionEnabled = NO;
//        self.interactable = NO;
        self.cancelSidebar.enabled = YES;
    }
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
        // self.view.userInteractionEnabled = YES;
//        self.interactable = YES;
    } else {
        // self.view.userInteractionEnabled = NO;
//        self.interactable = NO;
        self.cancelSidebar.enabled = YES;
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
    return [self.cbrFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Sets up reuseable cell
    static NSString *CellIdentifier = @"addingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Gets title for display
    NSURL *url = [self.cbrFiles objectAtIndex:indexPath.row];
    NSString *urlString = [[NSString alloc] initWithString:url.lastPathComponent];
    NSMutableString *str = [[NSMutableString alloc] initWithString:urlString];
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"\\(.+?\\)"
                                  options:NSRegularExpressionCaseInsensitive
                                  error:NULL];
    
    [regex replaceMatchesInString:str
                          options:0
                            range:NSMakeRange(0, [str length])
                     withTemplate:@""];
    
    // Gets labels from the storyboard by calling for the appropriate view tag
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:102];
    UILabel *volumeLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:100];
    UITextView *collectionText = (UITextView *)[cell viewWithTag:103];
    collectionText.secureTextEntry = YES;
    collectionText.scrollEnabled = NO;
    
    // Sets labels appropriately
    nameLabel.text = urlString;
    volumeLabel.text = [NSString stringWithFormat:@"Volume: #%@", [[self getVolumeNumber:str] stringValue]];
    NSString *title = [self getTitle:str];
    titleLabel.text = title;
    if([self.collectionTexts objectAtIndex:indexPath.row]!=nil) {
        collectionText.text = [self.collectionTexts objectAtIndex:indexPath.row];
    } else {
        collectionText.text = title;
    }
    [self.collectionNames insertObject:title atIndex:indexPath.row];
    
    // Creates toolbar to accomodate the picker view when collection is hit
    UIToolbar *accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    accessoryView.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nil action:@selector(cancelTapped: )];
    [cancel setWidth:300];
    cancel.tintColor = [UIColor orangeColor];
    
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTapped: )];
    done.tintColor = [UIColor orangeColor];
    
    accessoryView.items = [NSArray arrayWithObjects:cancel,space, done, nil];
    collectionText.inputAccessoryView = accessoryView;
    collectionText.inputView = self.pickerView;
    collectionText.delegate = self;
    
    // Configure the cell...
    
    return cell;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
//    [self.pickerView reloadAllComponents];
//    [self.pickerView selectRow:0 inComponent:0 animated:YES];
    self.currentEditable = textView;
    CGPoint buttonPosition = [textView convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    self.currentRow = indexPath;
    [self.pickerView reloadAllComponents];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
}
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if([self.topLevelShelf count] > 0) {
        return 1;
    } else {
        return 0;
    }
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if(self.currentEditable) {
        self.topLevelShelf = [self.shelf getCollectionsForPicker:[self.collectionNames objectAtIndex:self.currentRow.row]];
    }
    
    if([self.topLevelShelf count]>0) {
        return [self.topLevelShelf count];
    } else {
        return 0;
    }
    return [self.topLevelShelf count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    return [self.topLevelShelf objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
//    self.currentEditable.text = [self.topLevelShelf objectAtIndex:row];
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
    
    soundPath = [[NSBundle mainBundle] pathForResource:@"success" ofType:@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundPath])
    {
        NSURL* soundPathURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundPathURL, &_notification);
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
