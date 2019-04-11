//
//  SocketIOManager.swift
//  Skypep
//
//  Created by mac on 4/5/19.
//  Copyright © 2019 Paracosma. All rights reserved.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    let manager = SocketManager(socketURL: URL(string: "http://192.168.10.122:1000")!, config: [.log(true), .compress])
    var socket:SocketIOClient{
        get{
            return manager.defaultSocket
        }
    }
    
    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func startListening(completionHandler: @escaping (_ data: Data?) -> Void){
        socket.on("newPacket") { (data, socketAck) -> Void in
            print("......")
            completionHandler(data[0] as? Data)
        }
    }
    
    func startListeningAudio(completionHandler: @escaping (_ data: Data?) -> Void){
        socket.on("newAudio") { (data, socketAck) -> Void in
            print("......Audio")
            completionHandler(data[0] as? Data)
        }
    }
    
    func sendPacket(data: Data?){
        if let data = data{
            socket.emit("packet",data)
        }
    }
    
    func sendAudio(data: Data?){
        if let data = data{
            socket.emit("audio",data)
        }
    }
}
