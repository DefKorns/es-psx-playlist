#!/bin/bash
#
#  MIT License
#  Copyright (c) 2020 DefKorns (https://defkorns.github.io/LICENSE)
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

gaaData="/gaadata/"
peGameDir="/media/games/"
esPSXDir="/media/roms/psx"
volPSX="/var/volatile${esPSXDir}"
m3uDir="/media/project_eris/etc/project_eris/SUP/retroarch"
region="$(cat "/gaadata/geninfo/REGION")"
palGames=(SLUS-00594 SLUS-00776 SCUS-94163 SCUS-94164 SCUS-94165)
ntscjGames=(SLPS-01230 SLPS-01231 SLPS-01057 SLPS-01058 SLPS-01059 SLPM-86114 SLPM-86115)

# check if overlay is mounted and unmount it
mount | grep -qs "${esPSXDir}" && umount "${esPSXDir}"

# create lowerdir on volatile
[ ! -d "${volPSX}" ] && mkdir -p "${volPSX}"

# find all PSX games and link them to ES rom folder

find "$gaaData" "$peGameDir" -maxdepth 2 -regex ".*\.\(cue\|m3u\|bin\|pbp\|chd\|iso\)" | while IFS= read -r gameFile; do
  gameTitle="${gameFile##*/}"

  if [ ! -f "${volPSX}/${gameTitle}" ]; then
    ln -s "$gameFile" "$volPSX"
  fi
done

# Load playlists for multidisc original games
if [ "$region" == "EK" ]; then
  for g in "${palGames[@]}"; do
    find "$volPSX" -name "${g}.*" -exec rm {} +
  done
  ln -s "${m3uDir}/SLUS-00594.m3u" "${volPSX}"
  ln -s "${m3uDir}/SCUS-94163.m3u" "${volPSX}"
else
  for g in "${ntscjGames[@]}"; do
    find "$volPSX" -name "${g}.*" -exec rm {} +
  done
  ln -s "${m3uDir}/SLPS-01230.m3u" "${volPSX}"
  ln -s "${m3uDir}/SLPS-01057.m3u" "${volPSX}"
  ln -s "${m3uDir}/SLPM-86114.m3u" "${volPSX}"
fi

# mount volume
mount -t overlay -o lowerdir="${esPSXDir}":"${volPSX}" "overlay-PSX2ES-media" "${esPSXDir}"
# EOF
