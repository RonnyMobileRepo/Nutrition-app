//
//  pagecontentViewController.m
//  Nomful
//
//  Created by Sean Crowe on 7/22/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "pagecontentViewController.h"

@interface pagecontentViewController ()

@end

@implementation pagecontentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //_imgFile = @"sean.jpeg";
    //_txtTitle = @"hello holloh";
    
    self.imageView.image = [UIImage imageNamed:self.imgFile];
    self.label.text = self.txtTitle;
    

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

@end
