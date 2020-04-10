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

for batch in range(0,2):
  start_time = datetime.datetime.now().time()#.strftime('%H:%M:%S')
  print("Start time",start_time)
  start_date = datetime.date.today()
  Today_date = start_date.strftime("%d/%m/%Y %H:%M:%S")
  print("Today's date",Today_date)
  Year = str(format(start_date.year, '02d'))
  Month = str(format(start_date.month, '02d'))
  Day = str(format(start_date.day, '02d'))
  Hour = str(format(start_time.hour,'02d'))
  Min = str(format(start_time.minute,'02d'))
  folder = TestFolderPath + "/" + Year+"/"+Month+"/"+Day+"/"
  file = Year+Month+Day+"_"+Hour+"_"+Min+".csv"
  DateId = Year+Month+Day
  DateFormat = Year+Month+Day+Hour+Min
  Header= "Printing Hello World at time:"+Today_date+"\r\n"
  with open(file,'a+') as file1:
    file1.write(Header)
  print("FileWritten successfully")
  with open(file) as in_file:
    lines = in_file.read().splitlines()
    stripped = [line.split(",") for line in lines]
    grouped = itertools.zip_longest(*[stripped]*1)    
  with open(file, 'w') as out_file:
    writer = csv.writer(out_file)
    for group in grouped:
      writer.writerows(group)
  df = pd.read_csv(file,index_col=None,dtype='unicode').to_csv("/dbfs/"+file)
  events_FIC = spark.read.option("header", "true").csv("/"+file).drop('_c0')
  print("Writing this file",file)
  csv_location = folder+'temp.folder'
  file_location = folder+file
  events_FIC.coalesce(1).write.csv(path=csv_location, mode="append", header="true")
  fileOutput = dbutils.fs.ls(csv_location)[-1].path
  dbutils.fs.cp(fileOutput, file_location)
  dbutils.fs.rm(csv_location, recurse=True)
  dbutils.fs.rm("/"+file)#display(events)
  print("Printed immediately.")
  time.sleep(10*60.4)
  print("Printed after 5 mins.")
print("End of last loop")


# COMMAND ----------

#%fs rm -r /mnt/AdventureWorks/RawData/Increment/FactInternetSales/2020/