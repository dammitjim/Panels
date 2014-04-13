//
//  RARHandler.m
//  panels
//
//  Created by James A Hill on 09/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "RARHandler.h"
#import <Unrar4IOS/RARExtractException.h>
#import "ComicShelf.h"

@interface RARHandler()
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *documentsDirectory;
@property (strong, nonatomic) Unrar4iOS *unrar;
@property (strong, nonatomic) NSArray *files;
@property (weak, nonatomic) UIImage *imageToSave;
@property (weak, nonatomic) NSData *binaryImageData;
@property (strong, nonatomic) ComicShelf *shelf;
@end

@implementation RARHandler

- (id)init {
    self = [super init];
    if(self) {
//        NSLog(@"Hey we just made a rarhandler");
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES);
        self.documentsDirectory = [paths objectAtIndex:0];
        NSMutableString *filePathBuilder = [[NSMutableString alloc] initWithString:self.documentsDirectory];
        self.filePath = filePathBuilder;
    }
    return self;
}

-(Unrar4iOS *)unrar {
    if(!_unrar) _unrar = [[Unrar4iOS alloc] init];
    return _unrar;
}

-(NSArray *)files {
    if(!_files) _files = [[NSArray alloc] init];
    return _files;
}
-(ComicShelf *)shelf {
    if(!_shelf) _shelf = [[ComicShelf alloc] init];
    return _shelf;
}

- (int)decompressURL:(NSString *)filePathIn forTitle:(NSString *)title forVolume:(NSNumber *)volumeNumberIn {

    // File path to the .cbr
    NSString *filePathRAR = [[NSString alloc] initWithFormat:@"%@/%@", self.filePath, filePathIn];
    NSLog(@"%@", filePathRAR);
	BOOL ok = [self.unrar unrarOpenFile:filePathRAR];
    
    // If file opened
	if (ok) {
        
        @autoreleasepool {
            
            // Get list of files
            self.files = [self.unrar unrarListFiles];
            
            // Extract a stream
            try {
                
                // Create folder in format /title/volumenumber
                NSString *folderTitle = [[NSString alloc] initWithFormat:@"/%@/%@/" ,title , [volumeNumberIn stringValue]];
                NSLog(@"Creating Folder: %@", folderTitle);
                NSString *dataPath = [self.documentsDirectory stringByAppendingPathComponent:folderTitle];
                NSError *error;
                
                int fileCount = 0;
                
                // If folder doesn't already exist
                if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
                    [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:&error]; //Create folder
                
                    for(int i = 0; i < [self.files count] ; i++) {
                        @autoreleasepool {
                            NSData *data = [self.unrar extractStream:[self.files objectAtIndex:i]];
                            
                            if (data != nil) {
                                
                                UIImage *imageToSave2 = [[UIImage alloc] initWithData:data];
                                NSData *binaryImageData2 = [[NSData alloc] init];
                                
                                if(i == 0) {
                                    
                                    // Generate comic cover and compress it for smaller file size
                                    CGSize imageSize = CGSizeMake(160, 256);
                                    UIImage *coverImage = [self compressImage:imageToSave2 scaledToSize:imageSize];
                                    binaryImageData2 = UIImagePNGRepresentation(coverImage);
                                    [binaryImageData2 writeToFile:[dataPath stringByAppendingPathComponent:@"cover.jpg"] atomically:YES];
                                    
                                }
                                
                                NSLog(@"Saving Image #%d", i+1);
                                binaryImageData2 = UIImagePNGRepresentation(imageToSave2);
                                [binaryImageData2 writeToFile:[dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.png", i]] atomically:YES];
                                fileCount++;
                            }
                        }
                    }
                    
                    NSLog(@"Removing file at: %@", filePathRAR);
                    [[NSFileManager defaultManager] removeItemAtPath:filePathRAR error:&error];
                    return fileCount;
                
                }
            catch(RARExtractException *error) {
                if(error.status == RARArchiveProtected) {
                    NSLog(@"Password protected archive!");
                    return 0;
                }
            }
            
            [self.unrar unrarCloseFile];
            return 0;
        }
	}
	else
		[self.unrar unrarCloseFile];
    return 0;
}

-(UIImage *)compressImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}



@end
