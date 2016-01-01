//
//  TrialDoneCheckoutViewController.m
//  Nomful-App
//
//  Created by Sean Crowe on 12/28/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "TrialDoneCheckoutViewController.h"

@interface TrialDoneCheckoutViewController ()

@end

@implementation TrialDoneCheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //vars
    _planColor = [UIColor colorWithRed:126.0/255.0 green:202/255.0 blue:175/255.0 alpha:1.0];
    _planSelected = @"2"; //default this so that there is alwasy a 'plan selected' on load

    [self loadUX];
    [self loadPaymentOptionsView];
    [self stickyViewToKeyboard];
    
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

#pragma mark - User Interface Changes

- (void)loadUX{
    //load some styling shtuff0
    
    //rounded corners
    _planViewLeft.layer.cornerRadius = 4.0;
    _planViewMiddle.layer.cornerRadius = 4.0;
    _planViewRight.layer.cornerRadius = 4.0;
    
    //borders
    _planViewLeft.layer.borderColor = [[UIColor blackColor] CGColor];
    _planViewLeft.layer.borderWidth = 1.0;
    _planViewRight.layer.borderColor = [[UIColor blackColor] CGColor];
    _planViewRight.layer.borderWidth = 1.0;
    _payWithCardButton.layer.borderColor = [[UIColor blackColor] CGColor];
    _payWithCardButton.layer.borderWidth = 1.0;
    _payWithCardButton.layer.cornerRadius = 4.0;
    
    _purchaseButton.layer.cornerRadius =4.0;
    
    //showdow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_planViewMiddle.bounds];
    _planViewMiddle.layer.masksToBounds = NO;
    _planViewMiddle.layer.shadowColor = [UIColor blackColor].CGColor;
    _planViewMiddle.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    _planViewMiddle.layer.shadowOpacity = 0.7f;
    _planViewMiddle.layer.shadowPath = shadowPath.CGPath;
    
    // create effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    [_backgroundImage addSubview:effectView];
    
    _testimonialContainer.layer.masksToBounds = NO;
    _testimonialPicture.layer.masksToBounds = YES; //*keep this sean. fixes the weird transparency thing
    _testimonialContainer.layer.cornerRadius = 4.0;
    _testimonialPicture.layer.cornerRadius = _testimonialPicture.bounds.size.width /2;
    
    //showdow
    _testimonialContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    _testimonialContainer.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    _testimonialContainer.layer.shadowOpacity = 0.7f;
    
    
  
    
}

- (void)loadPaymentOptionsView{
    
    if ([PKPaymentAuthorizationViewController canMakePayments] && [PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex, PKPaymentNetworkDiscover]]) {
        
        _applePayEnabled = true;
        //make a button that will be the branded apple pay button
        _applePaybutton = [[UIButton alloc] init];
        _applePaybutton = [self makeApplePayButton];
        
        //add apple pay button to view at bottom of screen
        [self.paymentButtonsView addSubview:_applePaybutton];
        
        //remove the contraint that we added when we removed the appy pay button
        [_paymentButtonsView removeConstraints:_payWithCardConstraint];
        
        //calculate the width of the apple pay button
        float screenWidth = self.view.bounds.size.width;
        float buttonWidth = (screenWidth/2) - (10*2); //TODO: This is hard coded margins for calc
        NSNumber *width = [NSNumber numberWithFloat:buttonWidth];

        //define the views and metrics for autolayout
        NSDictionary *views = @{@"applePay": _applePaybutton,
                                @"payCard" : _payWithCardButton};
        
        NSDictionary *metrics = @{@"appleButtonWidth": width};
        
        //apple pay button 30 pts from left edge
        [self.paymentButtonsView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[applePay(appleButtonWidth)]-(5)-[payCard]"
                                                                                         options:0
                                                                                         metrics:metrics
                                                                                           views:views]];
        
        //apple pay button 50 pts tall (auto calcs the width since apple button)
        [self.paymentButtonsView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[applePay(50)]"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:views]];
        
        //vertically center the apple pay button in the view
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.paymentButtonsView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_applePaybutton
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0f constant:0.0f]];
        
        [_paymentButtonsView layoutIfNeeded];
        
        
    }else{
        
        NSDictionary *views = @{@"payWithCard": _payWithCardButton};
         
         
         //profile image is 8 pts from top and 100 pts tall
         [self.paymentButtonsView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[payWithCard]-(30)-|"
         options:0
         metrics:nil
         views:views]];
         
         [self.paymentButtonsView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[payWithCard(50)]"
         options:0
         metrics:nil
         views:views]];
         [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.paymentButtonsView
         attribute:NSLayoutAttributeCenterY
         relatedBy:NSLayoutRelationEqual
         toItem:_payWithCardButton
         attribute:NSLayoutAttributeCenterY
         multiplier:1.0f constant:0.0f]];
    }
    
}


