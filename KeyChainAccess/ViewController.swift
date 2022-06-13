//
//  ViewController.swift
//  KeyChainAccess
//
//  Created by 伊藤明孝 on 2022/02/12.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    let id: String = "id"
    let key: String = "key"
    var password = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        switch load(id: self.id, key: self.key){
        case true:
            textField.text = password
            break
        case false:
            break
        }
    }
    
    
    @IBAction func addKeyChain(_ sender: Any) {
        save(id: self.id, key: self.key)
    }
    func save(id: String, key: String){
            let str: String = textField.text!
            let data = str.data(using: .utf8)

        
            let query: [String: Any] = [
                //一般的なパスワード
                kSecClass as String: kSecClassGenericPassword,
                //一位性を担保する
                kSecAttrService as String: key,
                //一位性を保持する
                kSecAttrAccount as String: id,
                //保存するデータ
                kSecValueData as String: data as Any
            ]
            
            //データの存在を確認する
            let status = SecItemCopyMatching(query as CFDictionary, nil)
            
            //データの有無によって挙動を変える。
            switch status {
                //何もない場合追加する
            case errSecItemNotFound:
                SecItemAdd(query as CFDictionary, nil)
                //存在する場合アプデをかける
            case errSecSuccess:
                SecItemUpdate(query as CFDictionary, [kSecValueData as String: textField.text] as CFDictionary)
            default:
                print("none")
            }
    }
    
    func load(id: String, key: String) -> Bool{
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: key,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        switch status {
        case errSecItemNotFound:
            return false
        case errSecSuccess:
            guard let item = item,
                  let value = item[kSecValueData as String] as? Data else {
                      print("no data")
                      return false
                  }
            password = String(data: value, encoding: .utf8)!
            return true
        default:
            print("no data conformed")
            return false
        }
    }


}

