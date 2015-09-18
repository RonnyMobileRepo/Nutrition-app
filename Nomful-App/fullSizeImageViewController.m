//
//  fullSizeImageViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 2/23/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "fullSizeImageViewController.h"

@interface fullSizeImageViewController ()

@end

@implementation fullSizeImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image = self.image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.imageView.frame = CGRectMake(10,10,self.view.frame.size.width-20, self.view.frame.size.height-20);


}


- (void)addConstraints {
    
    [self.view addConstraint:
     [NSLayoutConstraint
      constraintWithItem:self.imageView
      attribute:NSLayoutAttributeCenterX
      relatedBy:NSLayoutRelationEqual
      toItem:self.view
      attribute:NSLayoutAttributeCenterX
      multiplier:1
      constant:0]];
    
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
