%% Global parameters used for modelling and data analysis:
global projections time cutStartTime simulationNumber vary scalingFactors sStr

% Type of synaptic projections to be varied with scaling factors:
projections = [ "all Th to L4","all L4 to L3","all L3 to L2"... % translaminar global
              "ThE to l4E","ThE to l4I","l4E to l3E","l4E to l3I","l4I to l3E","l3E to l2E","l3E to l2I","l3I to l2E","l3I to l2I"... % translaminar local
              "all (intra)layers E to E","all (intra)layers E to I","all (intra)layers I to E","all (intra)layers I to I"... % intralaminar global
              "l4E intralayer", "l4E to l4I", "l4I to l4E", "l4I intralayer", "l3E intralayer", "l3E to l3I", "l3I to l3E", "l3I intralayer", "l2E intralayer", "l2E to l2I", "l2I to l2E", "l2I intralayer"... % intralaminar local
               ];

time = [0 1100];        % time in ms in format [start stop]
cutStartTime = 100;     % cut first 100ms from analysis
simulationNumber = 10;  % number of times to repeat same simulation condition
vary = 'probs';         % aspect of projection to vary (probability='probs' or bouton number ='bouts') 
scalingFactors = [1, 0.75, 0.5, 0.25, 0.1]; % scaling factors

sStr = 0.10; % after model evaluation, we have seen that PSPs are too strong with original
             % synaptic strengths, so here we use only 10% of the original
             % values