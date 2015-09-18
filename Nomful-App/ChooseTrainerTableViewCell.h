//
//  ChooseTrainerTableViewCell.h
//  RealDietitian
//
//  Created by Sean Crowe on 3/24/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseTrainerTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *trainerImageView;
@property (weak, nonatomic) IBOutlet UILabel *trainerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *trainerEmployerLabel;

@end
