//
//  MandrilTestViewController.m
//  Nomful-App
//
//  Created by Sean Crowe on 11/16/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "MandrilTestViewController.h"

@interface MandrilTestViewController ()

@end

@implementation MandrilTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    
//    PFUser *currentUser = [PFUser currentUser];
//    
//    //send first time login email
//    [PFCloud callFunctionInBackground:@"sendFirstTimeLoginEmail"
//                       withParameters:@{@"toEmail": currentUser.email,
//                                        @"toName": currentUser[@"firstName"]
//                                        }
//                                block:^(NSString *result, NSError *error) {
//                                    if (!error) {
//                                        NSLog(@"RESULT IS: %@", result);
//                                    }
//                                    else{
//                                        NSLog(@"ERROR: %@", error);
//                                    }
//                                }];
    
    

    _coachUsers = @[[PFUser currentUser]];

    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"coachBioPageViewController"];
    self.pageViewController.dataSource = self;
    
    CoachPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((CoachPageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((CoachPageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.coachUsers count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (CoachPageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.coachUsers count] == 0) || (index >= [self.coachUsers count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    CoachPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"coachBioContent"];
    pageContentViewController.coachUserObject = self.coachUsers[index]; //LET'S SET A COACH USER HERE
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.coachUsers count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
