//
//  ViewController.swift
//  MLkit
//
//  Created by Bhanu Pratap Singh Thapliyal on 10/11/18.
//  Copyright © 2018 Bhanu Pratap Singh Thapliyal. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var ImageDescription: UILabel!
    
    @IBOutlet weak var clickButton: UIButton!
    
    var ImagePicker : UIImagePickerController!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        ImagePicker = UIImagePickerController()
        ImagePicker.delegate = self
        ImagePicker.sourceType = .camera
        
    }


    @IBAction func ButtonClickedCapture(_ sender: Any) {
        
    present(ImagePicker, animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        ImageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        ImagePicker.dismiss(animated: true, completion: nil)
        imageIdentify(image: ImageView.image!)
    }
    
 
    func imageIdentify(image : UIImage){
        
        guard let IdentificationModel = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("Model Not Imported")
        }
        let request = VNCoreMLRequest(model: IdentificationModel){
            [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
            let firstResult = results.first
                else{
                    fatalError("NoResult obtained from VNCoreModelRequsest")
                    
            }
            
            
            DispatchQueue.main.async {
                self?.ImageDescription.text = "Confidence = \(Int(firstResult.confidence * 100))% \n IMage identified as : \(firstResult.identifier)"
                
            }
            
        }
        
       guard let CIImage = CIImage(image: image) else {  fatalError("Cannot convert into CIImage") }
        
        let imageHandler = VNImageRequestHandler(ciImage: CIImage)
        
        DispatchQueue.global(qos: .userInteractive).sync {
            do{
                try imageHandler.perform([request])
                
            }catch{
                    print(print("ERROR\(error)"))
                }
            
        }
    }
}

