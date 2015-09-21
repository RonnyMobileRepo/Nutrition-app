//
//  CheckoutViewController.m
//  Nomful
//
//  Created by Sean Crowe on 7/22/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//


 
#import "CheckoutViewController.h"
#import "TrialViewController.h"

@interface CheckoutViewController ()

@end

NSString *const kINTROAMOUNT = @"49.00";
NSString *const kBOOTCAMPAMOUNT = @"199.00";

@implementation CheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Conditionally show Apple Pay button based on device availability
    if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard]]) {
        NSLog(@"apple pay is set up");
        //you are here b/c the device supports apple pay
        ///so go make the apple pay button!!!!
        _applePaybutton = [[UIButton alloc] init];
        
        _applePaybutton = [self makeApplePayButton];
        [self.paymentButtonsView addSubview:_applePaybutton];
        
    
        //constrainstss
        
        NSDictionary *views = @{@"applePay": _applePaybutton};
        
        
        //profile image is 8 pts from top and 100 pts tall
        [self.paymentButtonsView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(30)-[applePay]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:views]];
        
        [self.paymentButtonsView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[applePay(50)]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:views]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.paymentButtonsView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:_applePaybutton
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0f constant:0.0f]];
    }else{
        //apple pay not set up or not supported on device
        //just show pay with card button
        
        NSDictionary *views = @{@"payWithCard": _payWithCardButton};
        
        
        //profile image is 8 pts from top and 100 pts tall
        [self.paymentButtonsView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(30)-[payWithCard]-(30)-|"
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
    
    //constraints for initial layout
    [self initialLayout];

    //get and load coach image in background
    PFFile *coachImage = _coachUser[@"photo"];
    _profileImageView.file = coachImage;
    [_profileImageView loadInBackground];
    _profileImageView.image = [UIImage imageNamed:@"profilePlaceholder.png"];
    
    [self makeProfiilePictureACircle];
    
    //set label
    NSString *labelString = [NSString stringWithFormat:@"Team up with %@!", _coachUser[@"firstName"]];
    _titleLabel.text = labelString;
    
    _paymentProcessed = NO;

    [self autolayoutBottomPlan];
    
    _healthyStartView.layer.cornerRadius = 5.0;
    _bootCampView.layer.cornerRadius = 5.0;
    _healthyStartButton.layer.cornerRadius = 3.0;
    _bootCampButton.layer.cornerRadius = 3.0;


    // create effect
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = CGRectMake(0, 0, self.view.bounds.size.width*2, self.view.bounds.size.height);
    
    
    // add the effect view to the image view
    [self.backgroundImage addSubview:effectView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // the only place we can segue is to the trialviewcontroller
    
    TrialViewController *vc = [segue destinationViewController];
    vc.titleString = @"Next Steps";
    vc.buttonString = @"Let's Do this!";
    vc.stepOneString = @"Become Member - You've done this!!";

    
    //set objects for chatroom
    vc.coachUser = _coachUser;
    if(_trainerUser){
        vc.trainerUser = _trainerUser;
    }
    
    if(_gymObject){
        vc.gymObject = _gymObject;
    }
    
}


- (IBAction)buttonPressed:(id)sender {
    //declare new request to be sent to apple
    PKPaymentRequest *request = [Stripe
                                 paymentRequestWithMerchantIdentifier:@"merchant.nomful"];
    
    // Configure your request here
    NSString *label = @"";
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:@"0.00"];

    if (_healthyStartSelected) {
        label   = @"Healthy Start - 30 Day Coaching";
        amount  = [NSDecimalNumber decimalNumberWithString:kINTROAMOUNT];
    }
    
    if (_bootCampSelected) {
        label   = @"Boot Camp - 12 Week Coaching";
        amount  = [NSDecimalNumber decimalNumberWithString:kBOOTCAMPAMOUNT];
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
        [self noApplePay];
    }
    
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    /*
     We'll implement this method below in 'Creating a single-use token'.
     Note that we've also been given a block that takes a
     PKPaymentAuthorizationStatus. We'll call this function with either
     PKPaymentAuthorizationStatusSuccess or PKPaymentAuthorizationStatusFailure
     after all of our asynchronous code is finished executing. This is how the
     PKPaymentAuthorizationViewController knows when and how to update its UI.
     */
    
    NSLog(@"2. Authorize Payment");
    
    [self handlePaymentAuthorizationWithPayment:payment completion:completion];
}

- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment
                                   completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    NSLog(@"3. Create Token");
    
    [[STPAPIClient sharedClient] createTokenWithPayment:payment
                                             completion:^(STPToken *token, NSError *error) {
                                                 if (error) {
                                                     completion(PKPaymentAuthorizationStatusFailure);
                                                     return;
                                                 }
                                                 /*
                                                  We'll implement this below in "Sending the token to your server".
                                                  Notice that we're passing the completion block through.
                                                  See the above comment in didAuthorizePayment to learn why.
                                                  */
                                                 [self createBackendChargeWithToken:token completion:completion];
                                             }];
}

