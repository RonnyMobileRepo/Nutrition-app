//
//  SignUpConversationViewController.h
//  Nomful
//
//  Created by Sean Crowe on 8/10/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VPImageCropperViewController.h>
#import "trainerCell.h"
#import "CheckoutViewController.h"
#import "TrialViewController.h"


@interface SignUpConversationViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, VPImageCropperDelegate, UITableViewDataSource, UITableViewDelegate>

//variables
@property NSInteger messageCount;
@property NSInteger buttonLabelCount;
@property (strong, nonatomic) PFUser *coachUser;
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
@property (weak, nonatomic) IBOutlet UIButton *noTrainerButton;

//image
@property (nonatomic,strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) UIImage *image;

@property (strong, nonatomic) NSArray *constraints;
@property (strong, nonatomic) NSArray *constraints2;


@property bool hasTrainer;
@property bool cancelButtonPressed;
@property bool noTrainer;
@property bool getGymInstead;
@property bool isGymMember;
@property bool findAnotherCoachSelected;

@property int i;


@property (weak, nonatomic) IBOutlet UIButton *sendAnotherCodeButton;
- (IBAction)sendAnotherButtonPressed:(id)sender;

@property (strong, nonatomic) NSString *realCode;

@property (strong, nonatomic) PFUser *curUser;
@property (strong, nonatomic) PFObject *gymObject;

@property (strong, nonatomic) NSString *replacedString;

@property (strong, nonatomic) UITableView *trainerTableView;
@property (strong, nonatomic) NSArray *trainersArray;
@property (strong, nonatomic) PFUser *trainerUser;

typedef void(^findCoachCompleted)(BOOL);
@property (weak, nonatomic) IBOutlet UIView *coachBioView;
@property (strong, nonatomic) IBOutlet PFImageView *newestCoachImage;

@property (weak, nonatomic) IBOutlet UIButton *notlistedbutton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

- (IBAction)inputButtonPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextView *coachBioTextView;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)noTrainerButtonPressed:(id)sender;


@end
