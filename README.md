# EDIPI

EDIPI is an ETL pipeline project that extracts textual data in EDI format from file storage into relational IPI database, processes transactions over imported data and loads transformed data into target tables of an IPI database. The ETL process is subject to EDI/IPI standard whose protocols governs the composition of data in IPI files, the definition of IPI data model, and describes the transactions over IPI data due to the daily changes which are collected, prepared, and further transmitted through EDI files by the IPI centre at SUISA. 

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

 - A compatible Windows OS
 - SQL Server 2012 or later
     + [SQL Server installation guide](https://docs.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server?view=sql-server-ver15)
 - SQL Server Management Studio or compatible SQL client for SQL Server
     + [Download SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver15)


### Installation

First clone this repository into your local environment.

### Clone
```sh
$ git clone https://github.com/amosvoron/edipi.git
```

### Create database

Open your SQL client application, connect to the server and create a database.

```
CREATE DATABASE Edipi
```

You can find more information about creating an SQL Server database [here](https://docs.microsoft.com/en-us/sql/t-sql/statements/create-database-transact-sql?view=sql-server-ver15).

### Run create-db.sql script

Open the **create-db.sql** script that you find in the repository's root. Make sure that you choose newly created Edipi database by:

```
USE Edipi
```

Now run the script which creates all SQL objects and inserts default data.

### Choose file store and copy files

Choose a directory where the EDI files for ETL import will be stored. Then copy the files from the */data directory* of this repository to the chosen file store.

### Initialize database

Execute procedure **dbo.InitializeDatabase** by:

```
EXEC dbo.InitializeDatabase '<path-to-your-file-store>', '20130530.IPI'
```

The initialization makes two initial inserts into *dbo.File* table and *dbo.Config* table.

## Running the tests

Explain how to run the automated tests for this system

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

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments


