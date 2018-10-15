function dat = imputeWithMedian(dat,missData)

dat(isinf(dat)) = 0;
for i=1:size(dat,2)
    x = dat(:,i);
    ind = find(missData(:,i) == 1);    
    x(ind)=[];  %remove missing values
    med = median(x);
    dat(ind,i) = med;
end
