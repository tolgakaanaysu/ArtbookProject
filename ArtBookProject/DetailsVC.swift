import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenPaintingID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenPainting != "" {
            saveButton.isHidden = true
//          CoreData
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.returnsObjectsAsFaults = false
            
            let idString = chosenPaintingID?.uuidString

            do{
                
                let results = try context?.fetch(fetchRequest)
               
                if results!.count > 0 {
                   
                    for results in results as! [NSManagedObject] {
                        if let name = results.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        
                        if let artist = results.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        
                        if let year = results.value(forKey: "years") as? Int16 {
                            yearText.text = String(year)
                        }
                        
                        if let imageData = results.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }
            catch{
                print("Error")
                
            }
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
        }
        else {
            saveButton.isEnabled = false
        }
        
//      Recognizer
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onClickedImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
    
   
    
    
    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
//      Attributes
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "years")
        }
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("Saved")
        } catch  {
            print("Error")
        }
        
//      app e 'newData' mesajı yolla
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
        
    }

//  boşluğa tıklandığında klavyeyi kapat
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func onClickedImage(){
        if chosenPainting == "" {

//          pickerController
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false
            present(picker, animated: true, completion: nil)
           
        }
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            imageView.image = info[.originalImage] as? UIImage
            saveButton.isEnabled = true
            self.dismiss(animated: true, completion: nil)
    }
}
