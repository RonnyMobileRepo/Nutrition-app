//
//  MandrilTestViewController.h
//  Nomful-App
//
//  Created by Sean Crowe on 11/16/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoachPageContentViewController.h"

@interface MandrilTestViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *coachUsers;

@end
