//
//  stripeViewController.m
//  Nomful
//
//  Created by Sean Crowe on 7/1/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "stripeViewController.h"

@interface stripeViewController ()

@end

@implementation stripeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)buttonPressed:(id)sender {
    
    //declare new request to be sent to apple
    PKPaymentRequest *request = [Stripe
                                 paymentRequestWithMerchantIdentifier:@"merchant.nomful"];
    
    // Configure your request here
    NSString *label = @"Premium Llama Food";
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:@"10.00"];
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
        // Show the user your own credit card form (see options 2 or 3)
        NSLog(@"didn't work");
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

- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    
    NSLog(@"4. Send token to backend %@", token.tokenId);
    
    //call cloud code function chargeCard in main.js and pass is the credit card token
    [PFCloud callFunctionInBackground:@"chargeCard"
                       withParameters:@{@"token": token.tokenId
                                        }
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        NSLog(@"RESULT IS: %@", result);
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
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
