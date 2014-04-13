//
//  panelsReaderViewController.h
//  panels
//
//  Created by James A Hill on 19/03/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Comic.h"
#import "AudioToolbox/AudioToolbox.h"

@interface panelsReaderViewController : UIViewController
@property int pagesRead;

/**
 *  Sets the file for the reader
 *
 *  @param currentComic - comic to be read
 */
- (void)setComicToBeRead: (Comic *)currentComic;

@end
