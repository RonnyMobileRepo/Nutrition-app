//
//  CheckoutViewController.h
//  Nomful
//
//  Created by Sean Crowe on 7/22/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Stripe.h>
#import "PTKView.h"

@interface CheckoutViewController : UIViewController <PKPaymentAuthorizationViewControllerDelegate, PTKViewDelegate>

@property (strong, nonatomic) PKPaymentAuthorizationViewController *paymentController;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *epirationDateLabel;
@property (strong, nonatomic) UIButton *applePaybutton;
@property (weak, nonatomic) IBOutlet UIButton *payWithCardButton;
@property (weak, nonatomic) PFUser *coachUser;
@property (weak, nonatomic) PFUser *trainerUser;
@property (weak, nonatomic) IBOutlet UIButton *healthyStartButton;
@property (weak, nonatomic) IBOutlet UIButton *bootCampButton;

@property (strong,nonatomic) UIImage *profileImage;
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property bool paymentProcessed;

- (IBAction)buttonPressed:(id)sender;
- (IBAction)payCardButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *paymentButtonsView;
@property(weak, nonatomic) PTKView *paymentView;

@property(weak, nonatomic) PFObject *gymObject;
@property (weak, nonatomic) IBOutlet UIView *healthyStartView;
@property (weak, nonatomic) IBOutlet UIView *bootCampView;

@property bool trialDidEnd;
@property bool healthyStartSelected;
@property bool bootCampSelected;
@property bool paymentOptionsShowing;
@property (nonatomic, strong) NSArray *bootcampBottomConstraint;
@property (nonatomic, strong) NSArray *healthyStartBottomConstraint;

@property (strong, nonatomic) UIButton *saveCardButton;

- (IBAction)healthyStartButtonPressed:(id)sender;
- (IBAction)bootCampButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *ccActivityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
- (IBAction)closeButtonPresed:(id)sender;

@property (strong, nonatomic) NSMutableArray *initialConstraints;
@end
