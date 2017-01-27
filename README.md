Generating customized Ubuntu 16.04-amd64 ISO for safe exam using Moodle as a base plataform

The ISO must be used in conjunction with some Moodle modules in order to provide a secure environment for taking exams.

The ISO can be generated in any computer running Ubuntu 16.04 version. Steps to install and generate an ISO are:

1) Install packages:
    apt-get install uck squashfs-tools syslinux-utils

2) Fix the /usr/lib/uck/remaster-live-cd.sh script
	To correct this, "dpkg-query -p squashfs-tools" should be replaced with "dpkg -s squashfs-tools" as shown...
	https://bugs.launchpad.net/bugs/1435019

3) Download the ubuntu-mini-remix-16.04-amd64.iso (http://www.ubuntu-mini-remix.org)

4) Change the directories in 'generate_iso.sh' script

5) Adjust the settings by changing the files:

    ./config.sh
    ./install_additional_packages.sh
    ./packages_to_install

    ./config_files/opt/exam_scripts/exam_conf.sh
    ./config_files/etc/apt/sources.list             # server near you

6) Generate new ISO running:

    ./generate_iso.sh
