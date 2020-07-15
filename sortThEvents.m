%% SORTING THALAMIC EVENTS DETECTED IN AnalysisPsthAndThalamicEvents.m
% Use this protocol to extract data about thalamic events from structure
% resulting from AnalysisPsthAndThalamicEvents.m


for pNum=1:numel(projections) %% loop: projections
    fName=sprintf('N4_ProjectionNo_%d_Analysed',pNum); 
    load(fName); 
    allEventSpikesSorted=[]; %clear for new
           
    for sfNum=1:length(scalingFactors) %% loop: scaling factors
        newRow=1;
        sf=sprintf('sFact%s',regexprep(num2str(scalingFactors(sfNum)),'\.','_')); % replace dot with underscore
         reps=numel(fields(sortedResults.scalingFactors.(sf).dataPerRepeat)); 
         for repNum=1:simulationNumber % number of repeats in simulation batch
             rn=sprintf('simRepeat%d',repNum);
             thPath=sortedResults.scalingFactors.(sf).dataPerRepeat;
             if ~isempty(thPath.(rn).thalamicEvents)==1 % check if there is any event at all
                 fieldArr=fieldnames(thPath.(rn).thalamicEvents);
                  for evs=1:length(nonzeros(contains(fieldArr,'event')')) % actual number of events
                      evName=sprintf('event%d',evs);
                      thEvent=thPath.(rn).thalamicEvents.(evName).spikeArray;
                      for pop=1:size(thEvent,2) % populations in event
                          newName=join(['all_' thEvent(pop).population],''); % new name for field
                          allEventSpikesSorted.(sf)(1).(newName)(newRow,:)=thEvent(pop).eventHist(:,1:35); 
                      end%pop
                      newRow=1+newRow;
                   end%evs
              end%check for events
        end%repeats
           
 % prep for plots
    for pps=1:numel(fieldnames(allEventSpikesSorted.(sf)))
         allPps=fieldnames(allEventSpikesSorted.(sf));
         ppName=allPps{pps};
         allEventSpikesSorted.(sf)(2).(ppName)(1,:).means=mean(allEventSpikesSorted.(sf)(1).(ppName),1); %means after all events are sorted
         allEventSpikesSorted.(sf)(2).(ppName)(1,:).STDs=std(allEventSpikesSorted.(sf)(1).(ppName),1); %stds after all events are sorted
    end
    end%sfact
    save(sprintf('N4_ProjectionNo_%d_sortedThEvents',pNum),'allEventSpikesSorted','-v7.3'); % save struct

end%projection
