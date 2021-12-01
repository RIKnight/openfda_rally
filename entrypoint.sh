#!/usr/bin/env bash
set -Eeo pipefail

# check for test data and get it if needed
# match these values to those in camden_demo/_scripts/setup.sh
DATA_PATH=~/.rally/benchmarks/data/companies
FILENAME=documents
if [[ ! -f $DATA_PATH/$FILENAME.json ||  ! -f $DATA_PATH/$FILENAME.json.bz2 ]]; then
    echo "Test data files not found.  Starting setup script."
    mkdir -p ~/.rally/benchmarks/tracks/
    # cp -r /tracks/* ~/.rally/benchmarks/tracks/
    cd ~/.rally/benchmarks/tracks
    git clone https://github.com/RIKnight/camden_demo.git
    ~/.rally/benchmarks/tracks/camden_demo/_scripts/setup.sh
else
    echo "Test data files found."
fi

if [[ $1 == *"bash"* || $1 == *"sh"* ]]; then
    : # noop
elif [[ $1 != "esrally" ]]; then
    set -- esrally "$@"
fi

# echo "Now in entrypoint script..."
# echo "$@"
exec "$@"
