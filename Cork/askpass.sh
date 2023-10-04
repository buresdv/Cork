#!/bin/sh

#  askpass.sh
#  Cork
#
#  Created by Bryan Ledda on 06/10/2023.
#  

osascript -e 'set T to text returned of (display dialog "Enter password" buttons {"Cancel", "OK"} default button "OK" default answer "" with hidden answer)'
