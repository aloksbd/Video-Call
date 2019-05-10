//
//  CameraController.swift
//  AV Foundation
//
//  Created by VRLab on 4/3/19.
//  Copyright © 2019 Pranjal Satija. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import SwiftSocket
import CocoaAsyncSocket

class CameraController:NSObject, GCDAsyncUdpSocketDelegate {

    var session: AVCaptureSession!
    var device: AVCaptureDevice!
    var output: AVCaptureVideoDataOutput!
    var imageView = UIImageView()
    var client = UDPClient(address: "192.168.10.122", port: 7000)
    
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
    
    deinit {
        socket = nil
    }
    
    override init() {
        super.init()
        _socket?.setDelegate(self)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // Prepare a video capturing session.
        self.session = AVCaptureSession()
        self.session.sessionPreset = AVCaptureSession.Preset.vga640x480 
//        if #available(iOS 11.1, *) {
//            device = AVCaptureDevice.default(.builtInTrueDepthCamera, for: AVMediaType.video, position: .front)
//        } else {
            // Fallback on earlier versions
            device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)
//        }
        do{
            try device.lockForConfiguration()
            device.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: 10)
        }
        catch {
            print("boom")
        }
        
        if (self.device == nil) {
            print("no device")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: self.device)
            self.session.addInput(input)
        } catch {
            print("no device input")
            return
        }
        self.output = AVCaptureVideoDataOutput()
        self.output.videoSettings = [ kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA) ]
        let queue: DispatchQueue = DispatchQueue(label: "videocapturequeue", attributes: [])
        self.output.setSampleBufferDelegate(self as? AVCaptureVideoDataOutputSampleBufferDelegate, queue: queue)
        self.output.alwaysDiscardsLateVideoFrames = true
        if self.session.canAddOutput(self.output) {
            self.session.addOutput(self.output)
        } else {
            print("could not add a session output")
            return
        }
        do {
            try self.device.lockForConfiguration()
            self.device.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 20) // fps
            self.device.unlockForConfiguration()
        } catch {
            print("could not configure a device")
            return
        }

//        run()
    }
    
    var buff: CVPixelBuffer?
}

extension CameraController: AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let buffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("could not get a pixel buffer")
            return
        }
        buff = buffer
        do {
            CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags.readOnly)
            defer {
                CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags.readOnly)
            }
            let address = CVPixelBufferGetBaseAddressOfPlane(buffer, 0)
            let bytes = CVPixelBufferGetBytesPerRow(buffer)
            let width = CVPixelBufferGetWidth(buffer)
            let height = CVPixelBufferGetHeight(buffer)
            let color = CGColorSpaceCreateDeviceRGB()
            let bits = 8
            let info = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
            guard let context = CGContext(data: address, width: width, height: height, bitsPerComponent: bits, bytesPerRow: bytes, space: color, bitmapInfo: info) else {
                print("could not create an CGContext")
                return
            }
            guard let image = context.makeImage() else {
                print("could not create an CGImage")
                return
            }
            DispatchQueue.main.async {
                let img = UIImage(cgImage: image, scale: 1.0, orientation: UIImage.Orientation.right)
                self.imageView.image = img

            }
        }
    }
    
    
    
}
