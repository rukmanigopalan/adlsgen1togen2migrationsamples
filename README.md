## Azure data lake storage Gen1 to Gen2 Migration sample

Welcome to the documentation on migration from Gen1 to Gen2. Please review the [Gen1-Gen2 Migration Approach guide](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-migrate-gen1-to-gen2) to understand the patterns and approach. You can choose one of these patterns, combine them together, or design a custom pattern of your own.

Storage migration projects are similar to other technology projects and should follow a general pattern:

Assess -> Plan -> Migrate -> Validate

We have visually represented this in a Mindmap hosted on Mindmeister. This starts at a very high level and demonstrates where to start and what to consider. Most of the material covered is covered more in-depth in other parts of this repo. This is to allow yourself to become familiar with the high-level concepts and the "general flow" quickly.

[![MindtreeMap](/images/MindmapImage.jpg)](https://mm.tt/1857393315?t=a4ffTlBIX6)

This repo is a collection of tools and resources from Microsoft to assist you with migrating your data lake gen1 account to gen2. It is a collection of tools, sample scripts, and learnings that can be used to assist you with your own migration project. 

You will find here resources to help with planning, migrating, and validating. When migrating the data there are multiple patterns:

1. **Incremental copy pattern** using **Azure data factory**

   Refer [Incremental copy pattern guide](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/Incremental/README.md) to know more and get started.

2. **Bi-directional sync pattern** using **WANdisco Fusion**

   Refer [Bi-directional sync pattern guide](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/Bi-directional/README.md) to know more and get started.
   
3. **Lift and Shift pattern** using **Azure data factory**

   Refer [Lift and Shift pattern guide](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/Lift%20and%20Shift/README.md) to know more and get started.
   
4. **Dual Pipeline pattern** 

   Refer [Dual pipeline pattern guide](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/Dual%20pipeline/README.md) to know more and get started.

### How to migrate the workloads and Applications post data migration

   Refer [here](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/tree/master/src/Application%20Update) for more details on the steps to update the workloads and application post migration.
   
## References

* [Azure Data Lake Storage migration from Gen1 to Gen2 ](https://docs.microsoft.com/en-us/azure/storage/blobs/data-lake-storage-migrate-gen1-to-gen2)

* [Why WANdisco fusion](https://docs.wandisco.com/bigdata/wdfusion/adls/)

