%% Gaze Target Center Volume

%% HMD

roomXCenters = [-175:15:140]; %x values of each room center
targLocations = readtable('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\VR\targLocationsHMD.xlsx')

rawData = readtable('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\VR\Data\xMBO_01302025_RAW.csv');

data = readtable('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\VR\Data\xMBO_01302025.csv')

trialtimes = data.TrialTime;

%remove practice trial from analysis
data(1:2,:) = []; %remove practice

rooms = data.RoomName;

congruency = strcmp(data.Condition,'Congruent') %keep track of congruency
clutter = strcmp(data.Clutter,'Low'); %keep track of clutter

cl = [];
il = [];
ch = [];
ih = [];

figure
for t = 1:2:88

    %clean to retreive just this trial
    rd = rawData(rawData.TrialTime>=data.TrialTime(t),:); rd = rd(rd.TrialTime<=data.TrialTime(t+1),:);
           
    %remove any "background screen" points (artifact from hottub room, missing wall)
    rd = rd(~strcmp(rd.ObjectName,'BackgroundRooms'),:);
            
    %clean
    if any(abs(rd.Lx-rd.Rx) > 1)
        idx = abs(rd.Lx-rd.Rx) > 1 %if left and right discrepency is high, pick one eye to use (eye closer to the average)
        opts = [rd.Lx(idx),rd.Rx(idx)]; %options(list of discrepency points)
        c=[abs(mean(rd.Lx)-rd.Lx(idx))'; abs(mean(rd.Lx)-rd.Rx(idx))']; m=min(c)'; choice = m==c'; %c compares points to the mean, m finds the minimum, choice is a logical of either L or R is lower
        rd.Lx(idx) = opts(choice); rd.Rx(idx) = opts(choice); %replace discrepency point with other eyes value
    end
    if any(abs(rd.Ly-rd.Ry) > 1)
        idx = abs(rd.Ly-rd.Ry) > 1 %if left and right discrepency is high, pick one eye to use (eye closer to the average)
        opts = [rd.Ly(idx),rd.Ry(idx)]; %options(list of discrepency points)
        c=[abs(mean(rd.Ly)-rd.Ly(idx))'; abs(mean(rd.Ly)-rd.Ry(idx))']; m=min(c)'; choice = m==c'; %c compares points to the mean, m finds the minimum, choice is a logical of either L or R is lower
        rd.Ly(idx) = opts(choice); rd.Ry(idx) = opts(choice); %replace discrepency point with other eyes value
    end
    if any(abs(rd.Lz-rd.Rz) > 1)
        idx = abs(rd.Lz-rd.Rz) > 1 %if left and right discrepency is high, pick one eye to use (eye closer to the average)
        opts = [rd.Lz(idx),rd.Rz(idx)]; %options(list of discrepency points)
        c=[abs(mean(rd.Lz)-rd.Lz(idx))'; abs(mean(rd.Lz)-rd.Rz(idx))']; m=min(c)'; choice = m==c'; %c compares points to the mean, m finds the minimum, choice is a logical of either L or R is lower
        rd.Lz(idx) = opts(choice); rd.Rz(idx) = opts(choice); %replace discrepency point with other eyes value
    end
    
    %avg l and r eyes
    x = (rd.Lx+rd.Rx)./2;
    y = (rd.Ly+rd.Ry)./2;
    z = (rd.Lz+rd.Rz)./2;
    
    %remove remaining lag points (still at target screen, z will be -40 for con and -140 for incon)
    if congruency(t) == 1
        keep=(z>-9); %arbitrary point between rooms and targets
    else
        keep=(z>-99) %arbitrary point between rooms and targets
    end
    x=x(keep);
    y=y(keep);
    z=z(keep);
    
    [~,idx] = min(abs(mean(x)-roomXCenters)); %find which room so we can 0
    x = x - roomXCenters(idx); %center around 0
    
%     x = 0 - x %flip x bc matlab
    
    room = erase(rooms(t),'Room');
      
    %center target
    if congruency(t) == 1
        targetx = targLocations.x(str2double(room));
        targety = targLocations.y(str2double(room));
        targetz = targLocations.z(str2double(room));
    else
        targetx = targLocations.x_1(str2double(room));
        targety = targLocations.y_1(str2double(room));
        targetz = targLocations.z_1(str2double(room));
    end

    x = abs(x) - abs(targetx); %center around target
    y = abs(y) - abs(targety);
    z = abs(z) - abs(targetz);
    
    if congruency(t) == 1 & clutter(t) == 1 %congruent low
        p1 = subplot(2,2,1)
        scatter3(x,z,y)
        hold on;
        cl = [cl;x,z,y];
    elseif congruency(t) == 0 & clutter(t) == 1 %incongruent low
        p2 = subplot(2,2,2)
        scatter3(x,z,y)
        hold on;
        il = [il;x,z,y];
    elseif congruency(t) == 1 & clutter(t) == 0 %congruent high
        p3 = subplot(2,2,3)
        scatter3(x,z,y)
        hold on;
        ch = [ch;x,z,y];
    elseif congruency(t) == 0 & clutter(t) == 0 %incongruent high
        p4 = subplot(2,2,4)
        scatter3(x,z,y)
        hold on;
        ih = [ih;x,z,y];
    end
