session = 'jn039-1.mat';

directory = 'Z:\Dropbox\Dropbox\Chen Lab Team Folder\Projects\CRACK\OIST OCNC\sample dataset\2P\';
data = load([directory session]);
binSize = 1/data.CaA0.sampling_rate;
data = generateCovariates(session);

