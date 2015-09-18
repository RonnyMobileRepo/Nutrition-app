//
//  ProgressViewController.h
//  RealDietitian
//
//  Created by Sean Crowe on 4/18/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <M13ProgressViewPie.h>
#import "ChooseTrainerTableViewController.h"

@interface ProgressViewController : UIViewController
@property (weak, nonatomic) IBOutlet M13ProgressViewPie *pieView;
@property (weak, nonatomic) IBOutlet UILabel *congratsLabel;
@property (weak, nonatomic) IBOutlet UILabel *trainerLabel;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (strong, nonatomic) PFObject *gymObject;
@property (strong, nonatomic) PFObject *GymObjects;

@end
