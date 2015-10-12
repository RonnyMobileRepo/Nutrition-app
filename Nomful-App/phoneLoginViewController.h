//
//  phoneLoginViewController.h
//  Nomful
//
//  Created by Sean Crowe on 8/31/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface phoneLoginViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
- (IBAction)sendCode:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *enterCodeTextField;
- (IBAction)login:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *sendCodebutton;
@property (weak, nonatomic) IBOutlet UIButton *sendCodeButton;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *noCodeButton;
- (IBAction)noCodeButtonPressed:(id)sender;

@end
