# Museum Project - Data Modeling and Process Implementation

Welcome to the repository for the Museum Project. This project consists of two major assignments:

1. **Assignment 4: Data Modeling of the Museum** 📊
2. **Assignment 5: Conceptual Changes and Process Implementation on the Database Layer** 🔄

## Overview

### Assignment 4: Data Modeling

In this assignment, we focused on the data modeling of the museum. This includes creating the structure for all necessary entities and their relationships. The data modeling captures all the essential aspects of a museum, such as exhibits, artifacts, zones, and more.

### Assignment 5: Conceptual Changes and Process Implementation

This assignment involves making some conceptual changes and mainly focuses on implementing various processes on the database layer. These processes ensure the smooth operation and management of the museum's data.

## Files Included

- **museum.sql**: Contains the Data Definition Language (DDL) statements for setting up the database schema.
- **scenarios.sql**: Contains the implemented processes, defined as stored procedures and functions.

## Implemented Processes

### 5.1. Planning an Exhibition

When planning an exhibition, a new record is created in the `Exposition` table. Date validations are performed if provided. A new `ExpositionState` is created. New records are added to the `ExhibitedInformation` table with assigned zone and exposition IDs. The database allows creating an exposition without pre-known dates. During planning, all scenarios are validated using the `check_exposition_overlap()` function. The exposition status is set to `PLANNED`.

### 5.2. Inserting a New Specimen

When inserting a new specimen, all mandatory and optional attributes of the `Exemplar` entity are initialized. A record is created in the `ExemplarOwnership` table with the assigned ID of our institution (assuming the museum record is statically created during database initialization) and the specimen. If the specimen is owned by multiple institutions, the corresponding number of records is created. If the specimen has a category, a category record is created or an existing category is used. A relationship between the category and the specimen is established in the `ExemplarCategory` table. A record in the `ExemplarState` table is created with `locationStatus` set to `IN_STORAGE` and assigned the specimen ID.

### 5.3. Moving a Specimen to Another Zone

Moving a specimen to another zone involves the following steps:
1. Ensure exhibitions exist; if not, create them using the steps for planning an exhibition.
2. Check if the zone, specimen, and exhibition exist. If the specimen is in storage or vault, the previous status is closed, and a new record in the `ExemplarState` table with `locationStatus` set to `WITHIN_MUSEUM` is created. When the specimen reaches its place in the zone, the previous status is closed, and a new status `EXHIBITED` is created. If the `ExhibitedInformation` record does not yet contain the specimen, the specimen ID is assigned; otherwise, a new record is created. If the specimen is already exhibited, the status is set to `WITHIN_MUSEUM`, and in the `ExhibitedInformation` list, the transfer date is set, a new `ExhibitedInformation` record with the new zone is created, and the status is set to `EXHIBITED`.

### 5.4. Receiving a Specimen from Another Institution

When receiving a specimen from another institution, simulated data with the entire historical process of transferring the specimen to another institution and back to our institution are created. The last status of the specimen is `IN_TRANSIT`. The receiving process involves checking if the specimen exists, closing the previous state, creating a new record with `locationStatus` set to `IN_STORAGE`, and assigning the specimen ID.

### 5.5. Borrowing a Specimen from Another Institution

This process requires information about the specimen, initializing attributes when creating the `Exemplar` entity record. The input is validated based on the unique email of the institution; if the institution does not exist, it is created. The following steps are the same as receiving and creating a specimen. The change occurs when creating a record in the `ExemplarState` table, where a record with `locationStatus` set to `BORROWED` is created and the specimen ID is assigned.

## Technical Documentation

For detailed technical documentation, please check the documentation files in the repository. Diagrams illustrating the data model are available in the `png` format within the repository.

## Author

This project is authored by [RikoAppDev](https://github.com/RikoAppDev).

## License

This project is licensed under the [MIT License](https://github.com/RikoAppDev/database-museum/blob/main/LICENSE).

Happy coding! 🚀
