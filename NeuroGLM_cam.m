%function wts = NeuroGLM_BEST(data, binSize, neuronNum)
neuronNum = 8;
nTrials = length(data);
expParam = 'CRACK';
trial_duration = length(data(1).Ca1_spikes)*binSize;

expt = buildGLM.initExperiment('s', binSize, [], expParam);

expt = buildGLM.registerTiming(expt, 'stim1_CW', 'Stimulus 1 = CW onset'); 

expt = buildGLM.registerTiming(expt, 'stim1_CCW', 'Stimulus 1 = CCW onset');

expt = buildGLM.registerTiming(expt, 'CW_CW', 'match trial (CW CW)');
expt = buildGLM.registerTiming(expt, 'CW_CCW', 'nonmatch trial (CW CCW)');
expt = buildGLM.registerTiming(expt, 'CCW_CW', 'nonmatch trial (CCW CW)');
expt = buildGLM.registerTiming(expt, 'CCW_CCW', 'match trial (CCW CCW)');

expt = buildGLM.registerSpikeTrain(expt, 'licks', 'Licks');
expt = buildGLM.registerSpikeTrain(expt, 'sptrain', 'Our Neuron'); % Spike train!!!
%expt = buildGLM.registerValue(expt, 'response', 'Animals Choice');


for trialNum = 1:nTrials
    time_steps = length(data(trialNum).CW);
    trial = buildGLM.newTrial(expt, trial_duration);
    trial.licks = [];
    trial.sptrain = [];
    trial.stim1_CW = [];
    trial.stim1_CCW = [];
    trial.CW_CW = [];
    trial.CW_CCW = [];
    trial.CCW_CW = [];
    trial.CCW_CCW = [];

    a = find(diff([data(trialNum).CW(1:time_steps/2),zeros(1,(time_steps/2))]));
        if not(isempty(a))
            trial.stim1_CW = a(1)*binSize;

        end
    b = find(diff([data(trialNum).CCW(1:time_steps/2),zeros(1,(time_steps/2))]));
        if not(isempty(b))
            trial.stim1_CCW = b(1)*binSize;

        end
    e = find(diff(data(trialNum).match));
        if not(isempty(e)) && not(isempty(a))
            trial.CW_CW = e(1)*binSize;
        elseif not(isempty(e)) && not(isempty(b))
            trial.CCW_CCW = e(1)*binSize;
        end
    f = find(diff(data(trialNum).nonmatch));
        if not(isempty(f)) && not(isempty(a))
            trial.CW_CCW = f(1)*binSize;
        elseif not(isempty(f)) && not(isempty(b))
            trial.CCW_CW = f(1)*binSize;
        end
        
    lick_indices = data(trialNum).licks;
    if not(isempty(lick_indices))
        trial.licks = lick_indices*binSize;
    end
    sp_indices = find(data(trialNum).Ca1_spikes(neuronNum,:));
    if not(isempty(sp_indices))
        trial.sptrain = sp_indices*binSize;
    end
    
    expt = buildGLM.addTrial(expt, trial, trialNum);
    
end
dspec = buildGLM.initDesignSpec(expt);
numbasis_stims = 20;
numbasis_licks = 5;
bs_stim1 = basisFactory.makeSmoothTemporalBasis('boxcar', 4, numbasis_stims, expt.binfun);
bs_match = basisFactory.makeSmoothTemporalBasis('boxcar', 4, numbasis_stims, expt.binfun);
bs_licks = basisFactory.makeSmoothTemporalBasis('boxcar', 0.5, numbasis_licks, expt.binfun);

dspec = buildGLM.addCovariateSpiketrain(dspec, 'licks', 'licks','licks', bs_licks);
dspec = buildGLM.addCovariateTiming(dspec, 'stim1_CW', 'stim1_CW', 'Stim1 = CW', bs_stim1);
dspec = buildGLM.addCovariateTiming(dspec, 'stim1_CCW', 'stim1_CCW', 'Stim1 = CCW', bs_stim1);
dspec = buildGLM.addCovariateTiming(dspec, 'CW_CW', 'CW_CW', 'Match', bs_match);
dspec = buildGLM.addCovariateTiming(dspec, 'CCW_CCW', 'CCW_CCW', 'Match', bs_match);
dspec = buildGLM.addCovariateTiming(dspec, 'CW_CCW', 'CW_CCW', 'nonMatch', bs_match);
dspec = buildGLM.addCovariateTiming(dspec, 'CCW_CW', 'CCW_CW', 'nonMatch', bs_match);

trialIndices = 1:nTrials;
dm = buildGLM.compileSparseDesignMatrix(dspec, trialIndices);
dm = buildGLM.addBiasColumn(dm);

y = buildGLM.getBinnedSpikeTrain(expt, 'sptrain', dm.trialIndices);


prspec = gpriors.getPriorStruct({'smooth'});
Cinv_licks = glms.buildPriorCovariance(prspec, {1:numbasis_licks}, {'smooth'});
Cinv = glms.buildPriorCovariance(prspec, {1:numbasis_stims}, {'smooth'});
Cinv_all = blkdiag(Cinv_licks, Cinv, Cinv, Cinv, Cinv, Cinv, Cinv);
C_total = zeros(size(Cinv_all)+1);
C_total(2:end, 2:end) = Cinv_all;
C_total(1,1) = 1;


[wts, SDebars, S, funval, H] = glms.getPosteriorWeights(dm.X,y,C_total);
figure; plot(wts, '.'); title('licks, stim1 = CW; stim1 = CCW; CW CW; CCW CCW; CW CCW; CCW CW;');
xline(2);xline(2+numbasis_licks); xline(2+numbasis_licks+numbasis); xline(2+numbasis_licks+numbasis*2); xline(2+numbasis_licks+numbasis*3);xline(2+numbasis_licks+numbasis*4);xline(2+numbasis_licks+numbasis*5);
figure;
make_raster(neuronNum,data, session);
%end


%  w = glmfit(dm.X, y, 'poisson', 'link', 'log', 'constant', 'off');
% 
% ws = buildGLM.combineWeights(dm, w);







