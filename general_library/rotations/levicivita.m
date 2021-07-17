function [ e ] = levicivita( vi,vj,vk )
%Reed Gurchiek, 2020
%   levicivita returns the Levi-Civita symbol for the sequence i->j->k (see
%   Shuster 1993)
%
%--------------------------------INPUTS------------------------------------
%
%   vi,vj,vk:
%       3xn column vectors of principal axes.
%           1. x = [1 0 0]';
%           2. y = [0 1 0]';
%           3. z = [0 0 1]';
%
%--------------------------------OUTPUTS-----------------------------------
%
%   e:
%       1xn array of Levi-Civita symbol for each sequence inputs vectors
%
%--------------------------------------------------------------------------
%% levicivita

%verify proper inputs
[vir,vic] = size(vi);
[vjr,vjc] = size(vj);
[vkr,vkc] = size(vk);
if vir ~= 3 || vjr ~= 3 || vkr ~= 3
    error('vi,vj,vk must be 3xn');
elseif vic ~= vjc || vic ~= vkc || vjc ~= vkc
    error('vi,vj,vk must have same number of columns')
else
    %for each vector
    e = zeros(1,vic);
    for k = 1:vic
        %verify proper input
        if length(find(vi(:,k) == 1)) ~= 1 || length(find(vi(:,k) == 0)) ~= 2
            error('columns of vi must have a 1 in one dimension and zeros elsewhere')
        elseif length(find(vj(:,k) == 1)) ~= 1 || length(find(vj(:,k) == 0)) ~= 2
            error('columns of vj must have a 1 in one dimension and zeros elsewhere')
        elseif length(find(vk(:,k) == 1)) ~= 1 || length(find(vk(:,k) == 0)) ~= 2
            error('columns of vk must have a 1 in one dimension and zeros elsewhere')
        else
            %get symbol
            e(k) = vi(:,k)'*cross(vj(:,k),vk(:,k));
        end
    end
end


end

