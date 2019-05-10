//
//  VideoChatViewController.swift
//  Skypep
//
//  Created by mac on 4/5/19.
//  Copyright © 2019 Paracosma. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class VideoChatViewController: UIViewController, GCDAsyncUdpSocketDelegate {
    
    var _socket: GCDAsyncUdpSocket?
    var socket: GCDAsyncUdpSocket? {
        get {
            if _socket == nil {
                guard let port = UInt16("1234") , port > 0 else {
                    print(">>> Unable to init socket: local port unspecified.")
                    return nil
                }
                let sock = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
                do {
                    try sock.bind(toPort: port)
                    try sock.beginReceiving()
                } catch let err as NSError {
                    print(">>> Error while initializing socket: \(err.localizedDescription)")
                    sock.close()
                    return nil
                }
                _socket = sock
            }
            return _socket
        }
        set {
            _socket?.close()
            _socket = newValue
        }
    }
    
    var audioController = AudioController()
    
    var selfVideoWidth: CGFloat {
        get{
            return self.view.frame.width/4
        }
    }
    
    var selfVideoHeight: CGFloat {
        get{
            return selfVideoWidth/2 * 3
        }
    }
    
    lazy var camController: CameraController = {
        let c = CameraController()
        c.session.startRunning()
        return c
    }()

    lazy var selfVideoView: UIView = {
       let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: self.selfVideoWidth).isActive = true
        v.heightAnchor.constraint(equalToConstant: self.selfVideoHeight).isActive = true
//        v.layer.addSublayer(self.camController.SetUpPreviewLayer(frame:CGRect(x: 0, y: 0, width: self.selfVideoWidth, height: self.selfVideoHeight)))
        v.addSubview(self.camController.imageView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.camController.imageView, attribute: .top, relatedBy: .equal, toItem: v, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.camController.imageView, attribute: .bottom, relatedBy: .equal, toItem: v, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.camController.imageView, attribute: .leading, relatedBy: .equal, toItem: v, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.camController.imageView, attribute: .trailing, relatedBy: .equal, toItem: v, attribute: .trailing, multiplier: 1, constant: 0),
        ])
        return v
    }()
    
    lazy var incomingVideoView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .yellow
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _socket?.setDelegate(self)
        // Do any additional setup after loading the view.
        view.backgroundColor = .red
        audioController.socket = socket
        view.addSubview(incomingVideoView)
        view.addSubview(selfVideoView)
        addConstraints()
        
        run()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        SocketIOManager.sharedInstance.startListening { (data) in
//            if let data = data{
//                self.incomingVideoView.image = UIImage(data: data)
//            }
//        }
    }
    
    func run(){
        //        client.enableBroadcast()
        //        let ii = client.send(string: "asd")
        //        if ii.isSuccess{
        //            print("sent tp \(client.address):\(client.port)")
        ////            client.close()
        //        }else{
        //            print(ii.error)
        //        }
        if let data = camController.imageView.image?.jpegData(compressionQuality:  0.2){
                socket?.send(data, toHost: "192.168.10.255", port: 7000, withTimeout: -1, tag: 1)
//                socket?.send("STR".data( using: String.Encoding.utf8)!, toHost: "192.168.10.122", port: 7000, withTimeout: -1, tag: 1)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1/24, execute: {
            self.run()
        })
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        if let img = UIImage(data: data as Data){
            DispatchQueue.main.async {
                self.incomingVideoView.image = img
            }
        }else{
            audioController.play_recording(data: data)
        }
    }
    
    func addConstraints(){
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: selfVideoView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: selfVideoView, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 8),
            
            NSLayoutConstraint(item: incomingVideoView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: incomingVideoView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: incomingVideoView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: incomingVideoView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        ])
    }

}
