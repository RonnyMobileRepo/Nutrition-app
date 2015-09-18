//
//  SettingsTableViewController.m
//  Nomful
//
//  Created by Sean Crowe on 6/4/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "SettingsTableViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            //NSForegroundColorAttributeName: [UIColor greenColor],
                                                            NSFontAttributeName: [UIFont fontWithName:kFontFamilyName size:20.0f]                                                            }];
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 7;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //get the cell that we just selected
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellID = cell.reuseIdentifier;
    
    if([cellID isEqualToString:@"signOut"]){
        [self signOutSelected];
    }
    
    if([cellID isEqualToString:@"giveFeedback"]){
        [self sendFeedbackEmail];
    }
    
    if([cellID isEqualToString:@"technicalSupport"]){
        [self sendSupportEmail];
    }
    
    if([cellID isEqualToString:@"reportBug"]){
        [self sendBugEmail];
    }
}


#pragma mark - Cell Selected Methods


- (void)signOutSelected{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Are you sure you want to logout?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
    
    [alert show];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        NSNull *null = [[NSNull alloc] init];
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        
        currentInstallation[@"user"] = null;
        [currentInstallation save];
        
        [self performSegueWithIdentifier:@"loggedOutSegue" sender:self];
        [PFUser logOut];
        [Intercom reset];
        
        
    }
}

- (void)sendFeedbackEmail{
    
    // Email Subject
    NSString *emailTitle = @"Nomful Feedback";
    // Email Content
    NSString *messageBody = @"Nomful Team:";
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

- (void)sendSupportEmail{
    
    // Email Subject
    NSString *emailTitle = @"Tech Support";
    // Email Content
    NSString *messageBody = @"Nomful Team:";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"support@nomful.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
    
}

- (void)sendBugEmail{
    
    // Email Subject
    NSString *emailTitle = @"Nomful Bug";
    // Email Content
    NSString *messageBody = @"Nomful Team - I found a very Nomful bug:";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"bugs@nomful.com"];
    
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


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeButtonPressed:(id)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

}
@end