end

title(p1,'Congruent Low')
xlabel('X')
ylabel('Z')
zlabel('Y')
%set ( gca, 'xdir', 'reverse' )

title(p2,'Incongruent Low')
xlabel('X')
ylabel('Z')
zlabel('Y')

title(p3,'Congruent High')
xlabel('X')
ylabel('Z')
zlabel('Y')

title(p4,'Incongruent High')
xlabel('X')
ylabel('Z')
zlabel('Y')

figure
x = cl(:,1); y = cl(:,2), z = cl(:,3);
clP = scatter3(x,y,z)
%take 90% of points relative to centroid
centroid_x = mean(x);
centroid_y = mean(y);
centroid_z = mean(z);
[~,r] = cart2pol( x - centroid_x, y - centroid_y, z  - centroid_z);
[~, sortidx] = sort(r);
top95 = sortidx(1:floor(length(sortidx)*9.5/10));
x = x(top95);
y = y(top95);
z = z(top95);
[k, clvol] = boundary([x,y,z],1);
hold on
trisurf(k,x,y,z,'Facecolor','red','FaceAlpha',0.1)

figure
x = il(:,1); y = il(:,2), z = il(:,3);
ilP = scatter3(x,y,z)
%take 90% of points relative to centroid
centroid_x = mean(x);
centroid_y = mean(y);
centroid_z = mean(z);
[~,r] = cart2pol( x - centroid_x, y - centroid_y, z  - centroid_z);
[~, sortidx] = sort(r);
top95 = sortidx(1:floor(length(sortidx)*9.5/10));
x = x(top95);
y = y(top95);
z = z(top95);
[k, ilvol] = boundary([x,y,z],1);
hold on
trisurf(k,x,y,z,'Facecolor','red','FaceAlpha',0.1)

figure
x = ch(:,1); y = ch(:,2), z = ch(:,3);
chP = scatter3(x,y,z)
%take 90% of points relative to centroid
centroid_x = mean(x);
centroid_y = mean(y);
centroid_z = mean(z);
[~,r] = cart2pol( x - centroid_x, y - centroid_y, z  - centroid_z);
[~, sortidx] = sort(r);
top95 = sortidx(1:floor(length(sortidx)*9.5/10));
x = x(top95);
y = y(top95);
z = z(top95);
[k, chvol] = boundary([x,y,z],1);
hold on
trisurf(k,x,y,z,'Facecolor','red','FaceAlpha',0.1)


figure
x = ih(:,1); y = ih(:,2), z = ih(:,3);
ihP = scatter3(x,y,z)
%take 90% of points relative to centroid
centroid_x = mean(x);
centroid_y = mean(y);
centroid_z = mean(z);
[~,r] = cart2pol( x - centroid_x, y - centroid_y, z  - centroid_z);
[~, sortidx] = sort(r);
top95 = sortidx(1:floor(length(sortidx)*9.5/10));
x = x(top95);
y = y(top95);
z = z(top95);
[k, ihvol] = boundary([x,y,z],1);
hold on
trisurf(k,x,y,z,'Facecolor','red','FaceAlpha',0.1)

[clvol;ilvol;chvol;ihvol]



%% 2D
totalData = []

targLocations = readtable('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\targLocations2D.xlsx')

%dataFile
%data_2D = readtable('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\ClutterRoomDataexport8_19.xlsx');
data_2D = readtable("2Dclutterroomdata2-4-25.tsv", "FileType","text",'Delimiter', '\t');

