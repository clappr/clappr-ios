import Quick
import Nimble
import AVFoundation
import Swifter

@testable import Clappr

class AVFoundationPlaybackStateMachineEventsTests: QuickSpec {
    override func spec() {
        describe("AVFoundationPlayback Tests") {
            let server = HTTPStub()
            let unwantedEvents: [Event] = [
                .didUpdateBuffer, .didUpdatePosition,
                .seekableUpdate, .didFindAudio,
                .didFindSubtitle, .didChangeDvrAvailability,
                .didUpdateDuration
            ]

            beforeSuite {
                server.start()
            }

            afterSuite {
                server.stop()
            }

            describe("#state machine events") {
                context("when play, pause, seek, play and stop") {
                    it("triggers events following the state machine pattern") {
                        let options = [kSourceUrl: "http://localhost:8080/sample.m3u8"]
                        let playback = AVFoundationPlayback(options: options)
                        let expectedEvents: [Event] = [
                            .ready, .willPlay, .stalling, .willPlay, .playing,
                            .willPause, .didPause, .willSeek, .didSeek,
                            .willPlay, .playing, .willStop, .didStop
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
                            playback.pause()
                            playback.seek(2)
                        }
                        playback.once(Event.didSeek.rawValue) { _ in
                            playback.play()

                            playback.once(Event.playing.rawValue) { _ in
                                playback.stop()
                            }
                        }

                        expect(triggeredEvents).toEventually(equal(expectedEvents), timeout: 10)
                    }
                }

                context("when play and seek to end") {
                    it("triggers events following the state machine pattern") {
                        let options = [kSourceUrl: "http://localhost:8080/sample.m3u8"]
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
                        let options = [kSourceUrl: "http://localhost:8080/sample.m3u8"]
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
                        let options = [kSourceUrl: "http://localhost:8080/sample.m3u8"]
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
            }

            describe("#state machine error events") {
                beforeEach {
                    server.stop()
                }

                afterEach {
                    server.start()
                }

                context("when play and an error occurs") {
                    it("triggers events following the state machine pattern") {
                        let options = [kSourceUrl: "http://localhost:8080/sample.m3u8"]
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

                        expect(triggeredEvents).toEventually(equal(expectedEvents), timeout: 5)
                    }
                }
            }
        }
    }
}
