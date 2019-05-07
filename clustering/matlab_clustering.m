clear all, close all;

fileID = fopen('data.csv');
text = textscan(fileID, '%s');
text = char(text{1,1});

%%
mac = hex2dec(text(1:2:end, [1 2 4 5 7 8 10 11 13 14 16 17]));
fo = str2double(cellstr(strrep(string(text(2:2:end, :)), ',', '.')));

[~, ~, cluster] = unique(mac);

%%
alldata = [mac fo cluster];
save('alldata');