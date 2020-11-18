//
//  GKWYDataLoader.swift
//  GKWYWidgetExtension
//
//  Created by gaokun on 2020/11/11.
//  Copyright © 2020 gaokun. All rights reserved.
//

import Foundation
import UIKit

let typePrefix = "GKWYWidget://com.wy."
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
        list.append(.init(id: "4", title: "我喜欢的音乐", desc: "最懂你的音乐电台", icon: "cm4_disc_type_product", type: "fm", bgImage: UIImage(named: "love_bg")))
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
        let url = URL(string: "https://musicapi.qianqian.com/v1/restserver/ting?format=json&from=ios&channel=appstore&method=baidu.ting.billboard.billList&type=1&size=20&offset=0")!
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if data != nil && error == nil {
                let json = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                let error_code = json["error_code"] as! Int
                if error_code == 22000 {
                    if let list = (json["song_list"] as? [[String: Any]]) {
                        // 获取随机数
                        let random = arc4random() % UInt32(list.count)
                        let item = list[Int(random)]
                        
                        wyData.title = item["title"] as! String
                        
                        let author = item["author"] as! String
                        let album = item["album_title"] as! String
                        wyData.desc = author + "-" + album
                        
                        let cover = item["pic_radio"] as! String
                        if let imgData = try? Data(contentsOf: URL(string: cover)!) {
                            wyData.bgImage = UIImage(data: imgData)
                        }
                        completion(wyData)
                    }else {
                        completion(defaultData)
                    }
                }else {
                    completion(defaultData)
                }
            }else {
                completion(defaultData)
            }
        }.resume()
    }
}
