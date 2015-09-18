//
//  trainerCell.m
//  Nomful
//
//  Created by Sean Crowe on 8/21/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "trainerCell.h"

@implementation trainerCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    //may have to change this since we're using storyboards?..but not at the same time?
    //init with coder is the other one
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // configure  name label
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 300, 30)];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [UIFont fontWithName:kFontFamilyName size:18.0f];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.nameLabel];
        
        // configure  image
        _trainerProfileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15,10,30,30)];
        _trainerProfileImageView.translatesAutoresizingMaskIntoConstraints = NO;
        _trainerProfileImageView.image = [UIImage imageNamed:@"Sean.jpeg"];
        
       
        
        
        [self addSubview:_trainerProfileImageView];
        
    }

    return self;
}



-(void)updateConstraints{
    // add your constraints
    [super updateConstraints];
    
    NSLog(@"update constraints called");
    
    //dictionary for views to be constrained
    NSDictionary *views = @{@"nameLabel"       :   _nameLabel,
                            @"trainerImage"     :  _trainerProfileImageView
                            };
    
    //trainer image
    
    //5 from top and bottom
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[trainerImage]-(5)-|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:views]];
    
    //5 from top and bottom
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[nameLabel]-(5)-|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:views]];
    
    //5 from left
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(20)-[trainerImage]-(15)-[nameLabel]"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:views]];
    
    //aspect ratio 1:1
    NSLayoutConstraint *constraint =[NSLayoutConstraint
                                     constraintWithItem:_trainerProfileImageView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:_trainerProfileImageView
                                     attribute:NSLayoutAttributeHeight
                                     multiplier:1.0/1.0 //Aspect ratio: 4*height = 3*width
                                     constant:0.0f];
    [_trainerProfileImageView addConstraint:constraint];

}



@end
