addpath('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms')
addpath('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\entropy') %for fracdboxcount function

%% holders
ent = zeros(1,44);
fracDim = zeros(1,44);
edgeSum = zeros(1,44);

for i = 1:22
    cd('C:\Users\Kerri\Dropbox\Kerri_Walter\CVIRooms\VR\RoomsVR')
    filenames = dir; filenames = {filenames.name}; filenames(1:2) = []; filenames = natsort(filenames);
    filename = filenames{i};
    img = imread(filename);
        
    %entropy
    ent(i) = entropy(img)

    %fractal dimension
    myIm=double(rgb2gray(img)); % convert to floating point grayscale
    gaussSigma=0.5; % a list of values for the standard deviation of the Gaussian filter
    myFilter=fspecial('gaussian', [6*gaussSigma 6*gaussSigma], gaussSigma); % create filter kernel
    myImFilt=imfilter(double(myIm),myFilter);
%     imagesc(myImFilt); % plot the local mean luminance
    myImFilt=myImFilt>mean(myImFilt(:)); % convert to black white binary image
    fdEst=fractDBoxCount(myImFilt, 0);
%     imagesc(myImFilt); % plot the local mean luminance
%     colormap('gray'); % lightness increases with contrast value
%     title(sprintf('Sigma = %.2f pixels, FD = %.3f',gaussSigma, fdEst(1))); % give the figure a title
%     axis off
    fracDim(i) = fdEst(1)

    %edge sum
    e = edge(myIm, 'log');
    edgeSum(i) = sum(e(:))
    
end

%% Plot

figure()

subplot(2,2,2)
%bar(ent)
hist(ent)
xlabel('Entropy')
ylabel('Frequency')
% title('Entropy')

subplot(2,2,3)
%bar(fracDim)
hist(fracDim)
xlabel('Fractal Dimension')
ylabel('Frequency')
% title('Fractal Dimension')

subplot(2,2,4)
%bar(edgeSum)
hist(edgeSum)
xlabel('Number of Edges')
ylabel('Frequency')
% title('Number of Edges')

sgtitle('Measures of Environment Complexity')