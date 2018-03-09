function [result] = f1_mul(dataset, classes)
%F1_MUL Obtain the Fisher Discrimination Ratio values on multiclass problems.
%   Return an array with the Fisher Discrimination Ratio values of each
%   dataset feature. Each element in array corresponds with each dataset
%   feature. This function can work with multiclass datasets.
%
%   AUTHORS:
%   -----------------------------------------------------------------------
%   Borja Seijo-Pardo, Veronica Bolon-Canedo, Amparo Alonso-Betanzos
%   Laboratory for Research and Development in Artificial Intelligence
%   (LIDIA Group) Universidad of A Coruna
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
%   result ----> Array with Fisher Discrimination Ratio values obtained.
%                Each element in array corresponds with each dataset feature.

    %% PROCESS
    [nsamples, nfeats] = size(dataset);
    class = dataset(:,end);

    if (nfeats==1)
        result = 9999999;
    else
        nclasses = length(classes);
        f_feats = zeros(1,nfeats-1);

        auxdatasets = {};
        samples_per_class = zeros(1,nclasses); 
        proportions = zeros(1,nclasses);

        for c=1:nclasses
            auxdatasets{c} = dataset(class==classes{c},:);
            samples_per_class(c) = size(auxdatasets{c},1);
            proportions(c) = samples_per_class(c)/nsamples;
        end

        for i=1:nfeats-1,
            sumMean = 0;
            sumVar = 0;
            for c=1:nclasses,
                datasetC = auxdatasets{c}(:,i);
                for k=(c+1):nclasses,
                    datasetK = auxdatasets{k}(:,i);
                    sumMean = sumMean + (((mean(datasetC) - mean(datasetK))^2) * proportions(c) * proportions(k));
                end
                sumVar = sumVar + (var(datasetC) * proportions(c));
            end
            if (sumVar == 0 & sumMean == 0) f_feats(i) = 0;
            else f_feats(i) = sumMean/sumVar;
            end
        end
        f_feats(find(f_feats==0)) = min(f_feats(find(f_feats~=0)));
        % We return 1/f such that a small value represents an easy problem
        result= 1./f_feats;
        % The result is normalized
        result = result/norm(result);
    end
end