#! /bin/bash

. $HOME/.config/sway/scripts/vars.conf

if [[ -e $AGENT1 ]]; then
	startprogram $AGENT1 &
elif [[ -e $AGENT2 ]]; then
	startprogram $AGENT2 &
fi

# Portal
if [[ -e $PORTAL1 ]]; then
	startprogram $PORTAL1 &
elif [[ -e $PORTAL2 ]]; then
    startprogram $PORTAL2 &
fi
