//
//  ViewController.swift
//  KeyChainAccess
//
//  Created by 伊藤明孝 on 2022/02/12.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    func save<T: Codable>(id: String, key: String, data: T){
        let encoder = JSONEncoder()
        do{
            let encoded = try encoder.encode(data)
            
            let query: [String: Any] = [
                //一般的なパスワード
                kSecClass as String: kSecClassGenericPassword,
                //一位性を担保する
                kSecAttrService as String: key,
                kSecAttrAccount as String: id,
                kSecValueData as String: encoded
            ]
            
            //データの存在を確認する
            let status = SecItemCopyMatching(query as CFDictionary, nil)
            
            //データの有無によって挙動を変える。
            switch status {
            case errSecItemNotFound:
                SecItemAdd(query as CFDictionary, nil)
                
            case errSecSuccess:
                SecItemUpdate(query as CFDictionary, [kSecValueData as String: encoded] as CFDictionary)
                
            default:
                print("none")
            }
            
        }catch{
            print("error")
        }
    }
    
    func load<T: Codable>(id: String, key: String, type: T.Type) -> T?{
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
            return nil
        case errSecSuccess:
            guard let item = item,
                  let value = item[kSecValueData as String] as? Data else {
                      print("no data")
                      return nil
                  }
            do {
                return try JSONDecoder().decode(type, from: value)
            }catch{
                print("error")
            }
        default:
            print("no data conformed")
        }
        
        return nil
    }


}

