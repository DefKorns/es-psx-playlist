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

tmp_dir="/var/volatile"
original_games="/gaadata"
custom_games="/media/games"
rom_dir="/media/roms/psx"
lower_dir="${tmp_dir}${rom_dir}"
original_m3u="/media/project_eris/etc/project_eris/SUP/retroarch"
psc_region="$(cat "${original_games}/geninfo/REGION")"
game_ids=(SLUS-00594 SLUS-00776 SCUS-94163 SCUS-94164 SCUS-94165 SLPS-01230 SLPS-01231 SLPS-01057 SLPS-01058 SLPS-01059 SLPM-86114 SLPM-86115)

western_psc=(EK UC)

# check if overlay is mounted and unmount it
mount | grep -qs "${rom_dir}" && umount "${rom_dir}"
find ${rom_dir} -type l -exec rm {} \;
[ -d "${lower_dir}" ] && rm -rf "${lower_dir}"

# create lowerdir on volatile
[ ! -d "${lower_dir}" ] && mkdir -p "${lower_dir}"
[ -f "${tmp_dir}/psxCleanup" ] && rm -rf "${tmp_dir}/psxCleanup"

# find all PSX games and link them to ES rom folder
find "$original_games" "$custom_games" -maxdepth 2 -regex ".*\.\(cue\|m3u\|bin\|pbp\|chd\|iso\)" | while IFS= read -r game_file; do
  file_name="${game_file##*/}"
  game_title=${file_name%.*}
  ext=${game_file##*.}
  game_path="${game_file%/*}"
  initial_cleanup="${game_title%%(*}"
  disc_rm="${initial_cleanup%%Disc*}"

  [ ! -f "${lower_dir}/${file_name}" ] && ln -s "$game_file" "$lower_dir"


  if [ "${ext}" == "m3u" ]; then
    echo "${disc_rm}" >>"${tmp_dir}/psxCleanup"
    rm "${lower_dir}/${file_name}"
    find "${game_path}" -name "*.cue" | while IFS= read -r cue_file; do
      echo "../../games/${game_path##*/}/${cue_file##*/}" >>"${lower_dir}/${file_name}"
    done
  fi
done

# Load playlists for multidisc original games
for g in "${game_ids[@]}"; do
  find "$lower_dir" -name "${g}.*" -exec rm {} +
done

if [[ "${western_psc[@]}" =~ "$psc_region" ]]; then
  ln -s "${original_m3u}/SLUS-00594.m3u" "${lower_dir}"
  ln -s "${original_m3u}/SCUS-94163.m3u" "${lower_dir}"
else
  ln -s "${original_m3u}/SLPS-01230.m3u" "${lower_dir}"
  ln -s "${original_m3u}/SLPS-01057.m3u" "${lower_dir}"
  ln -s "${original_m3u}/SLPM-86114.m3u" "${lower_dir}"
fi

while IFS= read -r game; do
  find "${lower_dir}" \( -name "${game}*.cue" -o -name "${game}*.bin" \) -exec rm {} +
done <"${tmp_dir}/psxCleanup"

# mount volume
mount -t overlay -o lowerdir="${rom_dir}":"${lower_dir}" "overlay-PSX2ES-media" "${rom_dir}"
# EOF
