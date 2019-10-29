%This is going to test out the animation.
clear all; close all;
load('Parameters 10.mat'); %Whatever parameter you've saved.
%To counterbalance, just change the left-up/right-down vs.
%left-down/right-up. That way you just change the y coordinates.

Screen('Preference', 'SkipSyncTests', 1);
% Prefs and init
prefs = Preferences();
[w, sid] = Initialize(prefs);
%% Screen %%
%screens = Screen('Screens');
%screenNumber = max(screens);

%Screen('Preference', 'SkipSyncTests', 1);
%[win, rect] = Screen('OpenWindow', screenNumber);
%[xCenter, yCenter] = RectCenter(rect);
%[screenXpixels, screenYpixels] = Screen('WindowSize', win);

% Information about the screen
rct = Screen('Rect', prefs.monitor);
centerScreen = [rct(3)./2 rct(4)./2]; % x, y
xCenter = centerScreen(1);
yCenter = centerScreen(2);
[window.screenX, window.screenY] = Screen('WindowSize', w); % check resolution
window.screenRect  = [0 0 window.screenX window.screenY]; % screen rect
window.centerX = window.screenX * 0.5; % center of screen in X direction
window.centerY = window.screenY * 0.5; % center of screen in Y direction
window.centerXL = floor(mean([0 window.centerX])); % center of left half of screen in X direction
window.centerXR = floor(mean([window.centerX window.screenX])); % center of right half of screen in X direction
colorWheelLocations = ColorWheelLocations(window, prefs);

%% Screen-Motion %%
vbl = Screen('Flip', w);
flipSpd = 1; %2 for my Windows laptop! %Flip speed
% dispTime = 3; %3 seconds display.....DISPLAY will be 2.5 - 3.5
monitorFlipInterval = Screen('GetFlipInterval', w);

%% Colors %%
black = [0 0 0];
white = [255 255 255];
red = [255 0 0];
green = [0 255 0];
blue = [0 0 255];
grey = [127.5 127.5 127.5];

%% TrialStruct %%
nTrial = 8; %multiples of 8
data.nTrial = nTrial;

trialstruct(1,1:nTrial/2) = 1; %Left Up Right Down
trialstruct(1,nTrial/2+1:nTrial) = 2; %Right Up Left Down

trialstruct(2,1:nTrial/4) = 5; %Up Target
trialstruct(2,nTrial/4+1:nTrial/2) = 6; %Down Target
trialstruct(2,nTrial/2+1:6*nTrial/8) = 5; %Up Target
trialstruct(2,6*nTrial/8+1:8*nTrial/8) = 6; %Down Target

trialstruct(3,1:2:nTrial) = 3; %Break
trialstruct(3,2:2:nTrial) = 4; %Continuous

shuffletime = randi([1,100],1); %Shuffle 1 to 100 times.
for i = 1:shuffletime
    trialstruct = Shuffle(trialstruct, 1);
end

data.shuffletime = shuffletime;
data.trialstruct = trialstruct;

%% Fixation Point %%
fix = 25;

%% Trial %%
Screen(w, 'TextFont', 'Arial');
%Starting screen
Screen('DrawText', w, 'Press SpaceBar when ready', xCenter-200, yCenter);
Screen('Flip', w);
KbStrokeWait();
Screen(w, 'TextFont', 'Arial');
Screen('DrawText', w, 'Press SpaceBar when ready', xCenter-200, yCenter);
Screen('Flip', w);
KbStrokeWait();

