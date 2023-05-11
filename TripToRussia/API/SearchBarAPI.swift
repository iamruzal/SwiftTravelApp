//
//  SearchBarAPI.swift
//  TripToRussia
//
//  Created by Рузаль Назмутдинов on 25.03.2023.
//

import Foundation
import UIKit
import MessageUI


class SearchBarAPI {
    weak var reloadableTableView: TableViewReloadable?
    var ddd = DescriptionViewController()
    var namesout = names
    var tempCity: String = ""
    var tempLon: Double = 0
    var tempLat: Double = 0
    var tempLonPoint: Double = 0
    var tempLatPoint: Double = 0
    var tempXid: String = ""
    var favtempXid: String = ""
    var tempDescription: String?
    var tempTitle: String?
    var tempRate: String?
    var tempImage: String?
    var tempPlace: Place = Place(xid: "", name: "", description: "", photo: "", rate: "", lonPoint: 1, latPoint: 1)
    var newlist: [String] = []
    var newidlist: [String] = []
    
    var urlStringGeoname: String{
        "https://api.opentripmap.com/0.1/ru/places/geoname?name="+tempCity+"&apikey=5ae2e3f221c38a28845f05b680c80bafa358f21356635b16e9ffa7ec"
    }
    var urlStringGeoList: String {
        "https://api.opentripmap.com/0.1/ru/places/radius?radius=10000&lon="+String(tempLon)+"&lat="+String(tempLat)+"&apikey=5ae2e3f221c38a28845f05b680c80bafa358f21356635b16e9ffa7ec"
    }
    var urlStringDescritption: String {
        "https://api.opentripmap.com/0.1/ru/places/xid/"+tempXid+"?apikey=5ae2e3f221c38a28845f05b680c80bafa358f21356635b16e9ffa7ec"
    }
    
    //MARK: - Get city API request
    func getMethodAPI(){
        let encodedString = urlStringGeoname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string: encodedString!){
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request){ data, response, error in
                guard let data else {return}
                if let tempname = try? JSONDecoder().decode(Geoname.self, from: data) {
                    self.tempLon = tempname.lon
                    self.tempLat = tempname.lat
                    self.getRightList()
                }
                else {
                    print("FAIL")
                }
            }
            task.resume()
        }
    }
    
    // MARK: - List of sights API request
    func getRightList(){ // Получение имени достопримечательности
        newlist = []
        newidlist=[]
        let newencodedString = urlStringGeoList.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = URL(string: newencodedString!){
            let request = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: request){ data, response, error in
                guard let data else {return}
                if let templist = try? JSONDecoder().decode(FeatureCollection.self, from: data) {
                    for name in templist.features {
                        if(name.properties.name == "" || name.properties.xid == ""){
                            continue
                        }
                        self.newlist.append(name.properties.name)
                        self.newidlist.append(name.properties.xid)
                    }
                    self.namesout=self.newlist
                    DispatchQueue.main.async {
                        self.reloadableTableView?.ReloadTableView()
                    }
                                 }
            }
            task.resume()
        }
    }

    //MARK: - Description of sight API request
    func getDescriptionInfo (completion: @escaping (String?, String?, String?, String?, Double, Double, String, Place) -> Void) {
            let encodedString = urlStringDescritption.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            if let url = URL(string: encodedString!){
                let request = URLRequest(url: url)
                let task = URLSession.shared.dataTask(with: request){ data, response, error in
                    guard let data else {return}
                    if let tempdescription = try? JSONDecoder().decode(Descritpion.self, from: data) {
                        if let descr = tempdescription.wikipedia_extracts?.text ?? tempdescription.info?.descr {
                            self.tempDescription = descr
                        } else {
                            self.tempDescription = "Администрация области данного объекта не внесла информацию или ограничила доступ к получению полного описания данной достопримечательности"
                        }
                        if let image = tempdescription.preview?.source{
                            
                            self.tempImage = image.replacingOccurrences(of: "all.", with: "pro.")
                        }
                        else{
                            self.tempImage = "https://thomifelgen.ru/upload/iblock/053/no_photo.jpg"
                        }
                        self.tempPlace = Place(xid: tempdescription.xid, name: tempdescription.name, description: self.tempDescription ?? "Администрация области данного объекта не внесла информацию или ограничила доступ к получению полного описания данной достопримечательности", photo: self.tempImage ?? "https://thomifelgen.ru/upload/iblock/053/no_photo.jpg", rate: tempdescription.rate, lonPoint: tempdescription.point.lon, latPoint: tempdescription.point.lat)
                        self.favtempXid = tempdescription.xid
                        self.tempLatPoint = tempdescription.point.lat
                        self.tempLonPoint = tempdescription.point.lon
                        self.tempRate = tempdescription.rate
                        self.tempTitle = tempdescription.name
                        completion(self.tempDescription, self.tempTitle, self.tempRate, self.tempImage, self.tempLatPoint, self.tempLonPoint, self.favtempXid, self.tempPlace)
                    }
                    
                }
                task.resume()
            }
        }
}

// MARK: - Protocol
protocol TableViewReloadable: AnyObject{
    func ReloadTableView()
}



