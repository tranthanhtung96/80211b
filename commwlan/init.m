% AGC parameters
p80211.AGCStepSize = 5;
p80211.AGCUpperLimit = 60;
p80211.DecimationFactor = 4;

% DSSS parameters
p80211.SymbolRate = 1e6;
p80211.BitsPerSymbol = 1;
p80211.SamplesPerChip = 2;
p80211.FilterOrder    = 8; %in symbols
p80211.SpreadingCode  = [1; -1; 1; 1; -1; 1; 1; 1; -1; -1; -1 ];
p80211.SpreadingRate  = length(p80211.SpreadingCode);
p80211.ChipRate       = p80211.SymbolRate * p80211.SpreadingRate;

% Frame synchronization
load('sync');
p80211.SynchronizationSignal = (1/p80211.SamplesPerChip) * sync(1:4/p80211.SamplesPerChip:end);
p80211.CorrelationThreshold = 500;


% (MSB to LSB) LSB is transmitted first in time
p80211.SYNC      = true(128,1);
p80211.SFD       = logical([0;0;0;0;0;1;0;1;1;1;0;0;1;1;1;1]); % 0xF3A0
p80211.SIGNAL    = logical([0;1;0;1;0;0;0;0]);        % 0x0A = 1Mb/s
p80211.SERVICE   = false(8, 1);                       % Reserved
p80211.LENGTH    = false(16, 1)';                     % microseconds
p80211.CRCLength = 16;                                % Bits

p80211.ScramblerPolynomial = [1 0 0 0 1 0 0 1];

p80211.ScramblerAmbiguity = (2^(length(p80211.ScramblerPolynomial)-1));
p80211.ScramblerAmbiguitySamples = p80211.ScramblerAmbiguity...
    *p80211.SpreadingRate*p80211.SamplesPerChip;

p80211.NumSYNCSamples = ...
    (length(p80211.SYNC) * p80211.SpreadingRate ...
    * p80211.SamplesPerChip) / p80211.BitsPerSymbol;

p80211.PLCPPreambleLength = length(p80211.SYNC) + length(p80211.SFD);
p80211.NumPLCPPreambleSamples = ...
    (p80211.PLCPPreambleLength * p80211.SpreadingRate ...
    * p80211.SamplesPerChip) / p80211.BitsPerSymbol;

p80211.PLCPHeaderLength = length(p80211.SIGNAL) ...
    + length(p80211.SERVICE) + length(p80211.LENGTH) + p80211.CRCLength;
p80211.NumPLCPHeaderSamples = ...
    (p80211.PLCPHeaderLength * p80211.SpreadingRate ...
    * p80211.SamplesPerChip) / p80211.BitsPerSymbol;

p80211.PLCPLength = p80211.PLCPPreambleLength + p80211.PLCPHeaderLength;
p80211.NumPLCPSamples = (p80211.PLCPLength * p80211.SpreadingRate ...
    * p80211.SamplesPerChip) / p80211.BitsPerSymbol;

% Bits per channel has to be a divisor of maximum frame size in bits
p80211.MaximumPPDULength = 1024;
p80211.MaximumMPDULength = p80211.MaximumPPDULength - p80211.PLCPLength;
p80211.SymbolsPerChannelFrame = 128;
p80211.BitsPerChannelFrame = p80211.SymbolsPerChannelFrame ...
    * p80211.BitsPerSymbol;

p80211.SamplesPerChannelFrame = (p80211.SymbolsPerChannelFrame ...
    * p80211.SpreadingRate * p80211.SamplesPerChip);

p80211.MaximumPayloadSymbols = 5000;  % In bits (65535 is standard maximum)
p80211.MaximumPayloadSamples = p80211.MaximumPayloadSymbols * ...
    p80211.SpreadingRate*p80211.SamplesPerChip;

p80211.PayloadBufferLength = p80211.MaximumPayloadSymbols + ...
    p80211.SymbolsPerChannelFrame + p80211.ScramblerAmbiguity;

