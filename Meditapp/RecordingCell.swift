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
    
    var recordingName: String?
    
    func getDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDir = paths[0]
        return documentDir
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func playTap(_ sender: Any) {
        if (!RecordingViewController.audioPlayer.isPlaying){
            do{
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
        else{
            if(RecordingViewController.playingCell != nil && RecordingViewController.playingCell == self){
                stopPlaying()
            }
            else if (RecordingViewController.playingCell != nil && RecordingViewController.playingCell != self){
                
                RecordingViewController.playingCell?.stopPlaying()
                do{
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
        playButton.setImage(UIImage(named: "play"), for: UIControl.State.normal)
        RecordingViewController.audioPlayer.delegate = nil
    }
}
