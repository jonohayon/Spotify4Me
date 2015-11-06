//
//  TodayViewController.swift
//  Spotify4Me
//
//  Created by Lucas Backert on 02.11.14.
//  Copyright (c) 2014 Lucas Backert. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding {
    override var nibName: String? {
        return "TodayViewController"
    }
    
    let smState = "smState"
    let smTitle = "smTitle"
    let smAlbum = "smAlbum"
    let smArtist = "smArtist"
    let smCover = "smCover"
    let smVolume = "smVolume"
    let playImage = NSImage(named: "play")
    let pauseImage = NSImage(named: "pause")

    var initialize = true
    var defaults = NSUserDefaults(suiteName: "backert.apps")!
    var centerReceiver = NSDistributedNotificationCenter()
    var information = [NSObject:AnyObject]()
    var controller = NCWidgetController.widgetController()
    
    @IBOutlet weak var titleOutput: NSTextField!
    @IBOutlet weak var albumOutput: NSTextField!
    @IBOutlet weak var artistOutput: NSTextField!
    @IBOutlet weak var coverOutput: NSImageView!
    @IBOutlet weak var volumeSlider: NSSlider!
    @IBOutlet weak var playpauseButton: NSButton!
    
    @IBOutlet weak var CoverHight: NSLayoutConstraint!
    @IBAction func volumeSliderAction(sender: AnyObject) {
        let notify = NSNotification(name: "Spotify4Me", object: "volume\(sender.integerValue)")
        centerReceiver.postNotification(notify)
    }
    @IBAction func previousButton(sender: AnyObject) {
        let notify = NSNotification(name: "Spotify4Me", object: "back")
        centerReceiver.postNotification(notify)
    }
    @IBAction func nextButton(sender: AnyObject) {
        let notify = NSNotification(name: "Spotify4Me", object: "skip")
        centerReceiver.postNotification(notify)
    }
    @IBAction func playpauseButton(sender: AnyObject) {
        let notify = NSNotification(name: "Spotify4Me", object: "playpause")
        centerReceiver.postNotification(notify)
    }
    
    override func viewWillAppear() {
        if initialize {
            initialize = false
            setReceiver()
            let notify = NSNotification(name: "Spotify4Me", object: "update")
            let mainapp: [NSRunningApplication] = NSRunningApplication.runningApplicationsWithBundleIdentifier("backert.SpotifyMain") as [NSRunningApplication]
            if mainapp.isEmpty {
                titleOutput.stringValue = "Please start 'SpotifyMain' application"
            }else {
                let app: [NSRunningApplication] = NSRunningApplication.runningApplicationsWithBundleIdentifier("com.spotify.client") as [NSRunningApplication]
                if app.isEmpty {
                    controller.setHasContent(false, forWidgetWithBundleIdentifier: "backert.SpotifyMain.SpotifyMain4Me")
                }else{
                    centerReceiver.postNotification(notify)
                }
            }
        }
    }

    func setReceiver(){
        self.centerReceiver.addObserverForName("Spotify4Me", object: nil, queue: nil) { (note) -> Void in
            let cmd = note.object as! String
            if cmd == "finished" {
                self.information = self.defaults.persistentDomainForName("backert.apps")!
                self.refreshView()
            }
        }
        self.centerReceiver.addObserverForName("com.spotify.client.PlaybackStateChanged", object: nil, queue: nil) { (note) -> Void in
            let info = note.userInfo!
            let state = info["Player State"]! as! String
            let notify = NSNotification(name: "Spotify4Me", object: "update")
            
            let mainapp: [NSRunningApplication] = NSRunningApplication.runningApplicationsWithBundleIdentifier("backert.SpotifyMain") as [NSRunningApplication]
            if mainapp.isEmpty {
                self.titleOutput.stringValue = "Please start 'SpotifyMain' application"
            }else {
                if state != "Stopped" {
                    self.centerReceiver.postNotification(notify)
                }
            }
        }
    }
    
    func refreshView(){
        titleOutput.stringValue = information[smTitle] as! String
        albumOutput.stringValue = information[smAlbum] as! String
        artistOutput.stringValue = information[smArtist] as! String
        
        let vol: String = information[smVolume] as! String
        volumeSlider.integerValue = Int(vol)!
        
        let coverAsData = information[smCover] as! NSData
        let imageobj = NSImage.init(data: coverAsData)
        
        if( !coverAsData.isEqualToData(NSData()) && imageobj != nil ){
            CoverHight.constant = CGFloat(64)
            coverOutput.image = imageobj
        }else{
            CoverHight.constant = CGFloat(0)
        }
    
        let state = information[smState] as! String
        
        if state == "kPSP" {
            playpauseButton.image = pauseImage
        }else if state == "kPSp" {
            playpauseButton.image = playImage
        }
    }
}
