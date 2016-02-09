//
//  NomberryTableViewCell.h
//  Nomful-App
//
//  Created by Sean Crowe on 2/8/16.
//  Copyright © 2016 Nomful, inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "nomberrylabel.h"

@interface NomberryTableViewCell : UITableViewCell

@property (nonatomic, strong) nomberrylabel *messageLabel;
@property (nonatomic, strong) UIView *messageBox;
@property (nonatomic, strong) UIImageView *nomberryImageView;
@property bool didUpdateConstraints;


@end
