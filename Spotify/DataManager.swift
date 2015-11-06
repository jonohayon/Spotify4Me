//
//  DataManager.swift
//  SpotifyMain
//
//  Created by Lucas Backert on 05.11.14.
//  Copyright (c) 2014 Lucas Backert. All rights reserved.
//

import Foundation
import AppKit
import NotificationCenter

class DataManager {
    let smState = "smState"
    let smTitle = "smTitle"
    let smAlbum = "smAlbum"
    let smArtist = "smArtist"
    let smCover = "smCover"
    let smVolume = "smVolume"
    
    var defaults = NSUserDefaults(suiteName: "backert.apps")!
    var centerReceiver = NSDistributedNotificationCenter()
    var information: [String:AnyObject] = [:]
    init(){
        centerReceiver.addObserverForName("Spotify4Me", object: nil, queue: nil) { (note) -> Void in
            var defaultcase = false
            let cmd = note.object as! String
            switch cmd {
            case "update":
                self.update()
            case "playpause":
                self.playpause()
            case "skip":
                self.skip()
            case "back":
                self.back()
            case "finished":
                defaultcase = true
                break
            case let volumestring :
                if let range = volumestring.rangeOfString("volume") {
                    let stringVol:String = volumestring.substringFromIndex(range.endIndex)
                    self.volume(Int(stringVol)!)
                }
            }
            if !defaultcase {
                let notify = NSNotification(name: "Spotify4Me", object: "finished")
                self.centerReceiver.postNotification(notify)
            }
        }
        
        self.centerReceiver.addObserverForName("com.spotify.client.PlaybackStateChanged", object: nil, queue: nil) { (note) -> Void in
            let info = note.userInfo!
            let state = info["Player State"]! as! String
            let controller = NCWidgetController.widgetController()
            
            if state == "Stopped" {
                controller.setHasContent(false, forWidgetWithBundleIdentifier: "backert.SpotifyMain.SpotifyMain4Me")
            }else{
                controller.setHasContent(true, forWidgetWithBundleIdentifier: "backert.SpotifyMain.SpotifyMain4Me")
            }
            self.update()
        }
    }
    func update(){
        let state = Api2Spotify.getState()
        information.updateValue(state, forKey: smState)
        if state != "kPSS" {
            information.updateValue(Api2Spotify.getTitle(), forKey: smTitle)
            information.updateValue(Api2Spotify.getAlbum(), forKey: smAlbum)
            information.updateValue(Api2Spotify.getArtist(), forKey: smArtist)
            information.updateValue(Api2Spotify.getCover(), forKey: smCover)
            information.updateValue(Api2Spotify.getVolume(), forKey: smVolume)
        }
        defaults.setPersistentDomain(information, forName: "backert.apps")
        defaults.synchronize()
    }
    func playpause(){
        Api2Spotify.toPlayPause()
        update()
    }
    func skip(){
        Api2Spotify.toNextTrack()
        update()
    }
    func back(){
        Api2Spotify.toPreviousTrack()
        update()
    }
    func volume(level: Int){
        Api2Spotify.setVolume(level)
        update()
    }
}