//
//  ViewController.swift
//  meno_mise
//
//  Created by 竹野祐輔 on 2018/04/14.
//  Copyright © 2018年 竹野祐輔. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class ViewController: UIViewController, UITableViewDataSource{
    
    
    
    
    @IBOutlet weak var postVacantReqestBtn: UIButton!
    @IBOutlet weak var vacantResultTableView: UITableView!
    
    
    var vacantResultData: [String] = []
    var numOfData: Int = 0
    
    var locationManager: CLLocationManager!
    var mLastAction: LastAction = .Launched
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager() // インスタンスの生成
        locationManager.delegate = self // CLLocationManagerDelegateプロトコルを実装するクラスを指定する
        
        //Temp json
        let jsonString: String = "[{\"id\":\"1\", \"content\": {\"name\":\"Mise_1\",\"vacant\":3}},{\"id\":\"2\", \"content\": {\"name\":\"Mise_2\",\"vacant\":8}}, {\"id\":\"3\", \"content\": {\"name\":\"Mise_3\",\"vacant\":4}},{\"id\":\"4\", \"content\": {\"name\":\"Mise_4\",\"vacant\":0}}, {\"id\":\"5\", \"content\": {\"name\":\"Mise_5\",\"vacant\":12}},{\"id\":\"6\", \"content\": {\"name\":\"Mise_6\",\"vacant\":0}}, {\"id\":\"7\", \"content\": {\"name\":\"Mise_7\",\"vacant\":10}},{\"id\":\"8\", \"content\": {\"name\":\"Mise_8\",\"vacant\":1}}]"
        
        let personalData: Data =  jsonString.data(using: String.Encoding.utf8)!
        
        // ここから本題
        do {
            let json = try JSONSerialization.jsonObject(with: personalData, options: JSONSerialization.ReadingOptions.allowFragments) // JSONパース。optionsは型推論可(".allowFragmets"等)
            let top = json as! NSArray // トップレベルが配列
            for roop in top {
                vacantResultData.append("")
                
                let next = roop as! NSDictionary
                let content = next["content"] as! NSDictionary
                vacantResultData[numOfData] += content["name"] as! String + " : "
                switch content["vacant"] as! Int{
                case 0:
                    vacantResultData[numOfData] += "席は空いていません"
                default:
                    vacantResultData[numOfData] += String(content["vacant"] as! Int)
                    break
                }
                
                numOfData += 1
            }
        } catch {
            print(error) // パースに失敗したときにエラーを表示
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func postVacantRequestBtnAction(_ sender: Any) {
            if #available(iOS 9.0, *) {
                mLastAction = .PostVacantRequest
                locationManager.requestLocation() // 一度きりの取得
                
        }
    }
    
}

//MARK : TableViewController
extension ViewController{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numOfData
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "vacantResulTableViewCell", for: indexPath)
        
        // セルに表示する値を設定する
        cell.textLabel!.text = vacantResultData[indexPath.row]
        return cell
    }
    
}

//MARK : Location
extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("ユーザーはこのアプリケーションに関してまだ選択を行っていません")
            locationManager.requestWhenInUseAuthorization()
            break
        case .denied:
            print("ローケーションサービスの設定が「無効」になっています (ユーザーによって、明示的に拒否されています）")
            // 「設定 > プライバシー > 位置情報サービス で、位置情報サービスの利用を許可して下さい」を表示する
            break
        case .restricted:
            print("このアプリケーションは位置情報サービスを使用できません(ユーザによって拒否されたわけではありません)")
            // 「このアプリは、位置情報を取得できないために、正常に動作できません」を表示する
            break
        case .authorizedAlways:
            print("常時、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            break
        case .authorizedWhenInUse:
            print("起動時のみ、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            break
        }
    }
    
    //For error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗しました")
    }
    
    //didUpdateLocations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            print("緯度:\(location.coordinate.latitude) 経度:\(location.coordinate.longitude) 取得時刻:\(location.timestamp.description)")
            switch mLastAction{
            case .PostVacantRequest:
                createJasonForRequest(latituide: location.coordinate.latitude, longitude: location.coordinate.longitude)
            default:
                break
            }
        }
        
        
    }
    
}

// MARK : CreateJson
extension ViewController{
    
    //create json with location data to get neighbor restaurant
    func createJasonForRequest(latituide: Double, longitude: Double){
        //Create json data for location
        var center = Dictionary<String,Double>()
        center["latitude"] = latituide
        center["longitude"] = longitude
        
        //Create json data for radius
        var jsonObj = Dictionary<String,Any>()
        jsonObj["center"] = center
        jsonObj["radius"] = 100
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObj, options: [])
            let jsonStr = String(bytes: jsonData, encoding: .utf8)!
            print(jsonStr)
            
            //TODO : Post jason to server
            
        } catch let error {
            print(error)
        }
    }
}

//Because didUpdateLocation is called anytime when location is updated, state information is needed to control procedure as each action.
extension ViewController{
    enum LastAction {
        case Launched, PostVacantRequest
    }
}