#pragma mark - Actions
- (IBAction)planViewPressed:(UIButton *)button{
    //1 = healthy start
    //2 = bootcamp
    //3 = lifestyle
    
    UIView *planSelected;
    
    //update the ui
    [UIView animateWithDuration:0.15 animations:^{
        _paymentButtonsView.alpha = 0;

    }];

    //update the ui
    [UIView animateWithDuration:0.50 animations:^{
            _purchaseButton.alpha =   1.0;
        
    }];
    
    
    //update the plan description
    [self updatePlanDescription:button];
    
    if (button.tag == 1) {
        planSelected = _planViewLeft;
        _planViewLeft.backgroundColor = _planColor;
        _planViewMiddle.backgroundColor = [UIColor whiteColor];
        _planViewRight.backgroundColor = [UIColor whiteColor];
        _planSelected = @"1";
        
    }else if(button.tag == 2){
        planSelected = _planViewMiddle;
        _planViewLeft.backgroundColor = [UIColor whiteColor];
        _planViewMiddle.backgroundColor = _planColor;
        _planViewRight.backgroundColor = [UIColor whiteColor];
        _planSelected = @"2";
        
    }else if(button.tag == 3){
        planSelected = _planViewRight;
        _planViewLeft.backgroundColor = [UIColor whiteColor];
        _planViewMiddle.backgroundColor = [UIColor whiteColor];
        _planViewRight.backgroundColor = _planColor;
        _planSelected = @"3";
    }
    
    
    //update the ui
    [UIView animateWithDuration:0.50 animations:^{
        planSelected.alpha =   1.0;
        
    }];
    
    
}

- (IBAction)purchaseButtonPressed:(id)sender {
    //show payment options at bottom (credit card + Apple Pay)

    CGRect frame = _testimonialContainer.frame;

    //animate orange button out and make sure the payment container alpha is 1
    [UIView animateWithDuration:0.15
                     animations:^{
                         
                         //change alpha of button
                         _purchaseButton.alpha = 0;
                         _paymentButtonsView.alpha = 1;
                     }];
    
    
    //animate testimonial up 77pts
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         float x = frame.origin.x;
                         float y = frame.origin.y - _paymentButtonsView.frame.size.height;
                         _testimonialContainer.frame = CGRectMake(x, y, _testimonialContainer.frame.size.width, _testimonialContainer.frame.size.height );
                     }];

    
    
    //animate payment options up
    _paymentButtonsView.hidden = false;
    [_paymentButtonsView startCanvasAnimation];

    
}

