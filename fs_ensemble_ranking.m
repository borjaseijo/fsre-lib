function [ FRankings, IRankings, FRankings_README, IRankings_README, ...
           FisherTrainValue, OverlapTrainValue, EfficiencyTrainValue ] = ...
    fs_ensemble_ranking( ShowMessage, MXTrain, MYTrain, RankerMethods, ...
                         UnionMethods, ThresholdValues )
%FS_ENSEMBLE_RANKING Obtain relevant subsets of features.
%   Return different subsets of relevant features in a dataset according to 
%   different feature selection methods, union methods and thresholding
%   methods. Both individual and ensemble results are returned.
%
%   AUTHORS:
%   -----------------------------------------------------------------------
%   Borja Seijo-Pardo, Veronica Bolon-Canedo, Amparo Alonso-Betanzos
%   Laboratory for Research and Development in Artificial Intelligence
%   (LIDIA Group) Universidad of A Coruna
%
%   INPUTS:
%   -----------------------------------------------------------------------
%   ShowMessage -----------> Variable that indicates if the progress message
%                            must be showed or no:
%           - logical(0) o false -> don't show progress messages in the screen.
%           - logical(1) o true -> show progress messages in the screen.
%   MXTrain ---------------> Matrix that represent the dataset (samples and
%                            features). This matrix will have as many rows as
%                            samples and as many columns as features. Therefore, 
%                            this matrix has a size of [sample_size x feature_size].
%   MYTrain ---------------> Matrix that represent the dataset classes. This matrix
%                            will have as many rows as samples and a unique column
%                            that represents the class value. Therefore, this matrix
%                            has a size of [sample_size x 1].
%   RankerMethods ---------> Array of feature selection methods used to build
%                            the final ensemble method. Accepted method values range 
%                            from 1 to MAX_FS_METHODS, corresponding with:
%           1 - ChiSquare                                       *ranker method*
%           2 - InfoGain                                        *ranker method*
%           3 - mRMR (minimun Redundancy Maximun Relevance)     *ranker method*
%           4 - ReliefF                                         *ranker method*
%           5 - SVM-RFE (SVM Recursive Feature Elimination)     *ranker method*
%           6 - FS-P (Feature Selection perceptron)             *ranker method*
%           7 - CFS-BestFirst                                   *subset method*
%           8 - CFS-Forward                                     *subset method*
%           9 - CFS-Greedy-backward                             *subset method*
%                            Default ensemble is built by all ranker methods (1 to 6).
%   UnionMethods ----------> Array of combination methods used to join individual
%                            ranking results and obtain a final ranking. Accepted
%                            method values range from 1 to MAX_UNION_METHODS, 
%                            corresponding with:
%           1 - SVM-Rank (default value)
%           2 - Min
%           3 - Median
%           4 - Mean
%           5 - GeomMean
%           6 - Stuart
%           7 - RRA
%   ThresholdValues -------> Array of threshold methods used to cut the final
%                            ranking and obtain a final subset of features. Accepted
%                            method values range from 1 to MAX_THRESHOLD_VALUES, 
%                            corresponding with:
%           1 - Automatic threshold based on Original Fisher Discrimination Ratio (OFDR).
%           2 - Automatic threshold based on Log2(n) Fisher Discrimination Ratio (LFDR).
%           3 - Automatic threshold based on Original Overlap Region (OOR).
%           4 - Automatic threshold based on Log2(n) Overlap Region (LOR).
%           5 - Automatic threshold based on Log2(n) Max Feature Efficiency (LMFE).
%           6 - Automatic threshold based on Log2(n) Complexity Fusion (LCF).
%           7 - Fixed threshold based on selecting log2(n) features.
%           8 - Fixed threshold based on selecting 1% features.
%           9 - Fixed threshold based on selecting 5% features.
%          10 - Fixed threshold based on selecting 10% features.
%          11 - Fixed threshold based on selecting 25% features.
%          12 - Fixed threshold based on selecting 50% features.
%          13 - Fixed threshold based on selecting 100% features.
%
%   CALL FUNCTION EXECUTION EXAMPLE:
%       1 - Load a dataset from folder data_test.
%       2 - Call the function:
%           [F,I,F_README,I_README,Fisher,Overlap,Efficiency] = ...
%                   fs_ensemble_ranking(true, dataset, classes, ...
%                                       [1,2,3,4,5,6], [1,2,3,4,5,6,7], ...
%                                       [1,2,3,4,5,6])
%
%   OUTPUTS:
%   -----------------------------------------------------------------------
%   FRankings -------------> Cell matrix that represents the final feature
%                            rankings. This matrix will have as many rows as
%                            union methods were indicated and as many columns
%                            as threshold methods were selected. Each cell
%                            element refers to a ranking obtained with a 
%                            particular combination and threshold 
%                            configuration. Rows and columns have the same
%                            order as values in the input. For example, if 
%                            UnionMethods = [1,3,5] and ThresholdValues = [2,6],
%                            the FRankings cell matrix will be:
%   
%                           ThresholdValue [2]     ThresholdValue [6]
%       UnionMethod [1] ->     [Ranking 1,2]          [Ranking 1,6]
%       UnionMethod [3] ->     [Ranking 3,2]          [Ranking 3,6]
%       UnionMethod [5] ->     [Ranking 5,2]          [Ranking 5,6]
%   
%   IRankings -------------> Cell matrix that represents the individual feature
%                            rankings according to each individual feature
%                            selection method. This matrix will have as many 
%                            rows as feature selection methods were indicated
%                            and as many columns as threshold methods were
%                            selected. Each cell element refers to a ranking
%                            obtained with a particular feature selection
%                            and threshold configuration. Rows and columns 
%                            have the same order as values in the input. For
%                            example, if RankerMethod = [1,3,5] and 
%                            ThresholdValues = [2,6], the IRankings cell
%                            matrix will be:
%   
%                           ThresholdValue [2]     ThresholdValue [6]
%       RankerMethod [1] ->    [Ranking 1,2]         [Ranking 1,6]
%       RankerMethod [3] ->    [Ranking 3,2]         [Ranking 3,6]
%       RankerMethod [5] ->    [Ranking 5,2]         [Ranking 5,6]
%   
%   FRankings_README ------> Cell matrix that indicates the methods used on
%                            each FRanking matrix cell.
%   IRankings_README ------> Cell matrix that indicates the methods used on
%                            each IRanking matrix cell.
%   FisherTrainValue ------> Array with Fisher Discrimination Ratio values
%                            obtained using "f1_mul" function. Each element
%                            in array corresponds with each dataset feature.
%   OverlapTrainValue -----> Array with Overlap Region values obtained using
%                            "f2_mul" function. Each element in array corresponds
%                            with each dataset feature. 
%   EfficiencyTrainValue --> Array with Max Feature Efficiency values obtained
%                            using "f3_mul" function. Each element in array
%                            corresponds with each dataset feature.

%% MAX STATIC VALUES
MAX_FS_METHODS = 6;
MAX_UNION_METHODS = 7;
MAX_THRESHOLD_VALUES = 13;

UNION_METHODS_LIST = {'svmrank','min','median','mean','geomMean','stuart','RRA'};
cParam = 3; % Number of SVM-Rank parameters.

%% LOAD INITIAL PATH
[wekaPath rootDir] = load_path;

%% DEFAULT VALUES
RankerMethodsDefault = [1,2,3,4,5,6];
UnionMethodsDefault = [1];
ThresholdValuesDefault = [6];

%% PRE-PROCESS

if (nargin >=3)
    if (~islogical(ShowMessage))
        error('ERROR: "ShowMessage" parameter only accept "false" (logical(0)) or "true" (logical(1)) values');
    end
    % nsamples: number of dataset samples.
    % nfeats: number of dataset features.
    [nsamples1, nfeats] = size(MXTrain);
    [nsamples2, nclasses] = size(MYTrain);
    if (nsamples1 ~= nsamples2)
        error('ERROR: Wrong row number between MXTrain and MYTrain input matrix');
    end
    if (nclasses ~= 1)
        error('ERROR: Wrong column number on MYTrain classes matrix. This matrix must have only 1 column.');
    end
else error('ERROR: Wrong parameter number. There must be at least a MXTrain data matrix and a MYTrain classes matrix.');
end

