//
//  AudioController.swift
//  Anagrams
//
//  Created by Game on 2019. 5. 23..
//  Copyright © 2019년 Caroline. All rights reserved.
//

import AVFoundation

class AudioController{
    private var audio = [String: AVAudioPlayer]()
    
    var player: AVAudioPlayer?
    
    func preloadAudioEffects(audioFileNames: [String]){
        for effect in AudioEffectFiles{
            let soundPath = Bundle.main.path(forResource: effect, ofType: nil)
            let soundURL = NSURL.fileURL(withPath: soundPath!)
            
            do{
                player = try AVAudioPlayer(contentsOf: soundURL)
                guard let player = player else{
                    return
                }
                player.numberOfLoops = 0
                player.prepareToPlay()
                audio[effect] = player
            } catch let error{
                print(error.localizedDescription)
            }
        }
    }
    
    func playerEffect(name: String){
        if let player = audio[name]{
            if player.isPlaying{
                player.currentTime = 0
            } else {
                player.play()
            }
        }
    }
}
