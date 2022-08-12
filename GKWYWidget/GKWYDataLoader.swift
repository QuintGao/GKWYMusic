//
//  GKWYDataLoader.swift
//  GKWYWidgetExtension
//
//  Created by gaokun on 2020/11/11.
//  Copyright © 2020 gaokun. All rights reserved.
//

import Foundation
import UIKit

let typePrefix = "GKWYWidget://"
// 创建默认数据
let defaultData = GKWYData.getList().first!

struct GKWYData {
    let id: String      // 唯一标识
    var title: String   // 标题
    var desc: String    // 描述
    let icon: String    // 图标名称
    var type: String
    var bgImage: UIImage? = UIImage(named: "recommend_bg") // 背景图片对象
    
    static func getList() -> [GKWYData] {
        var list = [GKWYData]()
        list.append(.init(id: "1", title: "每日音乐推荐", desc: "为你带来每日惊喜", icon: "cm4_disc_type_list", type: "music", bgImage: UIImage(named: "recommend_bg")))
        list.append(.init(id: "2", title: "私人雷达", desc: "探索另类音乐宝藏", icon: "cm4_disc_type_radio", type: "radar", bgImage: UIImage(named: "leida_bg")))
        list.append(.init(id: "3", title: "私人FM", desc: "最懂你的音乐电台", icon: "cm4_disc_type_alb", type: "fm", bgImage: UIImage(named: "fm_bg")))
        list.append(.init(id: "4", title: "我喜欢的音乐", desc: "最懂你的音乐电台", icon: "cm4_disc_type_product", type: "liked", bgImage: UIImage(named: "love_bg")))
        list.append(.init(id: "5", title: "歌单推荐", desc: "精选人气歌单", icon: "cm4_disc_type_act", type: "playlist", bgImage: UIImage(named: "list_bg")))
        return list
    }
    
    static func getModeList() -> [GKWYWidgetMode] {
        return getList().map { (data) -> GKWYWidgetMode in
            .init(identifier: data.id, display: data.title, subtitle: data.desc, image: nil)
        }
    }
    
    static func dataWith(mode: GKWYWidgetMode) -> GKWYData {
        var data: GKWYData? = nil
        for m in getList() {
            if m.id == mode.identifier {
                data = m
            }
        }
        return data!
    }
}

struct GKWYDataLoader {
    static func request(modeArr: [GKWYWidgetMode], completion: @escaping ([GKWYData]) -> Void) {
        var list = [GKWYData]()
        
        let mode = modeArr.first
        
        // 如果第一个是推荐内容，则请求接口
        if mode?.identifier == "1" {
            // 获取数据成功后再回调
            requestRecomment(data: GKWYData.getList().first!) { (data) in
                list.append(data)
                
                for (index, value) in modeArr.enumerated() {
                    // 前面已经处理过第一个数据，这里不用再添加
                    if index != 0 {
                        list.append(GKWYData.dataWith(mode: value))
                    }
                }
                completion(list)
            }
        }else {
            for menu in modeArr {
                list.append(GKWYData.dataWith(mode: menu))
            }
            completion(list)
        }
    }
    
    /// 请求推荐内容
    /// - Parameter completion: 请求完成回调
    static func requestRecomment(data: GKWYData, completion: @escaping (GKWYData) -> Void) {
        var wyData = data
        let url = URL(string: "http://192.168.31.142:3000/recommend/songs")!
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if data != nil && error == nil {
                let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                let code = json["code"] as! Int
                if code == 200 {
                    guard let data = json["data"] as? [String: Any] else { completion(defaultData)
                        return
                    }
                    
                    guard let songs = data["dailySongs"] as? [[String: Any]] else {
                        completion(defaultData)
                        return
                    }
                    
                    // 获取随机数，随机取一个数据作为推荐数据
                    let random = arc4random() % UInt32(songs.count)
                    let item = songs[Int(random)]
                    wyData.title = item["name"] as! String
                    // 作者
                    let author = ((item["ar"] as! [[String: Any]]).first!)["name"] as! String
                    // 专辑
                    let album = (item["al"] as! [String: Any])["name"] as! String
                    wyData.desc = author + "-" + album
                    
                    // 图片
                    let cover = (item["al"] as! [String: Any])["picUrl"] as! String
                    if let imgData = try? Data(contentsOf: URL(string: cover)!) {
                        wyData.bgImage = UIImage(data: imgData)
                    }
                    
                    // 回调
                    completion(wyData)
                }else {
                    completion(defaultData)
                }
            }else {
                completion(defaultData)
            }
        }.resume()
    }
}
