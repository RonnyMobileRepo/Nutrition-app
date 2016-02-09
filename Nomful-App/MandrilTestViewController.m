//
//  MandrilTestViewController.m
//  Nomful-App
//
//  Created by Sean Crowe on 11/16/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "MandrilTestViewController.h"

@interface MandrilTestViewController (){
    
    PFUser *currentUser;
    
}

@end

@implementation MandrilTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    //account with 3306714458 - user: NG5H9p9EzM ch:qA3pTCUFiG
    //firebase with - 9BPlqvNCST
    
    //GO GET THE MEALS FOR S5aTk6Y90v
    //CREATE NEW MEALS WITH USEROBJECT NG5H9p9EzM
    
    
    ////demo -> GxX0VRJsNC
    ////sean -> xnk8YsLZqA
    
    
///go get meals and transfer over to demo account////
    
//    PFQuery * query = [PFUser query];
//    [query whereKey:@"objectId" equalTo:@"xnk8YsLZqA"];
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
//        //
//        PFQuery *query = [[PFQuery alloc] initWithClassName:@"Meals"];
//        [query whereKey:@"userObject" equalTo:object];
//        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//            
//            PFQuery *queries = [PFUser query];
//            [queries whereKey:@"objectId" equalTo:@"GxX0VRJsNC"];
//            [queries getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
//                
//                for (PFObject *meal in objects) {
//                    
//                    PFUser *userobject = object;
//                    
//                    PFObject *newMeal = [[PFObject alloc] initWithClassName:@"Meals"];
//                    newMeal[@"description"] = meal[@"description"];
//                    newMeal[@"hashtagsArrays"] = meal[@"hashtagsArrays"];
//                    newMeal[@"mealPhoto"] = meal[@"mealPhoto"];
//                    newMeal[@"userObject"] = userobject;
//                    [newMeal saveInBackground];
//                }
//            }];
//        }];
//    }];
//    
    
    
    
    
    
    
    
    
    
    
    
    // Do any additional setup after loading the view.
//    
//    PFUser *currentUser = [PFUser currentUser];
//    [currentUser fetch];
//    NSLog(@"current user is: %@", currentUser);
//    
//
    
//    
//    //send first time login email
//    [PFCloud callFunctionInBackground:@"sendFirstTimeLoginEmail"
//                       withParameters:@{@"toEmail" : @"crowesp2@miamioh.edu",
//                                        @"toName" : @"this is my name"}
//                                block:^(NSString *result, NSError *error) {
//                                    NSLog(@"result is %@", result);
//                                
//                                }];
//    
    

//    _coachUsers = @[[PFUser currentUser]];
//
//    // Create page view controller
//    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"coachBioPageViewController"];
//    self.pageViewController.dataSource = self;
//    
//    CoachPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
//    NSArray *viewControllers = @[startingViewController];
//    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
//    
//    // Change the size of page view controller
//    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//    
//    [self addChildViewController:_pageViewController];
//    [self.view addSubview:_pageViewController.view];
//    [self.pageViewController didMoveToParentViewController:self];

}

- (void)getChatroomFromLocal{
    PFQuery *query = [PFQuery queryWithClassName:@"Chatrooms"];
    [query whereKey:@"clientUser" equalTo:currentUser];
    [query fromLocalDatastore];
    [[query getFirstObjectInBackground] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            // Something went wrong.
            return task;
        }
        
        // task.result will be your game score
        NSLog(@"task is: %@", task.result);
        
        return task;
    }];
}
- (void)getChatroomFromNetwork{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Chatrooms"];
    [query whereKey:@"clientUser" equalTo:currentUser];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        //
        
        _chatroomObject = object;
        [_chatroomObject pinInBackground];
        NSLog(@"hey ey: %@", _chatroomObject);
        
    }];
    
    
    
    
    
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
