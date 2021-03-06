clear
global BEShirley IntensityShirley BackgroundShirley     %Globals needed to pass values to Shirley background function in this version.

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

%% Apply any shifts needed.

BEshift = input('What shift in eV should be applied to the binding energies? (answer 0 if you do not know): ');
BE = BE+BEshift;

%% Determine bounds for Shirley background

BoundPlot = figure;
plot(BE, Intensity);   % Generate plot to set bounds on Shirley background fitting.
BoundPlot.CurrentAxes.XDir = 'reverse';                                         % Set to typical reverse X axis
title({'Click twice to select the X bounds for the Shirley background.', 'Press ESC twice to skip the Shirley background.'});

[BoundX,BoundY,button] = ginput(2);
close(BoundPlot)



%% Determine Shirley background

if isempty(find(button == 27,1)) == 1
    disp('Starting Shirley background fit...')
    
    LowShirleyBound = min(BoundX);
    HighShirleyBound = max(BoundX);
    [ShirleyIndex,~] = find(BE(:,1) >= LowShirleyBound & BE(:,1) < HighShirleyBound);
    
    BEShirley = BE(ShirleyIndex);
    IntensityShirley = Intensity(ShirleyIndex);
    
    a0 = IntensityShirley(BEShirley==max(BEShirley));   %Find initial background value at highest BE
    b0 = IntensityShirley(BEShirley==min(BEShirley));   %Find initial background value at lowest BE
    
    BackgroundShirley = repmat(IntensityShirley(BEShirley==min(BEShirley)),length(BEShirley),1);  %Get initial background from constant value
    
    % Determine Shirley background by minimizing the peak areas.
    [BestFitValues,exitflag,output] = fminsearch(@ShirleyRG,[a0 b0]);
    
    Background = [repmat(BackgroundShirley(1),ShirleyIndex(1)-1,1); BackgroundShirley; repmat(BackgroundShirley(end),length(BE) - ShirleyIndex(end),1)];
    
    BSintensity = Intensity - Background;   % Determine background corrected intensities
    
    disp('... fit complete!')
    
else
    disp('No Shirley background applied.')
    Background = zeros(size(Intensity));
    BSintensity = Intensity - Background;
end

%% Do the peak fitting


FitPlot = figure;
plot(BE, Intensity,BE,Background);                   % Generate helpful plot to set fitting bounds and initial guesses
FitPlot.CurrentAxes.XDir = 'reverse';
title('Click to select the X bounds in which you want to fit peaks.')

[XfitRange,YfitRange] = ginput(2);
LowRange = min(XfitRange);
HighRange = max(XfitRange);

