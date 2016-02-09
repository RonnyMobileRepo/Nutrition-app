//
//  NomberryTableViewCell.m
//  Nomful-App
//
//  Created by Sean Crowe on 2/8/16.
//  Copyright © 2016 Nomful, inc. All rights reserved.
//

#import "NomberryTableViewCell.h"

@implementation NomberryTableViewCell

@synthesize messageLabel = _messageLabel;
@synthesize messageBox = _messageBox;
@synthesize nomberryImageView = _nomberryImageView ;




- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        self.backgroundColor = [UIColor clearColor];

        /////////////////
        //MESSAGE BOX////
        /////////////////
//        self.messageBox = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//        self.messageBox.translatesAutoresizingMaskIntoConstraints = NO;
//        self.messageBox.layer.cornerRadius = 4.0;
//        self.messageBox.clipsToBounds = YES;
//        self.messageBox.backgroundColor = [UIColor lightGrayColor];
//        [self.contentView addSubview:self.messageBox];
    
        
        /////////////////
        //MESSAGE LABEL//
        /////////////////
        self.messageLabel = [[nomberrylabel alloc] initWithFrame:CGRectMake(5, 10, 300, 30)];
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.messageLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.messageLabel setNumberOfLines:0];
        [self.messageLabel setTextAlignment:NSTextAlignmentLeft];
        self.messageLabel.textColor = [UIColor darkGrayColor];
        self.messageLabel.font = [UIFont fontWithName:@"Avenir" size:15.0f];
        self.messageLabel.backgroundColor = [UIColor whiteColor];
        self.messageLabel.layer.cornerRadius = 4.0;
        self.messageLabel.clipsToBounds = YES;
        [self.contentView addSubview:self.messageLabel];
        
    
        /////////////////
        /////NOMBERRY////
        /////////////////
        self.nomberryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nomberry"]];
        self.nomberryImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.nomberryImageView];
        
        
    }
    
    [self setNeedsUpdateConstraints];
    
    return self;
}

- (void)updateConstraints{
    
    NSLog(@"update constraints!!!");
    
    if (!_didUpdateConstraints) {
        
        
        NSDictionary *views = @{@"message": _messageLabel,
                                @"nomberry": _nomberryImageView};
        
        //////////////////
        //MESSAGE BOX/////
        //////////////////
//        [self.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(40)-[messageBox]-(10)-|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:views]];
//        
//        [self.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[messageBox]-(5)-|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:views]];
        
        //////////////////
        //MESSAGE LAABEL//
        //////////////////
        [self.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(50)-[message]-(10)-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
        
        [self.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[message]-(5)-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:views]];
        
        //////////////////
        //NOMBERRY IMAGE//
        //////////////////
        NSLayoutConstraint *yCenterConstraint = [NSLayoutConstraint constraintWithItem:_nomberryImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_messageLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        [self.contentView addConstraint:yCenterConstraint];
        
        [self.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[nomberry]"
                                                                                  options:0
                                                                                  metrics:nil
                                                                                    views:views]];
        
        _didUpdateConstraints = YES;
    }
    [super updateConstraints];

    //constraints here will ALWASY update when called
    
    
    
    
}

@end
