//
//  SignUpConversationViewController.m
//  Nomful
//
//  Created by Sean Crowe on 8/10/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "SignUpConversationViewController.h"
#import "MandrilTestViewController.h"
@interface SignUpConversationViewController (){
    
    NSString *firstNameString;
    NSString *lastNameString;
    NSNumber *numberOfDaysPrepaid;
    
    
}

@end

CGFloat const ktypeInterval = 0.02;

@implementation SignUpConversationViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"current user is: %@", [PFUser currentUser]);
    
    if(![PFUser currentUser]){
        //create anonymous user
        [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
            if (error) {
                NSLog(@"Anonymous login failed.");
            } else {
                NSLog(@"Anonymous user logged in.");
            }
        }];
    }
    
    [_messageTextView setFont:[UIFont fontWithName:kFontFamilyName100 size:22.0]];
    _realCode = [[NSString alloc] init];
    
    [_nomberry setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self layoutNomberry];
    
    //set the messages
    
    _textfield1.delegate = self;
    // Add a "textFieldDidChange" notification method to the text field control.
    [_textfield1 addTarget:self
                  action:@selector(textFieldDidChange)
        forControlEvents:UIControlEventEditingChanged];
    
    _messagesArray = [[NSMutableArray alloc] initWithObjects:
                                                        @"Hi! Welcome to Nomful. My name is Nomberry.",
                                                        @"I’ll help you find the perfect coach. Together, you’ll work towards achieving your health goals.",
                                                        @"Before we begin, I’ll need to know your full name.",
                                                        @"placeholder 0",
                                                        @"Are you female or male?",
                                                        @"How old are you?",
                                                        @"Do you have a personal trainer? - Get rid of me",
                                                        @"Just in case, what is your email? Don’t worry; you won’t be spammed. I would never do that to you!",
                                                        @"Awesome! Thanks for the information. Now we can work on finding your coach :)",
                                                        @"placeholder 2",
                                                        @"Congratulations! I’m excited for you to work towards a happier, healthier life! Why don’t you add a profile picture?",
                                                        @"To make sure you’re not a robot, please enter your phone number and I’ll text you a secret code.",
                                                        @"Check your phone and tell me the secret password! :) ",
                                                        @"",
                                                        nil];
    
   
   
    _buttonLabelArray = [[NSMutableArray alloc] initWithObjects:
                         @"Hey! Nice to meet you!",
                         @"Sounds good to me!", //\ue00e
                         @"",
                         @"Weight Loss",
                         @"Male",
                         @"",
                         @"",
                         @"",
                         @"Can't Wait!",
                         @"",
                         @"Let's Do This!",
                         @"Finish Creating Account",
                         @"Send Code",
                         @"Login",
                         @"",
                         nil];
    

    //set the counter to 0.
    _messageCount = 0;
    _buttonLabelCount = 0;
    
    //button design
    CGFloat borderWidth = 4.0;
    CGFloat cornerRadius = 7.0;
    UIColor *borderColor = [UIColor colorWithRed:93/255.0 green:164/255.0 blue:137/255.0 alpha:1.0];
    
    _button1.layer.borderWidth = borderWidth;
    _button2.layer.borderWidth = borderWidth;
    _button3.layer.borderWidth = borderWidth;
    _button4.layer.borderWidth = borderWidth;
    
    _button1.layer.cornerRadius = cornerRadius;
    _button2.layer.cornerRadius = cornerRadius;
    _button3.layer.cornerRadius = cornerRadius;
    _button4.layer.cornerRadius = cornerRadius;

    _button1.layer.borderColor = [borderColor CGColor];
    _button2.layer.borderColor = [borderColor CGColor];
    _button3.layer.borderColor = [borderColor CGColor];
    _button4.layer.borderColor = [borderColor CGColor];

    [self stickyButton];
    
    //textfield design
    _textfield1.layer.borderWidth = borderWidth;
    _textfield1.layer.cornerRadius = cornerRadius;
    _textfield1.layer.borderColor = [borderColor CGColor];
    _textfield1.tintColor = [UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0];
    
    //This gets the text in the textfields to move to the right 20px. Gives room for icons
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 41)];
    [_textfield1 setLeftViewMode:UITextFieldViewModeAlways];
    [_textfield1 setLeftView:spacerView];
    
    //index set for the typeIt function
    self.index = 1;
    _i = 0;
    //display message based on the count
    _messageTextView.text = [_messagesArray objectAtIndex:_messageCount];
    [_button1 setTitle:[_buttonLabelArray objectAtIndex:_buttonLabelCount] forState:UIControlStateNormal];
    _coachMatchContainer.hidden = true;


    [self showNextMessage];
    
}

- (void)showNextMessage{
    
    
    [_button1 setTitle:[_buttonLabelArray objectAtIndex:_messageCount] forState:UIControlStateNormal];
    
    //start timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:ktypeInterval target:self selector:@selector(typeIt) userInfo:nil repeats:YES];
}

