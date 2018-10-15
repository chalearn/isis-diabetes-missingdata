function [precision recall] = PRCurve(indFeat, actual)
%% indFeat should have the indices of features sorted according to their relevance
%% actual is 1 for relevant and 0 for irrelevant
precision = [];
recall = [];
relevant = find(actual==1);

for i=1:length(actual)
    common = intersect(relevant,indFeat(1:i));
    precision(i) = length(common)/i;
    recall(i) = length(common)/length(relevant); 
end
