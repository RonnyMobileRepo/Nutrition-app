//
//  ChooseTrainerTableViewCell.m
//  RealDietitian
//
//  Created by Sean Crowe on 3/24/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "ChooseTrainerTableViewCell.h"

@implementation ChooseTrainerTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self makeProfiilePictureACircle];

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    
//    [self makeProfiilePictureACircle];
//
//    return self;
//
//}

-(void)makeProfiilePictureACircle{
    
    self.trainerImageView.layer.cornerRadius = self.trainerImageView.frame.size.width / 2;
    self.trainerImageView.clipsToBounds = YES;
    
    
}


@end
