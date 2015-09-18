//
//  ChatViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 2/25/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "ChatViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)callButtonPressed:(id)sender {
    NSLog(@"User selected to call the dietitain!");
    
    PFQuery *query = [PFQuery queryWithClassName:@"Chatrooms"];
    [query includeKey:@"dietitianUser"];
    [query whereKey:@"clientUser" equalTo:[PFUser currentUser]];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
    
        if(!error){
            NSLog(@"Success! You have found the chatroom object");
            PFUser *rdUserObject = object[@"dietitianUser"];
            NSString *rdPhone = rdUserObject[@"phoneNumber"];
            NSLog(@"phone is %@", rdPhone);
            NSString *phoneNumber = [@"tel://" stringByAppendingString:rdPhone];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            
            }
        }];
}

- (IBAction)closeBarButtonItemPressed:(id)sender {
    
}
@end
