# EDIPI

EDIPI is an ETL pipeline project that extracts textual data in EDI format from file storage into relational IPI database, processes transactions over imported data and loads transformed data into target tables of an IPI database. The ETL process is subject to EDI/IPI standard whose protocols governs the composition of data in IPI files, the definition of IPI data model, and describes the transactions over IPI data due to the daily changes which are collected, prepared, and further transmitted through EDI files by the IPI centre at SUISA. 

## Deployment

### Clone
```sh
$ git clone https://github.com/amosvoron/edipi.git
```

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