- (void)completePaymentPressed{
    [_ccActivityIndicator startAnimating];
    
    STPCard *card = [[STPCard alloc] init];
    card.number = self.paymentView.card.number;
    card.expMonth = self.paymentView.card.expMonth;
    card.expYear = self.paymentView.card.expYear;
    card.cvc = self.paymentView.card.cvc;
    
    [[STPAPIClient sharedClient] createTokenWithCard:card
                                          completion:^(STPToken *token, NSError *error) {
                                              if (error) {
                                                  //[self handleError:error];
                                              } else {
                                                  
                            
                                                  [self createBackendChargeWithToken:token completion:^(PKPaymentAuthorizationStatus status) {
                                                      
                                                      NSLog(@"token created: %@ %ld", token, (long)status);
                                                      
                                                      if (status == PKPaymentAuthorizationStatusSuccess) {
                                                          //payment complete
                                                          
                                                          NSLog(@"payment worked diggity");
                                                          
                                                          //do something
                                                          
                                                          if(_paymentProcessed){
                                                              
                                                              [_ccActivityIndicator stopAnimating];
                                                
                                                              if (_trialDidEnd) {
                                                                  //dismiss view
                                                                  [self dismissViewControllerAnimated:true completion:^{
                                                                      //
                                                                  }];
                                                                  
                                                              }else{
                                                                  [self performSegueWithIdentifier:@"setExpectationSegue" sender:self];
                                                                  
                                                                  //save user on the gym member table too
                                                                  //the reason we do this is so that when we have users like philly phitness
                                                                  //try to log in, we can check to see if their phone exists before sending to payment
                                                                  [self makeMember];
                                                              }
                                                              
                                                            
                                                          }

                                                          
                                                      }else{
                                                          //something went horribly wrong
                                                          NSLog(@"fuck man you're broke");
                                                      }
                                                      
                                                  }];
                                              }
                                          }];
}


- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    NSLog(@"4. Send token to backend %@", token.tokenId);
    
    NSString *plan = @"";
    
    if(_bootCampSelected){
        plan = kBOOTCAMPAMOUNT;
    }else{
        plan = kINTROAMOUNT;
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
                                        completion(PKPaymentAuthorizationStatusSuccess);
                                    }
                                    else{
                                        NSLog(@"ERROR: %@", error);
                                        completion(PKPaymentAuthorizationStatusFailure);
                                    }
                                }];
    
    
}


- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    NSLog(@"5. Did finish payment");
    
    //called when payment is finished being processed
    //OR
    //when user selects cancel....stupid ass bitch of a method
    
    //dismiss the apple pay sheet that pops up :) SEEEEEE YA!
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //if payment success then leave
    if(_paymentProcessed){
        
        [self performSegueWithIdentifier:@"setExpectationSegue" sender:self];
        
        //save user on the gym member table too
        //the reason we do this is so that when we have users like philly phitness
        //try to log in, we can check to see if their phone exists before sending to payment
        [self makeMember];
        
    }
   

    //payment complete...do something here
    //maybe go somewhere
    //show something
    
    
}

- (void)makeMember{
    //add user to GymMember table
    
    PFObject *gymMember = [[PFObject alloc] initWithClassName:@"GymMembers"];
    
    //gymMember[@"GymObjects"] = _gymObject;
    gymMember[@"clientObject"] = [PFUser currentUser];
    gymMember[@"userPhone"] = [PFUser currentUser][@"phoneNumber"];
    [gymMember saveEventually];

    //mark as verified and paid user
    if(_bootCampSelected) {
        [PFUser currentUser][@"planType"] = @"bootcamp"; //this can be either 'trial' 'intro' or 'bootcamp'
    }else if(_healthyStartSelected){
        [PFUser currentUser][@"planType"] = @"intro"; //this can be either 'trial' 'intro' or 'bootcamp'
    }
    
    [[PFUser currentUser] saveEventually];
}

#pragma mark - Pay With Card

- (IBAction)payCardButtonPressed:(id)sender {
    [self noApplePay];
}

