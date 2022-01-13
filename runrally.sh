#! /bin/bash
# run this after the volume has been created and initialized
#
docker run --rm -it --entrypoint /bin/bash --volume rally_data:/rally/.rally openfda_rally
