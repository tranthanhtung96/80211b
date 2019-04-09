clear, clc;
a = csvread('samples.csv');
%%
b = a(:,1) + 1i*a(:,2);
c = reshape(b, 2816, 1, []);

%%
rcvd.time = [];
rcvd.signals.values = c/100;
rcvd.signals.dimensions = [2816,1];

%%
save('data.mat','rcvd');