switch(nargin)
    case 3,
        if (ShowMessage)
            sprintf('Default values are used for "RankerMethods", "UnionMethods" and "ThresholdValues"')
        end
        RankerMethods = RankerMethodsDefault;
        UnionMethods = UnionMethodsDefault;
        ThresholdValues = ThresholdValuesDefault;
    case 4,
        if (ShowMessage)
            sprintf('Default values are used for "UnionMethods" and "ThresholdValues"')
        end
        UnionMethods = UnionMethodsDefault;
        ThresholdValues = ThresholdValuesDefault;
    case 5,
        if (ShowMessage)
            sprintf('Default values are used for "ThresholdValues"')
        end
        ThresholdValues = ThresholdValuesDefault;
    case 6,
    otherwise 
        error('ERROR: Wrong parameter number.');
end

% Check the input values.
if ( min(RankerMethods)<1 | max(RankerMethods)>MAX_FS_METHODS )
    error('ERROR: Wrong "RankerMethods" value. Check the accepted values.');
else nRankerMethods = length(RankerMethods);
end
if ( min(UnionMethods)<1 | max(UnionMethods)>MAX_UNION_METHODS )
    error('ERROR: Wrong "UnionMethods" value. Check the accepted values.');
else nUnionMethods = length(UnionMethods);
end
if ( min(ThresholdValues)<1 | max(ThresholdValues)>MAX_THRESHOLD_VALUES )
    error('ERROR: Wrong "ThresholdValues" value. Check the accepted values.');
else nThresholdValues = max(length(ThresholdValues),1);
end

IRankings = cell(nRankerMethods, nThresholdValues);
IRankings_README = cell(nRankerMethods, nThresholdValues);
auxFeatsRanking = cell(nUnionMethods, 1);
FRankings = cell(nUnionMethods, nThresholdValues);
FRankings_README = cell(nUnionMethods, nThresholdValues);
 
