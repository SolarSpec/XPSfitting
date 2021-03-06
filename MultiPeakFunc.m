function [output] = MultiPeakFunc(x,params)
%MultiPeakFunc Function to evaluate multiple Voigt peaks as defined by SinglePeakFunc
% Params is an n x 4 matrix, where n is the number of peaks

    output = zeros(length(x),1);
    TempOutput = zeros(length(x),1);
    
    for i = 1 : size(params,1)
        TempOutput = SinglePeakFunc(x,params(i,:));
        output = output + TempOutput;
    end

end

function [output] = SinglePeakFunc(x,params)
%SINGLEPEAKFUNC Single Voigt peak as sum of Gauss and Lorentzian

output = params(1)*(1-params(2))*exp(-4*log(2)*((x-params(3)).^2)./(params(4))^2)+...
    params(1)*params(2)./(1+4*((x-params(3)).^2)./(params(4)).^2);

end

