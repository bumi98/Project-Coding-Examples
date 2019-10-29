clear all; close all;

%% Initializating
Screen('Preference', 'SkipSyncTests', 1); % TAKE THIS OUT FOR REAL EXPERIMENT!!!
% -----------------------
% Prefs and init
prefs = Preferences();
[win, sid] = Initialize(prefs);
% Information about the screen
rct = Screen('Rect', prefs.monitor);
centerScreen = [rct(3)./2 rct(4)./2]; % x, y
xCenter = centerScreen(1);
yCenter = centerScreen(2);
[window.screenX, window.screenY] = Screen('WindowSize', win); % check resolution
window.screenRect  = [0 0 window.screenX window.screenY]; % screen rect
window.centerX = window.screenX * 0.5; % center of screen in X direction
window.centerY = window.screenY * 0.5; % center of screen in Y direction
window.centerXL = floor(mean([0 window.centerX])); % center of left half of screen in X direction
window.centerXR = floor(mean([window.centerX window.screenX])); % center of right half of screen in X direction
vbl = Screen('Flip', win);
flipSpd = 1; %2 for my Windows laptop! %Flip speed
% dispTime = 3; %3 seconds display.....DISPLAY will be 2.5 - 3.5
monitorFlipInterval = Screen('GetFlipInterval', win);
%Colors
black = [0 0 0];
white = [255 255 255];
red = [255 0 0];
green = [0 255 0];
blue = [0 0 255];

%% Create trial struct
%It's gotta have test-cue, std-cue, test-left-std-right,
%std-right-test-left
%test will be 6, 13, 22, 37, 78 and std will always be 22
nTrial = 84; %For now. do multiples of 28.
d.nTrial = nTrial;
%Let's make test-cue 1 and std-cue 2
trialstruct(1,1:nTrial/2) = 1;
trialstruct(1,nTrial/2+1:nTrial) = 2;
%and then 3 test-left, 4 test-right
trialstruct(2, 1:2:nTrial) = 3;
trialstruct(2, 2:2:nTrial) = 4;
%now there will be 5 different test contrasts;
trialstruct(3, 1:nTrial/28) = 6;
trialstruct(3, nTrial/28+1:3*nTrial/28) = 13; %trialstruct(3, nTrial/20+1:nTrial/20+nTrial/10) = 13;
trialstruct(3, 3*nTrial/28+1:5*nTrial/28) = 17;
trialstruct(3, 5*nTrial/28+1:9*nTrial/28) = 22; %trialstruct(3, nTrial/20+nTrial/10+1:nTrial/20+nTrial/10+nTrial/5) = 22;
trialstruct(3, 9*nTrial/28+1:11*nTrial/28) = 29; %trialstruct(3, 7*nTrial/20+1: 7*nTrial/20+nTrial/10) = 37;
trialstruct(3, 11*nTrial/28+1:13*nTrial/28) = 37;
trialstruct(3, 13*nTrial/28+1:14*nTrial/28) = 78;
trialstruct(3, 14*nTrial/28+1:15*nTrial/28) = 78;
trialstruct(3, 15*nTrial/28+1:17*nTrial/28) = 37;
trialstruct(3, 17*nTrial/28+1:19*nTrial/28) = 29;
trialstruct(3, 19*nTrial/28+1:23*nTrial/28) = 22;
trialstruct(3, 23*nTrial/28+1:25*nTrial/28) = 17;
trialstruct(3, 25*nTrial/28+1:27*nTrial/28) = 13;
trialstruct(3, 27*nTrial/28+1:end) = 6;

%Now Randomize
trialstruct = Shuffle(trialstruct, 1);
d.trialstruct = trialstruct;

%% Set Parameters
d.amplitude_std = 0.22*0.5; %Stays 22%
%Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); %For masking transparency.
% Get buttons
KbName('UnifyKeyNames');
left_targ = KbName('n');    % left
right_targ =  KbName('m');    % right
quitkey = KbName('q');

