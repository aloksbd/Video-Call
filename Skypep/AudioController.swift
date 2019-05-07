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

class AudioController: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
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
        if counter == 4{
            finishRecording(success: true)
            if let data = try? Data(contentsOf: getFileUrl()){
//                SocketIOManager.sharedInstance.sendAudio(data: data)
            }
        }
        if counter == 5{
            
            counter = 0
            startRecording()
        }
        counter += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1/30, execute: {
            self.run()
        })
    }
    
}
