//
//  SignUpConversationViewController.h
//  Nomful
//
//  Created by Sean Crowe on 8/10/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VPImageCropperViewController.h>
#import "CheckoutViewController.h"
#import "TrialViewController.h"
#import "CoachPageContentViewController.h"



@interface SignUpConversationViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, VPImageCropperDelegate, UITableViewDataSource, UITableViewDelegate, UIPageViewControllerDataSource, CoachCardDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UILabel *coachNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberNameLabel;

//variables
@property NSInteger messageCount;
@property NSInteger buttonLabelCount;
@property (strong, nonatomic) PFUser *coachUser;
@property (strong, nonatomic) NSMutableArray *coachUserArray;

@property (strong, nonatomic) UIImage *coachImage;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

//coach stuff
@property (weak, nonatomic) IBOutlet UIImageView *coachProfileImage;

//message and buttons
@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (strong, nonatomic) NSMutableArray *buttonLabelArray;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *button1;
- (IBAction)buttonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *textfield1;
@property (weak, nonatomic) IBOutlet UIButton *button2;

@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIButton *button4;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSString *text;

@property (weak, nonatomic) IBOutlet UIImageView *nomberry;
//answers
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *city;

//image
@property (nonatomic,strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *image;

@property (strong, nonatomic) NSArray *constraints;
@property (strong, nonatomic) NSArray *constraints2;


@property bool cancelButtonPressed;
@property bool findAnotherCoachSelected;
@property bool isGymMember;


@property int i;

- (IBAction)dontWantCoachToSeePressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *sendAnotherCodeButton;
- (IBAction)sendAnotherButtonPressed:(id)sender;

@property (strong, nonatomic) NSString *realCode;

@property (strong, nonatomic) PFUser *curUser;
@property (strong, nonatomic) PFObject *gymObject;

@property (strong, nonatomic) NSString *replacedString;


typedef void(^findCoachCompleted)(BOOL);
@property (strong, nonatomic) IBOutlet PFImageView *newestCoachImage;

@property (weak, nonatomic) IBOutlet UIButton *notlistedbutton;
@property (weak, nonatomic) IBOutlet UIButton *noProfileButton;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

- (IBAction)inputButtonPressed:(UIButton *)sender;

- (IBAction)cancelButtonPressed:(id)sender;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *coachUsers;
@property (weak, nonatomic) IBOutlet UIView *coachMatchContainer;
@property (weak, nonatomic) IBOutlet PFImageView *coachMatchImageView;
@property (weak, nonatomic) IBOutlet UIImageView *memberMatchImageView;
- (IBAction)addProfileImagePressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *dontShowProfileButton;

@end