instructions = 'Choose the orientation with higher contrast';
nBlocks = 1; %For now

%% Prepare stuff (sizing)
targetSize = angle2pix(prefs,3);
eccentricity = angle2pix(prefs,36);
fixSize = angle2pix(prefs,0.1);
d.targetSize = targetSize;
d.eccentricity = eccentricity;
d.fixSize = fixSize;

%% Positions
%Left = [(window.centerX - eccentricity), (window.centerY - targetSize/2) , (window.centerX - eccentricity + targetSize), (window.centerY + targetSize/2)];
%Right= [(window.centerX + eccentricity - targetSize), (window.centerY - targetSize/2), (window.centerX + eccentricity ), (window.centerY  + targetSize/2)];
Left = [(window.centerX-500-targetSize), (window.centerY - targetSize), (window.centerX-500+targetSize), (window.centerY+targetSize)];
Right = [(window.centerX+500-targetSize), (window.centerY - targetSize), (window.centerX+500+targetSize), (window.centerY+targetSize)];
cue_Left = [(window.centerX-500-targetSize/3/2), (window.centerY - targetSize), (window.centerX-500+targetSize/3/2), (window.centerY-2*targetSize/3)];
%((cx-500+ts)-(cs-500-ts)) --> this is length of the target.It's basically
%2*targetsize. I'm making the cue smaller. Then cy-ts+1/2ts for y
%coordinate.
cue_Right = [(window.centerX+500-targetSize/3/2), (window.centerY - targetSize), (window.centerX+500+targetSize/3/2), (window.centerY-2*targetSize/3)];
FixRect = [window.centerX - fixSize, window.centerY - fixSize, window.centerX + fixSize, window.centerY + fixSize];
FixCircle = [window.centerX - fixSize*2, window.centerY - fixSize*2, window.centerX + fixSize*2, window.centerY + fixSize*2];

%% Timing
d.preFixTime = 0.500;
d.STmax = 0.800;
d.STmin = 0.500;
d.targetTime = 0.050; %It was 0.040 in Carrasco 2004...
d.cueISI = 0.053;
d.visualcueLength = 0.067; %in ms
%Copied Carrasco 2004

%% Experiment
Screen(win, 'TextFont', 'Arial');
Screen('DrawText', win, instructions, xCenter-400, yCenter); %instruction
[keyIsDown, secs, keyCode] = KbCheck();
Screen('Flip', win);
while (~any(keyCode(KbName('space'))))
    [keyIsDown, secs, keyCode] = KbCheck();
end
%Hide cursor
HideCursor();

for curBlock = 1:nBlocks %IF multiple blocks, do d(curBlock).
    Screen('DrawText', win, ['You are now entering Block ', num2str(curBlock)], xCenter-250, yCenter);
    Screen('Flip', win);
    KbStrokeWait();
    
    %Trial
    for curTrial = 1:nTrial
        Screen('DrawText', win, 'Press SpaceBar to start experiment', xCenter-200, yCenter);
        Screen('Flip', win);
        KbStrokeWait();
        
        if trialstruct(2,curTrial) == 3
            d.testlocation{curTrial} = 'Left';
            testlocation = Left;
            d.stdlocation{curTrial} = 'Right';
            stdlocation = Right;
        elseif trialstruct(2,curTrial) == 4
            d.testlocation{curTrial} = 'Right';
            testlocation = Right;
            d.stdlocation{curTrial} = 'Left';
            stdlocation = Left;
        end
        
        %Set cue location
        if trialstruct(1,curTrial) == 1
            if trialstruct(2,curTrial) == 3 %testcue, testleft stdright
                d.cuelocation(curTrial) = d.testlocation(curTrial);
                cuelocation = cue_Left;
            elseif trialstruct(2,curTrial) == 4 %testcue, testrightstd left
                d.cuelocation(curTrial) = d.testlocation(curTrial);
                cuelocation = cue_Right;
            end
        elseif trialstruct(1,curTrial) == 2
            if trialstruct(2,curTrial) == 3 %stdcue, testleft stdright
                d.cuelocation(curTrial) = d.stdlocation(curTrial);
                cuelocation = cue_Right;
            elseif trialstruct(2,curTrial) == 4 %testcue, testright stdleft
                d.cuelocation(curTrial) = d.stdlocation(curTrial);
                cuelocation = cue_Left;
            end
        end
        
        %Determine the test contrast
        d.amplitude_test(curTrial) = trialstruct(3,curTrial)/100*0.5;
