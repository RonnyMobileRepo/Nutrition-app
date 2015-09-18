//
//  AvailableClientsTableViewController.h
//  RealDietitian
//
//  Created by Sean Crowe on 2/20/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ClientCollectionViewController.h"
#import "MessagesViewController.h"
#import "UserAccountViewController.h"

@interface AvailableClientsTableViewController : UITableViewController 
@property (strong, nonatomic) NSMutableArray *availableChatsArray;
- (IBAction)logoutPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutBarButtonItem;
@property (strong, nonatomic) NSMutableArray *avatarsArray;
@property (strong, nonatomic) UIRefreshControl *refreshControl;


@end
