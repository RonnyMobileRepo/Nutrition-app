//
//  CoachPageContentViewController.h
//  Nomful-App
//
//  Created by Sean Crowe on 11/17/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

// 1. Forward declaration of ChildViewControllerDelegate - this just declares
// that a ChildViewControllerDelegate type exists so that we can use it
// later.
@protocol CoachCardDelegate;

// 2. Declaration of the view controller class, as usual
@interface CoachPageContentViewController : UIViewController

// Delegate properties should always be weak references
// See http://stackoverflow.com/a/4796131/263871 for the rationale
// (Tip: If you're not using ARC, use `assign` instead of `weak`)
@property (nonatomic, weak) id<CoachCardDelegate> delegate;

//UI ELEMENTS
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UILabel *coachLabel;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet PFImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet PFImageView *roundProfileImageView;
@property (weak, nonatomic) IBOutlet UITextView *aboutMeTextView;
@property (weak, nonatomic) IBOutlet UITextView *philTextView;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

- (IBAction)goButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *specialtiesTitleLabe;

//DELEGATE STUFF?
@property NSUInteger pageIndex;
@property NSString *titleText;
@property PFUser *coachUserObject;

@property (strong, nonatomic) NSMutableArray *coachSpecialitesArray;

@end

// 3. Definition of the delegate's interface
@protocol CoachCardDelegate <NSObject>

- (void)childViewController:(CoachPageContentViewController*)viewController
didChooseCoach:(PFUser*)coachUserSelected;

@end