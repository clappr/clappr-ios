[![Build Status](https://travis-ci.org/clappr/clappr-ios.svg?branch=master)](https://travis-ci.org/clappr/clappr-ios)

# Clappr for iOS

![image](https://cloud.githubusercontent.com/assets/1156242/12205646/0d5f7d0a-b623-11e5-81c6-79714a3673ef.png)

### Installation

The easiest way is through [CocoaPods](http://cocoapods.org). Simply add the dependency to your `Podfile` and then `pod install`:

```ruby
pod 'Clappr', '~> 0.1'
```

### Using the Player

Create
```swift
let options = [kSourceUrl : "http://clappr.io/highline.mp4"]
let player = Player(options: options)
```

Add it in your view

```swift
player.attachTo(yourView, controller: self)
```


### Built-in Plugins

To add plugins parameters use the options parameter on constructor. Example:

```Swift
let options = [kSourceUrl : "http://clappr.io/highline.mp4", pluginParameter1: "value1", pluginParameter2: true]
let player = Player(options: options)
```

##### Poster
Define a poster by adding `kPosterUrl: "http://url/img.png"` on your options. It will appear before the video starts, disappear on play and go back when video finishes.


### License

You can find it [here](https://github.com/clappr/clappr-ios/blob/master/LICENSE).


### Sponsor

[![image](https://cloud.githubusercontent.com/assets/244265/5900100/ef156258-a54b-11e4-9862-7e5851ed9b81.png)](http://globo.com)
