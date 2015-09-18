//
//  initialViewController.h
//  RealDietitian
//
//  Created by Sean Crowe on 4/15/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageItemController.h"

@interface initialViewController : UIViewController <UIPageViewControllerDataSource>

@property (nonatomic, strong) NSArray *contentImages;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;


@end
