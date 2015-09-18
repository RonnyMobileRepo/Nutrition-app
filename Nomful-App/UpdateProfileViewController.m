//
//  UpdateProfileViewController.m
//  Nomful
//
//  Created by Sean Crowe on 6/5/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "UpdateProfileViewController.h"

@interface UpdateProfileViewController ()

@end

@implementation UpdateProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            //NSForegroundColorAttributeName: [UIColor greenColor],
                                                            NSFontAttributeName: [UIFont fontWithName:kFontFamilyName size:20.0f]                                                            }];
    
    //blur background
    // create effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    [_bacgroundIMage addSubview:effectView];
    
    //save button design
    _saveButton.layer.cornerRadius = 4.0;
    
    //get current user object
    _currentUser = [PFUser currentUser];
    
    PFFile *userImageFile = _currentUser[@"photo"];
    
    if(userImageFile){ //if there is data for the photo...go to parse and get the image
        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                NSLog(@"getting file");
                UIImage *image = [UIImage imageWithData:imageData];
                [_bacgroundIMage setImage:image];
            }
        }];
    }

    //get and display profile info from parse
    _firstName.text = _currentUser[@"firstName"];
    _lastName.text = _currentUser[@"lastName"];
    _email.text = _currentUser[@"email"];

}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)resetPasswordPressed:(id)sender {
    
    //set password reset
    [PFUser requestPasswordResetForEmailInBackground:_currentUser[@"email"]];
    
    //get the email from the field above
    NSString *email = _email.text;
    NSString *message =  [[NSString alloc] initWithFormat:@"We sent an email to %@ to reset your password", email];

    //show alert view
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Reset" message:message delegate:self cancelButtonTitle:@"Woot!" otherButtonTitles: nil];
    [alert show];
    
}

- (IBAction)saveButtonPressed:(id)sender {
    
    [_activityIndicator startAnimating];
    _currentUser[@"firstName"] = _firstName.text;
    _currentUser[@"lastName"] = _lastName.text;
    [_currentUser setEmail:_email.text];
    
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            //succesfully saved info
            //show alert view
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info Saved" message:@"Your profile information has been updated." delegate:self cancelButtonTitle:@"Woot!" otherButtonTitles: nil];
            [alert show];
            
        }else{
            //show alert view
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Email address provided is already in use" delegate:self cancelButtonTitle:@"Try Again!" otherButtonTitles: nil];
            [alert show];
        }
    
    }];
     
    
    [_activityIndicator stopAnimating];
    
    [_email resignFirstResponder];
    [_lastName resignFirstResponder];
    [_firstName resignFirstResponder];

    
}


@end
