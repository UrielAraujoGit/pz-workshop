#!/bin/bash
set -euo pipefail
shopt -s nullglob
export LC_ALL=C

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
source ./utils/convert-to-ogg.sh

die() {
    printf '%s\n' "$*" >&2
    exit 1
}

MOD_ID="3640466271"
MOD_PATH="./../uriel_s_music/Contents/mods/truemusic_addon/common/media"

INPUT_DIR="./pz-music"
OUTPUT_DIR="$MOD_PATH/yourMusic/TCBoombox"

TCG_MUSIC_SCRIPT_TCBOOMBOX_FILE="$MOD_PATH/scripts/TCGMusicScriptTCBoombox${MOD_ID}.txt"
TCG_SOUNDS_TCBOOMBOX_FILE="$MOD_PATH/scripts/TCGSoundsTCBoombox${MOD_ID}.txt"
TCG_CONTAINERS_DISTRIBUTIONS="$MOD_PATH/lua/server/Items/TCGLoadingTCBoombox${MOD_ID}.lua"
TCG_MUSIC_DEFINITIONS_TCBOOMBOX="$MOD_PATH/lua/shared/TCGMusicDefenitionsTCBoombox${MOD_ID}.lua"

LIST_OF_SONGS="./list_of_songs.txt"

WORKSHOP_TXT="./../uriel_s_music/workshop.txt"
MOD_INFO="./../uriel_s_music/mod.info"
MOD_CONTENTS_INFO="./../uriel_s_music/Contents/mods/truemusic_addon/common/mod.info"
version_files=("$WORKSHOP_TXT" "$MOD_INFO" "$MOD_CONTENTS_INFO")

# Serialize runs and keep generated files staged until every conversion succeeds.
exec 9<.
flock -x 9
stage=$(mktemp -d ./.music-build.XXXXXXXX)
trap 'rm -rf -- "$stage"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

