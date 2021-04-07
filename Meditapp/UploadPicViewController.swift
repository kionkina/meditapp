//
//  UploadPicViewController.swift
//  Meditapp
//
//  Created by Gabriella Alexis on 3/30/21.
//
 
import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import Photos
import FirebaseUI

protocol UploadPicDelegate: class {
    func UploadedPic(
        forController controller: UploadPicViewController, forImagePath updatedPic: UIImage)
}

class UploadPicViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var Pfp: UIImageView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    var imagePickerController = UIImagePickerController()
    
    var curSelectedPhotoURL: URL?
    var selectedImage: UIImage?
    weak var delegate: UploadPicDelegate?

    
    var profilePicReference: StorageReference{
        return Storage.storage().reference().child("profilephotos")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController.delegate = self
        checkPermissions()

    }
    
    
    @IBAction func cancel(_ sender: Any) {
        
//        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    
    //update User object to have profile pic be this
    @IBAction func done(_ sender: Any) {
        let db = Firestore.firestore()
        
        
//        let imageID:String = User.current.uid
        let imageID:String = UUID().uuidString
        
        let oldProfilePicRef = profilePicReference.child(User.current.profilePic)
        
        
        let profilePicRef = profilePicReference
        let photoRef = profilePicRef.child(imageID)

        //upload image to bucket
        let uploadTask = photoRef.putFile(from: curSelectedPhotoURL!, metadata: nil) { (metadata, err) in
            if let err = err{
                print("error uploading pic: ", err.localizedDescription)
            }
            else{
                User.current.profilePic = imageID
                db.collection("users").document(User.current.uid).updateData(["profilePic" : imageID]) { err in
                    if let err  = err {
                        print("Error updating document: \(err.localizedDescription)")
                    }
                    else {
                        print("Document successfully updated")
                    }
                }
                print(User.current.profilePic, "after upload")
                
                self.delegate?.UploadedPic(forController: self, forImagePath: self.selectedImage!)
                print("successfully uploaded image")
                
                oldProfilePicRef.delete { error in
                    if let error = error {
                        print("error: ", error.localizedDescription)
                    } else {
                        print("Successfully deleted")
                    }
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    func checkPermissions() {
       if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
                                PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                                    ()
                                })
                            }

                            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
                            } else {
                                PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
                            }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus){
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized{
            print("WE CAN ACCESS PHOTOS NOW")
        } else {
            print("PHOTO ACCESS DENIED")
        }
    }
    
    @IBAction func uploadPfp(_ sender: Any) {
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    //see what img user chose and upload it to firebase
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        Pfp.image = info[.originalImage] as? UIImage
        selectedImage = info[.originalImage] as? UIImage
        
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL{
            curSelectedPhotoURL = url
        }
        
        doneButton.isEnabled = true
        
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
