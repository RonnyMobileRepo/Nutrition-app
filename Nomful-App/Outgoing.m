//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Parse/Parse.h>
#import <Firebase/Firebase.h>
#import "MBProgressHUD.h"

//#import "utilities.h"

#import "Outgoing.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Outgoing()
{
	NSString *groupId;
	UIView *view;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation Outgoing

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)groupId_ View:(UIView *)view_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	groupId = groupId_;
	view = view_;
	return self;
}


- (void)logPhone{
    
    NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
    item[@"userId"] = @"7zMGN960nO"; //live 7zMGN960nO //dev 9EZw4s8feD
    item[@"name"] = @"Nomberry";
    item[@"date"] = [self Date2String:[NSDate date]];
    item[@"status"] = @"Delivered"; //*this is the string that show up on each message underneath...timestamp instead?
    item[@"video"] = item[@"thumbnail"] = item[@"picture"] = item[@"audio"] = item[@"latitude"] = item[@"longitude"] = @"";
    item[@"video_duration"] = item[@"audio_duration"] = @0;
    item[@"picture_width"] = item[@"picture_height"] = @0;
    
    [self sendPhoneCall:item];

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)send:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture Audio:(NSString *)audio
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	item[@"userId"] = [PFUser currentUser].objectId;
	item[@"name"] = [PFUser currentUser][@"firstName"];
    item[@"date"] = [self Date2String:[NSDate date]];
	item[@"status"] = @"Delivered"; //*this is the string that show up on each message underneath...timestamp instead?
    
	//---------------------------------------------------------------------------------------------------------------------------------------------
	item[@"video"] = item[@"thumbnail"] = item[@"picture"] = item[@"audio"] = item[@"latitude"] = item[@"longitude"] = @"";
	item[@"video_duration"] = item[@"audio_duration"] = @0;
	item[@"picture_width"] = item[@"picture_height"] = @0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (text != nil) [self sendTextMessage:item Text:text];
	else if (video != nil) [self sendVideoMessage:item Video:video];
	else if (picture != nil) [self sendPictureMessage:item Picture:picture];
	else if (audio != nil) [self sendAudioMessage:item Audio:audio];
	else [self sendLoactionMessage:item];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendTextMessage:(NSMutableDictionary *)item Text:(NSString *)text
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	item[@"text"] = text;
	item[@"type"] = @"text";
	[self sendMessage:item];
}

- (void)sendPhoneCall:(NSMutableDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    //**this is where we set the phone call message from nomberry
    item[@"text"] = @"Hey there! Glad you guys had a call :) keep up the healthy progress!";
    item[@"type"] = @"phonecall";
    [self sendMessage:item];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendVideoMessage:(NSMutableDictionary *)item Video:(NSURL *)video
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    /*
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIImage *picture = VideoThumbnail(video);
	UIImage *squared = SquareImage(picture, 320);
	NSNumber *duration = VideoDuration(video);
	PFFile *fileThumbnail = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(squared, 0.6)];
	[fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error == nil)
		{
			PFFile *fileVideo = [PFFile fileWithName:@"video.mp4" data:[[NSFileManager defaultManager] contentsAtPath:video.path]];
			[fileVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
			{
				[hud hide:YES];
				if (error == nil)
				{
					item[@"video"] = fileVideo.url;
					item[@"video_duration"] = duration;
					item[@"thumbnail"] = fileThumbnail.url;
					item[@"text"] = @"[Video message]";
					item[@"type"] = @"video";
					[self sendMessage:item];
				}
				else NSLog(@"Outgoing sendVideoMessage video save error.");
			}
			progressBlock:^(int percentDone)
			{
				hud.progress = (float) percentDone/100;
			}];
		}
		else NSLog(@"Outgoing sendVideoMessage picture save error.");
	}];
     */
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendPictureMessage:(NSMutableDictionary *)item Picture:(UIImage *)picture
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
     
	//---------------------------------------------------------------------------------------------------------------------------------------------
	int width = (int) picture.size.width;
	int height = (int) picture.size.height;
	PFFile *file = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
	[file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		[hud hide:YES];
		if (error == nil)
		{
			item[@"picture"] = file.url;
			item[@"picture_width"] = [NSNumber numberWithInt:width];
			item[@"picture_height"] = [NSNumber numberWithInt:height];
			item[@"text"] = @"[Picture message]";
			item[@"type"] = @"picture";
			[self sendMessage:item];
		}
		else NSLog(@"Outgoing sendPictureMessage picture save error.");
	}
	progressBlock:^(int percentDone)
	{
		hud.progress = (float) percentDone/100;
	}];
     
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendAudioMessage:(NSMutableDictionary *)item Audio:(NSString *)audio
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendLoactionMessage:(NSMutableDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendMessage:(NSMutableDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Message/%@", kFirechatNS, groupId]];
	Firebase *reference = [firebase childByAutoId];
	item[@"messageId"] = reference.key;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[reference setValue:item withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"Outgoing sendMessage network error.");
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	//SendPushNotification1(groupId, item[@"text"]);
	//UpdateRecentItems(groupId, item[@"text"]);
}

#pragma mark - Not From Here
-(NSString*)Date2String:(NSDate *)date
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [formatter stringFromDate:date];
}


@end
