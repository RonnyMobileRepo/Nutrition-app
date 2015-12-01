//
//  Chatview.m
//  Nomful-App
//
//  Created by Sean Crowe on 9/28/15.
//  Copyright © 2015 Nomful, inc. All rights reserved.
//

#import "Chatview.h"
#import "Incoming.h"
#import "Outgoing.h"
#import "PhotoMediaItem.h"
#import <IDMPhotoBrowser.h>
#import "CoachBioViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>



@interface Chatview (){
    
    
    //test
    int numberOfMessagesToLoad;
    
    //chatroom ID
    NSString *groupId;
    NSString *messageContent;
    
    //flags
    BOOL initialized;
    BOOL phoneCallActive;
    int typingCounter;
    
    //firebase objects
    Firebase *firebase1;
    
    //message arrays
    NSMutableArray *items;
    NSMutableArray *messages;
    
    //dictionaries
    NSMutableDictionary *started;
    NSMutableDictionary *avatars;
    
    //jsqmessages ui elements
    JSQMessagesBubbleImage *bubbleImageOutgoing;
    JSQMessagesBubbleImage *bubbleImageIncoming;
    JSQMessagesAvatarImage *avatarImageBlank;
    
    MBProgressHUD *hud;
    NSTimer *hudTimer;
    
    int i;
    
}

@end

@implementation Chatview

- (id)initWith:(NSString *)groupId_

{
    self = [super init];
    groupId = groupId_;
    
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel timeEvent:@"Loading Chat"];
    
    
    PFUser *current = [PFUser currentUser];
    
    if ([current[@"role"] isEqualToString:@"Client"]) {
        //if user is client then update!
        PFQuery *query = [PFQuery queryWithClassName:@"Chatrooms"];
        [query fromLocalDatastore];
        [query getObjectInBackgroundWithId:groupId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (object) {
                [object fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    //
                    NSLog(@"chatview: we got the local object");
                    if (!object[@"isOnLatestVersion"]) {
                        object[@"isOnLatestVersion"] = @"YAS";
                        [object saveEventually];
                    }
                }];
                
            }else{
                NSLog(@"chatview: we got to do the network ting");
                
                PFQuery *query = [PFQuery queryWithClassName:@"Chatrooms"];
                [query fromLocalDatastore];
                [query getObjectInBackgroundWithId:groupId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    if (object) {
                        NSLog(@"chatview: we got the local object");
                        if (!object[@"isOnLatestVersion"]) {
                            object[@"isOnLatestVersion"] = @"YAS";
                            [object saveEventually];
                            [object pinInBackground];
                        }
                    
                    }
                }];

                
                
            }
            
    }];
    }
    
    //declare items for memory stuff i still don't get
    items = [[NSMutableArray alloc] init];
    messages = [[NSMutableArray alloc] init];
    started = [[NSMutableDictionary alloc] init];
    avatars = [[NSMutableDictionary alloc] init];

    //set the jsqmessagesviewcontroller senderID and name variable to the object ID of the current user
    self.senderId = [PFUser currentUser].objectId;
    self.senderDisplayName = [PFUser currentUser][@"firstName"];
    
    //set bubble colors
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:126.0/255.0 green:202.0/255.0 blue:175.0/255.0 alpha:1.0]];
    bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];

    //set the avatar image when chat is blank?
    avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"profilePlaceholder.png"] diameter:30.0];

    //set the font for the messages
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont fontWithName:kFontFamilyName size:15.0];

    //**havent used these before. Look into what they do
