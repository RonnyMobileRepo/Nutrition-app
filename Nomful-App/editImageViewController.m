//
//  editImageViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 4/9/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "editImageViewController.h"

@interface editImageViewController ()

@end

@implementation editImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //mealFile was set from previous view. Set the imageview to that file
    self.mealImageView.file = self.mealFile;
    
    //mealDescription was set in last view. Set text to the string passed to us
    self.descriptionTextview.text = self.mealDescription;
    
    //show the keybaord
    [self.descriptionTextview becomeFirstResponder];
    
    //have a save button in the top right and call 'saveChanges' when selected
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:nil action:@selector(saveChanges)];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    //reload the table so content is updated
    //...maybe
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)saveChanges{
    
    [self.descriptionTextview resignFirstResponder];
    
    //get the new string that the user entered into the description text view
    NSString *description = [self.descriptionTextview.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //get current meal object
    PFObject *meal = self.mealObject;
    
    //set the description to the parse object
    meal[@"description"] = description;
    
    //save parse object in background
    [meal saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"you saved it!");
    }];
    

}
@end