title({'Now click to select the initial X,Y coordinates of peaks.', 'Press ENTER to finish.'})
[XPeakGuess,YPeakGuess] = ginput(5);
n = length(XPeakGuess);
close(FitPlot)

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
        InitialGuess(3) = YPeakGuess(1);
        LowerBound(3) = 0;
        UpperBound(3) = inf;
        
        InitialGuess(4) = XPeakGuess(1);
        LowerBound(4) = LowRange;
        UpperBound(4) = HighRange;
        
        InitialGuess(5) = 1;
        LowerBound(5) = 0.4;
        UpperBound(5) = inf;
        
    case 2
        % For 2 gaussian peaks
        modelfun = @(b,x) b(1) + b(2) * x + b(3) * exp(-(x(:, 1) - b(4)).^2/b(5))...
            + b(6) * exp(-(x(:, 1) - b(7)).^2/b(8));
        
        % Determine initial guess for Gaussian peak
        % For first Gaussian peak        
        InitialGuess(3) = YPeakGuess(1);
        LowerBound(3) = 0;
        UpperBound(3) = inf;
        
        InitialGuess(4) = XPeakGuess(1);
        LowerBound(4) = LowRange;
        UpperBound(4) = HighRange;
        
        InitialGuess(5) = 1;
        LowerBound(5) = 0.4;
        UpperBound(5) = inf;
        
        % For second Gaussian peak
        InitialGuess(6) = YPeakGuess(2);
        LowerBound(6) = 0;
        UpperBound(6) = inf;
        
        InitialGuess(7) = XPeakGuess(2);
        LowerBound(7) = LowRange;
        UpperBound(7) = HighRange;
        
        InitialGuess(8) = 1;
        LowerBound(8) = 0.4;
        UpperBound(8) = inf;
        
    case 3
        % For 3 gaussian peaks
        modelfun = @(b,x) b(1) + b(2) * x + b(3) * exp(-(x(:, 1) - b(4)).^2/b(5))...
            + b(6) * exp(-(x(:, 1) - b(7)).^2/b(8))...
            + b(9) * exp(-(x(:, 1) - b(10)).^2/b(11));
        
        % Determine initial guess for Gaussian peak
        % For first Gaussian peak
        InitialGuess(3) = YPeakGuess(1);
        LowerBound(3) = 0;
        UpperBound(3) = inf;
        
        InitialGuess(4) = XPeakGuess(1);
        LowerBound(4) = LowRange;
        UpperBound(4) = HighRange;
        
        InitialGuess(5) = 1;
        LowerBound(5) = 0.4;
        UpperBound(5) = inf;
        
        % For second Gaussian peak
        InitialGuess(6) = YPeakGuess(2);
        LowerBound(6) = 0;
        UpperBound(6) = inf;
        
        InitialGuess(7) = XPeakGuess(2);
        LowerBound(7) = LowRange;
        UpperBound(7) = HighRange;
        
        InitialGuess(8) = 1;
        LowerBound(8) = 0.4;
        UpperBound(8) = inf;
        
        % For third Gaussian peak
        InitialGuess(9) = YPeakGuess(3);
        LowerBound(9) = 0;
        UpperBound(9) = inf;
        
        InitialGuess(10) = XPeakGuess(3);
        LowerBound(10) = LowRange;
        UpperBound(10) = HighRange;
        
        InitialGuess(11) = 1;
        LowerBound(11) = 0.4;
        UpperBound(11) = inf;
        
    case 4
        % For 4 gaussian peaks
        modelfun = @(b,x) b(1) + b(2) * x + b(3) * exp(-(x(:, 1) - b(4)).^2/b(5))...
            + b(6) * exp(-(x(:, 1) - b(7)).^2/b(8))...
            + b(9) * exp(-(x(:, 1) - b(10)).^2/b(11))...
            + b(12) * exp(-(x(:, 1) - b(13)).^2/b(14));
        
        % Determine initial guess for Gaussian peak
        % For first Gaussian peak
        InitialGuess(3) = YPeakGuess(1);
        LowerBound(3) = 0;
        UpperBound(3) = inf;
        
        InitialGuess(4) = XPeakGuess(1);
        LowerBound(4) = LowRange;
        UpperBound(4) = HighRange;
        
        InitialGuess(5) = 1;
        LowerBound(5) = 0.4;
        UpperBound(5) = inf;
        
        % For second Gaussian peak
        InitialGuess(6) = YPeakGuess(2);
        LowerBound(6) = 0;
        UpperBound(6) = inf;
        
        InitialGuess(7) = XPeakGuess(2);
        LowerBound(7) = LowRange;
        UpperBound(7) = HighRange;
        
        InitialGuess(8) = 1;
        LowerBound(8) = 0.4;
        UpperBound(8) = inf;
        
        % For third Gaussian peak
        InitialGuess(9) = YPeakGuess(3);
        LowerBound(9) = 0;
        UpperBound(9) = inf;
        
        InitialGuess(10) = XPeakGuess(3);
        LowerBound(10) = LowRange;
        UpperBound(10) = HighRange;
        
        InitialGuess(11) = 1;
        LowerBound(11) = 0.4;
        UpperBound(11) = inf;
        
        % For fourth Gaussian peak
        InitialGuess(12) = YPeakGuess(4);
        LowerBound(12) = 0;
        UpperBound(12) = inf;
        
        InitialGuess(13) = XPeakGuess(4);
        LowerBound(13) = LowRange;
        UpperBound(13) = HighRange;
        
        InitialGuess(14) = 1;
        LowerBound(14) = 0.4;
        UpperBound(14) = inf;
        
    case 5
        % For 5 gaussian peaks
        modelfun = @(b,x) b(1) + b(2) * x + b(3) * exp(-(x(:, 1) - b(4)).^2/b(5))...
            + b(6) * exp(-(x(:, 1) - b(7)).^2/b(8))...
            + b(9) * exp(-(x(:, 1) - b(10)).^2/b(11))...
            + b(12) * exp(-(x(:, 1) - b(13)).^2/b(14))...
            + b(15) * exp(-(x(:, 1) - b(16)).^2/b(17));
        
        % Determine initial guess for Gaussian peak

        % For first Gaussian peak
        InitialGuess(3) = YPeakGuess(1);
        LowerBound(3) = 0;
        UpperBound(3) = inf;
        
        InitialGuess(4) = XPeakGuess(1);
        LowerBound(4) = LowRange;
        UpperBound(4) = HighRange;
        
        InitialGuess(5) = 1;
        LowerBound(5) = 0.4;
        UpperBound(5) = inf;
        
        % For second Gaussian peak
        InitialGuess(6) = YPeakGuess(2);
        LowerBound(6) = 0;
        UpperBound(6) = inf;
        
        InitialGuess(7) = XPeakGuess(2);
        LowerBound(7) = LowRange;
        UpperBound(7) = HighRange;
        
        InitialGuess(8) = 1;
        LowerBound(8) = 0.4;
        UpperBound(8) = inf;
        
        % For third Gaussian peak
        InitialGuess(9) = YPeakGuess(3);
        LowerBound(9) = 0;
        UpperBound(9) = inf;
        
        InitialGuess(10) = XPeakGuess(3);
        LowerBound(10) = LowRange;
        UpperBound(10) = HighRange;
        
        InitialGuess(11) = 1;
        LowerBound(11) = 0.4;
        UpperBound(11) = inf;
        
        % For fourth Gaussian peak
        InitialGuess(12) = YPeakGuess(4);
        LowerBound(12) = 0;
        UpperBound(12) = inf;
        
        InitialGuess(13) = XPeakGuess(4);
        LowerBound(13) = LowRange;
        UpperBound(13) = HighRange;
        
        InitialGuess(14) = 1;
        LowerBound(14) = 0.4;
        UpperBound(14) = inf;
        
        % For fifth Gaussian peak
        InitialGuess(15) = YPeakGuess(5);
        LowerBound(15) = 0;
        UpperBound(15) = inf;
        
        InitialGuess(16) = XPeakGuess(5);
        LowerBound(16) = LowRange;
        UpperBound(16) = HighRange;
        
        InitialGuess(17) = 1;
        LowerBound(17) = 0.4;
        UpperBound(17) = inf;
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
plot(BE, FitRG,':','Color',[0.15,0.15,0.15],'Linewidth',2);
hold on
plot(BE, Intensity,'Color',[0.64,0.08,0.18],'Linewidth',1.5);
plot(BE, FitBkg, 'Color',[0.50,0.50,0.50],'Linewidth',0.8)