%         if trialstruct(3,curTrial) == 6
%             d.amplitude_test(curTrial) = 0.06*0.5;
%         elseif trialstruct(3,curTrial) == 13
%             d.amplitude_test(curTrial) = 0.13*0.5;
%         elseif trialstruct(3,curTrial) == 17
%             d.amplitude_test(curTrial) = 0.17*0.5;
%         elseif trialstruct(3,curTrial) == 22
%             d.amplitude_test(curTrial) = 0.22*0.5;
%         elseif trialstruct(3,curTrial) == 29
%             d.amplitude_test(curTrial) = 0.29*0.5;
%         elseif trialstruct(3,curTrial) == 37
%             d.amplitude_test(curTrial) = 0.37*0.5;
%         elseif trialstruct(3,curTrial) == 78
%             d.amplitude_test(curTrial) = 0.78*0.5; %Seems like 0.5 is the maximum so re-scale it.
%         end
        
        % Phase information for Gabor
        if rand(1) > 0.5, d.phase(curTrial) = 0;
        else d.phase(curTrial) = 1;
        end %shift phase randomly
        
        %Orientation should be either 45 or -45 and never same. 2AFC.
        d.testTilt(curTrial) = randi([1 2], 1);
        if d.testTilt(curTrial) == 1
            d.testTilt(curTrial) = 45;
            d.stdTilt(curTrial) = -45;
        else
            d.testTilt(curTrial) = -45;
            d.stdTilt(curTrial) = 45;
        end
        
        % Time between trials
        d.ITI(curTrial) = (d.STmax-d.STmin).* rand(1) + d.STmin;
        
        I_test = CreateGabor(d.testTilt(curTrial), d.phase(curTrial), d.amplitude_test(curTrial));
        gabor_test = Screen('MakeTexture', win, I_test);
        I_std = CreateGabor(d.stdTilt(curTrial), d.phase(curTrial), d.amplitude_std);
        gabor_std = Screen('MakeTexture', win, I_std);
        
        % -----------------------------------------------
        % Get ready fixation dot
        Screen('FillRect',win, prefs.backColor, rct); %Background
        Screen('FillOval', win,  black, FixRect);
        Screen('Flip', win);
        WaitSecs(d.preFixTime);
        
        % Trial starts
        Screen('FillRect',win, prefs.backColor, rct);
        %         Screen('FrameOval', win, black, Left, 1);
        %         Screen('FrameOval', win, black, Right, 1);
        Screen('FillOval', win,  black, FixRect);
        Screen('FrameOval', win, black, FixCircle);
        Screen('Flip', win);
        WaitSecs(d.ITI(curTrial)); % jittered
        
        % Visual cue
        Screen('FillRect', win, prefs.backColor, rct);
        Screen('FillOval', win,  black, FixRect);
        Screen('FrameOval', win, black, FixCircle);
        Screen('FillOval', win, black, cuelocation); %This is cue.
        Screen('Flip', win);
        
        WaitSecs(d.visualcueLength);
        
        % ISI
        Screen('FillRect',win, prefs.backColor, rct);
        %         Screen('FrameOval', win, black, Left, 1);
        %         Screen('FrameOval', win, black, Right, 1);
        Screen('FillOval', win,  black, FixRect);
        Screen('FrameOval', win,  black,FixCircle);
        Screen('Flip', win);
        WaitSecs(d.cueISI);
        
        %Present Gabors
        Screen('FillRect', win, prefs.backColor, rct);
        Screen('DrawTexture', win, gabor_test, [], testlocation);
        Screen('DrawTexture', win, gabor_std, [], stdlocation);
        Screen('FillOval', win,  black, FixRect);
        Screen('FrameOval', win, black, FixCircle);
        Screen('Flip', win);
        
        WaitSecs(d.targetTime);
        
        %Response
        Screen('FillRect', win, prefs.backColor, rct);
        Screen('Flip', win);
        
        time0=GetSecs(); %?
        %Get response 1 - left, 2 - right
        while 1
            [keyIsDown,secs, keyCode] = KbCheck();
            if keyIsDown
                if keyCode(left_targ)
                    d.response(curTrial) = 1; d.RT(curTrial) = (secs-time0)*1000; break;
                elseif keyCode(right_targ)
                    d.response(curTrial) = 2; d.RT(curTrial) = (secs-time0)*1000; break;
                elseif keyCode(quitkey)
                    d.response(curTrial) = NaN; d.RT(curTrial) = NaN; Screen('CloseAll'); sca; break;
                end
            end
        end
        
        %Check the right answer
        if d.amplitude_test(curTrial) > d.amplitude_std %If test is higher than std.
            if trialstruct(2,curTrial) == 3
                d.answer(curTrial) = 1;
            elseif trialstruct(2, curTrial) == 4
                d.answer(curTrial) = 2;
            end
        elseif d.amplitude_test(curTrial) < d.amplitude_std
            if trialstruct(2,curTrial) == 3
                d.answer(curTrial) = 2;
            elseif trialstruct(2, curTrial) == 4
                d.answer(curTrial) = 1;
            end
        elseif d.amplitude_test(curTrial) == d.amplitude_std
            d.answer(curTrial) = 0;
        end
        
        %Compute Accuracy
        if d.response(curTrial) == d.answer(curTrial)
            d.trialaccuracy(curTrial) = 1;
        else
            d.trialaccuracy(curTrial) = 0;
        end
        
        %Check whether or not participant has chosen test Gabor.
        if trialstruct(2, curTrial) == 3 %test left
            if d.response(curTrial) == 1 %if response left
                d.istest(curTrial) = 1;
            elseif d.response(curTrial) == 2 %if response right
                d.istest(curTrial) = 2;
            end
        elseif trialstruct(2, curTrial) == 4 %test right
            if d.response(curTrial) == 1 %if response left
                d.istest(curTrial) = 2;
            elseif d.response(curTrial) == 2 %if response right
                d.istest(curTrial) = 1;
            end
        end
        
        
    end