- (IBAction)payWithCardPressed:(id)sender {
    //the first time this button is pressed the title is "pay with card"
    //the second time this button is pressed the title is "Complete Payment"
    //we must differentiate from them
    
    NSString *buttonTitle = _payWithCardButton.titleLabel.text;
    
    if ([buttonTitle isEqualToString:@"Pay with Card"]) {
        NSLog(@"Button said pay with card.");
        
        //hide views so we can add in the credit card form
        [UIView animateWithDuration:0.5 animations:^{
            
            //fade out everythang
            _testimonialContainer.alpha = 0;
            _check1.alpha = 0;
            _check2.alpha = 0;
            _check3.alpha = 0;
            _check4.alpha = 0;
            _planDescriptionTitle.alpha = 0;
            _planBullet1.alpha = 0;
            _planBullet2.alpha = 0;
            _planBullet3.alpha = 0;
            _planBullet4.alpha = 0;
            _titleBar.alpha = 0;
            
            _middlePlanButton.enabled = NO;
            _rightPlanButton.enabled = NO;
            _leftPlanButton.enabled = NO;
            
            _payWithCardButton.enabled = false;
            
            _closeButton.hidden = false;
                
        
        } completion:^(BOOL finished) {
            
            //change button title to 'complete payment'
            [_payWithCardButton setTitle:@"Complete Payment" forState:UIControlStateNormal];
            
            //build stripe form for CC info
            self.paymentTextField = [[STPPaymentCardTextField alloc]
                                     initWithFrame:CGRectMake(15, 30, CGRectGetWidth(self.view.frame) - 20, 44)];; //20 = 10+10 margins
            self.paymentTextField.delegate = self;
            [self.view addSubview:self.paymentTextField];
            _paymentTextField.translatesAutoresizingMaskIntoConstraints = NO;
            
            _applePaybutton.hidden = true;
            
            //define the views and metrics for autolayout
            NSDictionary *views = @{@"ccField": _paymentTextField,
                                    @"titleBar" : _titleBar,
                                    @"payButton": _payWithCardButton};
            
            
            [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[titleBar]-(10)-[ccField(44)]"
                                                                                             options:0
                                                                                             metrics:nil
                                                                                               views:views]];
            
            _payWithCardConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[payButton]-(10)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views];
            [_paymentButtonsView addConstraints:_payWithCardConstraint];
            
            [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(20)-[ccField]-(20)-|"
                                                                                         options:0
                                                                                         metrics:nil
                                                                                           views:views]];
            
            [_paymentTextField becomeFirstResponder];
            
            
            
        }];
        
    }else if([buttonTitle isEqualToString:@"Complete Payment"]){
        NSLog(@"start payment procesing");

        STPCardParams* card = [self.paymentTextField card];
        [[STPAPIClient sharedClient]
         createTokenWithCard:card
         completion:^(STPToken *token, NSError *error) {
             if (token) {
                 
                 NSLog(@"4. Send token to backend %@", token.tokenId);
                 
                 NSString *plan = @"";
                 
                 
                 if([_planSelected isEqualToString:@"1"]){
                     plan = @"49.00";
                 }else if([_planSelected isEqualToString:@"2"]){
                     plan = @"199.00";
                 }else if([_planSelected isEqualToString:@"3"]){
                     plan = @"69.00";
                 }
                 
                 //call cloud code function chargeCard in main.js and pass is the credit card token
                 [PFCloud callFunctionInBackground:@"chargeCard"
                                    withParameters:@{@"token": token.tokenId,
                                                     @"plan": plan
                                                     }
                                             block:^(NSString *result, NSError *error) {
                                                 if (!error) {
                                                     NSLog(@"SUCCESS IS: %@", result);
                                                     _paymentProcessed = YES;
                                                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                         //TODO: UNCOMMENT[self sendRevenueInfoToMP:plan];
                                                     });

                                                 }
                                                 else{
                                                     NSLog(@"ERROR: %@", error);
                                                 }
                                             }];
                 
                 
             } else {
                 NSLog(@"Error creating token: %@", error.localizedDescription);
             }
         }];

    }

    
   }

#pragma mark - Helper Methods

