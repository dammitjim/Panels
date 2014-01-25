//
//  panelsNavigationController.m
//  panels
//
//  Created by James A Hill on 08/01/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "panelsNavigationController.h"

@interface panelsNavigationController ()

@end

@implementation panelsNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Panels";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationBar.titleTextAttributes = @{
                                               NSForegroundColorAttributeName : [UIColor blackColor]
                                               };
    
    self.navigationBar.tintColor = [UIColor orangeColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
