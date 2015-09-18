//
//  initialViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 4/15/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "initialViewController.h"

@interface initialViewController ()

@end

@implementation initialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createPageViewController];
    [self setupPageControl];
}

- (void) createPageViewController
{
    self.contentImages = @[@"straws.jpg",
                      @"fruit.png",
                      @"fitness-background.png",
                      @"profilePlaceholder.png"];
    
    UIPageViewController *pageController = [self.storyboard instantiateViewControllerWithIdentifier: @"homeView"];
    pageController.dataSource = self;
    
    if([self.contentImages count])
    {
        NSArray *startingViewControllers = @[[self itemControllerForIndex: 0]];
        [pageController setViewControllers: startingViewControllers
                                 direction: UIPageViewControllerNavigationDirectionForward
                                  animated: NO
                                completion: nil];
    }
    
    self.pageViewController = pageController;
    [self addChildViewController: self.pageViewController];
    [self.view addSubview: self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController: self];
    
    
    //add button prgramatically so that it stays constant while background can swipe
   
    self.loginButton.backgroundColor = [UIColor yellowColor];
    
    [self.view addSubview:self.loginButton];
    
}


- (void) setupPageControl
{
    [[UIPageControl appearance] setPageIndicatorTintColor: [UIColor grayColor]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor: [UIColor whiteColor]];
    [[UIPageControl appearance] setBackgroundColor: [UIColor darkGrayColor]];
}

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController viewControllerBeforeViewController:(UIViewController *) viewController
{
    NSLog(@"okay this was called...");
    PageItemController *itemController = (PageItemController *) viewController;
    
    if (itemController.itemIndex > 0)
    {
        return [self itemControllerForIndex: itemController.itemIndex-1];
    }
    
    return nil;
}

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController viewControllerAfterViewController:(UIViewController *) viewController
{
    PageItemController *itemController = (PageItemController *) viewController;
    
    if (itemController.itemIndex+1 < [self.contentImages count])
    {
        return [self itemControllerForIndex: itemController.itemIndex+1];
    }
    
    return nil;
}

- (PageItemController *) itemControllerForIndex: (NSUInteger) itemIndex
{
    
        PageItemController *pageItemController = [self.storyboard instantiateViewControllerWithIdentifier: @"profileView"];
        return pageItemController;
    
    
    return nil;
}

#pragma mark Page Indicator

- (NSInteger) presentationCountForPageViewController: (UIPageViewController *) pageViewController
{
    return [self.contentImages count];
}

- (NSInteger) presentationIndexForPageViewController: (UIPageViewController *) pageViewController
{
    return 0;
}
@end
