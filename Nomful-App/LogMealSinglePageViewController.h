//
//  LogMealSinglePageViewController.h
//  RealDietitian
//
//  Created by Sean Crowe on 4/12/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MessagesViewController.h"
#import <UIBarButtonItem+Badge.h>
#import "UIImage+ResizeAdditions.h"
#import "CheckoutViewController.h"


@interface LogMealSinglePageViewController : UIViewController <UITextViewDelegate>

//Views

@property (strong, nonatomic) UINavigationBar *navBar;
//Camera View finder
@property (strong, nonatomic)  UIView *cameraView;

//details container view
@property (strong, nonatomic) UIView *detailsContainerView;

//Textview for the photo description
@property (strong, nonatomic)  UITextView *descriptionTextView;

//Image view to display the image after it is captured
@property (strong, nonatomic) UIImageView *capturedImageView;

//Save button for user to save their image
@property (strong, nonatomic)  UIButton *saveButton;

//previous meal button
@property (strong, nonatomic) UIButton *pastMealsButton;

//Capture the image button
@property (strong, nonatomic) UIButton *captureButton;

//segues to the table view of previous meals
@property (weak, nonatomic)  UIButton *pastMeals;

//local copy of the image that is captured from camera
@property (strong, nonatomic) UIImage *capturedImage;

//Camera property that I don't really understand and took from SO
@property (strong, nonatomic)   AVCaptureStillImageOutput *stillImageOutput;

//constraint for the sticky button method
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;

//container for indicator so we can add transparency
@property (strong, nonatomic) UIView *activityIndicatorContainer;

//activity indicator for when a photot is taken
@property (strong, nonatomic) UIActivityIndicatorView *photoTakenActivityIndicator;

//label for Title of the goals "Your weekly Goals"
@property (strong, nonatomic) UILabel *goalsTitleLabel;

//label for the acutal goal "Record eating habits"
@property (strong, nonatomic) UITextView *goalsLabel;

//hashtag container
@property (strong, nonatomic) UIView *hashtagsContainer;
@property (strong, nonatomic) UIView *captureButtonContainer;
@property (strong, nonatomic) NSArray *verticalConstraints;


//origin
@property CGPoint originalCenter;

//hashtag buttons
@property (strong, nonatomic) UIButton *breakfastButton;
@property (strong, nonatomic) UIButton *lunchButton;
@property (strong, nonatomic) UIButton *dinnerButton;
@property (strong, nonatomic) UIButton *snackButton;
@property (strong, nonatomic) UIButton *coffeeButton;
@property (strong, nonatomic) UIButton *nomfulButton;
@property (strong, nonatomic) UIButton *makeYourOwnButton;

//array for hashtag selections
@property (strong, nonatomic) NSMutableArray *buttonsArray;
@property (strong, nonatomic) NSMutableArray *hashtagArray;

//avatars
@property (strong, nonatomic) UIImage *clientAvatar;
@property (strong, nonatomic) UIImage *dietitianAvatar;
@property (strong, nonatomic) UIImage *trainerAvatar;


///keep
@property (strong, nonatomic) UIColor *brandColor;
@property (strong, nonatomic) UIView *cardView;
@property (strong, nonatomic) UIView *bottomContainerView;
@property (strong, nonatomic) PFObject *chatroom;


@property (strong, nonatomic) PFFile *photoFile;
@property (strong, nonatomic) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;


@property (strong ,nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureLayer;

//account bar button item pressed
- (IBAction)accountBarButtonPressed:(id)sender;

//save image button pressed
- (IBAction)saveButtonPressed:(id)sender;

//camera capture button pressed
- (IBAction)captureButtonPressed:(id)sender;


//hashtag selected....
- (IBAction)hashtagSelected:(UIButton *)sender;

- (void)keyboardWillHide:(NSNotification *)sender;
- (void)keyboardDidShow:(NSNotification *)sender;

- (void) checkforBadgeValue;


@end