- (void)paymentView:(PTKView *)view withCard:(PTKCard *)card isValid:(BOOL)valid
{
    NSLog(@"card is valid");
    // Toggle navigation, for example
    _saveCardButton.enabled = valid;
    [_saveCardButton setAlpha:1.0];

    
}

-(void)makeProfiilePictureACircle{
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    
}


- (IBAction)healthyStartButtonPressed:(id)sender {
    
    NSLog(@"boot camp pressed");

    //make payment buttons visible
        [self animatePaymentOptions];
    
    
    //make the healthy start plan look like we just selected it
    _healthyStartView.alpha = 1.0;
    _bootCampView.alpha = .5;
    
    //set bool for checkout
    _bootCampSelected = false;
    _healthyStartSelected = true;
    
}

- (IBAction)bootCampButtonPressed:(id)sender {
    
    NSLog(@"boot camp pressed");
    _paymentView.hidden = false;

    //make payment buttons visible
    if(!_paymentOptionsShowing){
        [self animatePaymentOptions];
    }
    
    
    //make the healthy start plan look like we just selected it
    _healthyStartView.alpha = .5;
    _bootCampView.alpha = 1.0;

    
    
    //set bool for checkout
    _healthyStartSelected = false;
    _bootCampSelected = true;
    
}

- (void)animatePaymentOptions{
    
    _paymentButtonsView.hidden = false;
    
    //view is the thing we want to move around based on keyboard showing or not showing
    NSDictionary *views = @{@"view": self.bootCampView,
                            @"payment": _paymentButtonsView};
    
    [self.view removeConstraints:self.bootcampBottomConstraint];

    self.bootcampBottomConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[view]-(10)-[payment]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:views];
    
    [self.view addConstraints:self.bootcampBottomConstraint];
    
    
    [UIView animateWithDuration:0.5
                     animations:^{
                        [self.view layoutIfNeeded]; // Called on parent view
                     }];
    

    
    
}

-(void)autolayoutBottomPlan{
    
   

    //view is the thing we want to move around based on keyboard showing or not showing
    NSDictionary *views = @{@"view": self.bootCampView};
     
    
    
    self.bootcampBottomConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[view]-(10)-|"
                                            options:0
                                            metrics:nil
                                              views:views];
    
    
    
    [self.view addConstraints:self.bootcampBottomConstraint];
    
}


- (void)noApplePay{
    NSLog(@"no apple pay");
 
    //show close button
    _closeButton.hidden = false;
    
    //animte up
    [self animatePlansUp];
    
    //then add field and buttons
    [self addPaymentViews];
    
    //then do autolayout of those items
    [self paymentViewsAutolayout];
    
    [_bootCampButton setTitle:@"Package Selected" forState:UIControlStateNormal];
    [_healthyStartButton setTitle:@"Package Selected" forState:UIControlStateNormal];
    
    _bootCampButton.enabled = false;
    _healthyStartButton.enabled = false;

}

- (void)addPaymentViews{
    
    //let's remove the coach pictrue and label
    _profileImageView.hidden = true;
    _titleLabel.hidden = true;
    
    //show the payment thing
    PTKView *view = [[PTKView alloc] initWithFrame:CGRectMake(50,0,290,55)];
    self.paymentView = view;
    self.paymentView.delegate = self;
    self.paymentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.paymentView becomeFirstResponder];
    [self.view addSubview:self.paymentView];
    
    //button
    _saveCardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    _saveCardButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_saveCardButton setTitle:@"Complete Payment" forState:UIControlStateNormal];
    [_saveCardButton setAlpha:.6];
    [_saveCardButton setBackgroundColor:[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0]];
    _saveCardButton.layer.cornerRadius = 4.0;
    _saveCardButton.enabled = false;
    [_saveCardButton addTarget:self action:@selector(completePaymentPressed) forControlEvents:UIControlEventTouchDown];
    
    [self.view addSubview:_saveCardButton];
    
    //activity indicator
    _ccActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    _ccActivityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    _ccActivityIndicator.hidesWhenStopped = YES;
    _ccActivityIndicator.color = [UIColor whiteColor];
    [self.view addSubview:_ccActivityIndicator];
    
}

