Hey people,
since the last Spotify update to version 1.0.1.1060.gc75ebdfd they broke the support for the used applescript in their application. In the following link you can see how to change one file in the Spotify application to get partly the original functions back, only the album cover is still not supported in this new version.

https://community.spotify.com/t5/Help-Desktop-Linux-Mac-and/Apple-scripting-broken-in-1-0-1-988-g8f17a348/td-p/1029434

Another possibility is to go back to an older version of Spotify and turn off the autoupdate. There are advices in the Spotify forums how to do that.

If you want a deeper instruction how to use one of both solutions you can create an issue in this project and I will answer you.

Spotify4Me
==========

Implements a Widget for Spotify in the Notification Center of OS X 10.10 Yosemite

It uses the AppleScript API for Spotify to get the necesseray information and control it.

Watch Screenshot.tiff for preview.

Download the project, copy the "SpotifyMain.app" to your Applications folder and start it. Maybe in "Today View" settings the widget still needs to manually added.

If you have already installed one version restart the Mac, replace the old SpofityMain.app with the new one and start it.

Update:
- removed refresh button
- widget listens now to playstate of spotify, no manual refresh needed anymore
- if Spofity is closed or stopped (not paused) the widget will disappear and leaves the space for other widgets to take