for curTrial = 1:nTrial
    HideCursor();
    Screen('DrawText', w,['Press any key to start'], xCenter-250, yCenter);
    Screen('Flip', w);
    KbStrokeWait();
    %------------------------------------------------ Timing Variable
    ft = 1; %first_time
    it = 1; %implode_time
    et = 1; %explode_time
    lt = 1; %last_time
    %nt = 1; %no color time
    %------------------------------------------------ Set Colors
    targetColor = randsample(1:360, 1);
    nontargetColor = randsample(1:360, 1);
    while abs(targetColor - nontargetColor) <= 30 %At least this degrees apart.
        targetColor = randsample(1:360, 1);
        nontargetColor = randsample(1:360, 1);
    end
    
    %------------------------------------------------ Prep
    if trialstruct(1,curTrial) == 1
        Left_leftside = (d.leftstart1)-d.z/2;
        Left_rightside = (d.leftstart1)+d.z/2;
        Right_leftside = (d.rightstart1)-d.z/2;
        Right_rightside = (d.rightstart1)+d.z/2;
        %Left square
        Screen('FrameRect', w, black, [Left_leftside, (yCenter-2*d.z)-d.z/2, Left_rightside, (yCenter-2*d.z)+d.z/2], 2);
        %Right square
        Screen('FrameRect', w, black, [Right_leftside, (yCenter+2*d.z)-d.z/2, Right_rightside, (yCenter+2*d.z)+d.z/2], 2);
    elseif trialstruct(1,curTrial) == 2
        Left_leftside = (d.leftstart2)-d.z/2;
        Left_rightside = (d.leftstart2)+d.z/2;
        Right_leftside = (d.rightstart2)-d.z/2;
        Right_rightside = (d.rightstart2)+d.z/2;
        %Left square
        Screen('FrameRect', w, black, [Left_leftside, (yCenter-2*d.z)-d.z/2, Left_rightside, (yCenter-2*d.z)+d.z/2], 2);
        %Right square
        Screen('FrameRect', w, black, [Right_leftside, (yCenter+2*d.z)-d.z/2, Right_rightside, (yCenter+2*d.z)+d.z/2], 2);
    end
    
    Screen('FillRect', w, grey, [ d.Occ_leftside, yCenter-d.oc_height/2, d.Occ_rightside, yCenter+d.oc_height/2]);
    Screen('DrawDots', w, [xCenter, yCenter], fix, white, [0 0], 1);
    Screen('Flip', w);
    WaitSecs(1);
    
    %------------------------------------------------ Stimuli
    %tic;
    data.totalframetime = (d.rightstart1-d.leftstart1)/d.v;
    for t = 1:(d.rightstart1-d.leftstart1)/d.v
        %------------------------------------------------ Set Colors
        if t>=d.timestamp_rightin && t<=d.timestamp_rightalmost %If the stimuli are not in the occluder.
            targetColor = targetColor;
            nontargetColor = nontargetColor;
        else
            targetColor = targetColor+1; %check = targetColor; check1 = nontargetColor;
            if targetColor >= 360
                targetColor = 1+abs(360-targetColor); %That way if it's 359+2 than it becomes 2.
            end
            nontargetColor = nontargetColor+1; %During occluded do -2?
            if nontargetColor >= 360
                nontargetColor = 1+abs(360-nontargetColor);
            end
        end
        
        if t == 1
            data.initialtargetcolor(curTrial) = targetColor;
            data.initialnontargetcolor(curTrial) = nontargetColor;
        elseif t == round(d.timestamp_rightout + 100/monitorFlipInterval/1000) %100ms after rightout
            data.targetcolor(curTrial) = targetColor;
            data.nontargetcolor(curTrial) = nontargetColor;
        end
        
        %Determine whether it is left up or left down.
        if trialstruct(1,curTrial) == 1 %Left Up Right Down
            %------------------------------------------------Assign Colors
            if trialstruct(2,curTrial) == 5 %Up Target
                LUColor = prefs.colorwheel(targetColor,:);
                RDColor = prefs.colorwheel(nontargetColor,:);
            elseif trialstruct(2,curTrial) == 6 %Down Target
                RDColor = prefs.colorwheel(targetColor,:);
                LUColor = prefs.colorwheel(nontargetColor,:);
            end
            %------------------------------------------------
            if trialstruct(3,curTrial) == 3 %Break
                data.isbreaking(curTrial) = 1;
                if  t<=d.timestamp_righttouch
                    Left_leftside = (d.leftstart1)-d.z/2+d.v*ft;
                    Left_rightside = (d.leftstart1)+d.z/2+d.v*ft;
                    Right_leftside = (d.rightstart1)-d.z/2-d.v*ft;
                    Right_rightside = (d.rightstart1)+d.z/2-d.v*ft;
                    %Left square
                    Screen('FillRect', w, LUColor, [Left_leftside, (yCenter-2*d.z)-d.z/2, Left_rightside, (yCenter-2*d.z)+d.z/2]);
                    %Right square
                    Screen('FillRect', w, RDColor, [Right_leftside, (yCenter+2*d.z)-d.z/2, Right_rightside, (yCenter+2*d.z)+d.z/2]);
                    ft = ft+1;
                elseif t>=d.timestamp_righttouch && t<=d.timestamp_rightalmost
                    implode_size = sqrt(-d.v*it*d.z+d.z^2);
                    %Left implode
                    Screen('FillRect', w, LUColor, [((d.Occ_leftside-d.z/2)-implode_size/2), ((yCenter-d.z*2)-implode_size/2), ((d.Occ_leftside-d.z/2)+implode_size/2), ((yCenter-d.z*2)+implode_size/2)]);
                    %Right implode
                    Screen('FillRect', w, RDColor, [((d.Occ_rightside+d.z/2)-implode_size/2), ((yCenter+d.z*2)-implode_size/2), ((d.Occ_rightside+d.z/2)+implode_size/2), ((yCenter+d.z*2)+implode_size/2)]);
                    it = it+1;
                elseif t>=d.timestamp_rightalmost && t<=d.timestamp_rightout
                    explode_size = sqrt(d.v*et*d.z);
                    %Left implode
                    Screen('FillRect', w, LUColor, [((d.Occ_rightside+d.z/2)-explode_size/2), ((yCenter-d.z*2)-explode_size/2), ((d.Occ_rightside+d.z/2)+explode_size/2), ((yCenter-d.z*2)+explode_size/2)]);
                    %Right implode
                    Screen('FillRect', w, RDColor, [((d.Occ_leftside-d.z/2)-explode_size/2), ((yCenter+d.z*2)-explode_size/2), ((d.Occ_leftside-d.z/2)+explode_size/2), ((yCenter+d.z*2)+explode_size/2)]);
                    et = et+1;
                elseif t>=d.timestamp_rightout && t<=round(d.timestamp_rightout + 100/monitorFlipInterval/1000)
                    Left_leftside = (d.Occ_rightside+d.z/2)-d.z/2+d.v*lt;
                    Left_rightside = (d.Occ_rightside+d.z/2)+d.z/2+d.v*lt;
                    Right_leftside = (d.Occ_leftside-d.z/2)-d.z/2-d.v*lt;
                    Right_rightside = (d.Occ_leftside-d.z/2)+d.z/2-d.v*lt;
                    %Left square
                    Screen('FillRect', w, LUColor, [Left_leftside, (yCenter-2*d.z)-d.z/2, Left_rightside, (yCenter-2*d.z)+d.z/2]);
                    %Right square
                    Screen('FillRect', w, RDColor, [Right_leftside, (yCenter+2*d.z)-d.z/2, Right_rightside, (yCenter+2*d.z)+d.z/2]);
                    lt = lt+1;
                elseif t>=round(d.timestamp_rightout + 100/monitorFlipInterval/1000)
                    Left_leftside = (d.Occ_rightside+d.z/2)-d.z/2+d.v*lt;
                    Left_rightside = (d.Occ_rightside+d.z/2)+d.z/2+d.v*lt;
                    Right_leftside = (d.Occ_leftside-d.z/2)-d.z/2-d.v*lt;
                    Right_rightside = (d.Occ_leftside-d.z/2)+d.z/2-d.v*lt;
                    %Left square
                    Screen('FrameRect', w, black, [Left_leftside, (yCenter-2*d.z)-d.z/2, Left_rightside, (yCenter-2*d.z)+d.z/2], 2);
                    %Right square
                    Screen('FrameRect', w, black, [Right_leftside, (yCenter+2*d.z)-d.z/2, Right_rightside, (yCenter+2*d.z)+d.z/2], 2);
                    lt = lt+1;
                end
            elseif trialstruct(3,curTrial) == 4 %Continuous
                data.isbreaking(curTrial) = 0;
                if t<=round(d.timestamp_rightout + 100/monitorFlipInterval/1000)
                    Left_leftside = (d.leftstart1)-d.z/2+d.v*ft;
                    Left_rightside = (d.leftstart1)+d.z/2+d.v*ft;
                    Right_leftside = (d.rightstart1)-d.z/2-d.v*ft;
                    Right_rightside = (d.rightstart1)+d.z/2-d.v*ft;
                    %Left square
                    Screen('FillRect', w, LUColor, [Left_leftside, (yCenter-2*d.z)-d.z/2, Left_rightside, (yCenter-2*d.z)+d.z/2]);
                    %Right square
                    Screen('FillRect', w, RDColor, [Right_leftside, (yCenter+2*d.z)-d.z/2, Right_rightside, (yCenter+2*d.z)+d.z/2]);
                    ft = ft+1;
                elseif t>=round(d.timestamp_rightout + 100/monitorFlipInterval/1000)
                    Left_leftside = (d.leftstart1)-d.z/2+d.v*ft;
                    Left_rightside = (d.leftstart1)+d.z/2+d.v*ft;
                    Right_leftside = (d.rightstart1)-d.z/2-d.v*ft;
                    Right_rightside = (d.rightstart1)+d.z/2-d.v*ft;
                    %Left square
                    Screen('FrameRect', w, black, [Left_leftside, (yCenter-2*d.z)-d.z/2, Left_rightside, (yCenter-2*d.z)+d.z/2], 2);
                    %Right square
                    Screen('FrameRect', w, black, [Right_leftside, (yCenter+2*d.z)-d.z/2, Right_rightside, (yCenter+2*d.z)+d.z/2], 2);
                    ft = ft+1;
                end
            end
            %------------------------------------------------
            if trialstruct(2,curTrial) == 5 %Up Target
                Targetlocation = [Left_leftside, (yCenter-2*d.z)-d.z/2, Left_rightside, (yCenter-2*d.z)+d.z/2];
                nonTargetlocation = [Right_leftside, (yCenter+2*d.z)-d.z/2, Right_rightside, (yCenter+2*d.z)+d.z/2];
                data.targetloc(curTrial) = 'L';
            elseif trialstruct(2,curTrial) == 6 %Down Target
                Targetlocation = [Right_leftside, (yCenter+2*d.z)-d.z/2, Right_rightside, (yCenter+2*d.z)+d.z/2];
                nonTargetlocation = [Left_leftside, (yCenter-2*d.z)-d.z/2, Left_rightside, (yCenter-2*d.z)+d.z/2];
                data.targetloc(curTrial) = 'R';
            end
            %------------------------------------------------
        elseif trialstruct(1,curTrial) == 2 %Right Up Left Down
            %------------------------------------------------Assign Colors
            if trialstruct(2,curTrial) == 5 %Up Target
                RUColor = prefs.colorwheel(targetColor, :);
                LDColor = prefs.colorwheel(nontargetColor, :);
            elseif trialstruct(2,curTrial) == 6 %Down Target
                LDColor = prefs.colorwheel(targetColor, :);
                RUColor = prefs.colorwheel(nontargetColor, :);
            end
            %------------------------------------------------
            if trialstruct(3,curTrial) == 3 %Break
                data.isbreaking(curTrial) = 1;
                if  t<=d.timestamp_righttouch
                    Left_leftside = (d.leftstart1)-d.z/2+d.v*ft;
                    Left_rightside = (d.leftstart1)+d.z/2+d.v*ft;
                    Right_leftside = (d.rightstart1)-d.z/2-d.v*ft;
                    Right_rightside = (d.rightstart1)+d.z/2-d.v*ft;
                    %Left square
                    Screen('FillRect', w, LDColor, [Left_leftside, (yCenter+2*d.z)-d.z/2, Left_rightside, (yCenter+2*d.z)+d.z/2]);
                    %Right square
                    Screen('FillRect', w, RUColor, [Right_leftside, (yCenter-2*d.z)-d.z/2, Right_rightside, (yCenter-2*d.z)+d.z/2]);
                    ft = ft+1;
                elseif t>=d.timestamp_righttouch && t<=d.timestamp_rightalmost
                    implode_size = sqrt(-d.v*it*d.z+d.z^2);
                    %Left implode
                    Screen('FillRect', w, LDColor, [((d.Occ_leftside-d.z/2)-implode_size/2), ((yCenter+d.z*2)-implode_size/2), ((d.Occ_leftside-d.z/2)+implode_size/2), ((yCenter+d.z*2)+implode_size/2)]);
                    %Right implode
                    Screen('FillRect', w, RUColor, [((d.Occ_rightside+d.z/2)-implode_size/2), ((yCenter-d.z*2)-implode_size/2), ((d.Occ_rightside+d.z/2)+implode_size/2), ((yCenter-d.z*2)+implode_size/2)]);
                    it = it+1;
                elseif t>=d.timestamp_rightalmost && t<=d.timestamp_rightout
                    explode_size = sqrt(d.v*et*d.z);
                    %Left implode
                    Screen('FillRect', w, LDColor, [((d.Occ_rightside+d.z/2)-explode_size/2), ((yCenter+d.z*2)-explode_size/2), ((d.Occ_rightside+d.z/2)+explode_size/2), ((yCenter+d.z*2)+explode_size/2)]);
                    %Right implode
                    Screen('FillRect', w, RUColor, [((d.Occ_leftside-d.z/2)-explode_size/2), ((yCenter-d.z*2)-explode_size/2), ((d.Occ_leftside-d.z/2)+explode_size/2), ((yCenter-d.z*2)+explode_size/2)]);
                    et = et+1;
                elseif t>=d.timestamp_rightout && t<=round(d.timestamp_rightout + 100/monitorFlipInterval/1000)
                    Left_leftside = (d.Occ_rightside+d.z/2)-d.z/2+d.v*lt;
                    Left_rightside = (d.Occ_rightside+d.z/2)+d.z/2+d.v*lt;
                    Right_leftside = (d.Occ_leftside-d.z/2)-d.z/2-d.v*lt;
                    Right_rightside = (d.Occ_leftside-d.z/2)+d.z/2-d.v*lt;
                    %Left square
                    Screen('FillRect', w, LDColor, [Left_leftside, (yCenter+2*d.z)-d.z/2, Left_rightside, (yCenter+2*d.z)+d.z/2]);
                    %Right square
                    Screen('FillRect', w, RUColor, [Right_leftside, (yCenter-2*d.z)-d.z/2, Right_rightside, (yCenter-2*d.z)+d.z/2]);
                    lt = lt+1;
                elseif t>=round(d.timestamp_rightout + 100/monitorFlipInterval/1000)
                    Left_leftside = (d.Occ_rightside+d.z/2)-d.z/2+d.v*lt;
                    Left_rightside = (d.Occ_rightside+d.z/2)+d.z/2+d.v*lt;
                    Right_leftside = (d.Occ_leftside-d.z/2)-d.z/2-d.v*lt;
                    Right_rightside = (d.Occ_leftside-d.z/2)+d.z/2-d.v*lt;
                    %Left squarefdrc
                    Screen('FrameRect', w, black, [Left_leftside, (yCenter+2*d.z)-d.z/2, Left_rightside, (yCenter+2*d.z)+d.z/2], 2);
                    %Right square
                    Screen('FrameRect', w, black, [Right_leftside, (yCenter-2*d.z)-d.z/2, Right_rightside, (yCenter-2*d.z)+d.z/2], 2);
                    lt = lt+1;
                end
            elseif trialstruct(3,curTrial) == 4 %Continuous
                data.isbreaking(curTrial) = 0;
                if t<=round(d.timestamp_rightout + 100/monitorFlipInterval/1000)
                    Left_leftside = (d.leftstart1)-d.z/2+d.v*ft;
                    Left_rightside = (d.leftstart1)+d.z/2+d.v*ft;
                    Right_leftside = (d.rightstart1)-d.z/2-d.v*ft;
                    Right_rightside = (d.rightstart1)+d.z/2-d.v*ft;
                    %Left square
                    Screen('FillRect', w, LDColor, [Left_leftside, (yCenter+2*d.z)-d.z/2, Left_rightside, (yCenter+2*d.z)+d.z/2]);
                    %Right square
                    Screen('FillRect', w, RUColor, [Right_leftside, (yCenter-2*d.z)-d.z/2, Right_rightside, (yCenter-2*d.z)+d.z/2]);
                    ft = ft+1;
                elseif t>=round(d.timestamp_rightout + 100/monitorFlipInterval/1000)
                    Left_leftside = (d.leftstart1)-d.z/2+d.v*ft;
                    Left_rightside = (d.leftstart1)+d.z/2+d.v*ft;
                    Right_leftside = (d.rightstart1)-d.z/2-d.v*ft;
                    Right_rightside = (d.rightstart1)+d.z/2-d.v*ft;
                    %Left square
                    Screen('FrameRect', w, black, [Left_leftside, (yCenter+2*d.z)-d.z/2, Left_rightside, (yCenter+2*d.z)+d.z/2], 2);
                    %Right square
                    Screen('FrameRect', w, black, [Right_leftside, (yCenter-2*d.z)-d.z/2, Right_rightside, (yCenter-2*d.z)+d.z/2], 2);
                    ft = ft+1;
                end
            end
            %------------------------------------------------
            if trialstruct(2,curTrial) == 5 %Up Target
                Targetlocation = [Right_leftside, (yCenter-2*d.z)-d.z/2, Right_rightside, (yCenter-2*d.z)+d.z/2];
                nonTargetlocation = [Left_leftside, (yCenter+2*d.z)-d.z/2, Left_rightside, (yCenter+2*d.z)+d.z/2];
                data.targetloc(curTrial) = 'R';
            elseif trialstruct(2,curTrial) == 6 %Down Target
                Targetlocation = [Left_leftside, (yCenter+2*d.z)-d.z/2, Left_rightside, (yCenter+2*d.z)+d.z/2];
                nonTargetlocation = [Right_leftside, (yCenter-2*d.z)-d.z/2, Right_rightside, (yCenter-2*d.z)+d.z/2];
                data.targetloc(curTrial) = 'L';
            end
            %------------------------------------------------
        end
        Screen('FillRect', w, grey, [ d.Occ_leftside, yCenter-d.oc_height/2, d.Occ_rightside, yCenter+d.oc_height/2]);
        Screen('DrawDots', w, [xCenter, yCenter], fix, white, [0 0], 1);
        Screen('Flip', w);
        
    end
