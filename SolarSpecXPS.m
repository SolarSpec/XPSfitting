clear
global BE Intensity Background

%% Select the data file to analyze
[file,path] = uigetfile('.ascii');

FullFileName = [path, file];

%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 4);
opts.Delimiter = "\t";
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.VariableTypes = ["string", "double", "double", "string"];

%% Import the data and select the key ones
FullTable = readtable(FullFileName,opts);

BE = FullTable.Var2(5:end-2);
Intensity = FullTable.Var3(5:end-2);

% Clear temporary variables
clear FullTable opts

%% Determine Shirley background
disp('Starting Shirley background fit...')

a0 = Intensity(BE==max(BE));   %Find initial background value at highest BE
b0 = Intensity(BE==min(BE));   %Find initial background value at lowest BE

Background = repmat(Intensity(BE==min(BE)),length(BE),1);  %Get initial background from constant value

% Determine Shirley background by minimizing the peak areas.
[BestFitValues,exitflag,output] = fminsearch(@ShirleyRG,[a0 b0]);

BSintensity = Intensity - Background;   % Determine background corrected intensities

disp('... fit complete!')

%% Do the peak fitting

% Flip data to use findpeaks which need increasing X values
FlipBE = flip(BE);
FlipBSInt = flip(BSintensity);

% Find peaks to help with initial guesses and generate helpful plot
[pks,locs,widths,proms] = findpeaks(FlipBSInt,FlipBE);

HelpPlot = figure;
plot(FlipBE, FlipBSInt);                            % Generate helpful plot
HelpPlot.CurrentAxes.XDir = 'reverse';              % Set to typical reverse X axis

PeakLabelInt = maxk(proms,6);                       % Find 6 most prominent peaks
for LabelInd = 1:1:6
    PeakLabelIndex = find(proms == PeakLabelInt(LabelInd));
    text(locs(PeakLabelIndex)+0.5,pks(PeakLabelIndex)+10,num2str(locs((PeakLabelIndex)))) % Add label
end

n = input('How many peaks do you want to fit? (max of 4) :');
LowRange = input('What is the lower bound (in eV) to find peaks? :');
HighRange = input('What is the upper bound (in eV) to find peaks? :');

close(HelpPlot)

disp('Starting peak fitting...')

InitialGuess(1) = BSintensity(1);  %Estimate constant background from first point
LowerBound(1) = -inf;
UpperBound(1) = inf;

InitialGuess(2) = (BSintensity(end) - BSintensity(1))/length(BSintensity);
LowerBound(2) = -inf;
UpperBound(2) = inf;

