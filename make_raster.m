% 
% session = 'jn039-17.mat';
% 
% directory = 'Z:\Dropbox\Dropbox\Chen Lab Team Folder\Projects\CRACK\OIST OCNC\sample dataset\2P\';
% data = load([directory session]);
% binSize = 1/data.CaA0.sampling_rate;
% data = generateCovariates(session);


%%
function make_raster(neuronNum,data, session)

stimtimes = [find(diff(data(1).CW)), find(diff(data(1).CCW))];

CW_CW_trial = 1;
CW_CCW_trial = 1;
CCW_CW_trial = 1;
CCW_CCW_trial = 1;
CW_CW_spikes = logical([]);
CW_CCW_spikes = logical([]);
CCW_CW_spikes = logical([]);
CCW_CCW_spikes = logical([]);
for i = 1:length(data)
    if strcmp(data(i).stim1, 'CW') &&  strcmp(data(i).stim2, 'CW')
        CW_CW_spikes(CW_CW_trial,:) = data(i).Ca1_spikes(neuronNum,:);
        CW_CW_trial = CW_CW_trial + 1;
    end
    if strcmp(data(i).stim1, 'CW') &&  strcmp(data(i).stim2, 'CCW')
        CW_CCW_spikes(CW_CCW_trial,:) = data(i).Ca1_spikes(neuronNum,:);
        CW_CCW_trial = CW_CCW_trial + 1;
    end
    if strcmp(data(i).stim1, 'CCW') &&  strcmp(data(i).stim2, 'CW')
        CCW_CW_spikes(CCW_CW_trial,:) = data(i).Ca1_spikes(neuronNum,:);
        CCW_CW_trial = CCW_CW_trial + 1;
    end
    if strcmp(data(i).stim1, 'CCW') &&  strcmp(data(i).stim2, 'CCW')
        CCW_CCW_spikes(CCW_CCW_trial,:) = data(i).Ca1_spikes(neuronNum,:);
        CCW_CCW_trial = CCW_CCW_trial + 1;
    end
end
subplot(2,2,1); title('CW CW'); sgtitle(['Cell number ', num2str(neuronNum), ' ; Session = ', session, '; Area = A0']); 
[xPoints, yPoints] = rasterplot(CW_CW_spikes); xline(stimtimes(1));xline(stimtimes(2));xline(stimtimes(3));xline(stimtimes(4));
subplot(2,2,2); title('CW CCW');
[xPoints, yPoints] = rasterplot(CW_CCW_spikes); xline(stimtimes(1));xline(stimtimes(2));xline(stimtimes(3));xline(stimtimes(4));
subplot(2,2,3); title('CCW CW');
[xPoints, yPoints] = rasterplot(CCW_CW_spikes); xline(stimtimes(1));xline(stimtimes(2));xline(stimtimes(3));xline(stimtimes(4));
subplot(2,2,4); title('CCW CCW');
[xPoints, yPoints] = rasterplot(CCW_CCW_spikes); xline(stimtimes(1));xline(stimtimes(2));xline(stimtimes(3));xline(stimtimes(4));

end