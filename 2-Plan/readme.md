As you are planning your migration, consider some of the things that worked well in Gen1. What didn't? Now is a great time to plan for some of these changes to rid the project of outstanding technical debt as possible. Below is a "Target Architecture Definition" that we have put together to help you think through some of these items:


|Design Consideration  |Options  |Questions  |
|---------|---------|---------|
|Location     |East US, West US, N Europe, etc         |What region does most of your applications that are reading/writing to the data lake originate from?          |
|Data Lake Organization     |Number of Storage Accounts, Containers, Folders         |  How are you structured today? Does data access distribute across multiple folders or do you access one folder more frequently? There are performance considerations for this.       |
|Number of Environments     | Prod, UAT, Dev        |Will you have one data lake and have different environments for compute layers? Or will each environment exist on its own?         |
|Number of Subscriptions     |         | In which subscription will you deploy the ADLS Gen2 account? Will you split the environments on different subscriptions?        |
|Redundancy Settings     |LRS, ZRS, GA-ZRS         | Is LRS (locally redundant storage) enough? Or do you need a higher level for HA/DR or compliance reasons?         |
|Firewall     | vnet        | What are the vnet considerations you should consider? Can you deploy to the same vnet as data lake gen1? Or do you need to create another? If another what type of impact does that have on differing compute applications?        |
|Policies     |         |Are there Azure Policies already enforced by the platform team? Are there policies you would like to implement at the storage account level?         |
|RBAC/ACL Strategy     |         | ACL's work slightly differently in ALDS Gen2. Read the "Gen1 and Gen2 ACL Behavior readme" for an in-depth guide        |