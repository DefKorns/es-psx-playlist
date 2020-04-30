#!/bin/bash
#
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
source "/var/volatile/project_eris.cfg"

PSX_ROM_DIR="${ROMS_PATH}/psx"
LOWER_DIR="${VOLATILE}${PSX_ROM_DIR}"
SUP_RETROARCH="${SUPLEMENTARY_PATH}/retroarch"
GAME_IDS=(SLUS-00594 SLUS-00776 SCUS-94163 SCUS-94164 SCUS-94165 SLPS-01230 SLPS-01231 SLPS-01057 SLPS-01058 SLPS-01059 SLPM-86114 SLPM-86115)
# check if overlay is mounted and unmount it
mount | grep -qs "${PSX_ROM_DIR}" && umount "${PSX_ROM_DIR}"
find "${PSX_ROM_DIR}" -type l -exec rm {} \;
[ -d "${LOWER_DIR}" ] && rm -rf "${LOWER_DIR}"
# create lowerdir on volatile
[ ! -d "${LOWER_DIR}" ] && mkdir -p "${LOWER_DIR}"
# find all PSX games and link them to ES rom folder
find "${GAADATA}" "${GAME_PATH}" -maxdepth 2 -regex ".*\.\(cue\|m3u\|bin\|pbp\|chd\|iso\)" | while IFS= read -r GAME_IMAGE; do
  FILE_NAME="${GAME_IMAGE##*/}"
  GAME_TITLE=${FILE_NAME%.*}
  EXT=${GAME_IMAGE##*.}
  FULL_PATH="${GAME_IMAGE%/*}"
  STRIP_TITLE="${GAME_TITLE%%(*}"
  DISC_REMOVE="${STRIP_TITLE%%Disc*}"

  [ ! -f "${LOWER_DIR}/${FILE_NAME}" ] && ln -s "$GAME_IMAGE" "$LOWER_DIR"
  # Generate new m2u for multidisc games
  if [ "${EXT}" == "m3u" ]; then
    echo "${DISC_REMOVE}" >>"${VOLATILE}/psxCleanup"
    rm -f "${LOWER_DIR}/${FILE_NAME}"
    find "${FULL_PATH}" -name "*.cue" | while IFS= read -r CUE_FILE; do
      echo "../../games/${FULL_PATH##*/}/${CUE_FILE##*/}" >>"${LOWER_DIR}/${FILE_NAME}"
    done
  fi
done
# Remove symplinks for multidisc original games
for g in "${GAME_IDS[@]}"; do
  find "$LOWER_DIR" -name "${g}.*" -exec rm {} +
done
# Load playlists for multidisc original games
if [ "$REGION" != "J" ]; then
  ln -s "${SUP_RETROARCH}/SLUS-00594.m3u" "${LOWER_DIR}"
  ln -s "${SUP_RETROARCH}/SCUS-94163.m3u" "${LOWER_DIR}"
else
  ln -s "${SUP_RETROARCH}/SLPS-01230.m3u" "${LOWER_DIR}"
  ln -s "${SUP_RETROARCH}/SLPS-01057.m3u" "${LOWER_DIR}"
  ln -s "${SUP_RETROARCH}/SLPM-86114.m3u" "${LOWER_DIR}"
fi
# remove game image for m3u files
while IFS= read -r game; do
  find "${LOWER_DIR}" \( -name "${game}*.cue" -o -name "${game}*.bin" \) -exec rm {} +
done <"${VOLATILE}/psxCleanup"
# Emove
[ -f "${VOLATILE}/psxCleanup" ] && rm -f "${VOLATILE}/psxCleanup"
# mount volume
mount -t overlay -o lowerdir="${PSX_ROM_DIR}":"${LOWER_DIR}" "overlay-PSX2ES-media" "${PSX_ROM_DIR}"
# EOF
