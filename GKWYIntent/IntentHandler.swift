//
//  IntentHandler.swift
//  GKWYIntent
//
//  Created by gaokun on 2020/11/12.
//  Copyright © 2020 gaokun. All rights reserved.
//

import Intents

class IntentHandler: INExtension, GKWYWidgetConfigurationIntentHandling {
    func provideModeArrOptionsCollection(for intent: GKWYWidgetConfigurationIntent, searchTerm: String?, with completion: @escaping (INObjectCollection<GKWYWidgetMode>?, Error?) -> Void) {
        var list = [GKWYWidgetMode]()
        for model in GKWYData.getList() {
            if intent.modeArr != nil {
                var exist = false
                for mode in intent.modeArr! {
                    if mode.identifier == model.id {
                        exist = true
                    }
                }
                // 没有才去添加
                if !exist {
                    list.append(.init(identifier: model.id, display: model.title, pronunciationHint: model.desc))
                }
            }else {
                list.append(.init(identifier: model.id, display: model.title, pronunciationHint: model.desc))
            }
        }
        completion(.init(items: list), nil)
    }
    
    func defaultModeArr(for intent: GKWYWidgetConfigurationIntent) -> [GKWYWidgetMode]? {
        return GKWYData.getModeList()
    }
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
}
