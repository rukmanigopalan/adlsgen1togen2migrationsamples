import os
import pandas as pd
import numpy as np

# Function to generate pivot sheet 

def create_pivot_table(inputpath,filename,index,outputpath):
    df = pd.read_csv(inputpath+'\\'+filename,header=0,sep="\t",encoding="utf-16")

    #to choose the sub folder
    subpath=df.Path.str.split("/",expand=True,)
    df['Subfolder']=subpath[index]
    df['Nextfolder']=subpath[index+1]
    
        
    #to get the recent child modification date
    df[['RecentChildModificationDate','time']]=df.RecentChildModificationTime.str.split(" ",expand=True,)
    df.drop(['time','RecentChildModificationTime'], axis=1, inplace=True)
    
    df['RecentChildModificationDate'] = pd.to_datetime(df['RecentChildModificationDate'])
    df['RecentChildModificationDate'] = df['RecentChildModificationDate'].dt.strftime('%d/%m/%Y')
    
    #to convert the size to GB
    df['SizeinGB']= round((df['TotalSize']/1073741824),6)
    
    #to extract the sub directories 
    newdf = df[df['Nextfolder'].notnull()]
    
    #create pivot table
    table = pd.pivot_table(df,index=["Subfolder","Path"],
                   values=["SizeinGB",'RecentChildModificationDate'],
                   aggfunc={'SizeinGB':[np.max],
                            'RecentChildModificationDate':[np.max]},fill_value=0)
    
    #delete additional columns
    df.drop(['Nextfolder'], axis=1, inplace=True)
    newdf.drop(['Nextfolder'], axis=1, inplace=True)
    
    #Load df to excel
    name = filename.split('.txt')
    with pd.ExcelWriter(outputpath+'\\'+name[0]+'.xlsx') as ew:
        df.to_excel(ew, sheet_name="Raw Data",index=False)
        newdf.to_excel(ew, sheet_name="Sub Directories",index=False)
        table.to_excel(ew, sheet_name="Pivot Table")
    

#pass the location of input folder
inputpath = <<Enter the source path -location of input folder in which results of inventory saved>>
files = os.listdir(inputpath)

#pass the location of destination folder
outputpath = <<Enter the destination path -location of output folder in which resultant pivot sheet will be saving >>

# loop through each folder item in the given input path and call create_pivot_table function for each.

for f in files:
    f1 = f.split('_')
    f2 = [i for i in f1 if i] 
    index=len(f2)
    create_pivot_table(inputpath,f,index,outputpath)
    