% %convert to jpg for labelme
% cd('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\labelMe')
% 
% fileNames = dir; fileNames = {fileNames.name}; fileNames = fileNames(3:end);
% 
% for f = 1:44
%     
%     in_name = string(fileNames(f));    %the name of your input image
%     out_name = append(string(erase(fileNames(f),'.tiff')),'.jpg');   %the name of the desired output
%     
%     cd('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\labelMe')
%     IM = imread(in_name);   %read in the image
%     
%     cd('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\test')
%     imwrite(IM, out_name);  %write it out
% end

%load in the glove set
cd('E:\GloVe-master\GloVe')
glovefile = "glove.840B.300d";
if exist(glovefile + '.mat', 'file') ~= 2
    emb = readWordEmbedding(glovefile + '.txt');
    save(glovefile + '.mat', 'emb', '-v7.3');
else
    load(glovefile + '.mat')
end

%% HMD
cont = {'ball', 'flowers', 'kettle', 'slippers','plate','flowers','plant','magazines','glasses','kettle','books','candlestick','sunflower','telephone','bottle','book','pillow','alarmclock','basket','basket','cup','jug'}
incont = {'teapot','spoon','sunglasses','drink','duck','plate','pens','apple','pan','racket','drink','butcherblock','wineglass','controller','car','shoes','bottle','cup','remote','teapot','pots','dinosaur'}

for s = 5 %subject
    
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

    rooms = data.RoomName;
    
    if strcmp(data.Condition(2),'Congruent'); %keep track of congruency condition
       con = 1;
    else
        con = 0;
    end
    
    c=1; %dummy counter
    for t = 1:2:88 %44 total trials (22 each congruency cond)

        %clean to retreive just this trial
        rd = rawData(rawData.TrialTime>=data.TrialTime(t),:); rd = rd(rd.TrialTime<=data.TrialTime(t+1),:);
        
         %manual glove edits
        rd.ObjectName = lower(rd.ObjectName);
                 
        rd.ObjectName = strrep(rd.ObjectName,'cuttingboard','butcherblock');rd.ObjectName = strrep(rd.ObjectName,'cassetteplayer','tapedeck');rd.ObjectName = strrep(rd.ObjectName,'wateringcan','sprinkler');rd.ObjectName = strrep(rd.ObjectName,'toyhelicopter','helicopter');rd.ObjectName = strrep(rd.ObjectName,'toybus','bus');rd.ObjectName = strrep(rd.ObjectName,'toyhorse','horse');rd.ObjectName = strrep(rd.ObjectName,'toyship','ship');rd.ObjectName = strrep(rd.ObjectName,'toycar','car');rd.ObjectName = strrep(rd.ObjectName,'bathcurtains','curtains');rd.ObjectName = strrep(rd.ObjectName,'gameconsole','videogame');rd.ObjectName = strrep(rd.ObjectName,'arcademachine','videogame');
        rd.ObjectName = strrep(rd.ObjectName,'crossfitbox','box');rd.ObjectName = strrep(rd.ObjectName,'storagebox','box');rd.ObjectName = strrep(rd.ObjectName,'gamecartridge','game');rd.ObjectName = strrep(rd.ObjectName,'ironingboard','board');rd.ObjectName = strrep(rd.ObjectName,'laundrybasket','basket');rd.ObjectName = strrep(rd.ObjectName, 'tvbox', 'box');
              
        %list out each new object as a single occurance
        objName = {};
        for x = 1:length(rd.ObjectName)

            if x<length(rd.ObjectName) %work around last point
                if strcmp(rd.ObjectName(x), rd.ObjectName(x+1)) == 0 %when we switch to a new object
                   objName = [objName;rd.ObjectName(x)];
                end
            else
                objName = [objName;rd.ObjectName(x)]; %last obj = last point
            end
        end

        objName = objName(~strncmp(objName,'background',10)); %remove lag points      
        objName = objName(~strncmp(objName,'boundry',7)); %remove lag points      

        objs = objName;
        
        %compare object to the object next to it
        semanticSimNeighbor=[];
        for o = 1:length(objs)-1
            wv1 = word2vec(emb,string(objs(o)));
            wv2 = word2vec(emb,string(objs(o+1)));
            semanticSimNeighbor(o) = dot(wv1,wv2)/ (sqrt(dot(wv1,wv1))*sqrt(dot(wv2,wv2)));
        end

        scatter(1:length(objs)-1,semanticSimNeighbor)
        lsline
        ff=polyfit(1:length(objs)-1, semanticSimNeighbor, 1)        
        neighSlope(c) = ff(1)
        
        %compare objects to target
        semanticSimTarget = [];