end

sca

%% Results

for i = 1:length(trialstruct)
    if trialstruct(1,i) == 1 %if testcue
        if trialstruct(3,i) == 6
            %testcue_acc_6(i) = d.trialaccuracy(i);
            testcue_6(i) = d.istest(i);
        elseif trialstruct(3,i) == 13
            %testcue_acc_13(i) = d.trialaccuracy(i);
            testcue_13(i) = d.istest(i);
        elseif trialstruct(3,i) == 17
            testcue_17(i) = d.istest(i);
        elseif trialstruct(3,i) == 22
            %testcue_acc_22 = d.trialaccuracy(i);
            testcue_22(i) = d.istest(i);
        elseif trialstruct(3,i) == 29
            testcue_29(i) = d.istest(i);
        elseif trialstruct(3,i) == 37
            %testcue_acc_37 = d.trialaccuracy(i);
            testcue_37(i) = d.istest(i);
        elseif trialstruct(3,i) == 78
            %testcue_acc_78 = d.trialaccuracy(i);
            testcue_78(i) = d.istest(i);          
        end
    elseif trialstruct(1,i) == 2 %if stdcue
        if trialstruct(3,i) == 6
            %stdcue_acc_6(i) = d.trialaccuracy(i);
            stdcue_6(i) = d.istest(i);
        elseif trialstruct(3,i) == 13            
            %stdcue_acc_13(i) = d.trialaccuracy(i);
            stdcue_13(i) = d.istest(i);
        elseif trialstruct(3,i) == 17
            stdcue_17(i) = d.istest(i);
        elseif trialstruct(3,i) == 22            
            %stdcue_acc_22 = d.trialaccuracy(i);
            stdcue_22(i) = d.istest(i);
        elseif trialstruct(3,i) == 29
            stdcue_29(i) = d.istest(i);
        elseif trialstruct(3,i) == 37           
            %stdcue_acc_37 = d.trialaccuracy(i);
            stdcue_37(i) = d.istest(i);
        elseif trialstruct(3,i) == 78           
            %stdcue_acc_78 = d.trialaccuracy(i);
            stdcue_78(i) = d.istest(i);         
        end
    end
