//
//  AuthViewController.swift
//  TripToRussia
//
//  Created by Рузаль Назмутдинов on 26.04.2023.
//

import UIKit
import Firebase
import FirebaseAuth

class AuthViewController: UIViewController {


    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var enterButton: UIButton!
   
   
    @IBAction func touchEnterButton(_ sender: Any) {
        do {
            self.loginUser(email: self.emailTextField.text, password: self.passwordTextField.text) { error in
                if let error = error {
                    let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Хорошо", style: .default, handler: nil)
                    alert.addAction(cancelAction)
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                } else {
                    
                    if let vc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController{
                        vc.navigationItem.hidesBackButton = true
                        self.navigationController?.setNavigationBarHidden(true, animated: false)
                        self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        }
    }
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var regButton: UIButton!
    
    @IBAction func touchRegButton(_ sender: Any) {
        registerUser(email: emailTextField.text, password: passwordTextField.text) { error in
            if let error = error {
                let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Хорошо", style: .default, handler: nil)
                alert.addAction(cancelAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
               

            } else {
                let alert = UIAlertController(title: "Успешно", message: "Вы успешно зарегистрировались", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Хорошо", style: .default, handler: nil)
                alert.addAction(okAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)

            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        regButton.clipsToBounds = true
        regButton.layer.cornerRadius = 17.0
        enterButton.clipsToBounds = true
        enterButton.layer.cornerRadius = 17.0
      
     
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesBackButton = true
        
    }
    
    func registerUser(email: String?, password: String?, completion: @escaping (Error?) -> Void) {
        guard let email = email, !email.isEmpty else {
            let alert = UIAlertController(title: "Ошибка", message: "Пожалуйста, введите почту", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Хорошо", style: .default, handler: nil)
            alert.addAction(cancelAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            completion(nil)
            return
        }
        guard let password = password, !password.isEmpty else {
            let alert = UIAlertController(title: "Ошибка", message: "Пожалуйста, введите пароль", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Хорошо", style: .default, handler: nil)
            alert.addAction(cancelAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            completion(nil)
            return
        }
        if password.count < 6 {
            let alert = UIAlertController(title: "Ошибка", message: "Длина пароля должна быть не меньше 6 символов", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Хорошо", style: .default, handler: nil)
            alert.addAction(cancelAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            completion(nil)
            return
        }
        if !isValidEmail(email: email) {
             let alert = UIAlertController(title: "Ошибка", message: "Пожалуйста, введите правильный email", preferredStyle: .alert)
             let cancelAction = UIAlertAction(title: "Хорошо", style: .default, handler: nil)
             alert.addAction(cancelAction)
             UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
             completion(nil)
             return
         }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError?, error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                let alert = UIAlertController(title: "Ошибка", message: "Пользователь с такой почтой уже зарегистрирован", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Хорошо", style: .default, handler: nil)
                alert.addAction(cancelAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                completion(nil)
                return
            }
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    func isValidEmail(email: String?) -> Bool {
        guard let email = email, !email.isEmpty else {
            return false
        }

        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)

        return emailPredicate.evaluate(with: email)
    }

    func loginUser(email: String?, password: String?, completion: @escaping (Error?) -> Void) {
        guard let email = email, !email.isEmpty else {
            let alert = UIAlertController(title: "Ошибка", message: "Пожалуйста, введите почту", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Хорошо", style: .default, handler: nil)
            alert.addAction(cancelAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            completion(nil)
            return
        }
        guard let password = password, !password.isEmpty else {
            let alert = UIAlertController(title: "Ошибка", message: "Пожалуйста, введите пароль", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Хорошо", style: .default, handler: nil)
            alert.addAction(cancelAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            completion(nil)
            return
        }
        if password.count < 6 {
             let alert = UIAlertController(title: "Ошибка", message: "Пароль должен быть не менее 6 символов", preferredStyle: .alert)
             let cancelAction = UIAlertAction(title: "Хорошо", style: .default, handler: nil)
             alert.addAction(cancelAction)
             UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
             completion(nil)
             return
         }
        if !isValidEmail(email: email) {
             let alert = UIAlertController(title: "Ошибка", message: "Пожалуйста, введите правильный email", preferredStyle: .alert)
             let cancelAction = UIAlertAction(title: "Хорошо", style: .default, handler: nil)
             alert.addAction(cancelAction)
             UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
             completion(nil)
             return
         }
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    if error._code == AuthErrorCode.wrongPassword.rawValue {
                        let alert = UIAlertController(title: "Ошибка", message: "Неверный пароль", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "Хорошо", style: .default, handler: nil)
                        alert.addAction(cancelAction)
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                        completion(nil)
                        return
                    } else if error._code == AuthErrorCode.userNotFound.rawValue {
                        let alert = UIAlertController(title: "Ошибка", message: "Пользователь не найден", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "Хорошо", style: .default, handler: nil)
                        alert.addAction(cancelAction)
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                        completion(nil)
                        return
                    }
                    completion(error)
                }
                else {
                    completion(nil)
                }
            }

    }

}
