//
//  MatchCoachViewController.m
//  Nomful
//
//  Created by Sean Crowe on 7/22/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "MatchCoachViewController.h"

@interface MatchCoachViewController ()

@end

@implementation MatchCoachViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //coach user is found on the previous view controller and stored in _coachUser
    //I think we can hide everything and show a progress animation
    //then animate the elements in to give the effect of matching algo working in background
    
    //set content from coach user
    _coachFullNameLabel.text = [NSString stringWithFormat:@"%@ %@",[_coachUser valueForKey:@"firstName"], [_coachUser valueForKey:@"lastName"]];

    _specialitesTextView.text = _coachUser[@"goals"][0];
    _bioTextView.text = _coachUser[@"bio"];

    
    //get and set profile image
    PFFile *userImageFile = _coachUser[@"photo"];
    _coachProfileImageView.file = userImageFile;
    [_coachProfileImageView loadInBackground];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    SignUpConversationViewController *vc = [segue destinationViewController];
    vc.coachImage = _coachProfileImageView.image;
    
}


@end
