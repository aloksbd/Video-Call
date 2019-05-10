//
//  AudioController.swift
//  Skypep
//
//  Created by mac on 4/11/19.
//  Copyright © 2019 Paracosma. All rights reserved.
//

//import Foundation
import UIKit
import AVFoundation
import CocoaAsyncSocket

class AudioController: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    var socket: GCDAsyncUdpSocket?
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    var audioPlayer : AVAudioPlayer!
    var meterTimer:Timer!
    var isPlaying = false
    
    override init() {
        super.init()
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        do {
                            try self.recordingSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
                        } catch let error as NSError {
                            print("audioSession error: \(error.localizedDescription)")
                        }
//                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
//        SocketIOManager.sharedInstance.startListeningAudio { (data) in
//            if let data = data{
//                self.play_recording(data: data)
//            }
//        }
        startRecording()
        run()
    }
    
    func startRecording() {
        let audioFilename =  getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func getFileUrl() -> URL
    {
        let filename = "recording.m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(filename)
        return filePath
    }
    
    func prepare_play(data: Data)
    {
        do
        {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        }
        catch{
            print("Error")
        }
    }
    
    func play_recording(data: Data){
//        if(isPlaying)
//        {
//            audioPlayer.stop()
//            isPlaying = false
//        }
//        else
//        {
//            if FileManager.default.fileExists(atPath: getFileUrl().path)
//            {
                prepare_play(data: data)
                audioPlayer.play()
                isPlaying = true
//            }
//            else
//            {
//                print("error")
//            }
//        }
    }
    
    var counter = 0
    
    func run(){
        if counter == 2{
            finishRecording(success: true)
            if let fileUpdater = try? FileHandle(forUpdating: getFileUrl()) {
                
                // function which when called will cause all updates to start from end of the file
                fileUpdater.seekToEndOfFile()
                
                // which lets the caller move editing to any position within the file by supplying an offset
                fileUpdater.write("%".data(using: .utf8)!)
                
                //Once we convert our new content to data and write it, we close the file and that’s it!
                fileUpdater.closeFile()
            }
            if let data = try? Data(contentsOf: getFileUrl()){
                //                if let str = String(bytes: data, encoding: .utf8){
                //                    let newData = Data((str + "%").utf8)
                socket?.send(data, toHost: "192.168.10.122", port: 7000, withTimeout: -1, tag: 1)
                //                }
                //                SocketIOManager.sharedInstance.sendAudio(data: data)
            }
            //        }
            //        if counter == 3{
            
            counter = 0
            startRecording()
        }
        counter += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1/30, execute: {
            self.run()
        })
    }
    
}
