# ES Rally for openFDA

Rally is a benchmarking tool for [Elasticsearch](https://www.elastic.co/elasticsearch/).  In this project, we have implemented a Dockerized system which launches Rally and Elasticsearch in two separate containers on the same Docker network, in order for Rally to do benchmarking on Elasticsearch.

This tool is meant to be used for development of the benchmarking tests only.  It is commonly advised that one should do actual benchmarking measurements on bare-metal machines, rather than in virtual machines or in Docker containers.  Once the benchmarking tests are developed and running properly in this Dockerized system, they should be ported to bare-metal machines.

This setup is based on the [multi-container Docker system](https://github.com/elastic/rally/tree/master/docker) created by the Rally maintainers, but modified for use with the internal Elasticsearch container used in an [openFDA](https://github.com/FDA/openfda) system.

<!-- ABOUT THE PROJECT -->
## About The Project

Elasticsearch is an indexing and search engine which is highly configurable.  The speed and performance of searches in Elasticsearch is dependent on the configuration of the indexing and the data which has been indexed.  The performance of an Elasticsearch cluster is not easy to predict analytically.  Hence, in order to optimize the performance of Elasticsearch, benchmarking tests should be done against various configurations in order to help determine the optimal configuration for a given purpose.

This project was inspired by a need to discover the best Elasticsearch configuration for use by the openFDA project.

Currently, this project is configured (in the [docker compose file](docker-compose.yaml)) to run Elasticsearch version 7.14.1, consistent with the version currently used by openFDA. 


### Dependencies

* [Docker](https://www.docker.com/) - Everything runs inside Docker containers.
* [Camden Demo](https://github.com/RIKnight/camden_demo) - An example track based on data from Camden Council.
* [openFDA Testing](https://github.com/RIKnight/openfda_testing) - A track which can be used for testing the connection between Rally and the openFDA Elasticsearch container.


<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple steps.

### Prerequisites

Install Docker on your system.  


### Installation

Copy this repository to your local system.  Then, from the root directory of the repository, build the Rally Docker image using the [shortcut script](newbuild.sh):

```sh
./newbuild.sh
```
This will build (or completely re-build) the image and give it the name `openfda_rally`.

This should be done prior to running the `docker compose up` command which launches the whole system.

### Starting the containers

There is a command contained in the [docker compose](docker-compose.yaml) file which determines which `esrally` command to run upon startup of the `openfda_rally` container.  To run the system, only one of these commands should be active (not commented out).

Start the system with:

```sh
docker compose up
```

This will create the Docker containers, network, and volumes.  To close the system, first break with control-c, then run

```sh
docker compose down
```

That will remove the Docker containers and network, but not the volumes.


### Interacting via the command line

Once the docker volumes have been created and data has been inserted into them by the first `docker compose` run, it is possible to run each of the containers in the system with their same volumes, and examine their contents.  

Included are two shortcut scripts to interactively run the Elasticsearch and Rally containers (separately) in a bash shell.

To run the Rally container in an interactive bash shell, run the provided [script](runrally.sh), which will open a bash shell in an `openfda_rally` container:

```sh
./runrally.sh
```

From within the container, commands such as `esrally list track`, for listing the known tracks, can be executed.

Similarly, the Elasticsearch container can be run with the [script](runelasticsearch.sh):


```sh
./runelasticsearch.sh
```


<!-- Benchmarking -->
## Benchmarking

### About Rally Pipelines

In Rally, a construct called a [pipeline](https://esrally.readthedocs.io/en/stable/pipelines.html) is used to control what steps are performed before and after a benchmarking exercise.  In this project, we intend to use the `benchmark-only` pipeline, which omits the steps before and after benchmarking.  This was chosen due to the complex nature of the openFDA Elasticsearch indexing.  

To use this setup, the openFDA system under study must be configured to store Elasticsearch data on a Docker volume which can be shared with this benchmarking system.  In order to do so, the `docker-compose.yaml` files which set up both the openfda_rally system and the openFDA system itself should be modified to use named Docker volumes, and have the names match each other.  There is an included [docker-compose.yml](openfda/docker-compose.yml) file in this repo which can be used for configuring openFDA this way.  Note that the volume name (openfda_esdata) is the same name used in this project's [docker-compose.yaml](docker-compose.yaml) file.

### Default Example Track:  Camden Council Demo

In Rally, tracks are stored as git repositories, in order to help promote compatibility across different versions of Elasticsearch.  To be conistent with this framework, the example track used by default in this system is stored in a different repository.  See the [Camden Demo](https://github.com/RIKnight/camden_demo.git) repo for more information.

There are two different Rally "challenges" stored in this demo track.  To select which one runs, uncomment the appropriate line in this repo's [docker compose](docker-compose.yaml) file.


### Developing new Tracks

New tracks under development can be placed in subdirectories of the `tracks` directory.
See the `camden_demo` references throughout the files in this repo and the Camden Demo Track repo for an example of how to set this up.

When a change has been made to the track under development, it will need to be copied to a docker volume in order to be used.  First remove the old volumes, e.g.:

```sh
docker volume prune
```

Then rebuild the `openfda_rally` image, which will copy the track to a temporary location in the Docker image.  Running `docker compose up` will start a container which will put the files into the correct location on the Docker volume. 


### Benchmarking with openFDA data

This sytem runs Rally using the `benchmark-only` pipeline, and relies on a different system (openFDA) to index and populate an Elasticsearch data store with data, prior to running the Rally tracks (see above).  Once a Docker volume has been created, and data has been indexed and inserted, the volume can be used with this system to do Elasticsearch benchmarking.


## Retrieving Rally Race Results

After a Rally race, a summary of the race results are printed to the terminal which launched the race.  Furthermore, the full results of the benchmarking track are stored in the Docker volume which was used when running the Rally race, in `json` format.  After the race has completed, the Docker container will stop running.  A new container can be started which uses the same Docker volume using the script `runrally.sh`.  This script will run an interactive bash shell in a container which has access to the volume, and will be capable of reading the race results.


<!-- PROJECT ORGANIZATION -->
## Project Organization


    ├── LICENSE
    ├── README.md            <- The top-level README for developers using this project.
    │
    ├── docker-compose.yaml  <- A docker compose file, for launching the system
    │
    ├── Dockerfile           <- A Dockerfile for builiding the openfda_rally Docker image
    │
    ├── entrypoint.sh        <- A shell script which is run by the container when it starts up
    │
    ├── newbuild.sh          <- A convenience script for re-building the openfda_rally Docker image.
    |                           This is useful when developing new tracks in the tracks/<new_track> directory.
    │
    ├── rally.ini            <- An initialization file for rally.  Currently, this file is not used.
    |                           It is included here only as a placeholder for future development.
    │
    ├── runelasticsearch.sh  <- A convenience script for starting an interactive shell in an elasticsearch container after initialization.
    |                           Note that the entrypoint is /bin/bash rather than the usual startup script.
    │
    ├── runrally.sh          <- A convenience script for starting an interactive shell in an openfda_rally container after initialization.
    |                           Note that the entrypoint is /bin/bash rather than the usual startup script.
    |
    ├── openfda              <- A directory for example openFDA files.
    │    └──  docker-compose.yml <- A sample compose file for openFDA. 
    │
    └── tracks               <- A directory for developing new tracks.  
                                New tracks should be placed inside of a subdirectory of this folder.


<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

Project based on Rally's own [multi-container Docker system](https://github.com/elastic/rally/tree/master/docker).


