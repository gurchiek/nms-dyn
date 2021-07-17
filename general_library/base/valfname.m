function [ validFieldname ] = valfname(fieldname)
%Reed Gurchiek, 2018
%   make a fieldname valid by replacing invalid characters with '_' or ''
%   and leading numbers with 'x'
%
%---------------------------INPUTS-----------------------------------------
%
%   fieldname:
%       string, field name to validate
%
%--------------------------OUTPUTS-----------------------------------------
%
%   validFieldname:
%       string, validated field name
%
%--------------------------------------------------------------------------
%% valfname

validFieldname = replace(fieldname,{' ','-',},'_');
validdec = hex2dec(dec2hex('abcdefghijklmnopqrstuvwxyz_ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'));
l = 1;
while l <= length(validFieldname)
    if ~any(hex2dec(dec2hex(validFieldname(l))) == validdec)
        validFieldname(l) = [];
    else
        l = l+1;
    end
end
if (48 <= hex2dec(dec2hex(validFieldname(1)))) && (hex2dec(dec2hex(validFieldname(1))) <= 57); validFieldname = strcat('x',validFieldname); end


end