//    [JSQMessagesCollectionViewCell registerMenuAction:@selector(actionCopy:)];
//    [JSQMessagesCollectionViewCell registerMenuAction:@selector(actionDelete:)];
//    [JSQMessagesCollectionViewCell registerMenuAction:@selector(actionSave:)];
//
//    UIMenuItem *menuItemCopy = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(actionCopy:)];
//    UIMenuItem *menuItemDelete = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(actionDelete:)];
//    UIMenuItem *menuItemSave = [[UIMenuItem alloc] initWithTitle:@"Save" action:@selector(actionSave:)];
//    [UIMenuController sharedMenuController].menuItems = @[menuItemCopy, menuItemDelete, menuItemSave];
    
    //lets go get the chatroom id and upon comletion, load firebase and messages
    //we should make this an initializtion thing like it was before
    
    //delcare firebase connection!
    //url saved in prefixheader and groupid from initialization
    firebase1 = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Message/%@", kFirechatNS, groupId]];

    //load messages
    [self loadMessages];
  
    
    //if there is a badge count...reset it to zero in the background
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    
    if([[PFUser currentUser][@"role"] isEqualToString:@"RD"]){
        UIBarButtonItem *rightPhone = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"phone-barbutton"] style:UIBarButtonItemStylePlain target:self action:@selector(callClient)];
        
        self.navigationItem.rightBarButtonItem = rightPhone;
        
        [self markMessageAsUnread:false];

    }
    
    //put these here so that the timer isn't started prematurley on initial load 'enter foreground'
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterForeground)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];

    
    
    
}

- (void)updateLabel{
    
    hud.detailsLabelColor = [UIColor whiteColor];
    [hudTimer invalidate];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewdidAppear");

    [super viewDidAppear:animated];
    self.collectionView.collectionViewLayout.springinessEnabled = NO;

    //only show the progress hud if there are no messages and we must load
    if (messages.count == 0) {
        //don't put this in view did appear b/c it shows everytime we swipe over to the view even though all is loaded
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDAnimationFade;
        hud.labelText = @"Loading...";
        hud.detailsLabelText = @"Poor Network Connection";
        hud.detailsLabelColor = [UIColor clearColor];
        
        
        hudTimer = [NSTimer scheduledTimerWithTimeInterval:6.5
                                                    target:self
                                                  selector:@selector(updateLabel)
                                                  userInfo:nil
                                                   repeats:YES];
        

        
    }
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"Chatview did dissapear");
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController)
    {
        //**ClearRecentCounter(groupId);
        //[firebase1 removeAllObservers];
    }
}


#pragma mark - Backend methods

- (void)loadMessages{
    NSLog(@"load messages for chatrom %@", groupId);
    initialized = NO;
    self.automaticallyScrollsToMostRecentMessage = YES;
    i = 0;
    //querying data
    [[[firebase1 queryOrderedByChild:@"date"] queryLimitedToLast:25] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
    
         if(initialized){
             //You get here when a new child is added to the datastream
             BOOL incoming = [self addMessage:snapshot.value];
             if (incoming) [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
             [self finishReceivingMessage];
             

         }else{
            
             [self addMessage:snapshot.value]; //** I added this so the messages load initially
             i ++;
             
             NSLog(@"i is %d", i);
             
             if (i == messages.count) {
                 [hud hide:YES];
                 Mixpanel *mixpanel = [Mixpanel sharedInstance];
                 [mixpanel track:@"Loading Chat"];

             }
         }
         
     }];
    

    //FEventTypeValue: Fired when any data changes at a location and, recursively, any children
    [firebase1 observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
     {
         //reloads view
         [self finishReceivingMessage];
         [self scrollToBottomAnimated:YES];
         self.automaticallyScrollsToMostRecentMessage = YES;
         self.showLoadEarlierMessagesHeader = YES;
         
         //sets initialized to yes so we dont' run the code above on line 177-ish 'bool incoming...'
         initialized	= YES;
     }];
}

- (BOOL)addMessage:(NSDictionary *)item
{
    
    //using the incoming class that we made.
    //I commented out all the other message types like video/audio and all that
    Incoming *incoming = [[Incoming alloc] initWith:self.senderId CollectionView:self.collectionView];
    
    if ([item[@"type"] isEqualToString: @"picture"]) {
        NSLog(@"photo incomming");
  
        
    }
    
    JSQMessage *message = [incoming create:item];
    [items addObject:item];
    [messages addObject:message];
    return [self incoming:message];
}

