Generating customized Ubuntu 16.04-amd64 ISO for safe exam using Moodle as a base plataform

# Fix error in /usr/lib/uck/remaster-live-cd.sh
	To correct this, "dpkg-query -p squashfs-tools" should be replaced with "dpkg -s squashfs-tools" as shown...
	https://bugs.launchpad.net/uck/+bug/143501r

Steps:

1) Install packages:
    apt-get install uck

2) Download the ubuntu-mini-remix-16.04-amd64.iso (http://www.ubuntu-mini-remix.org)

3) Change the directories in 'generate_iso.sh' script

4) Adjust the settings by changing the files:
    - ./config.sh
    - ./install_additional_packages.sh
    - ./packages_to_install

    - ./config_files/opt/exam_scripts/exam_conf.sh
    - ./config_files/opt/exam_scripts/exam_params.sh

5) Generate new ISO running: ./generate_iso.sh
