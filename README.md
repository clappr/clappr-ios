[![Build Status](https://travis-ci.org/clappr/clappr-ios.svg?branch=master)](https://travis-ci.org/clappr/clappr-ios)

# Clappr for iOS

![image](https://cloud.githubusercontent.com/assets/1156242/16349649/54f233e2-3a30-11e6-98e4-42eb5284b730.png)

### Installation

The easiest way is through [CocoaPods](http://cocoapods.org). Simply add the dependency to your `Podfile` and then `pod install`:

```ruby
pod 'Clappr', git: 'https://github.com/clappr/clappr-ios.git', branch: 'tvos'
```

### Using the Player

##### Create
```swift
let options = [kSourceUrl : "http://clappr.io/highline.mp4"]
let player = Player(options: options)
```

##### Add to your controller

```swift
addChildViewController(player)
player.view.frame = view.bounds
view.addSubview(player.view)
player.didMove(toParentViewController: self)
```
Player default configuration assumes fullscreen in tvOS. Please ensure that the corresponding attached view fill all the windows area.

Player also supports embeded mode. This mode requires [media control](#media_control)  being disabled.

##### Listen to Events

```swift
player.on(Event.playing) { userInfo in
    print("on Play")
}
```

You can find public events on `Events` enum and listed bellow:

* bufferUpdate
* positionUpdate
* ready
* stalled
* willUpdateAudioSource
* didUpdateAudioSource
* willUpdateSubtitleSource
* didUpdateSubtitleSource
* disableMediaControl
* enableMediaControl
* didComplete
* willPlay
* playing
* willPause
* didPause
* willStop
* didStop
* airPlayStatusUpdate
* requestFullscreen
* exitFullscreen
* error: `userInfo` can contain the error that caused the event.

### Built-in Plugins

To add plugins parameters use the options parameter on constructor. Example:

```Swift
let options = [kSourceUrl : "http://clappr.io/highline.mp4", pluginParameter1: "value1", pluginParameter2: true]
let player = Player(options: options)
```
##### Source
Set the video source url with `kSourceUrl : "http://clappr.io/highline.mp4"`.

##### Playback not supported custom message
Add `kPlaybackNotSupportedMessage : 'Your custom message'` to define a custom message to be displayed for not supported videos.

##### AutoPlay
Add `kAutoPlay: true` if you want the video to play automatically.

##### Start At
Define a start position in seconds with `kStartAt : x`. Default is `0`.

##### MimeType
Add `kMimeType: 'selected mimetype'` if you need to use a url without extension.

##### Media Control
Add `kMediaControl : false` if you want to disable the media control. Media control is only suported for fullscreen.

### External Playback in Background
To enable external playback while your app is in background, you should include the `audio` value to your app's **Background Modes** capabilities.

#### Manually editing Info.plist
Add the key `UIBackgroundModes`. Just after adding it to your Info.plist file, Xcode will translate to a more readable value `Required background modes`, which represents an array of values. Then, add a new item with value `audio`, which will be translated to `App plays audio or streams audio/video using Airplay`.

#### Capabilities Tab
Click on the target that represents your app. Open the Capabilities tab, and there, you'll see the list of available capabilities. One of them is the `Background Modes`. Change its toggle to `on` and mark the `Audio, Airplay, and Picture in Picture` checkbox.


### License

You can find it [here](https://github.com/clappr/clappr-ios/blob/master/LICENSE).


### Sponsor

[![image](https://cloud.githubusercontent.com/assets/244265/5900100/ef156258-a54b-11e4-9862-7e5851ed9b81.png)](http://globo.com)
