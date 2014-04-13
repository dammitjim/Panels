//
//  panelsReaderViewController.m
//  panels
//
//  Some code here pulled from:
//  http://www.raywenderlich.com/10518/how-to-use-uiscrollview-to-scroll-and-zoom-content
//  for the basic scroll view and recognizers template.
//
//  Created by James A Hill on 19/03/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "panelsReaderViewController.h"
#import "ComicShelf.h"

@interface panelsReaderViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *readingScroll;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *previousPageView;
@property (strong, nonatomic) Comic *currentReading;
@property (strong, nonatomic) NSString *documentsDirectory;
@property (strong, nonatomic) UIView *bottomBar;
@property (strong, nonatomic) UILabel *bottomBarLabel;
@property (strong, nonatomic) UISlider *bottomBarSlider;
@property (strong, nonatomic) UIImageView *bottomBarSliderPreview;
@property (strong, nonatomic) UILabel *bottomBarSliderPreviewLabel;
@property (strong, nonatomic) UIView *notificationBox;
@property BOOL turningEnabled;
@property (nonatomic) CGSize screenSize;
@property BOOL navigationHidden;
@property BOOL hideStatusBar;
@property (strong, nonatomic) ComicShelf *saveShelf;
@property BOOL currentPageIsDouble;
@property BOOL isRotated;
@property (nonatomic) SystemSoundID sliderSound;
@property (nonatomic) SystemSoundID sliderRelease;
@property (nonatomic) SystemSoundID notification;
@property (nonatomic) SystemSoundID thud;
@property (nonatomic) SystemSoundID coin;
@property (nonatomic) int currentSliderPreviewPage;
@property (strong, nonatomic) NSUserDefaults *defaults;

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer;
- (void)scrollViewTapped:(UITapGestureRecognizer*)recognizer;

@end

@implementation panelsReaderViewController

@synthesize readingScroll = _readingScroll;
@synthesize imageView = _imageView;
@synthesize previousPageView = _previousPageView;
@synthesize navigationHidden = _navigationHidden;
@synthesize hideStatusBar = _hideStatusBar;
@synthesize pagesRead = _pagesRead;

- (Comic *)currentReading {
    if(!_currentReading) _currentReading = [[Comic alloc] init];
    return _currentReading;
}

-(NSUserDefaults *)defaults {
    if(!_defaults) _defaults = [NSUserDefaults standardUserDefaults];
    return _defaults;
}

-(UIView *)notificationBox {
    if(!_notificationBox) _notificationBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    return _notificationBox;
}

- (ComicShelf *)saveShelf {
    if(!_saveShelf) _saveShelf = [[ComicShelf alloc] init];
    return _saveShelf;
}

- (UIImageView *)previousPageView {
    if(!_previousPageView) _previousPageView = [[UIImageView alloc] init];
    return _previousPageView;
}

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    //NSLog(@"Double Tap");
    // Gets the point that was tapped
    CGPoint pointInView = [recognizer locationInView:self.imageView];
    
    // Recalculates the zoom scale to be 1.5x as zoomed in
    CGFloat newZoomScale = self.readingScroll.zoomScale * 1.5f;
    newZoomScale = MIN(newZoomScale, self.readingScroll.maximumZoomScale);
    
    // Sets the scroll view size
    CGSize scrollViewSize = self.readingScroll.bounds.size;
    
    // Creates a new rectangular viewport based on calculated data
    CGFloat w = scrollViewSize.width / newZoomScale;
    CGFloat h = scrollViewSize.height / newZoomScale;
    CGFloat x = pointInView.x - (w / 2.0f);
    CGFloat y = pointInView.y - (h / 2.0f);
    
    CGRect rectToZoomTo = CGRectMake(x, y, w, h);
    
    // Zooms to the rectangle
    [self.readingScroll zoomToRect:rectToZoomTo animated:YES];
}

- (void)scrollViewTapped:(UITapGestureRecognizer*)recognizer {
    NSLog(@"%f", self.navigationController.navigationBar.frame.size.height);
    // If the navigation bar is already hidden
    if(self.navigationHidden) {
//        [[self navigationController] setNavigationBarHidden:NO animated:YES];
        CGRect tmpFram = self.navigationController.navigationBar.frame;
        tmpFram.size.height += 25;
        self.navigationController.navigationBar.frame = tmpFram;
        self.navigationHidden = false;
        self.hideStatusBar = false;
        [UIView animateWithDuration:0.5 animations:^{
            self.bottomBar.alpha = 1.0;
            [self setNeedsStatusBarAppearanceUpdate];

            self.navigationController.navigationBar.frame = CGRectMake(0, 20, self.navigationController.navigationBar.frame.size.width, 44);
//                    }completion:^(BOOL finished) {
        }];
        
//        self.readingScroll.frame = CGRectMake(0, 0, 1000, 1000);
    } else {
//        // Hide the nav
        
        self.navigationHidden = true;
        self.hideStatusBar = true;
//        [[self navigationController] setNavigationBarHidden:YES animated:YES];
        [UIView animateWithDuration:0.5 animations:^{
            self.bottomBar.alpha = 0;
            [self setNeedsStatusBarAppearanceUpdate];
            self.navigationController.navigationBar.frame = CGRectMake(0, -100, self.navigationController.navigationBar.frame.size.width, 44);
//
        }completion:^(BOOL finished) {
            NSLog(@"Completed");
        }];

//
    }
//        [self logViews];
}


- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return self.hideStatusBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"";
    // Navigation controller configuration for a black theme
    self.navigationHidden = false;
    self.hideStatusBar = false;
    self.turningEnabled = true;
    self.currentPageIsDouble = false;
    self.currentSliderPreviewPage = 0;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        self.isRotated = false;
        NSLog(@"False");
    } else {
        NSLog(@"True");
        self.isRotated = true;
    }
//    [self.navigationController.navigationBar setAutoresizesSubviews:NO];
//    self.navigationController.view.autoresizesSubviews=NO;
    [self.navigationController.navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
//    [self.navigationController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
//    [self.view setAutoresizesSubviews:NO];
//    self.isRotated = false;
    self.pagesRead = [[self.currentReading pagesRead] intValue];
//    [self.currentReading setCompleted:0];
    NSLog(@"Current page: %d", self.pagesRead);
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                    };
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.opaque = NO;
    self.navigationController.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor blackColor];
    
    // Sets the document root for future calculations
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,    NSUserDomainMask, YES);
    self.documentsDirectory = [paths objectAtIndex:0];
    
    // Gets the last read page of the current comic
    NSLog(@"Current comic: %@ #%@", [self.currentReading title], [self.currentReading volumeNumber]);
    NSString *imagePath;
    if([[self.currentReading completed] boolValue]) {
        if([self.defaults boolForKey:@"settingsDefaultFirst"]) {
                imagePath = [[NSString alloc] initWithFormat:@"/%@/%@/%i.png" ,[self.currentReading title] , [[self.currentReading volumeNumber] stringValue], 0];
            self.pagesRead = 0;
            self.currentReading.pagesRead = 0;
        }
    } else {
        imagePath = [[NSString alloc] initWithFormat:@"/%@/%@/%i.png" ,[self.currentReading title] , [[self.currentReading volumeNumber] stringValue], self.pagesRead];
    }
    NSString *dataPath = [self.documentsDirectory stringByAppendingPathComponent:imagePath];
    NSLog(@"%@", dataPath);
    
    // Loads image into the view by building a filepath string and getting data from the path
    self.navigationItem.title = [NSString stringWithFormat:@"%@ #%@", [self.currentReading title], [self.currentReading volumeNumber]];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:dataPath]];
    
    self.imageView = [[UIImageView alloc] initWithImage:image];
    
    // Calculate screen size based on device
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenScale = [[UIScreen mainScreen] scale];
//    NSLog(@"Screen scale is %f", screenScale);

    self.screenSize = CGSizeMake(screenBounds.size.width * (screenScale+0.1), screenBounds.size.height * screenScale);
    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= self.screenSize};
    self.previousPageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= self.screenSize};
    self.readingScroll.contentSize = self.screenSize;
    
//    self.readingScroll.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
//    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
//    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // IF IMAGE IS A TWO PAGE SPREAD
    if(image.size.width>image.size.height) {
        
        // Creates new size
        CGSize DoublePager;
        DoublePager.height = self.screenSize.height;
        DoublePager.width = self.screenSize.width*2;
        
        float zoomScale = self.readingScroll.zoomScale;
        
        // THIS IS A VERY WEIRD BUG THAT ISN'T DOCUMENTED ANYWHERE BY APPLE - As far as I know
        // If you change the contentSize of a UIScrollView without resetting the zoomScale it
        // resets it to 1.0 for you but makes any further changes to it invalid. Odd.
        // So we solve it by just setting it to 1.0 before doing anything
        self.readingScroll.zoomScale = 1.0;
        self.readingScroll.contentSize = DoublePager;
        self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size = DoublePager};
        self.readingScroll.zoomScale = zoomScale;
        self.currentPageIsDouble = true;
    } else {
        // Regular page, regular scroll size
        float zoomScale = self.readingScroll.zoomScale;
        if(self.isRotated) {
            self.readingScroll.zoomScale = 1.0;
            CGSize newSize = self.screenSize;
            newSize.width = newSize.width*2;
            newSize.height = newSize.height*2;
            self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= newSize};
            //                self.previousPageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= newSize};
            NSLog(@"New bounds: %fx%f", self.view.bounds.size.width, self.view.bounds.size.height);
            self.readingScroll.frame = self.view.bounds;
            self.readingScroll.zoomScale = 0.5;
        } else {
            self.readingScroll.zoomScale = 1.0;
            self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= self.screenSize};
            self.readingScroll.zoomScale = zoomScale;
        }
        
    }
    
//    [self.readingScroll setAutoresizingMask:UIViewAutoresizingNone];
//    [self.imageView setAutoresizingMask:UIViewAutoresizingNone];
//    [self.view setAutoresizingMask:UIViewAutoresizingNone];
//    [self.view.superview setAutoresizingMask:UIViewAutoresizingNone];
//    [self.navigationController.navigationBar setAutoresizingMask:UIViewAutoresizingNone];
    
    [self.readingScroll addSubview:self.imageView];
    [self buildBottomBar];
    [self createSoundId];
    // Set up tap gesture recognizers
    
    // Zoom on double tap
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.readingScroll addGestureRecognizer:doubleTapRecognizer];
    
    // Show/Hide menu
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    
    // Only fired if double tap fails to fire
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [self.readingScroll addGestureRecognizer:singleTapRecognizer];
    
