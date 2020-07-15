function events=detectThEvent(histStruct,threshold,peakDistanceInMs,guessMax,binSize,eventDurInMs)
% function will detect events in an array of binned spike numbers (i.e.
% psth array):
    % user has to provide threshold -> minimal number of spikes in a histogram 
    % bin (i.e. at one time instance) which qualify as an event
    
    % user has to provide a guess of maximum event number
 if isempty(guessMax)==1; guessMax=1; end  

%% detect and sort
 histThArray=getfield(histStruct,'ThE_V','summedHistMatrix');
 arrSorted=sort(histThArray,'descend');
 popName=["l2E_V","l2I_V","l3E_V","l3I_V","l4E_V","l4I_V","ThE_V"];
 
 if arrSorted(1)>threshold % check if there are any events at all
     [peakVals,peakIndx,peakWidt,peakProm]=findpeaks(histThArray,...
         'NPeaks',guessMax,...          % expected max number of events
         'SortStr','descend',...        % find peaks from from the largest to the smallest value
         'MinPeakHeight',threshold,...  % min number of spikes to form an event
         'MinPeakDistance',round(peakDistanceInMs/binSize)); % peaks have to be at least peakDistance ms apart
     events.detectionSettings.minPeakHeight=[string(threshold) 'spikes'];
     events.detectionSettings.minPeakDistance=[string(peakDistanceInMs) 'ms'];   
     events.detectionSettings.binSize=[string(binSize) 'ms'];
     events.detectionSettings.allPeaksSpikeNum=peakVals;
     events.detectionSettings.allPeaksWidth=peakWidt;
     events.detectionSettings.allPeaksProminance=peakProm;
     events.detectionSettings.allPeaksIndices=peakIndx;
     
     eventDuration=round(eventDurInMs/binSize); % portion of time to extract
     durEdge=(round(eventDuration/2))-1;
     for peaks=1:length(peakIndx)
         evName=sprintf('event%d',peaks);
         % make sure events detected on the edges do not evoke error
         if peakIndx(peaks)<=durEdge % event detected on the left margin
             timeBins=1:eventDuration;
         elseif peakIndx(peaks)>=length(histThArray)-durEdge % event detected on the right margin
             timeBins=length(histThArray)-eventDuration+1:length(histThArray);
         else
             timeBins=peakIndx(peaks)-durEdge:peakIndx(peaks)+durEdge;
         end
            timeInMs=timeBins*binSize;
            events.(evName).eventTimeFrameInMs=timeInMs(1):0.01:timeInMs(end);
            events.(evName).eventTimeInBins=timeBins;
            
         for pop=1:length(popName) % find event activity in other pops
             popArray=getfield(histStruct,char(popName(pop)),'summedHistMatrix'); % define psth array
             popEvent=popArray(timeBins);
         % sort
         events.(evName).spikeArray(pop).population=(popName(pop));
         events.(evName).spikeArray(pop).eventHist=popEvent;
         end
     end

 else % no events
     events=[]; 
 end
   
end