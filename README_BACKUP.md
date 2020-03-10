# EDIPI

EDIPI is an ETL pipeline project that extracts textual data in EDI format from file storage into relational IPI database, processes transactions over imported data and loads transformed data into target tables of an IPI database. The ETL process is subject to EDI/IPI standard whose protocols governs the composition of data in IPI files, the definition of IPI data model, and describes the transactions over IPI data due to the daily changes which are collected, prepared, and further transmitted through EDI files by the IPI centre at SUISA. 

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

What things you need to install the software and how to install them

```
Give examples
```

### Installation

First clone this repository.

### Clone
```sh
$ git clone https://github.com/amosvoron/edipi.git
```

### Create database

Open your SQL client application and create the EDI IPI database.

```
Most basic example of creating a database:

CREATE DATABASE db

```

And repeat

```
until finished
```

End with an example of getting some data out of the system or using it for a little demo

### Clone
```sh
$ git clone https://github.com/amosvoron/edipi.git
```

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Repository Description

```sh
- data                              # data source for ETL pipeline
| - data.7z
| |- 20130530.IPI                   # IPI EDI text file on 05/30/2013
| |- 20130531.IPI                   # IPI EDI text file on 05/31/2013
| |- 20130601.IPI                   # IPI EDI text file on 06/01/2013
| |- 20130602.IPI                   # IPI EDI text file on 06/02/2013

- db                                # IPI database
|- functions                        # database functions 
|- schemas                          # database schemas
|- stored procedures                # database stored procedures
|- tables                           # database tables
|- views                            # database views

- docs
|- Conceptual_Data_Model.pdf        # data model of the IPI database
|- DFD_EDI.pdf                      # description of the EDI protocol for the IPI system
|- EDI_Examples.pdf                 # examples of the EDI protocol for the IPI system

- create-db.sql                     # SQL script to create all SQL objects with default data
- README.md                         # README file
- LICENCE.md                        # LICENCE file
```

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc
