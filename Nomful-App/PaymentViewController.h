//
//  PaymentViewController.h
//  Nomful
//
//  Created by Sean Crowe on 8/5/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentViewController.h"
//#import "PTKView.h"

@interface PaymentViewController : UIViewController <PTKViewDelegate>

@property(weak, nonatomic) PTKView *paymentView;
- (IBAction)saveButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end