- (void)stickyViewToKeyboard{
    
        
    //listen for keyboard events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //view is the thing we want to move around based on keyboard showing or not showing
    NSDictionary *views = @{@"view": _paymentButtonsView,
                            @"top": self.topLayoutGuide};
    

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[top][view]" options:0 metrics:nil views:views]];
    
    self.bottomConstraints = [NSLayoutConstraint constraintWithItem:_paymentButtonsView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bottomLayoutGuide attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    [self.view addConstraint:self.bottomConstraints];
    
}

-(void)keyboardDidShow:(NSNotification *)sender
{
    //https://gist.github.com/dlo/8572874
    
    CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect newFrame = [self.view convertRect:frame fromView:[[UIApplication sharedApplication] delegate].window];
    
    self.bottomConstraints.constant = newFrame.origin.y - CGRectGetHeight(self.view.frame);
    
    //this re-layouts our view
    [self.view layoutIfNeeded];
}

- (void)keyboardWillHide:(NSNotification *)sender {
    self.bottomConstraints.constant = 0;
    [self.view layoutIfNeeded];
}


- (IBAction)closeButtonPressd:(id)sender {
    
    //hide close button
    _closeButton.hidden = true;
    
    //dismiss keypad
    [_paymentTextField resignFirstResponder];
    
    //make button enabled
    _payWithCardButton.enabled = true;
    
    //make buttons selectable again
    _leftPlanButton.enabled = YES;
    _middlePlanButton.enabled = YES;
    _rightPlanButton.enabled = YES;
    
    //take away cc form
    [_paymentTextField removeFromSuperview];
    
    //change button title
    [_payWithCardButton setTitle:@"Pay with Card" forState:UIControlStateNormal];
    
    //animate in the plan title and bullets
    
    [UIView animateWithDuration:0.5 animations:^{
        
        //fade out everythang
        _testimonialContainer.alpha = 1;
        _check1.alpha = 1;
        _check2.alpha = 1;
        _check3.alpha = 1;
        _check4.alpha = 1;
        _planDescriptionTitle.alpha = 1;
        _planBullet1.alpha = 1;
        _planBullet2.alpha = 1;
        _planBullet3.alpha = 1;
        _planBullet4.alpha = 1;
        _titleBar.alpha = 1;
        _purchaseButton.alpha = 1;
        _paymentButtonsView.hidden = true;

        [self loadPaymentOptionsView];
        
    } completion:^(BOOL finished) {}];
    
    
    
}

-(void)updatePlanDescription:(UIButton *)planSelected{
    
    //string vars
    NSString *planTitleString;
    NSString *bullet1String1;
    NSString *bullet1String2;
    NSString *bullet1String3;
    NSString *bullet1String4;
    
    //change strings based on plan selected
    if (planSelected.tag == 1) {

        planTitleString = @"HEALTHY START";
        bullet1String1 = @"Initial phone assesment";
        bullet1String2 = @"Daily feedback and support";
        bullet1String3 = @"Quick meal sharing";
        bullet1String4 = @"Help with recipes, questions, etc";
        
    }else if(planSelected.tag == 2){
        planTitleString = @"BOOTCAMP";
        bullet1String1 = @"12-week immersive program";
        bullet1String2 = @"Complete personalized evaluation";
        bullet1String3 = @"Weekly progress tracking";
        bullet1String4 = @"Regular phone assesments";
        
    }else if(planSelected.tag == 3){
        planTitleString = @"LIFESTYLE";
        bullet1String1 = @"BULLET 1";
        bullet1String2 = @"BULLET 2";
        bullet1String3 = @"BULLET 3";
        bullet1String4 = @"BULLET 4";
    }

    //set texts
    _planDescriptionTitle.text = planTitleString;
    _planBullet1.text = bullet1String1;
    _planBullet2.text = bullet1String2;
    _planBullet3.text = bullet1String3;
    _planBullet4.text = bullet1String4;

}

- (IBAction)applePayButtonPressed:(id)sender {
    //declare new request to be sent to apple
    PKPaymentRequest *request = [Stripe
                                 paymentRequestWithMerchantIdentifier:@"merchant.nomful"];
    
    // Configure your request here
    NSString *label = @"";
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:@"0.00"];
    
    if ([_planSelected isEqualToString: @"1"]) {
        label   = @"Healthy Start - 21 Day Coaching";
        amount  = [NSDecimalNumber decimalNumberWithString:@"49.00"];
        
    }else if([_planSelected isEqualToString: @"2"]){
        label   = @"Boot Camp - 12-week Coaching";
        amount  = [NSDecimalNumber decimalNumberWithString:@"199.00"];
        
    }else if([_planSelected isEqualToString: @"3"]){
        label   = @"Lifestyle - 4-week Coaching";
        amount  = [NSDecimalNumber decimalNumberWithString:@"69.00"];
    }
    
    //build request object
    request.paymentSummaryItems = @[
                                    [PKPaymentSummaryItem summaryItemWithLabel:label
                                                                        amount:amount]
                                    ];
    //send request
    if ([Stripe canSubmitPaymentRequest:request]) {
        
        //declare applepay sheet
        //initialize it with the request sent and approved by apple
        _paymentController = [[PKPaymentAuthorizationViewController alloc]
                              initWithPaymentRequest:request];
        
        //this should probably work
        _paymentController.delegate = self;
        
        //display apple pay sheet
        [self presentViewController:_paymentController animated:YES completion:nil];
        NSLog(@"1. Start here");
        
    } else {
        //***  Apple pay not on device. Show the user your own credit card form (see options 2 or 3)
        NSLog(@"No Apple Pay on Device");
        //[self noApplePay];
        
        //TODO: Build the stripe form
    }
    
}