%% Define the model as the sume of n exponentials along the lines of Y = a + exp(-b*x) + c*x
switch n
    case 1
        % For 1 gaussian peak
        modelfun = @(b,x) b(1) + b(2) * x + b(3) * exp(-(x(:, 1) - b(4)).^2/b(5));
        
        % Determine initial guess for Gaussian peak
        PeakInt = maxk(proms,1);
        PeakIndex = find(proms == PeakInt);
        InitialGuess(3) = proms(PeakIndex);
        LowerBound(3) = 0;
        UpperBound(3) = inf;
        
        InitialGuess(4) = locs(PeakIndex);
        LowerBound(4) = LowRange;
        UpperBound(4) = HighRange;
        
        InitialGuess(5) = widths(PeakIndex) / 2.35;
        LowerBound(5) = 0;
        UpperBound(1) = inf;
        
    case 2
        % For 2 gaussian peaks
        modelfun = @(b,x) b(1) + b(2) * x + b(3) * exp(-(x(:, 1) - b(4)).^2/b(5))...
            + b(6) * exp(-(x(:, 1) - b(7)).^2/b(8));
        
        % Determine initial guess for Gaussian peak
        PeakInt = maxk(proms,2);
        PeakIndex = find(proms == PeakInt(1));      % For first Gaussian peak
        
        InitialGuess(3) = proms(PeakIndex);
        LowerBound(3) = 0;
        UpperBound(3) = inf;
        
        InitialGuess(4) = locs(PeakIndex);
        LowerBound(4) = LowRange;
        UpperBound(4) = HighRange;
        
        InitialGuess(5) = widths(PeakIndex) / 2.35;
        LowerBound(5) = 0;
        UpperBound(5) = inf;
        
        PeakIndex = find(proms == PeakInt(2));      % For second Gaussian peak
        InitialGuess(6) = proms(PeakIndex);
        LowerBound(6) = 0;
        UpperBound(6) = inf;
        
        InitialGuess(7) = locs(PeakIndex);
        LowerBound(7) = LowRange;
        UpperBound(7) = HighRange;
        
        InitialGuess(8) = widths(PeakIndex) / 2.35;
        LowerBound(8) = 0;
        UpperBound(8) = inf;
        
    case 3
        % For 3 gaussian peaks
        modelfun = @(b,x) b(1) + b(2) * x + b(3) * exp(-(x(:, 1) - b(4)).^2/b(5))...
            + b(6) * exp(-(x(:, 1) - b(7)).^2/b(8))...
            + b(9) * exp(-(x(:, 1) - b(10)).^2/b(11));
        
        % Determine initial guess for Gaussian peak
        PeakInt = maxk(proms,3);
        PeakIndex = find(proms == PeakInt(1));      % For first Gaussian peak
        
        InitialGuess(3) = proms(PeakIndex);
        LowerBound(3) = 0;
        UpperBound(3) = inf;
        
        InitialGuess(4) = locs(PeakIndex);
        LowerBound(4) = LowRange;
        UpperBound(4) = HighRange;
        
        InitialGuess(5) = widths(PeakIndex) / 2.35;
        LowerBound(5) = 0;
        UpperBound(5) = inf;
        
        PeakIndex = find(proms == PeakInt(2));      % For second Gaussian peak
        InitialGuess(6) = proms(PeakIndex);
        LowerBound(6) = 0;
        UpperBound(6) = inf;
        
        InitialGuess(7) = locs(PeakIndex);
        LowerBound(7) = LowRange;
        UpperBound(7) = HighRange;
        
        InitialGuess(8) = widths(PeakIndex) / 2.35;
        LowerBound(8) = 0;
        UpperBound(8) = inf;
        
        PeakIndex = find(proms == PeakInt(3));      % For third Gaussian peak
        InitialGuess(9) = proms(PeakIndex);
        LowerBound(9) = 0;
        UpperBound(9) = inf;
        
        InitialGuess(10) = locs(PeakIndex);
        LowerBound(10) = LowRange;
        UpperBound(10) = HighRange;
        
        InitialGuess(11) = widths(PeakIndex) / 2.35;
        LowerBound(11) = 0;
        UpperBound(11) = inf;
        
    case 4
        % For 4 gaussian peaks
        modelfun = @(b,x) b(1) + b(2) * x + b(3) * exp(-(x(:, 1) - b(4)).^2/b(5))...
            + b(6) * exp(-(x(:, 1) - b(7)).^2/b(8))...
            + b(9) * exp(-(x(:, 1) - b(10)).^2/b(11))...
            + b(12) * exp(-(x(:, 1) - b(13)).^2/b(14));
        
        % Determine initial guess for Gaussian peak
        PeakInt = maxk(proms,4);
        PeakIndex = find(proms == PeakInt(1));      % For first Gaussian peak
        
        InitialGuess(3) = proms(PeakIndex);
        LowerBound(3) = 0;
        UpperBound(3) = inf;
        
        InitialGuess(4) = locs(PeakIndex);
        LowerBound(4) = LowRange;
        UpperBound(4) = HighRange;
        
        InitialGuess(5) = widths(PeakIndex) / 2.35;
        LowerBound(5) = 0;
        UpperBound(5) = inf;
        
        PeakIndex = find(proms == PeakInt(2));      % For second Gaussian peak
        InitialGuess(6) = proms(PeakIndex);
        LowerBound(6) = 0;
        UpperBound(6) = inf;
        
        InitialGuess(7) = locs(PeakIndex);
        LowerBound(7) = LowRange;
        UpperBound(7) = HighRange;
        
        InitialGuess(8) = widths(PeakIndex) / 2.35;
        LowerBound(8) = 0;
        UpperBound(8) = inf;
        
        PeakIndex = find(proms == PeakInt(3));      % For third Gaussian peak
        InitialGuess(9) = proms(PeakIndex);
        LowerBound(9) = 0;
        UpperBound(9) = inf;
        
        InitialGuess(10) = locs(PeakIndex);
        LowerBound(10) = LowRange;
        UpperBound(10) = HighRange;
        
        InitialGuess(11) = widths(PeakIndex) / 2.35;
        LowerBound(11) = 0;
        UpperBound(11) = inf;
        
        PeakIndex = find(proms == PeakInt(4));      % For fourth Gaussian peak
        InitialGuess(12) = proms(PeakIndex);
        LowerBound(12) = 0;
        UpperBound(12) = inf;
        
        InitialGuess(13) = locs(PeakIndex);
        LowerBound(13) = LowRange;
        UpperBound(13) = HighRange;
        
        InitialGuess(14) = widths(PeakIndex) / 2.35;
        LowerBound(14) = 0;
        UpperBound(14) = inf;
end

%% Perform the fitting
% Define fit options
opts = statset('Display','iter');

% Now the next line is where the actual model computation is done.
[coefficients,resnorm] = lsqcurvefit(modelfun,InitialGuess,BE,BSintensity,LowerBound,UpperBound);

%% Look at the fit results
% Evaluate the fit and plot the comparison to the input data
FitRG = feval(modelfun,coefficients,BE) + Background;

