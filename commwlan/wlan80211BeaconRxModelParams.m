function wlan80211BeaconRxModelParams

load('commwlan80211BusTypes');
assignin('base', 'openMPDUGUI', true);

%% init
% Block name for model dialog parameters
settingsBlkName = 'Model Parameters';

% Get parameters from model settings block.
settingsBlk = [bdroot '/' settingsBlkName];

% Model name
[rcvdSignal, agcStepSize, agcMaxGain, ...
    corrThreshold, sampsPerChip] =  ...
    getparamvals(settingsBlk,...
    'rcvdSignal', ...
    'agcStepSize', ...
    'agcMaxGain', ...
    'corrThreshold', ...
    'sampsPerChip');

try
    validateattributes(agcStepSize, {'numeric'}, ...
        {'real','positive','scalar'}, ...
        'commwlan80211BeaconRxModelParams', '''AGC step size''');
catch e
    if strcmp(e.identifier, ...
            'MATLAB:commwlan80211BeaconRxModelParams:notLess')
        e = MException(e.identifier, strrep(e.message, '<', 'less then'));
    end
    throw(e)
end

validateattributes(agcMaxGain, {'numeric'}, ...
    {'real','positive','scalar'}, ...
    'commwlan80211BeaconRxModelParams', '''Maximum AGC gain''');

validateattributes(corrThreshold, {'numeric'}, ...
    {'real','positive','scalar', 'nonnan', 'finite'}, ...
    'commwlan80211BeaconRxModelParams', '''Synchronization threshold''');

% switch rcvdSignal
%     case 'Channel 5'
%         load('beacon_chan5_01_44MHz', 'rcvd')
%     case 'Channel 9'
%         load('beacon_chan9_01_44MHz', 'rcvd')
% end
% 
% rcvd.signals.values = rcvd.signals.values(1:4/sampsPerChip:end,:,:); %#ok<NODEF>
% rcvd.signals.dimensions(1) = rcvd.signals.dimensions(1) ...
%     / (4/sampsPerChip);

load('data', 'rcvd');
assignin('base', 'rcvd', rcvd);

p80211 = commwlan80211BeaconRxInit(agcStepSize, agcMaxGain, ...
    corrThreshold, sampsPerChip);

assignin('base', 'p80211', p80211);

%% scope
screenSize = get(0,'screensize');
if screenSize < 1190
    maxWidth = screenSize(3);
else
    maxWidth = 1190;
end
marginH = 20;
marginV = 120;
marginB = 60;
scopeWidth = floor((maxWidth - 7*marginH)/4);
xPos = 20:scopeWidth+marginH:maxWidth-20;
scopeHeight = floor((screenSize(4)-marginV)/3);
yPos = screenSize(4) - scopeHeight - marginV;

modelname = bdroot;
agcScope = [modelname ...
    '/Rx Front End/AGC Scope'];
freqOffsetScope = [modelname ...
    '/Rx Front End/Estimated Frequency Offset'];
syncScope = [modelname ...
    '/Receiver Controller/Synchronization Scope'];
chipsSP = [modelname ...
    '/Receiver Controller/Received Chips'];
symbolsSP = [modelname ...
    '/Receiver Controller/Received Symbols'];
hagcScope = get_param(agcScope,'ScopeConfiguration');
hagcScope.Position = [xPos(1) yPos scopeWidth scopeHeight];
hfreqOffsetScope = get_param(freqOffsetScope,'ScopeConfiguration');
hfreqOffsetScope.Position = [xPos(2) yPos scopeWidth scopeHeight];
hsyncScope = get_param(syncScope,'ScopeConfiguration');
hsyncScope.Position = [xPos(3) yPos scopeWidth scopeHeight];
scatterWidth = floor(0.9*scopeWidth);
scatterHeight = scatterWidth;
yPosScat = yPos-scatterHeight - marginV;
xPosScat = [xPos(1) xPos(1)+marginH+scatterWidth];
set_param(chipsSP, 'FigPos', ...
    mat2str([xPosScat(1) yPosScat scatterWidth scatterHeight]));
set_param(symbolsSP, 'FigPos', ...
    mat2str([xPosScat(2) yPosScat scatterWidth scatterHeight]));
xPosMPDU = xPosScat(2)+2*marginH+scatterWidth;
mpduWidth = (xPos(4)+scopeWidth) - xPosMPDU;
mpduHeight = yPos - marginH - marginB;
if mpduHeight > 530
    mpduHeight = 530;
end
assignin('base', 'mpduFigPos', [xPosMPDU marginB mpduWidth mpduHeight]);
end

function varargout = getparamvals(blk, varargin)
% Get parameter values from block.  This process uses the 'Evaluate' check
% box (in the mask) to determine whether the parameter string should be
% evaluated in the base workspace.
h = get_param(blk, 'Handle');
maskVars = get(h, 'MaskVariables');
for n = 1:length(varargin)
    paramName = varargin{n};
    paramValStr = get(h, paramName);
    evalParam = maskVars(strfind(maskVars, paramName) ...
        + length(paramName) + 1) == '@';
    if evalParam
        varargout{n} = evalin('base', paramValStr); %#ok<AGROW>
    else
        varargout{n} = paramValStr; %#ok<AGROW>
    end
end
end
