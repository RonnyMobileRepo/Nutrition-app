//
//  MessagesViewController.m
//  RealDietitian
//
//  Created by Sean Crowe on 2/20/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "MessagesViewController.h"
//#import <Crashlytics/Crashlytics.h>

@interface MessagesViewController ()

@end


@implementation MessagesViewController

#pragma mark - View lifecycle

/**
 *  Override point for customization.
 *
 *  Customize your view.
 *  Look at the properties on `JSQMessagesViewController` and `JSQMessagesCollectionView` to see what is possible.
 *
 *  Customize your layout.
 *  Look at the properties on `JSQMessagesCollectionViewFlowLayout` to see what is possible.
 */


- (void)viewDidLoad
{
    [super viewDidLoad]; //****
    
    NSLog(@"sean you made it");
    
    [self checkNetworkStatus];
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont fontWithName:kFontFamilyName size:15.0];
    //global nav bar
    
    //reset badge count
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    

    
    //self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    //initialize the messages array to display the messages in UI
    self.messagesArray = [[NSMutableArray alloc] init];
    self.avatars = [[NSMutableDictionary alloc] init];
    
    self.isSending = NO;
    //get the chatroom object
    
    if(!self.youAreDietitian){
        NSLog(@"You are NOT a dietitian: %d", self.youAreDietitian);
        
        //you are not a client user...so we can just query for chatroom
        
        PFQuery *query = [PFQuery queryWithClassName:@"Chatrooms"];
        [query whereKey:@"clientUser" equalTo:[PFUser currentUser]];
        //query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
           
            if(!error){
                NSLog(@"Success! You have found the chatroom object");
                
                //we've found the chatroom object
                //now lets set that to the public variable
                self.chatroomObject = object;
                [self getTheAvatars];
                //now we have all the data we need, so let's start the load timer
                //make sure to do this in the main thread so we can invalidate it later
                
                [self loadMessages:NO];
                 [self startTimer];
                    NSLog(@"You have all the data, now start the initial timer!");
                    
                    
                    //put these here so that the timer isn't started prematurley on initial load 'enter foreground'
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(didEnterBackground)
                                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(didEnterForeground)
                                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
                    


            }//end !error
            
            
        }]; //end get first object
        
    }//endif
    else{
        //you are not a client, so we need to get the chatroom object from clientdetailsviewcontroller
        NSLog(@"Messages: You are a someone other than a client %@", _chatroomObjectFromList);
        self.chatroomObject =  self.chatroomObjectFromList;
        [self getTheAvatars];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadMessages:NO];
            [self startTimer];
            //put these here so that the timer isn't started prematurley on initial load 'enter foreground'
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didEnterBackground)
                                                         name:UIApplicationDidEnterBackgroundNotification object:nil];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didEnterForeground)
                                                         name:UIApplicationDidBecomeActiveNotification object:nil];
            

        });//end main thread

    
    }
    
    //important to set the sender id
    self.senderId = [PFUser currentUser].objectId;
    self.senderDisplayName = @"";
    
    self.showLoadEarlierMessagesHeader = YES;
    
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0]];
                                    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(40, 40);
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;

     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkforBadgeValue) name:@"updateBarButtonBadge" object:nil];
        //listen for the app to enter background
    
    
    /**
     *  Customize your toolbar buttons
     *
     *  self.inputToolbar.contentView.leftBarButtonItem = custom button or nil to remove
     *  self.inputToolbar.contentView.rightBarButtonItem = custom button or nil to remove
     */
    
    self.currentUser = [PFUser currentUser];
    if([self.currentUser[@"role"] isEqualToString:@"RD"]){
        //add phone button for calling
        UIBarButtonItem *rightPhone = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"phone-barbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(callClient)];
    
        self.navigationItem.rightBarButtonItem = rightPhone;
        
        //if current user is a coach...
        //they just opened the messages view
        //let's set the chatroom as READ
        [self markMessageAsUnread:false];
    }
}

- (void)callClient{
    //only show if the user is an RD
    
        NSLog(@"You pressed the phone button! Woot woot!");
    
        NSString *phoneNumber = self.chatroomObject[@"twilioNumber"];
        NSString *cleanedPhone = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
        
        NSString *phoneNumbers = [@"tel://" stringByAppendingString:cleanedPhone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumbers]];
    
    //mixpanel tracking
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel timeEvent:@"Phone Call"];
    
}


