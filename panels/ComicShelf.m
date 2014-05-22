//
//  ComicShelf.m
//  panels
//
//  Created by James A Hill on 08/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "ComicShelf.h"

@interface ComicShelf()
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong ,nonatomic) NSMutableArray *shelfItems;
@property (strong, nonatomic) RARHandler *rarHandler;
@property (strong, nonatomic) NSMutableArray *trashItems;
@property (strong, nonatomic) NSMutableArray *moveItems;
@property (strong, nonatomic) NSMutableArray *unreadItems;
@end

@implementation ComicShelf

- (id)init {
    self = [super init];
    if(self) {

        panelsAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        self.context = [appDelegate managedObjectContext];
        
        // Initiate shelf
        [self getWholeShelf];
    }
    return self;
}

// Lazy instantiation

- (NSMutableArray *) shelfItems {
    if(!_shelfItems) _shelfItems = [[NSMutableArray alloc] init];
    return _shelfItems;
}

- (NSMutableArray *) trashItems {
    if(!_trashItems) _trashItems = [[NSMutableArray alloc] init];
    return _trashItems;
}

- (NSMutableArray *) moveItems {
    if(!_moveItems) _moveItems = [[NSMutableArray alloc] init];
    return _moveItems;
}

- (NSMutableArray *) unreadItems {
    if(!_unreadItems) _unreadItems = [[NSMutableArray alloc] init];
    return _unreadItems;
}

- (RARHandler *) rarHandler {
    if(!_rarHandler) _rarHandler = [[RARHandler alloc] init];
    return _rarHandler;
}

-(id)getItemFromShelfAtIndex:(int)index {
    return [self.shelfItems objectAtIndex:index];
}

-(Comic *)getItemFromCollection:(Collection *)collection atIndex:(int)index {
    NSArray *comics = [self getComicsByCollection:collection];
    return [comics objectAtIndex:index];
}

//

/**
 *  Gets relevant collection from title
 *
 *  @param title - to be fetched
 *
 *  @return Collection
 */
-(Collection *)getCollectionFromShelfByTitle:(NSString *)title {
    
    // Fetches all entities with the name "Collection"
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Collection" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    // Only return those which match the requested title
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(title = %@)", title];
    [fetchRequest setPredicate:predicate];
    
    // Execute fetch request
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    // If it returned a thing
    if([fetchedObjects count] > 0) {
        return [fetchedObjects objectAtIndex:0];
    } else {
        // If collection not found and collection title isn't blank a new collection is required
        if(![title isEqualToString:@""]) {
            Collection *newCollection = [NSEntityDescription insertNewObjectForEntityForName:@"Collection"
                                                                      inManagedObjectContext:self.context];
            [newCollection setTitle:title];
            return newCollection;
        } else {
            return nil;
        }

    }
}

-(NSArray *)getCollectionsForPicker:(NSString *)defaultString {
    
    // Fetches collections
    NSFetchRequest *collectionFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *collectionEntity = [NSEntityDescription entityForName:@"Collection" inManagedObjectContext:self.context];
    [collectionFetchRequest setEntity:collectionEntity];
    NSError *error;
    NSArray *collectionFetchedObjects = [self.context executeFetchRequest:collectionFetchRequest error:&error];
    
    // Builds titles array to be returned
    NSMutableArray *titles = [[NSMutableArray alloc] init];
    [titles addObject:defaultString];
    [titles addObject:@"None"];
    for (int i = 0; i < [collectionFetchedObjects count]; i++) {
        [titles addObject:[[collectionFetchedObjects objectAtIndex:i] title]];
    }
    //NSLog(@"%lu", (unsigned long)[titles count]);
    return titles;
}

