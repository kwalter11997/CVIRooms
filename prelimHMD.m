%% Preliminary Behavioral Analysis (reaction time / success rate / time after first fixation)

% %Lotfi Lab members
% xMLM_test_03082024
% xFCM_03112024
% xFMH_03112024
% 
% %controls
% xFVL_03152024
% xMAS_03152024
% xMJW_03192024*** HOLD OFF FOR NOW
% xMPB_04182024
% xMDW_08012024 (calibration issue/possible ADHD)
% xMKW_08012024 (calibration issue)
% xFCF_01172025
% xFGC_02012025 (calibration issue)
% xMBO_01302025

% %CVI
% cMCF_04092024
% cMKS_04172024
% cFML_05062024
% cFSF_06242024***(nystagmus)
% cFTC_05032024***(nystagmus)
% cFKG_07112024
% cMJB_07082024
% cMSS_07102024 (two calibrations)
% cMRR_07102024 (possible ADHD)
% cMNW_09272024 (exodeviation of the right eye, consider using only left eye data)
%% HMD 

successRate = []
reactionTime = []
timeAfterFirstGaze = []

for s = 5 %subjects
    
    %dataFile
    cd('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\VR\Data\ControlExpData')
    %cd('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\VR\Data\CVIExpData')
    fileNames = dir; fileNames = {fileNames.name}; fileNames = fileNames(3:end);
    fileName = fileNames(s);
    data = readtable(string(fileName));
    
    %Raw dataFile
    cd('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\VR\Data\ControlExpDataRaw')
    %cd('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\VR\Data\CVIExpDataRaw')
    fileNamesRaw = dir; fileNamesRaw = {fileNamesRaw.name}; fileNamesRaw = fileNamesRaw(3:end);
    fileNameRaw = fileNamesRaw(s);
    rawData = readtable(string(fileNameRaw));

    trialtimes = data.TrialTime;
    
    %remove practice trial from analysis
    data(1:2,:) = []; %remove practice

    clutter = data(1:2:end,4)
    
    if strcmp(data.Condition(2),'Congruent'); %keep track of congruency condition
       con = 1;
    else
        con = 0;
    end
    
    c = 1; %dummy counter
    for t = 1:2:88 %44 total trials (22 each congruency cond)

        %clean to retreive just this trial
        rd = rawData(rawData.TrialTime>=data.TrialTime(t),:); rd = rd(rd.TrialTime<=data.TrialTime(t+1),:);

        logi = strcmp(rd.TargetHit, 'True'); %logical index of target gazed upon

        idx = find(logi, 1, 'first'); %index of first gaze point on target

        if ~isempty(idx)
            timeFirstGaze(c) = rd.TrialTime(idx) - rd.TrialTime(1); %time it took for first gaze point to land on target (time at first gaze - time at start of trial)
            
            %determine if target was "found" during this first gaze point (gaze remains consistent)
            %test(c) = sum(logi) %check values
            if idx+50<length(logi)
                if sum(logi(idx:idx+50)) >= 50*.75 %50 frames per second, hold gaze for 1 second - if <%75 of gaze points are on the target within 1 second of first gaze, consider target found
                   targetFound(c) = 1;
                   timeFound(c) = timeFirstGaze(c);
                else
                    switchIdx = strfind(logi',[0,1]); %find points at which TargetFound switches from 0 to 1
                    for i = 1:length(switchIdx) 
                        if switchIdx(i)+101 > length(logi) %error, didn't reach threshold before end of trial
                            targetFound(c) = 0;
                            timeFound(c) = NaN;
                        else
                            if sum(logi(switchIdx(i)+1:switchIdx(i)+51)) >= 50*.75
                                targetFound(c) = 1;
                                timeFound(c) = rd.TrialTime(switchIdx(i)+1) - rd.TrialTime(1); %time it took for target to be properly found
                                break
                            else
                                targetFound(c) = 0;
                                timeFound(c) = NaN;
                                %test(c) = sum(logi(switchIdx(i)+1:switchIdx(i)+101)) %check values
                            end
                        end
                    end
                end
            else
               targetFound(c) = 0;
               timeFound(c) = NaN;
            end
            
        else %never gazed upon
            timeFirstGaze(c) = NaN; 
            targetFound(c) = 0;
            timeFound(c) = NaN; 
        end

        c=c+1; %dummy counter
    end
 
    targetFound' 
    timeFound'
    timeFound' - timeFirstGaze'
   
%     %split by congruency condition
%     if strcmp(data.Condition(2),'Congruent') %if first 22 trials were congruent
%        con_successRate(s) = sum(targetFound(1:22))/22; %sucess rate
%        con_reactionTime(s) = nanmean(timeFound(1:22)); %avg reaction time
%        con_timeAfterFirstGaze(s) = nanmean(nonzeros(timeFound(1:22) - timeFirstGaze(1:22))); %avg time after first gaze (not including 0s AKA not including when first gaze was the same as when target was found)
%        incon_successRate(s) = sum(targetFound(23:end))/22; %sucess rate
%        incon_reactionTime(s) = nanmean(timeFound(23:end)); %avg reaction time
%        incon_timeAfterFirstGaze(s) = nanmean(nonzeros(timeFound(23:end) - timeFirstGaze(23:end))); %avg time after first gaze (not including 0s AKA not including when first gaze was the same as when target was found)
% 
%     else
%        incon_successRate(s) = sum(targetFound(1:22))/22; %sucess rate
%        incon_reactionTime(s) = nanmean(timeFound(1:22)); %avg reaction time
%        incon_timeAfterFirstGaze(s) = nanmean(nonzeros(timeFound(1:22) - timeFirstGaze(1:22))); %avg time after first gaze (not including 0s AKA not including when first gaze was the same as when target was found)
%        con_successRate(s) = sum(targetFound(23:end))/22; %sucess rate
%        con_reactionTime(s) = nanmean(timeFound(23:end)); %avg reaction time
%        con_timeAfterFirstGaze(s) = nanmean(nonzeros(timeFound(23:end) - timeFirstGaze(23:end))); %avg time after first gaze (not including 0s AKA not including when first gaze was the same as when target was found)
%    end
    
%     %overall (both congruency conditions)    
%     successRate(s) = sum(targetFound)/44; %sucess rate
%     reactionTime(s) = nanmean(timeFound); %avg reaction time
%     timeAfterFirstGaze(s) = nanmean(nonzeros(timeFound - timeFirstGaze)); %avg time after first gaze (not including 0s AKA not including when first gaze was the same as when target was found)
end

% controlSuccessRate = successRate
% controlReactionTime = reactionTime
% controlTAFG = timeAfterFirstGaze

CVISuccessRate = successRate
CVIReactionTime = reactionTime
CVITAFG = timeAfterFirstGaze

SRa = controlSuccessRate'
SRb = [CVISuccessRate;NaN;NaN]

RTa = controlReactionTime'
RTb = [CVIReactionTime;NaN;NaN]

TAFGa = controlTAFG'
TAFGb = [CVITAFG;NaN;NaN]

boxplot([SRa,SRb])
boxplot([RTa,RTb])
boxplot([TAFGa,TAFGb])