BkgMdl = @(b,x) b(1) + b(2) * x;
FitBkg = feval(BkgMdl,coefficients(1:2),BE) + Background;

FitFigure = figure;
plot(BE, FitRG);
hold on
plot(BE, Intensity);
plot(BE, FitBkg)

GaussMdl = @(c,x) c(1) * exp(-(x(:, 1) - c(2)).^2/c(3));
switch n
    case 1
        GaussFit = feval(GaussMdl,coefficients(3:5),BE) + FitBkg;
        plot(BE,GaussFit)
        
        legend('TotalFit','Data','Background',['Peak 1: ' num2str(coefficients(4),'%.1f') ' eV; ']);
        
    case 2
        GaussFit = feval(GaussMdl,coefficients(3:5),BE);    % Calculate fit curve
        PeakArea(1) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        plot(BE,GaussFit)
        
        GaussFit = feval(GaussMdl,coefficients(6:8),BE);    % Calculate fit curve
        PeakArea(2) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        plot(BE,GaussFit)
        
        
        % Determine the relative area of each Gauss peak.
        RelArea(1) = PeakArea(1)/sum(PeakArea)*100;
        RelArea(2) = PeakArea(2)/sum(PeakArea)*100;
        
        
        legend('TotalFit','Data','Background',['Peak 1: ' num2str(coefficients(4),'%.1f') ' eV; ' ...
            num2str(RelArea(1),'%.0f') '%'],['Peak 2: ' num2str(coefficients(7),'%.1f') ' eV; ' ...
            num2str(RelArea(2),'%.0f') '%']);
        
    case 3
        GaussFit = feval(GaussMdl,coefficients(3:5),BE);    % Calculate fit curve
        PeakArea(1) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        plot(BE,GaussFit)
        
        GaussFit = feval(GaussMdl,coefficients(6:8),BE);    % Calculate fit curve
        PeakArea(2) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        plot(BE,GaussFit)
        
        GaussFit = feval(GaussMdl,coefficients(9:11),BE);    % Calculate fit curve
        PeakArea(3) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        plot(BE,GaussFit)
        
        
        % Determine the relative area of each Gauss peak.
        RelArea(1) = PeakArea(1)/sum(PeakArea)*100;
        RelArea(2) = PeakArea(2)/sum(PeakArea)*100;
        RelArea(3) = PeakArea(3)/sum(PeakArea)*100;
        
        
        legend('TotalFit','Data','Background',['Peak 1: ' num2str(coefficients(4),'%.1f') ' eV; ' ...
            num2str(RelArea(1),'%.0f') '%'],['Peak 2: ' num2str(coefficients(7),'%.1f') ' eV; ' ...
            num2str(RelArea(2),'%.0f') '%'],['Peak 3: ' num2str(coefficients(10),'%.1f') ' eV; ' ...
            num2str(RelArea(3),'%.0f') '%']);
        
    case 4
        GaussFit = feval(GaussMdl,coefficients(3:5),BE);    % Calculate fit curve
        PeakArea(1) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        plot(BE,GaussFit)
        
        GaussFit = feval(GaussMdl,coefficients(6:8),BE);    % Calculate fit curve
        PeakArea(2) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        plot(BE,GaussFit)
        
        GaussFit = feval(GaussMdl,coefficients(9:11),BE);   % Calculate fit curve
        PeakArea(3) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        plot(BE,GaussFit)
        
        GaussFit = feval(GaussMdl,coefficients(12:14),BE);  % Calculate fit curve
        PeakArea(4) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        plot(BE,GaussFit)
        
        
        % Determine the relative area of each Gauss peak.
        RelArea(1) = PeakArea(1)/sum(PeakArea)*100;
        RelArea(2) = PeakArea(2)/sum(PeakArea)*100;
        RelArea(3) = PeakArea(3)/sum(PeakArea)*100;
        RelArea(4) = PeakArea(4)/sum(PeakArea)*100;
        
        legend('TotalFit','Data','Background',['Peak 1: ' num2str(coefficients(4),'%.1f') ' eV; ' ...
            num2str(RelArea(1),'%.0f') '%'],['Peak 2: ' num2str(coefficients(7),'%.1f') ' eV; ' ...
            num2str(RelArea(2),'%.0f') '%'],['Peak 3: ' num2str(coefficients(10),'%.1f') ' eV; ' ...
            num2str(RelArea(3),'%.0f') '%'],['Peak 4: ' num2str(coefficients(13),'%.1f') ' eV; ' ...
            num2str(RelArea(4),'%.0f') '%']);
        
        
end
hold off

disp('... fit complete!')

FitFigure.CurrentAxes.XDir = 'reverse' ;                    % Make X axis as typical XPS data.
FitFigure.CurrentAxes.Legend.Location = 'best';             % Adjust where the legend is.

disp(['The residuals are ' num2str(resnorm)])
