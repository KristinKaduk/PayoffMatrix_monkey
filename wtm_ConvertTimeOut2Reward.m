function [PayOff] = wtm_ConvertTimeOut2Reward(PayOff,Coefficient)

if nargin < 2
    error('provide 2 Inputs');
end

% for all negative values -> convert

% PayOff ./Coefficient
PayOff(sign(PayOff)<0) = PayOff(sign(PayOff)<0)*Coefficient; 
