//
//  ViewController.m
//  BackgroundAudio
//
//  Created by Matt Bridges on 1/3/13.
//  Copyright (c) 2013 Matt Bridges. All rights reserved.
//

#import "ViewController.h"
#import "IPBackgroundAudioManager.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface ViewController ()
@property (strong, nonatomic) AVPlayer *player;
@end

@implementation ViewController
@synthesize player = _player;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[IPBackgroundAudioManager sharedManager] startSessionWithCategory:AVAudioSessionCategoryPlayback error:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChanged:) name:IPBackgroundAudioNotificationRouteChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeUnavailable:) name:IPBackgroundAudioNotificationRouteUnavailable object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlReceived:) name:IPBackgroundAudioNotificationRemoteControl object:nil];
    
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"JB_SpaceTheme" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:resourcePath];
    self.player = [AVPlayer playerWithURL:url];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)togglePlay
{
    if (self.player.rate > 0) {
        [self.player pause];
    } else {
        [[IPBackgroundAudioManager sharedManager] setNowPlayingInfoWithArtist:@"Edward Loveall"
                                                                        album:nil
                                                                        title:@"JumbleBook Space Theme"
                                                                      artwork:nil
                                                                     duration:nil];
        [self.player play];
    }
}

- (void)routeChanged:(NSNotification *)notification
{
    NSLog(@"Route Changed.");
}

- (void)routeUnavailable:(NSNotification *)notification
{
    [self.player pause];
    NSLog(@"Route Unavailable.");
}

- (void)remoteControlReceived:(NSNotification *)notification
{
    UIEvent *event = [[notification userInfo] objectForKey:IPBackgroundAudioRemoteControlEventKey];
    NSLog(@"Remote control received: %d", event.subtype);
    
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPause:
            [self.player pause];
            break;
        case UIEventSubtypeRemoteControlPlay:
            [self.player play];
            break;
        case UIEventSubtypeRemoteControlTogglePlayPause:
            [self togglePlay];
            break;
        default:
            break;
    }
}

@end
