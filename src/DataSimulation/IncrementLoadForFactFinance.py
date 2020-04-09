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
DataSetSize = 8150;
SeriesSize = 100;
DateID = 0;
uniqueIdentifier = 1;

NumberOfYears = 1;
StartDate = 1;
EndDate = NumberOfYears *2;
Fact = "FactFinance"
RowNumber = 10000

for startdate in reversed(range(StartDate,EndDate)):
  start = EndDate-startdate
  for batch in range(0,10):
    start_time = datetime.datetime.now().time()#.strftime('%H:%M:%S')
    print("Start time",start_time)
    start_date = datetime.date.today()
    d1 = start_date.strftime("%d/%m/%Y %H:%M:%S")
    print("StartDate",start_date)
    print("Today's date",d1)
    #date_1 = datetime.datetime.strptime("01/01/2018", "%m/%d/%y")-- use hardcoded  date for generating history records
    end_date = start_date #+ datetime.timedelta(days=-startdate)#.strftime("%Y-%m-%d %H:%M:%S")
    print("EndDate", end_date)
    eventat = end_date.year
    Year = str(format(end_date.year, '02d'))
    Month = str(format(end_date.month, '02d'))
    Day = str(format(end_date.day, '02d'))
    Hour = str(format(start_time.hour,'02d'))
    Min = str(format(start_time.minute,'02d'))
    print("Hour",Hour)
    print("Min", Min)
    folder = TestFolderPath + "/" + Fact +"/"+ Year+"/"+Month+"/"+Day+"/"
    file = Fact+"_"+Year+Month+Day+"_"+Hour+"_"+Min+".csv"
    DateId = Year+Month+Day
    DateFormat = Year+Month+Day+Hour+Min
    dbutils.fs.mkdirs(folder)
    Header= "FinanceKey,OrganizationKey,DepartmentGroupKey,ScenarioKey,AccountKey,Amount,Date\r\n"
    with open(file,'w') as file1:
      file1.write(Header)
    print("FileWritten successfully")
    RowN =RowNumber*start
    for s in range(1,SeriesSize):#SeriesSize
      for d in range(1,DataSetSize):#DataSetSize
        DataString =DataString + str((RowN+d)*s)+","+str(randrange(1,100))+","+str(randrange(1,50))+","+str(randrange(1,20))+","+str(randrange(1,1000))+","+str(float(randrange(10,100000)))+","+str(end_date)+"\r\n"
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
    eventsInc = spark.read.option("header", "true").csv("/"+file).drop('_c0')
    print("Writing this file",file)
    #events.coalesce(1).write.mode("overwrite").format("com.databricks.spark.csv").option("header", "true").csv(folder+file)
    print("Events count:",eventsInc.count())
    #MergedDataFrameWithDelete.repartition(1).write.format("csv").mode("overwrite").save(outfilename)
    csv_location = folder+'temp.folder'
    file_location = folder+file
    eventsInc.coalesce(1).write.csv(path=csv_location, mode="append", header="true")
    fileOutput = dbutils.fs.ls(csv_location)[-1].path
    dbutils.fs.cp(fileOutput, file_location)
    dbutils.fs.rm(csv_location, recurse=True)
    dbutils.fs.rm("/"+file)#display(events)
    print("Printed immediately.")
    time.sleep(5*60.4)
    print("Printed after 5 mins.")
    print("End of loop")
  print("End of loop")
  print("End of last loop")




# COMMAND ----------

#%fs rm -r /mnt/AdventureWorksProd/Raw/FactFinance/2020/04/08/

# COMMAND ----------

