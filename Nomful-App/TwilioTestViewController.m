//
//  TwilioTestViewController.m
//  Nomful
//
//  Created by Sean Crowe on 5/14/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "TwilioTestViewController.h"

@interface TwilioTestViewController ()

@end

@implementation TwilioTestViewController

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

- (IBAction)goButtonPressed:(id)sender {
    
    // Call our Cloud Function that sends an SMS with Twilio
    NSDictionary *params = [NSDictionary dictionaryWithObject:@"+1330006714458" forKey:@"number"];

    [PFCloud callFunctionInBackground:@"inviteWithTwilio"
                       withParameters:params
                                block:^(id object, NSError *error) {
                                    
                                    if(!error){
                                        [[[UIAlertView alloc] initWithTitle:@"Invite Sent!"
                                                                    message:@"Your SMS invitation has been sent!"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil, nil] show];
                                    }
                                }];
    
    
}
@end
