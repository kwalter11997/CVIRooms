# -*- coding: utf-8 -*-
"""
Created on Tue Jul 30 12:02:42 2024

@author: Kerri
"""
import os
import pandas as pd
import numpy as np

timeFound = []
targetFound = []
timeFirstGaze = []

s = 1

#dataFile
datafolder = 'C:/Users/Kerri/Dropbox/Kerri_Walter/CVIRooms/VR/Data/ControlExpData'
#cd('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\VR\Data\CVIExpData')
fileNames = os.listdir(datafolder)
fileName = fileNames[1];
os.chdir(datafolder)
data = pd.read_csv(fileName)

#Raw dataFile
rawdatafolder = 'C:/Users/Kerri/Dropbox/Kerri_Walter/CVIRooms/VR/Data/ControlExpDataRaw'
#cd('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\VR\Data\CVIExpDataRaw')
fileNamesRaw = os.listdir(rawdatafolder)
fileNameRaw = fileNamesRaw[1];
os.chdir(rawdatafolder)
rawData = pd.read_csv(fileNameRaw)

trialtimes = data.loc[:,' TrialTime']

#remove practice trial from analysis
data = data.drop([0,1]) #remove practice

clutter = data.loc[:,' Clutter']
clutter = clutter[::2]

for t in range(2, 89, 2):
    
    #clean to retreive just this trial
    rd = rawData.loc[rawData.loc[:,' TrialTime'] >= data.loc[t, ' TrialTime']]
    rd = rd.loc[rd.loc[:,' TrialTime'] <= data.loc[t+1, ' TrialTime']]

    logi = rd[' TargetHit'] 
    logiidx = logi[logi].index #indices of target gazed upon
    
    idx = logiidx[0] #index of first gaze point on target

    logi = logi.astype('uint8') #convert to numerical boolean
    
    tfg = rd.loc[idx, ' TrialTime'] - rd.iloc[0,1] #time it took for first gaze point to land on target (time at first gaze - time at start of trial)
    timeFirstGaze.append(tfg)
    
    #determine if target was "found" during this first gaze point (gaze remains consistent)       
    if sum(logi[list(range(idx, idx+50))]) >= 50*.75: #50 frames per second, hold gaze for 1 second - if <%75 of gaze points are on the target within 1 second of first gaze, consider target found
        targf = 1
        targetFound.append(targf)
        tf = tfg
        timeFound.append(tf)
    else:
        switchIdx = logi[(logi.shift(1) == 0) & (logi == 1)].index #find points at which TargetFound switches from 0 to 1 
        for i in range(1, len(switchIdx)):
            if [switchIdx[i] + 101] > logi[-1:].index.tolist(): #error, didn't reach threshold before end of trial
                targf = 0
                targetFound.append(targf)
                tf = float('NaN')
                timeFound.append(tf)
            else:
                if sum(logi[list(range(switchIdx[i], switchIdx[i]+51))]) >= 50*.75:   
                    targf = 1
                    targetFound.append(targf)
                    tf = rd.loc[switchIdx[i]+1,' TrialTime'] - rd.iloc[0,1] #time it took for target to be properly found
                    timeFound.append(tf)
                    break   
                else:
                    targf = 0
                    targetFound.append(targf)
                    tf = float('NaN')
                    timeFound.append(tf)
                break
                    
                    


