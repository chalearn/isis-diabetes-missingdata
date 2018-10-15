function dat = imputeWithSVD(dat,missData,iter)

if nargin < 3
    iter = 10;
end

indMissing = find(missData == 1);
dat(indMissing)=0;  %initialize all missing values to zero
dat = imputeWithMedian(dat,missData);

for i=1:iter
    [U S V] = svds(dat,50);  %take lots of values then reduce this number based on percentage energy
    temp = diag(S)./sum(diag(S))*100;
    ind = find(temp>.05);    %take values which have more than 0.05 percent energy
    U = U(:,ind);
    V = V(:,ind);
    S = S(ind,ind);
    datEst = U*S*V';      %estimate of data matrix
    dat(indMissing) = datEst(indMissing);   %impute
    a=10;
end