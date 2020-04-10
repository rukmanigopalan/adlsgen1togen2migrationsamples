# Databricks notebook source
# DBTITLE 1,Mount ADLS Storage
#Mounting ADLS Storage
configs = {"dfs.adls.oauth2.access.token.provider.type": "ClientCredential",
           "dfs.adls.oauth2.client.id": dbutils.secrets.get(scope = "Gen2migrationSP", key = "SPNId"), 
           "dfs.adls.oauth2.credential": dbutils.secrets.get(scope = "Gen2migrationSP", key = "SPNSecret"), 
           "dfs.adls.oauth2.refresh.url": "https://login.microsoftonline.com/72f988bf-86f1-41af-91ab-2d7cd011db47/oauth2/token"}

mountName = 'AdventureWorks'

mounts = [str(i) for i in dbutils.fs.ls('/mnt/')]
if "FileInfo(path='dbfs:/mnt/" +mountName + "/', name='" +mountName + "/', size=0)" in mounts: 
  dbutils.fs.unmount("/mnt/AdventureWorks/") 


print("Mounting the data lake file system")
dbutils.fs.mount(
  source = "adl://sourcedatalakestoregen1.azuredatalakestore.net/AdventureWorks", 
  mount_point = "/mnt/AdventureWorks/",extra_configs = configs)

# COMMAND ----------

# DBTITLE 1,Mounting to another ADLS Account 
#Mounting ADLS Storage
configs = {"dfs.adls.oauth2.access.token.provider.type": "ClientCredential",
           "dfs.adls.oauth2.client.id": dbutils.secrets.get(scope = "Gen2migrationSP", key = "SPNId"), 
           "dfs.adls.oauth2.credential": dbutils.secrets.get(scope = "Gen2migrationSP", key = "SPNSecret"), 
           "dfs.adls.oauth2.refresh.url": "https://login.microsoftonline.com/72f988bf-86f1-41af-91ab-2d7cd011db47/oauth2/token"}

mountName = 'AdventureWorksProd'

mounts = [str(i) for i in dbutils.fs.ls('/mnt/')]
if "FileInfo(path='dbfs:/mnt/" +mountName + "/', name='" +mountName + "/', size=0)" in mounts: 
  dbutils.fs.unmount("/mnt/"+mountName+"/") 


print("Mounting the data lake file system")
dbutils.fs.mount(
  source = "adl://sourcedatalakestoreprod.azuredatalakestore.net/AdventureWorks", 
  mount_point = "/mnt/"+mountName+"/",extra_configs = configs)

# COMMAND ----------

import os.path
import IPython
from pyspark.sql import SQLContext
display(dbutils.fs.ls("/mnt/AdventureWorksProd/"))

# COMMAND ----------

# DBTITLE 1,Listing the mount point to Gen1
import os.path
import IPython
from pyspark.sql import SQLContext
display(dbutils.fs.ls("/mnt/AdventureWorks/"))

# COMMAND ----------

# DBTITLE 1,Mounting the Gen2 storage
mountName = 'AdventureWorksProd'
configs_Blob = {"fs.azure.account.key.destndatalakestoregen2.blob.core.windows.net": dbutils.secrets.get(scope = "Gen2migrationSP", key = "Gen2AccountKey")}

mounts = [str(i) for i in dbutils.fs.ls('/mnt/')]
if "FileInfo(path='dbfs:/mnt/" +mountName + "/', name='" +mountName + "/', size=0)" in mounts: 
  dbutils.fs.unmount("/mnt/"+mountName+"/")
  print("Mounting the storage")
  dbutils.fs.mount(
  source = "wasbs://fis@destndatalakestoregen2.blob.core.windows.net/AdventureWorks",
  mount_point = "/mnt/"+mountName+"/",
  extra_configs = configs_Blob)
  print(mountName + " got mounted")
  print("Mountpoint:", "/mnt/" +mountName + "/")

# COMMAND ----------

# DBTITLE 1,Listing the Gen2 Storage
import os.path
import IPython
from pyspark.sql import SQLContext
display(dbutils.fs.ls("/mnt/AdventureWorks/"))

# COMMAND ----------

