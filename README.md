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
* [Camden Demo](https://github.com/RIKnight/camden_demo.git) - An example track based on data from Camden Council.


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

The Rally image will be ... (under construction)

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

Once the volumes have been created and data has been inserted into them by the first `docker compose` run, it is possible to run the container with that same volume, and examine its contents.
To do so, run the Docker container using the [provided script](runrally.sh), which will open a bash shell in an `openfda_rally` container:

```sh
./runrally.sh
```

### Interacting via the command line

In a terminal, find the docker container ID with:

```sh
docker ps
```

Look for the container ID for image `openfda_rally`.  It will look something like `788b940d8616`, for example.  To enter the container:

```sh
docker exec -it <CONTAINER ID> /bin/bash
```

From within the container, commands such as `esrally list track`, for listing the known tracks, can be executed.


## Developing new Tracks

New tracks under development can be placed in subdirectories of the `tracks` directory.
See the `camden_demo` references throughout the files in this repo and the Camden Demo Track repo for an example of how to set this up.

When a change has been made to the track under development, it will need to be copied to a docker volume in order to be used.  First remove the old volumes, e.g.:

```sh
docker volume prune
```

Then rebuild the `openfda_rally` image, which will copy the track to a temporary locaiton in the Docker image.  Running `docker compose up` will start a container which will put the files into the correct location on the Docker volume. 


## Default Example Track:  Camden Council Demo

In Rally, tracks are stored as git repositories, in order to help promote compatibility across different versions of Elasticsearch.  To be conistent with this framework, the example track used by default in this system is stored in a different repository.  See the [Camden Demo](https://github.com/RIKnight/camden_demo.git) repo for more information.

There are two different Rally "challenges" stored in this demo track.  To select which one runs, uncomment the appropriate line in this repo's [docker compose](docker-compose.yaml) file.


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
    ├── runrally.sh          <- A convenience script for starting an openfda_rally container after initialization
    │
    ├── tracks               <- A directory for developing new tracks.  
    |                           New tracks should be placed inside of a subdirectory of this folder.


<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

Project based on Rally's own [multi-container Docker system](https://github.com/elastic/rally/tree/master/docker).


