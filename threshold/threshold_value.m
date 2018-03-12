function [ numFinalFeatures, nomThreshold, typeThreshold, complexAcum] = ...
    threshold_value( which, featuresNumber, featsRanking, FisherTrainValue, ...
                     OverlapTrainValue, EfficiencyTrainValue )
%THRESHOLD_VALUE Obtain the optimal number of features according to a
%                threshold method.
%   Return the number of features selected according to a threshold method.
%       - Automatic thresholds obtain a number of features that minimize
%       the complexity value of subset according to groups of log2(n).
%       - Fixed thresholds obtain the number of features according to a
%       proportion of the total feature number.
%
%   AUTHORS:
%   -----------------------------------------------------------------------
%   Borja Seijo-Pardo, Veronica Bolon-Canedo, Amparo Alonso-Betanzos
%   Laboratory for Research and Development in Artificial Intelligence
%   (LIDIA Group) Universidad of A Coruna
%
%   INPUTS:
%   -----------------------------------------------------------------------
%   which ----------------> Threshold method. Select one of the following options:
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
%   featuresNumber -------> Total number of features of dataset. 
%   featsRanking ---------> Ranking of selected features of dataset.
%   FisherTrainValue -----> Array with Fisher Discrimination Ratio values
%                           obtained using "f1_mul" function. Each element
%                           in array corresponds with each dataset feature.
%   OverlapTrainValue ----> Array with Overlap Region values obtained using
%                           "f2_mul" function. Each element in array corresponds
%                           with each dataset feature. 
%   EfficiencyTrainValue -> Array with Max Feature Efficiency values obtained
%                           using "f3_mul" function. Each element in array
%                           corresponds with each dataset feature.
%
%   OUTPUTS:
%   -----------------------------------------------------------------------
%   numFinalFeatures -----> Number of selected features after applied a threshold
%                           process.
%   nomThreshold ---------> Name of threshold process applied.
%   typeThreshold --------> Type of threshold process applied.
%   complexAcum ----------> Complexity value of the selected subset of
%                           features.

    %% INITIAL STATIC VALUES
    fisherAlfa = 0.9;
    overlapAlfa = 0.9;
    efficiencyAlfa = 0.9;
    fisherAcum = Inf;
    overlapAcum = Inf;
    efficiencyAcum = Inf;
    fusionAcum = Inf;

    %% PROCESS
    if (isnumeric(which))
        switch(which)
            case 1, % Automatic threshold based on Original Fisher Discrimination Ratio (OFDR).
                nomThreshold = 'OFDR';
                fisherAux = FisherTrainValue(:,featsRanking);
                for f=1:featuresNumber
                    auxFeaturesNumber = f/featuresNumber;
                    fisherMin = fisherAlfa*fisherAux(f) + (1-fisherAlfa)*auxFeaturesNumber;
                    if ( (mod(f,5) == 0) && (fisherMin > fisherAcum) )
                        break;
                    end
                    if (fisherMin < fisherAcum)
                        fisherAcum = fisherMin;
                    end
                end
                numFinalFeatures = f;
                typeThreshold = 1;
            case 2, % Automatic threshold based on Log2(n) Fisher Discrimination Ratio (LFDR).
                nomThreshold = 'LFDR';
                % Select an initial subset with log2(n) features.
                numElementsGroup = round(log2(featuresNumber));
                fisherAux = FisherTrainValue(:,featsRanking);
                fisherAVG = 0;                
                for f=1:featuresNumber
                    auxFeaturesNumber = f/featuresNumber;
                    fisherAVG = fisherAVG + fisherAlfa*fisherAux(f) + (1-fisherAlfa)*auxFeaturesNumber;
                    if (mod(f,numElementsGroup) == 0)
                        if ( (fisherAVG/numElementsGroup) > (fisherAcum/(f-numElementsGroup)) )
                            break;
                        end
                        if (f == numElementsGroup)
                            fisherAcum = fisherAVG;
                        else
                            fisherAcum = fisherAcum + fisherAVG;
                        end
                        fisherAVG = 0;
                    end
                end
                complexAcum = fisherAcum;
                numFinalFeatures = (f-numElementsGroup);
                typeThreshold = 1;
            case 3, % Automatic threshold based on Original Overlap Region (OOR).
                nomThreshold = 'OOR';
                overlapAux = OverlapTrainValue(:,featsRanking);
                for f=1:featuresNumber
                    auxFeaturesNumber = f/featuresNumber;
                    overlapMin = overlapAlfa*overlapAux(f) + (1-overlapAlfa)*auxFeaturesNumber;
                    if ( (mod(f,5) == 0) && (overlapMin > overlapAcum) )
                        break;
                    end
                    if (overlapMin < overlapAcum)
                        overlapAcum = overlapMin;
                    end
                end
                numFinalFeatures = f;
                typeThreshold = 1;
            case 4,  % Automatic threshold based on Log2(n) Overlap Region (LOR).
                nomThreshold = 'LOR';
                % Select an initial subset with log2(n) features.
                numElementsGroup = round(log2(featuresNumber));
                overlapAux = OverlapTrainValue(:,featsRanking);
                for f=numElementsGroup:numElementsGroup:featuresNumber
                    overlapSubset = sum(overlapAux(1:f));
                    overlap = efficiencyAlfa*overlapSubset ...
                                    + (1-efficiencyAlfa)*(f/featuresNumber);
                    if (overlap < overlapAcum) || (f==numElementsGroup)
                        overlapAcum = overlap;
                    else
                        break;
                    end
                end
                complexAcum = overlapAcum;
                numFinalFeatures = (f-numElementsGroup);
                typeThreshold = 1;
            case 5, % Automatic threshold based on Log2(n) Max Feature Efficiency (LMFE).
                nomThreshold = 'LMFE';
                % Select an initial subset with log2(n) features.
                numElementsGroup = round(log2(featuresNumber));
                efficiencyAux = EfficiencyTrainValue(:,featsRanking);
                for f=numElementsGroup:numElementsGroup:featuresNumber
                    efficiencySubset = sum(efficiencyAux(1:f));
                    efficiency = efficiencyAlfa*efficiencySubset ...
                                    + (1-efficiencyAlfa)*(f/featuresNumber);
                    if (efficiency < efficiencyAcum) || (f==numElementsGroup)
                        efficiencyAcum = efficiency;
                    else
                        break;
                    end
                end
                complexAcum = efficiencyAcum;
                numFinalFeatures = (f-numElementsGroup);
                typeThreshold = 1;
            case 6, % Automatic threshold based on Log2(n) Complexity Fusion (LCF).
                nomThreshold = 'LCF';
                % Select an initial subset with log2(n) features.
                numElementsGroup = round(log2(featuresNumber));
                fisherAux = FisherTrainValue(:,featsRanking);
                overlapAux = OverlapTrainValue(:,featsRanking);
                efficiencyAux = EfficiencyTrainValue(:,featsRanking);
                fusionAux = (fisherAux+overlapAux+efficiencyAux)/3;
                for f=numElementsGroup:numElementsGroup:featuresNumber
                    fusionSubset = sum(fusionAux(1:f));
                    fusion = efficiencyAlfa*fusionSubset ...
                                    + (1-efficiencyAlfa)*(f/featuresNumber);
                    if (fusion < fusionAcum) || (f==numElementsGroup)
                        fusionAcum = fusion;
                    else
                        break;
                    end
                end
                complexAcum = fusionAcum;
                numFinalFeatures = (f-numElementsGroup);
                typeThreshold = 1;
            case 7, % Fixed threshold based on selecting log2(n) features.
                nomThreshold = 'log2(n)';
                numFinalFeatures = round(log2(featuresNumber));
                typeThreshold = 2;
            case 8, % Fixed threshold based on selecting 1% features.
                nomThreshold = '1%';
                numFinalFeatures = round(0.01*featuresNumber);
                typeThreshold = 3;
            case 9, % Fixed threshold based on selecting 5% features.
                nomThreshold = '5%';
                numFinalFeatures = round(0.05*featuresNumber);
                typeThreshold = 3;
            case 10, % Fixed threshold based on selecting 10% features.
                nomThreshold = '10%';
                numFinalFeatures = round(0.1*featuresNumber);
                typeThreshold = 3;
            case 11, % Fixed threshold based on selecting 25% features.
                nomThreshold = '25%';
                numFinalFeatures = round(0.25*featuresNumber);
                typeThreshold = 3;
            case 12, % Fixed threshold based on selecting 50% features.
                nomThreshold = '50%';
                numFinalFeatures = round(0.50*featuresNumber);
                typeThreshold = 3;
            case 13, % Fixed threshold based on selecting 100% features.
                nomThreshold = '100%';
                numFinalFeatures = featuresNumber;
                typeThreshold = 3;
            otherwise
                error('threhold:incorrect', 'Incorrect threshold value');
        end;
        % Return at least 1 feature.
        if (numFinalFeatures <= 0)
            numFinalFeatures = 1;
        end
    else
        error('threhold:incorrect', 'Incorrect threshold value');
    end;
end

