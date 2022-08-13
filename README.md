# EarthNow
Modern fork of a classic wallpaper updater script called "EarthNow". I am not sure where I got the first version of this, but I have modified it many times over the years, adding checks for battery status, tethering, metered connections, etc. I have in the past had it set up to change the wallpaper in KDE Plasma, Gnome, enlightenment, etc. I am including instructions for a python script that works for KDE Plasma, but this could be easily adjusted for other DEs. I realize bash scripts calling python scripts is really kludgy, but I really do not care. 

No warranty, guarantee, support or entitlement should be assumed from the fact that I am passing this script along to the world under CC-BY-SA 4.0. The base map images I believe are from the NASA Blue Marble collection ( https://visibleearth.nasa.gov/collection/1484/blue-marble ), which should be released in the public domain. If you are the copyright holder of any of the image files used in this method, please contact me with a DMCA request and I will be happy to take them down.

Installation

0. Get / verify dependencies:
 0.a. Python ( not sure min or maximum version, this was last tested with Python3.10 )
 0.b. nice, date, ip, and ln commands ( these come with most linux installations )
 0.c. xplanet ( available in most linux distributions freeware repos )
 0.d. nmcli ( comes with most NetworkManager packages, but this can be modified in configuration command section for other network manager systems )
 0.e. optional: systemd ( for running this script periodically, but it would work just as well via cron, chrony, etc )
1. Download all files from this repository and place them in any directory you wish. Default location is ~HOME/.xplanet/earthnow , but this can and should be configured in the variables at the start of earthnowplasma.sh .
2. Download generateclouds.py from https://gist.github.com/krkeegan/64e96290eb6569790d230085016501da to the same directory as earthnowplasma.sh script, and follow his instructions at the top of the file.
3. Get the necessary python script to trigger your DE to update your wallpaper and place it in the same directory as the above files. For Plasma, I found this one to work:  https://github.com/pashazz/ksetwallpaper/blob/master/ksetwallpaper.py
4. Modify configuration variables, directories, commands path, etc. at the start of earthnowplasma.sh to fit your environment, etc.
5. To run once, just trigger from command line, with or without -f (skip battery and tethering checks) options
6. Optionally, move the .service, .slice, and .timer files to appropriate user systemctl directory (i.e. $HOME/.config/systemd/user), edit the .service file to set the correct exec directory for earthnowplasma.sh, and enable the timer. This will run the script every 5 minutes by default. Edit the timer file to change the frequency it runs.
7. Enjoy your wallpaper, modify it, make suggestions about how my ugly code can be improved, etc!
