% MAIN SCRIPT
% simulate four-layered thalamocortical network (L2,L3,L4,Thalamic layer)
% and explore its behaviour after scaling the connectiviy probability
% (pconn) or the synaptic strength (in the form of number of boutons, nb) 

run globalVariables.m
%% Set network params
% cortical params
Ecells= 85; Icells= 15; Thcells= 50; % set the cell numbers in the network

% thalamic params
CorrPoissR =    3;   % in Hz, firing rate of correlated poisson spike train
CorrPoissIn =   0.3; % input probability to thalamic cells
UncorrPoissR =  9;  % in Hz, firing rate of uncorrelated poisson spike train
UncorrPoissIn = 0.7; % input probability to thalamic cells
gSyn= 0.5; % synaptic conductance for the input

% group thalamic variables
thparams=[CorrPoissR,CorrPoissIn,UncorrPoissR,UncorrPoissIn,gSyn];
           
%% grouping variables in struct          
settings.E_cell_number = Ecells;
settings.I_cell_number = Icells;
settings.Th_cell_number = Thcells;
settings.thalamic_spiking.correlatedPoissonRate = CorrPoissR;
settings.thalamic_spiking.correlatedPoissonInputProbability = CorrPoissIn;
settings.thalamic_spiking.uncorrelatedPoissonRate = UncorrPoissR;
settings.thalamic_spiking.uncorrelatedPoissonInputProbability = UncorrPoissIn;
settings.thalamic_spiking.synapticConductance = gSyn;
settings.synapticStrength = [string(sStr*100) "%"];
settings.simulationTime = time;
settings.discardedStartTime = cutStartTime;
settings.timeVector = cutStartTime:0.01:time(2);
settings.scalingFactors = scalingFactors;
settings.totalRepeatsNumber = simulationNumber;
if strcmp(vary,'probs')==1; settings.synapseAspectVaried = "connectionProbability"; end
if strcmp(vary,'bouts')==1; settings.synapseAspectVaried = "numberOfBoutons"; end

%% Run simulations
for act=1:size(projections,2) % which synapse is active/changing
    for sfnum=1:length(scalingFactors)
        sf=scalingFactors(sfnum); % define a scaling factor
        synparams=struct('act',act,'sf',sf,'vary',vary); % group parameters for synaptic modification
        
        % define empty stuctures to store data
        GroupSimulations=struct('Simulation',cell(1,simulations)); % simulated data for every network
        GroupResults=struct('SpAnalysis',cell(1,simulations)); % analysis results
        
        GroupResults.settings=settings;
        GroupResults.settings.currentScalingFactor=regexprep(string(sf),'\.','_');
        GroupResults.settings.currentVariedProjection=projections(act);
        
        fprintf('Simulating combination %d for sfact =%6.3f \n',act,sf) % combination = which synapses are active
        for sm=1:simulationNumber %repeat simulations 
            fprintf('Simulation repeat: %d \r',sm)
            % simulate network
            SpikingNetwork=FourLayNetworkSkelet(Ecells,Icells,Thcells,time,synparams,thparams);
            % store simulation results before analysis
            GroupSimulations(sm).Simulation=SpikingNetwork; % comment this if you have memory issues
            % analyse network spiking
            SpikeAnalysis=NetAnalysis(SpikingNetwork,time,Ecells,Icells,Thcells,cutStartTime);
            % store results
            GroupResults.(sprintf('repeat%d',sm))=SpikeAnalysis;
        end
        
        % saving intermediate results
        fprintf('Saving all results from simulations (ActSyn:%d), sfact =%6.3f \n',act,sf)
        
        save(sprintf('N4_Results_ProjectionNo_%d_Sfact_%d',act,sfnum),GroupResults,'-v7.3') % saves this struct before another loop starts
        % use custom ParallelSave.m function if you run this in parfor loop
    end
end

disp('all done')



