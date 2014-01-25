//
//  RARHandler.m
//  panels
//
//  Created by James A Hill on 09/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "RARHandler.h"
#import <Unrar4IOS/RARExtractException.h>

@interface RARHandler()
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSString *documentsDirectory;
@property (strong, nonatomic) Unrar4iOS *unrar;
@property (strong, nonatomic) NSArray *files;
@property (weak, nonatomic) UIImage *imageToSave;
@property (weak, nonatomic) NSData *binaryImageData;
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

- (void)decompressURL:(NSString *)filePathIn forTitle:(NSString *)title forVolume:(NSNumber *)volumeNumberIn {
    //NSLog(@"Hey, we're trying here");
    NSString *filePathRAR = [[NSString alloc] initWithFormat:@"%@/%@", self.filePath, filePathIn];
    NSLog(@"%@", filePathRAR);
	BOOL ok = [self.unrar unrarOpenFile:filePathRAR];
	if (ok) {
        @autoreleasepool {
            self.files = [self.unrar unrarListFiles];
            for (NSString *filename in self.files) {
                //NSLog(@"File: %@", filename);
            }
            
            // Extract a stream
            try {
                NSString *folderTitle = [[NSString alloc] initWithFormat:@"/%@/%@/" ,title , [volumeNumberIn stringValue]];
                NSLog(@"Creating Folder: %@", folderTitle);
                NSString *dataPath = [self.documentsDirectory stringByAppendingPathComponent:folderTitle];
                NSError *error;
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
                    [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:&error]; //Create folder
                @autoreleasepool {
                    for(int i = 0; i < [self.files count] ; i++) {
                        NSData *data = [self.unrar extractStream:[self.files objectAtIndex:i]];
                        if (data != nil) {
                            if(i == 0) {
                                self.imageToSave = [UIImage imageWithData:data];
                                self.binaryImageData = UIImagePNGRepresentation(self.imageToSave);
                                
                                [self.binaryImageData writeToFile:[dataPath stringByAppendingPathComponent:@"cover.jpg"] atomically:YES];
                            }
                            NSLog(@"Saving Image #%d", i+1);
                            self.imageToSave = [UIImage imageWithData:data];
                            self.binaryImageData = UIImagePNGRepresentation(self.imageToSave);
                            
                            [self.binaryImageData writeToFile:[dataPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.jpg", i]] atomically:YES];
                            //                imageView.image = image;
                            self.imageToSave = nil;
                            self.binaryImageData = nil;
                        }
                    }
                }
            }
            catch(RARExtractException *error) {
                
                if(error.status == RARArchiveProtected) {
                    NSLog(@"Password protected archive!");
                }
            }
            
            [self.unrar unrarCloseFile];
        }
	}
	else
		[self.unrar unrarCloseFile];
}

@end
