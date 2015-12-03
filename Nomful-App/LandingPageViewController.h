//
//  LandingPageViewController.h
//  Nomful-App
//
//  Created by Sean Crowe on 12/3/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LandingPageViewController : UIViewController

//actions
- (IBAction)getStartedButtonPressed:(id)sender;
- (IBAction)memberLoginButtonPressed:(id)sender;

//elements
@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;
@property (weak, nonatomic) IBOutlet UIButton *memberLoginButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end
