//
//  Collection.h
//  panels
//
//  Created by James A Hill on 08/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Collection : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * comicVineURL;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSSet *collects;
@end

@interface Collection (CoreDataGeneratedAccessors)

- (void)addCollectsObject:(NSManagedObject *)value;
- (void)removeCollectsObject:(NSManagedObject *)value;
- (void)addCollects:(NSSet *)values;
- (void)removeCollects:(NSSet *)values;

@end