%         i=find(strcmp(rd.TargetHit, 'True')); 
%         target = rd.ObjectName(i(1));
        room = erase(rooms(t),'Room')
        if strcmp(data.Condition(t),'Congruent')
           target = cont(str2double(room));
        else
            target = incont(str2double(room));
        end
        
        
        for o = 1:length(objs)
            wv1 = word2vec(emb,string(objs(o)));
            wv2 = word2vec(emb,string(target));
            semanticSimTarget(o) = dot(wv1,wv2)/ (sqrt(dot(wv1,wv1))*sqrt(dot(wv2,wv2)))
        end
        % 
        % lag = 5;
        % simple = movmean(semanticSimTarget,lag);

        scatter(1:length(objs),semanticSimTarget)
        lsline
        ff=polyfit(1:length(objs), semanticSimTarget, 1)        
        targSlope(c) = ff(1)
        % hold on
        % plot(1:length(objs),simple)
        
        c=c+1;      
    end
end

neighSlope'
targSlope'


%% 2D
cont = {'boombox', 'shoes', 'pan', 'flowers','drink','kettle','perfume','cassette','backpack','plant','flower','lamp','sprinkler','pencils','candlestick','vase','camera','helicopter','toiletpaper','iron','briefcase','bottle'}
incont = {'pan','carrot','blimp','hotdogs','lavalamp','toiletpaper','trophy','pan','kettlebell','teddybear','umbrella','tomatoes','alarmclock','sneakers','dumbbell','football','toothbrushes','plate','skateboard','videogame','cutlery','guitar'}

cd('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\labelMe\Annotations')

%dataFile
%data_2D = readtable('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\cMNW.xlsx');
data_2D = readtable("2Dclutterroomdata2-4-25.tsv", "FileType","text",'Delimiter', '\t');

subjs = unique(data_2D.ParticipantName, 'stable');
 
