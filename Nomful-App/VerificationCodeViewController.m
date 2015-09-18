//
//  VerificationCodeViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 3/2/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "VerificationCodeViewController.h"

@interface VerificationCodeViewController ()

@end

CGFloat const kMarginForTextFieldzz = 60.0;

@implementation VerificationCodeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //set up the constraints for the submit button
    [self stickyButton];
    
    //show the keyboard on load
    self.phoneNumberTextField.delegate = self;
    [self.phoneNumberTextField becomeFirstResponder];
    
    //add a margin in the textboxes
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMarginForTextFieldzz, 55)];
    [self.phoneNumberTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.phoneNumberTextField setLeftView:spacerView];
    
    UIView *spacerView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMarginForTextFieldzz, 55)];
    [self.verifyCodeTextField setLeftViewMode:UITextFieldViewModeAlways];
    [self.verifyCodeTextField setLeftView:spacerView2];
    
    
}

-(void)stickyButton{
    
    //listen for keyboard events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //view is the thing we want to move around based on keyboard showing or not showing
    NSDictionary *views = @{@"view": self.verifyButton,
                            @"indicator": self.activityIndicator,
                            @"top": self.topLayoutGuide,
                            @"icon": self.phoneIconImageView};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[top][view]" options:0 metrics:nil views:views]];
    //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[top][indicator]" options:0 metrics:nil views:views]];
    //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-230.0-[indicator]" options:0 metrics:nil views:views]];

    
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.verifyButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
//    self.bottomActivityConstraint = [NSLayoutConstraint constraintWithItem:self.activityIndicator attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0];

    
    [self.view addConstraint:self.bottomConstraint];
    //[self.view addConstraint:self.bottomActivityConstraint];
    
}

- (void)checkAccountStatus:(NSString *)phone{
    
  
    NSString *cleanedPhone = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];

    
    //user has entered their phone and we are checking if they are paying members somewhere
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"GymMembers"];
    [query whereKey:@"userPhone" equalTo:cleanedPhone];
    
    //query for GymMember Object
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if(!error){
            if(object){
                //there was a result
                //member phone number was found! This means they are a paying member
                //we can continue to verify their phone with AUthy
                
                if(!object[@"GymObjects"]){
                    NSLog(@"user has no gym and is random");
                    self.randomUserNoGym = true;
                }

                
                [self sendAuthyCode:phone];
                
                //save the user in the GymMember table
                PFUser *currentUser = [PFUser currentUser];
                object[@"clientObject"] = currentUser;
                [object saveInBackground];
                
                [self subscribeToMailChimp:currentUser[@"email"] firstName:currentUser[@"firstName"] lastName:currentUser[@"lastName"] isVerified:true];
                
                //if the Paid User has no gym object associated with them. Flag that they are RANDOM
                //This way we can send them directly to the home screen and skip PT stuff
            }
        }
        else{
            NSLog(@"Error found/no object");
            //if the user is NOT a paying member...this is where they end up
            //do someting here to let the user know that they are not a payign user
            
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Looks like you aren't a member yet! Please check your email to finsh registration. :)" delegate:self cancelButtonTitle:@"Got It" otherButtonTitles: nil];
            [alert show];
            
            [self.activityIndicator stopAnimating];
            
            //save phone to parse
            PFUser *currentUser = [PFUser currentUser];
            currentUser[@"phoneNumber"] = phone;
            [currentUser saveEventually];
            
            //put user in notVerified email list
            [self subscribeToMailChimp:currentUser[@"email"] firstName:currentUser[@"firstName"] lastName:currentUser[@"lastName"] isVerified:false];

        }
    }];
}