%     %Save ending colors
%     data.targetcolor(curTrial) = targetColor;
%     data.nontargetcolor(curTrial) = nontargetColor;
%     %letschecktime = toc;

     %------------------------------------------------ Probe Which Square
     Screen('FrameRect', w, black, Targetlocation, 7);
     Screen('FrameRect', w, black, nonTargetlocation, 2);
     Screen('FillRect', w, grey, [ d.Occ_leftside, yCenter-d.oc_height/2, d.Occ_rightside, yCenter+d.oc_height/2]);
     Screen('DrawDots', w, [xCenter, yCenter], fix, white, [0 0], 1);
     Screen('Flip', w);
     WaitSecs(0.5);

%     %------------------------------------------------ Delay
%     Screen('FillRect', w, white, rct);
%     Screen('DrawDots', w, [xCenter, yCenter], fix, grey, [0 0], 1);
%     Screen('Flip', w);
%     WaitSecs(0.5); %Don't need delay! Probe and time after colors go away!
    
    %------------------------------------------------ Response
    % Show report wheel
    testRect = Targetlocation;
    distRect = nonTargetlocation;
    
    %Response time
    tic;
    
    % If mouse button is already down, wait for release:
    scrSize1 = Screen('Rect', prefs.monitor); % offset by amount of main screen
    SetMouse(window.centerX + scrSize1(3), window.centerY);
    ShowCursor('Arrow');
    [~,~,buttons] = GetMouse(w);
    while any(buttons)
        [~,~,buttons] = GetMouse(w);
    end
    
    % Track mouse until clicked
    everMovedFromCenter = false;
    firstFrame = true;
    colorWheelSizes = 20;
    while ~any(buttons) || ~everMovedFromCenter
        % Get mouse location
        [x,y,buttons] = GetMouse(w);
        [minDistance, curAngle] = min(sqrt((colorWheelLocations(1,:)-x).^2 ...
            + (colorWheelLocations(2,:)-y).^2));
        if(minDistance < 250)
            everMovedFromCenter = true;
        end
        if(everMovedFromCenter)
            colorsOfTest = prefs.colorwheel(curAngle,:);
            Screen('FillRect', w, colorsOfTest, testRect, 2);
            Screen('FrameRect', w, black, distRect, 2);
        else %If mouse is not moved yet, make is somwhat grey-ish initially
            %colorsOfTest = [127.5,127.5,127.5]; %prefs.colorwheel(trialInfo.targetColorNumber(i),:);
            Screen('FrameRect', w, black, testRect, 7);
            Screen('FrameRect', w, black, distRect, 2);
        end
        
        % Draw text square and fixation and color wheel:
        %DrawDots(win, centerScreen, cSz, xOff, angle);
        Screen('DrawDots', w, [xCenter, yCenter], fix, grey, [0 0], 1);
        %Screen('FrameRect', w, black, Targetlocation, 2);  
        Screen('DrawDots', w, colorWheelLocations, colorWheelSizes, prefs.colorwheel', [], 1);
        Screen('Flip', w);
        if firstFrame
            firstFrame = false;
        end
        
        % Check for user quitting program
        [~,~,keys]=KbCheck;
        if keys(KbName('q')) && keys(KbName('z'))
            sca; error('User quit!');
        end
    end
    
    data.rt(curTrial) = toc;
    
    %Calculate error and record responses
    data.color_response(curTrial) = curAngle;
    data.color_error(curTrial) = curAngle - data.targetcolor(curTrial); %Negative --> Past, Positive --> Future
    while (data.color_error(curTrial)<-180), data.color_error(curTrial) = data.color_error(curTrial)+360;end
    while (data.color_error(curTrial)>180), data.color_error(curTrial) = data.color_error(curTrial)-360;end
    
    %KbStrokeWait(); %Just a key stroke for now. This will be the response screen soon.
end
save(fullfile('Data', ['occlusionstudy_' sid 'mat']), 'data');
sca; %Just close down for now.

%% Other functions
%--------------------------------------------------------------------------

function [win,sid] = Initialize(prefs)
% Do setup for the experiment
commandwindow;
% Ensure they enter digits for the subject name and it isn't already used:
rand('twister', sum(clock.*100));
sid = input('Enter test number: ', 's');

rand('state', str2double(sid));
win = Screen('OpenWindow', prefs.monitor, [0 0 0]);
Screen('FillRect', win, prefs.backColor);
Screen('Flip', win);
Screen('TextSize', win, 30);

end

%--------------------------------------------------------------------------
function L = ColorWheelLocations(window, prefs)
L = [cosd(1:360).*prefs.colorWheelRadius + window.centerX; ...
    sind(1:360).*prefs.colorWheelRadius + window.centerY];
end

%--------------------------------------------------------------------------
function p = Preferences()
% Setup preferences for this experiment
p.monitor    = max(Screen('Screens'));
p.backColor  = [255 255 255];
p.foreColor  = [0 0 0];
p.keys	     = KbName('space');
p.quitKey    = KbName('q');

p.colorWheelRadius = 300;
p.colorwheel = load('colorwheel360.mat', 'fullcolormatrix');
p.colorwheel = p.colorwheel.fullcolormatrix;
end
    
%--------------------------------------------------------------------------
function v=wrapD(v, limits)
if nargin<2
    limits = [1 360];
end
while any(v<limits(1) | v>limits(2))
    v(v<limits(1)) = v(v<limits(1)) + (limits(2)-limits(1));
    v(v>limits(2)) = v(v>limits(2)) - (limits(2)-limits(1));
end
end