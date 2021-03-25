import Quick
import Nimble
import AVFoundation
import OHHTTPStubs

@testable import Clappr

class AVFoundationPlaybackTests: QuickSpec {

    override func spec() {
        describe("AVFoundationPlayback Tests") {

            var asset: AVURLAssetStub!
            var item: AVPlayerItemStub!
            var player: AVPlayerStub!
            var playback: AVFoundationPlayback!
            var itemInfo: AVPlayerItemInfo!

            beforeEach {
                OHHTTPStubs.removeAllStubs()
                asset = AVURLAssetStub(url: URL(string: "https://www.google.com")!, options: nil)
                item = AVPlayerItemStub(asset: asset)

                player = AVPlayerStub()
                player.set(currentItem: item)

                playback = AVFoundationPlayback(options: [:])
                playback.player = player
                playback.render()
                itemInfo = AVPlayerItemInfo(item: item, delegate: playback)
                playback.itemInfo = itemInfo


                stub(condition: isHost("clappr.sample") || isHost("clappr.io")) { result in
                    if result.url?.path == "/master.m3u8" {
                        let stubPath = OHPathForFile("master.m3u8", type(of: self))
                        return fixture(filePath: stubPath!, headers: [:])
                    } else if result.url!.path.contains(".ts") {
                        let stubPath = OHPathForFile(result.url!.path.replacingOccurrences(of: "/", with: ""), type(of: self))
                        return fixture(filePath: stubPath!, headers: [:])
                    }

                    let stubPath = OHPathForFile("sample.m3u8", type(of: self))
                    return fixture(filePath: stubPath!, headers: [:])
                }
            }

            afterEach {
                playback.stop()
                itemInfo = nil
                asset = nil
                item = nil
                player = nil
                playback = nil
                itemInfo = nil
                OHHTTPStubs.removeAllStubs()
            }

            describe("#init") {
                context("without current item") {
                    it("it should call update asset if needed when current item is set") {
                        var didCallEventReady = false
                        playback = AVFoundationPlayback(options: [:])
                        playback.render()
                        expect(playback.itemInfo).to(beNil())
                        expect(playback.player.currentItem).to(beNil())

                        playback.on(Event.ready.rawValue) { _ in
                            didCallEventReady = true
                        }
                        playback.player.replaceCurrentItem(with: item)
                        playback.play()

                        expect(playback.itemInfo).toNot(beNil())
                        expect(playback.player.currentItem).toNot(beNil())
                        expect(didCallEventReady).toEventually(beTrue(), timeout: 5)
                    }
                }
                context("without kLoop option") {
                    it("instantiates player as an instance of AVPlayer") {
                        let options = [kSourceUrl: "http://clappr.io/highline.mp4"]
                        let playback = AVFoundationPlayback(options: options)

                        playback.play()

                        expect(playback.player).to(beAKindOf(AVPlayer.self))
                    }
                }

                context("with kLoop option") {
                    it("instantiates player as an instance of AVQueuePlayer") {
                        let options: Options = [kSourceUrl: "http://clappr.io/highline.mp4", kLoop: true]
                        let playback = AVFoundationPlayback(options: options)

                        playback.play()

                        expect(playback.player).to(beAKindOf(AVQueuePlayer.self))
                    }

                    context("when video finishes") {
                        it("triggers didLoop event") {
                            let options: Options = [kSourceUrl: "http://clappr.sample/sample.m3u8", kLoop: true]
                            playback = AVFoundationPlayback(options: options)
                            playback.render()

                            var didLoopTriggered = false

                            playback.on(Event.didLoop.rawValue) { _ in
                                didLoopTriggered = true
                            }

                            playback.on(Event.assetReady.rawValue) { _ in
                                playback.seek(playback.duration)
                            }
                            
                            playback.play()

                            expect(didLoopTriggered).toEventually(beTrue(), timeout: 10)
                        }
                    }

                    context("on destroy") {
                        it("stops observing loopCount") {
                            let options: Options = [kSourceUrl: "http://clappr.io/highline.mp4", kLoop: true]
                            let playback = AVFoundationPlayback(options: options)
                            playback.render()
                            
                            playback.play()
                            playback.destroy()

                            expect(playback.loopObserver).to(beNil())
                        }
                    }
                }
            }

            describe("AVFoundationPlaybackExtension") {
                describe("#minDvrSize") {
                    context("when minDvrOption has correct type value") {
                        it("return minDvrOption value") {
                            let options = [kMinDvrSize: 15.1]
                            let playback = AVFoundationPlayback(options: options)

                            expect(playback.minDvrSize).to(equal(15.1))
                        }
                    }
                    context("when minDvrOption has wrong type value") {
                        it("return default value") {
                            let options = [kMinDvrSize: 15]
                            let playback = AVFoundationPlayback(options: options)

                            expect(playback.minDvrSize).to(equal(60))
                        }
                    }
                    context("when minDvrOption has no value") {
                        it("returns default value") {
                            expect(playback.minDvrSize).to(equal(60))
                        }
                    }
                }

                describe("#didChangeDvrStatus") {
                    context("when video is vod") {
                        it("returns false") {
                            asset.set(duration: CMTime(seconds: 60, preferredTimescale: 1))

                            expect(playback.isDvrInUse).to(beFalse())
                        }
                    }

                    context("when video is live") {

                        beforeEach {
                            item._duration = CMTime.indefinite
                        }

                        context("video has dvr") {
                            context("when dvr is being used") {
                                it("triggers didChangeDvrStatus with inUse true") {
                                    item.setSeekableTimeRange(with: 60)
                                    item.set(currentTime: CMTime(seconds: 54, preferredTimescale: 1))
                                    itemInfo.update(item: item)
                                    var usingDVR = false
                                    playback.on(Event.didChangeDvrStatus.rawValue) { info in
                                        if let enabled = info?["inUse"] as? Bool {
                                            usingDVR = enabled
                                        }
                                    }

                                    player.setStatus(to: .readyToPlay)
                                    playback.seek(50)

                                    expect(usingDVR).toEventually(beTrue())
                                }
                            }

                            context("when dvr is not being used") {
                                it("triggers didChangeDvrStatus with inUse false") {
                                    player.set(currentTime: CMTime(seconds: 60, preferredTimescale: 1))
                                    item.setSeekableTimeRange(with: 60)
                                    itemInfo.update(item: item)
                                    var usingDVR = false
                                    playback.on(Event.didChangeDvrStatus.rawValue) { info in
                                        if let enabled = info?["inUse"] as? Bool {
                                            usingDVR = enabled
                                        }
                                    }

                                    player.setStatus(to: .readyToPlay)
                                    playback.seek(60)

                                    expect(usingDVR).toEventually(beFalse())
                                }
                            }
                        }

                        context("whe video does not have dvr") {
                            it("doesn't trigger didChangeDvrStatus event") {
                                player.set(currentTime: CMTime(seconds: 59, preferredTimescale: 1))
                                var usingDVR: Bool?
                                playback.on(Event.didChangeDvrStatus.rawValue) { info in
                                    if let enabled = info?["inUse"] as? Bool {
                                        usingDVR = enabled
                                    }
                                }

                                player.setStatus(to: .readyToPlay)
                                playback.seek(60)

                                expect(usingDVR).toEventually(beNil())
                            }
                        }
                    }
                }

                describe("#pause") {
                    beforeEach {
                        item._duration = CMTime.indefinite
                        itemInfo.update(item: item)
                    }

                    context("video has dvr") {
                       it("triggers usinDVR with enabled true") {
                            item.setSeekableTimeRange(with: 60)
                            player.setStatus(to: .readyToPlay)
                            var didChangeDvrStatusTriggered = false
                            playback.on(Event.didChangeDvrStatus.rawValue) { info in
                                didChangeDvrStatusTriggered = true
                            }

                            playback.pause()

                            expect(didChangeDvrStatusTriggered).toEventually(beTrue())
                        }
                    }

                    context("whe video does not have dvr") {
                        it("doesn't trigger usingDVR event") {
                            var didChangeDvrStatusTriggered = false
                            playback.on(Event.didChangeDvrStatus.rawValue) { info in
                                didChangeDvrStatusTriggered = true
                            }

                            playback.pause()

                            expect(didChangeDvrStatusTriggered).toEventually(beFalse())
                        }
                    }
                }

                describe("#didChangeDvrAvailability") {
                    var playback: AVFoundationPlayback!
                    var playerItem: AVPlayerItemStub?
                    var available: Bool?
                    var didCallChangeDvrAvailability: Bool?
                    let playerAsset = AVURLAssetStub(url: URL(string: "http://clappr.sample/master.m3u8")!)

                    func setupTest(minDvrSize: Double, seekableTimeRange: Double, duration: CMTime = .indefinite) {
                        playback = AVFoundationPlayback(options: [kMinDvrSize: minDvrSize])
                        playerItem = AVPlayerItemStub(asset: playerAsset)
                        playerItem!._duration = duration
                        playerItem!.setSeekableTimeRange(with: seekableTimeRange)
                        let player = AVPlayerStub()
                        player.set(currentItem: playerItem!)
                        playback.player = player
                        player.setStatus(to: .readyToPlay)
                        
                        itemInfo = AVPlayerItemInfo(item: playerItem!, delegate: playback)
                        playback.itemInfo = itemInfo

                        playback.on(Event.didChangeDvrAvailability.rawValue) { info in
                            didCallChangeDvrAvailability = true
                            if let dvrAvailable = info?["available"] as? Bool {
                                available = dvrAvailable
                            }
                        }
                    }

                    beforeEach {
                        didCallChangeDvrAvailability = false
                    }

                    context("when calls handleDvrAvailabilityChange") {
                        context("and lastDvrAvailability is nil") {
                            context("and seekableTime duration its lower than minDvrSize (dvr not available)") {
                                it("calls didChangeDvrAvailability event with available false") {
                                    setupTest(minDvrSize: 60.0, seekableTimeRange: 45.0, duration: .indefinite)
                                    playback.lastDvrAvailability = nil

                                    playback.handleDvrAvailabilityChange()

                                    expect(didCallChangeDvrAvailability).toEventually(beTrue())
                                    expect(available).toEventually(beFalse())
                                }
                            }

                            context("and seekableTime duration its higher(or equal) than minDvrSize (dvr available)") {
                                it("calls didChangeDvrAvailability event with available true") {
                                    setupTest(minDvrSize: 60.0, seekableTimeRange: 75.0, duration: .indefinite)
                                    playback.lastDvrAvailability = nil

                                    playback.handleDvrAvailabilityChange()

                                    expect(didCallChangeDvrAvailability).toEventually(beTrue())
                                    expect(available).toEventually(beTrue())
                                }
                            }
                        }

                        context("and lastDvrAvailability is true") {
                            context("and seekableTime duration its lower than minDvrSize (dvr not available)") {
                                it("calls didChangeDvrAvailability event with available false") {
                                    setupTest(minDvrSize: 60.0, seekableTimeRange: 45.0, duration: .indefinite)
                                    playback.lastDvrAvailability = true

                                    playback.handleDvrAvailabilityChange()

                                    expect(didCallChangeDvrAvailability).toEventually(beTrue())
                                    expect(available).toEventually(beFalse())
                                }
                            }

                            context("and seekableTime duration its higher(or equal) than minDvrSize (dvr available)") {
                                it("does not call didChangeDvrAvailability") {
                                    setupTest(minDvrSize: 60.0, seekableTimeRange: 85.0, duration: .indefinite)
                                    playback.lastDvrAvailability = true

                                    playback.handleDvrAvailabilityChange()

                                    expect(didCallChangeDvrAvailability).toEventually(beFalse())
                                }
                            }
                        }

                        context("and lastDvrAvailability is false") {
                            context("and seekableTime duration its lower than minDvrSize (dvr not available)") {
                                it("does not call didChangeDvrAvailability") {
                                    setupTest(minDvrSize: 60.0, seekableTimeRange: 35.0, duration: .indefinite)
                                    playback.lastDvrAvailability = false

                                    playback.handleDvrAvailabilityChange()

                                    expect(didCallChangeDvrAvailability).toEventually(beFalse())
                                }
                            }

                            context("and seekableTime duration its higher(or equal) than minDvrSize (dvr available)") {
                                it("calls didChangeDvrAvailability event with available true") {
                                    setupTest(minDvrSize: 60.0, seekableTimeRange: 75.0, duration: .indefinite)
                                    playback.lastDvrAvailability = false

                                    playback.handleDvrAvailabilityChange()

                                    expect(didCallChangeDvrAvailability).toEventually(beTrue())
                                    expect(available).toEventually(beTrue())
                                }
                            }
                        }
                    }

                    context("video is not live") {
                        it("does not call didChangeDvrAvailability") {
                            setupTest(minDvrSize: 60.0, seekableTimeRange: 45.0, duration: CMTime(seconds: 60, preferredTimescale: 1))
                            
                            playback.lastDvrAvailability = nil

                            playback.handleDvrAvailabilityChange()

                            expect(didCallChangeDvrAvailability).toEventually(beFalse())
                        }
                    }
                }

                describe("#seekableTimeRanges") {
                    context("when video has seekableTimeRanges") {
                        it("returns an array with NSValue") {
                            item.setSeekableTimeRange(with: 60)

                            expect(playback.seekableTimeRanges).toNot(beEmpty())
                        }
                    }
                    context("when video does not have seekableTimeRanges") {
                        it("is empty") {
                            expect(playback.seekableTimeRanges).to(beEmpty())
                        }
                    }
                }

                describe("#epochDvrWindowStart") {
                    it("returns the epoch time corresponding to the DVR start") {
                        let now = Date()
                        player.setStatus(to: .readyToPlay)
                        item._duration = .indefinite
                        item.setSeekableTimeRange(with: 200)
                        item.setWindow(start: 100, end: 160)
                        item._currentTime = CMTime(seconds: 125, preferredTimescale: 1)
                        itemInfo.update(item: item)
                        
                        item.set(currentDate: now)
                        

                        let dvrStart = now.addingTimeInterval(-25).timeIntervalSince1970
                        expect(playback.epochDvrWindowStart).to(equal(dvrStart))
                    }
                }

                describe("#loadedTimeRanges") {
                    context("when video has loadedTimeRanges") {
                        it("returns an array with NSValue") {
                            player.setStatus(to: .readyToPlay)
                            itemInfo.update(item: item)

                            item.setLoadedTimeRanges(with: 60)

                            expect(playback.loadedTimeRanges).toNot(beEmpty())
                        }
                    }
                    context("when video does not have loadedTimeRanges") {
                        it("is empty") {
                            player.setStatus(to: .readyToPlay)
                            itemInfo.update(item: item)

                            expect(playback.loadedTimeRanges).to(beEmpty())
                        }
                    }
                }

                describe("#isDvrAvailable") {
                    context("when video is vod") {
                        it("returns false") {
                            asset.set(duration: CMTime(seconds: 60, preferredTimescale: 1))

                            expect(playback.isDvrAvailable).to(beFalse())
                        }
                    }

                    context("when video is live") {
                        it("returns true") {
                            player.setStatus(to: .readyToPlay)
                            itemInfo.update(item: item)
                            
                            item._duration = .indefinite
                            item.setSeekableTimeRange(with: 60)

                            expect(playback.isDvrAvailable).to(beTrue())
                        }
                    }
                }

                describe("#position") {
                    context("when live") {
                        context("and DVR is available") {
                            it("returns the position inside the DVR window") {
                                player.setStatus(to: .readyToPlay)
                                itemInfo.update(item: item)
                                item._duration =  .indefinite
                                item.setSeekableTimeRange(with: 200)
                                item.setWindow(start: 100, end: 160)
                                item._currentTime = CMTime(seconds: 125, preferredTimescale: 1)

                                expect(playback.position).to(equal(25))
                            }
                        }
                        context("and dvr is not available") {
                            it("returns 0") {
                                asset.set(duration: .indefinite)
                                item.setSeekableTimeRange(with: 0)

                                expect(playback.position).to(equal(0))
                            }
                        }
                    }

                    context("when vod") {
                        it("returns current time") {
                            player.setStatus(to: .readyToPlay)
                            item._duration = CMTime(seconds: 160, preferredTimescale: 1)
                            item._currentTime = CMTime(seconds: 125, preferredTimescale: 1)
                            
                            itemInfo.update(item: item)
                            
                            expect(playback.position).to(equal(125))
                        }
                    }
                }

                describe("#currentDate") {
                    it("returns the currentDate of the video") {
                        let date = Date()
                        item.set(currentDate: date)

                        expect(playback.currentDate).to(equal(date))
                    }
                }

                describe("#currentLiveDate") {
                    context("when a video is not live") {
                        it("returns nil") {
                            let playback = StubbedLiveDatePlayback(options: [:])
                            playback.player = player
                            playback._playbackType = .vod

                            expect(playback.currentLiveDate).to(beNil())
                        }
                    }

                    context("when there's a currentDate") {
                        it("returns the currentLiveDate of the video") {
                            let playback = StubbedLiveDatePlayback(options: [:])
                            playback.player = player
                            let currentDate = Date()

                            item.set(currentDate: currentDate)
                            playback._position = 0
                            playback._duration = 0

                            expect(playback.currentLiveDate?.timeIntervalSince1970).to(equal(currentDate.timeIntervalSince1970))
                        }
                    }

                    context("when the video is not at the live position") {
                        it("returns the currentLiveDate of the video") {
                            let playback = StubbedLiveDatePlayback(options: [:])
                            playback.player = player
                            let currentDate = Date()

                            item.set(currentDate: currentDate)
                            playback._position = 30
                            playback._duration = 1000

                            expect(currentDate.timeIntervalSince1970).to(beLessThan(playback.currentLiveDate?.timeIntervalSince1970))
                        }
                    }
                }
            }

            describe("#duration") {
                var asset: AVURLAssetStub!
                var item: AVPlayerItemStub!
                var player: AVPlayerStub!
                var playback: AVFoundationPlayback!

                beforeEach {
                    asset = AVURLAssetStub(url: URL(string: "https://www.google.com")!, options: nil)
                    item = AVPlayerItemStub(asset: asset)

                    player = AVPlayerStub()
                    player.set(currentItem: item)

                    playback = AVFoundationPlayback(options: [:])
                    playback.player = player
                }

                context("when video is vod") {
                    it("returns different from zero") {
                        player.setStatus(to: .readyToPlay)
                        item._duration = CMTime(seconds: 60, preferredTimescale: 1)
                        itemInfo = AVPlayerItemInfo(item: item, delegate: playback)
                        playback.itemInfo = itemInfo
                        player.set(currentItem: item)

                        expect(playback.duration).to(equal(60))
                    }
                }
                context("when video is live") {
                    context("when has dvr enabled") {
                        it("returns different from zero") {
                            item._duration = .indefinite
                            item.setSeekableTimeRange(with: 60)
                            itemInfo = AVPlayerItemInfo(item: item, delegate: playback)
                            playback.itemInfo = itemInfo

                            player.setStatus(to: .readyToPlay)

                            expect(playback.duration).to(equal(60))
                        }
                    }
                    context("when doesn't have dvr enabled") {
                        it("returns zero") {
                            item._duration = .indefinite
                            player.setStatus(to: .readyToPlay)

                            expect(playback.duration).to(equal(0))
                        }
                    }
                }
            }

            context("canPlay media") {
                it("Should return true for valid url with mp4 path extension") {
                    let options = [kSourceUrl: "http://clappr.io/highline.mp4"]
                    let canPlay = AVFoundationPlayback.canPlay(options)
                    expect(canPlay).to(beTrue())
                }

                it("Should return true for valid url with m3u8 path extension") {
                    let options = [kSourceUrl: "http://clappr.io/highline.m3u8"]
                    let canPlay = AVFoundationPlayback.canPlay(options)
                    expect(canPlay).to(beTrue())
                }

                it("Should return true for valid url without path extension with supported mimetype") {
                    let options = [kSourceUrl: "http://clappr.io/highline", kMimeType: "video/avi"]
                    let canPlay = AVFoundationPlayback.canPlay(options)
                    expect(canPlay).to(beTrue())
                }

                it("Should return false for invalid url") {
                    let options = [kSourceUrl: "123123"]
                    let canPlay = AVFoundationPlayback.canPlay(options)
                    expect(canPlay).to(beFalse())
                }

                it("Should return false for url with invalid path extension") {
                    let options = [kSourceUrl: "http://clappr.io/highline.zip"]
                    let canPlay = AVFoundationPlayback.canPlay(options)
                    expect(canPlay).to(beFalse())
                }
            }

            context("playback state") {
                var playback: AVFoundationPlaybackMock!

                beforeEach {
                    playback = AVFoundationPlaybackMock(options: [:])
                }

                context("idle") {
                    beforeEach {
                        playback = AVFoundationPlaybackMock(options: [:])
                        playback.set(state: .idle)
                    }

                    it("canPlay") {
                        expect(playback.canPlay).to(beTrue())
                    }

                    it("canPause") {
                        expect(playback.canPause).to(beTrue())
                    }
                }

                context("paused") {
                    beforeEach {
                        playback.set(state: .paused)
                    }

                    it("canPlay") {
                        expect(playback.canPlay).to(beTrue())
                    }

                    it("cannot Pause") {
                        expect(playback.canPause).to(beFalse())
                    }
                }

                context("stalling") {
                    beforeEach {
                        playback.set(state: .stalling)
                    }
                    context("and asset is ready to play") {
                        it("canPlay") {
                            let url = URL(string: "http://clappr.sample/master.m3u8")!
                            let playerAsset = AVURLAssetStub(url: url)
                            let playerItem = AVPlayerItemStub(asset: playerAsset)
                            playerItem._status = .readyToPlay
                            let player = AVPlayerStub()
                            player.set(currentItem: playerItem)

                            playback.player = player

                            expect(playback.canPlay).to(beTrue())
                        }
                    }

                    it("canPause") {
                        expect(playback.canPause).to(beTrue())
                    }
                }

                context("playing") {
                    beforeEach {
                        playback.set(state: .playing)
                    }

                    it("cannot play") {
                        expect(playback.canPlay).to(beFalse())
                    }

                    it("canPause") {
                        expect(playback.canPause).to(beTrue())
                    }

                    context("live video with no DVR support") {
                        it("cannot Pause") {
                            playback._playbackType = .live
                            playback.set(isDvrAvailable: false)

                            expect(playback.canPause).to(beFalse())
                        }
                    }

                    context("live video with DVR support") {
                        it("canSeek") {
                            playback._playbackType = .live
                            playback.set(isDvrAvailable: true)

                            expect(playback.canSeek).to(beTrue())
                        }
                    }

                    context("video with zero duration") {
                        it("cannot Seek") {
                            playback._playbackType = .vod
                            playback.videoDuration = 0.0

                            expect(playback.canSeek).to(beFalse())
                        }
                    }
                }

                context("error") {
                    beforeEach {
                        playback.set(state: .error)
                    }

                    it("cannot Seek") {
                        expect(playback.canSeek).to(beFalse())
                    }
                }
            }

            if #available(iOS 11.0, *) {
                #if os(iOS)
                context("when did change bounds") {
                    it("sets preferredMaximumResolution according to playback bounds size") {
                        let playback = AVFoundationPlayback(options: [kSourceUrl: "http://clappr.io/slack.mp4"])
                        playback.render()
                        
                        playback.play()
                        playback.view.bounds = CGRect(x: 0, y: 0, width: 200, height: 200)
                        let playerSize = playback.view.bounds.size
                        let mainScale = UIScreen.main.scale
                        let screenSize = CGSize(width: playerSize.width * mainScale, height: playerSize.height * mainScale)

                        expect(playback.player?.currentItem?.preferredMaximumResolution).to(equal(screenSize))
                    }
                }
                #endif

                context("when setups avplayer") {

                    beforeEach {
                        stub(condition: isHost("clappr.io")) { _ in
                            let stubPath = OHPathForFile("video.mp4", type(of: self))
                            return fixture(filePath: stubPath!, headers: ["Content-Type":"video/mp4"])
                        }
                    }

                    afterEach {
                        OHHTTPStubs.removeAllStubs()
                    }

                    #if os(iOS)
                    it("sets preferredMaximumResolution according to playback bounds size") {
                        let playback = AVFoundationPlayback(options: [kSourceUrl: "http://clappr.io/slack.mp4"])
                        playback.render()
                        
                        playback.view.bounds = CGRect(x: 0, y: 0, width: 200, height: 200)
                        let playerSize = playback.view.bounds.size
                        let mainScale = UIScreen.main.scale
                        let screenSize = CGSize(width: playerSize.width * mainScale, height: playerSize.height * mainScale)

                        playback.play()

                        expect(playback.player?.currentItem?.preferredMaximumResolution).toEventually(equal(screenSize))
                    }
                    #endif

                    it("trigger didUpdateDuration") {
                        let playback = AVFoundationPlayback(options: [kSourceUrl: "http://clappr.sample/master.m3u8"])
                        var callDidUpdateDuration = false
                        playback.render()

                        playback.on(Event.didUpdateDuration.rawValue) { userInfo in
                            callDidUpdateDuration = true
                        }

                        playback.play()
                        expect(callDidUpdateDuration).toEventually(beTrue(), timeout: 3)
                    }

                    context("with startAt") {
                        it("triggers didSeek") {
                            let playback = AVFoundationPlayback(options: [kSourceUrl: "http://clappr.sample/master.m3u8", kStartAt: 10])
                            var didSeek = false
                            var startAtValue: Double = 0
                            playback.render()
                            playback.on(Event.didSeek.rawValue) { userInfo in
                                didSeek = true
                                startAtValue = userInfo!["position"] as! Double
                            }

                            playback.play()

                            expect(didSeek).toEventually(beTrue())
                            expect(startAtValue).toEventually(beCloseTo(10, within: 0.1))
                        }
                    }
                    
                    context("with liveStartTime") {
                        
                        func setupLiveDvr(liveStartTime: Double, dvrWindowStart: Double, dvrWindowEnd: Double)  {
                            playback = AVFoundationPlayback(options: [kMinDvrSize: 0, kLiveStartTime: liveStartTime])
                            
                            asset = AVURLAssetStub(url: URL(string:"globo.com")!)
                            
                            item = AVPlayerItemStub(asset: asset)
                            item._duration = .indefinite
                            let dvrWindowSize = dvrWindowEnd - dvrWindowStart
                            item.setWindow(start: 0, end: dvrWindowSize)
                            item.set(currentTime: CMTime(seconds: dvrWindowSize, preferredTimescale: 1))
                            item.set(currentDate: Date(timeIntervalSince1970: dvrWindowEnd))
                            
                            player = AVPlayerStub()
                            player.set(currentItem: item)
                            
                            itemInfo = AVPlayerItemInfo(item: item, delegate: playback)
                            playback.itemInfo = itemInfo
                            playback.player = player
                            
                            player.setStatus(to: .readyToPlay)
                        }
                        
                        context("when video is live with dvr") {
                            context("and liveStartTime is between dvrWindow range") {
                                it("triggers didUpdatePosition") {
                                    setupLiveDvr(liveStartTime: 2500, dvrWindowStart: 2000, dvrWindowEnd: 3000)
                                    
                                    let expectedPositionToSeek = 500.0
                                    
                                    var didCallUpdatePosition = false
                                    var positionToSeek: Double = 0
                                    
                                    playback.on(Event.didUpdatePosition.rawValue) { userInfo in
                                        didCallUpdatePosition = true
                                        positionToSeek = userInfo!["position"] as! Double
                                    }
                                    
                                    playback.didLoadDuration()
                                    
                                    expect(didCallUpdatePosition).toEventually(beTrue())
                                    expect(positionToSeek).toEventually(equal(expectedPositionToSeek))
                                }
                            }
                            
                            context("and liveStartTime is before dvrWindow range") {
                                it("should not seek") {
                                    setupLiveDvr(liveStartTime: 1500, dvrWindowStart: 2000, dvrWindowEnd: 3000)
                                    
                                    var didSeek = false
                                    
                                    playback.on(Event.didSeek.rawValue) { _ in
                                        didSeek = true
                                    }
                                    
                                    playback.handleDvrAvailabilityChange()
                                    
                                    expect(didSeek).toEventually(beFalse())
                                }
                            }
                            
                            context("and liveStartTime is after dvrWindow range") {
                                it("should not seek") {
                                    setupLiveDvr(liveStartTime: 3500, dvrWindowStart: 2000, dvrWindowEnd: 3000)
                                    
                                    var didSeek = false
                                    
                                    playback.on(Event.didSeek.rawValue) { _ in
                                        didSeek = true
                                    }
                                    
                                    playback.handleDvrAvailabilityChange()
                                    
                                    expect(didSeek).toEventually(beFalse())
                                }
                            }
                        }
                        
                        context("when video is live without dvr") {
                            it("should not seek") {
                                let playback = AVFoundationPlayback(options: [kLiveStartTime: 2500.0])
                                
                                let asset = AVURLAssetStub(url: URL(string:"globo.com")!)
                                asset.set(duration: .indefinite)
                                
                                let item = AVPlayerItemStub(asset: asset)
                                
                                let player = AVPlayerStub()
                                player.set(currentItem: item)
                                
                                playback.player = player
                                player.setStatus(to: .readyToPlay)
                                
                                var didSeek = false
                                
                                playback.on(Event.didSeek.rawValue) { _ in
                                    didSeek = true
                                }
                                
                                playback.handleDvrAvailabilityChange()
                                
                                expect(didSeek).toEventually(beFalse())
                            }
                        }
                        
                        context("when video is VOD") {
                            it("should not seek") {
                                let playback = AVFoundationPlayback(options: [kLiveStartTime: 2500.0])
                                let playerStub = AVPlayerStub()
                                playback.player = playerStub

                                playerStub.setStatus(to: .readyToPlay)

                                var didSeek = false
                                
                                playback.on(Event.didSeek.rawValue) { _ in
                                    didSeek = true
                                }
                                
                                playback.handleDvrAvailabilityChange()
                                
                                expect(didSeek).toEventually(beFalse())
                            }
                        }
                    }
                }
            }

            describe("#isReadyToPlay") {
                context("when AVPlayer status is readyToPlay") {
                    it("returns true") {
                        let playback = AVFoundationPlayback(options: [:])
                        let playerStub = AVPlayerStub()
                        playback.player = playerStub

                        playerStub.setStatus(to: .readyToPlay)

                        expect(playback.isReadyToPlay).to(beTrue())
                    }
                }

                context("when AVPlayer status is unknown") {
                    it("returns false") {
                        let playback = AVFoundationPlayback(options: [:])
                        let playerStub = AVPlayerStub()
                        playback.player = playerStub

                        playerStub.setStatus(to: .unknown)

                        expect(playback.isReadyToPlay).to(beFalse())
                    }
                }

                context("when AVPlayer status is failed") {
                    it("returns false") {
                        let playback = AVFoundationPlayback(options: [:])
                        let playerStub = AVPlayerStub()
                        playback.player = playerStub

                        playerStub.setStatus(to: .failed)

                        expect(playback.isReadyToPlay).to(beFalse())
                    }
                }
            }

            describe("playbackDidEnd") {
                func generateAssetWith(duration: TimeInterval, currentTime: TimeInterval) -> AVPlayerItemStub {
                    let url = URL(string: "http://clappr.sample/master.m3u8")!
                    let playerAsset = AVURLAssetStub(url: url)
                    let item = AVPlayerItemStub(asset: playerAsset)
                    item._duration = CMTime(seconds: duration, preferredTimescale: 1)
                    item._currentTime = CMTime(seconds: currentTime, preferredTimescale: 1)
                    return item
                }

                func generatePlayback(withState state: PlaybackState, itemDuration: TimeInterval, currentTime: TimeInterval) -> AVFoundationPlaybackMock {
                    let playback = AVFoundationPlaybackMock(options: [:])
                    let playerStub = AVPlayerStub()
                    playback.player = playerStub
                    playerStub.set(currentItem: generateAssetWith(duration: itemDuration, currentTime: currentTime))
                    playback.set(state: state)
                    return playback
                }

                context("when duration and currentTime are the same") {
                    it("calls didComplete") {
                        let playback = generatePlayback(withState: .playing, itemDuration: 100, currentTime: 100)
                        let notification = NSNotification(name: NSNotification.Name(""), object: playback.player?.currentItem)

                        var didCompleteCalled = false
                        playback.on(Event.didComplete.rawValue) { _ in
                            didCompleteCalled = true
                        }

                        playback.playbackDidEnd(notification: notification)

                        expect(didCompleteCalled).to(beTrue())
                        expect(playback.state).to(equal(.idle))
                    }
                }

                context("when duration and currentTime are at most 2 seconds apart") {
                    it("calls didComplete") {
                        let playback = generatePlayback(withState: .playing, itemDuration: 102, currentTime: 100)
                        let notification = NSNotification(name: NSNotification.Name(""), object: playback.player?.currentItem)

                        var didCompleteCalled = false
                        playback.on(Event.didComplete.rawValue) { _ in
                            didCompleteCalled = true
                        }

                        playback.playbackDidEnd(notification: notification)

                        expect(didCompleteCalled).to(beTrue())
                        expect(playback.state).to(equal(.idle))
                    }
                }

                context("when duration and currentTime are more than 2 seconds apart") {
                    it("doesn't call didComplete and keep the same playback state") {
                        let playback = generatePlayback(withState: .playing, itemDuration: 103, currentTime: 100)
                        let notification = NSNotification(name: NSNotification.Name(""), object: playback.player?.currentItem)

                        var didCompleteCalled = false
                        playback.on(Event.didComplete.rawValue) { _ in
                            didCompleteCalled = true
                        }

                        playback.playbackDidEnd(notification: notification)

                        expect(didCompleteCalled).to(beFalse())
                        expect(playback.state).to(equal(.playing))
                    }
                }

                context("when currentItem is not the same as notification object payload") {
                    it("doesn't call didComplete and keep the same playback state") {
                        let playback = generatePlayback(withState: .playing, itemDuration: 103, currentTime: 100)
                        let otherItem = generateAssetWith(duration: 200, currentTime: 200)
                        let notification = NSNotification(name: NSNotification.Name(""), object: otherItem)

                        var didCompleteCalled = false
                        playback.on(Event.didComplete.rawValue) { _ in
                            didCompleteCalled = true
                        }

                        playback.playbackDidEnd(notification: notification)

                        expect(didCompleteCalled).to(beFalse())
                        expect(playback.state).to(equal(.playing))
                    }
                }
            }

            context("when onFailedToPlayToEndTime") {
                it("dispatch error") {
                    let playback = AVFoundationPlayback(options: [:])
                    let error = NSError(domain: "", code: 0, userInfo: [:])
                    let notification = NSNotification(name: NSNotification.Name(""), object: playback.player?.currentItem, userInfo: ["AVPlayerItemFailedToPlayToEndTimeErrorKey": error])

                    var didErrorCalled = false
                    playback.on(Event.error.rawValue) { _ in
                        didErrorCalled = true
                    }

                    playback.onFailedToPlayToEndTime(notification: notification)

                    expect(didErrorCalled).to(beTrue())
                }
                
                context("user info on notification is nil") {
                    it("triggers default error") {
                        let errorKey = "AVPlayerItemFailedToPlayToEndTimeErrorKey"
                        let playback = AVFoundationPlayback(options: [:])
                        let notification = NSNotification(name: NSNotification.Name(""), object: playback.player?.currentItem, userInfo: nil)

                        var error: NSError?
                        playback.on(Event.error.rawValue) { userInfo in
                            error = userInfo?["error"] as? NSError
                        }

                        playback.onFailedToPlayToEndTime(notification: notification)

                        let errorDescription = error?.userInfo[errorKey] as? String
                        expect(errorDescription).to(equal("defaultError"))
                    }
                }
            }

            describe("#seek") {
                var avFoundationPlayback: AVFoundationPlayback!

                beforeEach {
                    avFoundationPlayback = AVFoundationPlayback(options: [kSourceUrl: "http://clappr.sample/master.m3u8"])
                    avFoundationPlayback.play()
                }

                context("when AVPlayer status is readyToPlay") {

                    it("doesn't store the desired seek time") {
                        let playback = AVFoundationPlayback(options: [:])
                        let player = AVPlayerStub()
                        player.setStatus(to: .readyToPlay)
                        playback.player = player

                        playback.seek(20)

                        expect(playback.seekToTimeWhenReadyToPlay).to(beNil())
                    }

                    it("calls seek right away") {
                        let playback = AVFoundationPlaybackMock(options: [:])
                        playback.videoDuration = 100
                        let player = AVPlayerStub()
                        player.setStatus(to: .readyToPlay)
                        playback.player = player

                        playback.seek(20)

                        expect(player._item.didCallSeekWithCompletionHandler).to(beTrue())
                    }
                }

                context("when AVPlayer status is not readyToPlay") {
                    it("stores the desired seek time") {
                        let playback = AVFoundationPlaybackMock(options: [:])
                        playback.videoDuration = 100

                        playback.seek(20)

                        expect(playback.seekToTimeWhenReadyToPlay).to(equal(20))
                    }

                    it("doesn't calls seek right away") {
                        let playback = AVFoundationPlayback(options: [:])
                        let player = AVPlayerStub()
                        playback.player = player

                        player.setStatus(to: .unknown)
                        playback.seek(20)

                        expect(player._item.didCallSeekWithCompletionHandler).to(beFalse())
                    }
                }

                context("when DVR is available") {
                    it("seeks to the correct time inside the DVR window") {
                        item._duration = .indefinite
                        item.setSeekableTimeRange(with: 60)
                        item.setWindow(start: 60, end: 120)
                        itemInfo.update(item: item)
                        player.setStatus(to: .readyToPlay)
                        
                        playback.seek(20)

                        expect(item.didCallSeekWithTime?.seconds).to(equal(80))
                    }
                }

                describe("#seekIfNeeded") {
                    context("when seekToTimeWhenReadyToPlay is nil") {
                        it("doesnt perform a seek") {
                            let playback = AVFoundationPlayback(options: [:])
                            let player = AVPlayerStub()
                            playback.player = player
                            player.setStatus(to: .readyToPlay)

                            playback.seekOnReadyIfNeeded()

                            expect(player._item.didCallSeekWithCompletionHandler).to(beFalse())
                            expect(playback.seekToTimeWhenReadyToPlay).to(beNil())
                        }
                    }

                    context("when seekToTimeWhenReadyToPlay is not nil") {
                        it("does perform a seek") {
                            let playback = AVFoundationPlaybackMock(options: [:])
                            playback.videoDuration = 100
                            let player = AVPlayerStub()
                            playback.player = player
                            player.setStatus(to: .unknown)

                            playback.seek(20)
                            player.setStatus(to: .readyToPlay)
                            playback.seekOnReadyIfNeeded()

                            expect(player._item.didCallSeekWithCompletionHandler).to(beTrue())
                            expect(playback.seekToTimeWhenReadyToPlay).to(beNil())
                        }
                    }
                }

                it("triggers willSeek event and send position") {
                    let playback = AVFoundationPlaybackMock(options: [:])
                    playback.videoDuration = 100
                    let player = AVPlayerStub()
                    playback.player = player
                    player.setStatus(to: .readyToPlay)
                    var didTriggerWillSeek = false
                    var position: Double?
                    let initialSeekPosition = 0.0

                    playback.on(Event.willSeek.rawValue) { userInfo in
                        didTriggerWillSeek = true
                    }
                    position = playback.position
                    playback.seek(5)

                    expect(position).to(equal(initialSeekPosition))
                    expect(didTriggerWillSeek).to(beTrue())
                }

                it("triggers didSeek when a seek is completed and send position") {
                    let playback = AVFoundationPlaybackMock(options: [:])
                    playback.videoDuration = 100
                    let player = AVPlayerStub()
                    playback.player = player
                    player.setStatus(to: .readyToPlay)
                    var didTriggerDidSeek = false
                    var position: Double?
                    let expectedSeekPosition = 5.0

                    playback.on(Event.didSeek.rawValue) { userInfo in
                        position = userInfo?["position"] as? Double
                        didTriggerDidSeek = true
                    }

                    playback.seek(5)

                    expect(position).to(equal(expectedSeekPosition))
                    expect(didTriggerDidSeek).to(beTrue())
                }
                
                context("and playback is paused") {
                    it("triggers didPause event") {
                        let playback = AVFoundationPlaybackMock(options: [:])
                        playback.videoDuration = 100
                        let player = AVPlayerStub()
                        playback.player = player
                        player.setStatus(to: .readyToPlay)
                        playback.set(state: .paused)
                        var didTriggerDidPause = false
                        playback.on(Event.didPause.rawValue) { _ in
                            didTriggerDidPause = true
                        }

                        playback.seek(5)

                        expect(didTriggerDidPause).to(beTrue())
                    }
                }

                it("triggers didUpdatePosition for the desired position") {
                    let playback = AVFoundationPlaybackMock(options: [:])
                    playback.videoDuration = 100
                    let player = AVPlayerStub()
                    playback.player = player
                    player.setStatus(to: .readyToPlay)
                    var updatedPosition: Double? = nil
                    let expectedSeekPosition = 5.0

                    playback.on(Event.didUpdatePosition.rawValue) { (userInfo: EventUserInfo) in
                        updatedPosition = userInfo!["position"] as? Double
                    }

                    playback.seek(5)

                    expect(updatedPosition).to(equal(expectedSeekPosition))
                }

                it("triggers didUpdatePosition before didSeek event") {
                    let playback = AVFoundationPlaybackMock(options: [:])
                    playback.videoDuration = 100
                    let player = AVPlayerStub()
                    playback.player = player
                    player.setStatus(to: .readyToPlay)
                    var updatedPosition: Double? = nil
                    var didSeek = false
                    var didTriggerDidSeekBefore = false
                    let expectedSeekPosition = 5.0

                    playback.on(Event.didSeek.rawValue) { _ in
                        didSeek = true
                    }
                    playback.on(Event.didUpdatePosition.rawValue) { (userInfo: EventUserInfo) in
                        updatedPosition = userInfo!["position"] as? Double
                        if didSeek {
                            didTriggerDidSeekBefore = true
                        }
                    }

                    playback.seek(5)

                    expect(updatedPosition).to(equal(expectedSeekPosition))
                    expect(didTriggerDidSeekBefore).to(beFalse())
                }
            }

            describe("#seekToLivePosition") {
                var playback: AVFoundationPlayback!
                var playerItem: AVPlayerItemStub!

                beforeEach {
                    playback = AVFoundationPlayback(options: [:])
                    let url = URL(string: "http://clappr.sample/master.m3u8")!
                    let playerAsset = AVURLAssetStub(url: url)
                    playerItem = AVPlayerItemStub(asset: playerAsset)
                    playerItem.setSeekableTimeRange(with: 45)
                    let player = AVPlayerStub()
                    player.set(currentItem: playerItem)
                   
                    itemInfo = AVPlayerItemInfo(item: playerItem, delegate: playback)
                    playback.itemInfo = itemInfo
                    
                    playback.player = player
                    player.setStatus(to: .readyToPlay)
                }

                it("triggers seek event") {
                    var didTriggerDidSeek = false
                    playback.once(Event.didSeek.rawValue) { _ in
                        didTriggerDidSeek = true
                    }

                    playback.seekToLivePosition()

                    expect(didTriggerDidSeek).toEventually(beTrue())
                }

                it("triggers didUpdatePosition for the desired position") {
                    var updatedPosition: Double? = nil
                    playback.once(Event.didUpdatePosition.rawValue) { userInfo in
                        updatedPosition = userInfo?["position"] as? Double
                    }

                    playback.seekToLivePosition()
                    let endPosition = playback.seekableTimeRanges.last?.timeRangeValue.end.seconds

                    expect(updatedPosition).to(equal(endPosition))
                }
            }

            describe("#isDvrInUse") {
                beforeEach {
                    item._duration = .indefinite
                    item.setSeekableTimeRange(with: 160)
                    
                    itemInfo.update(item: item)
                    
                    player.setStatus(to: .readyToPlay)

                }
                context("when video is paused") {
                    it("returns true") {
                        playback.pause()

                        expect(playback.isDvrInUse).to(beTrue())
                    }
                }

                context("when currentTime is lower then dvrWindowEnd - liveHeadTolerance") {
                    it("returns true") {
                        item.set(currentTime: CMTime(seconds: 154, preferredTimescale: 1))
                        
                        player.play()

                        expect(playback.isDvrInUse).toEventually(beTrue())
                    }
                }

                context("when currentTime is higher or equal then dvrWindowEnd - liveHeadTolerance") {
                    it("returns false") {
                        player.set(currentTime: CMTime(seconds: 156, preferredTimescale: 1))

                        player.play()

                        expect(playback.isDvrInUse).toEventually(beFalse())
                    }
                }
            }

            describe("#didFindAudio") {

                context("when video is ready") {
                    context("and has no default audio from options") {
                        it("triggers didFindAudio event with hasDefaultFromOption false") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)
                            playback.render()
                            
                            var hasDefaultFromOption = true
                            playback.on(Event.didFindAudio.rawValue) { userInfo in
                                guard let audio = userInfo?["audios"] as? AvailableMediaOptions else { return }
                                hasDefaultFromOption = audio.hasDefaultSelected
                            }

                            playback.play()

                            expect(hasDefaultFromOption).toEventually(beFalse(), timeout: 2)
                        }
                    }
                }
            }

            describe("#selectDefaultSubtitleIfNeeded") {
                context("for online asset") {
                    it("changes subtitle just once") {
                        let options = [kSourceUrl: "http://clappr.sample/sample.m3u8", kDefaultSubtitle: "pt"]
                        let playback = AVFoundationPlayback(options: options)
                        playback.render()
                        
                        var hasDefaultFromOption = false
                        playback.on(Event.didFindSubtitle.rawValue) { userInfo in
                            guard let subtitles = userInfo?["subtitles"] as? AvailableMediaOptions else { return }
                            hasDefaultFromOption = subtitles.hasDefaultSelected
                        }
                        playback.play()
                        expect(hasDefaultFromOption).toEventually(beTrue(), timeout: 5)
                        
                        playback.selectDefaultSubtitleIfNeeded()
                        
                        expect(hasDefaultFromOption).toEventually(beFalse(), timeout: 5)
                    }
                }
                context("for local asset") {
                    it("changes subtitle source") {
                        guard let pathSubtitle = Bundle(for: AVFoundationPlaybackTests.self).path(forResource: "sample", ofType: "movpkg") else {
                            fail("Could not load local sample")
                            return
                        }
                        let localURL = URL(fileURLWithPath: pathSubtitle)
                        let options = [kSourceUrl: localURL.absoluteString, kDefaultSubtitle: "pt"]
                        let playback = AVFoundationPlayback(options: options)

                        playback.play()

                        expect(playback.subtitles?.first?.name).toEventually(equal("Portuguese"), timeout: 5)
                    }
                }
            }

            describe("#changeSubtitleStyle") {
                it("changes the subtitles style") {
                    let options = [kSourceUrl: "http://clappr.sample/sample.m3u8", kDefaultSubtitle: "pt"]
                    let playback = AVFoundationPlayback(options: options)
                    let expectedvalue = [
                        AVTextStyleRule(textMarkupAttributes: [String((kCMTextMarkupAttribute_BoldStyle)) : true]),
                        AVTextStyleRule(textMarkupAttributes: [String((kCMTextMarkupAttribute_GenericFontFamilyName)) : kCMTextMarkupGenericFontName_Default]),
                    ]

                    playback.play()
                    let didChangeSubtitleStyle = playback.applySubtitleStyle(with: [
                        .bold,
                        .font(.default)
                    ])

                    expect(didChangeSubtitleStyle).to(beTrue())
                    expect(playback.player?.currentItem?.textStyleRules).toEventually(equal(expectedvalue), timeout: 2)
                }
            }

            describe("#selectDefaultAudioIfNeeded") {
                context("for online asset") {
                    it("changes audio just once") {
                        let options = [kSourceUrl: "http://clappr.sample/sample.m3u8", kDefaultAudioSource: "pt"]
                        let playback = AVFoundationPlayback(options: options)
                        playback.render()
                        
                        var hasDefaultFromOption = false
                        playback.on(Event.didFindAudio.rawValue) { userInfo in
                            guard let audio = userInfo?["audios"] as? AvailableMediaOptions else { return }
                            hasDefaultFromOption = audio.hasDefaultSelected
                        }
                        playback.play()
                        expect(hasDefaultFromOption).toEventually(beTrue(), timeout: 5)

                        playback.selectDefaultAudioIfNeeded()

                        expect(hasDefaultFromOption).toEventually(beFalse(), timeout: 2)
                    }
                }
                context("for local asset") {
                    context("when default audio is passed") {
                        it("changes the audio source") {
                            guard let pathAudio = Bundle(for: AVFoundationPlaybackTests.self).path(forResource: "sample", ofType: "movpkg") else {
                                fail("Could not load local sample")
                                return
                            }
                            let localURL = URL(fileURLWithPath: pathAudio)
                            let options = [kSourceUrl: localURL.absoluteString, kDefaultAudioSource: "por"]
                            let playback = AVFoundationPlayback(options: options)

                            playback.play()

                            expect(playback.audioSources?.first?.name).toEventually(equal("Portuguese"), timeout: 5)
                        }
                    }
                }
            }

            describe("#didFindSubtitle") {
                context("when video is ready and has subtitle available") {
                    context("and has default subtitle from options") {
                        it("triggers didFindSubtitle event with hasDefaultFromOption true") {
                            let options = [kSourceUrl: "http://clappr.sample/sample.m3u8", kDefaultSubtitle: "pt"]
                            let playback = AVFoundationPlayback(options: options)
                            playback.render()
                            var hasDefaultFromOption = false
                            playback.on(Event.didFindSubtitle.rawValue) { userInfo in
                                guard let subtitles = userInfo?["subtitles"] as? AvailableMediaOptions else { return }
                                hasDefaultFromOption = subtitles.hasDefaultSelected
                            }

                            playback.play()

                            expect(hasDefaultFromOption).toEventually(beTrue(), timeout: 5)
                        }
                    }

                    context("and has no default subtitle from options") {
                        it("triggers didFindSubtitle event with hasDefaultFromOption false") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)
                            playback.render()
                            var hasDefaultFromOption = true
                            playback.on(Event.didFindSubtitle.rawValue) { userInfo in
                                guard let subtitles = userInfo?["subtitles"] as? AvailableMediaOptions else { return }
                                hasDefaultFromOption = subtitles.hasDefaultSelected
                            }

                            playback.play()

                            expect(hasDefaultFromOption).toEventually(beFalse(), timeout: 4)
                        }
                    }
                }
            }

            describe("#didSelectSubtitle") {

                var avFoundationPlayback: AVFoundationPlayback!

                beforeEach {
                    stub(condition: isHost("clappr.sample")) { _ in
                        let stubPath = OHPathForFile("sample.m3u8", type(of: self))
                        return fixture(filePath: stubPath!, headers: ["Content-Type":"application/vnd.apple.mpegURL; charset=utf-8"])
                    }

                    avFoundationPlayback = AVFoundationPlayback(options: [kSourceUrl: "https://clappr.sample/sample.m3u8"])

                    avFoundationPlayback.play()
                }

                context("when playback does not have subtitles") {
                    it("returns nil for selected subtitle") {
                        expect(playback.selectedSubtitle).to(beNil())
                    }
                }

                context("when playback has subtitles") {
                    it("returns default subtitle for a playback with subtitles") {
                        expect(avFoundationPlayback.selectedSubtitle).toEventuallyNot(beNil(), timeout: 2)
                    }
                }

                context("when subtitle is selected") {
                    it("triggers didSelectSubtitle event") {
                        var subtitleOption: MediaOption?
                        avFoundationPlayback.on(Event.didSelectSubtitle.rawValue) { userInfo in
                            subtitleOption = userInfo?["mediaOption"] as? MediaOption
                        }

                        avFoundationPlayback.selectedSubtitle = avFoundationPlayback.subtitles?.first

                        expect(subtitleOption).toEventuallyNot(beNil())
                        expect(subtitleOption).toEventually(beAKindOf(MediaOption.self))
                    }
                }
            }

            describe("#selectedAudioSource") {
                it("returns nil for a playback without audio sources") {
                    expect(playback.selectedAudioSource).to(beNil())
                }

                context("when audio is selected") {
                    it("triggers didSelectAudio event") {
                        var audioSelected: MediaOption?
                        playback.on(Event.didSelectAudio.rawValue) { userInfo in
                            audioSelected = userInfo?["mediaOption"] as? MediaOption
                        }

                        playback.selectedAudioSource = MediaOption(name: "English", type: MediaOptionType.audioSource, language: "eng", raw: AVMediaSelectionOption())

                        expect(audioSelected).toEventuallyNot(beNil())
                        expect(audioSelected).to(beAKindOf(MediaOption.self))
                    }
                }
            }

            describe("#AVFoundationPlayback states") {
                describe("#idle") {
                    context("when ready to play") {
                        it("current state must be idle") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)

                            expect(playback.state).toEventually(equal(.idle))
                        }
                    }

                    context("when play is called") {
                        it("changes isPlaying to true") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)
                            playback.render()
                            
                            playback.play()

                            expect(playback.state).toEventually(equal(.playing), timeout: 10)
                        }
                    }

                    context("when pause is called") {
                        it("changes current state to paused") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)

                            playback.pause()

                            expect(playback.state).toEventually(equal(.paused), timeout: 3)
                        }
                    }
                    context("when stop is called") {
                        it("does not trigger didStop event") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)
                            var didStopWasTriggered = false
                            playback.on(Event.didStop.rawValue) { _ in
                                didStopWasTriggered = true
                            }
                            
                            playback.stop()
                            
                            expect(didStopWasTriggered).to(beFalse())
                        }
                    }
                }

                describe("#playing") {
                    context("when paused is called") {
                        it("changes current state to paused") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)

                            playback.play()
                            playback.pause()

                            expect(playback.state).toEventually(equal(.paused))
                        }
                    }

                    context("when seek is called") {
                        it("keeps playing") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)
                            playback.render()
                            
                            playback.play()
                            playback.seek(10)

                            expect(playback.state).toEventually(equal(.playing), timeout: 3)
                        }
                    }

                    context("when stop is called") {
                        it("changes state to idle") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)

                            playback.play()
                            playback.stop()

                            expect(playback.state).toEventually(equal(.idle), timeout: 3)
                        }
                    }

                    context("when video is over") {
                        it("changes state to idle") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)

                            playback.play()
                            playback.seek(playback.duration)

                            expect(playback.state).toEventually(equal(.idle), timeout: 10)
                        }
                    }

                    context("when is not likely to keep up") {
                        it("changes state to stalling") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)
                            playback.render()
                            
                            playback.play()

                            expect(playback.state).to(equal(.stalling))
                        }
                    }
                }

                describe("#paused") {
                    context("when playing is called") {
                        it("changes isPlaying to true") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)
                            playback.render()
                            
                            playback.play()
                            playback.pause()
                            playback.play()

                            expect(playback.state).toEventually(equal(.playing), timeout: 3)
                        }
                    }

                    context("when seek is called") {
                        it("keeps state in paused") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)

                            playback.play()
                            playback.pause()
                            playback.seek(10)

                            expect(playback.state).to(equal(.paused))
                        }
                    }

                    context("when stop is called") {
                        it("changes state to idle") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)

                            playback.play()
                            playback.pause()
                            playback.stop()

                            expect(playback.state).to(equal(.idle))
                        }
                    }

                    context("when is not likely to keep up") {
                        it("changes state to stalling") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)
                            playback.render()
                            
                            playback.play()
                            playback.pause()
                            playback.play()

                            expect(playback.state).toEventually(equal(.stalling), timeout: 3)
                        }
                    }
                }

                describe("#stalling") {
                    context("when seek is called") {
                        it("keeps stalling state") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)
                            playback.render()
                            
                            playback.play()
                            playback.seek(10)

                            expect(playback.state).to(equal(.stalling))
                        }
                    }

                    context("when paused is called") {
                        it("changes state to paused") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)
                            playback.render()
                            
                            playback.play()
                            playback.pause()

                            expect(playback.state).to(equal(.paused))
                        }
                    }

                    context("when stop is called") {
                        it("changes state to idle") {
                            let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                            let playback = AVFoundationPlayback(options: options)
                            playback.render()
                            
                            playback.play()
                            playback.stop()

                            expect(playback.state).to(equal(.idle))
                        }
                    }
                }
            }

            describe("#setupPlayer") {
                context("when asset is available") {
                    it("triggers event assetAvailable") {
                        let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                        let playback = AVFoundationPlayback(options: options)
                        playback.render()
                        var didTriggerAssetReady = false

                        playback.on(Event.assetReady.rawValue) { _ in
                            didTriggerAssetReady = true
                        }

                        playback.play()

                        expect(didTriggerAssetReady).toEventually(beTrue())
                    }
                }
            }
            
            describe("#mute") {
                context("when mute is enabled") {
                    it("sets volume to zero") {
                        playback.mute(true)
                        
                        expect(player.volume).to(equal(0))
                    }
                }
                context("when mute is disabled") {
                    it("sets volume to maximum") {
                        player.volume = 0
                        
                        playback.mute(false)
                        
                        expect(player.volume).to(equal(1))
                    }
                }
            }
        }
    }
}

private class StubbedLiveDatePlayback: AVFoundationPlayback {
    var _position: Double = .zero
    override var position: Double { _position }

    var _duration: Double = .zero
    override var duration: Double { _duration }

    var _playbackType: PlaybackType = .live
    override var playbackType: PlaybackType { _playbackType }
}

