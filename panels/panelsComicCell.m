//
//  panelsComicCell.m
//  panels
//
//  Created by James A Hill on 10/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "panelsComicCell.h"
@interface panelsComicCell()
@property (strong, nonatomic) IBOutlet UILabel *volumeLabel;
@property (strong, nonatomic) IBOutlet UITextView *nameText;
@property (strong, nonatomic) IBOutlet UIImageView *comicCover;
@end
@implementation panelsComicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setComicTitle:(NSString *)title {
    self.nameText.text = title;
}

- (void)setComicVolume:(NSNumber *)volume {
    self.volumeLabel.text = [NSString stringWithFormat:@"%@", [volume stringValue]];
}

- (void)setComicImage:(UIImage *)image {
    CGSize imageSize = CGSizeMake(230, 370);
    image = [self compressImage:image scaledToSize:imageSize];
    self.comicCover.image = image;
}

/*
 Credit to Brad Larson (Stack Overflow): http://stackoverflow.com/questions/612131/whats-the-easiest-way-to-resize-optimize-an-image-size-with-the-iphone-sdk
 */
-(UIImage *)compressImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
