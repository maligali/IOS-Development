//
//  ViewController.swift
//  MusicPlayer
//
//

import UIKit
import AVFoundation

final class ViewController: UIViewController, AVAudioPlayerDelegate {

    // Connect these outlets to the Storyboard objects.
    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var artistLabel: UILabel!
    @IBOutlet private weak var previousButton: UIButton!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!

    private var currentTrackIndex = 0
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false

    private var currentTrack: Track {
        TrackLibrary.tracks[currentTrackIndex]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard !TrackLibrary.tracks.isEmpty else {
            print("TrackLibrary is empty.")
            return
        }

        configureAppearance()
        refreshTrackUI()
        updatePlayPauseIcon()
    }

    private func configureAppearance() {
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true

        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        artistLabel.numberOfLines = 0
        artistLabel.textAlignment = .center

        previousButton.setImage(UIImage(systemName: "backward.fill"), for: .normal)
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        nextButton.setImage(UIImage(systemName: "forward.fill"), for: .normal)

        previousButton.accessibilityLabel = "Previous track"
        playPauseButton.accessibilityLabel = "Play or pause"
        nextButton.accessibilityLabel = "Next track"
    }

    private func refreshTrackUI() {
        let track = currentTrack
        print("Track title: \(track.title)")
        print("Track artist: \(track.artist)")
        titleLabel.text = track.title
        artistLabel.text = track.artist
        coverImageView.image = UIImage(named: track.coverImageName)

        if coverImageView.image == nil {
            // A fallback keeps the UI usable if a cover asset was not added.
            coverImageView.image = UIImage(systemName: "music.note")
            print("Missing cover image asset: \(track.coverImageName)")
        }
    }

    private func updatePlayPauseIcon() {
        let symbol = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: symbol), for: .normal)
    }

    @IBAction private func playPauseTapped(_ sender: UIButton) {
        if isPlaying {
            audioPlayer?.pause()
            isPlaying = false
            updatePlayPauseIcon()
            return
        }

        // If the current file has not been loaded yet, load it first.
        if audioPlayer == nil {
            guard loadCurrentTrack() else { return }
        }

        guard let player = audioPlayer else { return }

        if player.play() {
            isPlaying = true
            updatePlayPauseIcon()
        } else {
            print("Could not start playback for: \(currentTrack.fileName)")
        }
    }

    @IBAction private func nextTapped(_ sender: UIButton) {
        changeTrack(by: 1)
    }

    @IBAction private func previousTapped(_ sender: UIButton) {
        changeTrack(by: -1)
    }

    private func changeTrack(by offset: Int) {
        guard !TrackLibrary.tracks.isEmpty else { return }

        let shouldResumePlayback = isPlaying
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false

        let count = TrackLibrary.tracks.count
        currentTrackIndex = (currentTrackIndex + offset + count) % count

        refreshTrackUI()
        updatePlayPauseIcon()

        if shouldResumePlayback {
            guard loadCurrentTrack() else { return }
            if audioPlayer?.play() == true {
                isPlaying = true
                updatePlayPauseIcon()
            }
        }
    }

    @discardableResult
    private func loadCurrentTrack() -> Bool {
        let track = currentTrack
        let fileName = track.fileName as NSString
        let resourceName = fileName.deletingPathExtension
        let fileExtension = fileName.pathExtension

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension) else {
            print("Audio file not found in app bundle: \(track.fileName). Check that the file is added to the app target.")
            return false
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.prepareToPlay()
            audioPlayer = player
            return true
        } catch {
            print("Could not load \(track.fileName): \(error.localizedDescription)")
            return false
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Automatically advance and start the next track after the current one ends.
        changeTrack(by: 1)
        if !isPlaying {
            guard loadCurrentTrack() else { return }
            if audioPlayer?.play() == true {
                isPlaying = true
                updatePlayPauseIcon()
            }
        }
    }
}