//    [self completionBar];
}

/**
 *  Fire whenever scrolling is happening, method checks to see if page needs to be changed
 *
 *  @param scrollView
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(self.readingScroll.contentOffset.y > 0) {
//        [self.readingScroll setContentOffset: CGPointMake(self.readingScroll.contentOffset.x, 0)];
    }
    //NSLog(@"%f", scrollView.contentOffset.y);
    // Checks if the content is offset from the image frame (dragged outside the boundaries)
    if(self.turningEnabled) {
        if(scrollView.contentOffset.x<-50 && scrollView.contentOffset.x>-55) {
            if(!self.readingScroll.zooming) {
                NSLog(@"Previous page");
                if(self.pagesRead!=0) {
                    self.pagesRead--;
                    [self updatePage:self.pagesRead fromPage:self.pagesRead+1];
                }
            }
        }
        
        // Does the same but for the right side, extra math required as the offset starts at 360 rather than 0
        if (scrollView.contentOffset.x > (scrollView.contentSize.width - scrollView.frame.size.width)) {
            float size = scrollView.contentSize.width - scrollView.frame.size.width;
            // If the offset boundary to turn the page has been reached and the image isn't currently zooming
            if((size - scrollView.contentOffset.x)<-50 && (size - scrollView.contentOffset.x)>-55) {
                if(!self.readingScroll.zooming) {
                    NSLog(@"Next page with offset: %f", scrollView.contentOffset.x);
                    // Increment pages read
                    self.pagesRead++;
                    NSLog(@"Changing page to: %d", self.pagesRead);
                    [self updatePage:self.pagesRead fromPage:self.pagesRead-1];
                }
            }
        }
    }
}

/**
 *  It would probably make sense to split this into it's own class, however for now it is functional.
 */
- (void)buildBottomBar {
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    // Calculate the y axis position of the bar, take the height and subtract it from any current view on the stage to determine the position of the bottom of the page, then subtract the height of the view to be added to place it on screen
    float y = screenBounds.size.height- [UIApplication sharedApplication].statusBarFrame.size.height - 40;
    
    self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, y, screenBounds.size.width, 65)];
    
    // Customization
    self.bottomBar.backgroundColor = [UIColor blackColor];
    self.bottomBar.opaque = NO;
    self.bottomBar.alpha = 0.95;
    self.bottomBar.tintColor = [UIColor orangeColor];
    
    self.bottomBarSlider = [[UISlider alloc] initWithFrame:CGRectMake(10, 15, screenBounds.size.width-130, 30)];
    NSLog(@"%f", screenBounds.size.width);
    self.bottomBarSlider.maximumValue = [[self.currentReading totalPages] floatValue];
    NSLog(@"Max value: %f", self.bottomBarSlider.maximumValue);
    self.bottomBarSlider.minimumValue = 1;
    self.bottomBarSlider.tintColor = [UIColor orangeColor];
    self.bottomBarSlider.value = [[self.currentReading pagesRead] floatValue];
    [self.bottomBarSlider addTarget:self action:@selector(sliderValueChange: ) forControlEvents:UIControlEventValueChanged];
    [self.bottomBarSlider addTarget:self action:@selector(sliderValueEnd: ) forControlEvents:UIControlEventTouchUpInside];
    self.bottomBarSlider.continuous = YES;
//    NSLog(@"Float value of totalpages: %f", [[self.currentReading totalPages] floatValue]);
    
    self.bottomBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenBounds.size.width-100, 15, 100, 30)];
    self.bottomBarLabel.textColor = [UIColor orangeColor];
    self.bottomBarLabel.text = [NSString stringWithFormat:@"Page %d/%d", [[self.currentReading pagesRead] intValue]+1, [[self.currentReading totalPages] intValue]];
    
    self.bottomBarSliderPreview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"download.png"]];
    self.bottomBarSliderPreview.frame = CGRectMake(0, -250, 160, 256);
    self.bottomBarSliderPreview.hidden = YES;
    
    self.bottomBarSliderPreviewLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 20)];
    double pageValue = roundf(self.bottomBarSlider.value);
    self.bottomBarSliderPreviewLabel.text = [NSString stringWithFormat:@"Page %d", (int)pageValue+1];
    self.bottomBarSliderPreviewLabel.opaque = NO;
    self.bottomBarSliderPreviewLabel.backgroundColor = [UIColor blackColor];
    self.bottomBarSliderPreviewLabel.textColor = [UIColor whiteColor];
    self.bottomBarSliderPreviewLabel.alpha = 0.75;
    self.bottomBarSliderPreviewLabel.tintColor = [UIColor orangeColor];
    
    [self.view addSubview:self.bottomBar];
    [self.bottomBar addSubview:self.bottomBarSlider];
    [self.bottomBar addSubview:self.bottomBarLabel];
    [self.bottomBar addSubview:self.bottomBarSliderPreview];
    [self.bottomBarSliderPreview addSubview:self.bottomBarSliderPreviewLabel];
}

