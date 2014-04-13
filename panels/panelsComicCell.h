//
//  panelsComicCell.h
//  panels
//
//  Created by James A Hill on 10/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface panelsComicCell : UITableViewCell
- (void)setComicTitle:(NSString *)title;

- (void)setComicVolume:(NSNumber *)volume;

- (void)setComicImage:(UIImage *)image;

- (void)setComicPageProgress:(NSNumber *)totalPages atPage:(NSNumber *)page isCompleted:(BOOL)completed;
@end
