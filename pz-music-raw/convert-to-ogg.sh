#!/bin/bash

MOD_ID="3640466271"
MOD_PATH="./../uriel_s_music/Contents/mods/truemusic_addon/common/media"

INPUT_DIR="./pz-music"
OUTPUT_DIR="$MOD_PATH/yourMusic/TCBoombox"


TCG_MUSIC_SCRIPT_TCBBOOMBOX_FILE="$MOD_PATH/scripts/TCGMusicScriptTCBoombox${MOD_ID}.txt"
TCG_SOUNDS_TCBBOOMBOX_FILE="$MOD_PATH/scripts/TCGSoundsTCBoombox${MOD_ID}.txt"
TCG_VEHICLE_DISTRIBUTIONS="$MOD_PATH/lua/server/Items/TCGVehicleDistributions${MOD_ID}.lua"
TCG_CONTAINERS_DISTRIBUTIONS="$MOD_PATH/lua/server/Items/TCGLoadingTCBoombox${MOD_ID}.lua"
TCG_MUSIC_DEFINITIONS_TCBOOMBOX="$MOD_PATH/lua/shared/TCGMusicDefenitionsTCBoombox${MOD_ID}.lua"

LIST_OF_SONGS="./list_of_songs.txt"


WORKSHOP_TXT="./../uriel_s_music/workshop.txt"
MOD_INFO="./../uriel_s_music/mod.info"
MOD_CONTENTS_INFO="./../uriel_s_music/Contents/mods/truemusic_addon/common/mod.info"
version_files=("$WORKSHOP_TXT" "$MOD_INFO" "$MOD_CONTENTS_INFO")

CONTAINERS=("CrateCompactDiscs" "ElectronicStoreMusic" "MusicStoreCDs" "MusicStoreSpeaker" "GymLockers" "OfficeDrawers" "WardrobeRedneck" "CrateCompactDiscs" "PoliceLockers" "WardrobeChild" "Hobbies" "HolidayStuff" "BedroomDresser" "FactoryLockers" "ClosetShelfGeneric" "CrateRandomJunk" "HospitalLockers" "SchoolLockers" "LivingRoomSideTable" "FitnessTrainer" "FireDeptLockers" "Gifts" "DeskGeneric" "LivingRoomShelf" "DresserGeneric" "Locker" "SecurityLockers" "ShelfGeneric" "PoliceDesk")

mkdir -p "$OUTPUT_DIR"
mkdir -p "$(dirname "$TCG_MUSIC_SCRIPT_TCBBOOMBOX_FILE")"
mkdir -p "$(dirname "$TCG_SOUNDS_TCBBOOMBOX_FILE")"
mkdir -p "$(dirname "$TCG_VEHICLE_DISTRIBUTIONS")"
mkdir -p "$(dirname "$TCG_CONTAINERS_DISTRIBUTIONS")"
mkdir -p "$(dirname "$TCG_MUSIC_DEFINITIONS_TCBOOMBOX")"
mkdir -p "$(dirname "$LIST_OF_SONGS")"

echo "======================================"
echo " Converting music to OGG"
echo "======================================"

for i in "$INPUT_DIR"/*.flac "$INPUT_DIR"/*.mp3; do
    # Skip if no matching files exist
    [ -e "$i" ] || continue

    filename="${i%.*}"
    output="$OUTPUT_DIR/$(basename "$filename").ogg"

    # Skip if the OGG already exists
    if [ -f "$output" ]; then
        echo "Skipping: $i (already converted)"
        continue
    fi

    echo "Converting: $i -> $output"

    ffmpeg -i "$i" -vn -c:a libvorbis -q:a 8 -f ogg "$output"
done

echo ""
echo "======================================"
echo " Generating Project Zomboid script"
echo "======================================"


#NEW VERSION NUMBER


regex="True Music Addon \K[0-9]+\.[0-9]+(?=: \*Uriel's Music\*)"

version=$(grep -oP "$regex" $WORKSHOP_TXT)
IFS='.' read -r major minor <<< "$version"

if (( 10#$minor < 99 )); then
    minor=$((10#$minor + 1))
else
    major=$((10#$major + 1))
    minor=0
fi

new_version=$(printf "%d.%02d" "$major" "$minor")




for version_file in "${version_files[@]}"; do
  if [[ -f "$version_file" ]]; then
   sed -i "s/${version//./\\.}/${new_version}/g" "$version_file"

    echo "Version file updated: $new_version $version_file"
else
    echo "Version file not found: $version $version_file"
fi
done

echo ""
echo "======================================"
echo " New version $new_version"
echo "======================================"



# Generate file TCG_MUSIC_SCRIPT_TCBBOOMBOX_FILE
cat > "$TCG_MUSIC_SCRIPT_TCBBOOMBOX_FILE" << 'EOF'
module Tsarcraft

{

    imports

    {

        Base

    }

    /********************Generated Music Carriers********************/