- (IBAction)buttonPressed:(id)sender {
    NSLog(@"User made a selection or entered somethign and pressed send...GO!");
    NSLog(@"the message count currently is %ld", (long)_messageCount);
    //This is the FIRST thing executed when any input is selected or entered
    //validate that the input we selected or entered is valid!! GO!
    
    //hide the inputs
    //this is messy but whatevs
    _button1.hidden = true;
    _button2.hidden = true;
    _button3.hidden = true;
    _button4.hidden = true;
    _textfield1.hidden = true;
    
    
    ///old stuff
    if (_cancelButtonPressed) {
        if(sender == _button1){
            [self dismissViewControllerAnimated:YES completion:^{
                
                //do somethign
            }];
        }else{
            //continue with conversation
            [_messagesArray replaceObjectAtIndex:_messageCount withObject:_replacedString];
            
            //cleanup on the button labels
            if(_messageCount == 3){
                [_button2 setTitle:@"Boost Energy" forState:UIControlStateNormal];
            }
            if(_messageCount == 4){
                [_button2 setTitle:@"Female" forState:UIControlStateNormal];
            }
            if(_messageCount == 6){
                [_button2 setTitle:@"Nope" forState:UIControlStateNormal];
            }
        
            _cancelButtonPressed = NO;
            [self showNextMessage];
        }
    }else{


        //do the validation yo
        switch (_messageCount)
        
        {
            case 0:{
                //NICE TO MEET YOU!
                _messageCount ++;
                [self showNextMessage];
                
                }break;
            
            case 1:{
                _messageCount ++;
                _buttonLabelCount ++;
                [self showNextMessage];
                
            }break;
                
            case 2:{
                //NAME
                NSString *meetYouString = [NSString stringWithFormat:@"Great to meet you %@! Which one of these options best describes your health goals?", _textfield1.text];
                [_messagesArray replaceObjectAtIndex:_messageCount+1 withObject:meetYouString];

                //nothing was entered show warning message
                if([_textfield1.text isEqualToString:@""]){
                    
                    //error message
                    [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"Please enter your first Name!"];
                    
                    //show message
                    [self showNextMessage];
                    
                }else{
                    //name entered save
                    //save name to anonymouse user
                    NSString *fullName = [_textfield1.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    NSRange range = [fullName rangeOfString:@" "];
                    

                    
                    if (range.location != NSNotFound) {
                        //space found...so this menas that there is prolly a last name
                        NSString *fname = [fullName substringToIndex:range.location];
                        NSString *lname = [fullName substringFromIndex:range.location+1];
                        lastNameString = lname;
                        firstNameString = fname;
                        
                        [PFUser currentUser][@"lastName"] = lname;
                        [PFUser currentUser][@"firstName"] = fname;
                    }else{
                        [PFUser currentUser][@"firstName"] = fullName;
                        [PFUser currentUser][@"lastName"] = @"";
                    }
                    
                    [PFUser currentUser][@"role"] = @"Client";
                    [[PFUser currentUser] saveInBackground];
                    
                    //set the button labels for the next message
                    //these titles must be the same name as what is in parse
                    [_button2 setTitle:@"Boost Energy" forState:UIControlStateNormal];
                    [_button3 setTitle:@"Marathon Training" forState:UIControlStateNormal];
                    [_button4 setTitle:@"Weight Gain" forState:UIControlStateNormal];

                    //clear textfield
                    _textfield1.text = @"";
                    
                    _messageCount ++;
                    _buttonLabelCount ++;
                    [self showNextMessage];
                }
                
                }break;
                
            case 3:{
                //HEALTH GOALS
                
                NSString *goalString = [[NSString alloc] init];
                NSMutableArray *goalArray = [[NSMutableArray alloc] init];
                
                goalString = [sender currentTitle];
                [goalArray addObject:goalString];
                
                [PFUser currentUser][@"goals"] = goalArray;
                [[PFUser currentUser] saveInBackground];
                
                //prepare button label
                [_button2 setTitle:@"Female" forState:UIControlStateNormal];
                
                if(!_cancelButtonPressed){
                    _messageCount ++;
                    _buttonLabelCount ++;
                }
                
                [self showNextMessage];
                }break;
            
            case 4:{
                //GENDER
                
                if (sender == _button1) {
                    [PFUser currentUser][@"gender"] = @"m";
                }else if(sender == _button2){
                    [PFUser currentUser][@"gender"] = @"f";
                }
                
                [[PFUser currentUser] saveInBackground];
                
                _messageCount ++;
                _buttonLabelCount ++;
                [self showNextMessage];
                
                }break;
                
            case 5:{
                //AGE
                
                NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                
                if([_textfield1.text isEqualToString:@""] || !([_textfield1.text rangeOfCharacterFromSet:notDigits].location == NSNotFound)){
                    
                    //nothing was entered show warning message
                    //or
                    //not numeric
                    [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"Please enter a valid age."];
                    [self showNextMessage];
                    
                }else{
                    //name entered save
                    [PFUser currentUser][@"age"] = [_textfield1.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [[PFUser currentUser] saveInBackground];
                    
                    //prepare labels
                    [_button2 setTitle:@"Nope!" forState:UIControlStateNormal];
                    [_button3 setTitle:@"Yup!" forState:UIControlStateNormal];
                    
                    //show message
                    _messageCount ++;
                    _messageCount ++;


                    _buttonLabelCount ++;
                    _buttonLabelCount ++;

                    
                    //clear textfield
                    _textfield1.text = @"";
                    
                    [self showNextMessage];
                    
                    
                }
                
                
                }break;
                
            case 6:{
                //TRAINER OR NO
                
                
                if(sender == _button3){
                    
                    //we need to increment the messasge count BEFORE we show the message
                    //this way the NEXT message shown is the string we're setting below
                    _messageCount++;
                    
                    //add object to message array
                    [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"Great! Select your trainer below"];
                    
                    [self showNextMessage];
                    
                }else if(sender == _button2){ // && !_cancelButtonPressed
                    //no trinter no gym = button2
                    //go to next message
                    
                    _messageCount += 2; //message count is now 8
                    [self showNextMessage];
                    
                }else if(sender == _button1){
                    
                    //selected I go to a gym!!
                }
                
                
                }break;
                
            case 7:{
              
                //EMAIL
                
                if([_textfield1.text isEqualToString:@""]){
                    
                    //nothing was entered show warning message
                    [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"Please enter your email."];
                    [self showNextMessage];
                    
                }else{
                    NSLog(@"about to save email");
                    [[PFUser currentUser] fetchIfNeeded];
                    [PFUser currentUser].email = _textfield1.text;
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if(error){
                            NSLog(@"error: %@", error);
                            
                            [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"Email already in use. Try again."];
                            [self showNextMessage];
                        }else{
                            //no error
                            
                            //prep label
                            [_button2 setTitle:@"Find Another Coach!" forState:UIControlStateNormal];
                            _messageCount ++;
                            
                            //clear textfield
                            _textfield1.text = @"";
                            
                            [self showNextMessage];
                        }
                        
                    }];
                }
                }break;
            
            case 8:{
                //I'm going to find you the perfect coach
        
                _messageCount++;
                [self animateNomberry];
                
                }break;
            
            case 10:{
                NSLog(@"case 11");
                //only called when the I LOOK GOOD button is pressed
                //fade in coach view
                
                [UIView animateWithDuration:0.5f animations:^{
                    
                    [_coachMatchContainer setAlpha:0.0f];
                    
                } completion:^(BOOL finished) {
                    // ...then dismiss the child view controller
                    
                    _coachMatchContainer.hidden = YES;
                    _messageCount++;
                    [self showNextMessage];
                    
                }];
                

                
                }break;
                
            case 11:{
                //send code
                NSLog(@"send sending code to: %@", _textfield1.text);
                _coachMatchContainer.hidden = true;

                
                //check to see the phone is valide
                _phone = _textfield1.text;
                
                if([_phone length] != 10){
                    //invalid phone
                    [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"Please enter a 10 digit phone number."];
                    [self showNextMessage];
                }else{
                    //success, the phone is valid 10 digits
                    
                    //check for a user with phone number typed in in phoneNumber field
                    //if already exists
                        //display error message that phone already in use
                    //if doesn't exist
                        //call cloud code
                    
                    PFQuery *query = [PFUser query];
                    [query whereKey:@"phoneNumber" equalTo:_phone];
                    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                        if (objects.count > 0) {
                            
                            //you are here b/c we found other users with the phone number
                            //in case the user typed in their number...was saved to their user
                            //and then selected send me another code, we must see if the current user already
                            //has the phone number selected. If it is, then send code for login
                            
                            if ([[PFUser currentUser][@"phoneNumber"] isEqualToString:_phone]) {
                                //send code stuf
                                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    //cloud code uses the phoneNumber so we need to do this in a block
                                    //send twilio text
                                    [self sendCode];
                                    [self checkIfPrepaid]; //check to see if user is pre-paid by gym
                                    
                                    
                                    //clear textfield
                                    _textfield1.text = @"";
                                    _messageCount ++;
                                    [self showNextMessage];
                                    
                                }];
                            }else{
                                //again, you are here b/c we found other users with the phone number
                                //but we know it isn't the current user so we can allert them to try and log in or somehing
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh!" message:@"Looks like an account with your phone number is already in use. Please check and try again or go back and login to your account." delegate:self cancelButtonTitle:@"Got it!" otherButtonTitles: nil];
                                [alert show];
                                [_textfield1 becomeFirstResponder];
                                _textfield1.hidden = false;
                            }
                        
                       }else{
                            //succes! There are no other users with that phone number
                            [PFUser currentUser][@"phoneNumber"] = _phone; //*we can put this in cloud code eventually
                            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                //cloud code uses the phoneNumber so we need to do this in a block
                                //send twilio text
                                [self sendCode];
                                [self checkIfPrepaid]; //check to see if user is prepaid by gym
                                
                                
                                //clear textfield
                                _textfield1.text = @"";
                                _messageCount ++;
                                [self showNextMessage];
                                
                                
                            }];
                        }
                    }];
                    
                    
                }
                
                
                }break;
                
            case 12:{
                //login with phone
                NSLog(@"cloud code login called");
                //call cloud funciton...checks code and saves password
                [self loginWithPhone:_textfield1.text];

                }break;
                
            default:
                
                break;
                
        }//end switch
        
    }
}



