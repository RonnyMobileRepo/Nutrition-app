//
//  LandingPageViewController.m
//  Nomful-App
//
//  Created by Sean Crowe on 12/3/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "LandingPageViewController.h"
#import "AppDelegate.h"


@interface LandingPageViewController ()

@end

@implementation LandingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //clear navigation on the marketing/education screens
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    //button styling
    _getStartedButton.layer.cornerRadius = 4.0;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)getStartedButtonPressed:(id)sender {
    
    //send event to mixpanel that we've started the signup process
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"SignUp Started"];
    
    
    
}

- (IBAction)memberLoginButtonPressed:(id)sender {
}
@end
