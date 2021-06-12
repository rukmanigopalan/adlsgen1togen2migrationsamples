# Prerequisites-  Execute adls mount configuration script <MountConfiguration.py>
import datetime
from datetime import timedelta, date
import time

#adls storage path and it should by sync with mount storage Configuration
TestFolderPath  = "/mnt/AdventureWorksProd/Raw" 

Today_date = datetime.datetime.now()

#Generate the folder path ( Format - YYYY/MM/DD/YYYYMMDD_hh_mm.csv)
folder = TestFolderPath + "/" + str(format(Today_date.year, '02d'))+"/"+str(format(Today_date.month, '02d'))+"/"+str(format(Today_date.day, '02d'))+"/"
file =  folder + str(format(Today_date.year, '02d'))+str(format(Today_date.month, '02d'))+str(format(Today_date.day, '02d'))+"_"+str(format(Today_date.hour, '02d'))+"_"+str(format(Today_date.minute, '02d'))+".csv"

#Generating the sample data
Header= "Printing Hello World at time:"+str(Today_date)+"\r\n"

#Writing the file to adls storage
dbutils.fs.put(file, Header)
