//
//  IPBackgroundAudioManager.m
//  BackgroundAudio
//
//  Created by Matt Bridges on 1/3/13.
//  Copyright (c) 2013 Matt Bridges. All rights reserved.
//

#import "IPBackgroundAudioManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>
#import <objc/message.h>

NSString * const IPBackgroundAudioNotificationRouteChanged = @"IPBackgroundAudioNotificationRouteChanged";
NSString * const IPBackgroundAudioNotificationRouteUnavailable = @"IPBackgroundAudioNotificationRouteUnavailable";
NSString * const IPBackgroundAudioNotificationRemoteControl = @"IPBackgroundAudioNotificationRemoteControl";
NSString * const IPBackgroundAudioRemoteControlEventKey = @"IPBackgroundAudioRemoteControlEventKey";

void IPBackgroundAudioManagerRouteChangeCallback(void *inUserData, AudioSessionPropertyID inPropertyID, UInt32 inPropertyValueSize, const void *inPropertyValue);

void IPBackgroundAudioSwizzle(Class c, SEL orig, SEL new)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

@implementation IPBackgroundAudioManager

+ (IPBackgroundAudioManager *) sharedManager
{
    static IPBackgroundAudioManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void) startSessionWithCategory:(NSString *)category error:(NSError **)error
{
    // Here to receive remote control events. Also puts the "play" triangle icon in the status bar when music is playing.
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    // Default category mutes audio when silent switch is toggled. Use AVSessionCategoryPlayback for music.
    if (category) {
        NSError *setCategoryError = nil;
        [[AVAudioSession sharedInstance] setCategory:category error:&setCategoryError];
        if (setCategoryError) {
            *error = setCategoryError;
            return;
        }
    }
    
    // Activate the audio session. This is done implicitly when app launches, but Apple docs say to do it explicitly anyway.
    NSError *activationError = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&activationError];
    if (activationError) {
        *error = activationError;
        return;
    }
    
    // Add a listener for when the route changes.
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange,
                                    IPBackgroundAudioManagerRouteChangeCallback,
                                    (__bridge void *)(self));
    
    // Swizzle remote control listener into app delegate. In iOS 5.0+, app delegate is always on responder chain.
    IPBackgroundAudioSwizzle([[[UIApplication sharedApplication] delegate] class], @selector(remoteControlReceivedWithEvent:), @selector(altRemoteControlReceivedWithEvent:));
}

- (void) endSession
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    AudioSessionRemovePropertyListenerWithUserData (kAudioSessionProperty_AudioRouteChange,
                                                    IPBackgroundAudioManagerRouteChangeCallback,
                                                    (__bridge void*)self);
}

- (void) setNowPlayingInfo:(NSDictionary *)info
{
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    infoCenter.nowPlayingInfo = info;
}

- (void) setNowPlayingInfoWithArtist:(NSString *)artist
                               album:(NSString *)album
                               title:(NSString *)title
                             artwork:(UIImage *)artwork
                            duration:(NSNumber *)duration
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    
    if (artist) {
        [info setObject:artist forKey:MPMediaItemPropertyArtist];
    }
    if (album) {
        [info setObject:album forKey:MPMediaItemPropertyAlbumTitle];
    }
    if (title) {
        [info setObject:title forKey:MPMediaItemPropertyTitle];
    }
    if (artwork) {
        [info setObject:[[MPMediaItemArtwork alloc] initWithImage:artwork] forKey:MPMediaItemPropertyArtwork];
    }
    if (duration) {
        [info setObject:duration forKey:MPMediaItemPropertyPlaybackDuration];
    }
    
    [self setNowPlayingInfo:info];
}

// Callback for when the route changes.
void IPBackgroundAudioManagerRouteChangeCallback(void *inUserData,
                                            AudioSessionPropertyID inPropertyID,
                                            UInt32 inPropertyValueSize,
                                            const void *inPropertyValue)
{
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) return;
    
    IPBackgroundAudioManager *manager = (__bridge IPBackgroundAudioManager *) inUserData;
    
    CFDictionaryRef routeChangeDictionary = inPropertyValue;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IPBackgroundAudioNotificationRouteChanged object:manager userInfo:(__bridge NSDictionary *)(routeChangeDictionary)];
    
    CFNumberRef routeChangeReasonRef =
    CFDictionaryGetValue (routeChangeDictionary,
                          CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
                          );
    
    SInt32 routeChangeReason;
    
    CFNumberGetValue (routeChangeReasonRef,
                      kCFNumberSInt32Type,
                      &routeChangeReason
                      );
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
        [[NSNotificationCenter defaultCenter] postNotificationName:IPBackgroundAudioNotificationRouteUnavailable object:manager userInfo:(__bridge NSDictionary *)(routeChangeDictionary)];
    }
}

- (void)dealloc
{
    AudioSessionRemovePropertyListenerWithUserData (kAudioSessionProperty_AudioRouteChange,
                                                    IPBackgroundAudioManagerRouteChangeCallback,
                                                    (__bridge void*)self);
}

@end

@implementation UIResponder (IPBackgroundAudio)

- (void)altRemoteControlReceivedWithEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:IPBackgroundAudioNotificationRemoteControl object:self userInfo:@{IPBackgroundAudioRemoteControlEventKey : event}];
    [self altRemoteControlReceivedWithEvent:event];
}

@end
