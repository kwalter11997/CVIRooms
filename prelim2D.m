%% 2D
totalData = []

hemiMatch = readtable('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\VR\hemiMatch.xlsx');

%dataFile
%data_2D = readtable('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\2Dclutterroomdata2-4-25.tsv');
data_2D = readtable("2Dclutterroomdata2-4-25.tsv", "FileType","text",'Delimiter', '\t');

subjs = unique(data_2D.ParticipantName, 'stable');
 
 for s = 1:length(subjs)
    subData = [];

    sd = data_2D(strcmp(data_2D.ParticipantName,subjs(s)),:); sd = sd(:,[1,6,7,35,36,68,69,70,72,127,128,131,132]); %data per subject

    rooms = unique(sd.PresentedStimulusName(~cellfun(@isempty,strfind(sd.PresentedStimulusName, 'Room'))),'stable'); rooms(1)=[];

    roomidx = ~cellfun(@isempty,strfind(sd.PresentedStimulusName, 'Room')); %idx room shown

    tsidx = strfind(roomidx',[0,1])+1; %trial start indices
    teidx = strfind(roomidx',[1,0]); %trial end indices

    tsidx(1)=[];teidx(1)=[]; %remove practice trial

    if strcmp(sd.CongruentVsIncongruent(tsidx(1)),'Congruent'); %keep track of congruency condition
    congruency = [repmat({'Congruent'},22,1);repmat({'Incongruent'},22,1)];
    else
    congruency = [repmat({'Incongruent'},22,1);repmat({'Congruent'},22,1)]
    end
    
    for t = 1:44
     
        room = erase(rooms(t),' CH (1)');room = erase(room,' CL (1)');room = erase(room,' IH (1)');room = erase(room,' IL (1)');       
        room = erase(room,' ');

        idx = find(strcmp(hemiMatch.Room,room)); %idx in hemiMatch (same as room#)

        if contains(string(rooms(t)),"C")
            hemi(t) = hemiMatch.Con(idx)
        else
            hemi(t) = hemiMatch.Incon(idx)
        end

        td = sd(tsidx(t):teidx(t),:); %just this trial

        logi = td.AOIHit_Cong_High_==1 | td.AOIHit_Cong_Low_==1 | td.AOIHit_Incong_High_==1 | td.AOIHit_Incong_Low_==1 %logical index of target gazed upon (one of these rows should have 1s)

        idx = find(logi, 1, 'first'); %index of first gaze point on target

        clutter(t,:) = td.LowVsHighClutter(1);
         
        if ~isempty(idx)
            timeFirstGaze(t) = (td.RecordingTimestamp(idx) - td.RecordingTimestamp(1))/1000000; %time it took for first gaze point to land on target (time at first gaze - time at start of trial) (recording timestamp is super large, divide to convert to seconds)

            %determine if target was "found" during this first gaze point (gaze remains consistent)
            %test(t) = sum(logi) %check values
            if idx+31 > length(logi) %avoid error of moving past the trial window
               targetFound(t) = 0;
               timeFound(t) = NaN;
            else
                if sum(logi(idx:idx+30)) >= 30*.75 %30 frames per second, hold gaze for 1 second - if <%75 of gaze points are on the target within 1 second of first gaze, consider target found
                   targetFound(t) = 1;
                   timeFound(t) = timeFirstGaze(t);
                else
                    switchIdx = strfind(logi',[0,1]); %find points at which TargetFound switches from 0 to 1
                    for i = 1:length(switchIdx) 
                        if switchIdx(i)+31 > length(logi) %error, didn't reach threshold before end of trial
                            targetFound(t) = 0;
                            timeFound(t) = NaN;
                        else
                            if sum(logi(switchIdx(i)+1:switchIdx(i)+31)) >= 30*.75
                                targetFound(t) = 1;
                                timeFound(t) = (td.RecordingTimestamp(switchIdx(i)+1) - td.RecordingTimestamp(1))/1000000; %time it took for target to be properly found
                                break
                            else
                                targetFound(t) = 0;
                                timeFound(t) = NaN;
                                %test(c) = sum(logi(switchIdx(i)+1:switchIdx(i)+101)) %check values
                            end
                        end
                    end
                end
            end           
        else %never gazed upon
            timeFirstGaze(t) = NaN; 
            targetFound(t) = 0;
            timeFound(t) = NaN; 
        end
    end
     
    subData = [congruency, clutter, hemi', num2cell(targetFound') , num2cell(timeFound') , num2cell(timeFound' - timeFirstGaze')]
    totalData = [totalData;subData]
 end
 
