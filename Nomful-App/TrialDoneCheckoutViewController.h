//
//  TrialDoneCheckoutViewController.h
//  Nomful-App
//
//  Created by Sean Crowe on 12/28/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrialDoneCheckoutViewController : UIViewController <PKPaymentAuthorizationViewControllerDelegate>
//actions
- (IBAction)planViewPressed:(UIButton *)button;
- (IBAction)purchaseButtonPressed:(id)sender;
- (IBAction)payWithCardPressed:(id)sender;


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
@property (weak, nonatomic) IBOutlet UIView *paymentButtonsView;
@property (weak, nonatomic) IBOutlet UIButton *payWithCardButton;

//views made programatically
@property (strong, nonatomic) UIButton *applePaybutton;


//vars
@property (strong, nonatomic) UIColor *planColor;
@property bool paymentProcessed;
@property (strong, nonatomic) NSString *planSelected;


//apple pay
@property (strong, nonatomic) PKPaymentAuthorizationViewController *paymentController;



@end
