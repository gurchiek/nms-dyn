function [ i ] = getIndex( data, n, prompt)
%Reed Gurchiek, 2017
%
%   getIndex allows the user to click somewhere on the graph of data n 
%   times being prompted by prompt and returns the index of the location(s)
%   clicked
%
%------------------------------INPUTS--------------------------------------
%
%   data:
%       data to be plotted on which the user will click.  If y number of
%       plots are desired data should be a y x p matrix where p is the
%       number of data points
%
%   n:
%       number of indices to get
%
%   prompt (optional):
%       cell array of strings that will prompt the user for each click.  if
%       entered, there must be a prompt for each click (length of prompt
%       cell array must equal n).
%
%-------------------------------OUTPUTS------------------------------------
%
%   i:
%       indices
%
%--------------------------------------------------------------------------
%%  get_index

%if prompt input then make sure its length is n
if nargin == 3 && length(prompt) ~= n
    error('Number of strings in ''prompt'' cell array must be equal to number of indices ''n''');
end

%plot data
figure
hold on
set(gcf,'units','normalized','outerposition',[0 0 1 1])
[datar, ~] = size(data);
for k = 1:datar
    plot(data(k,:))
end

%allocate space for i
i = zeros(1,n);

%get indices
for k = 1:n
    
    %if prompts given
    if nargin == 3
        annotation('textbox',[0.15 0.7 0.1 0.1],'String',prompt{k},'FitBoxToText','on','Color','red','Tag','annot');
        [i0,~] = ginput(1);
        i(k) = round(i0);
        delete(findall(gcf,'Tag','annot'));
    %if no prompts given
    elseif nargin == 2
        str = strcat('Get Index ',num2str(k));
        annotation('textbox',[0.15 0.7 0.1 0.1],'String',str,'FitBoxToText','on','Color','red','Tag','annot');
        [i0,~] = ginput(1);
        i(k) = round(i0);
        delete(findall(gcf,'Tag','annot'));
    end
end

close
end

