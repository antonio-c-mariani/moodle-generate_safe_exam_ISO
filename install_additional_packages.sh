#!/bin/bash

SCRIPT_DIR=`dirname "$0"`

# RStudio respository
# gpg --homedir /tmp --keyserver keyserver.ubuntu.com --recv-key E084DAB9
# gpg --homedir /tmp -a --export E084DAB9 | apt-key add -
# echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" | sudo tee -a /etc/apt/sources.list.d/r.list

# apt-get update || failure "apt-get update failed, error=$?"

# Installing Rstudio
# PACKAGES_TO_INSTALL="libjpeg62 libgstreamer0.10-0 libgstreamer-plugins-base0.10-0 r-base r-base-dev"
# apt-get install --assume-yes $PACKAGES_TO_INSTALL || failure "Installing Rstudio packs failed, error=$?"
# /usr/bin/dpkg -i ${SCRIPT_DIR}/software_src/rstudio-1.0.44-amd64.deb | failure "Installing packs failed, error=$?"
