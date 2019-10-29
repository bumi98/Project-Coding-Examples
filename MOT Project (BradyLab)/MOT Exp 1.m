clear all;
Screen('Preference', 'SkipSyncTests', 1);
%% Experiment Information %%
nTrial = 48; %Make it divisible by 8 to ensure no remainders.
nBlock = 5;

% Prefs and init
prefs = Preferences();
[win, sid] = Initialize(prefs);

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
[window.screenX, window.screenY] = Screen('WindowSize', win); % check resolution
window.screenRect  = [0 0 window.screenX window.screenY]; % screen rect
window.centerX = window.screenX * 0.5; % center of screen in X direction
window.centerY = window.screenY * 0.5; % center of screen in Y direction
window.centerXL = floor(mean([0 window.centerX])); % center of left half of screen in X direction
window.centerXR = floor(mean([window.centerX window.screenX])); % center of right half of screen in X direction
colorWheelLocations = ColorWheelLocations(window, prefs);

%% Screen-Motion %%

vbl = Screen('Flip', win);
flipSpd = 1; %2 for my Windows laptop! %Flip speed
% dispTime = 3; %3 seconds display.....DISPLAY will be 2.5 - 3.5
monitorFlipInterval = Screen('GetFlipInterval', win);

%% Fixation Cross+Dot Information %%

%Fixation Cross coodinates
xCoords = [-40 40 0 0];
yCoords = [0 0 -40 40];
allCoords = [xCoords; yCoords];
width = 4;

%Dot size/Location info
dot.size = 85;
ovalsize = dot.size/2;

%Basic colors
black = [0 0 0];
white = [255 255 255];

%% Variables %%

%Circle 1 (left) center
Circle1Center = [window.screenX/4, window.screenY/2];
%Cirlce 2 (right) center
Circle2Center = [window.screenX*3/4, window.screenY/2];


radius = 200; %just for now...

%% Randomized Trials %%
%Now let's randomize the trials!!!
trialstruct(1, 1:nTrial/2) = 1; %Set Size 1
trialstruct(1, nTrial/2+1:nTrial) = 2; %Set Size 2

trialstruct(2, 1:nTrial/4) = 3; %Moving trials 3
trialstruct(2, nTrial/4+1:nTrial/2) = 4;  %Staionary trials 4
trialstruct(2, nTrial/2+1:3*nTrial/4) = 3;
trialstruct(2, 3*nTrial/4+1:nTrial) = 4;

trialstruct(3, 1:2:nTrial) = 5; %Left trials 5
trialstruct(3, 2:2:nTrial) = 6; %Right trials 6

%Now randomize
trialstruct = Shuffle(trialstruct, 1);

%% Start Screen %%
Screen(win, 'TextFont', 'Arial');
Screen('DrawText', win, 'Press SpaceBar when ready', xCenter-200, yCenter);
[keyIsDown, secs, keyCode] = KbCheck();
Screen('Flip', win);
while (~any(keyCode(KbName('space'))))
    [keyIsDown, secs, keyCode] = KbCheck();
end


