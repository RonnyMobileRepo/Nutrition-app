//
//  Chatview.h
//  Nomful-App
//
//  Created by Sean Crowe on 9/28/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "JSQMessages.h"
#import "LogMealSinglePageViewController.h"




@interface Chatview : JSQMessagesViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic,strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) PFObject *chatroomObject;
- (id)initWith:(NSString *)groupId_;

@end
