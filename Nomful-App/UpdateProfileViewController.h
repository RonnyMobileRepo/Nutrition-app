//
//  UpdateProfileViewController.h
//  Nomful
//
//  Created by Sean Crowe on 6/5/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateProfileViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UIImageView *bacgroundIMage;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)resetPasswordPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

@end
