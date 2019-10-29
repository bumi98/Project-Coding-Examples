clear all;

% files = dir('*.mat')    ; %%get all text files of the present folder
% N = length(files) ;  % Total number of files

numfiles = 30;
mydata = cell(1, numfiles);

for k = 1:numfiles
    myfilename = sprintf('2yongsstupidstudy_%dmat.mat', k);
    mydata{k} = importdata(myfilename);
end

for k = 1:numfiles
    data = mydata{k};
%     if k == 1 || k == 2 || k == 3 || k ==4
%         data(6).isMoving = []; %Because there were 6 blocks for this I'm deleting 6th one to match.
%         data(6).setSize = [];
%         data(6).colorError = [];
%     end This if for exp1
    
    isMoving = [data.ismoving];
    setSize = [data.setsize];
    colorError = [data.color_error];
    
    setSizeList = [1, 2];
    isMovingList = [0, 1];
    model = WithBias(StandardMixtureModel);
    
    % for i = 1:N
    %    filename = files(i).name ;
    %    fid=fopen(filename,'r');
    
    figure(k); clf;
    count = 1;
    for h=1:length(setSizeList)
        for j=1:length(isMovingList)
            err.errors = colorError(setSize==setSizeList(h) & isMoving==isMovingList(j));
            params(h,j,:) = MLE(err, model);
            
            subplot(2,2,count);
            PlotModelFit(model, params(h,j,:), err);
            title(sprintf('SS: %d, isMoving: %d', setSizeList(h), isMovingList(j)));
            count = count+1;
        end
    end
    
    mu_ss1_stay(k) = params(1,1,1);
    mu_ss1_move(k) = params(1,2,1);
    
    mu_ss2_stay(k) = params(2,1,1);
    mu_ss2_move(k) = params(2,2,1);
    
    sd_ss1_stay(k) = params(1,1,3);
    sd_ss1_move(k) = params(1,2,3);
    
    sd_ss2_stay(k) = params(2,1,3);
    sd_ss2_move(k) = params(2,2,3);
    
end

%Get rid of fifth one because the subject didn't complete it. Also for exp1
% exclude = [5];
% mu_ss1_stay(exclude) = [];
% mu_ss1_move(exclude) = [];
% mu_ss2_stay(exclude) = [];
% mu_ss2_move(exclude) = [];
% sd_ss1_stay(exclude) = [];
% sd_ss1_move(exclude) = [];
% sd_ss2_stay(exclude) = [];
% sd_ss2_move(exclude) = [];

%close all
%Uncomment above if you don't want the graphs.

%% Calculate Means %%
mu_ss1_move_mean = mean(mu_ss1_move);
mu_ss1_stay_mean = mean(mu_ss1_stay);
mu_ss2_move_mean = mean(mu_ss2_move);
mu_ss2_stay_mean = mean(mu_ss2_stay);
sd_ss1_stay_mean = mean(sd_ss1_stay);
sd_ss1_move_mean = mean(sd_ss1_move);
sd_ss2_stay_mean = mean(sd_ss2_stay);
sd_ss2_move_mean = mean(sd_ss2_move);

disp('Mu');
disp(['Set Size 1, Staionary is ', num2str(mu_ss1_stay_mean)]);
disp(['Set Size 1, Moving is ', num2str(mu_ss1_move_mean)]);
disp(['Set Size 2, Staionary is ', num2str(mu_ss2_stay_mean)]);
disp(['Set Size 2, Moving is ', num2str(mu_ss2_move_mean)]);
disp(' ');
disp('Sd');
disp(['Set Size 1, Stationary is ', num2str(sd_ss1_stay_mean)]);
disp(['Set Size 1, Moving is ', num2str(sd_ss1_move_mean)]);
disp(['Set Size 2, Staionary is ', num2str(sd_ss2_stay_mean)]);
disp(['Set Size 2, Moving is ', num2str(sd_ss2_move_mean)]);