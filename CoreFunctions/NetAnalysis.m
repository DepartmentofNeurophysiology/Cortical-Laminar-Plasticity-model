function AnalysisResults=NetAnalysis(network,time,Ne,Ni,Nt,discardTime)
% Function provides basic analysis of simulated network activity.
% >>> inputs: <<<
    % network - complete dynasim data structure
    % time - time [start stop] in ms
    % Ne, Ni, Nt - number of cortical excitatory, cortical inhibitory and
    %              thalamic cells, respectively
    % discardTime - portion of start time to discard, usually first 10% 

% >>> output: <<<
    % struct with fields:
        % Vtraces - raw voltage traces for every cell
        % rawspiketimes - raw spike times for every cell
        % sumofspikes - sum of spikes for every cell
        % FRpercell - mean firing rate per cell in a population

%% store raw voltage traces (because I can not store the whole network due
% to memory restraints, so at least Vtraces)
rw=1;
for k=1:length(network.labels)
    Vnamecheck=contains(network.labels(k),'_V');
    if Vnamecheck==1
        Vcellname=string(network.labels(k)); 
        Vtraces{rw,2}=getfield(network,Vcellname); % raw membrane potentials of cells in every pop
        Vtraces{rw,1}=Vcellname;
        rw=rw+1;
    end
end
%clear rw
%% preprocess (discard first 50sec)
% discardTime=50;
% 
for ii=1:length(network.labels) % this loop will discart the first 50sec of data in every variable in each network
    names=string(network.labels);
    network.(sprintf('%s',names(ii)))=network.(sprintf('%s',names(ii)))(find(network.time==discardTime):end,:); 
end % end of preprocessing (now there is only data from 50sec to end-sec)

%% detect spikes
spikes=dsCalcFR(network,'variable','*_V','threshold',-18); % this is the whole dsSimulate structure
for m=1:length(spikes.results) % array of all variable names calculated by dsCalcFR
    namecheck=contains(spikes.results(m),'spike_times'); % check if cells that contain "spike_times"
    if namecheck==1 % if cell contains "spike_times" in its name it is stored in "spiketimescells"
        cellname=string(spikes.results(m)); 
        pops(m)=cellname; % contains all variable names that have "spike_times" in their name
        pops=rmmissing(pops); % rmmissing removes empty cells from array
    end
 end % loop for collecting variable names ends
for p=1:length(pops) % p = number of populations in a 4-layered network
    spiketimes{p}=getfield(spikes,pops(p)); % spike times from each pop in a layer extracted from "spikes" structure
    for r=1:length(spiketimes{1,p}) % r = number of cells in each layer
         numspike=numel(spiketimes{1,p}{1,r}); % counts how many spike times, i.e. spikes, are there from each neuron in each layer population 
         numspikes(p,r)=numspike; % collects number of spikes per cell per layer (each row is one layer and each column is one cell)
         spikessummed(p)=sum(numspikes(p,:)); % sum of all spikes in a layer (each column is one layer)
    end
end % loop for summing spikes ends

% SECTION OUTPUT:
% spiketimes=contains spike times for every cell in each population
% numspikes=converts spike times into spike number per cell in every population (rows are populations, columns are individual cells)
% spikessummed=an array of all spikes per population (columns are populations)
        
%% calculate mean+-std FR per pop, mean+-FR per cell
% FR per cell per pop
tdur=time(end)-(time(1)+discardTime); tdur=tdur/1000; % convert into seconds
spikessummedFR=spikessummed./tdur; % divide with time duration
spikessummedFR(:,[1 3 5])=spikessummedFR(:,[1 3 5])./Ne; % number of E cells
spikessummedFR(:,[2 4 6])=spikessummedFR(:,[2 4 6])./Ni; % number of I cells
spikessummedFR(:,7)=spikessummedFR(:,7)./Nt; % number of Th cells

% SECTION OUTPUT:
% spikessummedFR=average firing rate per cell in pop

%% group relevant section outputs and store them

results.Vtraces=Vtraces;
results.rawspiketimes=spiketimes;
results.rawspikecount=numspikes;
results.sumofspikes=spikessummed;
results.FRpercell=spikessummedFR;


AnalysisResults=results;
end


