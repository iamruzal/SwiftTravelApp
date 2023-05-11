//
//  DescriptionViewController.swift
//  TripToRussia
//
//  Created by Рузаль Назмутдинов on 14.04.2023.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore



struct Place: Codable {
    var xid: String
    var name: String
    var description: String
    var photo: String
    var rate: String
    var lonPoint: Double
    var latPoint: Double
}

class JsonServices {
    static func encode<T: Encodable>(object: T) -> String{
        let encoder = JSONEncoder()
        let data = try! encoder.encode(object)
        return String(data: data, encoding: String.Encoding.utf8) ?? ""
    }
    static func decode<T: Decodable>(jsonString:String) -> T{
        let decoder = JSONDecoder()
        let data = jsonString.data(using: .utf8) ?? Data()
        return try! decoder.decode(T.self, from: data)
    }
}
class DescriptionViewController: UIViewController {
    var arr: [String] = []
    var tempPlace: Place = Place(xid: "", name: "", description: "", photo: "", rate: "", lonPoint: 1, latPoint: 1)
    
    @IBAction func favButton(_ sender: Any) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        addNewIdsToUser(userid: userID, newIds: tempPlace)

    }
  
    func addNewIdsToUser(userid: String, newIds: Place) {
        let db = Firestore.firestore()
        let query = db.collection("FavoritePlaces").whereField("userID", isEqualTo: userid)
        query.getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    guard let snapshot = snapshot else { return }
                    if snapshot.documents.isEmpty {
                        let places = [self.tempPlace]
                        db.collection("FavoritePlaces").document().setData(["userID": userid, "places": JsonServices.encode(object: places)]) { error in
                            if let error = error {
                                print("Error creating document: \(error)")
                            } else {
                                print("Document created successfully")
                            }
                        }
                    } else {
                        for document in snapshot.documents {
                        
                            let data = document.data()
                            var places: [Place] = JsonServices.decode(jsonString: data["places"] as! String)
                            if let indexPlaces = places.firstIndex(where: {$0.xid == newIds.xid}){
                                places.remove(at: indexPlaces)
                                self.favButton.setTitle("Добавить в избранное", for: .normal)
                                self.favButton.layer.backgroundColor = UIColor.blue.cgColor

                            }
                            else {
                                self.favButton.setTitle("Удалить из избранных", for: .normal)
                                self.favButton.backgroundColor = UIColor.red
                                places.append(self.tempPlace)
                                
                            }
                            db.collection("FavoritePlaces").document(document.documentID).updateData(["places": JsonServices.encode(object: places)]) { error in
                                if let error = error {
                                    print("Error updating document: \(error)")
                                } else {
                                    print("Document updated successfully")
                                }
                            }
                        }
                    }
                }
            }
    }

    @IBAction func mapsButton(_ sender: Any) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "YandexNavController") as? YandexNavController{
            vc.tempLatPoint = tempLatPoint
            vc.tempLonPoint = tempLonPoint
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var mapsButton: UIButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var sightImageView: UIImageView!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    var tempDescription: String?
    var tempTitle: String?
    var tempRate: String?
    var tempImage: String?
    var tempLonPoint: Double = 0
    var tempLatPoint: Double = 0
    var favtempXid: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Информация", style: .plain, target: nil, action: nil)
        self.favButton.layer.cornerRadius = 15
        self.favButton.layer.backgroundColor = UIColor.blue.cgColor
        self.mapsButton.layer.cornerRadius = 15
        self.mapsButton.layer.backgroundColor = UIColor.orange.cgColor
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let query = db.collection("FavoritePlaces").whereField("userID", isEqualTo: userID)
        query.getDocuments { [self] (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                guard let snapshot = snapshot else { return }
                if !snapshot.documents.isEmpty {
                    for document in snapshot.documents {
                        let data = document.data()
                        let places: [Place] = JsonServices.decode(jsonString: data["places"] as! String)
                        if (places.firstIndex(where: {$0.xid == self.favtempXid}) == nil){
                            self.favButton.setTitle("Добавить в избранное", for: .normal)
                            self.favButton.layer.backgroundColor = UIColor.blue.cgColor

                        }
                        else {
                            self.favButton.setTitle("Удалить из избранных", for: .normal)
                            self.favButton.backgroundColor = UIColor.red
                        }
                        UIView.animate(withDuration: 0.5) {
                            self.favButton.alpha = 1
                        }
                    }
                }
            }
        }
        descriptionTextView.clipsToBounds = true
        sightImageView.clipsToBounds = true
        sightImageView.layer.cornerRadius = 17.0
        sightImageView.layer.borderWidth = 0.5
        sightImageView.layer.borderColor = UIColor(red: 26/255, green: 35/255, blue: 126/255, alpha: 1).cgColor
        descriptionTextView.layer.cornerRadius = 17.0
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        if var tempDescription = tempDescription {
            tempDescription = tempDescription.replacingOccurrences(of: "<p>", with: "").replacingOccurrences(of: "</p>", with: "").replacingOccurrences(of: "&nbsp;", with: "").replacingOccurrences(of: "<span>", with: "").replacingOccurrences(of: "</span>", with: "").replacingOccurrences(of: "<br />", with: "").replacingOccurrences(of: "<a>", with: "").replacingOccurrences(of: "</a>", with: "").replacingOccurrences(of: "</br>", with: "").replacingOccurrences(of: "<em>", with: "").replacingOccurrences(of: "</em>", with: "").replacingOccurrences(of: "<strong>", with: "").replacingOccurrences(of: "</strong>", with: "").replacingOccurrences(of: "<span style='vertical-align:baseline'>", with: "").replacingOccurrences(of: "<span style='font-style:inherit;vertical-align:baseline;font-weight:bold'>ОГАУК «УльяновскКинофонд»<span style='font-style:inherit;font-weight:inherit;vertical-align:baseline'>", with: "").replacingOccurrences(of: "<span style='font-style:inherit;vertical-align:baseline;font-weight:bold'>ОГАУК «УльяновскКинофонд»<span style='font-style:inherit;font-weight:inherit;vertical-align:baseline'>", with: "").replacingOccurrences(of: "<span style=\"font-style:inherit;vertical-align:baseline;font-weight:bold\">", with: "").replacingOccurrences(of: "<span style=\"font-style:inherit;font-weight:inherit;vertical-align:baseline\">", with: "")
            descriptionTextView.text = tempDescription
            
        } else {
            descriptionTextView.text = "Администрация области данного объекта не внесла информацию или ограничила доступ к получению полного описания данной достопримечательности"
        }
        if let tempTitle = tempTitle {
            titleTextView.text = tempTitle
        } else {
            titleTextView.text = "Название отсутствует"
        }
        if let tempRate = tempRate {
            rateLabel.text = tempRate
        } else {
            tempRate = "0"
        }
        if let imageUrlString = tempImage, let tempImage = URL(string: imageUrlString) {
                URLSession.shared.dataTask(with: tempImage) { (data, response, error) in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.sightImageView.image = UIImage(data: data)
                        }
                    }
                }.resume()
            }

    }
 
}