-(NSArray *)getWholeShelf {
    
    // Clears whatever is currently in the shelf
    self.shelfItems = NULL;
    self.trashItems = NULL;
    self.moveItems = NULL;
    self.unreadItems = NULL;
    
    // Fetches collections
    NSFetchRequest *collectionFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *collectionEntity = [NSEntityDescription entityForName:@"Collection" inManagedObjectContext:self.context];
    [collectionFetchRequest setEntity:collectionEntity];
    NSError *error;
    NSArray *collectionFetchedObjects = [self.context executeFetchRequest:collectionFetchRequest error:&error];
    
    // Adds collections to the shelf
    for (NSManagedObject *collectionInfo in collectionFetchedObjects) {
        [self.shelfItems addObject:collectionInfo];
    }
    
    // Fetches comics
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comic" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    // Sorts by volume number
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"volumeNumber" ascending:YES];
    NSArray *sortedLinks = [fetchedObjects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor2, nil]];
    
    // Only add to shelf if they aren't part of a collection
    for (NSManagedObject *info in sortedLinks) {
        if(![info valueForKey:@"isPartOf"]) {
            if([[info valueForKey:@"isTrashed"] intValue]==1) {
                NSLog(@"Adding to trash");
                [self.trashItems addObject:info];
                NSLog(@"Trash items: %d", [self.trashItems count]);

            } else if([[info valueForKey:@"isMoving"] intValue]==1) {
                NSLog(@"Item moving");
                [self.moveItems addObject:info];
                NSLog(@"Move items: %d", [self.moveItems count]);
            } else {
                [self.shelfItems addObject:info];
            }
        } else if ([[info valueForKey:@"isTrashed"]intValue]==1) {
            NSLog(@"Adding to trash");
            [self.trashItems addObject:info];
            NSLog(@"Trash items: %d", [self.trashItems count]);
        } else if ([[info valueForKey:@"isMoving"]intValue] ==1) {
            NSLog(@"Item moving");
            [self.moveItems addObject:info];
            NSLog(@"Move items: %d", [self.moveItems count]);
        }
        if(![[info valueForKey:@"completed"]boolValue]) {
            [self.unreadItems addObject:info];
            NSLog(@"Unread items: %d", [self.unreadItems count]);
        }
    }
//    NSLog(@"Items in shelf: %lu", (unsigned long)[self.shelfItems count]);
    return self.shelfItems;
}

- (NSArray *)getAllDeleted {
    NSLog(@"Items in trash: %d", [self.trashItems count]);
    return self.trashItems;
}

- (NSArray *)getAllUnread {
    NSLog(@"Items in unread: %d", [self.unreadItems count]);
    return self.unreadItems;
}

