//
//  panelsCollectionCell.m
//  panels
//
//  Created by James A Hill on 11/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "panelsCollectionCell.h"
@interface panelsCollectionCell ()
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) ComicShelf *shelf;
@property (weak, nonatomic) UIImage *comicImage;
@property (nonatomic) BOOL hasLoaded;
@end
@implementation panelsCollectionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.hasLoaded = false;
    }
    return self;
}

-(ComicShelf *)shelf {
    if(!_shelf) _shelf = [[ComicShelf alloc] init];
    return _shelf;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCollectionTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setCollectionImageView:(Collection *)collectionIn {
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    if(!self.hasLoaded) {
        @autoreleasepool {
            NSArray *collectionComics = [self.shelf getComicsByCollection:collectionIn];
            NSLog(@"Comics in %@: %lu,", [collectionIn title], (unsigned long)[collectionComics count]);
            [self.scrollView setContentSize:CGSizeMake((80*[collectionComics count])+20, 128)];
            NSLog(@"%@", [collectionIn title]);
            int xPos = 10;
            for(int i=0; i<[collectionComics count] ; i++) {
            NSMutableString *filePathBuilder = [[NSMutableString alloc] initWithString:@""];
            [filePathBuilder appendFormat:@"/%@/", [collectionIn title]];
            [filePathBuilder appendFormat:@"%@/", [[[collectionComics objectAtIndex:i] volumeNumber] stringValue]];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *outputPath = [documentsDirectory stringByAppendingPathComponent:filePathBuilder ];
            NSMutableString *finalFilePath = [[NSMutableString alloc] initWithString:outputPath];
            [finalFilePath appendString:@"/cover.jpg"];
            
            UIImageView *comicCover = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, 0, 80, 128)];
            CGSize imageSize = CGSizeMake(160, 256);
            self.comicImage = [UIImage imageWithContentsOfFile:finalFilePath];
            self.comicImage = [self compressImage:self.comicImage scaledToSize:imageSize];
            if (self.comicImage) {
                comicCover.image = self.comicImage;
            }
            [self.scrollView addSubview:comicCover];
            self.hasLoaded = true;
            xPos += 80;
            self.comicImage = nil;
            }
        }
    }
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
