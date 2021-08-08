function [PeakArea] = ShirleyRG(input)
%SHIRLEYRG Function to use to calculate Shirley background for XPS fitting.

global BE Intensity Background

% Get values from inputs
a = input(1);
b = input(2);

% Prepare P and Q area variables.
P = zeros(length(BE),1);
Q = zeros(length(BE),1);

% Calculate curremt background substracted intensities
BSintensity = Intensity - Background;

% Determine integral of P and Q for all X values
for Index = 1:1:length(BE)
    P(Index) = trapz(BSintensity(find(BE==max(BE)):Index));
    Q(Index) = trapz(BSintensity(Index:find(BE==min(BE))));
end

% Calculate new background
Background = (a-b).*Q./(P+Q) + b;
%plot(BE,Background)

% Value to minimize
PeakArea = sum(P)+sum(Q);               
end

