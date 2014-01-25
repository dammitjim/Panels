//
//  panelsCollectionCell.h
//  panels
//
//  Created by James A Hill on 11/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Collection.h"
#import "ComicShelf.h"

@interface panelsCollectionCell : UITableViewCell

- (void)setCollectionTitle:(NSString *)title;

- (void)setCollectionImageView:(Collection *)collectionIn;

@end
