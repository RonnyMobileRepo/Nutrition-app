//
//  fullSizeImageViewController.h
//  RealDietitian
//
//  Created by Sean Crowe on 2/23/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class fullSizeImageViewController;

@protocol fullSizeImageDelegate <NSObject>

- (void)didDismissFullSizeImageDelegate:(fullSizeImageViewController *)vc;

@end

@interface fullSizeImageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic)  UIImage *image;


@property (weak) id<fullSizeImageDelegate> delegateModals;
@property (weak) id<fullSizeImageDelegate> delegates;

@end
