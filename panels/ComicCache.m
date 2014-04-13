//
//  ComicCache.m
//  panels
//
//  Created by James A Hill on 25/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "ComicCache.h"

@implementation ComicCache

-(void)addImage:(UIImage *)imageIn {
    [self.cachedImages addObject:imageIn];
    NSLog(@"Adding image to cache");
}

@end
