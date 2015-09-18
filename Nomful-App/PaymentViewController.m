//
//  PaymentViewController.m
//  Nomful
//
//  Created by Sean Crowe on 8/5/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "PaymentViewController.h"

@interface PaymentViewController ()

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add subview for payment form
    [super viewDidLoad];
    PTKView *view = [[PTKView alloc] initWithFrame:CGRectMake(50,200,290,55)];
    self.paymentView = view;
    self.paymentView.delegate = self;
    [self.view addSubview:self.paymentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)paymentView:(PTKView *)view withCard:(PTKCard *)card isValid:(BOOL)valid
{
    // Toggle navigation, for example
    self.saveButton.enabled = valid;

}

- (IBAction)saveButtonPressed:(id)sender {
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
                                                      
                                                      if (status == PKPaymentAuthorizationStatusSuccess) {
                                                          //payment complete
                                                          
                                                          //
                                                          
                                                          //do something
                                                          
                                                          //
                                                          
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
                                        NSLog(@"Backend ERROR: %@", error);
                                        completion(PKPaymentAuthorizationStatusFailure);
                                    }
                                }];
    
}
@end