%% PROCESS
    % Data normalization
    minVector = min(MXTrain);
    minVector = repmat(minVector,size(MXTrain,1),1);
    maxVector = max(MXTrain);
    maxVector = repmat(maxVector,size(MXTrain,1),1);
    MXTrain = (MXTrain-minVector)./(maxVector-minVector);
    MXTrain(find(isnan(MXTrain)))=1;
    
    FisherTrainValue = f1_mul([MXTrain MYTrain], num2cell(unique(MYTrain))');
    OverlapTrainValue = f2_mul([MXTrain MYTrain], num2cell(unique(MYTrain))');
    EfficiencyTrainValue = f3_mul([MXTrain MYTrain], num2cell(unique(MYTrain))');

    % Store the auxiliary data file to load in Weka framework.
    % Weka needs a input .arff file to call it from command line.
    fileNameTrain = [rootDir filesep 'train.arff'];
    mat2arff(rootDir, fileNameTrain, [MXTrain MYTrain], wekaPath);
    if (ShowMessage)
        sprintf('Auxiliary file has been stored successfully.')
    end
    
    if (ShowMessage)
        sprintf('Starting feature selection process...')
    end
    % Individual feature rankings are calculated for each of feature
    % selection methods indicated by parameter.
    for f=1:nRankerMethods
        [IRankings{f,1}, namefilter] = ...
                    fs_method(RankerMethods(f), fileNameTrain, MXTrain, ...
                              MYTrain, wekaPath, length(unique(MYTrain)), ...
                              nfeats);
        IRankings_aux{f,1} = namefilter;
        if (ShowMessage)
            sprintf('Ranking %s has been calculated successfully.', namefilter)
        end
    end
    % Delete the auxiliary data file .
    delete(fileNameTrain);
    
    % Individual rankings are combined and thresholded according to different
    % methods indicated by parameter. 
    if (nRankerMethods > 1)
        % Ensemble rankings are generated according to union methods
        % indicated by parameter.
        for u=1:nUnionMethods;
            if (ShowMessage)
                sprintf('Calculating the final rankings according to union methods...')
            end
            if UnionMethods(u) == 1
                auxFeatsRanking{u} = svm_rank(IRankings(:,1), rootDir, cParam);
            else
                complete = 1;
                N = [];
                [aggr pval nom] = aggregateRanks(IRankings(:,1)', N, ...
                                        UNION_METHODS_LIST{UnionMethods(u)}, ...
                                        complete, {});
                auxSort = sortrows([aggr nom]);
                auxFeatsRanking{u} = auxSort(:,2);
            end
            sprintf(UNION_METHODS_LIST{UnionMethods(u)})
            featuresNumberFinalRank = size(auxFeatsRanking{u},1);
            if (ShowMessage)
                sprintf('Calculating threshold values for ensemble rankings...')
            end
            for t=1:nThresholdValues
                % The number of features is obtained according to threshold methods
                % indicated by parameter.
                [numAttrib nomThreshold ~] = ...
                    threshold_value(ThresholdValues(t), featuresNumberFinalRank, ...
                                    auxFeatsRanking{u}, FisherTrainValue, ...
                                    OverlapTrainValue, EfficiencyTrainValue);
                sprintf(nomThreshold)
                FRankings{u,t} = (auxFeatsRanking{u}(1:numAttrib))';
                FRankings_README{u,t} = [UNION_METHODS_LIST{UnionMethods(u)} ...
                                        ' x ' nomThreshold];
            end
        end
    else
        if (ShowMessage)
            sprintf('WARNING: Only one feature selection method has been indicated. The use of union methods is omitted.')
        end
        auxFeatsRanking{1} = IRankings{1,1}';
        featuresNumberFinalRank = size(auxFeatsRanking{1},1);
        if (ShowMessage)
            sprintf('Calculating threshold values for ensemble rankings...')
        end
        for t=1:nThresholdValues
            % The number of features is obtained according to threshold methods
            % indicated by parameter.
            [numAttrib nomThreshold ~] = ...
                threshold_value(ThresholdValues(t), featuresNumberFinalRank, ...
                                auxFeatsRanking{1}, FisherTrainValue, ...
                                OverlapTrainValue, EfficiencyTrainValue);
            sprintf(nomThreshold)
            FRankings{1,t} = (auxFeatsRanking{1}(1:numAttrib))';
            FRankings_README{1,t} = [IRankings_README{1,1} ' x ' nomThreshold];
        end
    end
    for f=1:nRankerMethods
        auxFeatsRanking{1} = IRankings{f,1}';
        featuresNumberFinalRank = size(auxFeatsRanking{1},1);
        if (ShowMessage)
            sprintf('Calculating threshold values for individual rankings...')
        end
        for t=1:nThresholdValues
            % The number of features is obtained according to threshold methods
            % indicated by parameter.
            [numAttrib nomThreshold ~] = ...
                threshold_value(ThresholdValues(t), featuresNumberFinalRank, ...
                                auxFeatsRanking{1}, FisherTrainValue, ...
                                OverlapTrainValue, EfficiencyTrainValue);
                            
            sprintf(nomThreshold)
            IRankings{f,t} = (auxFeatsRanking{1}(1:numAttrib))';
            IRankings_README{f,t} = [IRankings_aux{f,1} ' x ' nomThreshold];
        end
    end
end