- (void)sliderValueEnd:(id)sender {
    if(![self.defaults boolForKey:@"settingsSound"]) {
        AudioServicesPlaySystemSound(self.sliderRelease);
    }
    self.bottomBarSliderPreview.hidden = YES;
    double pageValue = roundf(self.bottomBarSlider.value);
    NSLog(@"Setting page to: %d", (int)pageValue);
    [self updatePage:(int)pageValue-1 fromPage:[[self.currentReading pagesRead] intValue]];
    self.pagesRead = (int)pageValue-1;
    self.bottomBarLabel.text = [NSString stringWithFormat:@"Page %d/%d", self.pagesRead+1, [[self.currentReading totalPages] intValue]];
}

- (void)sliderValueChange:(id)sender {
    
    double pageValue = roundf(self.bottomBarSlider.value);
    if((int)pageValue != self.currentSliderPreviewPage) {
        NSLog(@"%d, %d", (int)pageValue, self.currentSliderPreviewPage);
        self.bottomBarSliderPreview.hidden = NO;
        self.currentSliderPreviewPage = (int) pageValue;
        
        /*
         The code to calculate the slider location on screen was taken from user willc2's post here: http://stackoverflow.com/questions/1714405/how-to-get-the-center-of-the-thumb-image-of-uislider
         */
        float sliderRange = self.bottomBarSlider.frame.size.width - self.bottomBarSlider.currentThumbImage.size.width;
        float sliderOrigin = self.bottomBarSlider.frame.origin.x + (self.bottomBarSlider.currentThumbImage.size.width / 2.0);
        
        float sliderValueToPixels = (((self.bottomBarSlider.value-self.bottomBarSlider.minimumValue)/(self.bottomBarSlider.maximumValue-self.bottomBarSlider.minimumValue)) * sliderRange) + sliderOrigin;
        
        CGRect newPosition = self.bottomBarSliderPreview.frame;
        newPosition.origin.x = sliderValueToPixels;
        
        if(![self.defaults boolForKey:@"settingsSound"]) {
            AudioServicesPlaySystemSound(self.sliderSound);
        }
        self.bottomBarSliderPreview.frame = newPosition;
        self.bottomBarSliderPreview.image = [self loadCoverImageFromPage:(int)pageValue-1];
        self.bottomBarSliderPreviewLabel.text = [NSString stringWithFormat:@"Page %d", (int)pageValue];
    }
}

- (void)buildNotification {
    
}
- (void)completionBar {
    self.notificationBox.center = self.view.center;
    self.notificationBox.opaque = YES;
    self.notificationBox.alpha = 0;
    UIImageView *tickBox = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    [tickBox setImage:[UIImage imageNamed:@"Great-success.png"]];
    
    [self.view addSubview:self.notificationBox];
    [self.notificationBox addSubview:tickBox];
    [UIView animateWithDuration:0.5 animations:^{
        self.notificationBox.alpha = 1.0;
            } completion:^(BOOL finished) {
                if(![self.defaults boolForKey:@"settingsSound"]) {
                    AudioServicesPlaySystemSound(self.notification);
                }
                [UIView animateWithDuration:0.5 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.notificationBox.alpha = 0;
                }completion:^(BOOL finished) {
                    [tickBox removeFromSuperview];
                }];
            }];

    ////    tickBox.center = self.view.center;
////    self.notificationBox.center = self.view.center;
//    self.notificationBox.opaque = YES;
//    self.notificationBox.alpha = 0;
//    CGRect originalFrame = self.notificationBox.frame;
//    CGRect frame2 = originalFrame;
//    frame2.origin.x = -500;
//    UIImageView *tickBox = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 3000, 3000)];
////    tickBox.center = self.view.center;
//    CGRect frame = tickBox.frame;
//    frame.size.height = 200;
//    frame.size.width = 220;
//    [tickBox setImage:[UIImage imageNamed:@"read_stamp.png"]];
//    [self.view addSubview:self.notificationBox];
//    [self.notificationBox addSubview:tickBox];
////    progressDrop.alpha
//    
////    AudioServicesPlaySystemSound(self.notification);
//    [UIView animateWithDuration:0.5 animations:^{
//        self.notificationBox.alpha = 1.0;
//        tickBox.frame = frame;
//    } completion:^(BOOL finished) {
//        if(![self.defaults boolForKey:@"settingsSound"]) {
//            AudioServicesPlaySystemSound(self.thud);
////            AudioServicesPlaySystemSound(self.r)
//        }
//        [UIView animateWithDuration:0.5 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            self.notificationBox.alpha = 0;
////            CGRect originalFrame = self.notificationBox.frame;
////            CGRect frame2 = originalFrame;
////            frame2.origin.x = -500;
////            self.notificationBox.frame = frame2;
//        }completion:^(BOOL finished) {
//            [tickBox removeFromSuperview];
////            self.notificationBox.frame = originalFrame;
////            self.notificationBox.center = self.view.center;
//        }];
//    }];
    self.notificationBox.center = self.view.center;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"View will appear");
    
    // Sets zoom scale based on the content size
    self.readingScroll.minimumZoomScale = 0.50;
    
    // Maximum zoom scale
    self.readingScroll.maximumZoomScale = 6.0;
    self.readingScroll.delegate = self;
    self.readingScroll.zoomScale = 0.5;
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    self.navigationController.navigationBar.titleTextAttributes = @{
                                                                    NSForegroundColorAttributeName : [UIColor whiteColor]
                                                                    };
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"%d", self.pagesRead);
    self.readingScroll.delegate = nil;
    if(![[self.currentReading completed] boolValue]) {
        [self.saveShelf updatePagesReadForComic:self.currentReading toPage:self.pagesRead];
    }

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setComicToBeRead:(Comic *)currentComic {
    self.currentReading = currentComic;
}

