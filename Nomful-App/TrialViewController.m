//
//  TrialViewController.m
//  Nomful
//
//  Created by Sean Crowe on 8/27/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "TrialViewController.h"

@interface TrialViewController (){
    
    bool isChecked;
}

@end

@implementation TrialViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"trail view controller did loaded");
    
    NSLog(@"current user is: %@", [PFUser currentUser]);
    NSLog(@"coach user is: %@", _coachUser);
    NSLog(@"trainer user is: %@", _trainerUser);

    _contentView.layer.cornerRadius = 4.0;
    _activateButton.layer.cornerRadius = 4.0;
    
    _titleLabel.text = _titleString;
    [_activateButton setTitle:_buttonString forState:UIControlStateNormal];
    _stepOneLabel.text = _stepOneString;
    
    BOOL userIsAnonymous = [PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]];
    
    if(userIsAnonymous){
        [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
            if (error) {
                NSLog(@"Anonymous login failed.");
            } else {
                NSLog(@"Anonymous user logged in.");
            }
        }];
    }
    
    
    //this is the point where the users is totally verified
    //we can now tell mixpanel our unique identifier is what will be used from now on
    //alias just says the objectid will associate the anonymous mixpanel user now :)
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Membership Started"];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation


- (IBAction)activateButtonPressed:(id)sender {
    
    if(isChecked){
        //button is checked...we good
        [_activityIndicator startAnimating];
        
        //create chatroom
        [self buildChatroom];
        
        [self activatePushNotification];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];

        
        if(_isTrial){
            //isTrial is sent from the signup VC
            NSLog(@"User is on trial. so we set end date for 3 days from now");
            
            NSDate *now = [NSDate date];
            NSInteger daysInTrial = 3;
            NSDate *trialEndDate = [now dateByAddingTimeInterval:60*60*24*daysInTrial];
            
            //mark trial start date
            [PFUser currentUser][@"trialEndDate"] = trialEndDate;
            
            [PFUser currentUser][@"planType"] = @"trial"; //this can be either 'trial' 'intro' or 'bootcamp'
            
            [mixpanel.people set:@{@"MemberhipEndDate": trialEndDate}];
            
        }else if([[PFUser currentUser][@"planType"] isEqualToString:@"prepaid"]){
            //user has been prepaid for...we must go find out how many days
            //this can either be from the link clicked...or from GymMember table
            
            
            NSDate *now = [NSDate date];
            NSInteger prepaidDays = 30; //30 days as default

            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if([defaults objectForKey:@"numberOfDaysPaid"]){
                
                int numberOfDaysPaid = [[defaults objectForKey:@"numberOfDaysPaid"] intValue];
                prepaidDays = numberOfDaysPaid;
            
            }
            
            NSDate *trialEndDate = [now dateByAddingTimeInterval:60*60*24*prepaidDays];
            
            //mark trial start date
            [PFUser currentUser][@"trialEndDate"] = trialEndDate;
            
            [mixpanel.people set:@{@"MemberhipEndDate": trialEndDate}];

            
        }else if([[PFUser currentUser][@"planType"] isEqualToString:@"bootcamp"]){
            NSDate *now = [NSDate date];
            NSInteger daysInTrial = 84; //12 weeks
            NSDate *trialEndDate = [now dateByAddingTimeInterval:60*60*24*daysInTrial];
            
            //mark trial start date
            [PFUser currentUser][@"trialEndDate"] = trialEndDate;
            [mixpanel.people set:@{@"MemberhipEndDate": trialEndDate}];

        }else if([[PFUser currentUser][@"planType"] isEqualToString:@"intro"]){
            NSDate *now = [NSDate date];
            NSInteger daysInTrial = 21; //12 weeks
            NSDate *trialEndDate = [now dateByAddingTimeInterval:60*60*24*daysInTrial];
            
            //mark trial start date
            [PFUser currentUser][@"trialEndDate"] = trialEndDate;
            [mixpanel.people set:@{@"MemberhipEndDate": trialEndDate}];

        }
        
        [[PFUser currentUser] saveEventually];

    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Terms and Conditions" message:@"Please agree to our terms and conditions before activiting!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
    }
    
}

