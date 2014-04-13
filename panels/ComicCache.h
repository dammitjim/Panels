//
//  ComicCache.h
//  panels
//
//  Created by James A Hill on 25/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ComicCache : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSMutableArray *cachedImages;

-(void)addImage:(UIImage *)imageIn;

@end