/**
 *  Updates the current image to the next or previous page
 *
 *  @param pageNumber  The page the view needs to transition to
 *  @param currentPage The page the view needs to transition from
 */
- (void)updatePage:(int)pageNumber fromPage:(int)currentPage {
    
    // Placeholder image
    UIImage *image;
    // Reset frame for when the page is turned
    CGRect defaultFrame;
    defaultFrame.origin.x = 0;
    defaultFrame.origin.y = 0;
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    self.screenSize = CGSizeMake(screenBounds.size.width * (screenScale+0.1), screenBounds.size.height * screenScale);
    
    // True = next page, false = previous
    BOOL forwardsOrBackwards = false;
    
    if(pageNumber>currentPage) {
        
        // Forwards
        forwardsOrBackwards = true;
        
        // Set the placeholder image to the next page's image
//        image = [self getNextPageImage:currentPage];
        image = [self getPageImage:pageNumber];
        
        // If double page spread
        if(image.size.width>image.size.height) {
            
            // Creates new size
            CGSize DoublePager;
            DoublePager.height = self.screenSize.height;
            DoublePager.width = self.screenSize.width*2;
            
            float zoomScale = self.readingScroll.zoomScale;
            
            // THIS IS A VERY WEIRD BUG THAT ISN'T DOCUMENTED ANYWHERE BY APPLE - As far as I know
            // If you change the contentSize of a UIScrollView without resetting the zoomScale it
            // resets it to 1.0 for you but makes any further changes to it invalid. Odd.
            // So we solve it by just setting it to 1.0 before doing anything
            self.readingScroll.zoomScale = 1.0;
            self.readingScroll.contentSize = DoublePager;
            self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size = DoublePager};
            self.readingScroll.zoomScale = zoomScale;
            self.currentPageIsDouble = true;
        } else {
            // Regular page, regular scroll size
            float zoomScale = self.readingScroll.zoomScale;
            if(self.isRotated) {
                self.readingScroll.zoomScale = 1.0;
                CGSize newSize = self.screenSize;
                newSize.width = newSize.width*2;
                newSize.height = newSize.height*2;
                self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= newSize};
//                self.previousPageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= newSize};
                NSLog(@"New bounds: %fx%f", self.view.bounds.size.width, self.view.bounds.size.height);
                self.readingScroll.frame = self.view.bounds;
                self.readingScroll.zoomScale = 0.5;
            } else {
                self.readingScroll.zoomScale = 1.0;
                self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= self.screenSize};
                self.readingScroll.zoomScale = zoomScale;
            }


            self.currentPageIsDouble = false;
            
        }
        if(image!=NULL) {
            
            // Sets placeholder imageView image, this will be the graphic that appears behind the animating image during the page flick transition
            [self.previousPageView setImage:image];
            
            // Sets the frame of the previous image to whatever is currently held in the transitioning image for a smoother animation
            CGRect frame = self.imageView.frame;
            self.previousPageView.frame = frame;
            
            self.bottomBarSlider.value = pageNumber;
            self.bottomBarLabel.text = [NSString stringWithFormat:@"Page %d/%d", self.pagesRead+1, [[self.currentReading totalPages] intValue]];
            
            // The frame is going to transition 360 units off screen
            frame.origin.x = -360;
            
            // Inserts the placeholder imageView underneath the animating view to make it look like a stack
            [self.readingScroll insertSubview:self.previousPageView belowSubview:self.imageView];
            
            // Prevents a LOT of bugs from happening during the transition
            self.readingScroll.scrollEnabled = NO;
            
            //NSLog(@"Current page: %d - Previous page: %d", currentPage, pageNumber);
            
            // Sets the content offset to be smaller than the boundary to change page, otherwise it will just change 100 pages at once
//            [self.readingScroll setContentOffset:CGPointMake(0, 20) animated:YES];
            
            // View animation options
            [UIView animateWithDuration:0.2f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 
                                 NSLog(@"Frame is: %f", self.imageView.frame.origin.x);
                                 self.imageView.frame = frame;
                                 self.imageView.alpha = 0;
                                 
                                 // Disables page turning while animating
                                 self.turningEnabled = false;
                                 
                             }
                             completion:^(BOOL finished){
                                 if (finished) {
                                     // Animation has finished, moves the frame to overlap the imageView placeholder
                                     CGRect frame = self.imageView.frame;
                                     frame.origin.x = 0;
                                     frame.origin.y = 0;
                                     self.imageView.frame = frame;
                                     self.imageView.alpha = 1;
                                     
                                     // Reenables scrolling now that the image is in position
                                     self.readingScroll.scrollEnabled = YES;
                                     
                                     // Sets the new image
                                     [self.imageView setImage:image];
                                     self.turningEnabled = true;
                                     
                                     [self.readingScroll setContentOffset:CGPointMake(0, 0) animated:YES];
                                     
                                     // Removes the placeholder imageView
                                     [self.previousPageView removeFromSuperview];
                                 }
                             }];
