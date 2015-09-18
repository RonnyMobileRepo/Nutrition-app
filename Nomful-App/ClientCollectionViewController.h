//
//  ClientCollectionViewController.h
//  RealDietitian
//
//  Created by Sean Crowe on 4/15/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "PFQueryCollectionViewController.h"
#import "ClientMealsCollectionViewCell.h"
#import "imageDetailViewController.h"
#import "MessagesViewController.h"

@interface ClientCollectionViewController : PFQueryCollectionViewController

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) PFUser *clientUser;


@property (strong, nonatomic) PFObject *chatroomObject;


@end
