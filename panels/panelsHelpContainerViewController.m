//
//  panelsHelpContainerViewController.m
//  panels
//
//  Most of this class is based on code in a tutorial found here: http://www.appcoda.com/uipageviewcontroller-storyboard-tutorial/
//  Created by James A Hill on 07/04/2014.
//  Copyright (c) 2014 Jcodr. All rights reserved.
//

#import "panelsHelpContainerViewController.h"
#import "panelsHelpContentViewController.h"
#import "SWRevealViewController.h"
#import <UIKit/UIKit.h>
@interface panelsHelpContainerViewController () <SWRevealViewControllerDelegate>
@property (nonatomic) BOOL interactable;
@property (strong, nonatomic) UITapGestureRecognizer *cancelSidebar;
@end

@implementation panelsHelpContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // SideBar config
    self.interactable = YES;
    //    NSLog(@"%lu",(unsigned long)[[self.shelf getWholeShelf] count]);
    self.revealViewController.delegate = self;
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    self.revealViewController.rearViewRevealWidth = 250;
    self.cancelSidebar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [self.view addGestureRecognizer:self.cancelSidebar];
    
    // Bar Buttons
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"row.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openMenu: ) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 28, 28)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    // Do any additional setup after loading the view.
    _pageTitles = @[@"Add comics using iTunes file sharing", @"Select move to add to the container", @"Touch your stash to release them", @"Deleted items are moved to the trash"];
    _pageImages = @[@"slide1.png", @"slide2.png", @"slide3.png", @"slide4.png"];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpViewController"];
    self.pageViewController.dataSource = self;
    
    panelsHelpContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 10);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((panelsHelpContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((panelsHelpContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (panelsHelpContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    panelsHelpContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"HelpContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
        // self.view.userInteractionEnabled = YES;
        self.interactable = YES;
    } else {
        // self.view.userInteractionEnabled = NO;
        self.interactable = NO;
        self.cancelSidebar.enabled = YES;
    }
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
        // self.view.userInteractionEnabled = YES;
        self.interactable = YES;
    } else {
        // self.view.userInteractionEnabled = NO;
        self.interactable = NO;
        self.cancelSidebar.enabled = YES;
    }
}

- (void)handleTapFrom: (UITapGestureRecognizer *)sender
{
    
    // If the menu is not active
    if(self.interactable) {
    } else {
        
        // If menu is active any tap outside the menu will cancel the menu
        [self.revealViewController revealToggle:self.view];
        
    }
}

- (void)openMenu:(id)sender
{
    [self.revealViewController revealToggle:self.view];
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