% General Setup
ax = gca;
fig = gcf;
ax.Color = 'white';
ax.LineWidth = 1.5;
ax.Box = 'on';
ax.FontWeight = 'bold';


GaussMdl = @(c,x) c(1) * exp(-(x(:, 1) - c(2)).^2/c(3));
switch n
    case 1
        GaussFit = feval(GaussMdl,coefficients(3:5),BE) + FitBkg;
        %plot(BE,GaussFit)
        fill([BE' fliplr(BE')],[GaussFit' fliplr(FitBkg')],[0.47,0.67,0.19],'EdgeColor','none','FaceAlpha',0.5);
        
        legend('TotalFit','Data','Background',['Peak 1: ' num2str(coefficients(4),'%.1f') ' eV; ']);
        legend('boxoff','bold','fontsize',9);
        xlabel('Binding Energy (eV)');
        ylabel('Intensity');
        
        
    case 2
        GaussFit = feval(GaussMdl,coefficients(3:5),BE);    % Calculate fit curve
        PeakArea(1) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        %plot(BE,GaussFit)
        fill([BE' fliplr(BE')],[GaussFit' fliplr(FitBkg')],[0.47,0.67,0.19],'EdgeColor','none','FaceAlpha',0.5);
        
        GaussFit = feval(GaussMdl,coefficients(6:8),BE);    % Calculate fit curve
        PeakArea(2) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        %plot(BE,GaussFit)
        fill([BE' fliplr(BE')],[GaussFit' fliplr(FitBkg')],[0.49,0.18,0.56],'EdgeColor','none','FaceAlpha',0.5);
        
        
        % Determine the relative area of each Gauss peak.
        RelArea(1) = PeakArea(1)/sum(PeakArea)*100;
        RelArea(2) = PeakArea(2)/sum(PeakArea)*100;
        
        
        legend('TotalFit','Data','Background',['Peak 1: ' num2str(coefficients(4),'%.1f') ' eV; ' ...
            num2str(RelArea(1),'%.0f') '%'],['Peak 2: ' num2str(coefficients(7),'%.1f') ' eV; ' ...
            num2str(RelArea(2),'%.0f') '%']);
        legend('boxoff','bold','fontsize',9);
        xlabel('Binding Energy (eV)');
        ylabel('Intensity');
        
    case 3
        
        GaussFit = feval(GaussMdl,coefficients(3:5),BE);    % Calculate fit curve
        PeakArea(1) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        %plot(BE,GaussFit)
        fill([BE' fliplr(BE')],[GaussFit' fliplr(FitBkg')],[0.47,0.67,0.19],'EdgeColor','none','FaceAlpha',0.5);
        
        
        GaussFit = feval(GaussMdl,coefficients(6:8),BE);    % Calculate fit curve
        PeakArea(2) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        %plot(BE,GaussFit)
        fill([BE' fliplr(BE')],[GaussFit' fliplr(FitBkg')],[0.49,0.18,0.56],'EdgeColor','none','FaceAlpha',0.5);
        
        
        GaussFit = feval(GaussMdl,coefficients(9:11),BE);    % Calculate fit curve
        PeakArea(3) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        %plot(BE,GaussFit)
        fill([BE' fliplr(BE')],[GaussFit' fliplr(FitBkg')],[0.30,0.75,0.93],'EdgeColor','none','FaceAlpha',0.5);
        
        
        % Determine the relative area of each Gauss peak.
        RelArea(1) = PeakArea(1)/sum(PeakArea)*100;
        RelArea(2) = PeakArea(2)/sum(PeakArea)*100;
        RelArea(3) = PeakArea(3)/sum(PeakArea)*100;
        
        
        
        legend('TotalFit','Data','Background',['Peak 1: ' num2str(coefficients(4),'%.1f') ' eV; ' ...
            num2str(RelArea(1),'%.0f') '%'],['Peak 2: ' num2str(coefficients(7),'%.1f') ' eV; ' ...
            num2str(RelArea(2),'%.0f') '%'],['Peak 3: ' num2str(coefficients(10),'%.1f') ' eV; ' ...
            num2str(RelArea(3),'%.0f') '%']);
        legend('boxoff','bold','fontsize',9);
        xlabel('Binding Energy (eV)');
        ylabel('Intensity');
        
        
    case 4
        GaussFit = feval(GaussMdl,coefficients(3:5),BE);    % Calculate fit curve
        PeakArea(1) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        %plot(BE,GaussFit)
        fill([BE' fliplr(BE')],[GaussFit' fliplr(FitBkg')],[0.47,0.67,0.19],'EdgeColor','none','FaceAlpha',0.5);
        
        GaussFit = feval(GaussMdl,coefficients(6:8),BE);    % Calculate fit curve
        PeakArea(2) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        %plot(BE,GaussFit)
        fill([BE' fliplr(BE')],[GaussFit' fliplr(FitBkg')],[0.49,0.18,0.56],'EdgeColor','none','FaceAlpha',0.5);
        
        GaussFit = feval(GaussMdl,coefficients(9:11),BE);   % Calculate fit curve
        PeakArea(3) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        %plot(BE,GaussFit)
        fill([BE' fliplr(BE')],[GaussFit' fliplr(FitBkg')],[0.30,0.75,0.93],'EdgeColor','none','FaceAlpha',0.5);
        
        GaussFit = feval(GaussMdl,coefficients(12:14),BE);  % Calculate fit curve
        PeakArea(4) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        %plot(BE,GaussFit)
        fill([BE' fliplr(BE')],[GaussFit' fliplr(FitBkg')],[0.64,0.08,0.18],'EdgeColor','none','FaceAlpha',0.5);
        
        
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
        legend('boxoff','bold','fontsize',9);
        xlabel('Binding Energy (eV)');
        ylabel('Intensity');
        
    case 5
        GaussFit = feval(GaussMdl,coefficients(3:5),BE);    % Calculate fit curve
        PeakArea(1) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        %plot(BE,GaussFit)
        fill([BE' fliplr(BE')],[GaussFit' fliplr(FitBkg')],[0.47,0.67,0.19],'EdgeColor','none','FaceAlpha',0.5);
        
        GaussFit = feval(GaussMdl,coefficients(6:8),BE);    % Calculate fit curve
        PeakArea(2) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        %plot(BE,GaussFit)
        fill([BE' fliplr(BE')],[GaussFit' fliplr(FitBkg')],[0.49,0.18,0.56],'EdgeColor','none','FaceAlpha',0.5);
        
        GaussFit = feval(GaussMdl,coefficients(9:11),BE);   % Calculate fit curve
        PeakArea(3) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        %plot(BE,GaussFit)
        fill([BE' fliplr(BE')],[GaussFit' fliplr(FitBkg')],[0.30,0.75,0.93],'EdgeColor','none','FaceAlpha',0.5);
        
        GaussFit = feval(GaussMdl,coefficients(12:14),BE);  % Calculate fit curve
        PeakArea(4) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        %plot(BE,GaussFit)
        fill([BE' fliplr(BE')],[GaussFit' fliplr(FitBkg')],[0.64,0.08,0.18],'EdgeColor','none','FaceAlpha',0.5);
        
        GaussFit = feval(GaussMdl,coefficients(15:17),BE);  % Calculate fit curve
        PeakArea(5) = trapz(GaussFit);                      % Determine area of peak
        GaussFit = GaussFit + FitBkg;                       % Add background for plotting
        %plot(BE,GaussFit)
        fill([BE' fliplr(BE')],[GaussFit' fliplr(FitBkg')],[0.93,0.70,0.10],'EdgeColor','none','FaceAlpha',0.5);
        
        % Determine the relative area of each Gauss peak.
        RelArea(1) = PeakArea(1)/sum(PeakArea)*100;
        RelArea(2) = PeakArea(2)/sum(PeakArea)*100;
        RelArea(3) = PeakArea(3)/sum(PeakArea)*100;
        RelArea(4) = PeakArea(4)/sum(PeakArea)*100;
        RelArea(5) = PeakArea(5)/sum(PeakArea)*100;
        
        legend('TotalFit','Data','Background',['Peak 1: ' num2str(coefficients(4),'%.1f') ' eV; ' ...
            num2str(RelArea(1),'%.0f') '%'],['Peak 2: ' num2str(coefficients(7),'%.1f') ' eV; ' ...
            num2str(RelArea(2),'%.0f') '%'],['Peak 3: ' num2str(coefficients(10),'%.1f') ' eV; ' ...
            num2str(RelArea(3),'%.0f') '%'],['Peak 4: ' num2str(coefficients(13),'%.1f') ' eV; ' ...
            num2str(RelArea(4),'%.0f') '%'],['Peak 5: ' num2str(coefficients(16),'%.1f') ' eV; ' ...
            num2str(RelArea(5),'%.0f') '%']);
        legend('boxoff','bold','fontsize',9);
        xlabel('Binding Energy (eV)');
        ylabel('Intensity');
        
end
hold off

disp('... fit complete!')

FitFigure.CurrentAxes.XDir = 'reverse' ;                    % Make X axis as typical XPS data.
FitFigure.CurrentAxes.Legend.Location = 'best';             % Adjust where the legend is.

disp(['The residuals are ' num2str(resnorm)])