end

% testcue_acc_6 = testcue_acc_6(testcue_acc_6~=0);
% testcue_acc_13 = testcue_acc_13(testcue_acc_13~=0);
% testcue_acc_22 = testcue_acc_22(testcue_acc_22~=0);
% testcue_acc_37 = testcue_acc_37(testcue_acc_37~=0);
% testcue_acc_78 = testcue_acc_78(testcue_acc_78~=0);
testcue_6 = testcue_6(testcue_6~=0);
testcue_13 = testcue_13(testcue_13~=0);
testcue_17 = testcue_17(testcue_17~=0);
testcue_22 = testcue_22(testcue_22~=0);
testcue_29 = testcue_29(testcue_29~=0);
testcue_37 = testcue_37(testcue_37~=0);
testcue_78 = testcue_78(testcue_78~=0);
% stdcue_acc_6 = stdcue_acc_6(stdcue_acc_6~=0);
% stdcue_acc_13 = stdcue_acc_13(stdcue_acc_13~=0);
% stdcue_acc_22 = stdcue_acc_22(stdcue_acc_22~=0);
% stdcue_acc_37 = stdcue_acc_37(stdcue_acc_37~=0);
% stdcue_acc_78 = stdcue_acc_78(stdcue_acc_78~=0);
stdcue_6 = stdcue_6(stdcue_6~=0);
stdcue_13 = stdcue_13(stdcue_13~=0);
stdcue_17 = stdcue_17(stdcue_17~=0);
stdcue_22 = stdcue_22(stdcue_22~=0);
stdcue_29 = stdcue_29(stdcue_29~=0);
stdcue_37 = stdcue_37(stdcue_37~=0);
stdcue_78 = stdcue_78(stdcue_78~=0);

for j = 1:length(testcue_6)
    if testcue_6(j) == 2, testcue_6(j) = 0; end
end
for j = 1:length(testcue_13)
    if testcue_13(j) == 2, testcue_13(j) = 0; end
end
for j = 1:length(testcue_17)
    if testcue_17(j) == 2, testcue_17(j) = 0; end
end
for j = 1:length(testcue_22)
    if testcue_22(j) == 2, testcue_22(j) = 0; end
end
for j = 1:length(testcue_29)
    if testcue_29(j) == 2, testcue_29(j) = 0; end
end
for j = 1:length(testcue_37)
    if testcue_37(j) == 2, testcue_37(j) = 0; end
end
for j = 1:length(testcue_78)
    if testcue_78(j) == 2, testcue_78(j) = 0; end
end
for j = 1:length(stdcue_6)
    if stdcue_6(j) == 2, stdcue_6(j) = 0; end
end
for j = 1:length(stdcue_13)
    if stdcue_13(j) == 2, stdcue_13(j) = 0; end
end
for j = 1:length(stdcue_17)
    if stdcue_17(j) == 2, stdcue_17(j) = 0; end
end
for j = 1:length(stdcue_22)
    if stdcue_22(j) == 2, stdcue_22(j) = 0; end
end
for j = 1:length(stdcue_29)
    if stdcue_29(j) == 2, stdcue_29(j) = 0; end
