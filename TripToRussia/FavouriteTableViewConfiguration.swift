//
//  FavouriteTableViewConfiguration.swift
//  TripToRussia
//
//  Created by Рузаль Назмутдинов on 05.05.2023.
//

import Foundation
import Firebase
import FirebaseAuth

class FavouriteTableViewConfiguration: NSObject {
    private var places: [Place] = []
    func getFavourites(_ completion: @escaping () -> ()){
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore()
        let query = db.collection("FavoritePlaces").whereField("userID", isEqualTo: userID)
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    let data = document.data()
                    let places: [Place] = JsonServices.decode(jsonString: data["places"] as! String)
                    self.places = places
                    completion()
                }
            }
            
        }
    }
    func allFavClear(_ completion: @escaping () -> ()){
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore()
        let query = db.collection("FavoritePlaces").whereField("userID", isEqualTo: userID)
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    db.collection("FavoritePlaces").document(document.documentID).updateData(["places" : "[]"])
                }
                
                self.places = []
                completion()
            }
        }
    }
}
//MARK: - TableView extension
extension FavouriteTableViewConfiguration: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tempCount = places.count
        return tempCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellFav", for: indexPath)
        if indexPath.row < places.count {
            cell.textLabel?.text = places[indexPath.row].name
            } else {
                cell.textLabel?.text = "Default Text"
            }
            return cell
        }
   

}
extension FavouriteTableViewConfiguration: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let place = places[row]
                if let vc = tableView.parentViewController?.storyboard?
.instantiateViewController(withIdentifier: "DescriptionViewController") as? DescriptionViewController{
                    vc.tempDescription = place.description
                    vc.tempTitle = place.name
                    vc.tempRate = place.rate
                    vc.tempImage = place.photo
                    vc.tempLatPoint = place.latPoint
                    vc.tempLonPoint = place.lonPoint
                    vc.favtempXid = place.xid
                    vc.tempPlace = place
                    tableView.parentViewController?.navigationController?.pushViewController(vc, animated: true)
                }
            
    }
    
}
extension UIResponder {
    public var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
