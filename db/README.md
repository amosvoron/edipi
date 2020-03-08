# db

The EDI IPI database has 2 schemas: *dbo* and *ipi*. The *dbo* schema contains objects:

 - for EDI import, parse & raw data storage, 
 - the transaction system, 
 - the procedures and functions to support ETL process.

The *ipi* schema contains exclusively the IPI data model and related tables where target IPI data is stored.