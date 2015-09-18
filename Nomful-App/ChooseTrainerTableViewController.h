//
//  ChooseTrainerTableViewController.h
//  RealDietitian
//
//  Created by Sean Crowe on 3/24/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseTrainerTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *trainersArray;
@property (strong, nonatomic) NSMutableArray *trainerAvatarsArray;
@property (strong, nonatomic) PFUser *ptUser;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) PFUser *rdUser;

@property (strong, nonatomic) PFObject *gymObject;

@end
