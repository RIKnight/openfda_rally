#! /bin/bash
# run this after the volume has been created and initialized
#
docker run -it --entrypoint /bin/bash --volume openfda_esdata:/usr/share/elasticsearch/data docker.elastic.co/elasticsearch/elasticsearch:7.14.1
