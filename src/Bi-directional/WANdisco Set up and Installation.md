WANdisco Fusion Set up and Installation Guide
===================================================

## Overview

This quickstart will help in setting up the Azure Linux Virtual Machine (VM) suitable for the WANdisco Fusion installation. Below will be covered:

  *  Azure Linux Virtual Machine (VM) creation using Azure Portal
  
  *  Configuration set up and Installation guide for WANdisco Fusion 
  
## Table of contents
   
 <!--ts-->
   * [Overview](#overview)
   * [Prerequisites](#prerequisites)
   * [Azure Linux Virtual Machine Creation](#azure-linux-virtual-machine-creation)
   * [Virtual Machine Connection set up](#virtual-machine-connection-set-up)
      * [Create an SSH connection with the VM](#create-an-ssh-connection-with-the-vm)
      * [Connect to VM](#connect-to-vm)
   * [WANdisco Fusion Set up](#wandisco-fusion-set-up)
   * [ADLS Gen1 and Gen2 Configuration](#adls-gen1-and-gen2-configuration)
      * [ADLS Gen1 storage Configuration](#adls-gen1-storage-configuration)
      * [ADLS Gen2 storage Configuration](#adls-gen2-storage-configuration)
   * [Reach out to us](#reach-out-to-us)
   * [References](#references)
 <!--te-->
 
## Prerequisites
 
 * **Active Azure Subscription**

 * **Azure Data Lake Storage Gen1**

 * **Azure Data Lake Storage Gen2**. For more details please refer to [create azure storage account](https://docs.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal) 

 * **Windows SSH client** like [Putty](https://www.putty.org/), [Git for Windows](https://gitforwindows.org/), [Cygwin](https://cygwin.com/), [MobaXterm](https://mobaxterm.mobatek.net/)


## Azure Linux Virtual Machine Creation 

  1. Go To **Azure Portal Home page**
  
  2. **Click** on  **+ Create a resource**
  
  3. Search for **Ubuntu Server**. Select **Ubuntu Server 16.04 LTS**.
  
  4. **Click** on **Create**
  
  5. In the **Basics** tab, under **Project details**, make sure the correct subscription is selected and then choose existing Resource   group or **Create new** one.
  
  ![image](https://user-images.githubusercontent.com/62353482/80261884-9b509580-8640-11ea-9b4e-b4e909ce76ca.png)
  
  6. Under **Instance details**, type any name for the Virtual machine name, choose East US for your Region, and choose Ubuntu 18.04 LTS   for Image. Leave the other defaults.
  
  ![image](https://user-images.githubusercontent.com/62353482/80262349-0189e800-8642-11ea-84a5-954f74bc7b2c.png)
  
  7. Under **Administrator account**, select **SSH public key** or **password**. Fill the details as required. Under **Inbound port rules** > **Public inbound ports**, choose **Allow selected ports** and then select **SSH (22)** and **HTTP (80)** from the drop-down.
  
  ![image](https://user-images.githubusercontent.com/62353482/80262658-000cef80-8643-11ea-9007-462dc366e2d3.png)

  8. Leave the defaults under **Disks**, **Networking**, **Management** . In the **Advanced** tab under **Cloud init** text field, paste the [cloud init](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/blob/master/src/Bi-directional/cloud-init.txt) content. 
  
  
  ![image](https://user-images.githubusercontent.com/62353482/80263267-f2586980-8644-11ea-86b8-4b1714779948.png)
  
  9. Leave the remaining defaults and then select the **Review + create** button at the bottom of the page.

 10. On the Create a virtual machine page, you can see the details about the VM you are about to create. When you are ready, select         **Create**.
 
## Virtual Machine Connection set up
 
### Create an SSH connection with the VM.

 1. Select the **Connect** button on the overview page for your VM.
 
 ![image](https://user-images.githubusercontent.com/62353482/80268818-407a6680-865f-11ea-818f-3d4dca06ed00.png)

 2. Go to **Networking** under **Settings**. 
 
 ![image](https://user-images.githubusercontent.com/62353482/80269030-1f1a7a00-8661-11ea-925f-2beb8cca0d2a.png)

3. Click on **Add inbound port rule**.

 ![image](https://user-images.githubusercontent.com/62353482/80269048-47a27400-8661-11ea-8aa6-cc65d19bc8ad.png)

4. Select **Source** as **IP addresses** from the drop down. Provide your [source ip](https://whatismyipaddress.com/) address in **Source IP addresses/CIDR ranges**. Provide list of port ranges as **22,8081,8083,8084** in the **Destination port ranges** field. Choose **TCP** under **Protocol**. Give any **Name**
 
 ![image](https://user-images.githubusercontent.com/62353482/80269123-bd0e4480-8661-11ea-8c92-d8923aaaa324.png)
 
 5. Click on **Add** button.
 
### Connect to VM
 
 To connect to the VM created above, you need a secure shell protocol (SSH) client like [Putty](https://www.putty.org/), [Git for Windows](https://gitforwindows.org/), [Cygwin](https://cygwin.com/), [MobaXterm](https://mobaxterm.mobatek.net/)
 
 1. Start the VM if it isn't already running. Under **Overview** configure the DNSname dynamic and set DNS name.
 
 ![image](https://user-images.githubusercontent.com/62353482/80270761-ca323000-866f-11ea-94bf-20e02133bb11.png)

The above DNS name can be used to login into SSH client.

2. Open the SSH client (Putty , Git , Cygwin, MobaXterm). 

 :bulb: Note : Here we will be using MobaXterm.

 Go to **Session** ---> **Click** on **SSH** 
 
 ![image](https://user-images.githubusercontent.com/62353482/80332096-b406aa00-87fe-11ea-9ebc-4a5c4a757833.png)

3. Provide the DNSname into the **Remote host** field along with username defined for SSH client while creating VM.

 ![image](https://user-images.githubusercontent.com/62353482/80333937-86bcfa80-8804-11ea-93ca-cefb660789f2.png)
 
4. Click **OK**

5. Provide the password for SSH client.

![image](https://user-images.githubusercontent.com/62353482/80334350-d18b4200-8805-11ea-881c-866858a255c4.png)


### WANdisco Fusion Set up

1. Clone the Fusion docker repository using below command in SSH Client:

```scala
  git clone https://github.com/WANdisco/fusion-docker-compose.git
  ```
2. Change to the repository directory:

 ```scala  
    cd fusion-docker-compose
```
3. Run the setup script:

 ```scala   
    ./setup-env.sh
 ```
 4. Enter the option **4** for **Custom deployment**
 
 ![image](https://user-images.githubusercontent.com/62353482/80396711-e6012600-8869-11ea-8161-cfbcc25c3170.png)

5. Enter the first zone type as **adls1**

6. Set the first zone name as [adls1] . Hit enter at the prompt.

7. Enter the second zone type as **adls2**

8. Set the second zone name as [adls2]. Hit **enter** key at the prompt.

9. Enter your license file path. Hit **enter** key at the prompt.

10. Enter the docker hostname. Hit **enter** key at the prompt for setting default name.

11. Enter the HDI version for adls1 as **3.6**

12. Enter HDI version for adls2 as **4.0** . Hit **enter** key for rest prompts

13. The docker set up is complete.

 ![image](https://user-images.githubusercontent.com/62353482/80404559-38e0da80-8876-11ea-9cc4-22314a46fedc.png)

14. To start the Fusion run the below command:

```scala

  docker-compose up -d

```

![image](https://user-images.githubusercontent.com/62353482/80407953-4ba9de00-887b-11ea-97a5-2baa8683943d.png)


## ADLS Gen1 and Gen2 Configuration

### ADLS Gen1 storage Configuration
 
 1. Log in to Fusion via a web browser.
 
    Enter the address in the form of: http://{dnsname}:8081
 
   ![image](https://user-images.githubusercontent.com/62353482/80413692-b7dd0f80-8884-11ea-82d0-9925706b4522.png)
   
  **Note**: Get the DNS name from portal **-->** Go to Virtual machine **-->** Overview **-->** DNS name 
   
 2. Create account and login to the Fusion.
 
 3. Click on settings icon for the adls1 storage. Select the ADLS Gen1 storage type
 
 4. Enter the details for the ADLS Gen1 storage account
 
 ![image](https://user-images.githubusercontent.com/62353482/80416242-a8f85c00-8888-11ea-851c-d23f38749d56.png)
 
 **ADLS Gen1 storage account details**:

   * Hostname / Endpoint (Example: <account-name>.azuredatalakestore.net)
 
   * Home Mount Point / Directory (Example: / or /path/to/mountpoint)
     **Note**: Fusion will be able to read and write to everything contained within the Mount Point.
     
   * Client ID / Application ID (Example: a73t6742-2e93-45ty-bd6d-4a8art6578ip)
   
   * Refresh URL (Example: https://login.microsoftonline.com/<tenant-id>/oauth2/token)

   * Handshake User / Service principal name (Example: fusion-app)
   
   * ADL credential / Application secret (Example: 8A767YUIa900IuaDEF786DTY67t-u=:])
   
  5. Click on **APPLY CONFIGURATION**
  
### ADLS Gen2 storage Configuration

  1. Click on settings icon for the adls2 storage. Select the ADLS Gen2 storage type
  
  2. Enter the details for the ADLS Gen2 storage account
  
   ![image](https://user-images.githubusercontent.com/62353482/80425042-c1bc3e00-8897-11ea-96b8-891c6e739935.png)

   
  **ADLS Gen2 storage account details**:
   
   * Account name (Example: adlsg2storage)
   
   * Container name (Example: fusionreplication)
   
   * Access key (Example: eTFdESnXOuG2qoUrqlDyCL+e6456789opasweghtfFMKAHjJg5JkCG8t1h2U1BzXvBwtYfoj5nZaDF87UK09po==)
   
   3. Click on **APPLY CONFIGURATION**
   
   
## Reach out to us

**You found a bug or want to propose a feature?**

File an issue here on GitHub: [![File an issue](https://img.shields.io/badge/-Create%20Issue-6cc644.svg?logo=github&maxAge=31557600)](https://github.com/rukmani-msft/adlsgen1togen2migrationsamples/issues/new).
Make sure to remove any credential from your code before sharing it.

   
## References

   * :link: [ WANdisco fusion Installation and set up guide ](https://wandisco.github.io/wandisco-documentation/docs/quickstarts/preparation/azure_vm_creation)
   
   * :link: [How to use SSH key with Windows on Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/ssh-from-windows)   
