/*
 *
 * StayOpened
 * Version: 1.5
 * Stop the AppStore from closing when you download applications
 * Copyright (c) 2011 EvilPenguin|
 *
 *
 */

#define REASON_DOWNLOADING_APPS 1
#define STAYOPENED_PLIST @"/var/mobile/Library/Preferences/us.nakedproductions.stayopened.plist"
#define isNotEmpty(string) (string != nil || ![string isEqualToString:@""] || ![string isEqualToString:@" "])
#define listenToNotification$withCallBack(notification, callback); 	\
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), \
        NULL, \
        (CFNotificationCallback)&callback, \
        CFSTR(notification), \
        NULL, \
        CFNotificationSuspensionBehaviorHold);

static NSMutableDictionary *plistDict = nil;
static void updateSettings() {
    NSLog(@"StayOpened: I make icecream sandwiches for everbody");
	if (plistDict) {
		[plistDict release]; 
		plistDict = nil;
	}
	plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:STAYOPENED_PLIST];
    if (plistDict == nil) {
        plistDict = [[NSMutableDictionary alloc] init];
    }
}

@interface UIApplication ()
    - (id) displayIdentifier;
@end

#pragma mark -
#pragma mark == SUStoreController ==

%hook SUStoreController
- (void) exitStoreWithReason:(int)reason {
	if ([plistDict objectForKey:@"DontCloseAppStore"] ? [[plistDict objectForKey:@"DontCloseAppStore"] boolValue] : YES) { 
		if (reason == REASON_DOWNLOADING_APPS) { 
            return; 
        }
	}
	%orig; 
}
%end

#pragma mark -
#pragma mark == UIApplication ==

%hook UIApplication
- (void) suspend {
	if ([[self displayIdentifier] isEqualToString:@"com.apple.AppStore"]) {
		if ([plistDict objectForKey:@"DontCloseAppStore"] ? [[plistDict objectForKey:@"DontCloseAppStore"] boolValue] : YES) { 
            return; 
        }
	}
	%orig; 
}
%end

#pragma mark -
#pragma mark == SUItemOfferButton ==

%hook SUItemOfferButton
- (void)setOfferTitle:(id)title {
	if ([plistDict objectForKey:@"AppStoreFreeTitle"] ? [[plistDict objectForKey:@"AppStoreFreeTitle"] boolValue] : NO) { 
        NSString *newTitle = [plistDict objectForKey:@"AppFreePurchasedTitle"];
        if (isNotEmpty(newTitle)) { title = newTitle; }
	}
	%orig(title);
}

- (void)setConfirmationTitle:(id)title {
	if ([plistDict objectForKey:@"AppStoreConfirmationTitle"] ? [[plistDict objectForKey:@"AppStoreConfirmationTitle"] boolValue] : NO) { 
        NSString *newTitle = [plistDict objectForKey:@"AppPurchasedTitle"];
		if (isNotEmpty(newTitle)) { title = newTitle; }
	}
	%orig(title);
}
%end

%ctor {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	%init;
	listenToNotification$withCallBack("us.nakedproductions.stayopened.enabled", updateSettings);
	updateSettings();
	[pool release];
}