//            NSLog(@"%d/%d", pageNumber, [[self.currentReading totalPages] intValue]);
            if(pageNumber+1 == [[self.currentReading totalPages] intValue] || pageNumber == [[self.currentReading totalPages] intValue]) {
                NSLog(@"Yall reached the end");
                if([[self.currentReading completed] intValue]==0) {
                    NSLog(@"Hasn't completed");
                    [self completionBar];
                    [self.currentReading setCompleted:[NSNumber numberWithBool:1]];
                    [self.saveShelf setComicCompleted:self.currentReading];
                } else {
                    NSLog(@"Comic completed");
                    [self completionBar];
                }
            }
        } else {
            // If image returns null, that means that the end of the document has been reached so the page should change to the next comic
            self.pagesRead = currentPage;
            NSLog(@"Yall reached the end");
            if([[self.currentReading completed] intValue]==0) {
                NSLog(@"Hasn't completed %d", self.pagesRead);
                [self.saveShelf setComicCompleted:self.currentReading];
                [self.saveShelf updatePagesReadForComic:self.currentReading toPage:self.pagesRead];
            } else {
                NSLog(@"Comic completed 2");
//                [self completionBar];
            }
            Collection *currentCollection = [self.currentReading isPartOf];
            NSArray *collectionItems = [self.saveShelf getComicsByCollection:currentCollection];
            int index = 0;
            for(int i = 0 ; i < [collectionItems count] ; i++) {
                if([[collectionItems objectAtIndex:i] title]== [self.currentReading title]) {
                    if([[collectionItems objectAtIndex:i] volumeNumber] == [self.currentReading volumeNumber]) {
                        NSLog(@"Next comic is at position %d in the collection", i+1);
                        index = i+1;
                    }
                }
            }
            if(index<[collectionItems count]) {
                Comic *nextComic = [collectionItems objectAtIndex:index];
                if(nextComic!=nil) {
                    NSLog(@"There's another comic here: %@ vol %d", [nextComic title], [[nextComic volumeNumber] intValue]);
                    [self setCurrentReading:nextComic];
                    self.pagesRead = 0;
                    [self updatePage:0 fromPage:0];
                    [self.bottomBar removeFromSuperview];
                    [self buildBottomBar];
                    self.navigationItem.title = [NSString stringWithFormat:@"%@ #%d", [nextComic title], [[nextComic volumeNumber] intValue]];
                }
            }
        }
    } else {
        // Backwards
        forwardsOrBackwards = false;
//        image = [self getPreviousPageImage:currentPage];
        image = [self getPageImage:pageNumber];
        
        if(image!=NULL) {
            
            // If double page spread
            if(image.size.width>image.size.height) {
                
                // Creates new size
                CGSize DoublePager;
                DoublePager.height = self.screenSize.height;
                DoublePager.width = self.screenSize.width*2;
                
                // THIS IS A VERY WEIRD BUG THAT ISN'T DOCUMENTED ANYWHERE BY APPLE - As far as I know
                // If you change the contentSize of a UIScrollView without resetting the zoomScale it
                // resets it to 1.0 for you but makes any further changes to it invalid. Odd.
                // So we solve it by just setting it to 1.0 before doing anything
                self.readingScroll.zoomScale = 1.0;
                self.readingScroll.contentSize = DoublePager;
                self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size = DoublePager};
                self.readingScroll.zoomScale = 0.5;
                self.currentPageIsDouble = true;
            } else {
                // Regular page, regular scroll size
                float zoomScale = self.readingScroll.zoomScale;
                if(self.isRotated) {
                    self.readingScroll.zoomScale = 1.0;
                    CGSize newSize = self.screenSize;
                    newSize.width = newSize.width*2;
                    newSize.height = newSize.height*2;
                    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= newSize};
                    //                self.previousPageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= newSize};
                    NSLog(@"New bounds: %fx%f", self.view.bounds.size.width, self.view.bounds.size.height);
                    self.readingScroll.frame = self.view.bounds;
                    self.readingScroll.zoomScale = 0.5;
                } else {
                    self.readingScroll.zoomScale = 1.0;
                    self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= self.screenSize};
                    self.readingScroll.zoomScale = zoomScale;
                }
                self.currentPageIsDouble = false;
                
            }
            [self.previousPageView setImage:image];
            
            CGRect frame = self.imageView.frame;
            frame.origin.x = -360;
            self.previousPageView.frame = frame;
            frame.origin.x = 0;
            
            self.bottomBarSlider.value = pageNumber;
            self.bottomBarLabel.text = [NSString stringWithFormat:@"Page %d/%d", self.pagesRead+1, [[self.currentReading totalPages] intValue]];
            
            [self.readingScroll insertSubview:self.previousPageView aboveSubview:self.imageView];
            self.readingScroll.scrollEnabled = NO;
