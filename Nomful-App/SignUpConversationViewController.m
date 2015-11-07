//
//  SignUpConversationViewController.m
//  Nomful
//
//  Created by Sean Crowe on 8/10/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "SignUpConversationViewController.h"

@interface SignUpConversationViewController ()

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
    
    _realCode = [[NSString alloc] init];
    
    [_nomberry setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self layoutNomberry];
    
    //set the messages
    
    _textfield1.delegate = self;
    // Add a "textFieldDidChange" notification method to the text field control.
    [_textfield1 addTarget:self
                  action:@selector(textFieldDidChange)
        forControlEvents:UIControlEventEditingChanged];
    _coachBioView.layer.cornerRadius = 6.0;
    _coachBioView.layer.shadowOffset = CGSizeMake(4, 4);
    _coachBioView.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    _coachBioView.layer.shadowRadius = 0.4f;
    _coachBioView.layer.shadowOpacity = 0.80f;

    
    _messagesArray = [[NSMutableArray alloc] initWithObjects:
                                                        @"Hi! Welcome to Nomful. My name is Nomberry.",
                                                        @"I'll help you get matched up with the perfect coach and together you'll work towards achieving your health goals.",
                                                        @"First, I'll need a little more info from you. Let's start with your full name",
                                                        @"placeholder 0",
                                                        @"Are you Male or Female?",
                                                        @"How old are you?",
                                                        @"Do you have a personal trainer?",
                                                        @"Placeholder 1",
                                                        @"If I need to email you, what is the best way to reach you? Don’t worry you won’t be spammed...I would never do that to you!",
                                                        @"Awesome! Thanks for all the information. I'm going to find you the perfect coach for you to team up with :)",
                                                        @"placeholder 2",
                                                        @"Enter your phone number and I'll text you a secret code.",
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
                         @"No, but I go to a gym!",
                         @"",
                         @"",
                         @"Can't Wait!",
                         @"Let's Do This!",
                         @"Send Code",
                         @"Login",
                         @"",
                         @"",
                         nil];
    

    //set the counter to 0.
    _messageCount = 0;
    _buttonLabelCount = 0;
    _hasTrainer = false;
    _noTrainer = false;
    _isGymMember = false;
    
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
                [_button2 setTitle:@"Energy Levels" forState:UIControlStateNormal];
            }
            if(_messageCount == 4){
                [_button2 setTitle:@"Female" forState:UIControlStateNormal];
            }
            if(_messageCount == 6){
                [_button2 setTitle:@"Nope" forState:UIControlStateNormal];
            }
            if(_messageCount == 10){
                [_button2 setTitle:@"Find Another Coach!" forState:UIControlStateNormal];
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
                NSString *meetYouString = [NSString stringWithFormat:@"Great to meet you %@! Tell me, which of the options below best describes your health goals?", _textfield1.text];
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
                    [_button2 setTitle:@"Energy Levels" forState:UIControlStateNormal];
                    [_button3 setTitle:@"Marathon Training" forState:UIControlStateNormal];
                    [_button4 setTitle:@"Gain Weight" forState:UIControlStateNormal];

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
                    
                    _messageCount ++;
                    
                    //no trainer yes gym = button1
                    [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"Great! Select your Gym below"];
                    [_notlistedbutton setTitle:@"My Gym Isn't Listed!" forState:UIControlStateNormal];
                    _getGymInstead = true;
                    
                    [self showNextMessage];

                }
                
                
                }break;
                
            case 7:{
                
                if(_noTrainer){
                    //users trainer not listed...they entered their name
                    NSLog(@"User's trainer's name is %@?", _textfield1.text);
                    
                    PFObject *collectName = [[PFObject alloc] initWithClassName:@"NameCollection"];
                    collectName[@"name"]=_textfield1.text;
                    [collectName saveEventually];
                    
                    //**do something here to capture trainer name!"//
                    
                    
                    
                    
                    _messageCount ++;
                    [self showNextMessage];
                    
                    _textfield1.text = @"";
                }
                
                }break;
                
            case 8:{
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
            
            case 9:{
                //I'm going to find you the perfect coach
        
                _messageCount++;
                [self animateNomberry];
                }break;
            
            case 10:{
            
                _coachBioView.hidden = YES;
                _messageTextView.hidden = NO;

                
                if(sender == _button1){
                    //Let's Do this!
                    _messageCount++;
                    [self showNextMessage];
                }
                else if (sender == _button2) {
                    //Find another coach
                    _findAnotherCoachSelected = true;

                    [self animateNomberry];
                }
                
                
                }break;
                
            case 11:{
                //send code
                NSLog(@"send sending code to: %@", _textfield1.text);

                
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
                                    [self checkIfGymMember]; //this is for the perry's of the world
                                    
                                    
                                    //clear textfield
                                    _textfield1.text = @"";
                                    _messageCount ++;
                                    [self showNextMessage];
                                    
                                }];
                            }else{
                                //again, you are here b/c we found other users with the phone number
                                //but we know it isn't the current user so we can allert them to try and log in or somehing
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh Oh!" message:@"Looks like your phone number is already in use. Please go back to home screen and select login, instead of Get Started" delegate:self cancelButtonTitle:@"Got it!" otherButtonTitles: nil];
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
                                [self checkIfGymMember]; //this is for the perry's of the world
                                
                                
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






//old button shtufffffffffffff
- (void)oldButtonPressed:(id)sender{
    
    
    ///old stuff
    if (_cancelButtonPressed) {
        if(sender == _button1){
            [self dismissViewControllerAnimated:YES completion:^{
                //do somethign
            }];
        }else{
            //continue with conversation
            [_messagesArray replaceObjectAtIndex:_messageCount withObject:_replacedString];
            _messageCount--;
            _buttonLabelCount--;
        }
    }
    
    if(_messageCount != 12){
        [self saveToAnonUser:sender];
        
        //incrememnt to next message
        _messageCount ++;
        _buttonLabelCount ++;
        
        //send button on keyboard pressed
        //so hide the textfield instead of button
        if(sender == _textfield1){
            NSLog(@"keyboard return");
            _textfield1.hidden = true;
        }else{
            //hide the button
            _button1.hidden = true;
            _button2.hidden = true;
            _button3.hidden = true;
            _button4.hidden = true;
        }
        
        //i have this here so that the label is changed BEFORE it becomes visible
        //we may have to differenciate this when more buttons are present
        [_button1 setTitle:[_buttonLabelArray objectAtIndex:_messageCount] forState:UIControlStateNormal];
        
        if(_messageCount == 3){
            //these titles must be the same name as what is in parse
            [_button2 setTitle:@"Energy Levels" forState:UIControlStateNormal];
            [_button3 setTitle:@"Marathon Training" forState:UIControlStateNormal];
            [_button4 setTitle:@"Gain Weight" forState:UIControlStateNormal];
        }
        if(_messageCount == 4){
            [_button2 setTitle:@"Female" forState:UIControlStateNormal];
        }
        if(_messageCount == 5){
            [_button2 setTitle:@"Nope!" forState:UIControlStateNormal];
            [_button3 setTitle:@"Yup!" forState:UIControlStateNormal];
        }
        if(_messageCount == 7){
            
            //what did they choose?
            
            
            if(sender == _button3){
                
                //add object to message array
                [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"Great! Select your trainer below"];
                
                
            }else if(sender == _button2 && !_cancelButtonPressed){
                //no trinter no gym = button2
                //go to next message
                
                _messageCount ++; //message count is now 8
                
            }else if(sender == _button1){
                //no trainer yes gym = button1
                [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"Great! Select your Gym below"];
                
            }
            
            
        }if(_messageCount == 8){
            //[_button2 setTitle:@"input button 8" forState:UIControlStateNormal];
        }
        if(_messageCount == 10){
            [_button2 setTitle:@"Pull The Other One" forState:UIControlStateNormal];
        }
        if(_messageCount == 11){
            _coachBioView.hidden = YES;
        }
        
        //don't start the timeer again when we go find the coach
        if(_messageCount != 10){
            //start timer for typing label
            self.timer = [NSTimer scheduledTimerWithTimeInterval:ktypeInterval target:self selector:@selector(typeIt) userInfo:nil repeats:YES];
        }else if( _messageCount == 10){
            [self animateNomberry];
        }else if(_messageCount == 7){
            NSLog(@"okay: ");
        }
    }else{
        [self saveToAnonUser:sender];
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
            
            
        }else if(_messageCount == 11){
            NSLog(@"send sending code to: %@", _textfield1.text);
            //save phone
            _phone = _textfield1.text;
            
            [PFUser currentUser][@"phoneNumber"] = _phone;
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                //cloud code uses the phoneNumber so we need to do this in a block
                //send twilio text
                [self sendCode];
                
            }];
            
        }else if(_messageCount == 12){
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
                        NSLog(@"success coach user is: %@", _coachUser);
                        
                        
                        //get and load coach image in background
                        PFFile *coachImage = _coachUser[@"photo"];
                        _newestCoachImage.file = coachImage;
                        [_newestCoachImage loadInBackground];
                        _newestCoachImage.layer.cornerRadius = _newestCoachImage.frame.size.width / 2;
                        _newestCoachImage.clipsToBounds = YES;

                        //set coach bio info
                        _coachBioTextView.text = _coachUser[@"bio"];
                        _coachNameLabel.text = [NSString stringWithFormat:@"%@ %@",[_coachUser valueForKey:@"firstName"], [_coachUser valueForKey:@"lastName"]];
                        
                        
                        NSLog(@"number of objects in array is: %lu", (unsigned long)[_messagesArray count]);
                        
                        
                        //You have found a coach
                        //stop animation
                        //return nomberry to top
                        [self nomberryLayoutAfterAnimation];
                        
                        
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
            _coachBioView.hidden = false;
            
            //show next message
            [self showNextMessage];
            
            
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
        
        if(_messageCount == 7){
            [_trainerTableView removeFromSuperview];
        }
        
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
            _textfield1.hidden = true;
            [self animateInputIn:_button1];
            [self animateInputIn:_button2];
            [self animateInputIn:_button3];
            
        }else if(_messageCount == 7){
            
            if(!_noTrainer){
                
                _textfield1.hidden = true;
                
                //show list of trainers or gyms here
                [self getAvailableTrainers];
                
                //add table view subview
                [self addTrainerTable];
            }
            
        }else if(_messageCount == 8){
            
            //age
            _textfield1.keyboardType = UIKeyboardTypeEmailAddress; //**for now leaving this out since we have ot add in a 'send' button that would normally be in the keyboard
            
            [_textfield1 becomeFirstResponder];
            _textfield1.hidden = false;
            
        }else if(_messageCount == 9){
            _textfield1.hidden = true;
            
            [self animateInputIn:_button1];
            
        }else if(_messageCount == 10){
            [self animateInputIn:_button2];
            [self animateInputIn:_button1];
        }else if (_messageCount == 11){
            //_textfield1.keyboardType = UIKeyboardTypeNumberPad;
            [_textfield1 becomeFirstResponder];
            _textfield1.hidden = false;
        }else if(_messageCount == 12 ){
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
    
    //when the trainer user is not set...go find a coach
    if(!_trainerUser){
        NSLog(@"trainer user not set");
        NSMutableArray *memberGoals = [[NSMutableArray alloc] init];
        memberGoals = [[PFUser currentUser] objectForKey:@"goals"];
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"goals" containedIn:memberGoals];
        [query whereKey:@"role" equalTo:@"RD"];
        NSArray *coaches = [query findObjects]; //**make this a background task! aka go figure out how background task works on image capture food log thingy
        
        if(_findAnotherCoachSelected){
            NSLog(@"number of coaches is: %lu", (unsigned long)[coaches count]);
            NSLog(@"i is: %lu", (unsigned long)_i);

            if (_i == [coaches count] - 1) {
                 _i--;
            }else{
                _i++;;
            }
        }
        
        //validation check to see if the query returned anything!
        NSLog(@"coach i is: %d", _i);
        _coachUser = coaches[_i];
        
        //create message and add to message array!
//        NSString *foundCoachString = [NSString stringWithFormat:@"Based on everything I know about you, I think %@ is giong to be an awesome fit :)", _coachUser[@"firstName"]];
//        [_messagesArray replaceObjectAtIndex:_messageCount withObject:foundCoachString];
        
        
        if(_coachUser){
            NSLog(@"coach block completed");
            compblock(YES);
        }else{
            compblock(NO);
        }
    }
    else{
        NSLog(@"Trainer user set");
        //trainer user is set...which means the user selected their trainer
        //go see if the trainer has a preferred coach
        
        //query
        PFQuery *query = [[PFQuery alloc] initWithClassName:@"TrainerDietitian"];
        [query whereKey:@"Trainer" equalTo:_trainerUser];
        NSArray *results = [query findObjects]; //***for whatever reason doing a background task here doesn't work....
        
        if([results count] > 0){
            //trainer has preferred coach
            
            //get the first results...should only be one anyway
            PFObject *trainerdiet = results[0];
            
            //get the user object from the table and fetch
            PFUser *coachUsers =  trainerdiet[@"DietitianUser"];
            [coachUsers fetch];
            
            //set the coachuser property to user!
            _coachUser = coachUsers;
            
            //create message and add to message array!
//            NSString *foundCoachString = [NSString stringWithFormat:@"Based on everything I know about you, I think %@ is giong to be an awesome fit :)", _coachUser[@"firstName"]];
//            [_messagesArray replaceObjectAtIndex:_messageCount withObject:foundCoachString];
//            
            //complete the block
            if(_coachUser){
                NSLog(@"coach block completed");
                compblock(YES);
            }else{
                compblock(NO);
            }

        }else{
            //trainer does not have prefereed coach
            
            NSMutableArray *memberGoals = [[NSMutableArray alloc] init];
            memberGoals = [[PFUser currentUser] objectForKey:@"goals"];
            
            PFQuery *query = [PFUser query];
            [query whereKey:@"goals" containedIn:memberGoals];
            [query whereKey:@"role" equalTo:@"RD"];
            NSArray *coaches = [query findObjects]; //**make this a background task! aka go figure out how background task works on image capture food log thingy
            
            //validation check to see if the query returned anything!
            _coachUser = coaches[0];
            
            //create message and add to message array!
//            NSString *foundCoachString = [NSString stringWithFormat:@"Based on everything I know about you, I think %@ is giong to be an awesome fit :)", _coachUser[@"firstName"]];
//            [_messagesArray replaceObjectAtIndex:_messageCount withObject:foundCoachString];
//            
//            
            if(_coachUser){
                NSLog(@"coach block completed");
                compblock(YES);
            }else{
                compblock(NO);
            }
        }
        
            }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

        if(_hasTrainer){
            trialVC.trainerUser = _trainerUser;
        }
        
        if(_getGymInstead){
            trialVC.gymObject = _gymObject;
        }
        
        NSLog(@"coach user %@", _coachUser);
        trialVC.coachUser = _coachUser;
        trialVC.titleString = @"10 day FREE TRIAL";
        trialVC.buttonString = @"Activate Trial";
        trialVC.stepOneString = @"Activate Trial";
        trialVC.isTrial = true;
    
    }
    
    if([segue.identifier isEqualToString:@"setExpectationsSegue"]){
        
        //prepaid users...aka perry
        
        TrialViewController *trialVC = [segue destinationViewController];
        trialVC.titleString = @"Next Steps";
        trialVC.buttonString = @"Let's Do This!";
        trialVC.stepOneString = @"Become Member - You've done this!!";
        
        
        //**not sure about this...perry use case
        if(_hasTrainer){
            trialVC.trainerUser = _trainerUser;
        }
        
        if(_getGymInstead){
            trialVC.gymObject = _gymObject;
        }
        
        NSLog(@"coach user %@", _coachUser);
        trialVC.coachUser = _coachUser;
        
    }
    
    ///toher
    if([segue.identifier isEqualToString:@"showCheckoutSegue"]){
        CheckoutViewController *vc = [segue destinationViewController];
        vc.coachUserFromSegue = _coachUser;
        vc.profileImage = _coachProfileImage.image;
        
        if(_hasTrainer){
            vc.trainerUser = _trainerUser;
        }
        
        if(_getGymInstead){
            vc.gymObject = _gymObject;
        }
    }
}