- (void)loadAvatar:(NSString *)senderId
{
    if (started[senderId] == nil) started[senderId] = @YES; else return;

    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:senderId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             if ([objects count] != 0)
             {
                 PFUser *user = [objects firstObject];
                 PFFile *file = user[@"photo"];
                 [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
                  {
                      if (error == nil)
                      {
                          UIImage *image = [UIImage imageWithData:imageData];
                          avatars[senderId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:image diameter:30.0];
                          [self.collectionView reloadData];
                      }
                      else [started removeObjectForKey:senderId];
                  }];
             }
         }
         else if (error.code != 120) [started removeObjectForKey:senderId];
     }];
}

- (void)messageSend:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture Audio:(NSString *)audio
{
    Outgoing *outgoing = [[Outgoing alloc] initWith:groupId View:self.navigationController.view];
    [outgoing send:text Video:video Picture:picture Audio:audio];

    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessage];
}

#pragma mark - JSQMessagesViewController method overrides


- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)name date:(NSDate *)date

{
    messageContent = text;
    [self messageSend:text Video:nil Picture:nil Audio:nil];
    [self sendPushNotifications];
    
    if ([[PFUser currentUser][@"role"] isEqualToString:@"Client"]) {
        [self markMessageAsUnread:true];
    }
    
    //mixpanel tracking
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Message Sent" properties:@{
      
      }];
}


- (void)didPressAccessoryButton:(UIButton *)sender

