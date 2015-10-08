//
//  adminViewController.m
//  Nomful-App
//
//  Created by Sean Crowe on 10/7/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "adminViewController.h"

@interface adminViewController ()

@end

@implementation adminViewController

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

- (IBAction)showCoachView:(id)sender {
    [PFUser currentUser][@"role"] = @"PT";
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        //go segue
        [self performSegueWithIdentifier:@"adminToCoach" sender:self];
        
    }];
    
    
}

- (IBAction)showMemberView:(id)sender {
    [PFUser currentUser][@"role"] = @"PT";
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        //go segue
        [self performSegueWithIdentifier:@"adminToClient" sender:self];
        
    }];
    

}
@end
