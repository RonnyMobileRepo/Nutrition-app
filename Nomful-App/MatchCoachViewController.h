//
//  MatchCoachViewController.h
//  Nomful
//
//  Created by Sean Crowe on 7/22/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignUpConversationViewController.h"

@interface MatchCoachViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *coachFullNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *specialitesTextView;
@property (weak, nonatomic) IBOutlet UITextView *bioTextView;
@property (weak, nonatomic) IBOutlet PFImageView *coachProfileImageView;

@property (strong, nonatomic) PFUser *coachUser;
@end
