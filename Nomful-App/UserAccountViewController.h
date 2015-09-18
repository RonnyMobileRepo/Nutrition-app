//
//  UserAccountViewController.h
//  RealDietitian
//
//  Created by Sean Crowe on 2/24/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@class UserAccountViewController;

@protocol UserAccountDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(UserAccountViewController *)vc;

@end

@interface UserAccountViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate>

@property (weak) id<UserAccountDelegate> delegateModals;
@property (weak) id<UserAccountDelegate> delegate;

@property (strong, nonatomic) PFObject *chatroomObject;

//ui
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *goalLabel;
@property (strong, nonatomic) IBOutlet UITextView *GoalTextView;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UIImageView *bacgroundImage;

//buttons
@property (weak, nonatomic) IBOutlet UIButton *addGoalButton;
@property (weak, nonatomic) IBOutlet UIButton *saveNotesButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//actions
- (IBAction)newGoalButtonPressed:(id)sender;
- (IBAction)saveNotesButtonPressed:(id)sender;

@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@property CGPoint originalCenter;
@property CGRect keyboardFrameBeginRect;

@property bool isNotes;


@end
