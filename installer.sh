#!/bin/bash

# Go into cache folder
mkdir ~/.dotcache/
cd ~/.dotcache/

# Clone repo
git clone https://github.com/c4dots/gnome_green_mar_25/
cd gnome_green_mar_25

# Run setup
bash setup.sh "$@"
