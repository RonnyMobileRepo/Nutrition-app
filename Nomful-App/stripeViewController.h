//
//  stripeViewController.h
//  Nomful
//
//  Created by Sean Crowe on 7/1/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <Stripe.h>

@interface stripeViewController : UIViewController <PKPaymentAuthorizationViewControllerDelegate>
- (IBAction)buttonPressed:(id)sender;

@property (strong, nonatomic) PKPaymentAuthorizationViewController *paymentController;
@end
