//
//  ComicShelf.h
//  panels
//
//  Created by James A Hill on 08/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comic.h"
#import "Collection.h"
#import "panelsAppDelegate.h"
#import "RARHandler.h"


@interface ComicShelf : NSObject

-(id)getItemFromShelfAtIndex:(int)index;
-(Comic *)getComicFromShelfByTitle:(NSString *)title;
-(Collection *)getCollectionFromShelfByTitle:(NSString *)title;
-(NSArray *)getWholeShelf;
-(NSArray *)getComicsByCollectionTitle:(NSString *)title;
-(void)addComicToShelf:(Comic *)comicIn;
-(void)addCollectionToShelf:(Collection *)collectionIn;
-(void)addComicToCollection:(Comic *)comicIn inCollection:(Collection *)collectionIn;
-(NSArray *)getComicsByCollection:(Collection *)collectionIN;
-(int)getTotalItems;
-(void)addComicToShelfWithParameters:(NSString *)title withVolume:(NSNumber *)volumeNumberIn withPath:(NSString *)filePath inCollection:(NSString *)collectionTitle;

@end
