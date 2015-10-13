//
//  ClientListViewController.h
//  Nomful
//
//  Created by Sean Crowe on 6/19/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "PFQueryTableViewController.h"
#import "MessagesViewController.h"
#import "ClientCollectionViewController.h"
#import "UserAccountViewController.h"
#import <UIButton+Badge.h>

@interface ClientListViewController : PFQueryTableViewController <MessagesViewControllerDelegate>
- (IBAction)chatButtonPressed:(UIButton*)button;
- (IBAction)mealsButtonPressed:(UIButton*)button;
- (IBAction)accountButtonPressed:(UIButton*)button;

@property (strong, nonatomic) PFObject *chatroomObject;

@end
