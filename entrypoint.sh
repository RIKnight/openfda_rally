#!/usr/bin/env bash
set -Eeo pipefail

# prepare tracks directory
TRACKS_DIR=~/.rally/benchmarks/tracks
mkdir -p "$TRACKS_DIR"
cd "$TRACKS_DIR"
        
if [[ "$*" =~ "camden_demo" ]]; then
    echo "camden_demo repository selected"
    # check for test data and get it if needed
    # match these values to those in camden_demo/_scripts/setup.sh
    DATA_PATH=~/.rally/benchmarks/data/companies
    FILENAME=documents
    if [[ ! -f $DATA_PATH/$FILENAME.json ||  ! -f $DATA_PATH/$FILENAME.json.bz2 ]]; then
        echo "Test data files not found.  Starting setup script."
        git clone https://github.com/RIKnight/camden_demo.git
        ~/.rally/benchmarks/tracks/camden_demo/_scripts/setup.sh
    else
        echo "Test data files found."
    fi
elif [[ "$*" =~ "openfda_testing" ]]; then
    echo "openfda_testing repository selected"
    if [[ ! -f "openfda_testing" ]]; then
        git clone https://github.com/RIKnight/openfda_testing.git
    fi
else
    # copy local tracks
    echo "Copying local tracks..."
    cp -r /tracks/* "$TRACKS_DIR"/
fi

if [[ $1 == *"bash"* || $1 == *"sh"* ]]; then
    : # noop
elif [[ $1 != "esrally" ]]; then
    set -- esrally "$@"
fi

# echo "Now in entrypoint script..."
# echo "$@"
exec "$@"
