/*
 *
 * StayOpened
 * Created by EvilPenguin|
 *
 *
 *
 *
 */
#include <iTunesUI/SUItemOfferButton.h>
#include <iTunesUI/SUStoreController.h>
#include <AppStore/ASApplicationPageView.h>
#include <UIKit2/UIApplication2.h>

#define STAYOPENED_PLIST @"/var/mobile/Library/Preferences/us.nakedproductions.stayopened.plist"

#pragma mark -
#pragma mark == ASApplicationPageView ==

%hook ASApplicationPageView
- (void)_reloadButtons {
	//UIButton *problemButton = MSHookIvar<UIButton *>(self, "_reportAProblemButton");
	//problemButton.center = CGPointMake(-100, 50);
	//UIButton *friendButton = MSHookIvar<UIButton *>(self, "_tellAFriendButton"); 
	//[friendButton removeFromSuperview];
	%orig;
}
%end



#pragma mark -
#pragma mark == SUStoreController ==

%hook SUStoreController
- (void) exitStoreWithReason:(int)reason {
	NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:STAYOPENED_PLIST];
	id value = [plistDict objectForKey:@"DontCloseAppStore"];
	if (value ? [value boolValue] : YES) { 
		if (reason == 1) { return; }
	}
	%orig; 
	[plistDict release];
}
%end

#pragma mark -
#pragma mark == UIApplication ==

%hook UIApplication
- (void) suspend {
	if ([[self displayIdentifier] isEqualToString:@"com.apple.AppStore"]) {
		NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:STAYOPENED_PLIST];
		id value = [plistDict objectForKey:@"DontCloseAppStore"];
		if (value ? [value boolValue] : YES) { return; }
		[plistDict release];
	}
	%orig; 
}
%end

#pragma mark -
#pragma mark == SUItemOfferButton ==

%hook SUItemOfferButton
- (void)setOfferTitle:(id)title {
	NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:STAYOPENED_PLIST];
	id value = [plistDict objectForKey:@"AppStoreFreeTitle"];
	NSString *newTitle = [plistDict objectForKey:@"AppFreePurchasedTitle"];
	if (value ? [value boolValue] : YES) { 
		if ([title isEqualToString:@"FREE"]) { 
			if ([newTitle isEqualToString:@""] || [newTitle isEqualToString:@" "] || newTitle == nil) { newTitle = @"FREE"; }
			title = newTitle;
		}
	}
	if ([title isEqualToString:@""] || [title isEqualToString:@" "] || title == nil) { newTitle = @"FREE"; }
	%orig;
	[plistDict release];
}

- (void)setConfirmationTitle:(id)title {
	NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:STAYOPENED_PLIST];
	id value = [plistDict objectForKey:@"AppStoreConfirmationTitle"];
	NSString *newTitle = [plistDict objectForKey:@"AppPurchasedTitle"];
	if (value ? [value boolValue] : YES) { 
		if ([newTitle isEqualToString:@""] || [newTitle isEqualToString:@" "] || newTitle == nil) { newTitle = @"Download"; }
		title = newTitle;
	}
	if ([title isEqualToString:@""] || [title isEqualToString:@" "] || title == nil) { newTitle = @"Download"; }
	%orig;
	[plistDict release];
}
%end