-(Comic *)addComicToShelfWithParameters:(NSString *)title withVolume:(NSDecimalNumber *)volumeNumberIn withPath:(NSString *)filePath inCollection:(NSString *)collectionTitle withPageCount:(int)pages {
    NSLog(@"Adding %@ #%@ to shelf", title, volumeNumberIn);
    if(self.context) {
        
        // Creates a new comic managed object
        Comic *comicToBeSaved = [NSEntityDescription insertNewObjectForEntityForName:@"Comic"
                                                              inManagedObjectContext:self.context];
        
        // Sets managed object parameters
        [comicToBeSaved setTitle:title];
        [comicToBeSaved setVolumeNumber:volumeNumberIn];
        [comicToBeSaved setRating:[NSNumber numberWithInt:0]];
        [comicToBeSaved setPagesRead:[NSNumber numberWithInt:0]];
        [comicToBeSaved setTotalPages:[NSNumber numberWithInt:pages]];
        [comicToBeSaved setCompleted:[NSNumber numberWithInt:0]];
        [comicToBeSaved setIsTrashed:[NSNumber numberWithBool:NO]];
        [comicToBeSaved setIsMoving:[NSNumber numberWithBool:NO]];
        
        // If it's part of a collection
        if(collectionTitle) {
            [comicToBeSaved setIsPartOf:[self getCollectionFromShelfByTitle:collectionTitle]];
        }
        
        // Save comic
        NSError *error;
        [self.context save:&error];
        if (![self.context save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Saved correctly");
        }
        // Do Unraring business
        return comicToBeSaved;
    }
    return nil;
}

-(BOOL)addCoverToComic:(Comic *)comicIn {
    
    // Builds path to file
    NSMutableString *filePathBuilder = [[NSMutableString alloc] initWithString:@""];
    [filePathBuilder appendFormat:@"%@/", [comicIn title]];
    [filePathBuilder appendFormat:@"%@/", [comicIn volumeNumber]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *outputPath = [documentsDirectory stringByAppendingPathComponent:filePathBuilder ];
    NSMutableString *finalFilePath = [[NSMutableString alloc] initWithString:outputPath];
    [finalFilePath appendString:@"/cover.jpg"];
    
    // Sets comic's cover to the image at the path, converts it to NSData for storage
    UIImage *theCover = [UIImage imageWithContentsOfFile:finalFilePath];
    NSData *imageData = UIImagePNGRepresentation(theCover);
    [comicIn setCover:imageData];
    
    NSError *error;
    [self.context save:&error];
    if (![self.context save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    } else {
        NSLog(@"Saved correctly");
    }
    
    NSLog(@"%@", finalFilePath);
    NSLog(@"Saved cover image for volume %@", [[comicIn volumeNumber] stringValue]);
    
    return true;
}

-(void)addComicToCollection:(Comic *)comicIn inCollection:(Collection *)collectionIn {
    [comicIn setIsPartOf:collectionIn];
    [collectionIn addCollectsObject:comicIn];
    NSError *error;
    [self.context save:&error];
    if (![self.context save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    } else {
        NSLog(@"Saved correctly");
    }
}

-(void)addCollectionToShelf:(Collection *)collectionIn {
    Comic *collectionToBeSaved = [NSEntityDescription insertNewObjectForEntityForName:@"Collection"
                                                          inManagedObjectContext:self.context];
    [collectionToBeSaved setTitle:[collectionIn title]];
    [collectionToBeSaved setRating:[collectionIn rating]];
    [collectionToBeSaved setComicVineURL:[collectionIn comicVineURL]];
    NSError *error;
    [self.context save:&error];
    if (![self.context save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    } else {
        NSLog(@"Saved correctly");
    }
}

-(void)addCollectionToShelfWithTitle:(NSString *)title {
    Comic *collectionToBeSaved = [NSEntityDescription insertNewObjectForEntityForName:@"Collection"
                                                               inManagedObjectContext:self.context];
    [collectionToBeSaved setTitle:title];
    NSError *error;
    [self.context save:&error];
    if (![self.context save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    } else {
        NSLog(@"Saved correctly");
    }
    [self getWholeShelf];
}

-(NSArray *)getComicsByCollectionTitle:(NSString *)title {
    return 0;
}

-(void)resetMovingItems {
    for(int i = 0 ; i < [self.moveItems count] ; i++) {
        Comic *aComic = [self.moveItems objectAtIndex:i];
        [aComic setIsMoving:[NSNumber numberWithBool:NO]];
    }
    [self.moveItems removeAllObjects];
    NSError *error;
    [self.context save:&error];
    if (![self.context save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    } else {
        NSLog(@"Saved correctly");
    }
    [self getWholeShelf];
}

-(NSArray *)getComicsByCollection:(Collection *)collectionIN {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comic" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(isPartOf = %@) AND (isTrashed = %@) AND (isMoving = %@)", collectionIN, [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO]];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"volumeNumber" ascending:YES];
    NSArray *sortedLinks = [fetchedObjects sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, sortDescriptor2, nil]];
//    for (NSManagedObject *info in fetchedObjects) {
//        //NSLog(@"Title: %@", [info valueForKey:@"title"]);
//        //NSLog(@"Type: %d", [info isKindOfClass:[Comic class]]);
//    }
    return sortedLinks;
}

-(NSArray *)getComicsByCollectionIgnoreTrashed:(Collection *)collectionIN {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comic" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(isPartOf = %@) AND (isTrashed = %@)", collectionIN, [NSNumber numberWithBool:NO]];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"volumeNumber" ascending:YES];
    NSArray *sortedLinks = [fetchedObjects sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    //    for (NSManagedObject *info in fetchedObjects) {
    //        //NSLog(@"Title: %@", [info valueForKey:@"title"]);
    //        //NSLog(@"Type: %d", [info isKindOfClass:[Comic class]]);
    //    }
    return sortedLinks;
}

-(int)getTotalItems {
    NSMutableArray *uncollectedItems = [[NSMutableArray alloc ] init];
    for (NSManagedObject *info in self.shelfItems) {
        if([info isKindOfClass:[Comic class]]) {
            if(![info valueForKey:@"isPartOf"]) {
                [uncollectedItems addObject:info];
            }
        } else {
            [uncollectedItems addObject:info];
        }
    }
    return (int)[uncollectedItems count];
}

-(UIImage *)getCoverFromComic:(NSString *)title volume:(NSNumber *)volumeNumberIn {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comic" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(title = %@) AND (volumeNumber = %@)", title, volumeNumberIn];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    UIImage *theImage;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    if([fetchedObjects count]>0) {
        theImage = [fetchedObjects objectAtIndex:0];
        return theImage;
    } else {
        NSLog(@"Cover not found");
        return 0;
    }
}

-(void)updatePagesReadForComic:(Comic *)comic toPage:(int)page{
    NSLog(@"%d", page);
    [comic setPagesRead:[NSNumber numberWithInt:page]];
    NSLog(@"Saving pages read to: %@", [NSNumber numberWithInt:page]);
    
    NSError *error;
    [self.context save:&error];
    if (![self.context save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    } else {
        NSLog(@"Saved correctly");
    }
}

-(void)removeCollection:(Collection *)collection {
    NSArray *comics = [self getComicsByCollection:collection];
    for (int i = 0; i < [comics count]; i++) {
        Comic *comic = [comics objectAtIndex:i];
        [comic setIsPartOf:nil];
    }
    [self.context deleteObject:collection];
    
    NSError *error;
    [self.context save:&error];
    if (![self.context save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    } else {
        NSLog(@"Saved correctly");
    }
    [self getWholeShelf];
}

-(void)removeComic:(Comic *)comic {
    
    [self.context deleteObject:comic];
    
    NSString *folderTitle = [[NSString alloc] initWithFormat:@"/%@/%@/" ,[comic title], [[comic volumeNumber]stringValue]];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:folderTitle];
    
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:dataPath error:nil];
    
    if(success) {
        NSError *error;
        [self.context save:&error];
        if (![self.context save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Saved correctly");
        }
        [self getWholeShelf];
    }

}

-(void)updateTotalPagesForComic:(Comic *)comic toAmount:(int)amount {
    [comic setTotalPages:[NSNumber numberWithInt:amount]];
}

-(Comic *)getComicByCollectionAndTitle:(NSString *)title withVolume:(int)volume {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comic" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(title = %@) AND (volumeNumber = %@)", title, [NSNumber numberWithInt:volume]];
    [fetchRequest setPredicate:predicate];
    NSError *error;
//    UIImage *theImage;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    if([fetchedObjects count]>0) {
        return [fetchedObjects objectAtIndex:0];
    } else {
        NSLog(@"Comic not found");
        return nil;
//        return 0;
    }
}

- (void)setComicCompleted:(Comic *)comic {
    [comic setCompleted:[NSNumber numberWithInt:1]];
    NSError *error;
    [self.context save:&error];
    if (![self.context save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    } else {
        NSLog(@"Saved correctly");
    }
    [self getWholeShelf];
}

- (void)setComicTrashed:(Comic *)comic trashIt:(BOOL)trashMe {
    [comic setIsTrashed:[NSNumber numberWithBool:trashMe]];
    NSError *error;
    [self.context save:&error];
    if (![self.context save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    } else {
        NSLog(@"Saved correctly");
    }
    [self getWholeShelf];
}

- (void)addItemToMover:(Comic *)comic {
    [self.moveItems addObject:comic];
    [comic setIsMoving:[NSNumber numberWithBool:YES]];
    NSError *error;
    [self.context save:&error];
    if (![self.context save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    } else {
        NSLog(@"Saved correctly");
    }
    [self getWholeShelf];
}

- (void)removeItemFromMover:(Comic *)comic {
    [self.moveItems removeObject:comic];
}

- (NSUInteger)getMoveItemsCount {
    return [self.moveItems count];
}

- (void)moveItemsToCollection:(Collection *)collection {
    
    for( int i = 0 ; i < [self.moveItems count] ; i++ ) {
        
        Comic *aComic = [self.moveItems objectAtIndex:i];
        [aComic setIsPartOf:collection];
        [collection addCollectsObject:aComic];
        
        [aComic setIsMoving:[NSNumber numberWithBool:NO]];
    }
    
    [self.moveItems removeAllObjects];
    
    NSError *error;
    [self.context save:&error];
    
    if (![self.context save:&error]) {
        
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        
    } else {
        
        NSLog(@"Saved correctly");
        
    }
    
    [self getWholeShelf];
}

- (void)moveItemsToBase {
    for( int i = 0 ; i < [self.moveItems count] ; i++ ) {
        
        Comic *aComic = [self.moveItems objectAtIndex:i];
        Collection *aCollection = [aComic isPartOf];
        if(aCollection!=nil) {
            [aComic setIsPartOf:nil];
            [aCollection removeCollectsObject:aComic];
        }
        [aComic setIsMoving:[NSNumber numberWithBool:NO]];
    }
    
    [self.moveItems removeAllObjects];
    
    NSError *error;
    [self.context save:&error];
    
    if (![self.context save:&error]) {
        
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        
    } else {
        
        NSLog(@"Saved correctly");
        
    }
    
    [self getWholeShelf];
}

- (void)clearMover {
    for( int i = 0 ; i < [self.moveItems count] ; i++ ) {
        
        Comic *aComic = [self.moveItems objectAtIndex:i];
        [aComic setIsMoving:[NSNumber numberWithBool:NO]];
    }
    [self.moveItems removeAllObjects];
    
    NSError *error;
    [self.context save:&error];
    
    if (![self.context save:&error]) {
        
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        
    } else {
        
        NSLog(@"Saved correctly");
        
    }
    
    [self getWholeShelf];
}

- (int)getCompletedForCollection:(Collection *)collection {
    NSArray *comics = [self getComicsByCollection:collection];
    int count = 0;
    for(int i = 0 ; i < [comics count] ; i++) {
        Comic *comic = [comics objectAtIndex:i];
        if([[comic completed] intValue]==1) {
            count++;
        }
    }
    return count;
}

@end
