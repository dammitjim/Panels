//
//  Comic.h
//  panels
//
//  Created by James A Hill on 22/05/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Collection;

@interface Comic : NSManagedObject

@property (nonatomic, retain) NSString * comicVineURL;
@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSData * cover;
@property (nonatomic, retain) NSNumber * isMoving;
@property (nonatomic, retain) NSNumber * isTrashed;
@property (nonatomic, retain) NSNumber * pagesRead;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * totalPages;
@property (nonatomic, retain) NSDecimalNumber * volumeNumber;
@property (nonatomic, retain) Collection *isPartOf;

@end
