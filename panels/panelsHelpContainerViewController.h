//
//  panelsHelpContainerViewController.h
//  panels
//
//  Created by James A Hill on 07/04/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface panelsHelpContainerViewController : UIViewController <UIPageViewControllerDataSource>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;
@end
