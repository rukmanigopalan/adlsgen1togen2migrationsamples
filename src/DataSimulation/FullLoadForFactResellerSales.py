# Databricks notebook source
#DataGen
import datetime
from datetime import timedelta, date
import random
from random import randrange
import itertools
import csv
import pandas as pd
import time

TestFolderPath  = "/mnt/AdventureWorksProd/Raw"
DataString = ""
DataSetSize = 9582; #8150
SeriesSize = 100;
DateID = 0;
uniqueIdentifier = 1;
Fact = "FactResellerSales"

NumberOfYears = 1;
StartDate = 1;
EndDate = NumberOfYears *283;
RowNumber = 100000

for startdate in reversed(range(StartDate,EndDate)):
  start = EndDate-startdate
  for batch in range(0,1):
    start_time = datetime.datetime.now().time()#.strftime('%H:%M:%S')
    print("Start time",start_time)
    start_date = datetime.date.today()
    d1 = start_date.strftime("%d/%m/%Y %H:%M:%S")
    print("StartDate",start_date)
    print("Today's date",d1)
    end_date = start_date + datetime.timedelta(days=-startdate)#.strftime("%Y-%m-%d %H:%M:%S")
    print("EndDate", end_date)
    PreviousDateId = end_date+datetime.timedelta(days=-1)
    print("Previous Date id", PreviousDateId)
    PreviousDayBeforeId = end_date+datetime.timedelta(days=-2)
    eventat = end_date.year
    Year = str(format(end_date.year, '02d'))
    Month = str(format(end_date.month, '02d'))
    Day = str(format(end_date.day, '02d'))
    Hour = str(format(start_time.hour,'02d'))
    Min = str(format(start_time.minute,'02d'))
    Batch = str(format(batch, '02d'))
    print("Hour",Hour)
    print("Min", Min)
    folder = TestFolderPath + "/" + Fact +"/"+ Year+"/"+Month+"/"+Day+"/"
    file = Fact+"_"+Year+Month+Day+"_"+Batch+"_"+Batch+".csv"
    DateId = Year+Month+Day
    DateFormat = Year+Month+Day+Hour+Min
    dbutils.fs.mkdirs(folder)
    Header= "ProductKey,ResellerKey,EmployeeKey,PromotionKey,CurrencyKey,SalesTerritoryKey,SalesOrderNumber,SalesOrderLineNumber,RevisionNumber,OrderQuantity,UnitPrice,ExtendedAmount,UnitPriceDiscountPct,DiscountAmount,ProductStandardCost,TotalProductCost,SalesAmount,TaxAmt,Freight,CarrierTrackingNumber,CustomerPONumber,OrderDate,DueDate,ShipDate\r\n"
    with open(file,'w') as file1:
      file1.write(Header)
    print("FileWritten successfully")
    RowN =RowNumber*start
    for s in range(1,SeriesSize+1):#SeriesSize
      for d in range(0,DataSetSize):#DataSetSize
        DataString =DataString + str(randrange(1,100))+","+str((RowN+d)*s)+","+str(randrange(1,100))+","+str(randrange(1,50))+","+str(randrange(1,20))+","+str(randrange(1,100))+","+str(randrange(1,1000))+","+str(randrange(1,100))+","+str(randrange(1,80))+","+str(randrange(1,20))+","+str(float(randrange(10,100)))+","+str(randrange(1,100))+","+str(float(randrange(1,10)))+","+str(float(randrange(10,100)))+","+str(randrange(1,1000))+","+str(randrange(1,1000))+","+str(randrange(1,100))+","+str(randrange(1,10))+","+str(randrange(1,10000))+","+str(randrange(1,10000))+","+str(randrange(1,1000))+","+str(PreviousDayBeforeId)+","+str(PreviousDateId)+","+str(end_date)+"\r\n"
        #print(DataString)
        with open(file,"a+") as f:
          f.write(DataString)
        DataString = ""
    print("End of  for loop")      
    with open(file) as in_file:
      lines = in_file.read().splitlines()
      stripped = [line.split(",") for line in lines]
      grouped = itertools.zip_longest(*[stripped]*1)
      
    with open(file, 'w') as out_file:
      writer = csv.writer(out_file)
      for group in grouped:
        writer.writerows(group)
    df = pd.read_csv(file,index_col=None,dtype='unicode').to_csv("/dbfs/"+file)
    FactResellerSales = spark.read.option("header", "true").csv("/"+file).drop('_c0')
    print("Writing this file",file)
    #events.coalesce(1).write.mode("overwrite").format("com.databricks.spark.csv").option("header", "true").csv(folder+file)
    print("Events count:",FactResellerSales.count())
    csv_location = folder+'temp.folder'
    file_location = folder+file
    FactResellerSales.coalesce(1).write.csv(path=csv_location, mode="append", header="true")
    fileOutput = dbutils.fs.ls(csv_location)[-1].path
    dbutils.fs.cp(fileOutput, file_location)
    dbutils.fs.rm(csv_location, recurse=True)
    dbutils.fs.rm("/"+file)#display(events)
    #print("Printed immediately.")
    #time.sleep(15*60.4)
    #print("Printed after 5 mins.")
    #print("End of loop")
    #break
  print("End of loop")
  
  print("End of last loop")


# COMMAND ----------

print("Events count:",FactResellerSales.count())

# COMMAND ----------

# MAGIC %fs rm -r /mnt/AdventureWorksProd/Raw/FactResellerSales/2019/

# COMMAND ----------


