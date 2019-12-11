import Quick
import Nimble
import AVFoundation
import OHHTTPStubs

@testable import Clappr

class AVFoundationPlaybackStateMachineEventsTests: QuickSpec {
    override func spec() {
        describe("AVFoundationPlayback Tests") {
            let unwantedEvents: [Event] = [
                .didUpdateBuffer, .didUpdatePosition,
                .seekableUpdate, .didFindAudio,
                .didFindSubtitle, .didChangeDvrAvailability,
                .didUpdateDuration, .didUpdateBitrate,
                .assetReady
            ]

            beforeEach {
                OHHTTPStubs.removeAllStubs()
                stub(condition: isHost("clappr.sample")) { result in
                    if result.url?.path == "/master.m3u8" {
                        let stubPath = OHPathForFile("master.m3u8", type(of: self))
                        return fixture(filePath: stubPath!, headers: [:])
                    } else if result.url!.path.contains(".ts") {
                        let stubPath = OHPathForFile(result.url!.path.replacingOccurrences(of: "/", with: ""), type(of: self))
                        return fixture(filePath: stubPath!, headers: [:])
                    }
                    
                    let stubPath = OHPathForFile("master.m3u8", type(of: self))
                    return fixture(filePath: stubPath!, headers: [:])
                }
            }

            describe("#state machine events") {
                context("when play, pause, seek, play and stop") {
                    it("triggers events following the state machine pattern") {
                        let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                        let playback = AVFoundationPlayback(options: options)
                        let expectedEvents: [Event] = [
                            .ready, .willPlay, .stalling, .willPlay, .playing,
                            .willPause, .didPause, .willSeek, .didSeek,
                            .willPlay, .stalling, .willPlay, .playing, .willStop, .didStop
                        ]
                        var triggeredEvents: [Event] = []
                        for event in Set(Event.allCases).subtracting(Set(unwantedEvents)) {
                            playback.on(event.rawValue) { _ in
                                triggeredEvents.append(event)
                            }
                        }

                        playback.once(Event.didSeek.rawValue) { _ in
                            playback.play()
                            
                            playback.once(Event.playing.rawValue) { _ in
                                playback.stop()
                            }
                        }
                        
                        playback.once(Event.playing.rawValue) { _ in
                            playback.pause()
                            playback.seek(2)
                        }

                        playback.render()
                        
                        #if os(iOS)
                        playback.play()
                        #endif
                        
                        expect(triggeredEvents).toEventually(equal(expectedEvents), timeout: 15)
                    }
                }

                context("when play and seek to end") {
                    it("triggers events following the state machine pattern") {
                        let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                        let playback = AVFoundationPlayback(options: options)
                        let expectedEvents: [Event] = [
                            .ready, .willPlay, .stalling, .willPlay, .playing,
                            .willSeek, .stalling, .playing, .didSeek, .stalling,
                            .playing, .didComplete
                        ]
                        var triggeredEvents: [Event] = []
                        for event in Set(Event.allCases).subtracting(Set(unwantedEvents)) {
                            playback.on(event.rawValue) { _ in
                                triggeredEvents.append(event)
                            }
                        }
                        playback.render()

                        #if os(iOS)
                        playback.play()
                        #endif
                        playback.once(Event.playing.rawValue) { _ in
                            playback.seek(playback.duration)
                        }

                        expect(triggeredEvents).toEventually(equal(expectedEvents), timeout: 12)
                    }
                }

                context("when pause, play and stop") {
                    it("triggers events following the state machine pattern") {
                        let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                        let playback = AVFoundationPlayback(options: options)
                        let expectedEvents: [Event] = [
                            .ready, .willPause, .didPause,
                            .willPlay, .stalling, .willStop, .didStop
                        ]
                        var triggeredEvents: [Event] = []
                        for event in Set(Event.allCases).subtracting(Set(unwantedEvents)) {
                            playback.on(event.rawValue) { _ in
                                triggeredEvents.append(event)
                            }
                        }
                        playback.render()

                        playback.pause()
                        playback.play()
                        playback.stop()
                        playback.destroy()

                        expect(triggeredEvents).toEventually(equal(expectedEvents), timeout: 5)
                    }
                }

                context("when pause, play, pause and stop") {
                    it("triggers events following the state machine pattern") {
                        let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                        let playback = AVFoundationPlayback(options: options)
                        let expectedEvents: [Event] = [
                            .ready, .willPause, .didPause,
                            .willPlay, .stalling, .willPause,
                            .didPause, .willStop, .didStop
                        ]
                        var triggeredEvents: [Event] = []
                        for event in Set(Event.allCases).subtracting(Set(unwantedEvents)) {
                            playback.on(event.rawValue) { _ in
                                triggeredEvents.append(event)
                            }
                        }
                        playback.render()

                        playback.pause()
                        playback.play()
                        playback.pause()
                        playback.stop()
                        playback.destroy()

                        expect(triggeredEvents).toEventually(equal(expectedEvents), timeout: 5)
                    }
                }
                
                context("when pause and seek") {
                    it("triggers events following the state machine pattern") {
                        let options = [kSourceUrl: "http://clappr.sample/master.m3u8"]
                        let playback = AVFoundationPlayback(options: options)
                        let expectedEvents: [Event] = [
                            .ready, .willPlay, .stalling,
                            .willPlay, .playing, .willPause,
                            .didPause, .willSeek, .didSeek,
                            .didPause
                        ]
                        var triggeredEvents: [Event] = []
                        for event in Set(Event.allCases).subtracting(Set(unwantedEvents)) {
                            playback.on(event.rawValue) { _ in
                                triggeredEvents.append(event)
                            }
                        }
                        playback.once(Event.didPause.rawValue) { _ in
                            playback.seek(2)
                        }
                        playback.once(Event.playing.rawValue) { _ in
                            playback.pause()
                        }
                        
                        playback.render()
                        playback.play()

                        expect(triggeredEvents).toEventually(equal(expectedEvents), timeout: 25)
                    }
                }
            }

            describe("#state machine error events") {
                context("when play and an error occurs") {
                    it("triggers events following the state machine pattern") {
                        let options = [kSourceUrl: "http://clappr8.sample/master.m3u8"]
                        let playback = AVFoundationPlayback(options: options)
                        let expectedEvents: [Event] = [
                            .ready, .willPlay, .stalling, .error, .didPause
                        ]
                        var triggeredEvents: [Event] = []
                        for event in Set(Event.allCases).subtracting(Set(unwantedEvents)) {
                            playback.on(event.rawValue) { _ in
                                triggeredEvents.append(event)
                            }
                        }

                        playback.render()

                        #if os(iOS)
                        playback.play()
                        #endif

                        expect(triggeredEvents).toEventually(equal(expectedEvents), timeout: 30)
                    }
                }
            }
        }
    }
}
