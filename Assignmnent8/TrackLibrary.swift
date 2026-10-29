import Foundation

enum TrackLibrary {
    // Add matching royalty-free audio files to the app target:
    // track01.mp3, track02.mp3, ... track10.mp3
    // Keep each file under 10 MB and check Target Membership in Xcode.
    static let tracks: [Track] = [
        Track(title: "Midnight Drive", artist: "Royalty-Free Collection", fileName: "track01.mp3", coverImageName: "cover01"),
        Track(title: "After Hours", artist: "Royalty-Free Collection", fileName: "track02.mp3", coverImageName: "cover02"),
        Track(title: "Cold Lights", artist: "Royalty-Free Collection", fileName: "track03.mp3", coverImageName: "cover03"),
        Track(title: "Slow Motion", artist: "Royalty-Free Collection", fileName: "track04.mp3", coverImageName: "cover04"),
        Track(title: "No Signal", artist: "Royalty-Free Collection", fileName: "track05.mp3", coverImageName: "cover05"),
        Track(title: "Blue Hour", artist: "Royalty-Free Collection", fileName: "track06.mp3", coverImageName: "cover06"),
        Track(title: "Quiet Storm", artist: "Royalty-Free Collection", fileName: "track07.mp3", coverImageName: "cover07"),
        Track(title: "Fading Echoes", artist: "Royalty-Free Collection", fileName: "track08.mp3", coverImageName: "cover08"),
        Track(title: "Dark Room", artist: "Royalty-Free Collection", fileName: "track09.mp3", coverImageName: "cover09"),
        Track(title: "Last Train", artist: "Royalty-Free Collection", fileName: "track10.mp3", coverImageName: "cover10")
    ]
}
