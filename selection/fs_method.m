function [resSelection nomSelection] = fs_method(which, inputTrain, XTrain, YTrain, wekapath, nClasses, nAttribs)
%FS_METHOD Obtain a ranking or subset of features according to a feature 
%          selection method.
%   Return the subset or fanking of features selected according to a 
%   feature selection method.
%       - Ranker methods obtain an ordered relevance ranking of features.
%       - Subset methods obtain a subset of most relevance features.
%
%   AUTHORS:
%   -----------------------------------------------------------------------
%   Borja Seijo-Pardo, Veronica Bolon-Canedo, Amparo Alonso-Betanzos
%   Laboratory for Research and Development in Artificial Intelligence
%   (LIDIA Group) Universidad of A Coruna
%
%   INPUTS:
%   -----------------------------------------------------------------------
%   which ---------> Feature selection method. Select one of the following options:
%           1 - ChiSquare                                       *ranker method*
%           2 - InfoGain                                        *ranker method*
%           3 - mRMR (minimun Redundancy Maximun Relevance)     *ranker method*
%           4 - ReliefF                                         *ranker method*
%           5 - SVM-RFE (SVM Recursive Feature Elimination)     *ranker method*
%           6 - FS-P (Feature Selection perceptron)             *ranker method*
%           7 - CFS-BestFirst                                   *subset method*
%           8 - CFS-Forward                                     *subset method*
%           9 - CFS-Greedy-backward                             *subset method*
%   inputTrain ----> Pathname of train file generated with mat2arff function. 
%   XTrain --------> Matrix that represent the dataset (samples and
%                    features). This matrix will have as many rows as
%                    samples and as many columns as features. Therefore, 
%                    this matrix has a size of [sample_size x feature_size].
%   YTrain --------> Matrix that represent the dataset classes. This matrix
%                    will have as many rows as samples and a unique column
%                    that represents the class value. Therefore, this matrix
%                    has a size of [sample_size x 1].
%   wekapath ------> Path to weka .jar file.
%   nClasses ------> Number of unique classes in the dataset.
%   nAttribs ------> Number of dataset features.
%
%   OUTPUTS:
%   -----------------------------------------------------------------------
%   resSelection --> Number of selected features after applied a feature
%                    selection process.
%   nomSelection --> Name of feature selection process applied.

    %% PROCESS
    if (isnumeric(which))
        switch(which)
            case 1, % ChiSquare
                nomSelection = 'ChiSquare';
                sprintf(nomSelection);
                s = evalc(['!java ', wekapath, ' -Xmx4g  weka.attributeSelection.AttributeSelection weka.attributeSelection.ChiSquaredAttributeEval -s "weka.attributeSelection.Ranker -T -1.7976931348623157E308 -N -1" -c last -i "', inputTrain, '"']);
                typeFilter = 1;
            case 2, % InfoGain
                nomSelection = 'InfoGain';
                sprintf(nomSelection);
                s = evalc(['!java ', wekapath, ' -Xmx4g  weka.attributeSelection.AttributeSelection weka.attributeSelection.InfoGainAttributeEval -s "weka.attributeSelection.Ranker -T -1.7976931348623157E308 -N -1" -c last -i "', inputTrain, '"']);
                typeFilter = 1;
            case 3, % mRMR (minimun Redundancy Maximun Relevance)
                nomSelection = 'mRMR';
                sprintf(nomSelection);
                feat_mrmr = mrmr_mid_d(XTrain,YTrain,nAttribs);
                s = feat_mrmr;
                typeFilter = 2;
            case 4, % ReliefF
                nomSelection = 'ReliefF';
                sprintf(nomSelection);
                s = evalc(['!java ', wekapath, ' -Xmx4g  weka.attributeSelection.AttributeSelection weka.attributeSelection.ReliefFAttributeEval -s "weka.attributeSelection.Ranker -T -1.7976931348623157E308 -N -1" -c last -i "', inputTrain, '"']);
                typeFilter = 1;
            case 5, % SVM-RFE (SVM Recursive Feature Elimination)
                nomSelection = 'SVM-RFE';
                sprintf(nomSelection);
                s = evalc(['!java ', wekapath, ' -Xmx4g  weka.attributeSelection.AttributeSelection weka.attributeSelection.SVMAttributeEval -s "weka.attributeSelection.Ranker -T -1.7976931348623157E308 -N  -1" -c last -i "', inputTrain, '"']);
                typeFilter = 1;
            case 6, % FS-P (Feature Selection Perceptron)
                nomSelection = 'FS-P';
                sprintf(nomSelection);
                [N, FS_P2] = FS_P(inputTrain, nClasses, nAttribs, wekapath);
                s = 'success';
                typeFilter = 3;
            case 7, % CFS-BestFirst
                nomSelection = 'CFS-BestFirst';
                sprintf(nomSelection)
                s = evalc(['!java ', wekapath, ' -Xmx8g weka.attributeSelection.AttributeSelection weka.attributeSelection.CfsSubsetEval -s "weka.attributeSelection.BestFirst -N 5" -c last -i ', inputTrain]);
                typeFilter = 1;
            case 8, % CFS-Forward
                nomSelection = 'CFS-Forward';
                sprintf(nomSelection)
                s = evalc(['!java ', wekapath, ' -Xmx8g weka.attributeSelection.AttributeSelection weka.attributeSelection.CfsSubsetEval -s "weka.attributeSelection.LinearForwardSelection -N 5" -c last -i ', inputTrain]);
                typeFilter = 1;
            case 9, % CFS-Greedy-Backward
                nomSelection = 'CFS-Greedy-Backward';
                sprintf(nomSelection)
                s = evalc(['!java ', wekapath, ' -Xmx8g weka.attributeSelection.AttributeSelection weka.attributeSelection.CfsSubsetEval -s "weka.attributeSelection.GreedyStepwise -N -1 -B" -c last -i ', inputTrain]);
                typeFilter = 1;
            otherwise
                nomSelection = 'none';
                sprintf(nomSelection);
                error('filters:incorrectFilter', 'Incorrect filter');
        end;
    else
        error('filters:incorrectFilter', 'Incorrect filter');
    end;
    if ~isempty(findstr(s, 'Weka exception'))
        error('classifier:wekaProblem', 'Weka exception in filter');
    end;

    if typeFilter == 2 % mRMR
        resSelection = feat_mrmr;
    elseif typeFilter == 3 % FS-P
        resSelection = FS_P2;
    else
        % We obtain the variables chosen by the feature selection method.
        t=findstr('Selected attributes:',s);
        result2=s([t+20:length(s)]);
        t=findstr(':',result2);
        filtervars=result2([1:t-1]);
        selection = ['[' filtervars ']'];
        resSelection = eval(selection);
    end




