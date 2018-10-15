function [dat probes] = addProbes(dat)
%% add as many probes as there are features
% each probe is a permutation of each feature

[rows cols] = size(dat);

probes = [];

for i=1:cols
    ind = randperm(rows);
    probes = [probes dat(ind,i)];
end

dat = [dat probes];