# Databricks notebook source
# DBTITLE 1,Mounting ADLS Storage
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

# DBTITLE 1,Importing Libraries
import random
import time
from datetime import datetime
from random import randrange
from datetime import timedelta
from pyspark.sql.functions import lit

# COMMAND ----------


FactInternetSales = spark.read.format("csv").option("header", "true").load("/mnt/AdventureWorks/RawData/FactInternetSales.csv") #converting csv to df
print("FactInternetSales Count: ",FactInternetSales.count())

# COMMAND ----------

# DBTITLE 1,Loading all the fact tables
FactProductInventory = spark.read.format("csv").option("header", "true").load("/mnt/AdventureWorks/Raw_Data/FactFiles/FactProductInventory.csv") #converting csv to df
print("FactProductInventory Count: ",FactProductInventory.count())
FactFinance = spark.read.format("csv").option("header", "true").load("/mnt/AdventureWorks/Raw_Data/FactFiles/FactFinance.csv") #converting csv to df
print("FactFinance Count: ",FactFinance.count())

FactInternetSales = spark.read.format("csv").option("header", "true").load("/mnt/AdventureWorks/Raw_Data/FactFiles/FactInternetSales.csv") #converting csv to df
print("FactInternetSales Count: ",FactInternetSales.count())
FactInternetSalesReason = spark.read.format("csv").option("header", "true").load("/mnt/AdventureWorks/Raw_Data/FactFiles/FactInternetSalesReason.csv") #converting csv to df
print("FactInternetSales Count: ",FactInternetSales.count())
FactResellerSales = spark.read.format("csv").option("header", "true").load("/mnt/AdventureWorks/Raw_Data/FactFiles/FactResellerSales.csv") #converting csv to df
print("FactResellerSales Count: ",FactResellerSales.count())
FactSalesQuota = spark.read.format("csv").option("header", "true").load("/mnt/AdventureWorks/Raw_Data/FactFiles/FactSalesQuota.csv") #converting csv to df
print("FactSalesQuota Count: ",FactSalesQuota.count())
FactSurveyResponse = spark.read.format("csv").option("header", "true").load("/mnt/AdventureWorks/Raw_Data/FactFiles/FactSurveyResponse.csv") #converting csv to df
print("FactSurveyResponse Count: ",FactSurveyResponse.count())

FactCurrencyRate = spark.read.format("csv").option("header", "true").load("/mnt/AdventureWorks/Raw_Data/FactFiles/FactCurrencyRate.csv") #converting csv to df
print("FactCurrencyRate Count: ",FactCurrencyRate.count())

NewFactCurrencyRate = spark.read.format("csv").option("header", "true").load("/mnt/AdventureWorks/Raw_Data/FactFiles/NewFactCurrencyRate.csv") #converting csv to df
print("NewFactCurrencyRate Count: ",NewFactCurrencyRate.count())

FactCallCenter = spark.read.format("csv").option("header", "true").load("/mnt/AdventureWorks/Raw_Data/FactFiles/FactCallCenter.csv") #converting csv to df
print("FactCallCenter Count: ",FactCallCenter.count())

FactAdditionalInternationalProductDescription = spark.read.format("csv").option("header", "true").load("/mnt/AdventureWorks/Raw_Data/FactFiles/FactAdditionalInternationalProductDescription.csv") #converting csv to df
print("FactAdditionalInternationalProductDescription Count: ",FactAdditionalInternationalProductDescription.count())


# COMMAND ----------

Years = ['2019']
FactSelected = ['FactInternetSales']
count = 0
# Read one file with one MB atleast into dataframe

FolderPath  = "/mnt/AdventureWorks/RawData/History"