subjs = unique(data_2D.ParticipantName, 'stable');
 
 for s = 1:length(subjs)
     subData = []
     sd = data_2D(strcmp(data_2D.ParticipantName,subjs(s)),:); sd = sd(:,[1,6,7,35,36,68,69,70,72,127,128,131,132]); %data per subject
     
     roomidx = ~cellfun(@isempty,strfind(sd.PresentedStimulusName, 'Room')); %idx room shown
   
     tsidx = strfind(roomidx',[0,1])+1; %trial start indices
     teidx = strfind(roomidx',[1,0]); %trial end indices
     
     tsidx(1)=[];teidx(1)=[]; %remove practice trial
   
    cl = [];
    il = [];
    ch = [];
    ih = [];

     for t = 1:44
     
        td = sd(tsidx(t):teidx(t),:); %just this trial
        
        %get name
        room = char(extractBetween(td.PresentedStimulusName(1),'Room',' '));
        congruency = char(td.CongruentVsIncongruent(1));
        if strcmp(congruency, 'Congruent')
            congruency = 1;
        else
            congruency = 0;
        end
        clutter = char(td.LowVsHighClutter(1));
        if strcmp(clutter, 'Low Clutter')
            clutter = 1;
        else
            clutter = 0;
        end

        x = td.GazePointX;
        y = td.GazePointY;
        
        %remove NaNs
        ns = isnan(x);
        x(ns) = []; y(ns) = []; 
        
        %center target
        if congruency == 1
            targetx = targLocations.x(str2double(room));
            targety = targLocations.y(str2double(room));
        else
            targetx = targLocations.x_1(str2double(room));
            targety = targLocations.y_1(str2double(room));
        end

        x = abs(x) - abs(targetx); %center around target
        y = abs(y) - abs(targety);

        if congruency == 1 & clutter == 1 %congruent low
            p1 = subplot(2,2,1)
            scatter(x,y)
            hold on;
            cl = [cl;x,y];
        elseif congruency == 0 & clutter == 1 %incongruent low
            p2 = subplot(2,2,2)
            scatter(x,y)
            hold on;
            il = [il;x,y];
        elseif congruency == 1 & clutter == 0 %congruent high
            p3 = subplot(2,2,3)
            scatter(x,y)
            hold on;
            ch = [ch;x,y];
        elseif congruency == 0 & clutter == 0 %incongruent high
            p4 = subplot(2,2,4)
            scatter(x,y)
            hold on;
            ih = [ih;x,y];
        end
     end

    title(p1,'Congruent Low')
    xlabel('X')
    ylabel('Y')

    title(p2,'Incongruent Low')
    xlabel('X')
    ylabel('Z')
    zlabel('Y')

    title(p3,'Congruent High')
    xlabel('X')
    ylabel('Z')
    zlabel('Y')

    title(p4,'Incongruent High')
    xlabel('X')
    ylabel('Z')
    zlabel('Y')

    figure
    x=cl(:,1);y=cl(:,2);
    clP = scatter(x,y)
    %take 90% of points relative to centroid
    centroid_x = mean(x);
    centroid_y = mean(y);
    [~,r] = cart2pol( x - centroid_x, y - centroid_y);
    [~, sortidx] = sort(r);
    top95 = sortidx(1:floor(length(sortidx)*9.5/10));
    x = x(top95);
    y = y(top95);
    [k,clvol] = boundary(x,y,1);
    hold on
    plot(x(k),y(k))

    figure
    x=il(:,1);y=il(:,2);
    ilP = scatter(x,y)
    %take 90% of points relative to centroid
    centroid_x = mean(x);
    centroid_y = mean(y);
    [~,r] = cart2pol( x - centroid_x, y - centroid_y);
    [~, sortidx] = sort(r);
    top95 = sortidx(1:floor(length(sortidx)*9.5/10));
    x = x(top95);
    y = y(top95);
    [k, ilvol] = boundary(x,y,1);
    hold on
    plot(x(k),y(k))

    figure
    x=ch(:,1);y=ch(:,2);
    chP = scatter(x,y)
    %take 90% of points relative to centroid
    centroid_x = mean(x);
    centroid_y = mean(y);
    [~,r] = cart2pol( x - centroid_x, y - centroid_y);
    [~, sortidx] = sort(r);
    top95 = sortidx(1:floor(length(sortidx)*9.5/10));
    x = x(top95);
    y = y(top95);
    [k,chvol] = boundary(x,y,1);
    hold on
    plot(x(k),y(k))

    figure
    x=ih(:,1);y=ih(:,2);
    ihP = scatter(x,y)
    %take 90% of points relative to centroid
    centroid_x = mean(x);
    centroid_y = mean(y);
    [~,r] = cart2pol( x - centroid_x, y - centroid_y);
    [~, sortidx] = sort(r);
    top95 = sortidx(1:floor(length(sortidx)*9.5/10));
    x = x(top95);
    y = y(top95);
    [k, ihvol] = boundary(x,y,1);
    hold on
    plot(x(k),y(k))

    subData = [clvol;ilvol;chvol;ihvol]
    totalData = [totalData;subData]
 end
