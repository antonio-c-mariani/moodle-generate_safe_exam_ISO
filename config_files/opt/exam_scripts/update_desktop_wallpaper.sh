#!/bin/bash
#set -x

source ${BASH_SOURCE%/*}/exam_conf.sh
source ${BASH_SOURCE%/*}/functions.sh

if [ ! -e ${wallpaper}.orig ] ; then
	log 'Copying original wallpaper'
	cp ${wallpaper} ${wallpaper}.orig
fi

if network_isup; then
    log 'Network is up: generating institution wallpaper'

    text="$exam_description"
    font_size='50'
    font_color='white'
    font_name='DejaVu-Sans-Bold'
    position='north'
    h_offset='+200'
    v_offset='+80'
    offset="${h_offset}${v_offset}"

    convert "${wallpaper}.orig" -font "$font_name" -pointsize "$font_size" -gravity "$position" \
            -stroke '#000C' -strokewidth 2 -annotate "$offset" "$text" \
            -stroke none -fill "$font_color" -annotate "$offset" "$text" "${wallpaper}.tmp"

    text="$institution_acronym - $institution_name"
    font_size='35'
    font_color='white'
    font_name='DejaVu-Sans-Bold'
    position='north'
    h_offset='+200'
    v_offset='+170'
    offset="${h_offset}${v_offset}"

    convert "${wallpaper}.tmp" -font "$font_name" -pointsize "$font_size" -gravity "$position" \
            -stroke '#000C' -strokewidth 2 -annotate "$offset" "$text" \
            -stroke none -fill "$font_color" -annotate "$offset" "$text" "${wallpaper}.tmp2"
    mv "${wallpaper}.tmp2" "${wallpaper}.tmp"

    contact_txt=$(get_string 'contact')
    version_txt=$(get_string 'version')

    text="${version_txt} ${exam_version} ${contact_txt} ${contact_email}"
    font_size='25'
    font_color='white'
    font_name='DejaVu-Sans-Mono-Bold'
    position='north'
    h_offset='+200'
    v_offset='+250'
    offset="${h_offset}${v_offset}"

    convert "${wallpaper}.tmp" -font "$font_name" -pointsize "$font_size" -gravity "$position" \
            -stroke '#000C' -strokewidth 2 -annotate "$offset" "$text" \
            -stroke none -fill "$font_color" -annotate "$offset" "$text" "${wallpaper}"
else
    log 'Network is down: generating alert wallpaper'

    text=$(get_string 'waiting_network')
    font_size='50'
    font_color='yellow'
    font_name='DejaVu-Sans-Bold'
    position='center'
    h_offset='+0'
    v_offset='+0'
    offset="${h_offset}${v_offset}"

    convert "${wallpaper}.orig" -font "$font_name" -pointsize "$font_size" -gravity "$position" \
            -stroke '#000C' -strokewidth 2 -annotate "$offset" "$text" \
            -stroke none -fill "$font_color" -annotate "$offset" "$text" "${wallpaper}.tmp"

    check=$(get_string 'check_network')
    text=$(get_string 'click_check_network' "$check")
    font_size='25'
    font_color='yellow'
    font_name='DejaVu-Sans-Bold'
    position='center'
    h_offset='+0'
    v_offset='+80'
    offset="${h_offset}${v_offset}"

    convert "${wallpaper}.tmp" -font "$font_name" -pointsize "$font_size" -gravity "$position" \
            -stroke '#000C' -strokewidth 2 -annotate "$offset" "$text" \
            -stroke none -fill "$font_color" -annotate "$offset" "$text" "${wallpaper}"
fi

rm -f "${wallpaper}.tmp"