- (void)paymentViewsAutolayout{
    //this calculates the x position by taking the entire width of the screen and subtracting
    //the width of the payment view...then we divide by two to get margin on each side
    double totalMargin = (self.view.bounds.size.width) - (_paymentView.bounds.size.width);
    NSNumber *oneMargin = [NSNumber numberWithDouble:totalMargin/2];
    
    
    NSDictionary *views = @{@"ccfield": self.paymentView,
                            @"label": _titleLabel,
                            @"button":_saveCardButton,
                            @"indicator": _ccActivityIndicator,
                            @"healthyStart": _healthyStartView,
                            @"bootCamp": _bootCampView};
    
    
    NSDictionary *metrics = @{@"margins":oneMargin};
    
    
    //now let's alignt the payment field and the button and activity indicator
    //to be below the selected plan which is aligned at the top of the view
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margins)-[ccfield]-(margins)-|"
                                                                       options:0
                                                                       metrics:metrics
                                                                         views:views]];
    if(_bootCampSelected){
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[bootCamp]-(15)-[ccfield]-(55)-[button]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:views]];
    }else{
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[healthyStart]-(15)-[ccfield]-(55)-[button]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:views]];
    }
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(200)]-(10)-[indicator]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:[ccfield]-(60)-[indicator]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_saveCardButton
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f constant:0.0f]];
    
    
    

}
- (void)animatePlansUp{
    NSDictionary *views = @{
                            @"healthyStart": _healthyStartView,
                            @"bootCamp": _bootCampView};
    

    if(_bootCampSelected){
        
        //remove healthy start from view
        _healthyStartView.hidden = true;
        
        //remove bottom constraint
        [self.view removeConstraints:_bootcampBottomConstraint];
        [self.view removeConstraints:_healthyStartBottomConstraint];
        
        _bootcampBottomConstraint =[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(50)-[bootCamp]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:views];
        [self.view addConstraints:_bootcampBottomConstraint];
        
        
        
        
    }else{
        //healhty start selecte
        
        //move bootcamp
        _bootCampView.hidden = true;
        
        
        //remove the constraint between healhty start and bootcamp since bootcamp doesnt exist anymore
        [self.view removeConstraints:_healthyStartBottomConstraint];
        
        _healthyStartBottomConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(50)-[healthyStart]"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:views];
        [self.view addConstraints:_healthyStartBottomConstraint];
        
        
    }
    
    
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded]; // Called on parent view
                     }];
}

- (void)initialLayout{
    
    NSDictionary *views = @{@"profileImage": _profileImageView,
                            @"titleLabel": _titleLabel,
                            @"healthyStart": _healthyStartView,
                            @"bootCamp": _bootCampView};
    
    
    //profile image is 8 pts from top and 100 pts tall
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(20)-[profileImage(106)]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    _healthyStartBottomConstraint = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[healthyStart]-(5)-[bootCamp]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views];
    
    [self.view addConstraints:_healthyStartBottomConstraint];

    
    //profile image is 100 pts wide
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[profileImage(106)]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //profile image is 100 pts wide
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[profileImage]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:views]];
    
    //center profile image horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:_profileImageView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f constant:0.0f]];
    
    
}
- (IBAction)closeButtonPresed:(id)sender {
    
    //remove pkpayment view
    [_paymentView removeFromSuperview];
    [_saveCardButton removeFromSuperview];
    
    _profileImageView.hidden = false;
    _titleLabel.hidden = false;
    
    [_bootCampButton setTitle:@"Sign Me Up!" forState:UIControlStateNormal];
    [_healthyStartButton setTitle:@"Sign Me Up!" forState:UIControlStateNormal];
    
    _bootCampButton.enabled = true;
    _healthyStartButton.enabled = true;

    
    [self.view removeConstraints:_healthyStartBottomConstraint];
    
    //bring back the other view
    if(_bootCampSelected){
        //show the healhty start plan
        _healthyStartView.hidden = false;
        [self animatePaymentOptions];
        
    }else{
        //show the bootcamp view
        _bootCampView.hidden = false;
    }
    
    [self initialLayout];
    [UIView animateWithDuration:0.5
                     animations:^{
                         [self.view layoutIfNeeded]; // Called on parent view
                     }];

}

- (UIButton *)makeApplePayButton {
    UIButton *button;
    
    if ([PKPaymentButton class]) { // Available in iOS 8.3+
        button = [PKPaymentButton buttonWithType:PKPaymentButtonTypeBuy style:PKPaymentButtonStyleWhiteOutline];
    } else {
        // TODO: Create and return your own apple pay button
        [button setBackgroundImage:[UIImage imageNamed:@"ApplePayBTN_64pt__whiteLine_textLogo_"] forState:UIControlStateNormal];
    }
    
   [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.translatesAutoresizingMaskIntoConstraints = false;
    return button;
}
@end

