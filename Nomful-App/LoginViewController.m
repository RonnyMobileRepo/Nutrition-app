//
//  LoginViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 2/19/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "SlideAnimatedTransitioning.h"

@interface LoginViewController ()

@property UIScreenEdgePanGestureRecognizer *edgePanGestureRecognizer;
@property UIPercentDrivenInteractiveTransition *percentDrivenInteractiveTransition;


@end

CGFloat const kMarginForTextField= 60.0;

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stickyButton];
    
    self.emailField.delegate = self;
    [self.emailField becomeFirstResponder];
    
    self.activityIndicator.hidden = YES;
    [self.activityIndicator hidesWhenStopped];
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMarginForTextField, 55)];
    [self.emailField setLeftViewMode:UITextFieldViewModeAlways];
    [self.emailField setLeftView:spacerView];

    UIView *spacerView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMarginForTextField, 55)];
    [self.passwordField setLeftViewMode:UITextFieldViewModeAlways];
    [self.passwordField setLeftView:spacerView2];


}


- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Navigation


- (IBAction)loginButtonPressed:(id)sender {
    
    
    //Login pressed
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
        
        if(!error){
            
            //check to see if there is a user associated with the device for Push Notifications
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            //if(!currentInstallation[@"user"]){
                //no user associated so make it!
                currentInstallation[@"user"] = user;
                [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"You just saved the client user on the installation in parse");
                }];
            //}
            
            //check what role the user logging in is
            NSString *userRole =  user[@"role"];
            
            //if the user is a client and has logged in before, then go to main page
            if([userRole isEqualToString:@"Client"]){
                
                //check if first time loggin in
                NSNumber *isVerifiedNum = user[@"isVerified"];
                bool isVerified = [isVerifiedNum boolValue];
                
                if(!isVerified){
                    //user has not logged in before
                    //let's verify their phone number
                    [self performSegueWithIdentifier:@"usersFirstTimeLogin" sender:self];
                }else{
                    //user has logged in before on the app
                    //send them away
                    
                    if([self checkIfMembershipActive]){
                        //membership is INACTIVE...don't go anywhere
                        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Looks like you're no longer a paying member. Please email support@nomful.com to reactiviate your account" delegate:self cancelButtonTitle:@"Got it!" otherButtonTitles: nil];
                        [view show];
                    }else{
                        [self performSegueWithIdentifier:@"loginSuccessfulSegue" sender:self];

                    }
                    
                }
  
            }else if([userRole isEqualToString:@"RD"]){
                NSLog(@"User is an RD");
                [self performSegueWithIdentifier:@"loginToLiz" sender:self];
                
            }else if([userRole isEqualToString:@"PT"]){
                NSLog(@"Login VC: User is a PT!");
                [self performSegueWithIdentifier:@"loginToLiz" sender:self];
                
            }else{
                NSLog(@"User has no credential");
            }
        }//end if(error)
        else{
            NSLog(@"Login Attempt failed");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Invalid credentials! Please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alert show];
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
        }
    }]; //end loginWithUSerinBackground
}

- (IBAction)textFieldDidBeginEditing:(UITextField *)textField{
    UIImage *image = [[UIImage alloc] init];
    
    if (textField == self.emailField){
        //name
        image = [UIImage imageNamed:@"email-selected"];
        self.emailImageView.image = image;
    }else if(textField == self.passwordField){
        //email
        image = [UIImage imageNamed:@"password-selected"];
        [self.passwordImageView setImage:image];
    }
}

-(IBAction)textFieldDidEndEditing:(UITextField *)textField{
    UIImage *image = [[UIImage alloc] init];
    
    if (textField == self.emailField && ([self.emailField.text isEqualToString:@""])){
        //name
        image = [UIImage imageNamed:@"email"];
        self.emailImageView.image = image;
    }else if(textField == self.passwordField && ([self.passwordField.text isEqualToString:@""])){
        //email
        image = [UIImage imageNamed:@"password"];
        [self.passwordImageView setImage:image];
    }
}

-(void)stickyButton{
    
    //listen for keyboard events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    //view is the thing we want to move around based on keyboard showing or not showing
    NSDictionary *views = @{@"view": self.loginButton,
                            @"indicator": self.activityIndicator,
                            @"top": self.topLayoutGuide};
    
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[top][view]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[top][indicator]" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-230.0-[indicator]" options:0 metrics:nil views:views]];
    
    
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.loginButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    self.bottomActivityConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    
    [self.view addConstraint:self.bottomConstraint];
    [self.view addConstraint:self.bottomActivityConstraint];
    
}

-(void)keyboardDidShow:(NSNotification *)sender
{
    //https://gist.github.com/dlo/8572874
    
    CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
    
    self.bottomConstraint.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame);
    self.bottomActivityConstraint.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame) - 17.5; // (height of button(55) + 2) - (height of indicator + 2)
    
    //this re-layouts our view
    [self.view layoutIfNeeded];
}

- (void)keyboardWillHide:(NSNotification *)sender {
    self.bottomConstraint.constant = 0;
    self.bottomActivityConstraint.constant = 0;
    [self.view layoutIfNeeded];
}


-(bool)checkIfMembershipActive{
    PFUser *currentUser = [PFUser currentUser];
    [currentUser fetch];
    
    if([currentUser[@"role"] isEqualToString:@"Client"]){
        //user is a client
        //let's check to see if their membership expired
        NSDate *startDate = currentUser[@"membershipStartDate"];
        NSDate *today = [NSDate date];
        NSInteger daysLeft = (30 - [self daysBetweenDate:startDate andDate:today]);
        
        if(daysLeft <= 0){
            NSLog(@"user logged out...membership canceled");
            [PFUser logOut];
            //replace and push rootview manually
            return true;
        }
    }
    return false;
}

- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}



@end
