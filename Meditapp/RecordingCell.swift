//
//  RecordingCell.swift
//  Meditapp
//
//  Created by Jackson Lu on 3/8/21.
//
import UIKit
import AVFoundation

class RecordingCell: UITableViewCell, AVAudioPlayerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
//    var audioPlayerRef: AVAudioPlayer = RecordingViewController.audioPlayer
    var recordingName: String?
    
    func getDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDir = paths[0]
        return documentDir
    }
    
//    var playAudio: ((UITableViewCell) -> Bool?)?
    override func awakeFromNib() {
        super.awakeFromNib()
        print("did i st delegate")
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func playTap(_ sender: Any) {
        if (!RecordingViewController.audioPlayer.isPlaying){
            do{
                print("about to play audio")
                RecordingViewController.playingCell = self
                RecordingViewController.audioPlayer = try AVAudioPlayer(contentsOf: getDirectory().appendingPathComponent("\( recordingName!).m4a"))
                RecordingViewController.audioPlayer.delegate = self
                RecordingViewController.audioPlayer.play()
                playButton.setImage(UIImage(named: "stop"), for: UIControl.State.normal)
            }
            catch{
                print("there was error playing audio", error.localizedDescription)
            }
//            print("i have stopped it")
////            audioPlayerRef?.pause()
////            audioPlayerRef?.currentTime = 0
//            audioPlayerRef?.stop()
//            playButton.setImage(UIImage(named: "play"), for: UIControl.State.normal)
        }
        else{
//            audioPlayerRef?.pause()
//            audioPlayerRef?.currentTime = 0
//            if(RecordingViewController.playingCell != nil){
//                RecordingViewController.playingCell?.stopPlaying()
//                playButton.setImage(UIImage(named: "play"), for: UIControl.State.normal)
//            }
            if(RecordingViewController.playingCell != nil && RecordingViewController.playingCell == self){
                stopPlaying()
            }
            else if (RecordingViewController.playingCell != nil && RecordingViewController.playingCell != self){
                
                RecordingViewController.playingCell?.stopPlaying()
                print(RecordingViewController.playingCell?.recordingName!, "someone else playing and i need to stop")
                do{
                    print("about to play audio in other condition")
                    RecordingViewController.playingCell = self
                    RecordingViewController.audioPlayer = try AVAudioPlayer(contentsOf: getDirectory().appendingPathComponent("\( recordingName!).m4a"))
                    RecordingViewController.audioPlayer.delegate = self
                    RecordingViewController.audioPlayer.play()
                    playButton.setImage(UIImage(named: "stop"), for: UIControl.State.normal)
                }
                catch{
                    print("there was error playing audio", error.localizedDescription)
                }
            }
        }
    }
    
    func stopPlaying(){
        RecordingViewController.audioPlayer.stop()
        RecordingViewController.audioPlayer.delegate = nil
        playButton.setImage(UIImage(named: "play"), for: UIControl.State.normal)
    }
    
    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully: Bool){
        print("finished playing")
        playButton.setImage(UIImage(named: "play"), for: UIControl.State.normal)
        RecordingViewController.audioPlayer.delegate = nil
    }
}
