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

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"trail view controller did loaded");
    
    NSLog(@"current user is: %@", [PFUser currentUser]);
    NSLog(@"coach user is: %@", _coachUser);
    NSLog(@"trainer user is: %@", _trainerUser);
    NSLog(@"gym user is: %@", _gymObject);

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
        
        if(_isTrial){
            NSLog(@"trainer user ttrial");
            
            NSDate *now = [NSDate date];
            NSInteger daysInTrial = 10;
            NSDate *trialEndDate = [now dateByAddingTimeInterval:60*60*24*daysInTrial];
            
            //mark trial start date
            [PFUser currentUser][@"trialEndDate"] = trialEndDate;
            
            [PFUser currentUser][@"planType"] = @"trial"; //this can be either 'trial' 'intro' or 'bootcamp'
            
        }else if([[PFUser currentUser][@"planType"] isEqualToString:@"intro"]){
            NSDate *now = [NSDate date];
            NSInteger daysInTrial = 30; //30 days
            NSDate *trialEndDate = [now dateByAddingTimeInterval:60*60*24*daysInTrial];
            
            //mark trial start date
            [PFUser currentUser][@"trialEndDate"] = trialEndDate;
            
        }else if([[PFUser currentUser][@"planType"] isEqualToString:@"bootcamp"]){
            NSDate *now = [NSDate date];
            NSInteger daysInTrial = 84; //12 weeks
            NSDate *trialEndDate = [now dateByAddingTimeInterval:60*60*24*daysInTrial];
            
            //mark trial start date
            [PFUser currentUser][@"trialEndDate"] = trialEndDate;
        }else if([[PFUser currentUser][@"planType"] isEqualToString:@"perry"]){
            NSDate *now = [NSDate date];
            NSInteger daysInTrial = 100; //30 days
            NSDate *trialEndDate = [now dateByAddingTimeInterval:60*60*24*daysInTrial];
            
            //mark trial start date
            [PFUser currentUser][@"trialEndDate"] = trialEndDate;
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
        

    }];//end save chatroom object
    
}

- (void)sendPushNotifications{
    
    //send push notification to RD and PT
    PFUser *currentUser = [PFUser currentUser];
    
    //fetch for data...?
    [currentUser fetch];
    
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
    
    
    //register with Mixpanel
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:[PFUser currentUser].objectId];
    [mixpanel.people set:@{@"$first_name"    : [PFUser currentUser][@"firstName"],
                           @"$email"         : [PFUser currentUser].email}];

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
@end
