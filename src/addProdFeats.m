function [dat prodFeats] = addProdFeats(dat,n)

%% n is how many times more columns are to be added
% for example if original col size = 10 and n = 3 then 3*10 more columns
% would be added

[row col] = size(dat);

feat1 = [];
feat2 = [];
for i=1:n
    feat1 = [feat1 randperm(col)];
    feat2 = [feat2 randperm(col)];
end

prodFeats = dat(:,feat1).*dat(:,feat2);

dat = [dat prodFeats];
dat(isnan(dat))=1;