- (void)getAvailableTrainers{
    
    
    
    if(!_getGymInstead){
        PFQuery *query = [PFUser query];
        [query whereKey:@"role" equalTo:@"PT"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            
            NSLog(@"all the coaches are: %@", objects);
            
            _trainersArray = objects;
            [_trainerTableView reloadData];
            
            
        }];
    }else{
        PFQuery *gymQuery = [PFQuery queryWithClassName:@"Gym"];
        [gymQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            
            NSLog(@"all the gyms are: %@", objects);
            
            _trainersArray = objects;
            [_trainerTableView reloadData];
            
            
        }];
    }
   
    
   
}

- (void)addTrainerTable{
    
    
    if (_trainerTableView) {
        [_trainerTableView removeFromSuperview];
        _trainerTableView = nil;
    }
    
    _trainerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.bounds.size.height / 2) - 50, self.view.bounds.size.width, self.view.bounds.size.height / 2)];
    _trainerTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    _trainerTableView.backgroundColor = [UIColor whiteColor];
    _trainerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // must set delegate & dataSource, otherwise the the table will be empty and not responsive
    _trainerTableView.delegate = self;
    _trainerTableView.dataSource = self;
    
    [self.view addSubview:_trainerTableView];
    _noTrainerButton.hidden = false;
}


