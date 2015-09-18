//
//  RootViewController.m
//  Nomful
//
//  Created by Sean Crowe on 7/22/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "RootViewController.h"
#import "SignUpConversationViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //set all content for all of the screens we're swiping through
    //the number of items in this array determines how many views to show
    _arrPageTitles = @[@"",@"Fast and simple meal sharing. Say bye to calorie counting.",@"Daily accountability, personalized support",@"Team up with the country's best habit-based nutrition coaches"];
    _arrPageImages =@[@"iphone_6.png", @"marketingscreen-meal.png",@"iphoneCall.png",@"marketingscreen-coach.png"];
    
    // Create page view controller from storyboard id
    self.PageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.PageViewController.dataSource = self;
    
    //set the view we want to start on
    pagecontentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.PageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    //this is for the dots at the bottom i think
    self.PageViewController.view.frame = CGRectMake(0, -20 , self.view.frame.size.width, self.view.frame.size.height - 60);
    [self addChildViewController:_PageViewController];
    [self.view addSubview:_PageViewController.view];
    [self.PageViewController didMoveToParentViewController:self];
    
    //clear navigation on the marketing/education screens
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    _memberLogin.layer.cornerRadius = 4.0;

}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    //set index
    NSUInteger index = ((pagecontentViewController *) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((pagecontentViewController *) viewController).pageIndex;
    if (index == NSNotFound)
    {
        return nil;
    }
    index++;
    if (index == [self.arrPageTitles count])
    {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (pagecontentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.arrPageTitles count] == 0) || (index >= [self.arrPageTitles count])) {
        return nil;
    }
    // Create a new view controller and pass suitable data.
    pagecontentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imgFile = self.arrPageImages[index];
    pageContentViewController.txtTitle = self.arrPageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.arrPageTitles count];
}
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (IBAction)memberLoginButtonPressed:(id)sender {
} 
- (BOOL) prefersStatusBarHidden
{
    return YES;
}
- (IBAction)buttonPressed:(id)sender {
    NSLog(@"button presed");
    
    }
@end