{
    [self actionAttach];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath

{
    return messages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath

{
    if ([self outgoing:messages[indexPath.item]])
    {
        return bubbleImageOutgoing;
    }
    else return bubbleImageIncoming;
}


- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath

{
    JSQMessage *message = messages[indexPath.item];
    if (avatars[message.senderId] == nil)
    {
        [self loadAvatar:message.senderId];
        return avatarImageBlank;
    }
    else return avatars[message.senderId];
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.item % 3 == 0)
    {
        JSQMessage *message = messages[indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    else return nil;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath

{
    JSQMessage *message = messages[indexPath.item];
    if ([self incoming:message])
    {
        if (indexPath.item > 0)
        {
            JSQMessage *previous = messages[indexPath.item-1];
            if ([previous.senderId isEqualToString:message.senderId])
            {
                return nil;
            }
        }
        return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
    }
    else return nil;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath

{
    if ([self outgoing:messages[indexPath.item]])
    {
        NSDictionary *item = items[indexPath.item];
        return [[NSAttributedString alloc] initWithString:item[@"status"]];
    }
    else return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [messages count];
}


- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath

{
    UIColor *color = [self outgoing:messages[indexPath.item]] ? [UIColor whiteColor] : [UIColor blackColor];
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    cell.textView.textColor = color;
    cell.textView.linkTextAttributes = @{NSForegroundColorAttributeName:color};
    
    return cell;
}

#pragma mark - UICollectionView Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender

{
    NSDictionary *item = items[indexPath.item];
    
    if (action == @selector(actionCopy:))
    {
        if ([item[@"type"] isEqualToString:@"text"]) return YES;
    }
    if (action == @selector(actionDelete:))
    {
        if ([self outgoing:messages[indexPath.item]]) return YES;
    }
    if (action == @selector(actionSave:))
    {
        if ([item[@"type"] isEqualToString:@"picture"]) return YES;
        if ([item[@"type"] isEqualToString:@"audio"]) return YES;
        if ([item[@"type"] isEqualToString:@"video"]) return YES;
    }
    return NO;
}


- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath
            withSender:(id)sender
{
    if (action == @selector(actionCopy:))		[self actionCopy:indexPath];
    if (action == @selector(actionDelete:))		[self actionDelete:indexPath];
    if (action == @selector(actionSave:))		[self actionSave:indexPath];
}

#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.item % 3 == 0)
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    else return 0;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = messages[indexPath.item];
    if ([self incoming:message])
    {
        if (indexPath.item > 0)
        {
            JSQMessage *previous = messages[indexPath.item-1];
            if ([previous.senderId isEqualToString:message.senderId])
            {
                return 0;
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    else return 0;
}


- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath

{
    if ([self outgoing:messages[indexPath.item]])
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    else return 0;
}

#pragma mark - Responding to collection view tap events


- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender

{
    bool earlierButtonPressed = true;
    //calculates the number of messages to load
    numberOfMessagesToLoad = (int)(messages.count + 15);
    
    //this makes sure that the previous listener no longer is being fired when messages added
    [firebase1 removeAllObservers];
    
    //this takes the current messages in the view and removes them so we can replace them with new ones
    [messages removeAllObjects];
    
    
    //querying data
    [[[firebase1 queryOrderedByChild:@"date"] queryLimitedToLast:numberOfMessagesToLoad] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        
        //You get here when a new child is added to the datastream
        BOOL incoming = [self addMessage:snapshot.value];
        if (incoming) [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        
        if (earlierButtonPressed) {
            [self.collectionView reloadData];

        }else{
            [self finishReceivingMessage];

        }
        
    
    }];
}


- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath

{
    
    JSQMessage *message = messages[indexPath.item];
    if ([self incoming:message])
    {
        PFQuery *query = [PFUser query];
        [query getObjectInBackgroundWithId:message.senderId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            //
            CoachBioViewController *profileView = [[CoachBioViewController alloc] initWith:object];
            [self presentViewController:profileView animated:YES completion:^{
                //
            }];

        }];
        
    
    }
    
}


- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath

{
    
    JSQMessage *message = messages[indexPath.item];
    
    if (message.isMediaMessage)
    {
        if ([message.media isKindOfClass:[PhotoMediaItem class]])
        {
            PhotoMediaItem *mediaItem = (PhotoMediaItem *)message.media;
            
            //check if the image is loaded yet...that way it don't crash
            if(mediaItem.image){
                NSArray *photos = [IDMPhoto photosWithImages:@[mediaItem.image]];
                IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
                browser.displayDoneButton = YES;
                browser.doneButtonImage = [UIImage imageNamed:@"IDMPhotoBrowser_customDoneButton.png"];
                
                [self presentViewController:browser animated:YES completion:nil];
            }
        }
    }
    
}


- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation

{
    
}

#pragma mark - User actions


- (void)actionAttach

{
    //display library 
    [self.view endEditing:YES];
    
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    
    
//    NSArray *menuItems = @[[[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_camera"] title:@"Camera"],
//                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_audio"] title:@"Audio"],
//                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_pictures"] title:@"Pictures"],
//                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_videos"] title:@"Videos"],
//                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_location"] title:@"Location"],
//                           [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"chat_stickers"] title:@"Stickers"]];
//    RNGridMenu *gridMenu = [[RNGridMenu alloc] initWithItems:menuItems];
//    gridMenu.delegate = self;
//    [gridMenu showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}


- (void)actionDelete:(NSIndexPath *)indexPath

{
    //ActionPremium(self);
}


- (void)actionCopy:(NSIndexPath *)indexPath

{
    NSDictionary *item = items[indexPath.item];
    [[UIPasteboard generalPasteboard] setString:item[@"text"]];
}


- (void)actionSave:(NSIndexPath *)indexPath

{
    //ActionPremium(self);
}

#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    //NSURL *video = info[UIImagePickerControllerMediaURL];
    UIImage *picture = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"picture is: %@", picture);
    
    [self messageSend:nil Video:nil Picture:picture Audio:nil];
    [self sendPushNotifications];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper methods


- (BOOL)incoming:(JSQMessage *)message

{
    return ([message.senderId isEqualToString:self.senderId] == NO);
}


- (BOOL)outgoing:(JSQMessage *)message

{
    return ([message.senderId isEqualToString:self.senderId] == YES);
}

- (void)sendPushNotifications{
    
        PFQuery *query = [PFQuery queryWithClassName:@"Chatrooms"];
        [query fromLocalDatastore];
        [query getObjectInBackgroundWithId:groupId block:^(PFObject * _Nullable object, NSError * _Nullable error) {

            //we now have the chatroom object!
            //maybe later we do init with chatroomobject instead of object id
            PFQuery *pushQuery = [PFInstallation query];
            NSDictionary *data = [[NSDictionary alloc] init];
            NSString *name = [[NSString alloc] init];
            PFUser *sendPushToUser = [[PFUser alloc] init];
            
            //figure out who is sending tha push so we know who to send it  to.
            if ([[PFUser currentUser][@"role"] isEqualToString:@"Client"]){
                sendPushToUser = object[@"dietitianUser"];
             }else if ([[PFUser currentUser][@"role"] isEqualToString:@"RD"]){
                sendPushToUser = object[@"clientUser"];
            }//end if coach
            
            //set data and variables for push...send away!!
            [pushQuery whereKey:@"user" equalTo:sendPushToUser];
            name = [NSString stringWithFormat:@"You have a new messages from %@", [PFUser currentUser][@"firstName"]];
            
            data = [NSDictionary dictionaryWithObjectsAndKeys:
                    name, @"alert",
                    @1, @"badge",
                    @"default", @"sound",
                    @"message", @"type",
                    nil];
            
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            [push setData:data];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                //
                if(succeeded){
                    NSLog(@"push sent successfully!");
                }
            }];
            
            //save message in parse eventually
            PFObject *message = [[PFObject alloc] initWithClassName:@"Messages"];
            message[@"chatroom"] = object;
            message[@"content"] = messageContent;
            message[@"fromUser"] = [PFUser currentUser];
            message[@"toUser"] = sendPushToUser;
            [message saveEventually];

        }];//end chatroom query
}


- (void)callClient{
    //only show if the user is an RD
    
    NSLog(@"You pressed the phone button! Woot woot!");
    phoneCallActive = true;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Chatrooms"];
    [query fromLocalDatastore];
    [query getObjectInBackgroundWithId:groupId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        NSString *phoneNumber = object[@"twilioNumber"];
        NSString *cleanedPhone = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
        
        NSString *phoneNumbers = [@"tel://" stringByAppendingString:cleanedPhone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumbers]];
        
        //mixpanel tracking
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel timeEvent:@"Phone Call"];
    }];
    
    
}

- (void)markMessageAsUnread:(bool)isUnread{
    
    //there is a new message that loaded in the view
    //mark it as read
    
    NSLog(@"mark messages as unread");
    
    //**check if the user has converted chatrooms yet
    PFQuery *query = [PFQuery queryWithClassName:@"Chatrooms"];
    [query fromLocalDatastore];
    [query getObjectInBackgroundWithId:groupId block:^(PFObject * _Nullable chatroom, NSError * _Nullable error) {
        NSLog(@"the objet it: %@", chatroom);
        
        NSNumber *isUnreadNum = [[NSNumber alloc] initWithBool:isUnread];
        chatroom[@"isUnread"] = isUnreadNum;
        [chatroom saveInBackground]; //don't do save eventually b/c badge won't show up on coach end

        
    }];
    
    
}

- (void)didEnterForeground{
    NSLog(@"did enter foreground 2");
    
    /////////////////////////////////////
    //BUILD MESSAGE TO SEND TO FIREBASE//
    /////////////////////////////////////
    
    //if coming from a phone call then...
    //get chatroom and check if updated
    //
    if(phoneCallActive){
        
        PFQuery *query = [PFQuery queryWithClassName:@"Chatrooms"];
        [query fromLocalDatastore];
        [query getObjectInBackgroundWithId:groupId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            //object is chatroom
            if ([object[@"isOnLatestVersion"] isEqualToString:@"YAS"]) {
                Outgoing *outgoing = [[Outgoing alloc] initWith:groupId View:self.navigationController.view];
                [outgoing logPhone];
            }
            
        }];
        
        phoneCallActive = false;
    }
}

-(NSString*)Date2String:(NSDate *)date

{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [formatter stringFromDate:date];
}

@end