end
for j = 1:length(stdcue_37)
    if stdcue_37(j) == 2, stdcue_37(j) = 0; end
end
for j = 1:length(stdcue_78)
    if stdcue_78(j) == 2, stdcue_78(j) = 0; end
end


%Accuracy overall for testcue and stdcue
for i = 1:length(trialstruct)
    if trialstruct(1,i) == 1
        tcac(i) = d.trialaccuracy(i);
        stac(i) = 99;
    elseif trialstruct(1,i) == 2
        stac(i) = d.trialaccuracy(i);
        tcac(i) = 99;
    end
end

tcac = tcac(tcac~=99);
stac = stac(stac~=99);

d.testcue_6 = mean(testcue_6);
d.testcue_13 = mean(testcue_13);
d.testcue_17 = mean(testcue_17);
d.testcue_22 = mean(testcue_22);
d.testcue_29 = mean(testcue_29);
d.testcue_37 = mean(testcue_37);
d.testcue_78 = mean(testcue_78);
d.stdcue_6 = mean(stdcue_6);
d.stdcue_13 = mean(stdcue_13);
d.stdcue_17 = mean(stdcue_17);
d.stdcue_22 = mean(stdcue_22);
d.stdcue_29 = mean(stdcue_29);
d.stdcue_37 = mean(stdcue_37);
d.stdcue_78 = mean(stdcue_78);
%% Display

disp(['Overall Accuracy test cue std cue']);
disp([mean(tcac), mean(stac)]);
disp(' '); disp(' '); %spaces
% disp(['Testcue Accuracy']);
% disp([mean(testcue_acc_6), mean(testcue_acc_13), mean(testcue_acc_22), mean(testcue_acc_37), mean(testcue_acc_78)]);
disp(['Testcue TestSelected Percentage']);
disp([mean(testcue_6), mean(testcue_13), mean(testcue_17), mean(testcue_22), mean(testcue_29), mean(testcue_37), mean(testcue_78)]);
disp(' '); disp(' ');
% disp(['Standardcue Accuracy']);
% disp([mean(stdcue_acc_6), mean(stdcue_acc_13), mean(stdcue_acc_22), mean(stdcue_acc_37), mean(stdcue_acc_78)]);
disp(['Standardcue TestSelected Percentage']);
disp([mean(stdcue_6), mean(stdcue_13), mean(stdcue_17), mean(stdcue_22), mean(stdcue_29), mean(stdcue_37), mean(stdcue_78)]);

%% Curve
x1 = [6 13 17 22 29 37 78]; %Contrast values
x2 = x1;
y1 = [mean(testcue_6) mean(testcue_13) mean(testcue_17) mean(testcue_22) mean(testcue_29) mean(testcue_37) mean(testcue_78)];
y2 = [mean(stdcue_6) mean(stdcue_13) mean(stdcue_17) mean(stdcue_22) mean(stdcue_29) mean(stdcue_37) mean(stdcue_78)];

%Plot TEST CUE
figure(1);
set(gca, 'FontSize', 18); hold on
scatter(x1,y1); hold on
set(gca,'xscale','log')
ylabel('performance'); xlabel('contrast');

