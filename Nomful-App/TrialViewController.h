//
//  TrialViewController.h
//  Nomful
//
//  Created by Sean Crowe on 8/27/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrialViewController : UIViewController

@property (strong, nonatomic) PFUser *coachUser;
@property (strong, nonatomic) PFUser *trainerUser;
@property (strong, nonatomic) PFObject *gymObject;
@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *buttonString;
@property (strong, nonatomic) NSString *stepOneString;
@property bool isTrial;

@property (weak, nonatomic) IBOutlet UILabel *stepOneLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *activateButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *termsButton;
- (IBAction)termsButtonPressed:(id)sender;

@end