- (void)checkforBadgeValue{
    [self loadMessages:YES];

    
}
- (void)scrollToBottomAnimated:(BOOL)animated
{
    if ([self.collectionView numberOfSections] == 0) {
        return;
    }
    
    NSInteger items = [self.collectionView numberOfItemsInSection:0];
    
    if (items > 0) {
        [self.collectionView layoutIfNeeded];
        CGRect scrollRect = CGRectMake(0, self.collectionView.contentSize.height - 1.f, 1.f, 1.f);
        [self.collectionView scrollRectToVisible:scrollRect animated:animated];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"will appear");

    if(self.messagesArray.count != 0){
        [self startTimer];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollToBottomAnimated:YES];
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"will diessapear");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatsTimer invalidate];
    });
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
  
}

-(void)viewDidDisappear:(BOOL)animated{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatsTimer invalidate];
    });
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}


-(void)startTimer{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.chatsTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                           target:self
                                                         selector:@selector(loadMessagesFromTimer)
                                                         userInfo:nil
                                                          repeats:YES];
    });
}

- (void)loadMessagesFromTimer{
    
    [self loadMessages:NO];
    
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    
    //check if you are currentcly trying to send a message
    //check if the network is available
    
    if(![self checkNetworkStatus] && !self.isSending){
        
        //tell the world you are sending a message so you don't try to send one during one sending
        self.isSending = YES;
        
        //plays a cool little jingle...we should totes make our own
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
        
        //build the message object
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                                 senderDisplayName:senderDisplayName
                                                              date:date
                                                              text:text];
        
        //put the message object in the local array
        [self.messagesArray addObject:message];
        
        ///do parse stuff//
        //DETERMINES WHICH USER IS IN USER1 COLUMN AND WHICH IS IN USER2
        
        //set the current user
        self.currentUser = [PFUser currentUser];
        
        //declare push variables for use in if statements
        PFQuery *pushQuery = [PFInstallation query];
        NSDictionary *data = [[NSDictionary alloc] init];
        
        //get the client user object from the chatRoom
       // PFUser *testUser1 = self.chatroomObject[@"clientUser"];
        
        //if the client object from chatroom is the same as the current user
        //then the current user is the client!
        if ([self.currentUser[@"role"] isEqualToString:@"Client"]){
            
            //set the 'withUser' to the dietitian
            self.withUser = self.chatroomObject[@"dietitianUser"];
            
            //we are a client right now...sending a new message to a coach
            //set the new message as unread since the coach hasn't seen it yet
            [self markMessageAsUnread:true];
            
            //RD gets a push and a badge
            [pushQuery whereKey:@"user" equalTo:self.withUser];
            
            //build the string for the push message to be shown
            NSString *name = [NSString stringWithFormat:@"You have a new messages from %@", self.currentUser[@"firstName"]];
            
            //set the data info for the push
            data = [NSDictionary dictionaryWithObjectsAndKeys:
                    name, @"alert",
                    @1, @"badge",
                    @"default", @"sound",
                    @"message", @"type",
                    nil];

        }else if([self.currentUser[@"role"] isEqualToString:@"RD"]) {
            //the current user is an RD
            
            //the message must be being sent to the client
            self.withUser = self.chatroomObject[@"clientUser"];
            
            //Client gets a push and a badge
            [pushQuery whereKey:@"user" equalTo:self.withUser];
            
            //build the string for the push message to be shown
            NSString *name = [NSString stringWithFormat:@"You have a new messages from %@", self.currentUser[@"firstName"]];
            
            //set the data info for the push
            data = [NSDictionary dictionaryWithObjectsAndKeys:
                    name, @"alert",
                    @1, @"badge",
                    @"default", @"sound",
                    @"message", @"type",
                    nil];

            
        }else if([self.currentUser[@"role"] isEqualToString:@"PT"]){
            //the current user is a PT
            
            //the message must be sent to a client
            self.withUser = self.chatroomObject[@"clientUser"];

            //Client gets a push and a badge
            [pushQuery whereKey:@"user" equalTo:self.withUser];
            
            //build the string for the push message to be shown
            NSString *name = [NSString stringWithFormat:@"You have a new messages from %@", self.currentUser[@"firstName"]];
            
            //set the data info for the push
            data = [NSDictionary dictionaryWithObjectsAndKeys:
                    name, @"alert",
                    @1, @"badge",
                    @"default", @"sound",
                    nil];
            
            //??//
            //RD gets a badge
            //RD gets an indicator

        }
        
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery];
        [push setData:data];
        [push sendPushInBackground];
        
        //create a PFMessage object and set values
        PFObject *sendMessage = [[PFObject alloc] initWithClassName:@"Messages"];
        sendMessage[@"chatroom"] = self.chatroomObject;
        sendMessage[@"fromUser"] = self.currentUser;
        sendMessage[@"toUser"] = self.withUser;
        sendMessage[@"content"] = text;
        
        
        //save the message on parse
        [sendMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            //some jsqmessages thing
            [self finishSendingMessageAnimated:YES];
            
            //tells the world that you are no longer sending a message. Woot woot toot toot
            self.isSending = NO;
        }];

    }
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Media messages"
//                                                       delegate:self
//                                              cancelButtonTitle:@"Cancel"
//                                         destructiveButtonTitle:nil
//                                              otherButtonTitles:@"Send photo", @"Send location", @"Send video", nil];
//    
//    [sheet showFromToolbar:self.inputToolbar];
//    
//    [self finishSendingMessage];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            //show library picker for image
            
            break;
            
        case 1:
        {
            //__weak UICollectionView *weakView = self.collectionView;
            
//            [self.demoData addLocationMediaMessageCompletion:^{
//                [weakView reloadData];
//            }];
        }
            break;
            
        case 2:
           // [self.demoData addVideoMediaMessage];
            break;
    }
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated:YES];
}



