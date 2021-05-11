%% Define directories and conversion factors
dataDir = 'E:\Two Channel Nematic\Linnea Data\forRemi\Linnea Original Data';
analysisDir = 'E:\Two Channel Nematic\Linnea Data\forRemi\Linnea Original Data';
% dataDir = 'D:\Two Channel Nematic\Linnea Data\forRemi\2020-11-19 Analysis';
% analysisDir = 'D:\Two Channel Nematic\Alex Two Color MT Data\Data Set 1\Combined\Stephen Test\Channel 1\Channel 1';
pixelConv = 6.5*2/100;   %in microns/pixel
timeConv = 0.35;    %in seconds/frame
angleCutOff = 10;   %in degrees
axisCutOff = 1;     %microns
allDataName = 'LinneaOgVelPairs_unscaled.csv';

%% 