- (void)saveToAnonUser:(id)sender{
    
    NSLog(@"Save to Parse: %ld", (long)_messageCount);
    
    if(_cancelButtonPressed){
        _cancelButtonPressed = NO;
    }else{
        if(_messageCount == 2){
            
            if([_textfield1.text isEqualToString:@""]){
                
                //nothing was entered show warning message
                [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"Please Enter your first Name!"];
                _messageCount --;
                _buttonLabelCount --;
                
            }else{
                //name entered save
                //save name to anonymouse user
                [PFUser currentUser][@"firstName"] = [_textfield1.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [[PFUser currentUser] saveInBackground];
            }
            
            
        }else if(_messageCount == 3){
            
            NSString *goalString = [[NSString alloc] init];
            NSMutableArray *goalArray = [[NSMutableArray alloc] init];
            
            goalString = [sender currentTitle];
            [goalArray addObject:goalString];
            
            NSLog(@"it is: %@", goalString);
            
            [PFUser currentUser][@"goals"] = goalArray;
            [[PFUser currentUser]saveInBackground];
            
        }else if(_messageCount == 4){
            
            if (sender == _button1) {
                [PFUser currentUser][@"gender"] = @"m";
            }else if(sender == _button2){
                [PFUser currentUser][@"gender"] = @"f";
            }
            [[PFUser currentUser] saveInBackground];
            
        }else if(_messageCount == 5){
            
            NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];

            if([_textfield1.text isEqualToString:@""] || !([_textfield1.text rangeOfCharacterFromSet:notDigits].location == NSNotFound)){
                
                //nothing was entered show warning message
                //or
                //not numeric
                [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"Please enter a valid age."];
                _messageCount --;
                _buttonLabelCount --;
                
            }else{
                //name entered save
                [PFUser currentUser][@"age"] = [_textfield1.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [[PFUser currentUser] saveInBackground];
            }
            
        }else if (_messageCount == 6){
            
            
            
        }
        else if(_messageCount == 8){
            
            if([_textfield1.text isEqualToString:@""]){
                
                //nothing was entered show warning message
                [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"Please enter your email."];
                _messageCount --;
                _buttonLabelCount --;
                
            }else{
                NSLog(@"about to save email");
                [PFUser currentUser].email = _textfield1.text;
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if(error){
                        NSLog(@"error: %@", error);
                       
                        [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"Email already in use. Try again."];
                        _messageCount --;
                        _buttonLabelCount --;
                        
                    }
                    
                }];
                
                
            }
            
            
        }else if(_messageCount == 12){
            NSLog(@"send sending code to: %@", _textfield1.text);
            //save phone
            _phone = _textfield1.text;
            
            [PFUser currentUser][@"phoneNumber"] = _phone;
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                //cloud code uses the phoneNumber so we need to do this in a block
                //send twilio text
                [self sendCode];
                
            }];
            
        }else if(_messageCount == 13){
            NSLog(@"cloud code login called");
            //call cloud funciton...checks code and saves password
            [self loginWithPhone:_textfield1.text];
        }

    }
    
}

