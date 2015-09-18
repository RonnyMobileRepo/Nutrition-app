//
//  PageViewController.h
//  RealDietitian
//
//  Created by Sean Crowe on 4/30/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIBarButtonItem+Badge.h>


@class PageViewController;

@protocol PageViewControllerDelegate <NSObject>

//- (void)didDismissJSQDemoViewController:(MessagesViewController *)vc;

@end

@interface PageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (strong, nonatomic) UIViewController *homeVCNav;
@property (strong, nonatomic) UIViewController *profileVC;
@property (strong, nonatomic) UIViewController *chatVC;
@property (strong, nonatomic) UIViewController *settingsVC;

@property (strong, nonatomic) UIColor *brandColor;
- (void)goToPreviousVC;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;

- (IBAction)goRight:(id)sender;
- (IBAction)goLeft:(id)sender;

@end
