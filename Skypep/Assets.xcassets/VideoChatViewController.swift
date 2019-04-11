//
//  VideoChatViewController.swift
//  Skypep
//
//  Created by mac on 4/5/19.
//  Copyright © 2019 Paracosma. All rights reserved.
//

import UIKit

class VideoChatViewController: UIViewController {
    
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
        v.backgroundColor = .green
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
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .yellow
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .red
        
        view.addSubview(incomingVideoView)
        view.addSubview(selfVideoView)
        addConstraints()
        
//        run()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SocketIOManager.sharedInstance.startListening { (data) in
            if let data = data{
                self.incomingVideoView.image = UIImage(data: data)
            }
        }
    }
    
    func run(){
//        SocketIOManager.sharedInstance.sendPacket(data: "alok")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.run()
        })
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
