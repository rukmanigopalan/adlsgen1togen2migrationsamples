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
import string

TestFolderPath  = "/mnt/AdventureWorksProd/Raw"
DataString = ""
DataSetSize = 7800; #8150
SeriesSize = 10;
DateID = 0;
uniqueIdentifier = 1;
Fact = "DimProduct"

NumberOfYears = 1;
StartDate = 8;
EndDate = NumberOfYears *283;

for startdate in reversed(range(StartDate,EndDate)):
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
    u= ( ''.join(random.choice(letters) for i in range(10)) )
    dbutils.fs.mkdirs(folder)
    color_list = ['red','black','white','blue','brown']
    Header= "ProductKey,ProductAlternateKey,ProductSubcategoryKey,WeightUnitMeasureCode,SizeUnitMeasureCode,EnglishProductName,SpanishProductName,FrenchProductName,StandardCost,FinishedGoodsFlag,Color,SafetyStockLevel,ReorderPoint,ListPrice,Size,SizeRange,Weight,DaysToManufacture,ProductLine,DealerPrice,Class,Style,ModelName,LargePhoto,EnglishDescription,FrenchDescription,ChineseDescription,ArabicDescription,HebrewDescription,ThaiDescription,GermanDescription,JapaneseDescription,TurkishDescription,StartDate,EndDate,Status\r\n"

    with open(file,'w') as file1:
      file1.write(Header)
    print("FileWritten successfully")
    for s in range(1,SeriesSize):#SeriesSize
      for d in range(1,DataSetSize):#DataSetSize
        #DataString =DataString + str(randrange(1,100))+","+"NA"+","+str(randrange(1,100))+","+str(randrange(1,50))+","+str(randrange(1,20))+","+u+","+"NA"+","+"NA"+","+str(float(randrange(1,1000)))+","+str(randrange(0,1))+","+color_list[randrange(5)]+","+str(randrange(1,5))+","+str(randrange(1,10))+","+str(randrange(1,80))+","+str(randrange(1,10))+","+str(randrange(1,10))+","+str(randrange(1,1000))+","+str(randrange(1,30))+","+"NA"+","+str(randrange(1,1000))+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+u+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+str(PreviousDateId)+","+str(end_date)+",Current\r\n"  
        DataString =DataString + str(randrange(1,100))+","+","+str(randrange(1,100))+","+str(randrange(1,50))+","+str(randrange(1,20))+","+u+","+","+","+str(float(randrange(1,1000)))+","+str(randrange(0,1))+","+color_list[randrange(5)]+","+str(randrange(1,5))+","+str(randrange(1,10))+","+str(randrange(1,80))+","+str(randrange(1,10))+","+str(randrange(1,10))+","+str(randrange(1,1000))+","+str(randrange(1,30))+","+","+str(randrange(1,1000))+","+","+","+","+","+u+","+","+","+","+","+","+","+","+","+str(PreviousDateId)+","+str(end_date)+",Current\r\n"   
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
    DimProduct = spark.read.option("header", "true").csv("/"+file).drop('_c0')
    print("Writing this file",file)
    #events.coalesce(1).write.mode("overwrite").format("com.databricks.spark.csv").option("header", "true").csv(folder+file)
    print("Events count:",DimProduct.count())
    csv_location = folder+'temp.folder'
    file_location = folder+file
    DimProduct.coalesce(1).write.csv(path=csv_location, mode="append", header="true")
    fileOutput = dbutils.fs.ls(csv_location)[-1].path
    dbutils.fs.cp(fileOutput, file_location)
    dbutils.fs.rm(csv_location, recurse=True)
    #dbutils.fs.rm("/"+file)#display(events)
    #print("Printed immediately.")
    #time.sleep(15*60.4)
    #print("Printed after 5 mins.")
    #print("End of loop")
   
  print("End of loop")
  print("End of last loop")


# COMMAND ----------

#%fs rm -r /mnt/AdventureWorksProd/Raw/DimProduct/2019/

# COMMAND ----------

display(DimProduct)

# COMMAND ----------

import random
import string
from random import randrange
test_list = ['gfg', 'is', 'best', 'for', 'geeks'] 
print(test_list[randrange(5)])
letters = string.ascii_letters
u= ( ''.join(random.choice(letters) for i in range(10)) )
print(u)

# COMMAND ----------