#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return [self.messagesArray objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.messagesArray objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.messagesArray objectAtIndex:indexPath.item];
    //NSLog(@"AVATAR ARRAY IS: %@", self.avatars);
    
    return [self.avatars objectForKey:message.senderId];
    

}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messagesArray objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messagesArray objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messagesArray objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messagesArray count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.messagesArray objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messagesArray objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messagesArray objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
    //load more messages
    [self loadMessages:YES];
    
    
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}


#pragma mark - Sean Added Here!
-(void)loadMessages:(bool)loadEarlier{
    
    if(self.isLoading == YES){
        //don't do anything!!
        NSLog(@"You are trying to load but you are already loading");
    }else{
        
        //we are loading the messages
        self.isLoading = YES;
        //[self.messagesArray removeAllObjects];
        PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
        [query whereKey:@"chatroom" equalTo:self.chatroomObject];
        [query includeKey:@"toUser"];
        [query includeKey:@"fromUser"];
        [query orderByDescending:@"createdAt"];
        //query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        
        if(loadEarlier){
            //you are loading MORE messages by tapping load Earlier button
            //add 15 more to the current number of messages
            query.limit = 15 + self.messagesArray.count;
        
        }else{
            //you are on the screen for first time
            //let's just load 15 :)
            query.limit = 15;
        }
        
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            
            //this is the last object returned from query
            //this is the most recent message sent
            PFObject *lastMessageObject = [objects firstObject];
            NSString *lastMessageQuery = lastMessageObject[@"content"];
            
            //this is the last object displayed to the user
            JSQMessage *lastVisibleObject = [self.messagesArray lastObject];
            NSString *lastVisibleMessage = lastVisibleObject.text;
            
            NSLog(@"query: %@ visible: %@", lastMessageQuery, lastVisibleMessage);
            
            if( ![lastMessageQuery isEqualToString:lastVisibleMessage] ){
                //there is a new message
                [self.messagesArray removeAllObjects];
                for (PFObject *object in [objects reverseObjectEnumerator]){
                    
                    PFUser *fromUser = object[@"fromUser"];
                    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:fromUser.objectId
                                                             senderDisplayName:fromUser[@"firstName"]
                                                                          date:object.createdAt
                                                                          text:object[@"content"]];
                    
                    [self.messagesArray addObject:message];
                    
                    //user is in the messages view and a new message was loaded
                    //if that user is a coach..then we have to mark the new message as read
                    if([self.currentUser[@"role"] isEqualToString:@"RD"]){
                        [self markMessageAsUnread:false];
                    }
                }//end for loop
                
                [self refreshTheTable];
                [self scrollToBottomAnimated:NO];
                NSLog(@"messages are: %@", self.messagesArray);
            }//end if
            else{
                //there is no new messges
                NSLog(@"There are no new messages");
                if(loadEarlier){
                    [self.messagesArray removeAllObjects];
                    
                    for (PFObject *object in [objects reverseObjectEnumerator]){
                        
                        PFUser *fromUser = object[@"fromUser"];
                        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:fromUser.objectId
                                                                 senderDisplayName:fromUser[@"firstName"]
                                                                              date:object.createdAt
                                                                              text:object[@"content"]];
                        
                        [self.messagesArray addObject:message];
                        
                    }//end for loop
                    [self refreshTheTable];
                }
                self.isLoading = NO;
            }
            
        }];
    }
}

