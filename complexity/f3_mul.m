function [result] = f3_mul(dataset, classes)
%F3_MUL Obtain the Max Feature Efficiency values on multiclass problems.
%   Return an array with the Max Feature Efficiency values of each dataset
%   feature. Each element in array corresponds with each dataset feature.
%   This function can work with multiclass datasets.
%
%   INPUTS:
%   -----------------------------------------------------------------------
%   dataset ---> Dataset matrix where rows corresponds with dataset samples and
%                columns with dataset features.
%   classes ---> Class array that cotains the unique identifiers of each
%                class. Each element in the array corresponds to a different
%                feature.
%
%   OUTPUTS:
%   -----------------------------------------------------------------------
%   result ----> Array with Max Feature Efficiency values obtained. Each
%                element in array corresponds with each dataset feature.

    %% PROCESS
    [nsamples, nfeats]=size(dataset);
    class = dataset(:,end);

    nclasses=length(classes);
    auxdatasets={};

    for c=1:nclasses
       auxdatasets{c}=dataset(class==classes{c},:); 
    end

    result=zeros(1, nfeats-1);
    for i=1:nfeats-1,
        efficiency = [];
        for c=1:nclasses,
            datasetC=auxdatasets{c}(:,i);
            for k=(c+1):nclasses,
                datasetK=auxdatasets{k}(:,i);
                minmaxi=min(max(datasetC),max(datasetK));
                maxmini=max(min(datasetC),min(datasetK));
                outoverlap = sum([sum((datasetC<maxmini) | (datasetC>minmaxi)) ...
                                 sum((datasetK<maxmini) | (datasetK>minmaxi))]);
                efficiency = [efficiency outoverlap/nsamples];
            end
        end
        result(1,i) = max(efficiency);
    end
    % We return 1-f such that a small value represents an easy problem
    result = 1-result;
end