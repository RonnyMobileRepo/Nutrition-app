//
//  AvailableClientTableViewCell.m
//  RealDietitian
//
//  Created by Sean Crowe on 2/20/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "AvailableClientTableViewCell.h"

@implementation AvailableClientTableViewCell

- (void)awakeFromNib {
    
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2;
    self.profileImageView.clipsToBounds = YES;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    _membershipLabel.text = @"-";
    _daysLeftLabel.text = @"-";
    _lastSeenLabel.text = @"-";
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
