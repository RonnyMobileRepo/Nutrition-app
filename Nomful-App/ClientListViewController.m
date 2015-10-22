//
//  ClientListViewController.m
//  Nomful
//
//  Created by Sean Crowe on 6/19/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "ClientListViewController.h"
#import "AvailableClientTableViewCell.h"
//#import "Chatview.h"

@interface ClientListViewController ()

@end

@implementation ClientListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerWithMixpanel];
    
    //nav Bar style
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            //NSForegroundColorAttributeName: [UIColor greenColor],
                                                            NSFontAttributeName: [UIFont fontWithName:kFontFamilyName size:20.0f]                                                            }];
    
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0]];
    
    [self.navigationController.navigationBar setTitleTextAttributes: @{
                                                                       NSForegroundColorAttributeName:[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0]
                                                                       ,
                                                                       NSFontAttributeName: [UIFont fontWithName:kFontFamilyName size:21.0f],
                                                                       }];
    
    //add listener for local notification
    //this is fired when a client sends a messages AND the coach is in the app
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadObjects) name:@"updateBarButtonBadge" object:nil];
    
    //listen for the app re-entering the foreground
    //when coach does this...let's reload the table
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadObjects)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //reaload table when you come back from a view
    [self loadObjects];
}

- (id)initWithCoder:(NSCoder *)aCoder
{
    //init with coder since we are using storyboards
    self = [super initWithCoder:aCoder];
    if (self) {
        // The className to query on
        self.parseClassName = @"Chatrooms";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = NO;
        
    }
    return self;
}