#pragma mark - TableView DataSource Implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    return [_trainersArray count]; // or other number, that you want

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *cellIdentifier = @"TrainerCell";
    
    // Similar to UITableViewCell, but
    trainerCell *cell = (trainerCell *)[_trainerTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[trainerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    cell.backgroundView = [[UIView alloc] init];
    [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
    [[[cell contentView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Make sure the constraints have been set up for this cell, since it
    // may have just been created from scratch. Use the following lines,
    // assuming you are setting up constraints from within the cell's
    // updateConstraints method: [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    //format after constraints set
    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2;
    cell.profileImage.clipsToBounds = YES;
    
    
    if(_getGymInstead){
        NSLog(@"gym cell");
        //show gym objects instead
        PFObject *gym = [_trainersArray objectAtIndex:indexPath.row];
        cell.nameLabel.text = gym[@"businessName"];
    }else{
        //trainers
        //show gym objects instead
        PFUser *trainer = [_trainersArray objectAtIndex:indexPath.row];
        [trainer fetchIfNeeded];
        NSString *fullName = [NSString stringWithFormat:@"%@%@",trainer[@"firstName"], trainer[@"lastName"]];
        cell.nameLabel.text = fullName;
        PFFile *imageFile = trainer[@"photo"];
        cell.profileImage.file = imageFile;
        [cell.profileImage loadInBackground];
    }
    
    // cell.cityLabel.text =
    
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
       return 60;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(_getGymInstead){
        _gymObject = [_trainersArray objectAtIndex:indexPath.row];
        NSLog(@"gym user is: %@", _gymObject);

    }else{
        //set the selected trainer to the traineruser property
        _trainerUser = [_trainersArray objectAtIndex:indexPath.row];
        NSLog(@"trainer user is: %@", _trainerUser);

    }
    
    //hide the table
    _trainerTableView.hidden = true;
    
    //set flag to true
    _hasTrainer = true;
    
    //show next message
    _messageCount ++;
    
    //start timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:ktypeInterval target:self selector:@selector(typeIt) userInfo:nil repeats:YES];

    _noTrainerButton.hidden = true;
}

#pragma mark - Image Cropping
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    NSLog(@"Cropper View Controller Show");
    
    self.image = editedImage;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // dismiss the image cropper
        if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera){
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
        }
        
        CGFloat newSize = 100.0f; //this is the size of the square that we want
        self.image = [self squareImageFromImage:self.image scaledToSize:newSize];
        
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
                                                [user signUpInBackground];
                                                // your app's userId, 127 chars or less
                                               
                                                
                                                
                                                if(_isGymMember){
                                                    NSLog(@"is gym member. probably perry client %d", _isGymMember);
                                                    
                                                    
                                                    //user has already paid!
                                                    //send them to a page to set expectations
                                                    
                                                    [self performSegueWithIdentifier:@"setExpectationsSegue" sender:self];
                                                    
                                                    [PFUser currentUser][@"planType"] = @"perry";
                                                    [[PFUser currentUser] saveEventually];
                                                    
                                                    //check to see if there is a user associated with the device for Push Notifications
                                                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                                                    //if(!currentInstallation[@"user"]){
                                                    //no user associated so make it!
                                                    currentInstallation[@"user"] = user;
                                                    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                        NSLog(@"You just saved the client user on the installation in parse");
                                                    }];

                                                    

                                                }else{
                                                    //basically what we're doing here is seeing if the user is supposed
                                                    //to get a trial or not and how long the trial is
                                                    
                                                    //that information is stored on the Gym table so if we have a gym
                                                    //object already, then we're good and can use that.
                                                    //If we have a  trainer object we can get the gym object from them.
                                                    [_gymObject fetchIfNeeded];
                                                    
                                                    if(!_trainerUser){
                                                        if(_gymObject[@"numberOfTrialDays"]){
                                                            [self performSegueWithIdentifier:@"showTrialView" sender:self];
                                                        }else{
                                                            [self performSegueWithIdentifier:@"showCheckoutSegue" sender:self];
                                                        }
                                                    }
                                                    
                                                    
                                                    if(_trainerUser){
                                                        
                                                        if(!_gymObject){
                                                            _gymObject = _trainerUser[@"employerObject"];
                                                        }
                                                        
                                                        [_gymObject fetchIfNeeded];
                                                        
                                                        
                                                        if(_gymObject[@"numberOfTrialDays"]){
                                                            [self performSegueWithIdentifier:@"showTrialView" sender:self];
                                                            
                                                        }else{
                                                            //no trial
                                                            [self performSegueWithIdentifier:@"showCheckoutSegue" sender:self];
                                                        }
                                                    }
                                                }
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

- (void)checkIfGymMember{
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"GymMembers"];
    [query whereKey:@"userPhone" equalTo:_phone];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if([objects count] > 0){
            //results exist
            //this mesans that the user's phone number is already in the gymmembers table
            //which means THEY HAVE PAID...most likey a perry client
            _isGymMember = true;
            
        }else{
            _isGymMember = false;
        }

    }];
    
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

    _coachBioView.hidden = YES;
    
    //nothing was entered show warning message
    [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"Are you sure you want to stop chatting? If you quit now, you will have to start over."];
    
    //go type the message YO
    [self showNextMessage];

    
}

- (IBAction)noTrainerButtonPressed:(id)sender {
    NSLog(@"No Trainer Button Presed");
    //the user is like....I don't see my trainer, but I have a trainer
    //we're like...bro you aren't using one of our trainer partners...what's the deal with that?
    //we're going to like, take the name of your trainer and your city and then reach out to them
    
    //the user will enter in trainer name and city they're in. Then will continue
    _noTrainer = true;
    
    if(!_getGymInstead){
        //change message
        [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"What's your trainers name?"];
    }else{
        [_messagesArray replaceObjectAtIndex:_messageCount withObject:@"What gym do you go to?"];

    }
    
    
    //go type the message YO
    [self showNextMessage];
    
    //hide button
    _noTrainerButton.hidden = true;
    
    //hide the trainer table
    [_trainerTableView removeFromSuperview];
    
    //show textfield
    _textfield1.hidden = false;
    [_textfield1 becomeFirstResponder];
    
    
    
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
            
            [_textfield1 resignFirstResponder];
            [self buttonPressed:_textfield1];

        }
    }
}
@end
