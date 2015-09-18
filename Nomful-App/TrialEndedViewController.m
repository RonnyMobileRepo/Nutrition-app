//
//  TrialEndedViewController.m
//  Nomful
//
//  Created by Sean Crowe on 8/28/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "TrialEndedViewController.h"

@interface TrialEndedViewController ()

@end

@implementation TrialEndedViewController

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
- (IBAction)paymentCompletePressed:(id)sender {
    
    NSLog(@"payment button presed");
    
    //mark account as active
    [PFUser currentUser][@"accountMembership"] = @"active";
    [[PFUser currentUser]saveEventually];
    
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
    

    
    
    
}

@end
