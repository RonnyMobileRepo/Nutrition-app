//
//  phoneLoginViewController.m
//  Nomful
//
//  Created by Sean Crowe on 8/31/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "phoneLoginViewController.h"

@interface phoneLoginViewController ()

@end

@implementation phoneLoginViewController

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    //text field design
    _phoneTextField.layer.cornerRadius = 4.0;
    
    //This gets the text in the textfields to move to the right 20px. Gives room for icons
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 50)];
    [_phoneTextField setLeftViewMode:UITextFieldViewModeAlways];
    [_phoneTextField setLeftView:spacerView];
    _phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    _phoneTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
    _phoneTextField.delegate = self;
    
    //This gets the text in the textfields to move to the right 20px. Gives room for icons
    UIView *spacerView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 50)];
    [_enterCodeTextField setLeftViewMode:UITextFieldViewModeAlways];
    [_enterCodeTextField setLeftView:spacerView1];
    _enterCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
    _enterCodeTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
    
    //button format
    _sendCodebutton.layer.cornerRadius = 4.0;
    _enterCodeTextField.layer.cornerRadius = 4.0;
    _loginButton.layer.cornerRadius = 4.0;
    

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_phoneTextField becomeFirstResponder];

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)sendCode:(id)sender {
    NSLog(@"send code button pressed");
    
    //show didn't receive a cod button
    _noCodeButton.hidden = false;
    
    //this sends a random code to my number
    [PFCloud callFunctionInBackground:@"sendCodeForLogin"
                       withParameters:@{@"phoneNumber": self.phoneTextField.text,
                                        @"language" : @"en"
                                        }
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        NSLog(@"RESULT IS: %@", result);
                                        
                                        //hide ui
                                        _phoneTextField.hidden = true;
                                        _sendCodebutton.hidden = true;
                                        [_phoneTextField resignFirstResponder];
                                        
                                        _enterCodeTextField.hidden = false;
                                        _loginButton.hidden = false;
                                        [_enterCodeTextField becomeFirstResponder];
                                        _titleLabel.text = @"Enter the code we just sent you!";
                                        
                                     
                                    }
                                    else{
                                        NSLog(@"ERROR: %@", error);
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Number" message:@"Looks like you aren't a member yet! Please go back and create an account first. If you think this is a mistake, please contact us." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                                        [alert show];
                                        
                                        
                                    }
                                }];
    
    

}
- (IBAction)login:(id)sender {
    NSLog(@"code is: %@", _enterCodeTextField.text);
    NSLog(@"phone is: %@", _phoneTextField.text);

    
    [PFCloud callFunctionInBackground:@"logIn"
                       withParameters:@{@"phoneNumber": self.phoneTextField.text,
                                        @"codeEntry" : self.enterCodeTextField.text
                                        }
                                block:^(NSString *token, NSError *error) {
                                    if (!error) {
                                        
                                        //no error...code is valid
                                        //the result from cloud code is a session token that we can now use to set the current user
                                        [PFUser becomeInBackground:token block:^(PFUser *user, NSError *error) {
                                            if (error) {
                                                // The token could not be validated.
                                                NSLog(@"Login Not Successful!");
                                                
                                            } else {
                                                // The current user is now set to user.
                                                // no longer anonymous user!
                                                NSLog(@"Login Successful! %@", token);
                                                
                                                
                                                //check for role first
                                                //if coach/trainer
                                                if ([user[@"role"] isEqualToString:@"RD"] || [user[@"role"] isEqualToString:@"PT"]) {
                                                    //then send to their view
                                                    [self performSegueWithIdentifier:@"loginToCoach" sender:self];
                                                }
                                                else if([user[@"role"] isEqualToString:@"Client"]){
                                                    //if user is a client
                                                    //check if they've activated a trial or have paid
                                                    if(user[@"planType"]){
                                                        //we are here b/c there is a value for planType...the only way this can happen is if the user
                                                        //has activated a trial or paid for a membership
                                                        [self performSegueWithIdentifier:@"loginToMainSegue" sender:self];

                                                    }else{
                                                        //they have no plan type...get them ousta here!
                                                        [PFUser logOut];
                                                        
                                                        //show alert view
                                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Looks like you aren't a member yet. Please go back and select GET STARTED. If you think this is an error, please contact us." delegate:self cancelButtonTitle:@"Sounds Good!" otherButtonTitles: nil];
                                                        [alert show];
                                                        
                                                    }
                                                }//end else if client role
                                                else if([user[@"role"] isEqualToString:@"admin"]){
                                                    NSLog(@"you are admin");
                                                    [self performSegueWithIdentifier:@"loginToCoach" sender:self];
                                                }
                                            }//end else
                                        }];
                                        
                                    }//end if(error)
                                    else{
                                        NSLog(@"ERROR: %@", error);
                                        //login failed
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"The code you entered was incorrect, please double check the code we texted you, or send another code." delegate:self cancelButtonTitle:@"Sounds Good!" otherButtonTitles: nil];
                                        [alert show];
                                        
                                    }
                                }];
}

#pragma mark - Phone number formatting


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString* totalString = [NSString stringWithFormat:@"%@%@",textField.text,string];
    
    // if it's the phone number textfield format it.
    if(textField.tag==102 ) {
        if (range.length == 1) {
            // Delete button was hit.. so tell the method to delete the last char.
            textField.text = [self formatPhoneNumber:totalString deleteLastChar:YES];
        } else {
            textField.text = [self formatPhoneNumber:totalString deleteLastChar:NO ];
        }
        return false;
    }
    
    return YES;
}

-(NSString*) formatPhoneNumber:(NSString*) simpleNumber deleteLastChar:(BOOL)deleteLastChar {
    if(simpleNumber.length==0) return @"";
    // use regex to remove non-digits(including spaces) so we are left with just the numbers
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\\s-\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    simpleNumber = [regex stringByReplacingMatchesInString:simpleNumber options:0 range:NSMakeRange(0, [simpleNumber length]) withTemplate:@""];
    
    // check if the number is to long
    if(simpleNumber.length>10) {
        // remove last extra chars.
        simpleNumber = [simpleNumber substringToIndex:10];
    }
    
    if(deleteLastChar) {
        // should we delete the last digit?
        simpleNumber = [simpleNumber substringToIndex:[simpleNumber length] - 1];
    }
    
    // 123 456 7890
    // format the number.. if it's less then 7 digits.. then use this regex.
    if(simpleNumber.length<7)
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d+)"
                                                               withString:@"($1) $2"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    
    else   // else do this one..
        simpleNumber = [simpleNumber stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d+)"
                                                               withString:@"($1) $2-$3"
                                                                  options:NSRegularExpressionSearch
                                                                    range:NSMakeRange(0, [simpleNumber length])];
    return simpleNumber;
}
- (IBAction)noCodeButtonPressed:(id)sender {
    NSLog(@"no code button pressed");
    
    [self sendCode:sender];
    
}
@end
