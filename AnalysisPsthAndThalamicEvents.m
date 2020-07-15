%% DATA ANALYSIS: PART 1
% Further analysis of data structure produced by RunFourLayNetwork.m
run globalVariables.m

% >>> output <<<
% structure with simulation settings and following results for every repeat:
    % peristimulus time histograms (PSTH) for every population
    % raster plot data for every population
    % raw spike times -> (copied from original struct)
    % mean firing rate per cell for every population -> (copied from original struct)
    % raw spike count per cell for every population -> (copied from original struct)
    % detected thalamic events

% >>> input <<<
binSize=2; % for PSTH calculation

% for thalamic event detection
thresh=9;       % spike number threshold for event detection (%% value is arbitrary)
maxEvents=5;    % set after inspecting figures
peakDist=50;    % peak distance in ms (also arbitrary)
eventDuration=70;   % expected duration of the event in ms


%% calculations and sorting
for pNum=1:numel(projections) %% loop: projections
      % make struct with data:
    sortedResults=[]; % clear for new projection
    sortedResults.projectionLabel=sprintf('%sProj%d',sStr,pNum);
    sortedResults.projectionType=ProjN(pNum);
      % store settings
    sortedResults.simulationSettings.synapticStrength=[string(sStr*100) "%"]; %percentage of the original strength
    sortedResults.simulationSettings.simulationTime=time;
    sortedResults.simulationSettings.discardedStartTime=cutStartTime;
    sortedResults.simulationSettings.timeVector=cutStartTime:0.01:time(2);
    sortedResults.simulationSettings.scalingFactors=scalingFactors;
    sortedResults.simulationSettings.totalRepeatsNumber=simulationNumbers;
            
    edgHist=(time(1)+cutStartTime):binSize:time(end); % define hist edges 
    edgRast=(time(1)+cutStartTime):1:time(end); % define raster edges (nbin=1)  
            
    for sfNum=1:length(scalingFactors) %% loop: scaling factors
        fName=ConstructName(pNum,sfNum);  % name constructed
        load(fName);
                
        for sim=1:numel(fields(simResults.repeats))    %% loop: number of repeats with same sfact
              % make names
            sf=sprintf('sFact%s',regexprep(num2str(sFact(sfNum)),'\.','_')); % replace dot with underscore
            rn=sprintf('simRepeat%d',sim);
                    
              % calculate means+/-stds (data path: resStruct.VarName(sim).SpAnalysis.FRpercell)
            FRsperRep(sim,:)=simResults.repeats.(sprintf('repeat%d',sim)).FRpercell;
            if sim==numel(fields(simResults.repeats))
               meanFRsperSf=mean(FRsperRep,1); % rows are repeats with same sFact, columns are pops
               stdsFRsperSf=std(FRsperRep,0,1); % rows are repeats with same sFact, columns are pops
                        
               sortedResults.scalingFactors.(sf).meanFRsForAllRepeats=meanFRsperSf; % mean FR from all repeats with the same sfact
               sortedResults.scalingFactors.(sf).stdsForAllRepeats=stdsFRsperSf; % respective stds
            end
                % store psth settings for every repeat individually
            sortedResults.scalingFactors.(sf).dataPerRepeat.(rn).PsthAndRaster.psthSettings.histBinSize=binSize;
            sortedResults.scalingFactors.(sf).dataPerRepeat.(rn).PsthAndRaster.psthSettings.histBinEdges=edgHist; % store edges
                    
                % define data with raw spike times per cell in a population
            PandRdata=simResults.repeats.(sprintf('repeat%d',sim)).rawspiketimes;
                    
                % psth matrices:
            for ax=1:length(PandRdata) % loop through pops in current repeat
                popName=simResults.repeats.(sprintf('repeat%d',sim)).Vtraces{ax,1};
                OnePop=PandRdata{1,ax};
                OnePopRast=[]; % empty for next
                OnePopBins=[]; % empty for next
                for bx=1:length(OnePop)
                     OnePopRast(bx,:)=histcounts(OnePop{1,bx},edgRast); % raster matrix
                     OnePopBins(bx,:)=histcounts(OnePop{1,bx},edgHist); % hist matrix
                end
                sortedResults.scalingFactors.(sf).dataPerRepeat.(rn).PsthAndRaster.histMatrices.(popName).rasterMatrix=OnePopRast;
                sortedResults.scalingFactors.(sf).dataPerRepeat.(rn).PsthAndRaster.histMatrices.(popName).rawHistMatrix=OnePopBins;
                sumMat=sum(OnePopBins);
                sortedResults.scalingFactors.(sf).dataPerRepeat.(rn).PsthAndRaster.histMatrices.(popName).summedHistMatrix=sumMat;
    
                   %%include raw data
                sortedResults.scalingFactors.(sf).dataPerRepeat.(rn).rawData.rawSpikeTimes.(popName)=OnePop;
                sortedResults.scalingFactors.(sf).dataPerRepeat.(rn).rawData.meanFRperPop.(popName)=simResults.repeats.(sprintf('repeat%d',sim)).FRpercell(1,ax);
                sortedResults.scalingFactors.(sf).dataPerRepeat.(rn).rawData.rawSpikeCountPerCellInPop.(popName)=simResults.repeats.(sprintf('repeat%d',sim)).rawspikecount(ax,:); % rows are pops, columns are individual cells
            end %current repeat
                    

  dataStruct=sortedResults.scalingFactors.(sf).dataPerRepeat.(rn).PsthAndRaster.histMatrices;
  % INFO: detectThEvent(histStruct,threshold,peakDistanceInMs,guessMax,binSize,eventDurInMs)
  events=detectThEvent(dataStruct,thresh,peakDist,maxEvents,binSize,eventDuration); % function for detecting thalamic events
  sortedResults.scalingFactors.(sf).dataPerRepeat.(rn).thalamicEvents=events;
        
        end %all repeats
   end %all sFacts
   
   save(sprintf('N4_ProjectionNo_%d_Analysed',pNum),'sortedResults','-v7.3') % save struct
   fprintf('Saved: Analysis of ProjojectionNo_%d \n',pNum)
end %all projections

    
%% function for constructing file name
function fName=ConstructName(ProjNum,sFact)
    fName=sprintf('N4_Results_ProjectionNo_%d_Sfact_%d',ProjNum,sFact);
end
%% load function
% function LoadedFile=LoadData(DataFile)
%     %addpath(genpath([PathToData '/results']));
%     LoadedFile=load(DataFile);
% end