- (void)buildChatroom{
    //let's build the chatroom and then segue when done
    
    //user has gone through the signup flow
    //this means they have an assigned coach
    //and they may or may not have a trainer
    //let' s build the chatroom object now
    
    //_coachUser
    //_trainerUser
    
    
    PFObject *chatroom = [PFObject objectWithClassName:@"Chatrooms"];
    
    //set the client, RD, and PT
    [chatroom setObject:[PFUser currentUser] forKey:@"clientUser"];
    [chatroom setObject:_coachUser forKey:@"dietitianUser"];
    [chatroom setObject:@"Yes" forKey:@"upgradedToFirebase"];

    
    if(_trainerUser){
        [chatroom setObject:_trainerUser forKey:@"trainerUser"];
    }
    
    //set chatroom as unread for coach!
    NSNumber *isUnreadNum = [[NSNumber alloc] initWithBool:true];
    chatroom[@"isUnread"] = isUnreadNum;
    
    //save the chatroom in background
    [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        
        //go home
        [self performSegueWithIdentifier:@"loginSegue" sender:self];
        
        [self sendPushNotifications];
        
        //set twilio number
        [self setTwilioNumber:chatroom coachuser:_coachUser];
        
        [self sendFirstMessage:chatroom];

    }];//end save chatroom object
    
}

- (void)sendPushNotifications{
    
    //send push notification to RD and PT
    PFUser *currentUser = [PFUser currentUser];
    
    //fetch for data...?
    [currentUser fetchIfNeeded];
    
    //build array of who is getting the push sent to them
    NSArray *pushUsers = @[_coachUser];
    
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

- (void)activatePushNotification{
    //check to see if there is a user associated with the device for Push Notifications
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation[@"user"] = [PFUser currentUser];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"You just saved the client user on the installation in parse");
    }];
    
}
- (IBAction)termsButtonPressed:(id)sender {
    
    
    if(!isChecked){
        [_termsButton setBackgroundImage:[UIImage imageNamed:@"box_checked"] forState:UIControlStateNormal];
        isChecked = YES;
    }else{
        [_termsButton setBackgroundImage:[UIImage imageNamed:@"box_empty"] forState:UIControlStateNormal];
        isChecked = NO;
    }
   
}

- (void)sendFirstMessage:(PFObject *)chatroom{

    /////////////////////////////////////
    //BUILD MESSAGE TO SEND TO FIREBASE//
    /////////////////////////////////////
    
    NSString *gender1;
    NSString *gender2;
    
    NSString *firstName = _coachUser[@"firstName"];
    
    if ([_coachUser[@"gender"] isEqualToString:@"m"]) {
        //female
        gender1 = @"him";
        gender2 = @"He";
    }else{
        gender1 = @"her";
        gender2 = @"She";
    }
    //set the text we want it to be
 
    NSString *text = [[NSString alloc] initWithFormat:@"Welcome to Nomful! This is where you will communicate with your coach, %@ :) I let %@ know that you're all signed up and ready to go! %@ will reach out to you today and set up a phone call so you can get to know eachother. In the meantime you can start taking photos of your foods for %@ to review!",firstName, gender1, gender2, firstName];
    
    //build firebase json? object
    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    item[@"userId"] = @"7zMGN960nO"; //prod 7zMGN960nO //dev 9EZw4s8feD
    item[@"name"] = @"Nomberry";
    item[@"date"] = [self Date2String:[NSDate date]];
    item[@"status"] = @"Delivered"; //*this is the string that show up on each message underneath...timestamp instead?
    item[@"video"] = item[@"thumbnail"] = item[@"picture"] = item[@"audio"] = item[@"latitude"] = item[@"longitude"] = @"";
    item[@"video_duration"] = item[@"audio_duration"] = @0;
    item[@"picture_width"] = item[@"picture_height"] = @0;
    item[@"text"] = text;
    item[@"type"] = @"text";

    //send to firebase feed
    Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Message/%@", kFirechatNS, chatroom.objectId]];
    Firebase *reference = [firebase childByAutoId];
    item[@"messageId"] = reference.key;
    
    [reference setValue:item withCompletionBlock:^(NSError *error, Firebase *ref)
     {
         if (error != nil) NSLog(@"Outgoing sendMessage network error.");
     }];

    //////////////////////////////////////////
    //SEND PUSH NOTIFICATION TO CURRENT USER//
    //////////////////////////////////////////
    
    //send push notification
    //send push notification to RD and PT
    PFUser *currentUser = [PFUser currentUser];
    
    //fetch for data...?
    [currentUser fetch];
    
    //build array of who is getting the push sent to them
    NSArray *pushUsers = @[currentUser];
    
    //build push query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" containedIn:pushUsers];
    
    //build push string
    NSString *name = [NSString stringWithFormat:@"Welcome to Nomful %@! Glad you've joined us. ", currentUser[@"firstName"]];
    
    //set data for push
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          name, @"alert",
                          @1, @"badge",
                          @"message", @"type",
                          nil];
    
    //new push object
    PFPush *push = [[PFPush alloc] init];
    
    //set data and send
    [push setQuery:pushQuery];
    [push setData:data];
    
    //send
    [push sendPushInBackground];
    
    ///////////////////////////////
    //SEND FIRST TIME LOGIN EMAIL//
    ///////////////////////////////
    
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

    
}

-(NSString*)Date2String:(NSDate *)date

{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [formatter stringFromDate:date];
}

@end