#pragma mark - Apple Pay

- (UIButton *)makeApplePayButton {
    UIButton *button;
    
    if ([PKPaymentButton class]) { // Available in iOS 8.3+
        button = [PKPaymentButton buttonWithType:PKPaymentButtonTypeBuy style:PKPaymentButtonStyleWhiteOutline];
    } else {
        // TODO: Create and return your own apple pay button
        [button setBackgroundImage:[UIImage imageNamed:@"ApplePayBTN_64pt__whiteLine_textLogo_"] forState:UIControlStateNormal];
    }
    
    [button addTarget:self action:@selector(applePayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.translatesAutoresizingMaskIntoConstraints = false;
    return button;
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    NSLog(@"2. Authorize Payment");

    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment
                                   completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    NSLog(@"3. Create Token");
    
    [[STPAPIClient sharedClient] createTokenWithPayment:payment
                                             completion:^(STPToken *token, NSError *error) {
                                                 if (error) {
                                                     completion(PKPaymentAuthorizationStatusFailure);
                                                     NSLog(@"create token failure: %@", error);
                                                     return;
                                                 }
                                                
                                                 [self createBackendChargeWithToken:token completion:completion];
                                             }];
}

- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    NSLog(@"4. Send token to backend %@", token.tokenId);
    
    NSString *plan = @"";
    
    
    if([_planSelected isEqualToString:@"1"]){
        plan = @"49.00";
    }else if([_planSelected isEqualToString:@"2"]){
        plan = @"199.00";
    }else if([_planSelected isEqualToString:@"3"]){
        plan = @"69.00";
    }
    
    //call cloud code function chargeCard in main.js and pass is the credit card token
    [PFCloud callFunctionInBackground:@"chargeCard"
                       withParameters:@{@"token": token.tokenId,
                                        @"plan": plan
                                        }
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        NSLog(@"RESULT IS: %@", result);
                                        _paymentProcessed = YES;
                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                            //TODO: UNCOMMENT[self sendRevenueInfoToMP:plan];
                                        });
                                        
                                        completion(PKPaymentAuthorizationStatusSuccess);
                                        
                                        
                                    }
                                    else{
                                        NSLog(@"ERROR: %@", error);
                                        completion(PKPaymentAuthorizationStatusFailure);
                                    }
                                }];
    
    
}

#pragma mark - Stripe CC Field
- (void)paymentCardTextFieldDidChange:(STPPaymentCardTextField *)textField {
    _payWithCardButton.enabled = textField.isValid;
}



@end