%Fit psychometric functions
weights = ones(1,length(x1)); % No weighting (one could potentially way certain x=points more
% do the fit
[coeffs_t, curve_t, threshold_t] = FitPsycheCurveLogit(x1, y1, weights);
% Plot psychometic curves
plot(curve_t(:,1), curve_t(:,2), 'LineStyle', '--')
legend('data', 'fit');

% calculate the PSE ( the value returned at 50% performance)
Pb50 = 0.50;
d.PSE_t = (log(Pb50/(1-Pb50))-coeffs_t(1)/coeffs_t(2))
% calculated from the difference along the x axis between 25% and 75% performance on the y axis.
Pb75 = 0.75;
d.thresh_t = ((log(Pb50/(1-Pb50))-coeffs_t(1)/coeffs_t(2) - (log(Pb50/(1-Pb50))-coeffs_t(1)/coeffs_t(2)) /2));



%Plot STD CUE
figure(2);
set(gca, 'FontSize', 18); hold on
scatter(x2,y2); hold on
set(gca,'xscale','log')
ylabel('performance'); xlabel('contrast');

%Fit psychometric functions
weights = ones(1,length(x2)); % No weighting (one could potentially way certain x=points more
% do the fit
[coeffs_s, curve_s, threshold_s] = FitPsycheCurveLogit(x2, y2, weights);
% Plot psychometic curves
plot(curve_s(:,1), curve_s(:,2), 'LineStyle', '--')
legend('data', 'fit');

% calculate the PSE ( the value returned at 50% performance)
Pb50 = 0.50;
d.PSE_s = (log(Pb50/(1-Pb50))-coeffs_s(1)/coeffs_s(2))
% calculated from the difference along the x axis between 25% and 75% performance on the y axis.
Pb75 = 0.75;
d.thresh_s = ((log(Pb50/(1-Pb50))-coeffs_s(1)/coeffs_s(2) - (log(Pb50/(1-Pb50))-coeffs_s(1)/coeffs_s(2)) /2));

save(['data_' sid], 'd');


%% Other Functions
%--------------------------------------------------------------------------
function [imOut] = CreateGabor(orientation, phase ,amplitude)
% eg: imshow(CreateGabor([100 100], 8, 45, 0, 6 , 0.5, 0.5)
vhSize=[100,100];
cyclesPer100Pix=8; %20;
sigma=12;
mean=0.5; %higher numbers
% orientation = - orientation + 90;
X = ones(vhSize(1),1)*[-(vhSize(2)-1)/2:1:(vhSize(2)-1)/2];
Y =[-(vhSize(1)-1)/2:1:(vhSize(1)-1)/2]' * ones(1,vhSize(2));
CosIm =  cos(2.*pi.*(cyclesPer100Pix/100).* (cos(deg2rad(orientation)).*X ...
    + sin(deg2rad(orientation)).*Y)  ...
    - deg2rad(phase)*ones(vhSize) );
G = fspecial('gaussian', vhSize, sigma);
G = G ./ (max(max(G))*(ones(vhSize))); 	% make the max 1
im = amplitude *  G.* CosIm + mean*ones(vhSize);
im(find(abs(im-mean) < amplitude/64)) = mean;  % remove 1-grayscale error 64->
imOut = 255*im;  %RGB values for psychotoolbox
end
%--------------------------------------------------------------------------
function [win,sid] = Initialize(prefs)
% Do setup for the experiment
commandwindow;
% Ensure they enter digits for the subject name and it isn't already used:
rand('twister', sum(clock.*100));
sid = input('Enter subject number: ', 's');

rand('state', str2double(sid));
win = Screen('OpenWindow', prefs.monitor, [0 0 0]);
Screen('FillRect', win, prefs.backColor);
Screen('Flip', win);
Screen('TextSize', win, 30);

end
%--------------------------------------------------------------------------
function p = Preferences()
% Setup preferences for this experiment
p.monitor    = max(Screen('Screens'));
p.backColor  = [127.5 127.5 127.5];
p.foreColor  = [0 0 0];
p.keys	     = KbName('space');
p.quitKey    = KbName('q');
p.tmp = Screen('Resolution',p.monitor);
p.resolution = [p.tmp.width, p.tmp.height];
p.dist =   45; % viewing distance (cm)
p.width =  35; % width of screen (cm)
p.pixelSize=p.width/p.resolution(1);
end
%--------------------------------------------------------------------------
function n=angle2pix(prefs,ang)
n=2*prefs.dist*tan(ang*pi/360)/prefs.pixelSize; %not 100% sure about this either...
end

%--------------------------------------------------------------------------
function frames=secs2frames(prefs,secs)
frames = round(secs*prefs.frameRate);
end

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
        
