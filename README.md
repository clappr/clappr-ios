 [![Build Status](https://travis-ci.org/clappr/clappr-ios.svg?branch=master)](https://travis-ci.org/clappr/clappr-ios)

# Clappr for iOS

![image](https://cloud.githubusercontent.com/assets/1156242/16349649/54f233e2-3a30-11e6-98e4-42eb5284b730.png)

### Installation

The easiest way is through [CocoaPods](http://cocoapods.org). Simply add the dependency to your `Podfile` and then `pod install`:

```ruby
pod 'Clappr', '~> 0.6'
```

### Using the Player

##### Create
```swift
let options = [kSourceUrl : "http://clappr.io/highline.mp4"]
let player = Player(options: options)
```

##### Add it in your view

```swift
player.attachTo(yourView, controller: self)
```

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
You can add options to the player.
[Here](https://github.com/clappr/clappr-ios/wiki/Options) you can see the list of available options and how to use it.


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
