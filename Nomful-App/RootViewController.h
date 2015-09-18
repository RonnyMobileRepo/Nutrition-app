//
//  RootViewController.h
//  Nomful
//
//  Created by Sean Crowe on 7/22/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "pagecontentViewController.h"

@interface RootViewController : UIViewController <UIPageViewControllerDataSource>

@property (nonatomic,strong) UIPageViewController *PageViewController;
@property (nonatomic,strong) NSArray *arrPageTitles;
@property (nonatomic,strong) NSArray *arrPageImages;
- (pagecontentViewController *)viewControllerAtIndex:(NSUInteger)index;

@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;
- (IBAction)memberLoginButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *memberLogin;
- (IBAction)buttonPressed:(id)sender;

@end
