//
//  VerificationCodeViewController.h
//  RealDietitian
//
//  Created by Sean Crowe on 3/2/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <M13ProgressViewPie.h>

@interface VerificationCodeViewController : UIViewController <UITextFieldDelegate>

- (IBAction)verifyButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *verifyCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet UIButton *didntReceiveCodeButton;
- (IBAction)sendAnotherCodePressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *seperatorView;
@property (weak, nonatomic) IBOutlet UIImageView *phoneIconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *codeIconImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomActivityConstraint;

@property (weak, nonatomic) IBOutlet M13ProgressViewPie *pieview;

@property bool randomUserNoGym;

- (void)keyboardWillHide:(NSNotification *)sender;
- (void)keyboardDidShow:(NSNotification *)sender;

@end
