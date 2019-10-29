%Let's analyze!
clear all;
clc;
%% Load the data
numfiles = 12;
% mydata = cell(1,numfiles);
% for k = 1:numfiles
%     myfilename = sprintf('ImPing_S0%d.mat',k);
%     mydata{k} = importdata(myfilename);
% end
for k = 1:numfiles %Loop it so I do all the data.
    if k == 4
        k = k+1;
    end
    if k == 5
        k = k+1;
    end
    if k == 6
        k = k+1;
    end
    if k == 9
        k = k+1;
    end
    if k == 10
        k = k+1;
    end
    if k<10
        myfilename = sprintf('ImPing_S0%d.mat',k);
    else
        myfilename = sprintf('ImPing_S%d.mat',k);
    end
    load(myfilename);

%load('ImPing_S12.mat');

%% Set variables
nBlock = length(TheData); %How many runs they did.
nTrial = 0; %total number of trials
for i = 1:nBlock
    Trials(1,i) = length(TheData(i).TrialStuff);
    nTrial = nTrial+Trials(1,i);
end

%Find the number of trials in each cond. in each run
for j = 1:nBlock
    %If the run was quit in the middle, just skip it.
    if length(TheData(j).TrialStuff) ~= length(TheData(j).data.rightwrong)
        disp(['run number ' num2str(j) ' was skipped']);
        j = j+1;
    end
    condition = [TheData(j).TrialStuff.rotation];
    tmp1 = (TheData(j).data.rightwrong(condition==0));
    tmp2 = (TheData(j).data.rightwrong(condition==-45));
    tmp3 = (TheData(j).data.rightwrong(condition==45));
    nt_wr(1,j) = length(tmp1(~isnan(tmp1)));
    nt_ccw(1,j) = length(tmp2(~isnan(tmp2)));
    nt_cw(1,j) = length(tmp3(~isnan(tmp3)));
end
%all conditions combined should equal to 80*nBlock
if sum(nt_wr)+sum(nt_ccw)+sum(nt_cw) ~= 80*nBlock
    disp('number of conditions do not all match');
end
%There should be 40 wr trials, 20 ccw, and 20 cw in each run.
howmanytrial_wr(1,k) = sum(nt_wr);
howmanytrial_ccw(1,k) = sum(nt_ccw);
howmanytrial_cw(1,k) = sum(nt_cw);

%% Display subject number
disp(' ')
disp(['Subject ' num2str(k)]);

%% Show final threshold
disp(' ')
disp('FINAL THRESHOLDS')
disp(['   --> without rotation: ' num2str(nanmean(TheData(nBlock).data.OrientEstimated_0(end-4:end))) ' deg'])
disp(['   --> ccw rotation: ' num2str(nanmean(TheData(nBlock).data.OrientEstimated_ccw(end-4:end))) ' deg'])
disp(['   --> cw rotation: ' num2str(nanmean(TheData(nBlock).data.OrientEstimated_cw(end-4:end))) ' deg'])
%Save it to an array
thres_wr(1,k) = nanmean(TheData(nBlock).data.OrientEstimated_0(end-4:end));
thres_ccw(1,k) = nanmean(TheData(nBlock).data.OrientEstimated_ccw(end-4:end));
thres_cw(1,k) = nanmean(TheData(nBlock).data.OrientEstimated_cw(end-4:end));
%% Accuracy
%Here I'm getting the actual scores of all the trials then dividing by
%total numbers of trials in each condition.
for j = 1:nBlock
    %If the run was quit in the middle, just skip it.
    if length(TheData(j).TrialStuff) ~= length(TheData(j).data.rightwrong)
        j = j+1;
    end
    condition = [TheData(j).TrialStuff.rotation];
    tmpacc_wr(1,j) = nanmean(TheData(j).data.rightwrong(condition==0))*nt_wr(1,j);
    tmpacc_ccw(1,j) = nanmean(TheData(j).data.rightwrong(condition==-45))*nt_ccw(1,j);
    tmpacc_cw(1,j) = nanmean(TheData(j).data.rightwrong(condition==45))*nt_cw(1,j);
end
totalacc_wr(1,k) = sum(tmpacc_wr); %for later calculating total result
totalacc_ccw(1,k) = sum(tmpacc_ccw);
totalacc_cw(1,k) = sum(tmpacc_cw);
acc_wr = sum(tmpacc_wr)/sum(nt_wr);
acc_ccw = sum(tmpacc_ccw)/sum(nt_ccw);
acc_cw = sum(tmpacc_cw)/sum(nt_cw);
disp(' ')
disp('ACCURACY')
disp(['   --> without rotation: ' num2str(acc_wr*100) '%']);
disp(['   --> ccw rotation: ' num2str(acc_ccw*100) '%']);
disp(['   --> cw rotation: ' num2str(acc_cw*100) '%']);
end

%% Show Final Total Results
%First get rid of 0s due to empty subject number.
%For accuracy it's okay since I'm taking a sum anyway.
thres_wr = thres_wr(thres_wr~=0);
thres_ccw = thres_ccw(thres_ccw~=0);
thres_cw = thres_cw(thres_cw~=0);

disp(' ')
disp('Total Threshold Estimates')
disp(['   --> without rotation: ' num2str(sum(thres_wr)/length(thres_wr)) ' deg'])
disp(['   --> ccw rotation: ' num2str(sum(thres_ccw)/length(thres_ccw)) ' deg'])
disp(['   --> cw rotation: ' num2str(sum(thres_cw)/length(thres_cw)) ' deg'])

disp(' ')
disp('Total Performance')
disp(['   --> without rotation: ' num2str(sum(totalacc_wr)/sum(howmanytrial_wr)*100) '%']);
disp(['   --> ccw rotation: ' num2str(sum(totalacc_ccw)/sum(howmanytrial_ccw)*100) '%']);
disp(['   --> cw rotation: ' num2str(sum(totalacc_cw)/sum(howmanytrial_cw)*100) '%']);

%% Error Distribution
% error = response-answer.
% This means negative error = response was too counterclockwise.
for j = 1:nBlock
    %If the run was quit in the middle, just skip it.
    if length(TheData(j).TrialStuff) ~= length(TheData(j).data.rightwrong)
        j = j+1;
    end
    for t = 1:length(TheData(j).TrialStuff)
        ori_error(j,t) = TheData(j).data.RespContinuous(t)-TheData(j).TrialStuff(t).orient;
        if TheData(j).data.RespContinuous(t)-TheData(j).TrialStuff(t).orient > 90
            ori_error(j,t) = TheData(j).data.RespContinuous(t)-TheData(j).TrialStuff(t).orient+180;
        elseif TheData(j).data.RespContinuous(t)-TheData(j).TrialStuff(t).orient < -90
            ori_error(j,t) = TheData(j).data.RespContinuous(t)+180-TheData(j).TrialStuff(t).orient;
        end
        
        
    end
end