-(void)stickyButton{
    
    //listen for keyboard events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //view is the thing we want to move around based on keyboard showing or not showing
    NSDictionary *views = @{@"view": _textfield1,
                            @"top": self.topLayoutGuide};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[top][view]" options:0 metrics:nil views:views]];
   
    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:_textfield1 attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:-15];
    
    
    
    [self.view addConstraint:self.bottomConstraint];
    
}


-(void)keyboardShow:(NSNotification *)sender
{
    //https://gist.github.com/dlo/8572874
    
    CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
    
    //-15 is to get the thing to show up with some padding above keyboard
    self.bottomConstraint.constant = (newFrame.origin.y - CGRectGetHeight(self.view.frame))-15;

    //this re-layouts our view
    [self.view layoutIfNeeded];
}

- (void)keyboardHide:(NSNotification *)sender {
    self.bottomConstraint.constant = -15;
    [self.view layoutIfNeeded];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"send button on keyboard pressed");
    
    [textField resignFirstResponder];
    [self buttonPressed:textField];
    
    return YES;
}


-(void)typeIt{
    NSLog(@"typing with message count of %ld", _messageCount);
    
    _text = [_messagesArray objectAtIndex:_messageCount];
    
    //hide close button
    _closeButton.hidden = true;
    
    if( [_text length] >= self.index )
    {
        self.messageTextView.text = [NSString stringWithFormat:@"%@", [self.text substringToIndex:self.index++]];
    }
    else
    {
        NSLog(@"Typeit Complete");
        [self.timer invalidate];
        _index = 1;
        
        //Now that the label is done animating show the input button options
        [self showInputOptions];
        
        //show close button
        _closeButton.hidden = false;

    }

}


