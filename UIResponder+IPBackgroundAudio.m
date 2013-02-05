//
//  UIResponder+IPBackgroundAudio.m
//  BackgroundAudio
//
//  Created by Matt Bridges on 1/3/13.
//  Copyright (c) 2013 Matt Bridges. All rights reserved.
//

#import "UIResponder+IPBackgroundAudio.h"
#import "IPBackgroundAudioManager.h"

@implementation UIResponder (IPBackgroundAudio)

- (void)altRemoteControlReceivedWithEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:IPBackgroundAudioNotificationRemoteControl object:self userInfo:@{IPBackgroundAudioRemoteControlEventKey : event}];
    [self altRemoteControlReceivedWithEvent:event];
}

@end
