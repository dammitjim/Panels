//
//  panelsNavigationController.m
//  panels
//
//  Created by James A Hill on 08/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "panelsNavigationController.h"
#import "panelsReaderViewController.h"

@interface panelsNavigationController ()

@end

@implementation panelsNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Panels";
        [self.navigationBar setAutoresizesSubviews:NO];
    }
    return self;
}

//- (BOOL)shouldAutorotate
//{
//    id currentViewController = self.topViewController;
////    NSLog(@"HEHEYHEYHEYHEYHEY");
//    if ([currentViewController isKindOfClass:[panelsReaderViewController class]])
//        return YES;
//    
//    return NO;
//}

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
//    NSArray *viewControllers = self.navigationController.viewControllers;
    UIViewController *rootViewController = [self visibleViewController];
    if ([rootViewController isKindOfClass:[panelsReaderViewController class]])
    {
//        NSLog(@"It's a reader");
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else
    {
//        NSLog(@"It's not");
        return UIInterfaceOrientationMaskPortrait;
    }
//    return UIInterfaceOrientationMaskAll;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationBar.titleTextAttributes = @{
                                               NSForegroundColorAttributeName : [UIColor blackColor]
                                               };
    
    self.navigationBar.tintColor = [UIColor orangeColor];
    [self.navigationBar setAutoresizesSubviews:NO];
    [self.navigationBar setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
