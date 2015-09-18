//
//  ManageSubscriptionViewController.h
//  Nomful
//
//  Created by Sean Crowe on 7/6/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface ManageSubscriptionViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *cancelMembershipButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (IBAction)cancelMembershipButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *daysLeftLabel;

@end
