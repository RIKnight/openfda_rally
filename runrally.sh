#! /bin/bash
# run this after the volume has been created and initialized
#
docker run -it --entrypoint /bin/bash --volume rally_rally:/rally/.rally openfda_rally
