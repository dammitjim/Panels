//
//  Comic.h
//  panels
//
//  Created by James A Hill on 08/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Collection;

@interface Comic : NSManagedObject

@property (nonatomic, retain) NSString * comicVineURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * volumeNumber;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * pagesRead;
@property (nonatomic, retain) NSString * coverURL;
@property (nonatomic, retain) Collection *isPartOf;

@end
