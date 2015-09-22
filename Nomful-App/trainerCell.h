//
//  trainerCell.h
//  Nomful
//
//  Created by Sean Crowe on 8/21/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface trainerCell : UITableViewCell

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *cityLabel;
@property (strong, nonatomic) PFImageView *profileImage;

@end
