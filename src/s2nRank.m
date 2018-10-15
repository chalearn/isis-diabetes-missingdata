function [wts ind] = s2nRank(x,y,missData)
%% Returns the wt of each feature
% ind has feature indices sorted according to their importance
% assume y is target with two possible values
% if missData matrix is present then apply case wise deletion

if (nargin<3)
    missData = [];
end

targets = unique(y);
[rows cols] = size(x);
means = zeros(2,cols);
sigmas = zeros(2,cols);

if (length(missData)==0)
    for i=1:length(targets)
        ind = find(y==targets(i));
        means(i,:) = mean(x(ind,:));
        sigmas(i,:) = std(x(ind,:));
    end
else % apply case wise deletion
    x(find(missData==1))=0;
    
    for i=1:length(targets)
        ind = find(y==targets(i));
        present = length(ind)-sum(missData(ind,:));
        means(i,:) = sum(x(ind,:))./present;   %compute mean from only present values
        stdev = sum(x(ind,:).*x(ind,:))./present -means(i,:).*means(i,:); %biased estimate of std
        stdev = stdev.*(present)./(present-1);%unbiased estimate
        sigmas(i,:) = sqrt(stdev);
    end
    

end
    
    
sigma = mean(sigmas)+.000005;

wts = (means(1,:)-means(2,:))./sigma;
wts = abs(wts);

[temp ind] = sort(wts,'descend');

