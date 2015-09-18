//
//  ParseErrorHandlingController.m
//  Nomful
//
//  Created by Sean Crowe on 6/29/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "ParseErrorHandlingController.h"


@implementation ParseErrorHandlingController

+ (void)handleError:(NSError *)error {
    if (![error.domain isEqualToString:PFParseErrorDomain]) {
        return;
    }
    
    switch (error.code) {
        case kPFErrorInvalidSessionToken: {
            [self _handleInvalidSessionTokenError];
            break;
        }
             // Other Parse API Errors that you want to explicitly handle.
    }
}

+ (void)_handleInvalidSessionTokenError {
    
    //https://www.parse.com/docs/ios/guide#sessions
    
    //--------------------------------------
    // Option 1: Show a message asking the user to log out and log back in.
    //--------------------------------------
    // If the user needs to finish what they were doing, they have the opportunity to do so.
    //
//    NSLog(@"the code actually ran!");
//     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Session"
//                                                         message:@"Session is no longer valid, please log out and log in again."
//                                                        delegate:self
//                                               cancelButtonTitle:@"Not Now"
//                                               otherButtonTitles:@"OK", nil];
//     [alertView show];
    
    //--------------------------------------
    // Option #2: Show login screen so user can re-authenticate.
    //--------------------------------------
    // You may want this if the logout button is inaccessible in the UI.
    //
    // UIViewController *presentingViewController = [[UIApplication sharedApplication].keyWindow.rootViewController;
    // PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
    // [presentingViewController presentViewController:logInViewController animated:YES completion:nil];
}

@end