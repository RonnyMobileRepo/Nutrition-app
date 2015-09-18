//
//  ManageSubscriptionViewController.m
//  Nomful
//
//  Created by Sean Crowe on 7/6/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "ManageSubscriptionViewController.h"

@interface ManageSubscriptionViewController ()

@end

@implementation ManageSubscriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _daysLeftLabel.text = @"";
    
    PFUser *currentUser = [PFUser currentUser];
    [currentUser fetch];
    

    if([currentUser[@"role"] isEqualToString:@"RD"]){
        //user is a coach..we need to change the UI a bit
        
        //get the day they started working
        NSDate *startDate = currentUser[@"membershipStartDate"];
        NSDate *today = [NSDate date];
        
        //find how long that's been
        NSInteger daysAsCoach = [self daysBetweenDate:startDate andDate:today];
        NSString *daysAsCoachString = [[NSString alloc] init];
        daysAsCoachString = [NSString stringWithFormat:@"%ld", (long)daysAsCoach];
        
        //set string
        _daysLeftLabel.text = daysAsCoachString;
        _messageLabel.text = @"Days as Nomful Coach";
        _cancelMembershipButton.hidden = YES;
        
        
    }else{
        NSDate *startDate = currentUser[@"membershipStartDate"];
        NSDate *today = [NSDate date];
        
        NSInteger days = (30 - [self daysBetweenDate:startDate andDate:today]);
        NSString *daysLeft = [[NSString alloc] init];
        
        if(days > 0){
            //still active
            daysLeft =  [NSString stringWithFormat:@"%ld", (long)days];
            _daysLeftLabel.text = daysLeft;
        }else if(days <= 0 ){
            //inactive user
            
            _daysLeftLabel.text = [NSString stringWithFormat:@"%ld", days];
            _daysLeftLabel.textColor = [UIColor redColor];
        }
        

    }
    
    
}


- (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}


- (IBAction)cancelMembershipButtonPressed:(id)sender {
    
    // Email Subject
    NSString *emailTitle = @"Cancel Membership";
    // Email Content
    NSString *messageBody = @"Nomful Team: I would like to cancel my membership for the next billing cycle. ";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"feedback@nomful.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];

}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
