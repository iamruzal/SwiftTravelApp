//
//  MainAPI.swift
//  TripToRussia
//
//  Created by Рузаль Назмутдинов on 26.01.2023.
//
import Foundation
import UIKit
import MessageUI

// MARK: - Descritpion
struct Descritpion: Codable {
    let xid, name: String
    let address: Address?
    let osm: String?
    let rate: String
    let bbox: Bbox?
    let wikidata: String?
    let kinds: String?
    let sources: Sources
    let info: Info?
    let wikipedia: String?
    let otm: String
    let image: String?
    let preview: Preview?
    let wikipedia_extracts: WikipediaExtracts?
    let voyage: String?
    let url: String?
    let point: Point
    
  
}

struct Info: Codable{
    let src: String?
    let src_id: Int?
    let descr: String?
}

// MARK: - Address
struct Address: Codable {
    let city, state, county, suburb: String?
    let country, postcode, address29, pedestrian: String?
    let countryCode, cityDistrict: String?
}

// MARK: - Bbox
struct Bbox: Codable {
    let lonMin, lonMax, latMin, latMax: Double?
}

// MARK: - Point
struct Point: Codable {
    let lon, lat: Double
}

// MARK: - Preview
struct Preview: Codable {
    let source: String?
    let height, width: Int?
}

// MARK: - Sources
struct Sources: Codable {
    let geometry: String?
    let attributes: [String]?
}

// MARK: - WikipediaExtracts
struct WikipediaExtracts: Codable {
    let title, text, html: String?
}

struct Geoname: Codable {
    let name, country: String
    let lat, lon: Double
    let population: Int
    let timezone, status: String
}

struct FeatureCollection: Codable {
    let type: String
    let features: [Feature]
}

struct Feature: Codable {
    let type: String
    let id: String
    let geometry: Geometry
    let properties: Properties
}

struct Geometry: Codable {
    let type: String
    let coordinates: [Double]
}

struct Properties: Codable {
    let xid: String
    let name: String
    let dist: Double?
    let rate: Int
    let osm: String?
    let wikidata: String?
    let kinds: String?
}
let urlString = "https://api.opentripmap.com/0.1/ru/places/bbox?lon_min=50&lat_min=41&lon_max=160&lat_max=77&limit=500&apikey=5ae2e3f221c38a28845f05b680c80bafa358f21356635b16e9ffa7ec"
var names: [String] = []

func decodeAPI(completion: @escaping([String]) -> Void){
        let url = URL(string: urlString)!
    let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let data else {return}
            if let properties = try? JSONDecoder().decode(FeatureCollection.self, from: data) {
                for name in properties.features {
                    names.append(name.properties.name)
                }
             
                completion(names)
               
            }
            else {
                print("FAIL")
            }
        }
        task.resume()
    }

