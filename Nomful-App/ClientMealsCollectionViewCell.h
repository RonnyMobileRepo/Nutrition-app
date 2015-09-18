//
//  ClientMealsCollectionViewCell.h
//  RealDietitian
//
//  Created by Sean Crowe on 4/15/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClientMealsCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet PFImageView *mealImageView;
@property (weak, nonatomic) IBOutlet UILabel *mealTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *hashtagLabel;

@end
