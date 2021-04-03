//
//  RecordingViewController.swift
//  Meditapp
//
//  Created by Jackson Lu on 2/28/21.
//

import UIKit
import AVFoundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import Photos
import FirebaseUI



class RecordingViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, UITableViewDataSource, TagsViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //MARK: - Outlets
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var nameofRecording: UITextField!
    @IBOutlet weak var postDesc: UITextView!
    @IBOutlet weak var charLimit: UILabel!
    @IBOutlet weak var postButton: UIBarButtonItem!
    @IBOutlet weak var postImage: UIImageView!
    
    
    
    //MARK: - Variables
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer = AVAudioPlayer()
    var recordings = [Recording]()
    var postTags = [String]()
    var imagePickerController = UIImagePickerController()
    
    var checkedIndex: IndexPath!
    
    var recordingReference: StorageReference{
        return Storage.storage().reference().child("recordings")
    }
    
    var postPhotoReference: StorageReference{
        return Storage.storage().reference().child("postphotos")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadRecordings()
        navigationItem.largeTitleDisplayMode = .never
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        tapGesture.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(tapGesture)
        nameofRecording.delegate = self
        postDesc.delegate = self
        
        //Setting up session
        recordingSession = AVAudioSession.sharedInstance()
        
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission{
                print("Accepted")
                do{
                    try self.recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
                    try self.recordingSession.setActive(true)
                } catch{
                    print("Couldn't set Audio session category")
                }
            }
            else{
                print("not granted")
            }
        }
        
        imagePickerController.delegate = self
        checkPermissions()
    }
    
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: - Helper functions
    func getDirectory() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDir = paths[0]
        return documentDir
    }
    
    func deleteFile(_ myURL: URL){
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: myURL)
        } catch {
            print(error)
        }
    }
    func deleteAllFiles(){
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if fileURL.pathExtension == "m4a" {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch  { print(error) }
    }
    
    func configureCheckmark(for cell: UITableViewCell,with item: Recording) {
        if item.checked {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        saveRecordings()
    }
    
    func saveRecordings() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(recordings)
            try data.write(to: getDirectory().appendingPathComponent("Recordings.plist"), options: Data.WritingOptions.atomic)
        }
        catch {
            print("Error encoding item array: \(error.localizedDescription)")
        }
    }

    func loadRecordings() {
        let path = getDirectory().appendingPathComponent("Recordings.plist")
        if let data = try? Data(contentsOf: path) {
            let decoder = PropertyListDecoder()
            do {
                recordings = try decoder.decode([Recording].self, from: data)
            }
            catch {
                print("Error decoding item array: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func uploadImg(_ sender: Any) {
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
        
    }
    
    func checkPermissions() {
       if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
      
        PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in ()})}
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
        }
        else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    //photo auth function
    func requestAuthorizationHandler(status: PHAuthorizationStatus){
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized{
            print("WE CAN ACCESS PHOTOS NOW")
        } else {
            print("PHOTO ACCESS DENIED")
        }
    }
    
    //see what img user chose and upload it to firebase
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL{
            print("Image selected: \(url)")
            let postPhotoRef = postPhotoReference
            let localFile = url
            let photoRef = postPhotoRef.child(url.lastPathComponent)
            
            let uploadTask = photoRef.putFile(from: localFile, metadata: nil) { (metadata, err) in
                guard let metadata = metadata
                else {
                    print(err?.localizedDescription)
                    return
                }
                print("Photo uploaded")
                self.postImage.sd_setImage(with: photoRef)
                print("img URL: \(String(describing: self.postImage.sd_imageURL?.lastPathComponent))")
//                print("this is the post image")
            }
            
        }
        
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Actions
    @IBAction func record(_ sender: Any) {
        //Check if active recorder
        if audioRecorder == nil{
            //name of the audiofile
            let audioFileName = getDirectory().appendingPathComponent("\(nameofRecording.text!).m4a")
            //disable typing once person clicks play
            nameofRecording.isUserInteractionEnabled = false
            //create a new recording
            var newRecording = Recording(audioFileName, nameofRecording.text!)
            //append to array
            recordings.append(newRecording)
            
            //set settings
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            do {
                    audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
                    audioRecorder.delegate = self
                    audioRecorder.record()

                    recordButton.setTitle("Stop Recording", for: .normal)
            }
            catch {
                print("Error failed")
                //remove the new recording we expected to have
                recordings.remove(at: recordings.count)
            }
        }
        else{
            //Its already recording, stop it
            audioRecorder.stop()
            audioRecorder = nil
            
            //Reload the tableview
            myTableView.reloadData()
            
            nameofRecording.isUserInteractionEnabled = true
            nameofRecording.text! = ""
            textFieldShouldClear(nameofRecording)
            //Make button back to record
            recordButton.setTitle("Start Recording", for: .normal)
            
            saveRecordings()
        }
    }
    
    
    
    
    //MARK: -Tableview Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Recordings", for: indexPath) as! RecordingCell
        
        let item = recordings[indexPath.row]
        
        cell.nameLabel.text = item.recordingName
        //  item.checked = false
        configureCheckmark(for: cell, with: item)
        
        cell.playAudio = { (cell) in
            do {
                if !self.audioPlayer.isPlaying{
                    self.audioPlayer = try AVAudioPlayer(contentsOf: self.getDirectory().appendingPathComponent("\( self.recordings[indexPath.row].recordingName).m4a"))
                    self.audioPlayer.play()
                    return false
                }
                else{
                    self.audioPlayer.stop()
                    return true
                }
            }
            catch {
                print(error)
            }
            return nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if checkedIndex != nil {
            tableView.cellForRow(at: checkedIndex)?.accessoryType = .none
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        checkedIndex = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
        if checkedIndex != nil && postTags.count > 0{
            postButton.isEnabled = true
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            
            let URLPath = getDirectory().appendingPathComponent("\( recordings[indexPath.row].recordingName).m4a")
            if FileManager.default.fileExists(atPath: URLPath.path){
                
                print("FILE AVAILABLE")
                deleteFile(URLPath)
                recordings.remove(at: indexPath.row)
                let indexPaths = [indexPath]
                tableView.deleteRows(at: indexPaths, with: .automatic)
                
                saveRecordings()
            }
            else {
                print("FILE NOT AVAILABLE at \(recordings[indexPath.row].audioURL.path)")
            }
        }
    
    // MARK: -Textfield Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
    
        let stringRange = Range(range, in: oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
      
        if newText.isEmpty{
        recordButton.isEnabled = false
        }
        else {
            recordButton.isEnabled = true
        }
            return true
        }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        recordButton.isEnabled = false
        return true
    }




    // MARK: -Textview Delegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let charlimit:Int = 200
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        charLimit.text! = "\(updatedText.count)/200"
        return updatedText.count <= charlimit
    }
    
    func converTimetoToInt(date: Date) -> Int {
        // using current date and time as an example

        // convert Date to TimeInterval (typealias for Double)
        let timeInterval = date.timeIntervalSince1970

        // convert to Integer
        let myInt = Int(timeInterval)
        
        return myInt
    }
    
    // MARK: -Actions
    @IBAction func postRec(_ sender: Any) {
        //connect to firestore
        let db = Firestore.firestore()
        //get reference to recordings bucket
        let recordingRef = recordingReference
        
        let recID = UUID().uuidString
        
        let filename = recordings[checkedIndex.row].recordingName
        //append to bucket route
        let audioRef = recordingRef.child(filename)
        
        let localFile = getDirectory().appendingPathComponent("\(recID).m4a")
        
        //specify task. on success, we get info that we can reference to in our documents
        let uploadTask = audioRef.putFile(from: localFile, metadata: nil){ (metadata, err) in
            
            guard let metadata = metadata
            
            else {
                print(err?.localizedDescription)
                return
            }
            print("Audio Uploaded")
        }
        
        uploadTask.resume()
        
//        guard let user = Auth.auth().currentUser else{return}
        
        let stamp = Timestamp(date: Date())
        let currTime = converTimetoToInt(date: Date())
        
        let docData: [String: Any] = [
            "Name" : filename,
            "Timestamp" : stamp,
            "RecID" : recID,
//            "OwnerRef" : db.collection("users").document(User.current.uid),
            "OwnerID" : User.current.uid,
            "Tags" : postTags,
            "Description" : postDesc.text!,
            "numLikes" : 0,
            "numComments": 0,
            "Image" : postImage.sd_imageURL?.lastPathComponent as Any,
            //combine query for filtering and sorting
            "IdTime" : String(currTime) + recID
//            "StorageRef" : audioRef
        ]
        
        db.collection("Recordings").document(recID).setData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
       
        let dbref: DocumentReference = db.collection("Recordings").document(recID)
        db.collection("users").document(User.current.uid).updateData([
            "content" : FieldValue.arrayUnion([dbref])
        ])
        User.current.recordings.append(dbref)
        print(User.current.recordings, "after appending")
//        do{
//            let data = try NSKeyedArchiver.archivedData(withRootObject: User.current)
//            try UserDefaults.standard.set(data, forKey: "currentUser")
//        } catch{
//            print("Error")
//        }
          
        
//        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
        //deleteAllFiles(false)
    }
    
    @IBAction func cancel(_ sender: Any) {
//        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
        //deleteAllFiles(true)
    }
    
    //MARK: - Tags delegate protocols
//    func TagsViewControllerDidCancel(_ controller: TagsViewController) {
//        navigationController?.popViewController(animated: true)
//    }
    
    func TagsViewController(_ controller: TagsViewController, didAddTags tags: [String]) {
        postTags = tags
        print(postTags)
        
        if checkedIndex != nil && postTags.count > 0{
            postButton.isEnabled = true
        }
        else{
            postButton.isEnabled = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! TagsViewController
        controller.delegate = self
        controller.productTagsCollection.tags = postTags
    }
}


    
