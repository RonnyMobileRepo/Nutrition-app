//
//  CoachPageContentViewController.m
//  Nomful-App
//
//  Created by Sean Crowe on 11/17/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "CoachPageContentViewController.h"

@interface CoachPageContentViewController ()

@end

@implementation CoachPageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //**set this fromt he user passed to us (coachUserObject)
    PFUser *coachUser = _coachUserObject;
    
    [coachUser fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        //get coach user info
        
        //image
        PFFile *imageFile = coachUser[@"photo"];
        _backgroundImageView.file = imageFile;
        [_backgroundImageView loadInBackground];

        //first name
        self.coachLabel.text = coachUser[@"firstName"];

        _roundProfileImageView.file = imageFile;
        [_roundProfileImageView loadInBackground];
        
        
    }];
    
    
    
    //LOAD STYLES
    //CARDVIEW NOT VISIBLE
    [_cardView setBackgroundColor:[UIColor clearColor]];
    _cardView.layer.cornerRadius = 20.0;
    
    //IMAGE
    _backgroundImageView.layer.cornerRadius = 20.0;
    _backgroundImageView.layer.masksToBounds = YES; //need this for corner radius
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    [_backgroundImageView addSubview:effectView];
    
    _roundProfileImageView.layer.cornerRadius = _roundProfileImageView.frame.size.width / 2;
    _roundProfileImageView.clipsToBounds = YES;

    //BUTTON
    _goButton.layer.borderWidth = 1.0;
    [_goButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    _goButton.layer.cornerRadius = 6.0;
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goButtonPressed:(id)sender {
    NSLog(@"BUTTON %lu PRESSED!", (unsigned long)_pageIndex);
}


@end
