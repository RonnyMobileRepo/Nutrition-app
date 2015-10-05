//
//  AvailableClientsTableViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 2/20/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "AvailableClientsTableViewController.h"
#import "AvailableClientTableViewCell.h"
#import "Chatview.h"

@interface AvailableClientsTableViewController ()

@end

@implementation AvailableClientsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            //NSForegroundColorAttributeName: [UIColor greenColor],
                                                            NSFontAttributeName: [UIFont fontWithName:kFontFamilyName size:20.0f]                                                            }];
    
    self.avatarsArray = [[NSMutableArray alloc] init];
    
    [self updateAvailableList];
    // Initialize the refresh control.
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateAvailableList) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = self.refreshControl;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateAvailableList)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNomBadge) name:@"updateNomBadge" object:nil];
    
}

- (void)updateNomBadge{
    
    
    UIAlertView *cameralert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"The main functionality of Nomful is a camera to snap photos of meals. Please use a device with a camera for the best experience. :)" delegate:self cancelButtonTitle:@"Got It!" otherButtonTitles: nil];
    [cameralert show];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //
 
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0]];
    
    [self.navigationController.navigationBar setTitleTextAttributes: @{
                                                                       NSForegroundColorAttributeName:[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0]
,
                                                                       NSFontAttributeName: [UIFont fontWithName:kFontFamilyName size:21.0f],
                                                                       }];
   
    [self updateAvailableList];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.availableChatsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AvailableClientTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clientCell" forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *currentChatObject = [[PFObject alloc] initWithClassName:@"Chatrooms"];
    currentChatObject = [self.availableChatsArray objectAtIndex:indexPath.row];
    NSLog(@"current chat object: %@", currentChatObject);
    PFUser *currentUserObject = currentChatObject[@"clientUser"];
    NSLog(@"current user object: %@", currentUserObject);

    NSNumber *isUnreadNum = currentChatObject[@"isUnread"];
    bool isUnreadBool = [isUnreadNum boolValue];
    
    cell.accountButton.tintColor = [UIColor whiteColor];
    //set the button tag to the indexPath it is contained in
    cell.chatButton.tag = indexPath.row;
    
    //execute method when button is pressed
    [cell.chatButton addTarget:self action:@selector(chatButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //meal buttton
    cell.mealButton.tag = indexPath.row;
    [cell.mealButton addTarget:self action:@selector(mealButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //account button
    cell.accountButton.tag = indexPath.row;
    [cell.accountButton addTarget:self action:@selector(showAccount:) forControlEvents:UIControlEventTouchUpInside];
    
    if(isUnreadBool){
        //there is an unread message in this chatroom
        //cell.indicatorImageView.hidden = NO;
    }
    if(!isUnreadBool){
        //there are no unread messages in this chatroom...make sure inidcator is gon
        //cell.indicatorImageView.hidden = YES;
    }
    [currentUserObject fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        NSString *fullName = [[NSString alloc] initWithFormat:@"%@ %@",object[@"firstName"], object[@"lastName"]];
        
        cell.nameLabel.text = fullName;
        
        PFFile *userImageFile = object[@"photo"];
        
            
        [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            
            if (!error) {
                
                NSLog(@"getting file");
                UIImage *image = [UIImage imageWithData:imageData];
                cell.profileImageView.image = image;
            }
        }];
    }];

    
    return cell;
}


- (void)chatButtonPressed:(UIButton*)button{
    NSLog(@"chat button pressed");
    
    PFObject *chatroom = [self.availableChatsArray objectAtIndex:button.tag];
    Chatview *chatview = [[Chatview alloc] initWith:chatroom.objectId];
    
    [self presentViewController:chatview animated:YES completion:^{
        //presentation successful
    }];

    
    //[self performSegueWithIdentifier:@"listToChat" sender:button];
    
}

-(void)mealButtonPressed:(UIButton*)button{

    [self performSegueWithIdentifier:@"listToDetailSegue" sender:button];
}
-(void)showAccount:(UIButton *)button{
    
    [self performSegueWithIdentifier:@"showAccount" sender:button];
}

#pragma mark - Navigation

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    UIButton *senderButton = [[UIButton alloc] init];
//    senderButton.tag = 0;
    
    //[self performSegueWithIdentifier:@"listToChat" sender:senderButton];
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        UIButton *senderButton = sender;
    
    if([segue.identifier isEqualToString:@"listToChat"]){
        NSLog(@"CHAT segue called. Sender tag is: %ld", (long)senderButton.tag);
        
//        PFObject *chatroom = [self.availableChatsArray objectAtIndex:senderButton.tag];
//        Chatview *chatview = [[Chatview alloc] initWith:chatroom.objectId];
//        
//        [self presentViewController:chatview animated:YES completion:^{
//            //presentation successful
//        }];
        
        
    }else if([segue.identifier isEqualToString:@"listToDetailSegue"]){
        NSLog(@"Meal segue called");
        ClientCollectionViewController *vc = [segue destinationViewController];
        vc.chatroomObject = [self.availableChatsArray objectAtIndex:senderButton.tag];
    }else if([segue.identifier isEqualToString:@"showAccount"]){
        UserAccountViewController *vc = [segue destinationViewController];
        vc.chatroomObject = [self.availableChatsArray objectAtIndex:senderButton.tag];
    }
    
}

- (IBAction)pushMyNewViewController
{
    
}

#pragma mark - Sean Added yay

-(void)updateAvailableList{
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Chatrooms"];
    
    if([currentUser[@"role"] isEqualToString:@"RD"]){
        //if the current user is an RD, then search the dietitian field in chatroom
        NSLog(@"Available Clients TVC: You are an RD and are about to query for RDs");
        [query whereKey:@"dietitianUser" equalTo:[PFUser currentUser]];

    }else if([currentUser[@"role"] isEqualToString:@"PT"]){
        //if the current user is a PT, then search the trainer field in chatroom
        NSLog(@"Available Clients TVC: You are an PT and are about to query for PT");

        [query whereKey:@"trainerUser" equalTo:[PFUser currentUser]];
    }else if([currentUser[@"role"] isEqualToString:@"admin"]){
        //query all the chatrooms
    }
        [query whereKeyDoesNotExist:@"ptRemoved"];
        [query orderByDescending:@"createdAt"];
        [query orderByDescending:@"isUnread"];
        //[query includeKey:@"clientUser"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //go find all chatrooms where the dietitian user is the current user
        //this is okay since the only users that can access this page have the dietitian role
        
        self.availableChatsArray = [objects mutableCopy];
        
        //go make the array of avatars
        //[self getAvatars];
        
        NSLog(@"available chats is: %@", self.availableChatsArray);
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
    
}


- (void)getAvatars{
    NSLog(@"loading avatars");
    
   
    
    for(PFObject *object in self.availableChatsArray){
        int i;
        
        //get a local copy of the client user for the chatroom
        PFUser *user = object[@"clientUser"];
        PFFile *userImageFile = user[@"photo"];
        
        if(userImageFile){
            
            [userImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                
                if (!error) {
                    
                    NSLog(@"getting file");
                    UIImage *image = [UIImage imageWithData:imageData];
                    [self.avatarsArray addObject:image];
                    
                    
                }
            }];
        }
        
        i++;
        if(i == self.availableChatsArray.count){
            [self.tableView reloadData];
        }
        
    }//end for loop
    
}


@end
