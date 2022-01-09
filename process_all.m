% This script will process the data from all 4 subjects and outputs the
% gain (snr_coil/snr_body) for the speech and head coil, for all subjects.

% Please run this script from speech_coil_eval

% add speech_coil_eval to the path:
addpath(genpath('../speech_coil_eval/'));

% change directory to data and read filenames:
cd ./data/
d = dir;
% initizize data contatiner to store ratios:
ratio = struct;

% loop through volunteers to obtain snr ratios:
for i = 1:size(d,1)
    
if startsWith(d(i).name,'vol')
     folder_name = d(i).name;
     cd(folder_name)
     fprintf('Currently reading %s',folder_name)
    
    % put ratios in data container:
    [ ratio(i).sp, ratio(i).hd ] = ratio_output;
    % return to data folder:
    cd ..
end

end

% remove empty fields:
while isempty(ratio(1).sp)
    ratio(1) = [];
end
    
clearvars folder_name i d

%% Plot all ratios:

figure1 = figure;
figure1.Position = [1185 347 992 690];

tlo = tiledlayout(2,3,'TileSpacing','none');
t = title(tlo,'SNR GAIN');
t.FontSize = 28;
t.FontWeight = 'bold';
list = ["1","2","3"];%,"4"];

% plot speech ratios:
for i = 1:3
h(i) = nexttile(tlo); %vol 2x
imshow(ratio(i).sp(:,:,18),[])
t=title(list(i));
t.FontSize = 24;
end

% plot head ratios:
for i=1:3
h(i+3) = nexttile(tlo);
imshow(ratio(i).hd(:,:,18),[])
end


% set colormap:
set(h, 'Colormap', jet, 'CLim', [0 40])

cbh = colorbar(h(end)); 

cbh.Layout.Tile = 'east'; 

% Create textbox for title "UA" 
annotation(figure1,'textbox',[0.020128087831656 0.256788887907718 0.0713632204940532 0.0482180293501049],'String',{'HN'},...
    'LineStyle','none',...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FontSize',24,...
    'FitBoxToText','off');

% Create textbox for title "HN" 
annotation(figure1,'textbox',[0.0286346773080534 0.665255621012462 0.0720057618502266 0.0746991383607495],'String',{'UA'},...
    'LineStyle','none',...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FontSize',24,...
    'FitBoxToText','off');