- (void)layoutNomberry{
    
    //dictionary for views to be constrained
    NSDictionary *views = @{@"nomberry"       :   _nomberry
                            };
    
    //15 pts from top view and height
    
    _constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[nomberry(95)]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views];
    [self.view addConstraints:_constraints];
    
    //width
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[nomberry(69)]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];

    //center horizontally
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_nomberry
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f constant:0.0f]];


    

    
 
    
}
- (void)animateNomberry{
    
    _messageTextView.hidden = true;
    _button1.hidden = true;
    
    //remove the constraint 40pts and horizontal alignment
    [self.view removeConstraints:_constraints];
    
    //add in the height constraint again since we just removed it
    //dictionary for views to be constrained
    NSDictionary *views = @{@"nomberry"       :   _nomberry
                            };
    
    _constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[nomberry(95)]"
                                                           options:0
                                                           metrics:nil
                                                             views:views];
    [self.view addConstraints:_constraints];
    
    //vertical center
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_nomberry
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f constant:0.0f]];
    
    
    
    [UIView animateWithDuration:0.8 animations:^{
            //layout the nomberry to animate down
            [self.view layoutIfNeeded];

     
        }completion:^ (BOOL finished){
            if(finished){
                
                //animate nomberry to show that we're searching for somethign
                
                
                //go find the coach
            
                [self findCoach:^(BOOL finished) {
                    if(finished){
                        
                        
                        //You have found a coach list
                        //stop animation
                        //return nomberry to top
                        [self nomberryLayoutAfterAnimation];
                       
                        //display the coaches in our new card view :)
                        _coachUsers = _coachUserArray;
                
                        // Create page view controller
                        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"coachBioPageViewController"];
                        self.pageViewController.dataSource = self;
                        
                        _pageViewController.view.alpha = 0.0f;
                        
                        //create view controller and pass it our user data
                        CoachPageContentViewController *startingViewController = [self viewControllerAtIndex:0];
                        startingViewController.delegate = self;
                        NSArray *viewControllers = @[startingViewController];
                        
                        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
                        
                        // Change the size of page view controller...make room for button at bottom
                        //self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50);
                        
                        //[self addChildViewController:_pageViewController]; //just doing this doesn't work
                        [self.view addSubview:_pageViewController.view]; //just doing this does work
                        
                        //the view is not visible yet...it is animated in
                        
                        
                    }else{
                        NSLog(@"failllleD");
                        //you didn't find a coach
                        //search again and keep animation going
                        //maybe display a warning message that no coach found?
                    }
                }];
                
                
            }
        }];
    

}

- (void)nomberryLayoutAfterAnimation{
    
  
    //remove the constraint 40pts and horizontal alignment
    [self.view removeConstraints:_constraints];
    
    //add in the height constraint again since we just removed it
    //dictionary for views to be constrained
    NSDictionary *views = @{@"nomberry"       :   _nomberry
                            };
    
    _constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[nomberry(95)]"
                                                           options:0
                                                           metrics:nil
                                                             views:views];
    [self.view addConstraints:_constraints];
    
    //vertical center
    [self.view removeConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_nomberry
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f constant:0.0f]];
    
    
    
    
    [UIView animateWithDuration:0.8 animations:^{
        //layout the nomberry to animate down
        [self.view layoutIfNeeded];
        
        
    }completion:^(BOOL finished) {
        
        if(finished){
          
            //show coach bio stuff

            _messageTextView.text = @"what";
            
            //show next message
            [self showNextMessage];
            
            
            //fade in coach view
            
            [UIView animateWithDuration:0.5f animations:^{
                
                [_pageViewController.view setAlpha:1.0f];
                
            } completion:^(BOOL finished) {
                
                
            }];

        }
    }];
}

- (void)showInputOptions{
    NSLog(@"show input with message count at: %ld", (long)_messageCount);
    
    if(_cancelButtonPressed){
        //show yes and no
        
        [_button1 setTitle:@"I'm Done Talking With You" forState:UIControlStateNormal];
        [_button2 setTitle:@"Joking! Let's keep talking :)" forState:UIControlStateNormal];
        
        _textfield1.hidden = YES;
        _button3.hidden = YES;
        _button4.hidden = YES;
        

        [self animateInputIn:_button1];
        [self animateInputIn:_button2];

    }
    else{
        
        //show button1
        if(_messageCount == 0 || _messageCount == 1 ){
            
            [self animateInputIn:_button1];
            
        }else if(_messageCount == 2){
            [_textfield1 becomeFirstResponder];
            _textfield1.hidden = false;
            
            //for #9...we may want to force format the phone number
            //maybe a new textfield init'd programatically will be good here
        }else if(_messageCount == 3){
            
            //maybe we do an array input here instead??
            [self animateInputIn:_button1];
            [self animateInputIn:_button2];
            [self animateInputIn:_button3];
            [self animateInputIn:_button4];
            
        }else if(_messageCount == 4){
            
            [self animateInputIn:_button1];
            [self animateInputIn:_button2];
            
        }else if(_messageCount == 5){
            
            //age
            _textfield1.keyboardType = UIKeyboardTypeNumberPad;
            [_textfield1 becomeFirstResponder];
            _textfield1.hidden = false;
            
        }else if(_messageCount == 6){
            _textfield1.keyboardType = UIKeyboardTypeDefault;

            _textfield1.hidden = true;
            [self animateInputIn:_button1];
            [self animateInputIn:_button2];
            [self animateInputIn:_button3];
            
        }else if(_messageCount == 7){
    
            //age
            _textfield1.keyboardType = UIKeyboardTypeEmailAddress; //**for now leaving this out since we have ot add in a 'send' button that would normally be in the keyboard
            
            [_textfield1 becomeFirstResponder];
            _textfield1.hidden = false;
            
        }else if(_messageCount == 8){
            _textfield1.hidden = true;
            
            [self animateInputIn:_button1];
            
        }else if(_messageCount == 9){
//            [self animateInputIn:_button2];
//            [self animateInputIn:_button1];
            _coachMatchContainer.alpha = 0.0f;
            _dontShowProfileButton.hidden = false;
        }else if (_messageCount == 10){
            //add profile pic
            //_textfield1.keyboardType = UIKeyboardTypeNumberPad;
            
            
            _coachMatchContainer.hidden = false;

            [UIView animateWithDuration:0.5f animations:^{
                _coachMatchContainer.alpha = 1.0f;
                _noProfileButton.hidden = false;

            }];
            

            
        }else if(_messageCount == 11 ){
            
            [_textfield1 becomeFirstResponder];
            _textfield1.hidden = false;
            
        }else if(_messageCount == 12){
            [_textfield1 becomeFirstResponder];
            _textfield1.hidden = false;
            
            
            //show code didn't send button
            _sendAnotherCodeButton.hidden = false;

        }
    }
}

