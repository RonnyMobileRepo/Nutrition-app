//
//  SettingsTableViewController.h
//  Nomful
//
//  Created by Sean Crowe on 6/4/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SettingsTableViewController : UITableViewController <MFMailComposeViewControllerDelegate>
- (IBAction)closeButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButton;

@end
