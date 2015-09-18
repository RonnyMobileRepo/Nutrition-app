//
//  ProgressViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 4/18/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "ProgressViewController.h"

@interface ProgressViewController ()

@end

@implementation ProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.congratsLabel.alpha = 0;
    self.trainerLabel.alpha = 0;
    self.yesButton.alpha = 0;
    self.noButton.alpha = 0;
    
    //yestbutton
    [self.yesButton.layer setBorderWidth:2];
    self.yesButton.layer.cornerRadius = 4;
    [self.yesButton.layer setBorderColor:[[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0] CGColor]];
    
    //no butotn
    [self.noButton.layer setBorderWidth:2];
    self.noButton.layer.cornerRadius = 4;
    [self.noButton.layer setBorderColor:[[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0] CGColor]];
    self.noButton.titleLabel.textColor = [UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0];

    
    self.pieView.primaryColor = [UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0];
    self.pieView.secondaryColor = [UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0];
    //query for gym object
    [self getGymObject];
    
}

- (void)getGymObject{
    PFQuery *query = [PFQuery queryWithClassName:@"GymMembers"];
    [query whereKey:@"clientObject" equalTo:[PFUser currentUser]];
    [query includeKey:@"GymObjects"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        self.gymObject = object;
        self.GymObjects = object[@"GymObjects"];

        PFUser *currentUser = [PFUser currentUser];
        
        //build string for trainer question label
        NSString *trainerMessage = [[NSString alloc] initWithFormat:@"%@, do you currently have a trainer at %@?", currentUser[@"firstName"], self.GymObjects[@"businessName"]];
        
        self.trainerLabel.text = trainerMessage;

        
        [self performSelector:@selector(setQuarter) withObject:Nil afterDelay:.25];

     }];
    
}

- (void)setQuarter
{
    [self.pieView setProgress:.25 animated:YES];
    [self performSelector:@selector(setTwoThirds) withObject:nil afterDelay:.75];
}

- (void)setTwoThirds
{
    [self.pieView setProgress:.66 animated:YES];
    [self performSelector:@selector(setThreeQuarters) withObject:nil afterDelay:.5];
}

- (void)setThreeQuarters
{
    [self.pieView setProgress:.75 animated:YES];
    [self performSelector:@selector(setOne) withObject:nil afterDelay:.5];
}

- (void)setOne
{
    [self.pieView setProgress:1.0 animated:YES];
    [self performSelector:@selector(setComplete) withObject:nil afterDelay:self.pieView.animationDuration + .1];
}

- (void)setComplete
{
    [self.pieView performAction:M13ProgressViewActionSuccess animated:YES];
    
    //load the contrats label below the checkmark
    [UIView animateWithDuration:2.0
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{self.congratsLabel.alpha = 1.0;}
                     completion:^(BOOL finished) {
                         
                         
                         [self performSelector:@selector(loadTrainerViews) withObject:nil afterDelay:3];
                        
                         [self loadTrainerViews];
                     }];
    
}



- (void)loadTrainerViews{
    
    //fade out the pie and the congrats lable
    [UIView animateWithDuration:0.38
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         
                        self.pieView.alpha = 0.0;
                        self.congratsLabel.alpha = 0.0;
                     
                     }
                     completion:^(BOOL finished) {
                         
                         //fade IN the trainer question label
                         [UIView animateWithDuration:0.75
                                               delay:0.0
                                             options: UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              self.trainerLabel.alpha = 1.0;
                                              self.yesButton.alpha = 1.0;
                                              self.noButton.alpha = 1.0;
                                          
                                          }
                                          completion:^(BOOL finished) {
                                              
                                              
                                          }];

                     }];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"yesTrainer"]) {
        //user selected yse
        ChooseTrainerTableViewController *vc = [segue destinationViewController];
        PFObject *gymObject = self.gymObject[@"GymObjects"];
        
        vc.gymObject = gymObject;
    }
    else if([segue.identifier isEqualToString:@"noTrainer"]){
        //user selected no
        //we must build the chatroom then
        [self buildChatroom];
        
        UIAlertView *welcomeMessage = [[UIAlertView alloc] initWithTitle:@"Welcome!!" message:@"This is where you can log your meals by snapping a quick photo. In the upper right, you will find your conversation with a live nutrition expert! Have fun and enjoy eating :)"  delegate:nil cancelButtonTitle:@"Got it!" otherButtonTitles:nil, nil];
        [welcomeMessage show];
    }
    
}

- (void)buildChatroom{
    //the user selected NO pt
    //let's build the chatroom and then segue when done
    //no coach user

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
            
            [self setTwilioNumber:chatroom coachuser:userSelected];
            
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
                                  @"default", @"sound",
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
            
        }];//end save chatroom object
    }];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
