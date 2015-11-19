//
//  CoachCardParentViewController.h
//  Nomful-App
//
//  Created by Sean Crowe on 11/18/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoachPageContentViewController.h"

@interface CoachCardParentViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) NSArray *coachUsers;
@property (strong, nonatomic) UIPageViewController *pageViewController;

- (id)initWith:(NSArray *)coachArray_;
@end
