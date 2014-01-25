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
@end

@implementation ComicShelf

- (id)init {
    self = [super init];
    if(self) {
        // Get current list
        panelsAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        self.context = [appDelegate managedObjectContext];
        //[self populateShelf];
        [self getWholeShelf];
//        RARHandler *testHandler = [[RARHandler alloc] init];
//        [testHandler description];
    }
    return self;
}

- (NSMutableArray *) shelfItems {
    if(!_shelfItems) _shelfItems = [[NSMutableArray alloc] init];
    return _shelfItems;
}

- (RARHandler *) rarHandler {
    if(!_rarHandler) _rarHandler = [[RARHandler alloc] init];
    return _rarHandler;
}

-(void)populateShelf {
    //NSLog(@"Hey");
    // Custom initialization
    if(self.context) {
        //NSLog(@"Hey");
        Comic *newComic2 = [NSEntityDescription insertNewObjectForEntityForName:@"Comic"
                                                        inManagedObjectContext:self.context];
        [newComic2 setTitle:@"The Walking Dead"];
        [newComic2 setVolumeNumber:[[NSNumber alloc] initWithInt:1]];
        [newComic2 setIsPartOf:nil];
        NSError *error;
        [self.context save:&error];
        if (![self.context save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Saved correctly");
        }
        Collection *newCollection = [NSEntityDescription insertNewObjectForEntityForName:@"Collection"
                                                                  inManagedObjectContext:self.context];
        [newCollection setTitle:@"Hawkeye"];
        [self.context save:&error];
        if (![self.context save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Saved correctly");
        }
        [self addCollectionTestData:1 intoCollection:newCollection];
        [self addCollectionTestData:2 intoCollection:newCollection];
        [self addCollectionTestData:3 intoCollection:newCollection];
        [self addCollectionTestData:4 intoCollection:newCollection];
        [self addCollectionTestData:5 intoCollection:newCollection];
        [self addCollectionTestData:6 intoCollection:newCollection];
    }
//    [self getResults];
}

-(id)getItemFromShelfAtIndex:(int)index {
//    NSLog(@"Shelf count: %d", [self.shelfItems count]);
//    for(int i = 0 ; i < [self.shelfItems count] ; i++) {
//        NSLog(@"%@", [[self.shelfItems objectAtIndex:i] title]);
//    }
    return [self.shelfItems objectAtIndex:index];
}

-(Comic *)getComicFromShelfByTitle:(NSString *)title {
    return 0;
}

-(Collection *)getCollectionFromShelfByTitle:(NSString *)title {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Collection" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(title = %@)", title];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    if([fetchedObjects count] > 0) {
        return [fetchedObjects objectAtIndex:0];
    } else {
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

-(NSArray *)getWholeShelf {
    self.shelfItems = NULL;
    NSFetchRequest *collectionFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *collectionEntity = [NSEntityDescription entityForName:@"Collection" inManagedObjectContext:self.context];
    [collectionFetchRequest setEntity:collectionEntity];
    NSError *error;
    NSArray *collectionFetchedObjects = [self.context executeFetchRequest:collectionFetchRequest error:&error];
    for (NSManagedObject *collectionInfo in collectionFetchedObjects) {
       // NSLog(@"%@", collectionInfo);
        [self.shelfItems addObject:collectionInfo];
        //NSLog(@"Title: %@", [collectionInfo valueForKey:@"title"]);
        //NSLog(@"Type: %d", [collectionInfo isKindOfClass:[Collection class]]);
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comic" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"volumeNumber" ascending:YES];
    NSArray *sortedLinks = [fetchedObjects sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    for (NSManagedObject *info in sortedLinks) {
        if(![info valueForKey:@"isPartOf"]) {
            [self.shelfItems addObject:info];
        }
//        NSLog(@"Title: %@", [info valueForKey:@"title"]);
//        NSLog(@"Type: %d", [info isKindOfClass:[Comic class]]);
//        NSLog(@"Type of: %@", [[info valueForKey:@"isPartOf"] title]);
        //NSLog(@"Volume: %@", [info valueForKey:@"volumeNumber"]);
    }
    NSLog(@"Items in shelf: %d", [self.shelfItems count]);
    return self.shelfItems;
}

-(void)addComicToShelfWithParameters:(NSString *)title withVolume:(NSNumber *)volumeNumberIn withPath:(NSString *)filePath inCollection:(NSString *)collectionTitle {
    NSLog(@"Adding %@ #%@ to shelf", title, volumeNumberIn);
    if(self.context) {
        Comic *comicToBeSaved = [NSEntityDescription insertNewObjectForEntityForName:@"Comic"
                                                              inManagedObjectContext:self.context];
//        NSLog(@"%@", title);
//        NSLog(@"%@", volumeNumberIn);
        [comicToBeSaved setTitle:title];
        [comicToBeSaved setVolumeNumber:volumeNumberIn];
        [comicToBeSaved setRating:[NSNumber numberWithInt:0]];
        [comicToBeSaved setPagesRead:[NSNumber numberWithInt:0]];
        [comicToBeSaved setComicVineURL:@""];
        [comicToBeSaved setIsPartOf:[self getCollectionFromShelfByTitle:collectionTitle]];
        NSError *error;
        [self.context save:&error];
        if (![self.context save:&error]) {
            NSLog(@"Failed to save - error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Saved correctly");
        }
        // Do Unraring business
    }
//    NSLog(@"Got here");
}

-(void)addComicToShelf:(Comic *)comicIn {
    Comic *comicToBeSaved = [NSEntityDescription insertNewObjectForEntityForName:@"Comic"
                                                     inManagedObjectContext:self.context];
    [comicToBeSaved setTitle:[comicIn title]];
    [comicToBeSaved setVolumeNumber:[comicIn volumeNumber]];
    [comicToBeSaved setRating:[comicIn rating]];
    [comicToBeSaved setPagesRead:[NSNumber numberWithInt:0]];
    [comicToBeSaved setCoverURL:[comicIn coverURL]];
    [comicToBeSaved setComicVineURL:[comicIn comicVineURL]];
    NSError *error;
    [self.context save:&error];
    if (![self.context save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    } else {
        NSLog(@"Saved correctly");
    }
}

-(void)addComicToCollection:(Comic *)comicIn inCollection:(Collection *)collectionIn {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comic" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(SELF = %@)", comicIn];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    Comic *aComic = [fetchedObjects objectAtIndex:0];
    [aComic setIsPartOf:collectionIn];
    [collectionIn addCollectsObject:aComic];
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

-(NSArray *)getComicsByCollectionTitle:(NSString *)title {
    return 0;
}

-(NSArray *)getComicsByCollection:(Collection *)collectionIN {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Comic" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(isPartOf = %@)", collectionIN];
    [fetchRequest setPredicate:predicate];
    NSError *error;
    NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:&error];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"volumeNumber" ascending:YES];
    NSArray *sortedLinks = [fetchedObjects sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    for (NSManagedObject *info in fetchedObjects) {
        //NSLog(@"Title: %@", [info valueForKey:@"title"]);
        //NSLog(@"Type: %d", [info isKindOfClass:[Comic class]]);
    }
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

-(void)addCollectionTestData:(int)volumeNumber intoCollection:(Collection *)collectionIN {
    Comic *comicToBeSaved = [NSEntityDescription insertNewObjectForEntityForName:@"Comic"
                                                          inManagedObjectContext:self.context];
    [comicToBeSaved setTitle:@"Hawkeye"];
    [comicToBeSaved setVolumeNumber:[NSNumber numberWithInt:volumeNumber]];
    [comicToBeSaved setRating:[NSNumber numberWithInt:5]];
    [comicToBeSaved setPagesRead:[NSNumber numberWithInt:0]];
    [comicToBeSaved setComicVineURL:@""];
    [comicToBeSaved setIsPartOf:collectionIN];
    
    NSError *error;
    [self.context save:&error];
    if (![self.context save:&error]) {
        NSLog(@"Failed to save - error: %@", [error localizedDescription]);
    } else {
        NSLog(@"Saved correctly");
    }
}

@end