- (void)animateInputIn:(id)sender{
    
    if([sender isKindOfClass:[UIButton class]]){
        UIButton *button = sender;
        //make invisible
        button.alpha = 0;
        
        //show button...even though invisible
        button.hidden = false;
        
        //animate aplha to 100%
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             button.alpha = 1.0;
                         }
                         completion:nil];
        
    }
  
    if([sender isKindOfClass:[UITextField class]]){
        UITextField *textField = sender;
        
        //animate
        textField.hidden = false;
    }
    
    
}

-(void) findCoach:(findCoachCompleted) compblock{
    //do stuff
    NSLog(@"find coach started");
    
    //query for coaches based on goal selected
    NSMutableArray *memberGoals = [[NSMutableArray alloc] init];
    memberGoals = [[PFUser currentUser] objectForKey:@"goals"];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"goals" containedIn:memberGoals];
    [query whereKey:@"role" equalTo:@"RD"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable coaches, NSError * _Nullable error) {
        
        //array 'coaches' contains all the coaches returned from our query
        _coachUserArray = [coaches mutableCopy];
        
        if(coaches.count > 0){
            NSLog(@"coach block completed");
            compblock(YES);
        }else{
            compblock(NO);
        }
        
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    //trial view segue
    if([segue.identifier isEqualToString:@"showTrialView"]){
        //let's pass all the info needed
        TrialViewController *trialVC = [segue destinationViewController];
        
        NSLog(@"coach user %@", _coachUser);
        trialVC.coachUser = _coachUser;
        trialVC.titleString = @"3 day FREE TRIAL";
        trialVC.buttonString = @"Activate Trial";
        trialVC.stepOneString = @"Activate Trial";
        trialVC.isTrial = true;
    
    }
    
    if([segue.identifier isEqualToString:@"setExpectationsSegue"]){
        
        //prepaid users
        TrialViewController *trialVC = [segue destinationViewController];
        trialVC.titleString = @"Next Steps";
        trialVC.buttonString = @"Let's Do This!";
        trialVC.stepOneString = @"Become Member - You've done this!!";
        trialVC.coachUser = _coachUser;
        trialVC.daysPrepaid = numberOfDaysPrepaid;
        
    }
    
}

-(void)sendCode{
    
    NSLog(@"send login pressed");
    //get values from fields
   
    //this sends a random code to my number
    [PFCloud callFunctionInBackground:@"sendCode"
                       withParameters:@{@"phoneNumber": _phone,
                                        @"language" : @"en"
                                        }
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        NSLog(@"CODE SENT");
                                        
                                    }
                                    else{
                                        NSLog(@"ERROR: %@", error);
                                        
                                    }
                                }];
}

