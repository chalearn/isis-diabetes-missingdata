%% this code will make the AUC curves for the questionnaire items in the diabetes
%%% dataset as mentioned in the paper
%%% for queries contact mehreen.saeed@nu.edu.pk

clear all
clear all

%% TO RUN, CHANGE THE PATH FOR DATASET
dataPath = '~/work/data/epidemiology/diabetesData/';

qeFileName = [dataPath 'diabetesQEData.csv'];
%% read the data and make the dat and target variables
% read the second row, first column
dat = csvread(qeFileName,2,1);
target = dat(:,end);
dat = dat(:,1:end-1);
missData = isinf(dat);      %make a binary matrix indicating missing values
[rows cols] = size(missData);


%% start the plots
hfig = figure;
colors = [3,255,3;3,191,191;3,3,255;191,3,191;255,3,3]/255;
typesInd=1;
tempTypes = {'k--','k-','k-.'};
hplot = [];
colorIndex = 1;
tempTypes = {'k--','k-','k-.'};
hplot = [];

%% product of features and add probes

[dat prodFeats] = addProdFeats(dat,2);
[dat probes] = addProbes(dat); 
datSVD = dat;
[rows cols] = size(dat);
%% adjust the missing data accordingly
missData = repmat(missData,1,cols/size(missData,2));
missData(isinf(dat))=1;  %add originally missing values to probes 
origData = dat;
origMissData = missData;

for percentage = [0 0.3 0.6 0.8]
%    dat = origData;
    missData = origMissData;
    dat = origData;
    datSVD = origData;
    %% add missing values MCAR for both probes and data
    perms = randperm(rows*cols);
    perms = perms(1:floor(rows*cols*percentage));
    missData(perms)=1;
    

    %% impute missing values
    dat = imputeWithMedian(dat,missData);
    datSVD = imputeWithSVD(datSVD,missData);
    %truth values
    featRelevant = [ones(cols/2,1);zeros(cols/2,1)];
 
    %% rank the features using s2n
    [wtsMedian,indMedian] = s2nRank(dat,target);  %median
    [wtsSVD,indSVD] = s2nRank(datSVD,target); %svd
    
    %% classify
    [accMedian featsMedian] =  classifyKRidge(dat,target,indMedian,2);
    [accSVD featsSVD] =  classifyKRidge(datSVD,target,indSVD,2);

    hplot1 = plot(log2(featsMedian),accMedian,tempTypes{1},log2(featsSVD),accSVD,tempTypes{2},'LineWidth',3);  %temporary black lines for legend
    hplot = [hplot plot(log2(featsMedian),accMedian,'--',log2(featsSVD),accSVD,'-','LineWidth',3,'color',colors(colorIndex,:))];
    hold on;

    colorIndex = colorIndex+1;
    
    
end

title('Learning curves');
xlabel('log2(Number of features)');
ylabel('AUROC');

hlegend = legend(hplot1,{'Median','SVD'});
aa=axes('position',get(gca,'position'),'visible','off');
legend(aa,hplot(2,:),{'0%','30%','60%','80%'},'Location','SouthEast')

