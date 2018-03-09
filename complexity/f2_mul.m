function [result] = f2_mul (dataset, classes)
%F2_MUL Obtain the Overlap Region values on multiclass problems.
%   Return an array with the Overlap Region values of each dataset feature.
%   Each element in array corresponds with each dataset feature. This
%   function can work with multiclass datasets.
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
%   result ----> Array with Overlap Region values obtained. Each element in
%                array corresponds with each dataset feature.

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
        for c=1:nclasses-1,
            datasetC=auxdatasets{c}(:,i);
            for k=(c+1):nclasses,
                datasetK=auxdatasets{k}(:,i);
                minmaxi=min(max(datasetC),max(datasetK));
                maxmini=max(min(datasetC),min(datasetK));
                maxmaxi=max(max(datasetC),max(datasetK));
                minmini=min(min(datasetC),min(datasetK));
                %Classical approach 
                if ( (minmaxi-maxmini) == 0 && (maxmaxi-minmini) == 0)
                    result(1,i) = result(1,i) + 1;
                else
                    result(1,i) = result(1,i) + (max(0,minmaxi-maxmini)/(maxmaxi-minmini));
                end
%                % Microarray improved approach replacing plus by times.
%                if (nsamples > nfeats)
%                    if ( (minmaxi-maxmini) == 0 && (maxmaxi-minmini) == 0)
%                        result(1,i) = result(1,i) * 1;
%                    else
%                        result(1,i) = result(1,i) * (max(0,minmaxi-maxmini)/(maxmaxi-minmini));
%                    end
%                end
            end
        end
    end
end