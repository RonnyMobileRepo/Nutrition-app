//
//  MessagesViewController.h
//  RealDietitian
//
//  Created by Sean Crowe on 2/20/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//


// Import all the things
#import "JSQMessages.h"
#import <Parse/Parse.h>
#import  "Reachability.h"
#import "GAITrackedViewController.h"
#import "PageViewController.h"
#import "LogMealSinglePageViewController.h"

@class MessagesViewController;

@protocol MessagesViewControllerDelegate <NSObject>

//- (void)didDismissJSQDemoViewController:(MessagesViewController *)vc;

@end


@interface MessagesViewController : JSQMessagesViewController <UIActionSheetDelegate, UIPageViewControllerDelegate>

@property (weak) id<MessagesViewControllerDelegate> delegateModals;
@property (weak) id<MessagesViewControllerDelegate> delegates;

@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (strong, nonatomic) PFObject *chatroomObject;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) PFUser *withUser;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property BOOL youAreDietitian;
@property (strong, nonatomic) PFObject *chatroomObjectFromList;
@property (strong, nonatomic) NSTimer *chatsTimer;
@property bool isLoading;

@property (strong, nonatomic) NSMutableDictionary *avatars;

@property (strong, nonatomic) NSMutableDictionary *PFavatars;

@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@property bool isSending;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *didPressLeftItem;
- (IBAction)didPressBack:(id)sender;

@end

