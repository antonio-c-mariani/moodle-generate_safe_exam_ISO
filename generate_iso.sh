#!/bin/bash

local_dir="${BASH_SOURCE%/*}"

# Path to the base Ubuntu ISO
ISO=~/isos/ubuntu-mini-remix-16.04-amd64.iso

# Path to the directory containing the necessary scripts and files to generate the ISO
SCRIPTS_DIR=$local_dir

# Working directory. The final ISO will be stored here
REMASTER_HOME=~/tmp

sudo rm -rf $REMASTER_HOME/*
sudo time /usr/bin/uck-remaster $ISO $SCRIPTS_DIR $REMASTER_HOME
