//
//  CoachPageContentViewController.m
//  Nomful-App
//
//  Created by Sean Crowe on 11/17/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "CoachPageContentViewController.h"
#import "SignUpConversationViewController.h"

@interface CoachPageContentViewController ()

@end

@implementation CoachPageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //**set this fromt he user passed to us (coachUserObject)
    PFUser *coachUser = _coachUserObject;
    
    [coachUser fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        //get coach user info
        
        NSString *fullName = [NSString stringWithFormat:@"%@ %@",[coachUser valueForKey:@"firstName"], [coachUser valueForKey:@"lastName"]];
        NSString *aboutMeString = coachUser[@"aboutMe"];
        NSString *myPhilString = coachUser[@"myPhilosophy"];
        NSString *cityString = coachUser[@"city"];

        PFFile *imageFile = coachUser[@"photo"];


        
        
        //background image
        _backgroundImageView.file = imageFile;
        [_backgroundImageView loadInBackground];

        //profile image
        _roundProfileImageView.file = imageFile;
        [_roundProfileImageView loadInBackground];
        
        //first name last initian Sean C.
        NSArray* firstLastStrings = [fullName componentsSeparatedByString:@" "];
        NSString* firstName = [firstLastStrings objectAtIndex:0];
        NSString* lastName = [firstLastStrings objectAtIndex:1];
        char lastInitialChar = [lastName characterAtIndex:0];
        NSString* newNameStr = [NSString stringWithFormat:@"%@ %c.", firstName, lastInitialChar];
        self.coachLabel.text = newNameStr;

        //about me
        _aboutMeTextView.text = aboutMeString;
        _philTextView.text = myPhilString;
        _cityLabel.text = cityString;
        
       
        
        //text views
        [_aboutMeTextView setTextColor:[UIColor whiteColor]];
        [_aboutMeTextView setFont:[UIFont fontWithName:kFontFamilyName100 size:14.0]];
        [_philTextView setTextColor:[UIColor whiteColor]];
        [_philTextView setFont:[UIFont fontWithName:kFontFamilyName100 size:14.0]];
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
    // Xcode will complain if we access a weak property more than
    // once here, since it could in theory be nilled between accesses
    // leading to unpredictable results. So we'll start by taking
    // a local, strong reference to the delegate.
    id<CoachCardDelegate> strongDelegate = self.delegate;
    
    // Our delegate method is optional, so we should
    // check that the delegate implements it
    if ([strongDelegate respondsToSelector:@selector(childViewController:didChooseCoach:)]) {
        [strongDelegate childViewController:self didChooseCoach:_coachUserObject];
    }

}


@end
