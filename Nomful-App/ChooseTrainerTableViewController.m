//
//  ChooseTrainerTableViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 3/24/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "ChooseTrainerTableViewController.h"
#import "ChooseTrainerTableViewCell.h"

@interface ChooseTrainerTableViewController ()

@end

@implementation ChooseTrainerTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadTrainers];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    
    
   }


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.trainersArray.count + 1;
}


- (void)loadTrainers{
    NSLog(@"Trainers Are Being Loaded: %@", self.gymObject);
    
    PFQuery *trainerQuery = [PFUser query];
    [trainerQuery whereKey:@"role" equalTo:@"PT"];
    [trainerQuery whereKey:@"employerObject" equalTo:self.gymObject];
    [trainerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       //all PTs are stored in 'objects'
        
        self.trainersArray = [objects mutableCopy];
        [self.tableView reloadData];
        //[self getAvatars];
        NSLog(@"The number of trainers is: %lu", (unsigned long)objects.count);
    }];
}

- (void)getAvatars{
    NSLog(@"Loading avatars");
    
    for (PFObject *singleTrainerUser in self.trainersArray) {
        
        PFFile *userImageFile = singleTrainerUser[@"photo"];
        
        if(userImageFile){ //if there is data for the photo...go to parse and get the image
            [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    NSLog(@"getting file");
                    UIImage *image = [UIImage imageWithData:imageData];
                    [self.trainerAvatarsArray addObject:image];
                    [self.tableView reloadData];
                }
            }];
        }
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"firstCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        return cell;
    }else{

        ChooseTrainerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trainerCell" forIndexPath:indexPath];
 
    
        PFUser *currentTrainer = [self.trainersArray objectAtIndex:indexPath.row -1];
        PFObject *employerObject = currentTrainer[@"employerObject"];
        [employerObject fetchIfNeeded];
        
        PFFile *userImageFile = currentTrainer[@"photo"];
    
        [userImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            //*** We can display an activity indicator if we want!!!!
    
            UIImage *image = [UIImage imageWithData:data];
            cell.trainerImageView.image = image;
        
            //end theoretical activity indicator
        }];
    

        
        //set labels
        cell.trainerNameLabel.text = currentTrainer[@"firstName"];
        cell.trainerEmployerLabel.text = employerObject[@"businessName"];
    
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Are you sure this is your personal trainer?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
    
    [alert show];
    self.ptUser = [self.trainersArray objectAtIndex:indexPath.row - 1];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        //[self performSegueWithIdentifier:@"selectedPTSegue" sender:self];
        [self buildChatroom];
        
        UIAlertView *welcomeMessage = [[UIAlertView alloc] initWithTitle:@"Welcome!!" message:@"This is where you can log your meals by snapping a quick photo. In the upper right, you will find your conversation with a live nutrition expert! Have fun and enjoy eating :)"  delegate:nil cancelButtonTitle:@"Got it!" otherButtonTitles:nil, nil];
        [welcomeMessage show];
    }
}

- (void)buildChatroom{
    //the user selected a pt and confirmed the selection
    //let's build the chatroom and then segue when done
    
    //let's query the Trainer/Dietitian to see which rD is paired up with the selected trainer
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"TrainerDietitian"];
    [query whereKey:@"Trainer" equalTo:self.ptUser];
    
    //get a TRAINER/DIETITIAN object in the background
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        if(!error){
            //if no errors, set a variable to the dietitian user
            PFUser *dietitianUser = object[@"DietitianUser"];
            
            //let' s build the chatroom object now
            PFObject *chatroom = [PFObject objectWithClassName:@"Chatrooms"];
            
            //set the client, RD, and PT
            [chatroom setObject:[PFUser currentUser] forKey:@"clientUser"];
            [chatroom setObject:dietitianUser forKey:@"dietitianUser"];
            [chatroom setObject:self.ptUser forKey:@"trainerUser"];
            NSNumber *isUnreadNum = [[NSNumber alloc] initWithBool:true];
            chatroom[@"isUnread"] = isUnreadNum;
            
            //save the chatroom in background
            [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                //...now we can segue to next screen
                [self performSegueWithIdentifier:@"trainerSelectedSegue" sender:self];
                
                [self setTwilioNumber:chatroom coachuser:dietitianUser];
                
                //send push notification to RD and PT
                PFUser *trainerUser =   self.ptUser;
                PFUser *currentUser = [PFUser currentUser];
                
                //fetch for data...?
                [trainerUser fetch];
                [currentUser fetch];
                
                //build array of who is getting the push sent to them
                NSArray *pushUsers = @[dietitianUser,
                                       trainerUser];
                
                //build push query
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"user" containedIn:pushUsers];
                
                //build push string
                NSString *name = [NSString stringWithFormat:@"You have a new client! Say hi to %@ :)", currentUser[@"firstName"]];
                
                //set data for push
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      name, @"alert",
                                      @"default", @"sound",
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
        }//end error check
        else{
            //error when looking for the PT/RD pair
            //do something
            
            //ALL OF THE ABOVE ASSUMES THAT THERE IS A MATCH IN THE PT/RD TABLE///
            //if trainer has no preferred RD...then random
            
            
            [self randomRD];
            

        }//end else
    }];//end get dietitian/trainer object


}

- (void)randomRD{
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
        [chatroom setObject:self.ptUser forKey:@"trainerUser"];

        NSNumber *isUnreadNum = [[NSNumber alloc] initWithBool:true];
        chatroom[@"isUnread"] = isUnreadNum;
        
        //save the chatroom in background
        [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            NSLog(@"chat saved");
            
            [self performSegueWithIdentifier:@"trainerSelectedSegue" sender:self];
            
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
@end
