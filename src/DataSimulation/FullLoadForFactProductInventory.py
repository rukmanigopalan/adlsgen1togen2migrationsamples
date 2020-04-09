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
DataSetSize = 32650;
SeriesSize = 50;
DateID = 0;
uniqueIdentifier = 1;

NumberOfYears = 1;
StartDate = 8;
EndDate = NumberOfYears *283;
Fact = "FactProductInventory"
RowNumber = 1

for startdate in reversed(range(StartDate,EndDate)):
  start = EndDate-startdate
  for batch in range(0,1):
    start_time = datetime.datetime.now().time()#.strftime('%H:%M:%S')
    print("Start time",start_time)
    start_date = datetime.date.today()
    d1 = start_date.strftime("%d/%m/%Y %H:%M:%S")
    print("StartDate",start_date)
    print("Today's date",d1)
    #date_1 = datetime.datetime.strptime("01/01/2018", "%m/%d/%y")-- use hardcoded  date for generating history records
    end_date = start_date + datetime.timedelta(days=-startdate)#.strftime("%Y-%m-%d %H:%M:%S")
    print("EndDate", end_date)
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
    PreviousDateId = end_date+datetime.timedelta(days=-1)
    print("Previous Date id", PreviousDateId)
    DateId = Year+Month+Day
    DateFormat = Year+Month+Day+Hour+Min
    dbutils.fs.mkdirs(folder)
    Header= "ProductKey,MovementDate,UnitCost,UnitsIn,UnitsOut,UnitsBalance\r\n"
    with open(file,'w') as file1:
      file1.write(Header)
    print("FileWritten successfully")
    RowN =RowNumber*start
    for s in range(1,SeriesSize):#SeriesSize
      for d in range(0,DataSetSize):#DataSetSize
        DataString = DataString+ str((RowN+d)*s)+","+str(end_date)+","+str(float(randrange(1,1000)))+","+str(randrange(1,100))+","+str(randrange(1,80))+","+str(randrange(1,50))+"\r\n"
        with open(file,"a+") as f:
             f.write(DataString)
        DataString = ""
        #break
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
    FactProductInventory = spark.read.option("header", "true").csv("/"+file).drop('_c0')
    print("Writing this file",file)
    #events.coalesce(1).write.mode("overwrite").format("com.databricks.spark.csv").option("header", "true").csv(folder+file)
    print("Events count:",FactProductInventory.count())
    #MergedDataFrameWithDelete.repartition(1).write.format("csv").mode("overwrite").save(outfilename)
    csv_location = folder+'temp.folder'
    file_location = folder+file
    FactProductInventory.coalesce(1).write.csv(path=csv_location, mode="append", header="true")
    fileOutput = dbutils.fs.ls(csv_location)[-1].path
    dbutils.fs.cp(fileOutput, file_location)
    dbutils.fs.rm(csv_location, recurse=True)
    dbutils.fs.rm("/"+file)#display(events)
    print("Printed immediately.")
    #time.sleep(5*60.4)
    #print("Printed after 5 mins.")
    print("End of loop")
  print("End of loop")                                                                        
  print("End of last loop")




# COMMAND ----------

startdate = 283
start = reversed(range(283,0))
print(start)

# COMMAND ----------

# MAGIC %fs rm -r /mnt/AdventureWorksProd/Raw/FactProductInventory/2019/07/

# COMMAND ----------

