//
//  MusicList.swift
//  MusicPlay
//
//  Created by User on 5/18/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit
import AVFoundation

class Player: NSObject,AVAudioPlayerDelegate {
    //adpoting AVAudioPlayerDelegate Protocol declares audioPlayerDidFinishPlaying(_:Succefull:) which notifies audio has finished palying
    
    var player : AVAudioPlayer?
    var currentTrackIndex = 0
    var tracksUrl:[Any] = [Any]()
    var tracksName:[String] = [String]()
    var error:NSError?
    
    // invoke FileReader's read file method to fecth the paths of mp3
    init(tracksPlayerUrl:[Any],trackName:[String]){
        super.init()
        self.tracksUrl = tracksPlayerUrl
        self.tracksName = trackName

        queueTrack()
    }
    
    //invoke fileUrlWithPath to fetch the current MP3 file and store the value in url
    //passing tracks array as a param currentTrackIndex.Tracks array contains the path to mp3
    //passing url to AVAudioPlayer
    //Preparing AVAudio Player Deletgate property to self
    func queueTrack(){
        if( player != nil){
            player = nil
        }
        
        
        let url = tracksUrl[currentTrackIndex]
        do{
            try player = AVAudioPlayer(contentsOf: url as! URL)
        }catch{
            print("______Error_____",error)
        }
        
        
        if let hasError = error{
            print(hasError)
        }else{
            player?.delegate = self
            player?.prepareToPlay()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SetTrackNameText"), object: nil)
        }
    }
    
    //  player to play the audio if player is not playing audio
    func play(){
        if player?.isPlaying == false{
            player?.play()
        }
    }
    
    // player to stop the audio if its playing
    func stop(){
        if player?.isPlaying ==  true{
            player?.stop()
            player?.currentTime = 0
        }
    }
    
    // player to pause the audio if its playing
    func pause(){
        if player?.isPlaying ==  true{
            player?.pause()
        }
    }
    
    //nextSong method  queus up to the next song if the player is playing
    //songFinshedPlaying method called when song finished playing
    //playerWasPlaying variable used to check wheather or not player was playing
    //incriment the current currentTrackIndex and check to see if it is greater than or equal to tracks count
    func nextSong(songFinshedPlaying:Bool){
        var playerWasPlaying = false
        if player?.isPlaying == true{
            player?.stop()
            playerWasPlaying = true
        }
        currentTrackIndex += 1
//        if currentTrackIndex >= tracks.count{
        if currentTrackIndex >= tracksUrl.count{
            currentTrackIndex = 0
        }
        queueTrack()
        if playerWasPlaying || songFinshedPlaying{
            player?.play()
        }
    }
    
    //decrement the currentTrackIndex and check if it is equal to 0
    // playing the previous song
    func previousSong(){
        var playerWasPlaying = false
        if player?.isPlaying == true{
            player?.stop()
            playerWasPlaying = true
        }
        currentTrackIndex -= 1
        if currentTrackIndex < 0{
            currentTrackIndex = tracksUrl.count - 1
        }
//        queueTrack(tracks: tracks, song: songQueryPlayer)
        queueTrack()
        if playerWasPlaying{
            player?.play()
        }
    }
    
    //getCurrentTrackName method gets the name of MP3 file without extension
    func getCurrentTrackName() -> String{
        let trackName = (tracksName[currentTrackIndex])
        return trackName as String
    }
    
    // current time property is of type NSInterval
    func getCurrentTimeAsString() -> String{
        var seconds = 0
        var minutes = 0
        if let time = player?.currentTime{
            seconds = Int(time) % 60
            minutes = (Int(time)/60) % 60
        }
        return String(format : "%0.2d:%0.2d",minutes,seconds)
        
    }
    
    //getProgress method used to indicate the how much of Mp3 has been played
    func getProgress() -> Float{
        var theCurrentTime = 0.0
        let theCurrentDuration = 0.0
        if let currentTime = player?.currentTime, let duration = player?.duration{
            theCurrentTime = currentTime
            theCurrentTime = duration
            
        }
        let ratio = Float(theCurrentTime / theCurrentDuration)
        return ratio
    }
    
    //set volume method setVolume of the player instance
    func setVolume(volume:Float){
        player?.volume = volume
    }
    
    //method of AVAudioPlayerDelegate Protocol tells if the player has stoped playing 
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        if flag == true {
            nextSong(songFinshedPlaying: true)
        }
    }
    
}