- (void)sendAuthyCode:(NSString *)phone{
    //user has been verified as paying
    //then we can now send the authy code for verification
    
    //save phone to parse
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"phoneNumber"] = phone;
    [currentUser saveEventually];
    
    
    if(self.verifyCodeTextField.hidden == YES){
        //if the field is hidden, then we know it's the first press
        NSLog(@"This is the first time you presed the verify button!");
        
        if([self requestVerification:phone]){
            
            [self.activityIndicator stopAnimating];
            
            //verificaiton code requested and sent with no errors
            UIAlertView *verifySentAlert = [[UIAlertView alloc] initWithTitle:@"Yay!" message:@"Verification code is on the way! Please enter it below to complete registration." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [verifySentAlert show];
            
            //show the verify code text field. Show number pad
            self.verifyCodeTextField.hidden = NO;
            [self.verifyCodeTextField becomeFirstResponder];
            self.didntReceiveCodeButton.hidden = NO;
            self.seperatorView.hidden = NO;
            self.codeIconImageView.hidden = NO;
            
            UIImage *image = [[UIImage alloc] init];
            image = [UIImage imageNamed:@"phone-selected"];
            self.phoneIconImageView.image = image;
            
            //change button label
            [self.verifyButton setTitle:@"Verify" forState:UIControlStateNormal];
            
        }//end request verificaiton if
        else{
            //authy returned false
            [self.activityIndicator stopAnimating];
        }
    }//end if textfield.hidden
    else{
        //this means that the user entered a phone number and is ready to auth
        
        NSLog(@"this is the second time you pressed the button");
        UIImage *image = [[UIImage alloc] init];
        image = [UIImage imageNamed:@"key-selected"];
        [self.codeIconImageView setImage:image];
        
        NSString *code = [self.verifyCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSString *cleanedPhone = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
        
        if([self verifyCode:code phone:cleanedPhone]){
            [self.activityIndicator stopAnimating];
            
            
            
            //verify returned very true
            PFUser *currentUser = [PFUser currentUser];
            
            bool isVerifiedBool = true;
            NSNumber *isVerifiedNum = [[NSNumber alloc] initWithBool:isVerifiedBool];
            currentUser[@"isVerified"] = isVerifiedNum;
            
            [currentUser saveEventually];
            
            if([currentUser[@"role"] isEqualToString:@"Client"]){
                if(self.randomUserNoGym){
                    //user is random...match w/RD...send home
                    
                    //match with random RD
                    [self buildChatroom];
                    
                    
                }else{
                    //send to client home view
                    [self performSegueWithIdentifier:@"isClientSegue" sender:self];
                    //set the chatroom object here before segue-ing to the next view
                }
            
            }else{
                //send to pt/rd views
                //pts and rds will be on the verification page the first time they log in :)
                [self performSegueWithIdentifier:@"isNotClientSegue" sender:self];
            }
            
            NSLog(@"Your code has been verified and segue has been called");
            
        }else{
            [self.activityIndicator stopAnimating];
            UIAlertView *verifySentAlert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Verification code did not work! Please check and enter again." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [verifySentAlert show];
        }
        
    }//end else

}

- (IBAction)verifyButtonPressed:(id)sender {
    
    [self.activityIndicator startAnimating];
    
    NSString *phone = [self.phoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([phone isEqualToString:@""] || [phone length] < 14){
        NSLog(@"phoen string i s: %@", phone);
        [self.activityIndicator stopAnimating];
        
        //the the phone is nil or not enough charactres
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You entered an invalid phone number. Please check and try again :) " delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
        
    }else{
        //let's see if the phone is an active paying account
        [self checkAccountStatus:phone];
    }
    
}



- (bool)verifyCode:(NSString *)code phone:(NSString *)phone{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *urlFormat = [[NSString alloc] initWithFormat:@"https://api.authy.com/protected/json/phones/verification/check?api_key=ECOTpmCCg8XGn8CR1ec7EkAL8ZE3k08s2akxoI5OLvw&phone_number=%@&country_code=1&verification_code=%@",phone,code];
    [request setURL:[NSURL URLWithString:urlFormat]];
    [request setHTTPMethod:@"GET"];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:nil error:nil];
    
    NSError* error;
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
    NSLog(@"dictionary: %@", dictionary);
    
    NSNumber *boolean = [dictionary objectForKey:@"success"];
    
    if(boolean.boolValue == true){
        NSLog(@"Code accepted.....");
        
        //we are here because we checked the code...and it has been accepted
        [self firstTimeLogin];
        return true;
        
    }else{
        NSLog(@"code not accepted....");
        return false;
    }

}

-(bool)requestVerification:(NSString *)phone{
    
     NSString *post = [NSString stringWithFormat:@"via=sms&phone_number=%@&country_code=1", phone];
     NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
     NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
     
     NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
     [request setURL:[NSURL URLWithString:@"https://api.authy.com/protected/json/phones/verification/start?api_key=ECOTpmCCg8XGn8CR1ec7EkAL8ZE3k08s2akxoI5OLvw"]];
     [request setHTTPMethod:@"POST"];
     [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
     [request setHTTPBody:postData];

    NSData *response = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:nil error:nil];
    
    NSError* error;
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];
    NSLog(@"dictionary: %@", dictionary);
    
    NSNumber *boolean = [dictionary objectForKey:@"success"];
    
    if(boolean.boolValue == true){
        NSLog(@"Messages sent!!!!!");
        return true;
        
    }else{
        NSLog(@"Message did not send!!!");
        return false;
    }
    
}

