function [acc featArr] =  classifyKRidge(dat,targets,featRanks,foldNum)
% apply classification with different number of features.  The top features
% are found by using featRanks

if (nargin<4)
    foldNum = 5;
end


acc = [];
featArr = [];
iter = ceil(log2(length(featRanks)))+1;
totalFeats = 1;
[row col] = size(dat);
%% first standardize the data
m = mean(dat);
m = repmat(m,row,1);
s = std(dat);
s = repmat(s,row, 1);
dat = (dat-m)./(s+.0000001);
%% now apply the classifier, each time taking top ranked features
for j=1:iter %[ 700 800 900 1000 1100 1200 1500 2000] %1:iter
    i = min(length(featRanks),totalFeats);
    
    feats = featRanks(1:i);
    acc = [acc applyClassifier(dat(:,feats),targets,foldNum)];
    featArr = [featArr i];
    totalFeats = totalFeats*2;
end

end % end function

function [acc] =  applyClassifier(dat,targets,foldNum)

[row col] = size(dat);

CVInd = CVIndices(row,foldNum);
aucArr = [];
for i=1:1
    testInd = CVInd==i;
    trainInd = ~testInd;
    
    trainX = dat(trainInd,:);
    trainY = targets(trainInd,1);
    testX = dat(testInd,:);
    testY = targets(testInd,1);
    
    prediction = applyKRidge(trainX,trainY,testX);
    [notused,notused,notused,AUC] = perfcurve(testY,prediction,1);
    aucArr = [aucArr AUC]; 
end

acc = mean(aucArr);

end %end function

function pred = applyKRidge(x,y,testX,lambda);
%% apply kernel ridge regression with linear kernel

if nargin < 4
    lambda = 10000;
end

[row col] = size(x);
[rowtest coltest] = size(testX);

% add a col of ones
x = [ones(row,1) x ];
testX = [ones(rowtest,1) testX];

[row col] = size(x);
[rowtest coltest] = size(testX);


%linear kernel
k = x*x';
k = (1 + k);
k = k+lambda*eye(row,row);

kinv = inv(k);


%for test data first the dot products
testdot = testX*x';
testdot = (1+testdot);

%get predictions
pred = testdot*kinv*y;


end %end function

function ind = CVIndices(total,K)
%% will generate indices for K-fold cross validation
%  ind will be a an array with values 1 to K and it will be of length total

s = RandStream('mt19937ar','Seed',19);

% generate a random permutation of indices
myperm = randperm(s,total);
foldSize = ceil(total/K);

starting = 1;
ending = foldSize;
ind = zeros(1,total);

for i=1:K
    ind(myperm(starting:ending)) = i;
    starting = ending+1;
    ending = min(total,starting+foldSize-1);
end

end %end function