-(void)loginWithPhone:(NSString *)code{
    

    [PFCloud callFunctionInBackground:@"logIn"
                       withParameters:@{@"phoneNumber": _phone,
                                        @"codeEntry" : code
                                        }
                                block:^(NSString *token, NSError *error) {
                                    if (!error) {
                                        
                                        NSLog(@"Login button pressed");
                                        [[PFUser currentUser]signUpInBackground];
                                        
                                        //send event to mix panel that this user is verified
                                        Mixpanel *mixpanel = [Mixpanel sharedInstance];
                                        
                                        //tell mixpanel to identify user
                                        [mixpanel identify:mixpanel.distinctId];
                                        
                                        //set device token for push notification
                                        
                                        //send device token to mixpanel
                                        if(  [[NSUserDefaults standardUserDefaults] dataForKey:@"deviceToken"]){
                                            NSData *deviceToken = [[NSUserDefaults standardUserDefaults] dataForKey:@"deviceToken"];
                                            [mixpanel.people addPushDeviceToken:deviceToken];
                                        }
                                       
                                        
                                        [mixpanel.people set:@{@"$first_name"    : [PFUser currentUser][@"firstName"],
                                                               @"$email"         : [PFUser currentUser].email,
                                                               @"Role"           : @"Client"
                                                               }];
                                        
                                        //we're doing this b/c if one of the fields is empty it doesn't know what to do...so yea check dat shit
                                        if ([PFUser currentUser][@"lastName"]) {
                                            [mixpanel.people set:@{@"$last_name"    : [PFUser currentUser][@"lastName"]
                                                                   }];
                                        }
                                        
                                        //if the user used a link
                                        if ([[NSUserDefaults standardUserDefaults] dataForKey:@"partnerID"]) {
                                            [mixpanel.people set:@{@"Referal Partner" : [[NSUserDefaults standardUserDefaults] dataForKey:@"partnerID"]}];
                                        }
                                        
                                        
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
                                                
                                                NSString *planType;
                                                
                                                [user signUpInBackground];
                                               
                                                
                                                if(_isGymMember){
                                                
                                                    //user has already paid for!
                                                    //send them to a page to set expectations
                                                    planType = @"prepaid";
                                                    [self performSegueWithIdentifier:@"setExpectationsSegue" sender:self];
                                                }
                                                else{
                                                    //user is not paid for...give them a 3 day free trial
                                                    //login was a success!
                                                    planType = @"trial";
                                                    [self performSegueWithIdentifier:@"showTrialView" sender:self];
                                                }
                                                
                                                [PFUser currentUser][@"planType"] = planType;
                                                [[PFUser currentUser] saveInBackground];
                                                
                                                //tell MP they are prepaid
                                                //send user info to mixpanel
                                                [mixpanel.people set:@{@"Plan"    : planType}];
                                                
                                                //check to see if there is a user associated with the device for Push Notifications
                                                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                                                //if(!currentInstallation[@"user"]){
                                                //no user associated so make it!
                                                currentInstallation[@"user"] = user;
                                                [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                    NSLog(@"You just saved the client user on the installation in parse");
                                                }];
                                                
                                            }
                                        }];
                                        
                                    }//end if(error)
                                    else{
                                        NSLog(@"ERROR: %@", error);
                                        //login failed
                                       
                                        [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"Code invalid. Check my text and try again!"];
                                        [self showNextMessage];
                                        
                                    }
                                }];

    
}

- (void)checkIfPrepaid{
    
    // Get the stored data before the view loads
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if([defaults objectForKey:@"numberOfDaysPaid"]){
        //user used a brach link from a partner that paid for their membership
        _isGymMember = true;
    }else{
        //nothing stored in user defaults so check gym table in case
        PFQuery *query = [[PFQuery alloc] initWithClassName:@"GymMembers"];
        [query whereKey:@"userPhone" equalTo:_phone];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if([objects count] > 0){
                //results exist
                //this mesans that the user's phone number is already in the gymmembers table
                //which means THEY HAVE PAID...most likey a perry client
                _isGymMember = true;
                
                //set user default here for the number of days
                numberOfDaysPrepaid = objects[0][@"numberOfDaysPrepaid"];
        
                
            }else{
                _isGymMember = false;
            }
            
        }];

    }
    
}

-(void)makeProfiilePictureACircle{
    
    self.coachProfileImage.layer.cornerRadius = self.coachProfileImage.frame.size.width / 2;
    self.coachProfileImage.clipsToBounds = YES;
    self.coachProfileImage.layer.borderWidth = 4.0f;
    self.coachProfileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    
    
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    _cancelButtonPressed = YES;
    _replacedString = _messageTextView.text;
    
    _textfield1.hidden = true;
    //dismiss keyboard
    [_textfield1 resignFirstResponder];
    
    //nothing was entered show warning message
    [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"Are you sure you want to stop chatting? If you quit now, you will have to start over."];
    
    //go type the message YO
    [self showNextMessage];

    
}

- (IBAction)sendAnotherButtonPressed:(id)sender {
    
    //hide the button, then go back
    _sendAnotherCodeButton.hidden = true;
    
    //prepopulate the field with the phone last entered
    _textfield1.text = _phone;
    
    //for now, let's just go back to the last message
    _messageCount --;
    [self showNextMessage];
}

