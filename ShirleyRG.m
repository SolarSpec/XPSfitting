function [PeakArea] = ShirleyRG(input)
%SHIRLEYRG Function to use to calculate Shirley background for XPS fitting.

global BEShirley IntensityShirley BackgroundShirley

% Get values from inputs
a = input(1);
b = input(2);

% Prepare P and Q area variables.
P = zeros(length(BEShirley),1);
Q = zeros(length(BEShirley),1);

% Calculate curremt background substracted intensities
BSintensity = IntensityShirley - BackgroundShirley;

% Determine integral of P and Q for all X values
for Index = 1:1:length(BEShirley)
    P(Index) = trapz(BSintensity(find(BEShirley==max(BEShirley)):Index));
    Q(Index) = trapz(BSintensity(Index:find(BEShirley==min(BEShirley))));
end

% Calculate new background
BackgroundShirley = (a-b).*Q./(P+Q) + b;
%plot(BE,Background)

% Value to minimize
PeakArea = sum(P)+sum(Q);               
end

