//
//  IPBackgroundAudioManager.h
//  BackgroundAudio
//
//  Created by Matt Bridges on 1/3/13.
//  Copyright (c) 2013 Matt Bridges. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const IPBackgroundAudioNotificationRouteChanged;
extern NSString * const IPBackgroundAudioNotificationRouteUnavailable;
extern NSString * const IPBackgroundAudioNotificationRemoteControl;
extern NSString * const IPBackgroundAudioRemoteControlEventKey;

@interface IPBackgroundAudioManager : NSObject
+ (IPBackgroundAudioManager *) sharedManager;
- (void) startSessionWithCategory:(NSString *)category error:(NSError **)error;
- (void) endSession;
- (void) setNowPlayingInfo:(NSDictionary *)info;
- (void) setNowPlayingInfoWithArtist:(NSString *)artist album:(NSString *)album title:(NSString *)title artwork:(UIImage *)artwork duration:(NSNumber *)duration;
@end
