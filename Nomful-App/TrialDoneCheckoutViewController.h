//
//  TrialDoneCheckoutViewController.h
//  Nomful-App
//
//  Created by Sean Crowe on 12/28/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Canvas.h"
#import "LogMealSinglePageViewController.h"

@interface TrialDoneCheckoutViewController : UIViewController <PKPaymentAuthorizationViewControllerDelegate, STPPaymentCardTextFieldDelegate>
//actions
- (IBAction)planViewPressed:(UIButton *)button;
- (IBAction)purchaseButtonPressed:(id)sender;
- (IBAction)payWithCardPressed:(id)sender;
- (IBAction)closeButtonPressd:(id)sender;


//views from storyboard
@property (weak, nonatomic) IBOutlet UIView *planViewLeft;
@property (weak, nonatomic) IBOutlet UIView *planViewMiddle;
@property (weak, nonatomic) IBOutlet UIView *planViewRight;
@property (weak, nonatomic) IBOutlet UIButton *purchaseButton;
@property (weak, nonatomic) IBOutlet UILabel *planDescriptionTitle;
@property (weak, nonatomic) IBOutlet UILabel *planBullet1;
@property (weak, nonatomic) IBOutlet UILabel *planBullet2;
@property (weak, nonatomic) IBOutlet UILabel *planBullet3;
@property (weak, nonatomic) IBOutlet UILabel *planBullet4;
@property (weak, nonatomic) IBOutlet CSAnimationView *paymentButtonsView;
@property (weak, nonatomic) IBOutlet UIButton *payWithCardButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIView *testimonialContainer;
@property (weak, nonatomic) IBOutlet UIImageView *testimonialPicture;
@property (weak, nonatomic) IBOutlet UIImageView *check1;
@property (weak, nonatomic) IBOutlet UIImageView *check2;
@property (weak, nonatomic) IBOutlet UIImageView *check3;
@property (weak, nonatomic) IBOutlet UIImageView *check4;
@property (weak, nonatomic) IBOutlet UIView *titleBar;
@property (weak, nonatomic) IBOutlet UIButton *leftPlanButton;
@property (weak, nonatomic) IBOutlet UIButton *middlePlanButton;
@property (weak, nonatomic) IBOutlet UIButton *rightPlanButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *testimonialTextView;
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;

//views made programatically
@property (strong, nonatomic) UIButton *applePaybutton;
@property (strong, nonatomic) UILabel *enterCCLabel;



//vars
@property (strong, nonatomic) UIColor *planColor;
@property bool paymentProcessed;
@property bool applePayEnabled;
@property (strong, nonatomic) NSString *planSelected;
@property (nonatomic, strong) NSArray *bottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *topConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraints;
@property (nonatomic, strong) NSArray *payWithCardConstraint;





//apple pay
@property (strong, nonatomic) PKPaymentAuthorizationViewController *paymentController;
@property (nonatomic) STPPaymentCardTextField *paymentTextField;




@end