allneighSlope = [];
alltargSlope = [];
for s = 1:length(subjs)
    sd = data_2D(strcmp(data_2D.ParticipantName,subjs(s)),:); sd = sd(:,[1,6,7,35,36,68,69,70,72,127,128,131,132]); %data per subject
     
    roomidx = ~cellfun(@isempty,strfind(sd.PresentedStimulusName, 'Room')); %idx room shown
   
    tsidx = strfind(roomidx',[0,1])+1; %trial start indices
    teidx = strfind(roomidx',[1,0]); %trial end indices
     
    tsidx(1)=[];teidx(1)=[]; %remove practice trial
     
    for t = 1:44
     
        td = sd(tsidx(t):teidx(t),:); %just this trial
        
        %get name
        room = char(extractBetween(td.PresentedStimulusName(1),'Room',' '));
        congruency = char(td.CongruentVsIncongruent(1));
        if strcmp(congruency, 'Congruent')
            congruency = 'con';
        else
            congruency = 'incon';
        end
         
        annotation = LMread(['room',room,congruency,'.xml']); 
%         figure();
%         imshow(['C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\labelMe\','room',room,congruency,'.jpg'])
%         f = LMplot(annotation);
% 
%         hold on
%         scatter(td.GazePointX,td.GazePointY)

        myImage = imread(['C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\labelMe\','room',room,congruency,'.jpg']);
        imSize=size(myImage);
        nObjects=length(annotation.object);

        myMask=false([imSize(1)  imSize(2) nObjects]); % set up memory for areas of all objects
        objSize=zeros(1, nObjects); % list of object sizes

        % objName={};
        % figure();
        % imshow(myImage);
        % LineWidth=2;
        % hold on
        for objNum=1:nObjects
            xLoc=str2num(char(annotation.object(objNum).polygon.pt.x)); % extract vertices of labeled object
            yLoc=str2num(char(annotation.object(objNum).polygon.pt.y));
        %     drawpolygon('Position',[xLoc'; yLoc']'); % draw object outline on figure alternative:     plot([xLoc; xLoc(1)],[yLoc; yLoc(1)], 'LineWidth', LineWidth, 'color', [0 0 0]); 
            myMask(:,:,objNum) = roipoly(myImage,xLoc,yLoc); % find logical polygon for this object
            objSize(objNum)=sum(sum(myMask(:,:,objNum))); % size of this object
            objName(objNum) = {annotation.object(objNum).name};
        end
        %manual glove edits
        objName = strrep(objName,'cuttingboard','butcherblock');objName = strrep(objName,'cassetteplayer','tapedeck');objName = strrep(objName,'wateringcan','sprinkler');objName = strrep(objName,'toyhelicopter','helicopter');objName = strrep(objName,'toybus','bus');objName = strrep(objName,'toyhorse','horse');objName = strrep(objName,'toyship','ship');objName = strrep(objName,'toycar','car');objName = strrep(objName,'bathcurtains','curtains');objName = strrep(objName,'gameconsole','videogame');objName = strrep(objName,'arcademachine','videogame');
        objName = strrep(objName,'crossfitbox','box');objName = strrep(objName,'storagebox','box');objName = strrep(objName,'gamecartridge','game');objName = strrep(objName,'ironingboard','board');objName = strrep(objName,'laundrybasket','basket');objName = strrep(objName, 'tvbox', 'box');
        
        objLabels=zeros(imSize(1),imSize(2)); %create an empty matrix to fill

        [~,sizeOrder] = sort(objSize, 'descend'); % start with largest object
        for objNum=1:nObjects % work through objects in size order to minimize occlusions
            currentObject=sizeOrder(objNum); % next largest object
            objLabels(myMask(:,:,currentObject)==1)=currentObject; % assign pixels to this object
        end

        obj={};
        for n =1:length(td.GazePointX)
            if td.GazePointY(n) <= size(objLabels,1) && td.GazePointY(n) >= 0 && td.GazePointX(n) <= size(objLabels,2) && td.GazePointX(n) >= 0 %only use points within image window (flip x and y bc matlab)
                if isnan(td.GazePointX(n)) 
                    obj(n) = {NaN};
                else
                    objidx = objLabels(td.GazePointY(n)+1,td.GazePointX(n)+1); %flip x and y bc matlab
                    if objidx>0
                        obj(n) = objName(objidx);
                    else
                        obj(n) = {NaN}; %if obj isn't labeled (gaze is on gray background)
                    end
                end
            end
        end
        
        obj(cellfun(@(obj) any(isnan(obj)),obj)) = []; %remove NaNs obj
        obj(cellfun(@(obj) any(isempty(obj)),obj)) = []; %remove emptys
        
        %list out each new object as a single occurance
        objs = {};
        for x = 1:length(obj)

            if x<length(obj) %work around last point
                if strcmp(obj(x), obj(x+1)) == 0 %when we switch to a new object
                   objs = [objs;obj(x)];
                end
            else
                objs = [objs;obj(x)]; %last obj = last point
            end
        end

        semanticSimNeighbor=[];
        %compare object to the object next to it
        for o = 1:length(objs)-1
            wv1 = word2vec(emb,string(objs(o)));
            wv2 = word2vec(emb,string(objs(o+1)));
            semanticSimNeighbor(o) = dot(wv1,wv2)/ (sqrt(dot(wv1,wv1))*sqrt(dot(wv2,wv2)));
        end

        if isempty(semanticSimNeighbor)
           neighSlope(t) = NaN;
        else
            scatter(1:length(objs)-1,semanticSimNeighbor)
            lsline
            ff=polyfit(1:length(objs)-1, semanticSimNeighbor, 1)
            neighSlope(t) = ff(1)
        end
        
        %compare objects to target
        i = td.AOIHit_Cong_High_==1 | td.AOIHit_Cong_Low_==1 | td.AOIHit_Incong_High_==1 | td.AOIHit_Incong_Low_==1; %logical index of target gazed upon (one of these rows should have 1s)
%         idx = find(i,1,'first'); %idx of first gaze point that landed on target
%         objidx = objLabels(td.GazePointY(idx),td.GazePointX(idx)); %flip x and y bc matlab, idx of target object
%         target = objName(objidx); %target name
        if strcmp(congruency,'con')
            target = cont(str2double(room));
        else
            target = incont(str2double(room));
        end

        if isempty(target) %if subj didn't find target this trial
            target = NaN;
        end
        semanticSimTarget=[];
        for o = 1:length(objs)
            wv1 = word2vec(emb,string(objs(o)));
            wv2 = word2vec(emb,string(target));
            semanticSimTarget(o) = dot(wv1,wv2)/ (sqrt(dot(wv1,wv1))*sqrt(dot(wv2,wv2)));
        end

%         lag = 5;
%         simple = movmean(semanticSimTarget,lag);

        if isempty(semanticSimNeighbor)
           targSlope(t) = NaN;
        else
            scatter(1:length(objs),semanticSimTarget)
            lsline
            ff=polyfit(1:length(objs), semanticSimTarget, 1)        
            targSlope(t) = ff(1)
        end
    
%         hold on
%         plot(1:length(objs),simple)
    end
    
    allneighSlope = [allneighSlope;neighSlope']
    alltargSlope = [alltargSlope;targSlope']
    
end

