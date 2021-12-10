function [output] = SinglePeakFunc(x,params)
%SINGLEPEAKFUNC Single Voigt peak as sum of Gauss and Lorentzian

output = params(1)*(1-params(2))*exp(-4*log(2)*((x-params(3)).^2)./(params(4))^2)+...
    params(1)*params(2)./(1+4*((x-params(3)).^2)./(params(4)).^2);

end