for Fact in FactSelected:
  for year in Years:
    for month in range(1,13):
      for day in range(1,31):
        for hour in range(0,24):
          Year = str(year)
          Month = str(format(month, '02d'))
          Day =  str(format(day, '02d'))
          Hour = str(format(hour, '02d'))
          start_time = datetime.datetime.now().time().strftime('%H:%M:%S')
          with open("/dbfs/HistoryLog_FactInternetSales.txt", 'w') as f:
            f.write(start_time + "\n")          	  
          FormatSelected = randrange(1,6)
          if(FormatSelected == 1):
            print("Selected Fact Table:", "FactInternetSales")
            folder = FolderPath + "/" + "FactInternetSales" +"/"+ Year+"/"+Month+"/"+Day
            file = folder +"/"+"FactInternetSales"+"_"+Year+Month+Day+"_"+Hour+".csv"
            FactInternetSales.write.mode("overwrite").format("com.databricks.spark.csv").option("header","true").csv(file)
            print("Selected Fact Table Format:", "FactInternetSales - csv")
            print("Selected Fact Table Count:",FactInternetSales.count())
          if(FormatSelected == 2):
            print("Selected Fact Table:", "FactInternetSales")
            folder = FolderPath + "/" + "FactInternetSales" +"/"+ Year+"/"+Month+"/"+Day
            file = folder +"/"+"FactInternetSales"+"_"+Year+Month+Day+"_"+Hour+".parquet"
            FactInternetSales.write.mode("overwrite").format("com.databricks.spark.parquet").option("header","true").parquet(file)
            print("Selected Fact Table Format:", "FactInternetSales - parquet")
            print("Selected Fact Table Count:",FactInternetSales.count())         
          if(FormatSelected == 3):
            print("Selected Fact Table:", "FactInternetSales")
            folder = FolderPath + "/" + "FactInternetSales" +"/"+ Year+"/"+Month+"/"+Day
            file = folder +"/"+"FactInternetSales"+"_"+Year+Month+Day+"_"+Hour+".avro"
            FactInternetSales.write.mode("overwrite").format("avro").option("header","true").save(file)
            print("Selected Fact Table Format:", "FactInternetSales - avro")
            print("Selected Fact Table Count:",FactInternetSales.count())
          if(FormatSelected == 4):
            print("Selected Fact Table:", "FactInternetSales")         
            folder = FolderPath + "/" + "FactInternetSales" +"/"+ Year+"/"+Month+"/"+Day
            file = folder +"/"+"FactInternetSales"+"_"+Year+Month+Day+"_"+Hour+".json"
            FactInternetSales.write.mode("overwrite").format("com.databricks.spark.json").option("header","true").json(file)
            print("Selected Fact Table Format:", "FactInternetSales - json")
            print("Selected Fact Table Count:",FactInternetSales.count())
            #with open("/dbfs/HistoryLog_FactInternetSales.txt", 'w') as f:
              #f.write("Selected Fact Table:FactInternetSales\n")
              #f.write("Selected Fact Table Format: FactInternetSales - json\n")
              #f.write("Selected Fact Table count:")
              #f.write(str(FactInternetSales.count()) +"\n") 
          if(FormatSelected == 5):
            print("Selected Fact Table:", "FactInternetSales")         
            folder = FolderPath + "/" + "FactInternetSales" +"/"+ Year+"/"+Month+"/"+Day
            file = folder +"/"+"FactInternetSales"+"_"+Year+Month+Day+"_"+Hour+".orc"
            FactInternetSales.write.mode("overwrite").format("orc").option("header","true").save(file)
            print("Selected Fact Table Format:", "FactInternetSales - orc")
            print("Selected Fact Table Count:",FactInternetSales.count())
          with open("/dbfs/HistoryLog_FactInternetSales.txt", 'w') as f:
            f.write("Selected Fact Table:FactInternetSales\n")
            f.write("Selected Fact Table count:")
            f.write(str(FactInternetSales.count()) +"\n")
            endtime= datetime.datetime.now().time().strftime('%H:%M:%S')
            f.write("Endtime\n")
            f.write(str(endtime))
          print("End of Hour loop")
        print("End of Day loop")
      print("End of Month loop")
    print("End of Year loop")
  print("End of Fact loop")
            

# COMMAND ----------

#Readigng the parquet data externally by dataframe at hive location and displaying the records
hivedata = spark.read.format("csv").option("header", "true").load("/mnt/AdventureWorks/RawData/History/FactInternetSales/2019/01/01/FactProductInventory_20190101_19.csv") #converting csv to df
print("hivedata Count: ",hivedata.count())
#display(hivedata)
#/Migration/RAW/FactProductInventory.csv
#/Migration/RAW/Incremental/FactProductIncrementalSample_1Million.csv