//            [self.readingScroll setContentOffset:CGPointMake(0, 20) animated:YES];

            // View animation options
            [UIView animateWithDuration:0.2f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 
//                                 NSLog(@"Frame is: %f", self.imageView.frame.origin.x);
//                                 self.imageView.frame = frame;
//                                 self.imageView.alpha = 0;
                                 self.previousPageView.frame = frame;
                                 
                                 // Disables page turning while animating
                                 self.turningEnabled = false;
                                 
                             }
                             completion:^(BOOL finished){
                                 if (finished) {
                                     // Animation has finished, moves the frame to overlap the imageView placeholder
                                     CGRect frame = self.previousPageView.frame;
                                     frame.origin.x = 0;
                                     frame.origin.y = 0;
                                     self.imageView.frame = frame;
                                     self.imageView.alpha = 1;
                                     [self.readingScroll setContentOffset:CGPointMake(0, 0) animated:YES];
                                     // Reenables scrolling now that the image is in position
                                     self.readingScroll.scrollEnabled = YES;
                                     
                                     // Sets the new image
                                     [self.imageView setImage:image];
                                     self.turningEnabled = true;
                                     
                                     // Removes the placeholder imageView
                                     [self.previousPageView removeFromSuperview];
                                 }
                             }];
        } else {
            self.pagesRead = currentPage;
        }
    }
}

- (UIImage *)loadCoverImageFromPage:(int)pageNumber {
    NSString *imagePath = [[NSString alloc] initWithFormat:@"/%@/%@/%i.png" ,[self.currentReading title] , [[self.currentReading volumeNumber] stringValue], pageNumber];
    NSString *dataPath = [self.documentsDirectory stringByAppendingPathComponent:imagePath];
    //NSLog(@"%@", dataPath);
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:dataPath]];
    return [self compressImage:image scaledToSize:CGSizeMake(160, 256)];
}

- (UIImage *)getPageImage:(int)pageNumber {
    NSString *imagePath = [[NSString alloc] initWithFormat:@"/%@/%@/%i.png" ,[self.currentReading title] , [[self.currentReading volumeNumber] stringValue], pageNumber];
    NSString *dataPath = [self.documentsDirectory stringByAppendingPathComponent:imagePath];
    //NSLog(@"%@", dataPath);
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:dataPath]];
    return image;
}

- (UIImage *)getNextPageImage:(int)pageNumber {
    NSString *imagePath = [[NSString alloc] initWithFormat:@"/%@/%@/%i.png" ,[self.currentReading title] , [[self.currentReading volumeNumber] stringValue], pageNumber+1];
    NSString *dataPath = [self.documentsDirectory stringByAppendingPathComponent:imagePath];
    //NSLog(@"%@", dataPath);
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:dataPath]];
    return image;
}

- (UIImage *)getPreviousPageImage:(int)pageNumber {
    NSString *imagePath = [[NSString alloc] initWithFormat:@"/%@/%@/%i.png" ,[self.currentReading title] , [[self.currentReading volumeNumber] stringValue], pageNumber-1];
    NSString *dataPath = [self.documentsDirectory stringByAppendingPathComponent:imagePath];
    //NSLog(@"%@", dataPath);
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:dataPath]];
    return image;
}

-(UIImage *)compressImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(self.hideStatusBar) {
        
        // THIS IS A TERRIBLE THING I RECOMMEND NOT DOING THIS
        // I HAVE DONE THIS BECAUSE I HAD TWO DAYS TO FIX THIS BUG
        // BASICALLY, HIDING THE BAR SCREWS WITH THE AUTOLAYOUT, SO WE JUST THROW IT OFFSCREEN
        // THE "I'LL JUST PUT THIS OVER HERE AND HOPE NOBODY NOTICES IT" TECHNIQUE
        // IT'S SUUUUUPER BAD TO BE MESSING WITH NAVBAR FRAMES SO YEAH
        self.navigationController.navigationBar.frame = CGRectMake(0, -100, self.navigationController.navigationBar.frame.size.width, 44);
    }
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        NSLog(@"called");
        self.notificationBox.center = self.view.center;
        self.isRotated = true;
        float y = screenBounds.size.width- [UIApplication sharedApplication].statusBarFrame.size.width - 40;
//        self.view.frame = CGRectMake(0, 0, screenBounds.size.height, screenBounds.size.width);
        NSLog(@"%f", self.view.frame.size.width);
        if(self.hideStatusBar) {
            self.bottomBar.frame = CGRectMake(0, y-20, screenBounds.size.height, 65);
        } else {
            self.bottomBar.frame = CGRectMake(0, y, screenBounds.size.height, 65);
        }
        self.bottomBarSliderPreview.frame = CGRectMake(0, -192, 120, 192);
        self.bottomBarLabel.frame = CGRectMake(screenBounds.size.height-100, 15, 100, 30);
        self.bottomBarSliderPreviewLabel.frame = CGRectMake(0, 0, 120, 20);
        self.bottomBarSlider.frame = CGRectMake(10, 15, screenBounds.size.height-130, 30);
        
        if(self.currentPageIsDouble) {
//            self.view.frame = CGRectMake(0, 0, 568, 320);
//            [self.view setNeedsDisplay];
            NSLog(@"%f", self.view.frame.size.width);
            
//            self.view.bounds = CGRectMake(0, 0, 1024, 320);
            NSLog(@"It's a double page yo");
            self.readingScroll.zoomScale = 1.0;
            CGSize newSize = self.screenSize;
            newSize.height = newSize.height*1;
            newSize.width = newSize.width*2;
//            newSize.width = newSize.width*2;
            self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= newSize};
