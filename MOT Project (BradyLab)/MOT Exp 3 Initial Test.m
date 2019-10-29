function test_theultimate(v,z, oc_width)
%This is to test out the screen and set the parameters that'll be used for
%the main experiment.
%v is for the velocity and z is for the initial square length. Oc_width
%determines the occluder width.

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
%colorWheelLocations = ColorWheelLocations(window, prefs);

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

%% Occluder %%
d.oc_width = oc_width;
d.oc_height = window.screenY;
d.Occ_leftside = xCenter-oc_width/2;
d.Occ_rightside = xCenter+oc_width/2;

%% Other Parameters %%
d.v = v;
d.z = z;
d.area = z^2; %Initial square area.
d.zero_size = z/v; %This is when size becomes 0 during implosion.
d.full_size = z/v; %This is when size becomes z during explosion.

d.leftstart1 = rct(3)/5; %Start at one fifth point of the screen.
d.rightstart1 = 4*rct(3)/5;
d.leftstart2 = 4*rct(3)/5;
d.rightstart2 = rct(3)/5;
%% Fixation Point %%
fix = 50;

%% Test Start %%
    Screen(w, 'TextFont', 'Arial');
    Screen('DrawText', w, 'Press SpaceBar when ready', xCenter-200, yCenter);
    Screen('Flip', w);
    KbStrokeWait();
    
    for t = 1:(d.rightstart1-d.leftstart1)/v %Until they end at the same distance.
        Left_leftside = (d.leftstart1)-z/2+v*t;
        Left_rightside = (d.leftstart1)+z/2+v*t;
        Right_leftside = (d.rightstart1)-z/2-v*t;
        Right_rightside = (d.rightstart1)+z/2-v*t;
        
        %Left square
        Screen('FillRect', w, black, [Left_leftside, (yCenter-2*z)-z/2, Left_rightside, (yCenter-2*z)+z/2]);
        %Right square
        Screen('FillRect', w, black, [Right_leftside, (yCenter+2*z)-z/2, Right_rightside, (yCenter+2*z)+z/2]);
        
        %Draw Fixation dot and Occluder
        Screen('FillRect', w, green, [ d.Occ_leftside, yCenter-d.oc_height/2, d.Occ_rightside, yCenter+d.oc_height/2]);
        Screen('DrawDots', w, [xCenter, yCenter], fix, white, [0 0], 1);
        Screen('Flip', w);
        
        %Check for timestamps
        %Because I can't sometimes make it EXACTLY equal, make it so that
        %when it's super close....give up 1 frame accuracy.
        if abs(Right_leftside - d.Occ_rightside) <= v  %0.5
            d.timestamp_righttouch = t;
        elseif abs(Right_rightside - d.Occ_leftside) <= v
            d.timestamp_rightout = t;
        elseif abs(Right_rightside - d.Occ_rightside) <= v
            d.timestamp_rightin = t;
        elseif abs(Right_leftside - d.Occ_leftside) <= v
            d.timestamp_rightalmost = t;
        end
        
        if abs(Left_rightside - d.Occ_leftside) <= v
            d.timestamp_lefttouch = t;
        elseif abs(Left_leftside - d.Occ_rightside) <= v
            d.timestamp_leftout = t;
        elseif abs(Left_leftside - d.Occ_leftside) <= v
            d.timestamp_leftin = t;
        elseif abs(Left_rightside - d.Occ_rightside) <= v
            d.timestamp_leftalmost = t; %If Occ width is same as z, this wouldn't exist.
        end
        
        %Save the paths
        d.Right_leftside(t) = Right_leftside;
        d.Right_rightside(t) = Right_rightside;
        d.Left_leftside(t) = Left_leftside;
        d.Left_rightside(t) = Left_rightside;
        
    end
    
%disp(d.timestamp_leftalmost); %This is to see if there's a parameter recorded for this.

%If occluder width is same as z...
if oc_width == z
    d.timestamp_leftalmost = d.timestamp_leftin;
    d.timestamp_rightalmost = d.timestamp_rightin;
end
    
save(['Parameters ' num2str(sid)], 'd');

sca
end

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
function p = Preferences()
% Setup preferences for this experiment
p.monitor    = max(Screen('Screens'));
p.backColor  = [255 255 255];
p.foreColor  = [0 0 0];
p.keys	     = KbName('space');
p.quitKey    = KbName('q');

%p.colorWheelRadius = 300;
%p.colorwheel = load('colorwheel360.mat', 'fullcolormatrix');
%p.colorwheel = p.colorwheel.fullcolormatrix;
end

