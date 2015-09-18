//
//  SignUpLandingVideoViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 3/30/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "SignUpLandingVideoViewController.h"

@interface SignUpLandingVideoViewController ()

@end

@implementation SignUpLandingVideoViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // Do any additional setup after loading the view.
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testing" ofType:@"gif"];
//    NSData *gif = [NSData dataWithContentsOfFile:filePath];
//    
//    UIWebView *webViewBG = [[UIWebView alloc] initWithFrame:self.view.frame];
//    [webViewBG loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
//    webViewBG.userInteractionEnabled = NO;
//    [self.view addSubview:webViewBG];
//    

    

}
- (void)viewDidLoad {
    [super viewDidLoad];
    _tagLabel.adjustsFontSizeToFitWidth = YES;
    _signupButton.layer.cornerRadius = 4.0;
    _loginButton.layer.cornerRadius = 4.0;
    
 
    // Do any additional setup after loading the view.
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"testing" ofType:@"gif"];
//    NSData *gif = [NSData dataWithContentsOfFile:filePath];
//    
//    UIWebView *webViewBG = [[UIWebView alloc] initWithFrame:self.view.frame];
//    [webViewBG loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
//    webViewBG.userInteractionEnabled = NO;
//    [self.view addSubview:webViewBG];
//    
    

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