//            self.imageView.frame = self.view.bounds;
            self.previousPageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= newSize};
            NSLog(@"New bounds: %fx%f", self.view.bounds.size.width, self.view.bounds.size.height);
            self.readingScroll.frame = self.view.bounds;
//            self.readingScroll.frame = CGRectMake(0,0, screenBounds.size.height, screenBounds.size.width);
            self.readingScroll.zoomScale = 0.5;

        } else {
            
            self.readingScroll.zoomScale = 1.0;
            CGSize newSize = self.screenSize;
            newSize.height = newSize.height*2;
            newSize.width = newSize.width*2;
            self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= newSize};
            self.previousPageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= newSize};
            NSLog(@"New bounds: %fx%f", self.view.bounds.size.width, self.view.bounds.size.height);
            self.readingScroll.frame = self.view.bounds;
            self.readingScroll.zoomScale = 0.5;
//            self.readingScroll.frame = newFrame;
        }
//        self.view.frame = CGRectMake(0, 0, 100000, 10000);
        CGRect tmpFram = self.navigationController.navigationBar.frame;
//        tmpFram.size.height += 10;
        self.navigationController.navigationBar.frame = tmpFram;
    }
    else {
        self.isRotated = false;
        self.notificationBox.center = self.view.center;
        // Repositioning bottom bar assets
        float y = screenBounds.size.height- [UIApplication sharedApplication].statusBarFrame.size.height - 40;
        
        if(self.hideStatusBar) {
            self.bottomBar.frame = CGRectMake(0, y-20, screenBounds.size.width, 65);
        } else {
            self.bottomBar.frame = CGRectMake(0, y, screenBounds.size.width, 65);
        }
        self.bottomBarSliderPreview.frame = CGRectMake(0, -250, 160, 256);
        self.bottomBarLabel.frame = CGRectMake(screenBounds.size.width-100, 15, 100, 30);
        self.bottomBarSliderPreviewLabel.frame = CGRectMake(0, 0, 160, 20);
        self.bottomBarSlider.frame = CGRectMake(10, 15, screenBounds.size.width-130, 30);
        
        if(self.currentPageIsDouble) {
            // Creates new size
            CGSize DoublePager;
            DoublePager.height = self.screenSize.height;
            DoublePager.width = self.screenSize.width*2;
            
            float zoomScale = self.readingScroll.zoomScale;
            
            self.readingScroll.zoomScale = 1.0;
            self.readingScroll.contentSize = DoublePager;
            self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size = DoublePager};
            self.readingScroll.zoomScale = zoomScale;
            self.currentPageIsDouble = true;
        } else {
            self.screenSize = CGSizeMake(screenBounds.size.width * (screenScale+0.1), screenBounds.size.height * screenScale);
            self.readingScroll.zoomScale = 1.0;
            self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= self.screenSize};
            self.previousPageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size= self.screenSize};
            self.readingScroll.contentSize = self.screenSize;
            self.readingScroll.zoomScale = 0.5;
        }
        CGRect tmpFram = self.navigationController.navigationBar.frame;
//        tmpFram.size.y -= 20;
        self.navigationController.navigationBar.frame = tmpFram;

    }
    
    [self.view setNeedsUpdateConstraints];
    [self logViews];
    
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(void)logViews {
    NSArray *subviews = self.view.subviews;
    for(int i = 0 ; i < [subviews count] ; i++) {
        NSLog(@"Type: %@", [[subviews objectAtIndex:i] class]);
        UIView *view = [subviews objectAtIndex:i];
        NSLog(@"View dimensions: %fx%f", view.frame.size.width, view.frame.size.height);
        NSLog(@"View bounds: %fx%f", view.bounds.size.width, view.bounds.size.height);
    }
}

- (void) createSoundId
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"slider_blip" ofType:@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundPath])
    {
        NSURL* soundPathURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundPathURL, &_sliderSound);
    }
    
    soundPath = [[NSBundle mainBundle] pathForResource:@"slider_release" ofType:@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundPath])
    {
        NSURL* soundPathURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundPathURL, &_sliderRelease);
    }
    
    soundPath = [[NSBundle mainBundle] pathForResource:@"success" ofType:@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundPath])
    {
        NSURL* soundPathURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundPathURL, &_notification);
    }
    
    soundPath = [[NSBundle mainBundle] pathForResource:@"thud" ofType:@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundPath])
    {
        NSURL* soundPathURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundPathURL, &_thud);
    }
    
    soundPath = [[NSBundle mainBundle] pathForResource:@"coin" ofType:@"wav"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:soundPath])
    {
        NSURL* soundPathURL = [NSURL fileURLWithPath:soundPath];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundPathURL, &_coin);
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
