//
//  PageViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 4/30/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "PageViewController.h"


@interface PageViewController ()

@end


@implementation PageViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-nav.png"]];
    self.navigationItem.titleView = imageView;

    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(checkforBadgeValue)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkforBadgeValue) name:@"updateBarButtonBadge" object:nil];
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    
    //alloc
    self.homeVCNav = [[UIViewController alloc] init];
    self.profileVC = [[UIViewController alloc] init];
    self.chatVC = [[UIViewController alloc] init];

    //set to view controller
    self.homeVCNav = [self.storyboard instantiateViewControllerWithIdentifier:@"homeViewNav"];
    self.profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"profileView"];
    self.chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"chatView"];

    
    NSMutableArray *homeVCArray = [[NSMutableArray alloc] initWithObjects:self.homeVCNav, nil];
    [self setViewControllers:homeVCArray direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
  
    
    self.brandColor = [UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0];
    
    
    //set left iten to account button
    self.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile"] style:UIBarButtonItemStylePlain target:self action:@selector(goLeft:)];
    self.navigationItem.leftBarButtonItem = self.leftBarButtonItem;
    self.navigationItem.leftBarButtonItem.tintColor = self.brandColor;
    
    //set right item to chat button
    self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat"] style:UIBarButtonItemStylePlain target:self action:@selector(goRight:)];
    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0];
    
    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];

}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController{
    
    if(viewController == self.homeVCNav){
        return self.profileVC;
    }else if(viewController == self.chatVC){
        return self.homeVCNav;
    }else{
        return nil;
    }
    
  
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerAfterViewController:(UIViewController *)viewController{
    
    if(viewController == self.profileVC){
        return self.homeVCNav;
    }else if(viewController == self.homeVCNav){
        return self.chatVC;
    }else{
        return nil;
    }
    
    
}



- (void)goToPreviousVC{
    
    UIViewController *prevVC = [[UIViewController alloc] init];
    UIViewController *currentView = [[UIViewController alloc] init];
    currentView = [self.viewControllers objectAtIndex:0];
    
    prevVC = [self pageViewController:self viewControllerBeforeViewController:currentView];

    NSMutableArray  *prevVCArray = [[NSMutableArray alloc] init];
    [prevVCArray addObject:prevVC];
    
    [self setViewControllers:prevVCArray direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    
    if(currentView == self.chatVC){
        [self homeNavBar];
    }else if(currentView == self.homeVCNav){
        [self accountNavBar];
    }
}

- (void)goToNextVC{
    UIViewController *prevVC = [[UIViewController alloc] init];
    UIViewController *currentView = [[UIViewController alloc] init];
    currentView = [self.viewControllers objectAtIndex:0];
    
    prevVC = [self pageViewController:self viewControllerAfterViewController:currentView];
    
    NSMutableArray  *prevVCArray = [[NSMutableArray alloc] init];
    [prevVCArray addObject:prevVC];
    
    [self setViewControllers:prevVCArray direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    if(currentView == self.homeVCNav){
        [self chatNavBar];
    }else if(currentView == self.profileVC){
        [self homeNavBar];
    }
    
}

- (IBAction)goRight:(id)sender {
    [self goToNextVC];
}

- (IBAction)goLeft:(id)sender {
    
    [self goToPreviousVC];
}

- (void)chatNavBar{
    
    //fade out nomful logo
    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         //set the title to clear
                         self.navigationItem.titleView.alpha = 0.0;
                         
                         //nav bar title view
                         UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chatFilled"]];
                         self.navigationItem.titleView = imageView;
                         self.navigationItem.titleView.alpha = 0.0;
                     }];
    
    //fad in filled chat icon
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.navigationItem.titleView.alpha = 1.0;
                     }];
    
    
    //left nomberry
    UIImage *nomImage = [[UIImage imageNamed:@"nomberry"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *nomBar = [[UIBarButtonItem alloc] initWithImage:nomImage style:UIBarButtonItemStylePlain target:self action:@selector(goLeft:)];
    self.navigationItem.leftBarButtonItem = nomBar;
    
    //right nil
    self.navigationItem.rightBarButtonItem = nil;
    
    //reset badge
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    
}


- (void)homeNavBar{
    
    //fade out middle
    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         //set the title to clear
                         self.navigationItem.titleView.alpha = 0.0;
                         
                         //nav bar title view
                         UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-nav.png"]];
                         self.navigationItem.titleView = imageView;
                         self.navigationItem.titleView.alpha = 0.0;
                     }];
    
    //fad in filled chat icon
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.navigationItem.titleView.alpha = 1.0;
                     }];
    
    //set left iten to account button
    self.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile"] style:UIBarButtonItemStylePlain target:self action:@selector(goLeft:)];
    self.navigationItem.leftBarButtonItem = self.leftBarButtonItem;
    self.navigationItem.leftBarButtonItem.tintColor = self.brandColor;
    
    //set right item to chat button
    self.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat"] style:UIBarButtonItemStylePlain target:self action:@selector(goRight:)];
    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0];
    
    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    [self checkforBadgeValue];
    
}

- (void)accountNavBar{
    
    
    
    //right bar button itme
    UIImage *nomImage = [[UIImage imageNamed:@"nomberry"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *nomBar = [[UIBarButtonItem alloc] initWithImage:nomImage style:UIBarButtonItemStylePlain target:self action:@selector(goRight:)];
    self.navigationItem.rightBarButtonItem = nomBar;
    self.navigationItem.leftBarButtonItem =nil;
    
    //fade out middle
    [UIView animateWithDuration:0.25
                     animations:^{
                         
                         //set the title to clear
                         self.navigationItem.titleView.alpha = 0.0;
                         
                         //nav bar title view
                         //nav bar title view
                         UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"profileFilled"]];
                         self.navigationItem.titleView = imageView;
                         self.navigationItem.titleView.alpha = 0.0;
                     }];
    
    //fad in filled chat icon
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.navigationItem.titleView.alpha = 1.0;
                     }];

    
}
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers{
    NSLog(@"called %@", pendingViewControllers[0]);
    
    //if the view we're about to go to is the chat...
    if(pendingViewControllers[0] == self.chatVC){
        NSLog(@"chat view is comin dude");
        
    }
    
    UIViewController *currentView = [[UIViewController alloc] init];
    currentView = [self.viewControllers objectAtIndex:0];
    
    if (pendingViewControllers[0] == self.homeVCNav && currentView == self.chatVC) {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        if (currentInstallation.badge != 0) {
            currentInstallation.badge = 0;
            [currentInstallation saveEventually];
        }
        
    }
}


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed{
    //we can load new nav items now that it is all loaded
    
    UIViewController *currentView = [[UIViewController alloc] init];
    currentView = [self.viewControllers objectAtIndex:0];
    
    if(currentView == self.chatVC){
        
        [self chatNavBar];

    }else if(currentView == self.homeVCNav){
        
        [self homeNavBar];
        
    }else if(currentView == self.profileVC){
        
        [self accountNavBar];
        
    }
    
    
    
//    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
//                                                    initWithTarget:self
//                                                    action:@selector(doneEditing)] ;
//    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionDown];
//    [[self view] addGestureRecognizer:oneFingerSwipeLeft];
//    
    
   }

- (void) checkforBadgeValue{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        
        self.navigationItem.rightBarButtonItem.badgeValue = @"1";
        
    }else{
        self.navigationItem.rightBarButtonItem.badgeValue = @"0";
        
    }
    
}

@end
