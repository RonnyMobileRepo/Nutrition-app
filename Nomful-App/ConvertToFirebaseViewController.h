//
//  ConvertToFirebaseViewController.h
//  Nomful-App
//
//  Created by Sean Crowe on 10/7/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConvertToFirebaseViewController : UIViewController

- (id)initWith:(NSString *)groupId_;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) UIButton *doneButton;

@end