%% Trial %%
for j = 1:nBlock
    Screen('DrawText', win, ['You are now entering Block ', num2str(j)], xCenter-250, yCenter);
    Screen('Flip', win);
    
    KbStrokeWait(); %Wait for a key press
    
    
    for i = 1:nTrial
        Screen('DrawText', win, ['Press any key to start'], xCenter-250, yCenter);
        Screen('Flip', win);
        KbStrokeWait();
        
        %angle_start1(left)
        angle_start1 = 1.5708+(4.71239-1.5708)*rand(1,1); %calculated in radian
        data(j).angle_start_left(i) = angle_start1;
        %right
        angle_start2 = 4.71239+(7.85398-4.71239)*rand(1,1);
        data(j).angle_start_right(i) = angle_start2;
        
        %Target Colors
        targetColor = randsample(1:360,1);
        nontargetColor = randsample(1:360,1);       
        
        %Make sure target and non target colors are at least 15 degrees
        %apart.
        while abs(targetColor - nontargetColor) <= 30
            targetColor = randsample(1:360,1);
            nontargetColor = randsample(1:360,1);
        end
        
        data(j).targetcolor(i) = targetColor;
        data(j).targetcolor(i) = nontargetColor;
        
        %Display time jittered 2.5~3.5s
        dispTime = ((3.5-2.5)*rand(1,1)+2.5)/2;
        %So the actual timing is more like dispTime*2 due to flipspd being
        %1 instead of 2.
      
        data(j).displaytime(i) = dispTime;   
        
        %Staionary vs. Moving
        if trialstruct(2,i) == 3
            v1 = 0.045; %v for velocity
            v2 = 0.045;
            data(j).ismoving(i) = 1; %recording that the trial moved
        elseif trialstruct(2,i) == 4
            v1 = 0;
            v2 = 0;
            data(j).ismoving(i) = 0;
        end
        
        
        %Preset the locations
        %Left
        x1 = radius*cos(angle_start1)+Circle1Center(1);
        y1 = radius*sin(angle_start1)+Circle1Center(2);
        data(j).location_start_left{i} = [x1, y1];
        %Right
        x2 = radius*cos(angle_start2)+Circle2Center(1);
        y2 = radius*sin(angle_start2)+Circle2Center(2);
        data(j).location_start_right{i} = [x2, y2];
        
        
        
        %Set size info
        if trialstruct(1,i) == 1
            colorInfo1 = prefs.colorwheel(targetColor, :);
            colorInfo2 = black;
            data(j).setsize(i) = 1;
        elseif trialstruct(1,i) == 2
            colorInfo1 = prefs.colorwheel(targetColor, :);
            colorInfo2 = prefs.colorwheel(nontargetColor, :);
            data(j).setsize(i) = 2;
        end
        
        
        HideCursor();
        
        
        
        %Prep
        Screen('FrameOval', win, black, [x1-ovalsize, y1-ovalsize, x1+ovalsize, y1+ovalsize], [7]);
        Screen('FrameOval', win, black, [x2-ovalsize, y2-ovalsize, x2+ovalsize, y2+ovalsize], [7]);
        Screen('DrawLines', win, allCoords, width, black, [xCenter yCenter]);
        Screen('Flip', win);
        WaitSecs(1);
        
        
        %Stimuli
        for k = 1:round(dispTime/(flipSpd*monitorFlipInterval)) %around 3 secs
            
            %Color
            targetColor = targetColor+2; %Change the color by 2 degrees each iteration
            if targetColor >= 360
                targetColor = 1;
            end
            
            nontargetColor = nontargetColor+2;
            if nontargetColor >= 360
                nontargetColor = 1;
            end
            
            %Set the trial target colors
            if trialstruct(1,i) == 1 && trialstruct(3,i) == 5 %SS1, Left
                colorInfo1 = prefs.colorwheel(targetColor, :);
                colorInfo2 = black;
                data(j).targetlocation{i} = 'left';
            elseif trialstruct(1,i) == 1 && trialstruct(3,i) ==6 %SS1, Right
                colorInfo1 = black;
                colorInfo2 = prefs.colorwheel(targetColor, :);
                data(j).targetlocation{i} = 'right';
            elseif trialstruct(1,i) == 2 && trialstruct(3,i) == 5 %SS2, Left
                colorInfo1 = prefs.colorwheel(targetColor, :);
                colorInfo2 = prefs.colorwheel(nontargetColor, :);
                data(j).targetlocation{i} = 'left';
            elseif trialstruct(1,i) == 2 && trialstruct(3,i) == 6 %SS2, Right
                colorInfo1 = prefs.colorwheel(nontargetColor, :);
                colorInfo2 = prefs.colorwheel(targetColor, :);
                data(j).targetlocation{i} = 'right';
            end
            
            %Movement
            angle_start1 = angle_start1+v1;
            angle_start2 = angle_start2+v2;
            
            %Left Location
            x1 = radius*cos(angle_start1)+Circle1Center(1);
            y1 = radius*sin(angle_start1)+Circle1Center(2);
            %Right Location
            x2 = radius*cos(angle_start2)+Circle2Center(1);
            y2 = radius*sin(angle_start2)+Circle2Center(2);
            
            
            %Boundary for left
            if angle_start1 <= 1.5708 || angle_start1 >= 4.7139
                v1 = (-1)*v1;
            end
            
            %Boundary for right
            if angle_start2 <= 4.71239 || angle_start2 >= 7.85398
                v2 = (-1)*v2;
            end
            
            coin_flip = randi([1,2],1); %This is the random coin flip
            
            %Random coin flip movement change
            if k == round((dispTime/(flipSpd*monitorFlipInterval))/4) || k == round((dispTime/(flipSpd*monitorFlipInterval))*2/4) || ...
                    k == round((dispTime/(flipSpd*monitorFlipInterval))*3/4)
                if angle_start1 > 1.5708 && angle_start1 < 4.7139 && angle_start2 > 4.71239 && angle_start2 < 7.85398
                    %Depending on the coin flip, either left or right dot
                    %will change the direction only if it's not at the very
                    %end of the boundary.
                    if coin_flip == 1
                        v1 = (-1)*v1;
                    elseif coin_flip == 2
                        v2 = (-1)*v2;
                    end
                end
            end
            
            %Fixation cross
            Screen('DrawLines', win, allCoords, width, black, [xCenter yCenter]);
            
            Screen('DrawDots', win, [x1, y1], dot.size, colorInfo1, [0 0], 1);
            Screen('DrawDots', win, [x2, y2], dot.size, colorInfo2, [0 0], 1);
            vbl = Screen('Flip', win, vbl+(flipSpd*monitorFlipInterval));
        end
        
        data(j).location_end_left{i} = [x1, y1];
        data(j).location_end_right{i} = [x2, y2];       
        
        %Delay
        Screen('FillRect', win, white, rct);
        Screen('DrawLines', win, allCoords, width, black, [xCenter yCenter]);
        Screen('Flip', win);
        WaitSecs(1);
        
        %Set Target Location
        if trialstruct(3,i) == 5
            TargetLocation = [x1, y1];
            NonTargetLocation = [x2, y2];
        elseif trialstruct (3,i) == 6
            TargetLocation = [x2, y2];
            NonTargetLocation = [x1, y1];
        end
        
        
        % Show report wheel
        testRect = [TargetLocation(1), TargetLocation(2)];
        
        % If mouse button is already down, wait for release:
        scrSize1 = Screen('Rect', prefs.monitor); % offset by amount of main screen
        SetMouse(window.centerX + scrSize1(3), window.centerY);
        ShowCursor('Arrow');
        [~,~,buttons] = GetMouse(win);
        while any(buttons)
            [~,~,buttons] = GetMouse(win);
        end
        
        % Track mouse until clicked
        everMovedFromCenter = false;
        firstFrame = true;
        colorWheelSizes = 20;
        while ~any(buttons) || ~everMovedFromCenter
            % Get mouse location
            [x,y,buttons] = GetMouse(win);
            [minDistance, curAngle] = min(sqrt((colorWheelLocations(1,:)-x).^2 ...
                + (colorWheelLocations(2,:)-y).^2));
            if(minDistance < 250)
                everMovedFromCenter = true;
            end
            if(everMovedFromCenter)
                colorsOfTest = prefs.colorwheel(curAngle,:);
            else %If mouse is not moved yet, make is somwhat grey-ish initially
                colorsOfTest = [128,128,128]; %prefs.colorwheel(trialInfo.targetColorNumber(i),:);
            end
            
            % Draw text square and fixation and color wheel:
            %DrawDots(win, centerScreen, cSz, xOff, angle);
            Screen('DrawLines', win, allCoords, width, black, [xCenter yCenter]);
            Screen('FrameOval', win, black, [TargetLocation(1)-ovalsize, TargetLocation(2)-ovalsize,...
                TargetLocation(1)+ovalsize, TargetLocation(2)+ovalsize], [7]);
            Screen('DrawDots', win, testRect, dot.size, colorsOfTest, [0,0], 1);
            Screen('DrawDots', win, colorWheelLocations, colorWheelSizes, prefs.colorwheel', [], 1);
            Screen('Flip', win);
            if firstFrame
                firstFrame = false;
            end
            
            % Check for user quitting program
            [~,~,keys]=KbCheck;
            if keys(KbName('q')) && keys(KbName('z'))
                sca; error('User quit!');
            end
        end
        
        
        %load this sniz up boi <- Mark did this.
        image_interval = imread('Likert.jpg');
        [IYL,IXL, z] = size(image_interval);
        Interval=Screen('MakeTexture',win,image_interval);
        
        Screen('DrawText', win, 'How fast did the color change?', xCenter-200, yCenter+200);
        Screen('DrawText', win, 'Slow', xCenter-500, yCenter);
        Screen('DrawText', win, 'Fast', xCenter+500, yCenter);
        Screen('DrawTexture', win, Interval,[], ...
            [xCenter-IXL/2 yCenter-IYL/2 xCenter+IXL/2 yCenter+IYL/2]);
        
        Screen('Flip', win);
        speed_judgement_onset = GetSecs; %This is marking when the display for the likert scale goes up
        
        %Change Confidence Level
        response = '';
        while isempty(response)
            [~,~,keysDown]=KbCheck;
            if keysDown(KbName('1!'))
                response='1';
                speed_judgement_RT = GetSecs - speed_judgement_onset;
            end
            if keysDown(KbName('2@'))
                response='2';
                speed_judgement_RT = GetSecs - speed_judgement_onset;
            end
            if keysDown(KbName('3#'))
                response='3';
                speed_judgement_RT = GetSecs - speed_judgement_onset;
            end
            if keysDown(KbName('4$'))
                response='4';
                speed_judgement_RT = GetSecs - speed_judgement_onset;
            end
            if keysDown(KbName('5%'))
                response='5';
                speed_judgement_RT = GetSecs - speed_judgement_onset;
            end
            if keysDown(KbName('6^'))
                response='6';
                speed_judgement_RT = GetSecs - speed_judgement_onset;
            end
        end
        
        %Calculate error and record responses
        data(j).color_response(i) = curAngle;
        data(j).color_error(i) = curAngle - targetColor; %Negative --> Past, Positive --> Future
        while (data(j).color_error(i)<-180), data(j).color_error(i) = data(j).color_error(i)+360;end
        while (data(j).color_error(i)>180), data(j).color_error(i) = data(j).color_error(i)-360;end
        data(j).speed_judgment{i} = response;
        data(j).speed_RT(i) = speed_judgement_RT; %Confidence Level Response
        data(j).nTrial = nTrial;
        data(j).nBlock = j;
        
    end
    save(fullfile('Data', ['yongsstupidstudy_' sid 'mat']), 'data');
end
save(fullfile('Data', ['yongsstupidstudy_' sid 'mat']), 'data');

sca;

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