- (IBAction)sendAnotherCodePressed:(id)sender {
    
    NSString *phone = [self.phoneNumberTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self requestVerification:phone];
    
    UIAlertView *verifySentAlert = [[UIAlertView alloc] initWithTitle:@"Yay!" message:@"Another verification code is on the way! Please enter it below to complete registration." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [verifySentAlert show];

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

-(void)keyboardDidShow:(NSNotification *)sender
{
    //https://gist.github.com/dlo/8572874
    
    CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
    
    self.bottomConstraint.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame);
    //self.bottomActivityConstraint.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame) - 17.5; // (height of button(55) + 2) - (height of indicator + 2)
    
    //this re-layouts our view
    [self.view layoutIfNeeded];
}

- (void)keyboardWillHide:(NSNotification *)sender {
    self.bottomConstraint.constant = 0;
    self.bottomActivityConstraint.constant = 0;
    [self.view layoutIfNeeded];
}

- (void)subscribeToMailChimp:(NSString *)email firstName:(NSString *)fName lastName:(NSString *)lName isVerified:(bool)isVerified{
    
    NSString *listId = [[NSString alloc] init];
    PFUser *currentUser = [PFUser currentUser];
    [currentUser fetch];
    
    if(isVerified){
        //put useres in verified users list
        listId = @"e94de31b41";
        

    }else{
        //put users in unverified users list
        listId = @"645b460f4f";
        
        //send nonmember email
        [PFCloud callFunctionInBackground:@"sendNonMemberEmail"
                           withParameters:@{@"toEmail": currentUser.email,
                                            @"toName": currentUser[@"firstName"]
                                            }
                                    block:^(NSString *result, NSError *error) {
                                        if (!error) {
                                            NSLog(@"RESULT IS: %@", result);
                                        }
                                        else{
                                            NSLog(@"ERROR: %@", error);
                                        }
                                    }];
        
        
        

    }
        //send you aren't a member email
    
    NSDictionary *params = @{@"id": listId, @"email": @{@"email": email}, @"merge_vars": @{@"FNAME": fName, @"LName":lName}, @"double_optin": @0};
    
    [[ChimpKit sharedKit] callApiMethod:@"lists/subscribe" withApiKey:MAILCHIMP_TOKEN params:params andCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        //        NSLog(@"HTTP Status Code: %d", request.response.statusCode);
        //        NSLog(@"Response String: %@", request.responseString);
        
        if (error) {
            //Handle connection error
            NSLog(@"Error, %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update UI here
            });
        } else {
            //success?
            
            
            
            
        }
    }];
}

- (void)buildChatroom{
    //the user selected NO pt
    //let's build the chatroom and then segue when done
    //no dietitian user
    
    //get a random RD and assign it to them
    PFQuery *query = [PFUser query];
    [query whereKey:@"role" equalTo:@"RD"]; //query for all RDs in the system
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //we just got all the RD objects
        //now lets randomly assign one to the user who just signed up
        
        PFUser *randomUser = [objects objectAtIndex: arc4random() % [objects count]];
        NSLog(@"The random user is.........%@", randomUser);
        
        //we just got a random user
        PFUser *userSelected = [[PFUser alloc] init];
        userSelected = [PFQuery getUserObjectWithId:randomUser.objectId];
        
        //let' s build the chatroom object now
        PFObject *chatroom = [PFObject objectWithClassName:@"Chatrooms"];
        
        //set the client, RD, and PT
        [chatroom setObject:[PFUser currentUser] forKey:@"clientUser"];
        [chatroom setObject:userSelected forKey:@"dietitianUser"];
        NSNumber *isUnreadNum = [[NSNumber alloc] initWithBool:true];
        chatroom[@"isUnread"] = isUnreadNum;
        
        //save the chatroom in background
        [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            //go home
            [self performSegueWithIdentifier:@"isRandomClientSegue" sender:self];

            //send push notification to RD and PT
            PFUser *currentUser = [PFUser currentUser];
            
            //fetch for data...?
            [currentUser fetch];
            
            //build array of who is getting the push sent to them
            NSArray *pushUsers = @[userSelected];
            
            //build push query
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" containedIn:pushUsers];
            
            //build push string
            NSString *name = [NSString stringWithFormat:@"You have a new client! Say hi to  %@  :)", currentUser[@"firstName"]];
            
            //set data for push
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  name, @"alert",
                                  @1, @"badge",
                                  nil];
            
            //new push object
            PFPush *push = [[PFPush alloc] init];
            
            //set data and send
            [push setQuery:pushQuery];
            [push setData:data];
            
            //send
            [push sendPushInBackground];
            
            NSLog(@"Push's sent and everything okay...");
         
            //set twilio number
            [self setTwilioNumber:chatroom coachuser:userSelected];
            
        }];//end save chatroom object
    }];
    
}