EOF

# Generate file TCG_SOUNDS_TCBBOOMBOX_FILE
cat > "$TCG_SOUNDS_TCBBOOMBOX_FILE" << 'EOF'
module Tsarcraft
{
EOF

# Generate file TCG_MUSIC_DEFINITIONS_TCBOOMBOX
cat > "$TCG_MUSIC_DEFINITIONS_TCBOOMBOX" << 'EOF'
require "TCMusicDefenitions"

EOF

# Generate file LIST_OF_SONGS
cat > "$LIST_OF_SONGS" << 'EOF'
EOF

# Generate file TCG_VEHICLE_DISTRIBUTIONS
cat > "$TCG_VEHICLE_DISTRIBUTIONS" << 'EOF'
EOF


# Generate file TCG_CONTAINERS_DISTRIBUTIONS
cat > "$TCG_CONTAINERS_DISTRIBUTIONS" << 'EOF'
EOF

for i in "$OUTPUT_DIR"/*.ogg; do
    # Skip if no OGG files exist
    [ -e "$i" ] || continue

    filename="$(basename "$i" .ogg)"

    # Create item ID:
    # Keep only letters and numbers.
    item_name="$(echo "$filename" | sed 's/[^a-zA-Z0-9]//g')"

    # Skip files that result in an empty item name
    if [ -z "$item_name" ]; then
        echo "Skipping script entry: $filename (invalid item name)"
        continue
    fi

    # ========================================================
    # Add song to the list of songs 
    # ========================================================

    cat >> "$LIST_OF_SONGS" << EOF
$filename
EOF

    # Random number between 1 and 9
    tape_number=$(( RANDOM % 9 + 1 ))

    cat >> "$TCG_MUSIC_SCRIPT_TCBBOOMBOX_FILE" << EOF
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

    cat >> "$TCG_SOUNDS_TCBBOOMBOX_FILE" << EOF
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

    cat >> "$TCG_MUSIC_DEFINITIONS_TCBOOMBOX" << EOF
    GlobalMusic["Cassette$item_name"] = "tsarcraft_music_01_62"
EOF

    # ========================================================
    # Add chances to VehicleDistributions
    # ========================================================

    cat >> "$TCG_VEHICLE_DISTRIBUTIONS" << EOF
table.insert(VehicleDistributions.GloveBox.items, "Tsarcraft.Cassette$item_name");
table.insert(VehicleDistributions.GloveBox.items, 0.2);
EOF


    # ========================================================
    # Add chances to containers
    # ========================================================

for container in "${CONTAINERS[@]}"; do
    cat >> "$TCG_CONTAINERS_DISTRIBUTIONS" << EOF
table.insert(ProceduralDistributions.list["$container"].items, "Tsarcraft.Cassette$item_name");
table.insert(ProceduralDistributions.list["$container"].items, 0.1);
EOF
done

done

# Close TCG_MUSIC_SCRIPT_TCBBOOMBOX_FILE
cat >> "$TCG_MUSIC_SCRIPT_TCBBOOMBOX_FILE" << 'EOF'
}
EOF

# Close TCG_SOUNDS_TCBBOOMBOX_FILE
cat >> "$TCG_SOUNDS_TCBBOOMBOX_FILE" << 'EOF'
}
EOF

echo ""
echo "======================================"
echo " Done!"
echo "======================================"
echo "Music directory:"
echo "$OUTPUT_DIR"
echo ""
echo "Generated script:"
echo "$TCG_SOUNDS_TCBBOOMBOX_FILE"
echo "$TCG_VEHICLE_DISTRIBUTIONS"
echo "$TCG_MUSIC_DEFINITIONS_TCBOOMBOX"
echo "$TCG_MUSIC_SCRIPT_TCBBOOMBOX_FILE"
