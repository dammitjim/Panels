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

/**
 * Return object at index
 *
 * @param index index to return
 *
 * @return id, could be either collection or comic type
 */
-(id)getItemFromShelfAtIndex:(int)index;

/**
 *  Returns whole shelf of items
 *
 *  @return shelf
 */
-(NSArray *)getWholeShelf;

/**
 *  Gets relevant collections for picker view
 *
 *  @param defaultString default item for picker
 *
 *  @return array of collections
 */
-(NSArray *)getCollectionsForPicker:(NSString *)defaultString;

/**
 *  Returns comics by collection title
 *
 *  @param title
 *
 *  @return array of comics
 */
-(NSArray *)getComicsByCollectionTitle:(NSString *)title;

/**
 *  Add collection object to shelf
 *
 *  @param collectionIn
 */
-(void)addCollectionToShelf:(Collection *)collectionIn;

/**
 *  Returns comics for given collection
 *
 *  @param collectionIN
 *
 *  @return
 */
-(NSArray *)getComicsByCollection:(Collection *)collectionIN;

/**
 *  Returns a count of all shelf items
 *
 *  @return
 */
-(int)getTotalItems;

/**
 *  Adds cover to given comic object
 *
 *  @param comicIn
 *
 *  @return confirmation it was added
 */
-(BOOL)addCoverToComic:(Comic *)comicIn;

/**
 * Add comic to the shelf using parameters passed in, calls RARHandler after core data has been inserted to extract the .rar at the filepath.
 *
 * @param title            Comic title
 * @param volumeNumberIn   Volume number
 * @param filePath         Path to the relevant .rar
 * @param collectionTitle  Title of the associated collection
 *
 * @return Comic callback
 */
-(Comic *)addComicToShelfWithParameters:(NSString *)title withVolume:(NSNumber *)volumeNumberIn withPath:(NSString *)filePath inCollection:(NSString *)collectionTitle withPageCount:(int)pages;

/**
 *  Returns item in specified collection
 *
 *  @param collection - collection to search
 *  @param index      - index to return
 *
 *  @return comic - to be returned
 */
-(Comic *)getItemFromCollection:(Collection *)collection atIndex:(int)index;

/**
 *  Updates the pages read property of the comic
 *
 *  @param comic - the comic to be updated
 */
-(void)updatePagesReadForComic:(Comic *)comic toPage:(int)page;

-(void)addCollectionToShelfWithTitle:(NSString *)title;

-(void)removeCollection:(Collection *)collection;

-(void)removeComic:(Comic *)comic;

- (void)setComicCompleted:(Comic *)comic;

- (void)setComicTrashed:(Comic *)comic trashIt:(BOOL)trashMe;

- (NSArray *)getAllDeleted;

- (void)addItemToMover:(Comic *)comic;

- (void)removeItemFromMover:(Comic *)comic;

- (NSUInteger)getMoveItemsCount;

- (void)moveItemsToCollection:(Collection *)collection;

- (void)moveItemsToBase;

- (void)resetMovingItems;

- (void)clearMover;

- (Comic *)getComicByCollectionAndTitle:(NSString *)title withVolume:(int)volume;

- (int)getCompletedForCollection:(Collection *)collection;

- (NSArray *)getAllUnread;
@end
