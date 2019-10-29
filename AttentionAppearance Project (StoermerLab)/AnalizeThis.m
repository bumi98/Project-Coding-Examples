clear all; close all; clc;

numFiles = 4;
for k = 1:numFiles
    myfilename1 = sprintf('data_%d.mat', k);
    myfilename2 = sprintf('data2block_%d.mat', k);
    load(myfilename1); load(myfilename2);
    
    if d.PSE_t >= d.amplitude_std/0.5*100
        disp(['Test cue attention effect was not there for subject ' num2str(k)]);
    end
    if d.PSE_s <= d.amplitude_std/0.5*100
        disp(['Std cue attention effect was not there for subject ' num2str(k)]);
    end
    
    testcueeff(k) = d.PSE_t;
    stdcueeff(k) = d.PSE_s;
    
    
    performance(k) = t.performance;
   
    
    
   
x1 = [6 13 17 22 29 37 78]; %Contrast values
%x1 = [6 13 22 37 78];
x2 = x1;
y1 = [d.testcue_6 d.testcue_13 d.testcue_17 d.testcue_22 d.testcue_29 d.testcue_37 d.testcue_78];
y2 = [d.stdcue_6 d.stdcue_13 d.stdcue_17 d.stdcue_22 d.stdcue_29 d.stdcue_37 d.stdcue_78];
% y1 = [d.testcue_6 d.testcue_13 d.testcue_22 d.testcue_37 d.testcue_78];
% y2 = [d.stdcue_6 d.stdcue_13 d.stdcue_22 d.stdcue_37 d.stdcue_78];




%Plot TEST CUE
figure(k);
set(gca, 'FontSize', 18); hold on
scatter(x1,y1); hold on
set(gca,'xscale','log')
ylabel('performance'); xlabel('contrast');

%Fit psychometric functions
weights = ones(1,length(x1)); % No weighting (one could potentially way certain x=points more
% do the fit
[coeffs_t, curve_t, threshold_t] = FitPsycheCurveLogit(x1, y1, weights);
% Plot psychometic curves
plot(curve_t(:,1), curve_t(:,2), 'LineStyle', '--', 'color', 'b')
legend('data', 'fit');
% calculate the PSE ( the value returned at 50% performance)
Pb50 = 0.50;
PSE_t(k) = (log(Pb50/(1-Pb50))-coeffs_t(1)/coeffs_t(2));
% calculated from the difference along the x axis between 25% and 75% performance on the y axis.
Pb75 = 0.75;
thresh_t(k) = ((log(Pb50/(1-Pb50))-coeffs_t(1)/coeffs_t(2) - (log(Pb50/(1-Pb50))-coeffs_t(1)/coeffs_t(2)) /2));



%Plot STD CUE
figure(k);
set(gca, 'FontSize', 18); hold on
scatter(x2,y2); hold on
set(gca,'xscale','log')
ylabel('performance'); xlabel('contrast');

%Fit psychometric functions
weights = ones(1,length(x2)); % No weighting (one could potentially way certain x=points more
% do the fit
[coeffs_s, curve_s, threshold_s] = FitPsycheCurveLogit(x2, y2, weights);
% Plot psychometic curves
plot(curve_s(:,1), curve_s(:,2), 'LineStyle', '--', 'color', 'r')
legend('data', 'fit');

% calculate the PSE ( the value returned at 50% performance)
Pb50 = 0.50;
PSE_s(k) = (log(Pb50/(1-Pb50))-coeffs_s(1)/coeffs_s(2));
% calculated from the difference along the x axis between 25% and 75% performance on the y axis.
Pb75 = 0.75;
thresh_s(k) = ((log(Pb50/(1-Pb50))-coeffs_s(1)/coeffs_s(2) - (log(Pb50/(1-Pb50))-coeffs_s(1)/coeffs_s(2)) /2));

    
    
    
end

disp(num2str(mean(testcueeff)));
disp(num2str(mean(stdcueeff)));
disp(num2str(mean(performance)*100));





%--------------------------------------------------------------------------
function [coeffs, curve, threshold] = ...
    FitPsycheCurveLogit(xAxis, yData, weights, targets)

% Transpose if necessary
if size(xAxis,1)<size(xAxis,2)
    xAxis=xAxis';
end
if size(yData,1)<size(yData,2)
    yData=yData';
end
if size(weights,1)<size(weights,2)
    weights=weights';
end

% Check range of data
if min(yData)<0 || max(yData)>1  
     % Attempt to normalise data to range 0 to 1
    yData = yData/(mean([min(yData), max(yData)])*2);
end

% Perform fit
coeffs = glmfit(xAxis, [yData, weights], 'binomial','link','logit');

% Create a new xAxis with higher resolution
fineX = linspace(min(xAxis),max(xAxis),numel(xAxis)*50);
% Generate curve from fit
curve = glmval(coeffs, fineX, 'logit');
curve = [fineX', curve];

% If targets (y) supplied, find threshold (x)
if nargin==4
else
    targets = [0.25, 0.5, 0.75];
end
threshold = (log(targets./(1-targets))-coeffs(1))/coeffs(2);
end    
        