version=$(sed -nE "s/^title=True Music Addon ([0-9]+\\.[0-9]{2}): \\*Uriel's Music\\*\\r?$/\\1/p" "$WORKSHOP_TXT")
[[ $version =~ ^([0-9]+)\.([0-9]{2})$ ]] || die "Invalid music version in $WORKSHOP_TXT"
major=$((10#${BASH_REMATCH[1]}))
minor=$((10#${BASH_REMATCH[2]} + 1))
new_version=$(printf '%d.%02d' "$((major + minor / 100))" "$((minor % 100))")

for index in "${!version_files[@]}"; do
    version_file=${version_files[index]}
    key=name
    [[ $version_file != "$WORKSHOP_TXT" ]] || key=title
    title_prefix="$key=True Music Addon "
    title_suffix=": *Uriel's Music*"
    sed 's/\r$//' "$version_file" | grep -Fx "${title_prefix}${version}${title_suffix}" >/dev/null ||
        die "Expected music version $version in $version_file"
    sed -E "s/^(${title_prefix})${version//./\\.}(: \\*Uriel's Music\\*\\r?)$/\\1${new_version}\\2/" \
        "$version_file" > "$stage/version-$index"
done

# Existing IDs can contain accented letters. Keep IDs and artwork tied to their song names.
declare -A existing_ids=() tape_numbers=()
while IFS= read -r entry; do
    item_name=${entry%%$'\t'*}
    rest=${entry#*$'\t'}
    tape_numbers[$item_name]=${rest%%$'\t'*}
    filename=${rest#*$'\t'}
    existing_ids[$filename]=$item_name
done < <(awk '/^[[:space:]]*item Cassette/ { item = substr($2, 9) }
    /^[[:space:]]*Icon[[:space:]]*= TCTape[1-9],/ { tape = substr($3, 7, 1) }
    /^[[:space:]]*DisplayName[[:space:]]*= / {
        sub(/^[[:space:]]*DisplayName[[:space:]]*= /, "")
        sub(/,$/, "")
        printf "%s\t%s\t%s\n", item, tape, $0
    }' "$TCG_MUSIC_SCRIPT_TCBOOMBOX_FILE")

declare -A tracks=() sources=() item_names=()
for file in "$OUTPUT_DIR"/*.ogg "$INPUT_DIR"/*.flac "$INPUT_DIR"/*.mp3 "$INPUT_DIR"/*.m4a; do
    filename=${file##*/}
    filename=${filename%.*}
    case "$filename" in
        ''|*[{},=]*|*$'\n'*|*$'\r'*) die "Unsupported song filename: $file" ;;
    esac

    item_name=${existing_ids[$filename]:-${filename//[^a-zA-Z0-9]/}}
    [[ -n $item_name ]] || die "Song has no usable cassette ID: $file"
    if [[ -n ${item_names[$item_name]+exists} && ${item_names[$item_name]} != "$filename" ]]; then
        die "Cassette ID $item_name is shared by '$filename' and '${item_names[$item_name]}'"
    fi
    item_names[$item_name]=$filename
    tracks[$filename]=1
    if [[ $file == "$INPUT_DIR/"* ]]; then
        [[ -z ${sources[$filename]+exists} ]] || die "Multiple input files for '$filename'"
        sources[$filename]=$file
    fi
done

(( ${#tracks[@]} > 0 )) || die "No audio found in $INPUT_DIR or $OUTPUT_DIR"
catalog=()
declare -A listed=()
while IFS= read -r filename || [[ -n $filename ]]; do
    [[ -n $filename ]] || continue
    [[ -n ${tracks[$filename]+exists} ]] || die "Missing audio for existing song: $filename"
    [[ -z ${listed[$filename]+exists} ]] || die "Song is listed twice: $filename"
    catalog+=("$filename")
    listed[$filename]=1
done < "$LIST_OF_SONGS"

while IFS= read -r filename; do
    if [[ -z ${listed[$filename]+exists} ]]; then
        catalog+=("$filename")
    fi
done < <(printf '%s\n' "${!tracks[@]}" | sort)

mkdir -p -- "$OUTPUT_DIR"
for filename in "${!sources[@]}"; do
    output="$OUTPUT_DIR/$filename.ogg"
    if [[ ! -s $output ]]; then
        printf 'Converting: %s\n' "${sources[$filename]}"
        convertOgg "${sources[$filename]}" "$stage/audio.ogg"
        mv -fT -- "$stage/audio.ogg" "$output"
    fi
done

# Generate file TCG_MUSIC_SCRIPT_TCBOOMBOX_FILE
cat > "$stage/${TCG_MUSIC_SCRIPT_TCBOOMBOX_FILE##*/}" << 'EOF'
module Tsarcraft

{

    imports

    {

        Base

    }

    /********************Generated Music Carriers********************/

EOF

# Generate file TCG_SOUNDS_TCBOOMBOX_FILE
cat > "$stage/${TCG_SOUNDS_TCBOOMBOX_FILE##*/}" << 'EOF'
module Tsarcraft
{
EOF

# Generate file TCG_MUSIC_DEFINITIONS_TCBOOMBOX
cat > "$stage/${TCG_MUSIC_DEFINITIONS_TCBOOMBOX##*/}" << 'EOF'
require "TCMusicDefenitions"

EOF

# Generate the consolidated loot table from the same catalog as the items.
cat > "$stage/${TCG_CONTAINERS_DISTRIBUTIONS##*/}" << 'EOF'
require "Items/ProceduralDistributions"
require "Vehicles/VehicleDistributions"

local cassettes = {
EOF

: > "$stage/${LIST_OF_SONGS##*/}"
for filename in "${catalog[@]}"; do
    [[ -s "$OUTPUT_DIR/$filename.ogg" ]] || die "Empty audio file: $filename.ogg"
    item_name=${existing_ids[$filename]:-${filename//[^a-zA-Z0-9]/}}

    printf '%s\n' "$filename" >> "$stage/${LIST_OF_SONGS##*/}"
    printf '    "Cassette%s",\n' "$item_name" >> "$stage/${TCG_CONTAINERS_DISTRIBUTIONS##*/}"

    tape_number=${tape_numbers[$item_name]:-}
    if [[ -z $tape_number ]]; then
        read -r checksum _ < <(printf '%s' "$item_name" | cksum)
        tape_number=$((checksum % 9 + 1))
    fi

    cat >> "$stage/${TCG_MUSIC_SCRIPT_TCBOOMBOX_FILE##*/}" << EOF
    item Cassette$item_name
    {
        Type            = Normal,
        ItemType        = base:normal,
        DisplayCategory = True Music,
        Weight          = 0.02,
        Icon            = TCTape$tape_number,
        DisplayName     = $filename,
        WorldStaticModel = Tsarcraft.TCTape$tape_number,
    }

EOF


    # ========================================================
    # Add sound to TCGSounds
    # ========================================================

    cat >> "$stage/${TCG_SOUNDS_TCBOOMBOX_FILE##*/}" << EOF
    sound Cassette$item_name
    {

        category = Entertainment,
        master = Ambient,

        clip

        {

            file = media/yourMusic/TCBoombox/$filename.ogg,
            distanceMax = 75,

        }

    }

EOF

    # ========================================================
    # Add sound to TCGMusicDefinitions
    # ========================================================

    cat >> "$stage/${TCG_MUSIC_DEFINITIONS_TCBOOMBOX##*/}" << EOF
GlobalMusic["Cassette$item_name"] = "tsarcraft_music_01_62"
EOF

done

cat >> "$stage/${TCG_CONTAINERS_DISTRIBUTIONS##*/}" << 'EOF'
}

local containers = {
    "CrateCompactDiscs",
    "ElectronicStoreMusic",
    "MusicStoreCDs",
    "MusicStoreSpeaker",
    "GymLockers",
    "OfficeDrawers",
    "WardrobeRedneck",
    "PoliceLockers",
    "WardrobeChild",
    "Hobbies",
    "HolidayStuff",
    "BedroomDresser",
    "FactoryLockers",
    "ClosetShelfGeneric",
    "CrateRandomJunk",
    "HospitalLockers",
    "SchoolLockers",
    "LivingRoomSideTable",
    "FitnessTrainer",
    "FireDeptLockers",
    "Gifts",
    "DeskGeneric",
    "LivingRoomShelf",
    "DresserGeneric",
    "Locker",
    "SecurityLockers",
    "ShelfGeneric",
    "PoliceDesk",
}

local function addCassettes(distribution, chance)
    if not distribution or not distribution.items then
        return
    end

    for _, cassette in ipairs(cassettes) do
        table.insert(distribution.items, "Tsarcraft." .. cassette)
        table.insert(distribution.items, chance)
    end
end

for _, name in ipairs(containers) do
    addCassettes(ProceduralDistributions.list[name], 0.1)
end
addCassettes(VehicleDistributions.GloveBox, 0.2)
EOF

# Close TCG_MUSIC_SCRIPT_TCBOOMBOX_FILE
cat >> "$stage/${TCG_MUSIC_SCRIPT_TCBOOMBOX_FILE##*/}" << 'EOF'
}
EOF

# Close TCG_SOUNDS_TCBOOMBOX_FILE
cat >> "$stage/${TCG_SOUNDS_TCBOOMBOX_FILE##*/}" << 'EOF'
}
EOF

for destination in "$TCG_MUSIC_SCRIPT_TCBOOMBOX_FILE" "$TCG_SOUNDS_TCBOOMBOX_FILE" \
    "$TCG_MUSIC_DEFINITIONS_TCBOOMBOX" "$TCG_CONTAINERS_DISTRIBUTIONS" "$LIST_OF_SONGS"; do
    mv -fT -- "$stage/${destination##*/}" "$destination"
done

for index in "${!version_files[@]}"; do
    mv -fT -- "$stage/version-$index" "${version_files[index]}"
done

printf 'Generated %d songs for version %s.\n' "${#tracks[@]}" "$new_version"
