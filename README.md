Summary
=======

IPBackgroundAudioManger is meant to ease implementation of background audio in iOS5+ applications. It is ideal for applications that play audio tracks and need to handle remote control events as well as audio route change events (e.g. when the user unplugs their headphones). It also assists in setting up an `AVAudioSession` for music playback, and includes convenience methods for setting the "now playing" info on the lock screen.

Setup
=====

**Add these frameworks to your project**

* AVFoundation.framework
* AudioToolbox.framework
* MediaPlayer.framework

**Next, add the UIBackgroundModes key to your info.plist**

![Info.plist](http://i.imgur.com/63nlGHM.png)

**Include IPBackgroundAudioManager.[mh] and UIResponder+IPBackgroundAudio.[mh] in your project.**

![Xcode Project](http://i.imgur.com/rK37MZt.png)

**Start the audio session before your app begins playing audio:**

    [[IPBackgroundAudioManager sharedManager] startSessionWithCategory:AVAudioSessionCategoryPlayback error:nil];

**(Optional) Handle notifications for remote control and audio route change events.** The background audio manager will post the following NSNotifications:

* `IPBackgroundAudioNotificationRouteChanged`: Posted when the default route changes for any reason.
* `IPBackgroundAudioNotificationRouteUnavailable`: Posted when the default route changes because the previous route has become unavailable (e.g. headphones were unplugged). It's usually good form to stop playing audio when this happens.
* `IPBackgroundAudioNotificationRemoteControl`: Posted when the app receives a remote control event. The relevant UIEvent object will be in the notification's userInfo dictionary, under the key `IPBackgroundAudioRemoteControlEventKey`

**(Optional) Set the now playing info when playing tracks.** When a track changes, you can set the lock screen's "now playing" info with a convenience method on `IPBackgroundManager`:

    - (void) setNowPlayingInfoWithArtist:(NSString *)artist
                               album:(NSString *)album
                               title:(NSString *)title
                             artwork:(UIImage *)artwork
                            duration:(NSNumber *)duration

Demo
====
A sample project can be found in the "Demo" folder.