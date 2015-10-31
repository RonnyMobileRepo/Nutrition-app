//
//  CoachBioViewController.h
//  Nomful-App
//
//  Created by Sean Crowe on 10/27/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoachBioViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
- (id)initWith:(PFObject *)coachObject_;
@end
