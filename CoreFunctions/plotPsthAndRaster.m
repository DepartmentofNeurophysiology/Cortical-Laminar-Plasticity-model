function plotPsthAndRaster(WhichPlot, VarNameRawSpikeTimes, BinSize, Time, DiscardStartTime, FigName, Visibility, SaveFig)
%% This function plots psth and/or rasterplots with input arguments:
    % WhichPlot: 'psth', 'raster', 'both-joint', 'both-separate'
    % VarNameRawSpikeTimes=raw spike times per cell/trial
    % BinSize for psth
    % Time [start end]
    % DiscardStartTime (e.g. first 50ms)
    % FigName is the title of the fig
    % Visibility of the figure: 'on'/'off'
    % SaveFig: 1=save / 0=dont save
%% colors
 % RGB palette:
 LineCol=[0.0000 0.4470 0.7410;... % blue,      l2E
          0.8500 0.3250 0.0980;... % orange,    l2I
          0.9290 0.6940 0.1250;... % yellow,    l3E
          0.4940 0.1840 0.5560;... % purple,    l3I
          0.4660 0.6740 0.1880;... % green,     l4E
          0.3010 0.7450 0.9330;... % light blue,l4I
          0.6350 0.0780 0.1840;... % bordeaux,  Th
               ];
 PopName=["l2E","l2I","l3E","l3I","l4E","l4I","ThE"];
%% params   
    rst=VarNameRawSpikeTimes;
    pops=length(rst);
    %fprintf('Detected number of populations: %d \n',pops)
 
    edgHist=(Time(1)+DiscardStartTime):BinSize:Time(end); % define hist edges 
    edgRast=(Time(1)+DiscardStartTime):1:Time(end); % define raster edges (nbin=1)
    f=figure('Name',FigName,'Visible',Visibility);
    
  switch WhichPlot
%% psth
      case 'psth'
          for ax=1:pops
              OnePop=rst{1,ax};
              OnePopBins=[];
              for bx=1:length(OnePop)
                  OnePopBins(bx,:)=histcounts(OnePop{1,bx},edgHist); % hist matrix
              end
              if ax==7
              subplot(round(pops./2),2,ax+0.5)
                SumOPB=sum(OnePopBins);
                stairs(SumOPB,'Color',LineCol(ax,:),'LineWidth',1.8); 
                % or use: bar(SumOPB,'FaceColor',LineCol(ax,:));
                xlabel('Number of bins');
                ylabel(sprintf('%s',PopName(ax)));
              else
              subplot(round(pops./2),2,ax)
                SumOPB=sum(OnePopBins);
                stairs(SumOPB,'Color',LineCol(ax,:),'LineWidth',1.8); 
                % or use: bar(SumOPB,'FaceColor',LineCol(ax,:));
                xlabel('Number of bins');
                ylabel(sprintf('%s: spike count',PopName(ax)));
              end
          end % end psth
%% raster 
      case 'raster'
          for ax=1:pops
              OnePop=rst{1,ax};
              OnePopRast=[];
              for bx=1:length(OnePop)
                  OnePopRast(bx,:)=histcounts(OnePop{1,bx},edgRast); % raster matrix
              end
              if ax==7
              subplot(round(pops./2),2,ax+0.5)
                imagesc(OnePopRast);
                colormap(flipud(colormap('Gray')));
                set(gca,'YDir','normal')
                xlabel('time (ms)')
                ylabel(sprintf('%s neurons',PopName(ax)));
              else
              subplot(round(pops./2),2,ax)
                imagesc(OnePopRast);
                colormap(flipud(colormap('Gray')));
                set(gca,'YDir','normal')
                xlabel('time (ms)')
                ylabel(sprintf('%s neurons',PopName(ax)));
              end
          end % end raster

%% both-separate
      case 'both-separate'
          for ax=1:pops
              OnePop=rst{1,ax};
              OnePopBins=[];
              OnePopRast=[];
              for bx=1:length(OnePop)
                  OnePopBins(bx,:)=histcounts(OnePop{1,bx},edgHist); % hist matrix
                  OnePopRast(bx,:)=histcounts(OnePop{1,bx},edgRast); % raster matrix
              end
              SumOPB=sum(OnePopBins);
              %disp('Plotting PSTH... and rasters')
              subOrder=[1:2:14]; % placement of rasters
              subplot(pops,2,subOrder(ax))
                stairs(SumOPB,'Color',LineCol(ax,:),'LineWidth',1.8);
                xlabel('Number of bins');
                ylabel(sprintf('%s: spike count',PopName(ax)));
                %ylim([0 120])
                
              subplot(pops,2,subOrder(ax)+1)
                imagesc(OnePopRast);
                colormap(flipud(colormap('Gray')));
                set(gca,'YDir','normal');
                xlabel('time (ms)')
                ylabel(sprintf('%s neurons',PopName(ax)));
          end % end both-separate
 
 %% both-joint (overlapping)
      case 'both-joint'
          for ax=1:pops
              OnePop=rst{1,ax};
              OnePopBins=[];
              OnePopRast=[];
              for bx=1:length(OnePop)
                  OnePopBins(bx,:)=histcounts(OnePop{1,bx},edgHist); % hist matrix
                  OnePopRast(bx,:)=histcounts(OnePop{1,bx},edgRast); % raster matrix
              end
              SumOPB=sum(OnePopBins);
              %disp('Plotting PSTH... and rasters')
              if ax==7
              subplot(round(pops./2),2,ax+0.5)
              imagesc(OnePopRast);
                colormap(flipud(colormap('Gray')));
                set(gca,'YDir','normal');
                oldXlab=xlabel('time (ms)'); % label for xaxis
                %oldXlab.Position=oldXlab.Position+0.3; % move old xaxis; %Position(1) is left/right, Position(2) is up/down
                ylabel(sprintf('%s neurons',PopName(ax)));
                getAxes=gca; axLocation=getAxes.Position; % get location of axes for every subplot
                newAxs=axes('NextPlot','add','Visible','on',...
                    'Position',axLocation,'XAxisLocation','top','YAxisLocation','right',...
                    'Color','none','XColor','b','YColor','b'); % turn off the background of the next plot
              stairs(SumOPB,'Parent',newAxs,'Color',LineCol(ax,:),'LineWidth',1.8); % plot psth on top of rasters
                xlabel('Number of bins');
                ylabel(sprintf('%s: spike count',PopName(ax)));
              else
              subplot(round(pops./2),2,ax)
              imagesc(OnePopRast);
                colormap(flipud(colormap('Gray')));
                set(gca,'YDir','normal');
                if ismember(ax,[1 2 3 4]) % middle subplots do not need xlabel
                else; xlabel('time (ms)')
                end
                ylabel(sprintf('%s neurons',PopName(ax)));
              getAxes=gca; axLocation=getAxes.Position; % get location of axes for every subplot
              newAxs=axes('NextPlot','add','Visible','on',...
                    'Position',axLocation,'XAxisLocation','top','YAxisLocation','right',...
                    'Color','none','XColor','b','YColor','b'); % turn off the background of the next plot
              stairs(SumOPB,'Parent',newAxs,'Color',LineCol(ax,:),'LineWidth',1.8); % plot psth on top of rasters
                if ismember(ax,[3 4 5 6]) % middle subplots do not need xlabel
                    %no xlabel
                else; xlabel('Number of bins'); 
                end
                ylabel(sprintf('%s: spike count',PopName(ax)));
                    %title('Rasterplot superposed with PSTH')
              end
          end % end both-joint
  end % switch
  
%% save figure
    if SaveFig==1 
       savefig(f,FigName)
    end
end