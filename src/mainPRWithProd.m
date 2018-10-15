%% this code will make the PR curves for the questionnaire items in the diabetes
%%% dataset as mentioned in the paper
%%% mehreen.saeed@nu.edu.pk

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

%% add product of features and add probes

[dat prodFeats] = addProdFeats(dat,2);
[dat probes] = addProbes(dat); 
datSVD = dat;
[rows cols] = size(dat);

%% adjust the missing data accordingly
missData = repmat(missData,1,cols/size(missData,2));
missData(isinf(dat))=1;  %add originally missing values to probes 
origData = dat;
origMissData = missData;
[rows cols] = size(dat);

hfig = figure;

colors = [3,255,3;3,191,191;3,3,255;191,3,191;255,3,3]/255;
typesInd=1;
tempTypes = {'k--','k-','k-.'};
hplot = [];
colorIndex = 1;
for percentage=[0 .3 .6 .8]
    dat = origData;
    missData = origMissData;
    datSVD = dat;

    %% add missing values MCAR for both probes and data
    perms = randperm(rows*cols);
    perms = perms(1:floor(rows*cols*percentage));
    missData(perms)=1;
    ind = find(isinf(dat));
    missData(isinf(dat))=1;  %add originally missing values to probes 
    
    
    %% impute missing values
    dat = imputeWithMedian(dat,missData);
    datSVD = imputeWithSVD(datSVD,missData);
    %truth values
    featRelevant = [ones(cols/2,1);zeros(cols/2,1)];
 
    %% rank the features using s2n
    [wtsMedian,indMedian] = s2nRank(dat,target);  %median
    [wtsSVD,indSVD] = s2nRank(datSVD,target); %svd
    [wtsCaseDel,indCaseDel] = s2nRank(dat,target,missData);%case wise deletion
    
    [pMedian rMedian] = PRCurve(indMedian,featRelevant);
    [pSVD rSVD] = PRCurve(indSVD,featRelevant);
    [pCaseWiseDel rCaseWiseDel] = PRCurve(indCaseDel,featRelevant);
    hplot1 = plot(rMedian,pMedian,tempTypes{1},rSVD,pSVD,tempTypes{2},'LineWidth',3);  %temporary black lines for legend    
    hplot = [hplot plot(rMedian,pMedian,'--',rSVD,pSVD,'-','LineWidth',3,'color',colors(colorIndex,:))];
    hold on;
    colorIndex = colorIndex+1;
end

hplot2 = plot([0 1 1],[1 1 0.5],'-','LineWidth',2,'color',colors(end,:));
xlabel('Recall');
ylabel('Precision');
hlegend = legend(hplot1,{'Median','SVD'});
aa=axes('position',get(gca,'position'),'visible','off');
legend(aa,[ hplot(2,:) hplot2],{'0%','30%','60%','80%','Ideal'},'Location','SouthEast')