-(void)refreshTheTable{
    //we are totall done loading data into the array
    self.isLoading = NO;
    [self.collectionView reloadData];
}
-(void)didEnterBackground{
//    //invalidate chat
    NSLog(@"You just entered the background and invalidated the timer!");

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.chatsTimer invalidate];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Image Upload"];
    });//end main thread
    
    //reset badge count on the app icon
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];

    
    
}

-(void)didEnterForeground{
     NSLog(@"You just entered the foreground and validated the timer!");
    [self startTimer];
    
}

-(void)getTheAvatars{
   
    PFUser *clientUser =  self.chatroomObject[@"clientUser"];
    PFUser *dietitianUser = self.chatroomObject[@"dietitianUser"];
    PFUser *trainerUser = self.chatroomObject[@"trainerUser"];
    [clientUser fetch];
    [dietitianUser fetch];
    [trainerUser fetch];

    
    PFFile *clientImageFile = clientUser[@"photo"];
    PFFile *dietitianImageFile = dietitianUser[@"photo"];
    PFFile *trainerImageFile = trainerUser[@"photo"];

    
    if(clientImageFile){ //if there is data for the photo...go to parse and get the image
        [clientImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                
                JSQMessagesAvatarImage *clientImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:image                                                                                                             diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                [self.avatars setValue:clientImage forKey:clientUser.objectId];
            }//end if error
        }];//end getdata block
    }//end if
    
    if(dietitianImageFile){ //if there is data for the photo...go to parse and get the image
        [dietitianImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                
                JSQMessagesAvatarImage *dietitianImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:image                                                                                                             diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                [self.avatars setValue:dietitianImage forKey:dietitianUser.objectId];
                }//end if error
        }];//end getdata block
    }//end if

    
    if(trainerImageFile){ //if there is data for the photo...go to parse and get the image
        [trainerImageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:imageData];
                
                JSQMessagesAvatarImage *trainerImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:image                                                                                                             diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                [self.avatars setValue:trainerImage forKey:trainerUser.objectId];
                
                NSLog(@"you got an image!");
            }//end if error
        }];//end getdata block
    }//end if

   
}

-(bool)checkNetworkStatus{

    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    if([self stringFromStatus:status] != nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Internet Connection Problem!"
                                                        message:[self stringFromStatus:status] delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return true;
    }else{
        return false;
    }
    
}

- (NSString *)stringFromStatus:(NetworkStatus) status {
    
    NSString *string;
    switch(status) {
        case NotReachable:
            string = @"Sorry, you don't have network access at this time. Please check wifi and cellular settings.";
            break;
        case ReachableViaWiFi:
            string = nil;
            break;
        case ReachableViaWWAN:
            string = nil;
            break;
        default:
            string = nil;
            break;
    }
    return string;
}

- (IBAction)didPressBack:(id)sender{
    NSLog(@"back button pressed");
    
    PageViewController *vc = [[PageViewController alloc] init];
    
   
    [vc goToPreviousVC];
    
}

- (void)markMessageAsUnread:(bool)isUnread{
    
    //there is a new message that loaded in the view
    //mark it as read
    
    NSNumber *isUnreadNum = [[NSNumber alloc] initWithBool:isUnread];
    self.chatroomObject[@"isUnread"] = isUnreadNum;
    [self.chatroomObject saveInBackground];
    
}



@end
