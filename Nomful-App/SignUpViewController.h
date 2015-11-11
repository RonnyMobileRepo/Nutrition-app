//
//  SignUpViewController.h
//  RealDietitian
//
//  Created by Sean Crowe on 2/19/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <VPImageCropperViewController.h>
#import <Mixpanel.h>

@interface SignUpViewController : UIViewController <UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, VPImageCropperDelegate, UITextFieldDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UITextField *firstNameField;
@property (strong, nonatomic) UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *repasswordField;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIButton *uploadPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *motivationField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property BOOL didUploadPhoto;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomActivityConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *nameFieldIcon;
@property (weak, nonatomic) IBOutlet UIImageView *emailFieldIcon;
@property (weak, nonatomic) IBOutlet UIImageView *passwordFieldIcon;
@property (weak, nonatomic) IBOutlet UIImageView *motivationFieldIcon;
@property (weak, nonatomic) IBOutlet UIImageView *realMotivationIcon;


@property (nonatomic, strong) UIPopoverController *popOver;


- (IBAction)closeButtonPressed:(id)sender;
- (IBAction)SignInButtonPressed:(id)sender;
- (IBAction)pickImagePressed:(id)sender;
- (IBAction)textFieldDidBeginEditing:(UITextField *)textField;
- (IBAction)textFieldDidEndEditing:(UITextField *)textField;
@property (weak, nonatomic) IBOutlet UIButton *checkBox;
- (IBAction)checkBoxChecked:(id)sender;

@end
