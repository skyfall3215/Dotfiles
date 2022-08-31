#!/bin/bash
###############################
#
## Load Variables
#
###############################
. $HOME/.config/sway/scripts/vars.conf



###############################
#
## Program Config
#
###############################
_date=$(date +%d%m%Y_%H%M%S)
[[ -n "$(ps aux | grep -v grep | grep -ioE 'swappy|feh|grim|slurp')" ]] && killall swappy feh grim slurp
[[ -n "$(ps aux | grep -v grep | grep -Ei '/bin/bash /home/.*/.config/sway/scripts.d/screenshot.sh')" ]] && killall zenity && exit
showEditor="$(zenity --list  --title "Screenshot" --column "Show Editor" yes no)"



###############################
#
## Take SS Before Run
#
###############################
takeInitialSS() {
	[[ -e "/tmp/*.png" ]] && rm /tmp/*.png
	grim -g "0,0 $screenResolution" - | tee /tmp/ss.png 1>/dev/null
}



###############################
#
## Open Photo Editor (swappy)
#
###############################
photoEditor() {
	[[ "$showEditor" == "yes" ]] && swappy -f /tmp/$@ -o /tmp/$@ || echo "->"
}



###############################
#
## Timeout (if selected)
#
###############################
timeoutBeforeSS() {
	timeout="$(zenity --title Screenshot \
	--text '               Full Screenshot' \
	--scale --value 3 --max-value 50)"
	[[ ! -z $timeout ]] && sleep $timeout || exit
}



###############################
#
## Take Rectangular SS
#
###############################
rectangularSS() {
	feh -F /tmp/ss.png &
	sleep 0.5
	slurpout=$(slurp)
	[[ -z $slurpout ]] && notify-send "Coordinate not specified, aborting..." && killall swappy feh grim slurp && exit
	grim -g "$slurpout" - | tee /tmp/rectangularss.png 1>/dev/null
	killall feh
}



###############################
#
## Copy Image to Clipboard
#
###############################
copyToClipboard() {
	cat /tmp/$@ | wl-copy && notify-send "The photo has been taken" || notify-send "The photo could not be taken"
	rm /tmp/*.png
}



###############################
#
## Save Image to Directory
#
###############################
saveToDirectory() {
	mv /tmp/$@ $imageDirectory/IMG_$_date.png && notify-send "The photo has been taken" || notify-send "The photo could not be taken"
	rm /tmp/*.png
}



###############################
#
## Handler
#
###############################
rectangular() {
ENTRY2="$(zenity --warning \
	--title Screenshot \
	--text 'Rectangular Screenshot' \
	--width 300 \
       	--extra-button "Timeout&Save" \
	--extra-button "Timeout&Copy" \
	--extra-button "Save" \
       	--extra-button "Copy" \
	--ok-label 'Cancel')"

[[ "$ENTRY2" == "Timeout&Save" ]] && timeoutBeforeSS && takeInitialSS && rectangularSS && photoEditor "rectangularss.png" && saveToDirectory "rectangularss.png"
[[ "$ENTRY2" == "Timeout&Copy" ]] && timeoutBeforeSS && takeInitialSS && rectangularSS && photoEditor "rectangularss.png" && copyToClipboard "rectangularss.png"
[[ "$ENTRY2" == "Save" ]] && takeInitialSS && rectangularSS && photoEditor "rectangularss.png" && saveToDirectory "rectangularss.png"
[[ "$ENTRY2" == "Copy" ]] && takeInitialSS && rectangularSS && photoEditor "rectangularss.png" && copyToClipboard "rectangularss.png"
}


full() {
ENTRY2="$(zenity --warning \
	--title Screenshot \
	--text 'Full Screenshot' \
	--width 300 \
       	--extra-button "Timeout&Save" \
	--extra-button "Timeout&Copy" \
	--extra-button "Save" \
       	--extra-button "Copy" \
	--ok-label 'Cancel')"

[[ "$ENTRY2" == "Timeout&Save" ]] && timeoutBeforeSS && takeInitialSS && photoEditor "ss.png" && saveToDirectory "ss.png"
[[ "$ENTRY2" == "Timeout&Copy" ]] && timeoutBeforeSS && takeInitialSS && photoEditor "ss.png" && copyToClipboard "ss.png"
[[ "$ENTRY2" == "Save" ]] && takeInitialSS && photoEditor "ss.png" && saveToDirectory "ss.png"
[[ "$ENTRY2" == "Copy" ]] && takeInitialSS && photoEditor "ss.png" && copyToClipboard "ss.png"
}


case $1 in
	rec)
		takeInitialSS && rectangularSS && photoEditor "rectangularss.png" && copyToClipboard "rectangularss.png"
	;;
	full)
		takeInitialSS && photoEditor "ss.png" && copyToClipboard "ss.png"
	;;
	*)
		ENTRY1="$(zenity --warning \
		       	--title Screenshot \
			--text 'Screenshot' \
			--width 300 \
		       	--extra-button Rectangular \
			--extra-button Full \
		       	--ok-label 'Cancel')"
		[[ "$ENTRY1" == "Rectangular" ]] && rectangular
		[[ "$ENTRY1" == "Full" ]] && full
	;;
esac