- (void)firstTimeLogin{
    
    PFUser *currentUser = [PFUser currentUser];
    [currentUser fetch];
    
    //add mixpanel user
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    // mixpanel identify: must be called before
    // people properties can be set
    [mixpanel identify:currentUser.objectId];
    
    // Sets user  "Plan" attribute to "Premium"
    [mixpanel.people set:@{@"$first_name": currentUser[@"firstName"],
                           @"$last_name": currentUser[@"lastName"],
                           @"$email": currentUser.username,
                           @"Role": currentUser[@"role"],
                           @"$created": currentUser.createdAt
                           }];
    
    
    
    //send first time login email
    [PFCloud callFunctionInBackground:@"sendFirstTimeLoginEmail"
                       withParameters:@{@"toEmail": currentUser.email,
                                        @"toName": currentUser[@"firstName"]
                                        }
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        NSLog(@"RESULT IS: %@", result);
                                    }
                                    else{
                                        NSLog(@"ERROR: %@", error);
                                    }
                                }];
    
    //sets the start of the users membership
    currentUser[@"membershipStartDate"] = [NSDate date];
    [currentUser saveInBackground];

}

- (void)setTwilioNumber:(PFObject *)chatroom coachuser:(PFUser *)coachUser{
    //set the twilio number for the chatroom
    NSLog(@"Hey you. You are setting twilio numba");
    //we need to use a twilio number that their assigned coach is NOT using already
    //retrieve all chatrooms that have the 'userSeleccted' user as 'dietitianUser'
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Chatrooms"];
    [query whereKey:@"dietitianUser" equalTo:coachUser];
    [query whereKeyExists:@"twilioNumber"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSMutableArray *usedTwilioNumbers = [[NSMutableArray alloc] init];
        NSMutableArray *availableTwilioNumbers = [[NSMutableArray alloc] init];
        
        for(PFObject *chatroomObject in objects){
            //put all the twilio numbers in use into an array
            NSString *twilioNumber = chatroomObject[@"twilioNumber"];
            [usedTwilioNumbers addObject:twilioNumber];
        }
        
        NSLog(@"used numbers are are: %@", usedTwilioNumbers);
        
        //retrieve all available twilio numbers from Twilio class **twilos api for this??
        PFQuery *query = [[PFQuery alloc] initWithClassName:@"Twilio"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSLog(@"avail numbas are: %@", objects);
            
            //just returned array of all twilio numbers
            for(PFObject *twilioNumberObject in objects){
                //add each available twilio number to local array
                
                NSString *avialNumbas = twilioNumberObject[@"phoneNumber"];
                [availableTwilioNumbers addObject:avialNumbas];
            }
            
            //okay...so now we have all available number and all USED numbers
            //remove all twilio numbers from availableNumbers array that exist in UsedNumbesr array
            NSMutableArray *result = [[NSMutableArray alloc] init];
            result = [availableTwilioNumbers mutableCopy];
            
            //usedtwilio
            //availabletwilio
            
            for(NSString *numba in usedTwilioNumbers){
                for(NSString *innerNumba in availableTwilioNumbers){
                    if([innerNumba isEqualToString:numba]){
                        //the first number in available numbers is checked against every number that is used
                        //if the availalbl number is equal to a used number
                        //then we remove that from possible twilio number for use
                        [result removeObject:numba];
                        NSLog(@"inner numba: %@ outta numba: %@ result: %@", innerNumba, numba, result);
                        
                    }
                }
            }
            
            //availableTwilioNumbers should now only have unUsed numbesr
            
            NSString *numberToAssign = [result firstObject];
            NSLog(@"numberToassign is: %@", numberToAssign);
            
            [chatroom fetchIfNeeded];
            chatroom[@"twilioNumber"] = numberToAssign;
            [chatroom saveInBackground];
            NSLog(@"Hey you. You made it");
            
            
        }];//end twilio query
        
    }];//end chatroom query
    
    
    
    
    //select first number in resulting array
    //assign that number to the coachUser
    //save
    
    
    
    
    
}



@end
