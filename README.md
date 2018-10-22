# Clappr for iOS and tvOS

![image](https://cloud.githubusercontent.com/assets/1156242/16349649/54f233e2-3a30-11e6-98e4-42eb5284b730.png)

Clappr is an extensible media player for iOS and tvOS.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate Clappr into your Xcode project using CocoaPods, specify it to a target in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'Clappr', '~> 0.9.0'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Clappr into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "clappr/clappr-ios"  ~> 0.9.0
```

Run `carthage update` to build the framework and drag the built `Clappr.framework` into your Xcode project.

## Usage

### iOS

#### Create
```swift
let options = [kSourceUrl : "http://clappr.io/highline.mp4"]
let player = Player(options: options)
```

#### Add it in your view

```swift
player.attachTo(yourView, controller: self)
```

### tvOS

#### Create
```swift
let options = [kSourceUrl : "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8"]
let player = Player(options: options)
```

#### Register Custom Plugins

In order to register a custom plugin is necessary to pass the plugin type to Player before initialize it, using the static method `register` as the example below:


```swift
let plugins = [PluginExemplo.self]
WMPlayer.register(plugins: plugins)

var player = WMPlayer(options: options)

player.attachTo(playerContainer, controller: self)
```

The Player does not support adding or removing plugins at runtime so it is necessary register the plugins before its initialization.
In case player be destroyed and recreated, all plugins registered will be reused, like the example below:

```swift
let firstTimePlugins = [PluginExemploA.self]
WMPlayer.register(plugins: firstTimePlugins)

var player = WMPlayer(options: options)

let secondTimePlugins = [PluginExemploB.self]
WMPlayer.register(plugins: secondTimePlugins)

// PluginExemploB will not be used in this instance of Player
player.attachTo(playerContainer, controller: self) 

player.destroy()

// PluginExemploA and PluginExemploB will be used in this instance of Player
player = WMPlayer(options: options)

```

#### Add to your controller

```swift
addChildViewController(player)
player.view.frame = view.bounds
view.addSubview(player.view)
player.didMove(toParentViewController: self)
```

The default configuration assumes fullscreen in tvOS, ensure that the corresponding attached view fills all the window area.

Player also supports embedded mode. For this you'll have to disable MediaControl through options:

```
kMediaControl: false
```

You can read more about options [here](https://github.com/clappr/clappr-ios/wiki/Options).

## Events
The player throw's a [list of events](https://github.com/clappr/clappr-ios/wiki/Events) that can be useful to your application.

## Options
You can add options to the player.
[Here](https://github.com/clappr/clappr-ios/wiki/Options) you can see the list of available options and how to use it.

## External Playback in Background
To enable external playback while your app is in background, you should include the `audio` value to your app's **Background Modes** capabilities.

### Manually editing Info.plist
Add the key `UIBackgroundModes`. Just after adding it to your Info.plist file, Xcode will translate to a more readable value `Required background modes`, which represents an array of values. Then, add a new item with value `audio`, which will be translated to `App plays audio or streams audio/video using Airplay`.

### Capabilities Tab
Click on the target that represents your app. Open the Capabilities tab, and there, you'll see the list of available capabilities. One of them is the `Background Modes`. Change its toggle to `on` and mark the `Audio, Airplay, and Picture in Picture` checkbox.

## License

You can find it [here](https://github.com/clappr/clappr-ios/blob/master/LICENSE).

## Sponsor

[![image](https://cloud.githubusercontent.com/assets/244265/5900100/ef156258-a54b-11e4-9862-7e5851ed9b81.png)](http://globo.com)