- (PFQuery *)queryForTable
{
    //get current coach user
    PFUser *currentUser = [PFUser currentUser];
    [currentUser fetch];
    
    //query the chatroom calss
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    //admins get to see all
    if([currentUser[@"role"] isEqualToString:@"admin"]){
        [query orderByDescending:@"createdAt"];
        [query orderByDescending:@"isUnread"];
    }else if([currentUser[@"role"] isEqualToString:@"PT"]){
        //coaches only get to see their clients
        [query whereKey:@"trainerUser" equalTo:currentUser];
        [query includeKey:@"clientUser"];
        [query orderByDescending:@"isUnread"];
        [query orderByDescending:@"updatedAt"];
    }else if([currentUser[@"role"] isEqualToString:@"RD"]){
        [query whereKey:@"dietitianUser" equalTo:currentUser];
        [query includeKey:@"clientUser"];
        [query orderByDescending:@"isUnread"];
        [query orderByDescending:@"updatedAt"];
    }
    
    //returns all chatrooms with the coach user as the curernt user
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    //custom cell calss
    AvailableClientTableViewCell *cell = (AvailableClientTableViewCell * )[self.tableView dequeueReusableCellWithIdentifier:@"clientCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[AvailableClientTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clientCell"];
    }
    
    //get the client user from the chatroom object
    PFUser *clientUserObject = object[@"clientUser"];
    [clientUserObject fetchIfNeeded];
    
    // Configure PROFILE PICTURE
    //get the photo file form client user object
    PFFile *thumbnail = [clientUserObject objectForKey:@"photo"];
    
    //set the image view in our custom cell to the placeholder image while
    //the parse image is loading
    cell.profileImageView.image = [UIImage imageNamed:@"profilePlaceholder.png"];
    
    //if there is a profile file in parse...then set the imageview to that image
    //load that in the background
    if(thumbnail){
        //profile pic exists
        cell.profileImageView.file = thumbnail;
        [cell.profileImageView loadInBackground];
    }else{
        //no pic
        NSLog(@"no pfoile picture found");
    }
    
    // Configure name label
    //get full name from client user
    NSString *fullName = [[NSString alloc] initWithFormat:@"%@ %@",clientUserObject[@"firstName"], clientUserObject[@"lastName"]];
    
    //set name label to full name
    cell.nameLabel.text = fullName;
    cell.lastSeenLabel.text = clientUserObject[@"timezone"];
    
    //configure time left label
    if(clientUserObject[@"trialEndDate"]){
        NSDate *startDate = clientUserObject[@"trialEndDate"];
        NSDate *today = [NSDate date];
        
        NSInteger days = ([self daysBetweenDate:today andDate:startDate]);
        NSString *daysLeft = [[NSString alloc] init];
        
        if(days > 5){
            //still active
            daysLeft =  [NSString stringWithFormat:@"%ld days to renew", (long)days];
            cell.daysLeftLabel.textColor = [UIColor blackColor];
        }else if(days <= 5 && days > 0 ){
            //only three days left
            daysLeft =  [NSString stringWithFormat:@"%ld days to renew", (long)days];
            cell.daysLeftLabel.textColor = [UIColor redColor];
        }else if(days <= 0 ){
            //inactive user
            
            daysLeft = [NSString stringWithFormat:@"Account expired for %ld days", ABS(days)];
            cell.daysLeftLabel.textColor = [UIColor redColor];
        }
        cell.daysLeftLabel.text = daysLeft;
    }
    
    
        NSString *plan = [NSString stringWithFormat:@"%@ plan", clientUserObject[@"planType"]];
        cell.membershipLabel.text = plan;
    
    //    cell.membershipLabel.text = @"hey";
    //    PFQuery *sessionQuery = [PFQuery queryWithClassName:@"_Session"];
    //    [sessionQuery whereKey:@"user" equalTo:clientUserObject];
    //    [sessionQuery getFirstObjectInBackgroundWithBlock:^(PFObject *session, NSError *error){
    //        NSDate *lastSeen = session.updatedAt;
    //
    //        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    //        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    //        NSString *formattedDateString = [dateFormatter stringFromDate:lastSeen];
    //
    //        cell.lastSeenLabel.text = formattedDateString;
    //        NSLog(@"last seen at: %@", formattedDateString);
    //    }];
    //
    
    //set the tag for button pressed
    //if you choose the first clients messages vs the fourth clients messages this is
    //what differentiates them from eachother
    cell.chatButton.tag = indexPath.row;
    cell.mealButton.tag = indexPath.row;
    cell.accountButton.tag = indexPath.row;
    
    //get the unread flag from parse as a number
    NSNumber *isUnreadNum = object[@"isUnread"];
    
    //convert to a bool
    bool isUnreadBool = [isUnreadNum boolValue];
    
    //if the bool is true then there is an unread message
    //therefore we want to show the indicator
    if(isUnreadBool){
        //there is an unread message in this chatroom
        cell.chatButton.badgeValue = @"1";
    }
    if(!isUnreadBool){
        //there are no unread messages in this chatroom...make sure inidcator is gon
        cell.chatButton.badgeValue = @"";
    }
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIButton *senderButton = sender;
    
    if([segue.identifier isEqualToString:@"listToDetailSegue"]){
        NSLog(@"Meal segue called");
        ClientCollectionViewController *vc = [segue destinationViewController];
        vc.chatroomObject = [self.objects objectAtIndex:senderButton.tag];
    }
    else if([segue.identifier isEqualToString:@"listToChat"]){
        MessagesViewController *vc = [segue destinationViewController];
        vc.delegates = self;
        vc.chatroomObjectFromList = [self.objects objectAtIndex:senderButton.tag];
        vc.youAreDietitian = true;
        
            }
    else if([segue.identifier isEqualToString:@"showAccount"]){
        UserAccountViewController *vc = [segue destinationViewController];
        vc.chatroomObject = [self.objects objectAtIndex:senderButton.tag];
    }
    
}


- (IBAction)chatButtonPressed:(UIButton*)button {
    
    PFObject *chatroom = [self.objects objectAtIndex:button.tag];
    
    //if we're using the old messaging then double check if chat is updated
    [chatroom fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        //
        if ([object[@"upgradedToFirebase"] isEqualToString:@"Yes"]) {
            //go to firebase
            Chatview *chatview = [[Chatview alloc] initWith:object.objectId];
            [self.navigationController pushViewController:chatview animated:YES];
            
        }else{
            [self performSegueWithIdentifier:@"listToChat" sender:button];
        }
        
        
    }];


}

- (IBAction)mealsButtonPressed:(UIButton*)button
{
    [self performSegueWithIdentifier:@"listToDetailSegue" sender:button];
    
}

- (IBAction)accountButtonPressed:(UIButton*)button {
    [self performSegueWithIdentifier:@"showAccount" sender:button];
    
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

- (void)_refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    [self loadObjects];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel identify:[PFUser currentUser].objectId];

    [mixpanel track:@"Pulled-to-refresh" properties:@{
        @"numberOfClients": @7
    }];

}

- (void)registerWithMixpanel{
    

    
}
@end
