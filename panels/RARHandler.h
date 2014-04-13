//
//  RARHandler.h
//  panels
//
//  Created by James A Hill on 09/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Unrar4iOS/Unrar4iOS.h>
#import "ComicShelf.h"

@interface RARHandler : NSObject

/**
 *  Decompresses .rar file at given url
 *
 *  @param filePathIn     path to .rar
 *  @param title          title of comic
 *  @param volumeNumberIn volume number of comic
 */
- (int)decompressURL:(NSString *)filePathIn forTitle:(NSString *)title forVolume:(NSNumber *)volumeNumberIn;

@end
