Welcome to the scenarios readme.

This is a placeholder for scenarios, frequently asked questions, and lessons learned from customer migrations and the field.




# Frequently Asked Questions
Backup and Restore strategy 

What is the “Microsoft” recommended approach to conduct point in time backup and restore 

[ACTION] – List options (being worked on by Product Group) 

Performance improvement opportunities 

How to identify and make actionable 

[ACTION] – List recommendations for improvements on the storage account, independent of the application or workload 

Networking configuration 

Gen 1 approach may not be recommended going into Gen 2.  Need to analyze feature support for advanced networking security configuration 

For example, our recommendation on Gen 2 is to use Private Endpoints, however not all services support that option, or substantial change would be needed to applications or workloads to support this new feature 

Firewall and Access Controls 

This is related to the Networking concerns, however there is a need to understand what the implications of putting Firewalls or similar access controls (not specifically configured on the storage account itself) in place for connectivity controls. 

Service and Application Identity context 

While we recommend using managed identities within service to service communication, not all services support this.  Where is the right place to use the MSI, versus SPN, and what are the risks associated?  What is the overall strategy we need to implement which does not comprise security? 

Integration with Enterprise Scale Analytics  

How to make sure the target design on ADLS Gen2 does not collide with the Enterprise Scale Analytics framework?  

Rollback  

What can we setup to secure the migration and rollback if blockers are encountered? 