//
//  AudioPlayer.swift
//  DarkSlide
//
//  Created by Calum Harris on 17/11/2016.
//  Copyright © 2016 Calum Harris. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayer: NSObject, AVAudioPlayerDelegate {

	var player: AVAudioPlayer!

	func playSoundFile(atPath url: URL) {
		self.player?.stop()
		guard let p = try? AVAudioPlayer(contentsOf: url) else { print("error with url audio player"); return }
		self.player = p
		player.delegate = self
		self.player.prepareToPlay()
		print("playing")
		self.player.play()
	}

	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		print("audio player finished playing \(flag)")
	}
}
