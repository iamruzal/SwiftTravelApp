//
//  ViewController.swift
//  city
//
//  Created by Рузаль Назмутдинов on 04.10.2022.
//

import UIKit
import MessageUI
import Firebase
import FirebaseAuth

class ViewController: UIViewController, TableViewReloadable {
    
    @IBAction func allClear(_ sender: Any) {
        configuration.allFavClear {
            self.favTableView.reloadData()
        }
    }
    @IBOutlet weak var allClearButton: UIButton!
    @IBOutlet weak var favTableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var exitButton: UIButton!
    @IBAction func touchExitButton(_ sender: Any) {
      logout()
    
    }
    var aaa = AuthViewController()
    var sss = SearchBarAPI()
    var ggg = DescriptionViewController()
    let configuration = FavouriteTableViewConfiguration()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let favTableView = self.favTableView, favTableView.window != nil {
            
            favTableView.delegate = configuration
            favTableView.dataSource = configuration
            configuration.getFavourites {
                favTableView.reloadData()
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        sss.reloadableTableView = self
      
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        
        imageView?.layer.cornerRadius = (imageView?.frame.size.width ?? 0.0) / 2 
        imageView?.clipsToBounds = true
        exitButton?.clipsToBounds = true
        exitButton?.layer.cornerRadius = 17.0
        if #available(iOS 13.0, *) {
           let appearance = UINavigationBarAppearance()
           appearance.configureWithTransparentBackground()
           navigationController?.navigationBar.standardAppearance = appearance
           navigationController?.navigationBar.scrollEdgeAppearance = appearance
           navigationController?.navigationBar.compactAppearance = appearance
        } else {
           navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
           navigationController?.navigationBar.shadowImage = UIImage()
           navigationController?.navigationBar.isTranslucent = true
        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Выход", style: .plain, target: self, action: #selector(logout))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
   
    @IBAction func mainWindow(_ sender: Any) {
        performSegue(withIdentifier: "mainWindow", sender:nil)
    }
    func ReloadTableView(){
        self.tableView?.reloadData()
    }
    @objc func logout(){
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
          print(error)
        }
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController{
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
//MARK: - TableView extension
extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let tempCount = sss.namesout.count
        return tempCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            if indexPath.row < sss.namesout.count {
                cell.textLabel?.text = sss.namesout[indexPath.row]
            } else {
                cell.textLabel?.text = "Default Text"
            }
            return cell
        }
   

}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if row < sss.newidlist.count{
            sss.tempXid = sss.newidlist[row]
        }
        sss.getDescriptionInfo { [weak self] tempDescription, tempTitle, tempRate, tempImage, tempLonPoint, tempLatPoint, favtempXid, tempPlace  in
            DispatchQueue.main.async {
                if let vc = self?.storyboard?.instantiateViewController(withIdentifier: "DescriptionViewController") as? DescriptionViewController{
                    vc.tempDescription = tempDescription
                    vc.tempTitle = tempTitle
                    vc.tempRate = tempRate
                    vc.tempImage = tempImage
                    vc.tempLatPoint = tempLonPoint
                    vc.tempLonPoint = tempLatPoint
                    vc.favtempXid = favtempXid
                    vc.tempPlace = tempPlace
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                
            }
        }
    }
    
}
    //MARK: - SearchBar extension
    extension ViewController: UISearchBarDelegate{
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText == ""{
                return
            }
            sss.tempCity=searchText
            sss.getMethodAPI()
        }
    }
    
    
    

