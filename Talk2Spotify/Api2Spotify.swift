//
//  Api2Spotify.swift
//  Spotify
//
//  Created by Lucas Backert on 02.11.14.
//  Copyright (c) 2014 Lucas Backert. All rights reserved.
//
import Foundation
import AppKit

struct Api2Spotify {
    static let osaStart = "tell application \"Spotify\" to"
    
    static func getState() ->String{
        return executeScript("player state")
    }

    static func getTitle() -> String{
        return executeScript("name of current track")
    }
    
    static func getAlbum() -> String{
        return executeScript("album of current track")
    }
    
    static func getArtist() -> String{
        return executeScript("artist of current track")
    }
    
    static func getCover() -> NSData{
        var result: NSData?
        var id = executeScript("id of current track")
        if( id != ""){
            let localOrNot = id.substringToIndex(id.startIndex.advancedBy(14))
            
            if( localOrNot != "spotify:local:" ){
                id = id.substringFromIndex(id.startIndex.advancedBy(14)) //ignore 'spotify:track'
                let request = NSMutableURLRequest(URL: NSURL(string: "https://api.spotify.com/v1/tracks/\(id)")!)
                let session = NSURLSession.sharedSession()
                request.HTTPMethod = "GET"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let task1 = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                    if(error == nil && data != nil){
                        var imageurl: String?
                        let jsonvalue: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)
                        
                        if(jsonvalue != nil ){
                            let jsondict = jsonvalue as! NSDictionary
                            let albumvalue = jsondict.valueForKey("album")
                            
                            if(albumvalue != nil ){
                                let imagesdict = albumvalue!.valueForKey("images") as! NSArray
                                let imageinfo = imagesdict[2] as! NSDictionary
                                imageurl = imageinfo.valueForKey("url") as? String
                            }
                        }
                        
                        if(imageurl != nil){
                            
                            let request2 = NSMutableURLRequest(URL: NSURL(string: imageurl!)!)
                            let session2 = NSURLSession.sharedSession()
                            request2.HTTPMethod = "GET"
                            request2.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
                            
                            let task2 = session2.dataTaskWithRequest(request2, completionHandler: {data2, response2, error2 -> Void in
                                if(data2 != nil){
                                    result = data2!
                                }else{
                                    result = NSData()
                                }
                            })
                            task2.resume()
                            
                        }
                        
                    }else{
                        result = NSData()
                    }
                })
                
                task1.resume()
                
                while(result == nil){
                    usleep(100)
                }
            }else{
                result = NSData()
            }
        }else{
            result = NSData()
        }
        
        return result!
    }
    
    static func getVolume() -> String{
        return executeScript("sound volume")
    }
    
    static func setVolume(level: Int){
        executeScript("set sound volume to \(level)")
    }
    
    static func toNextTrack(){
        executeScript("next track")
    }
    
    static func toPreviousTrack(){
        executeScript("previous track")
    }
    
    static func toPlayPause(){
        executeScript("playpause")
    }
    
    static func executeScript(phrase: String) -> String{
        var output = ""
        if(isSpotifyOn()){
            let script = NSAppleScript(source: "\(osaStart) \(phrase)" )
            var errorInfo: NSDictionary?
            let descriptor = script?.executeAndReturnError(&errorInfo)
            if(descriptor?.stringValue != nil){
                output = descriptor!.stringValue!
            }

        }
        return output
    }
    
    static func isSpotifyOn() -> Bool{
        let spotifyapp: [NSRunningApplication] = NSRunningApplication.runningApplicationsWithBundleIdentifier("com.spotify.client") as [NSRunningApplication]
        if spotifyapp.isEmpty {
            return false
        }else {
            return true
        }
    }
    
    // NOT USED AT THE MOMENT
    static func getDuration() -> String{
        return executeScript("duration of current track")
    }
    
    static func getPosition() -> String{
        return executeScript("position of current track")
    }
}

