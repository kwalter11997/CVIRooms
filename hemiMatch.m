%hemiMatch

hemiMatch = readtable('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\VR\hemiMatch.xlsx');
    
%HMD
for s=5

    %dataFile
    cd('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\VR\Data\ControlExpData')
    %cd('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\VR\Data\CVIExpData')
    fileNames = dir; fileNames = {fileNames.name}; fileNames = fileNames(3:end);
    fileName = fileNames(s);
    data = readtable(string(fileName));
    
    data = data(3:2:end,1:3) %only what we need
    
    for h = 1:44
        room = data.RoomName(h) %room
        con = data.Condition(h) %congruency
        
        idx = find(strcmp(hemiMatch.Room,room)); %idx in hemiMatch (same as room#)
        if strcmp(con,'Congruent')
           hemi(h) = hemiMatch.Con(idx); 
        else
           hemi(h) = hemiMatch.Incon(idx);
        end
    end
    
end

%2D

%dataFile
data_2D = readtable('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\2DClutterRoomDataexport6_27.xlsx');

subjs = unique(data_2D.ParticipantName, 'stable');
 
for s=2

    sd = data_2D(strcmp(data_2D.ParticipantName,subjs(s)),:); sd = sd(:,[68,69]); %only data we need
    rooms = unique(sd.PresentedStimulusName(~cellfun(@isempty,strfind(sd.PresentedStimulusName, 'Room'))),'stable'); rooms(1)=[];

    for h = 1:44
        room = erase(rooms(h),' CH (1)');room = erase(room,' CL (1)');room = erase(room,' IH (1)');room = erase(room,' IL (1)');       
        room = erase(room,' ');
        
        idx = find(strcmp(hemiMatch.Room,room)); %idx in hemiMatch (same as room#)
        
        if contains(string(rooms(h)),"C")
            hemi(h) = hemiMatch.Con(idx)
        else
            hemi(h) = hemiMatch.Incon(idx)
        end
    end
    hemi=hemi'
        