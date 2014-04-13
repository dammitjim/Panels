//
//  panelsCollectionCell.m
//  panels
//
//  Created by James A Hill on 11/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "panelsCollectionCell.h"
@interface panelsCollectionCell ()
@property (strong, nonatomic) IBOutlet UIProgressView *collectionProgress;
@property (strong, nonatomic) IBOutlet UILabel *fileCountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageLabel4;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageLabel2;
@property (strong, nonatomic) IBOutlet UIImageView *imageLabel3;
@property (strong, nonatomic) IBOutlet UIImageView *imageLabel;
@property (strong, nonatomic) ComicShelf *shelf;
@property (strong, nonatomic) UIImage *comicImage;
@property (strong, nonatomic) NSMutableArray *covers;
@property (nonatomic) BOOL hasLoaded;
@end
@implementation panelsCollectionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.hasLoaded = false;
//        NSLog(@"Creating new collection cell");
    }
    return self;
}

-(NSMutableArray *) covers {
    if(!_covers) _covers = [[NSMutableArray alloc] init];
    return _covers;
}

-(ComicShelf *) shelf {
    if(!_shelf) _shelf = [[ComicShelf alloc] init];
    return _shelf;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCollectionTitle:(NSString *)title {
//    UIView *label = (UIView *)[self viewWithTag:301];
//    label.layer.masksToBounds = NO;
//    label.layer.shadowColor = [UIColor grayColor].CGColor;
//    label.layer.shadowOffset = CGSizeMake(10, 10);
//    label.layer.shadowOpacity = 0.2;
//    label.layer.shadowRadius = 5;
    self.titleLabel.text = title;
}

- (void)setCollectionFileCount:(int)count{
    NSString *fileLabelString = [NSString stringWithFormat:@"%d Files", count];
    self.fileCountLabel.text = fileLabelString;
}

-(void)clearSubviews {
}

- (void) prepareForReuse {
    self.comicImage = nil;
    [self setNeedsDisplay];
}

- (void)setCollectionFileProgress:(Collection *)collection {
    UIProgressView *progressBar = (UIProgressView *)[self viewWithTag:203];
    
    // This right here is what we call a "F**K IT" line of code, it works, it's horrificly overcomplicated, let's hope nobody notices.
    if([[self.shelf getComicsByCollection:collection] count]>0) {
        double progressCalculation = (([self.shelf getCompletedForCollection:collection]*100)/[[self.shelf getComicsByCollection:collection] count]);
        float currentProgress = progressCalculation/100;
        [progressBar setProgress:currentProgress];
    }
}

- (void)setCollectionImageView:(Collection *)collectionIn {
    self.comicImage = nil;
//    NSLog(@"Setting image for %@", [collectionIn title]);
    if(!self.hasLoaded) {
        // Gets comics to be used for covers
        NSArray *collectionComics = [self.shelf getComicsByCollection:collectionIn];
        int count = 0;
        
        // Maximum of 4 covers
        if([collectionComics count]>3) {
            count = 4;
        } else {
            count = (int)[collectionComics count];
        }
        
        for(int i=0; i< 4 ; i++) {
            
            // Get comic covers and set size
            if([collectionComics count]-1<i) {
//                NSLog(@"tits");
                self.comicImage = [UIImage imageWithContentsOfFile:@"blankCover.png"];
                switch (i) {
                    case 0:
                        self.imageLabel.image = nil;
                        self.imageLabel.image = self.comicImage;
                        break;
                        
                    case 1:
                        self.imageLabel2.image = nil;
                        self.imageLabel2.image = self.comicImage;
                        break;
                        
                    case 2:
                        self.imageLabel3.image = nil;
                        self.imageLabel3.image = self.comicImage;
                        break;
                        
                    case 3:
                        self.imageLabel4.image = nil;
                        self.imageLabel4.image = self.comicImage;
                        break;
                    default:
                        break;
                }
            } else {
                Comic *aComic = [collectionComics objectAtIndex:i];
                if([[aComic isMoving] boolValue]==NO) {
                    self.comicImage = [UIImage imageWithData:[aComic cover]];
                    CGSize imageSize = CGSizeMake(160, 256);
                    self.comicImage = [self compressImage:self.comicImage scaledToSize:imageSize];
                    
                    if (self.comicImage) {
                        
                        // Sets the cover to the appropriate slot
                        switch (i) {
                            case 0:
                                self.imageLabel.image = nil;
                                self.imageLabel.image = self.comicImage;
                                break;
                                
                            case 1:
                                self.imageLabel2.image = nil;
                                self.imageLabel2.image = self.comicImage;
                                break;
                                
                            case 2:
                                self.imageLabel3.image = nil;
                                self.imageLabel3.image = self.comicImage;
                                break;
                                
                            case 3:
                                self.imageLabel4.image = nil;
                                self.imageLabel4.image = self.comicImage;
                                break;
                            default:
                                break;
                        }
                    }
                }
            }

        }
    } else {
        NSLog(@"Already got this tho");
    }
}

-(void)addCoverToView:(UIImage *)cover {
    UIImageView *comicCover = [[UIImageView alloc] initWithFrame:CGRectMake(80*[self.covers count], 0, 80, 128)];
    CGSize imageSize = CGSizeMake(160, 256);
    [self compressImage:cover scaledToSize:imageSize];
    comicCover.image = cover;
    [self.covers addObject:cover];
//    NSLog(@"%lu", (unsigned long)[self.covers count]);
}

-(void)reloadScroller:(UIScrollView *)scrollViewIn {
    [self setNeedsLayout];
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

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}

@end
