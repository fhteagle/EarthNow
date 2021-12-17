#!/bin/bash

# EARTHNOW v20211216 by D.H. (github fhteagle)
# based on a previous script set by unknown author and generateclouds by https://gist.github.com/krkeegan

# CONFIGURATION VARIABLES

# final output size 
geometry=2256x1504    																							# SETME

# Re-download and stitch cloud maps if they are older than how many minutes?
stale_mins=180

# Skip battery and metered connection checks?
forceflag=0 																									# set to 1 to skip battery and internet status checking, 0 to enable these checks
stop_dl=0

# Battery thresholds
discharging_floor=93 																							# SETME do not run the script if we are discharging and battery percentage is below this value
charging_floor=70 																								# SETME do not run the script if we are charging and battery percentage is below this value

# Commands to get key variables
capacity=$( cat /sys/bus/acpi/drivers/battery/PNP0C0A\:00/power_supply/BAT1/capacity )  						# SETME this should retrieve a integer of current battery percentage
discharging=$( cat /sys/bus/acpi/drivers/battery/PNP0C0A\:00/power_supply/BAT1/status | grep -c Discharging ) 	# SETME this should retrieve either a 1 if the battery is discharging, or a 0 if either charging or not discharging 
bt_tethering=$( ip addr show | grep -c bnep ) 																	# SETME command to check if bluetooth tethering is in use, should return 0 for no tethering, 1 for tethering in use
usb_tethering=$( ip addr show | grep -c enp0s13f0u1 ) 															# SETME command to check if usb tethering is in use, should return 0 for no tethering, 1 for tethering in use
metered_conn=$( nmcli -t -f GENERAL.DEVICE,GENERAL.METERED dev show | grep -ic METERED:yes ) 					# SETME count number of connections that are guessed or manually have their metered property set

# Locations of needed commands on this system
xplanet_cmd="/usr/bin/xplanet"
nice_cmd="/usr/bin/nice"
python_cmd="/usr/bin/python"
ln_cmd="/bin/ln -sf"
date_cmd="/bin/date"

# base directory to work from
earthnow_dir=$( getent passwd "$USER" | cut -d: -f6 )/.xplanet/earthnow											# SETME

# Command to re-generate clouds
clouds_cmd="$earthnow_dir/generateclouds.py"																	# SETME

# Command to update DE's wallpaper
kwallpaper_cmd="$earthnow_dir/ksetwallpaper.py"																	# SETME
wallpaper_cmd="$python_cmd $kwallpaper_cmd"						                                            	# SETME

# intermediate step filenames
fileNamePrefix="earthnow"
fileNameTmp="earthnow_tmp.jpg"
fileNameDay="earthnow_day.jpg"
fileNameNight="earthnow_night.jpg"
fileNameClouds="earthnow_clouds.png"
fileNameConfig="earthnow_config"

# END CONFIG

# Check for options specified in command line arguments
while getopts ":f" opt; do
    case "$opt" in
    f)  forceflag=1
        ;;
    esac
done

# Check if we are on battery. If so, use the last built image and exit.
if [[ $forceflag -lt 1 && (( $discharging -gt 0 && $capacity -lt $discharging_floor ) || ( $discharging -lt 1 && $capacity -lt $charging_floor )) ]]; then
      echo "Due to power status, not updating the wallpaper image";
    exit 1
else
    echo "Sufficient battery or force flag invoked, continuing";
fi

# Checking if BT tethering is in use
if [[ $forceflag -lt 1 && $bt_tethering -gt 0 ]]; then
  echo "bluetooth tethering in use, preventing download"
  stop_dl=$stop_dl+1
else
  echo "Not bluetooth tethering or force flag invoked, continuing"
fi

# Checking if USB tethering is in use
if [[ $forceflag -lt 1 && $usb_tethering -gt 0 ]]; then
  echo "USB tethering in use, preventing download"
  stop_dl=$stop_dl+1
else
  echo "Not USB tethering or force flag invoked, continuing"
fi

# Checking if metered connection is in use
if [[ $forceflag -lt 1 && $metered_conn -gt 1 ]]; then
  echo "Metered Connection in use, preventing download"
  stop_dl=$stop_dl+1
else
  echo "Not Using a metered connection or force flag invoked, continuing"
fi

# Set day base map for the current month
month=$( $date_cmd +%m )
$( $ln_cmd $earthnow_dir/world.2004${month}.3x5400x2700.jpg $earthnow_dir/$fileNameDay )

# If config file does not exist, then output xplanet config file
if [[ -f $earthnow_dir/$fileNameConfig ]]; then
  # config file exists, and is assumed to be valid, do not overwrite
  echo "Skipping config file write"
else
  # write config file
  printf "[earth]\nmap=$earthnow_dir/$fileNameDay\nnight_map=$earthnow_dir/$fileNameNight\ncloud_map=$earthnow_dir/$fileNameClouds" > $earthnow_dir/$fileNameConfig
fi

# Download newest cloud map, but only if it is newer than local
updated=$( $date_cmd -r $earthnow_dir/$fileNameClouds +%s )
echo "Clouds last updated: $updated"
stale_date=$( $date_cmd -d "$stale_mins minutes ago" +%s)
if [[ $updated -lt $stale_date && stop_dl -lt 1 ]]; then
  echo "Cloud file is stale, generating a new one"
  $( $python_cmd $clouds_cmd )
else
  echo "Cloud file is not stale, continuing"
fi

# Get current minute number
minutes=$( $date_cmd +%M )

# Actually make the wallpaper
$( $nice_cmd -n 19 $xplanet_cmd -config $earthnow_dir/$fileNameConfig -num_times 1 -output $earthnow_dir/$fileNamePrefix_m$minutes.jpg -geometry $geometry -body earth -projection mercator -proj_param 72 )
# Other options for projection, which uses the radius parameter instead
#$( $nice_cmd -n 19 $xplanet_cmd -config $earthnow_dir/$fileNameConfig -num_times 1 -output $earthnow_dir/earthnow_m$minutes.jpg -geometry $geometry -body earth -projection peters -radius 70 )
#$( $nice_cmd -n 19 $xplanet_cmd -config $earthnow_dir/$fileNameConfig -num_times 1 -output $earthnow_dir/$fileName -geometry $geometry -body earth -projection mercator -latitude 38 -longitude -108 -proj_param 72 )

# Set the wallpaper
$( $wallpaper_cmd $earthnow_dir/earthnow_m$minutes.jpg )

exit 0;