- (void)textFieldDidChange{
    NSLog(@"did change");
    
    if (_messageCount == 5) {
        //we are entering age
        if (_textfield1.text.length == 2) {
            
            //pause so the last digit appears in textview
            
            double delayInSeconds = 0.15;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                NSLog(@"Do some work");
                [_textfield1 resignFirstResponder];
                [self buttonPressed:_textfield1];

            });
            
            
        }
    }
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((CoachPageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((CoachPageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.coachUsers count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (CoachPageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.coachUsers count] == 0) || (index >= [self.coachUsers count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    CoachPageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"coachBioContent"];
    pageContentViewController.delegate = self;
    pageContentViewController.coachUserObject = self.coachUsers[index]; //LET'S SET A COACH USER HERE
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.coachUsers count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

// Implement the delegate methods for ChildViewControllerDelegate
- (void)childViewController:(CoachPageContentViewController *)viewController didChooseCoach:(PFUser *)coachUserSelected{
    NSLog(@"delegate called on coach card");
    
    
    // when a user selectes...'CHOOSE COACH' on one of the cards, this method is fired
    // we now have to coach that they selected AND we can dismiss the cards and continue with convo
    
    _coachUser = coachUserSelected;
    
    //convo
    _messageTextView.hidden = NO;

    _messageCount++;
    [self showNextMessage];
    

    _coachMatchImageView.layer.cornerRadius = _coachMatchImageView.bounds.size.width/2;
    _coachMatchImageView.clipsToBounds = YES;
    
    _memberMatchImageView.layer.cornerRadius = _coachMatchImageView.bounds.size.width/2;
    _memberMatchImageView.clipsToBounds = YES;
    
    //set container information for profile adding
    PFFile *coachImage = coachUserSelected[@"photo"];
    _coachMatchImageView.file = coachImage;
    [_coachMatchImageView loadInBackground];

    //first name label
    _coachNameLabel.text = coachUserSelected[@"firstName"];
    _memberNameLabel.text = [PFUser currentUser][@"firstName"];
    
    //fade in coach view
    
    [UIView animateWithDuration:0.5f animations:^{
        
        [_pageViewController.view setAlpha:0.0f];
        
    } completion:^(BOOL finished) {
        // ...then dismiss the child view controller
        [_pageViewController.view removeFromSuperview];
        
    }];
    
    NSDictionary *coachInfo = @{@"ID" : _coachUser.objectId,
                                @"Name" : _coachUser[@"firstName"]};
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Coach Chosen" properties:coachInfo];
    
}

#pragma mark - Image Picker

- (IBAction)addProfileImagePressed:(id)sender {
    //display image picker
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Choose Existing",@"Take Photo",nil];
    [actionSheet showInView:self.view];
    
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //You are looking at an action sheet
    //I make sure you are taken to the camera or the library
    NSLog(@"Action Sheet Pressed");
    
    if(buttonIndex == 0){
        //choose existing was pressed
        //show the library
        
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
    else if(buttonIndex == 1){
        //takephoto was pressed
        //show the camera
        self.imagePicker = [[UIImagePickerController alloc] init];
        self.imagePicker.delegate = self;
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //You finished selecting an image, whether through taking a pic or selecting
    //first dismiss the picker
    //then show the cropper to make it square
    NSLog(@"Image Selected");
    
    
    [picker dismissViewControllerAnimated:NO completion:^() {
        
        UIImage *portraitImg = [info objectForKey:UIImagePickerControllerOriginalImage];
        VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgCropperVC.delegate = self;
        [self presentViewController:imgCropperVC animated:YES completion:^{
            // TO DO
        }];
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Image Cropping
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    NSLog(@"Cropper View Controller Show");
    //image done selecting ********
    
    _addPhotoButton.hidden = true;
    
    self.image = editedImage;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // dismiss the image cropper
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera){
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        }
        
        CGFloat newSize = 100.0f; //this is the size of the square that we want
        self.image = [self squareImageFromImage:self.image scaledToSize:newSize];
        
        _memberMatchImageView.image = editedImage;
        NSLog(@"edited image is: %@", editedImage);
        _button1.hidden = NO;
        _dontShowProfileButton.hidden = YES;
        [self uploadPhotoToParse];
    }];
}

- (UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize {
    NSLog(@"Scaled to Size Called");
    
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height) {
        CGFloat scaleRatio = newSize / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    } else {
        CGFloat scaleRatio = newSize / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize, newSize);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)uploadPhotoToParse{
    //declasre a file datatype and a filename datatype
    NSData *fileData;
    NSString *fileName;
    UIImage *newImage = self.image; //lets try setting the new image to the image property that was set in the didfinishpickingimage method
    
    fileData = UIImagePNGRepresentation(newImage);
    fileName = @"image.png";
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    
    //save file
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Occured!"
                                                                message:@"File didn't save."
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
            // [self.activityIndicatorView stopAnimating];
            [alertView show];
            
        }
        else{
            //success, file is on parse.com
            PFUser *currentUser = [PFUser currentUser];
            [currentUser setObject:file forKey:@"photo"];
            //save parse object in background
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error){
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Occured!"
                                                                        message:@"Couldn't save the image to the user"
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                    //[self.activityIndicatorView stopAnimating];
                    [alertView show];
                }
                else{
                    //success
                    //[self reset];
                    //NSLog(@"hey");
                    
                }
                
            }];
            
        }
    }];
}


- (IBAction)dontWantCoachToSeePressed:(id)sender {
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Coaches can provide better value to you if they can see what you look like! Are you sure you don't want to add a picture?" delegate:self cancelButtonTitle:@"Okay, I'll Go Add One" otherButtonTitles:@"Yup", nil];
//    [alert show];
    
    //THIS DOES NOT CALL THE 'BUTTONPRESSED METHOD'
    //HIDE THE BIO VIEWS HERE. MAYBE ANIMATE **
    
   _coachMatchContainer.hidden = YES;
    _dontShowProfileButton.hidden = YES;
    _messageCount++;
    [self showNextMessage];
}

@end
