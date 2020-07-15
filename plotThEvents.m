%% PLOT THALAMIC EVENTS SORTED IN sortThEvents.m
% Use this protocol to plot event-triggered average (ETA) plots in two ways:
    % std shown as shaded area
    % std shown using bars
    
% this protocol also extracts peaks from ETA plots and displays them as
% separate plots

%% settings for plots
saveFig=0;                  % save figure (1 or 0)
figVisibility='on';         % figure visibility
plotType='shades';          % STD shown as: 'bars' or 'shades'

fpeaks1=figure('Name','Statistical analysis of change in: Peak height and timing PART 1');
fpeaks2=figure('Name','Statistical analysis of change in: Peak height and timing PART 2');
fpeaks3=figure('Name','Statistical analysis of change in: Peak height and timing PART 3');
%% load and plot
% load data

for pNum=1:numel(projections) %% loop: projections
    dataname = sprintf('N4_ProjectionNo_%d_sortedThEvents',pNum);
    load(dataname) % variable name: allEventSpikesSorted
    
    % plot Event Triggered Averages (ETAs)
    figName = sprintf('Fig%d (change in %s)',pNum, ProjN(pNum));
    plotETAs(allEventSpikesSorted, saveFig, figName, ProjN(pNum), plotType, sFact, figVisibility, pNum);
    
    % find just peaks in ETA plots and plot that
    plotETApeaks(allEventSpikesSorted,[fpeaks1, fpeaks2, fpeaks3],pNum,ProjN(pNum));
    %return
end


%% plot ETAs function
function plotETAs(datastruct, saveFig, figName, variedProj, plotType, sFactVector, visibility, figurine)
%population labels:
 % RGB palette:
 lineCol=[0.0000 0.4470 0.7410;... % blue,      l2E
          0.8500 0.3250 0.0980;... % orange,    l2I
          0.9290 0.6940 0.1250;... % yellow,    l3E
          0.4940 0.1840 0.5560;... % purple,    l3I
          0.4660 0.6740 0.1880;... % green,     l4E
          0.3010 0.7450 0.9330;... % light blue,l4I
          0.6350 0.0780 0.1840;... % bordeaux,  Th
               ];
    figure('Name',sprintf('Projection varied: %s',variedProj),'visible',visibility);
    positions=[1.2, 3, 4, 5, 6];
    for sfactCount=1:numel(fields(datastruct)) % how many scaling factors
        sfactNames=fieldnames(datastruct);
        fieldCount=fieldnames(datastruct.(sfactNames{sfactCount})); % how many populations
        for fldC=1:length(fieldCount) % population
            rws=round(numel(fields(datastruct))/2); % rows in the subplot
         subplot(rws,2,positions(sfactCount)) % position
            means=datastruct.(sfactNames{sfactCount})(2).(fieldCount{fldC}).means;
            stds=datastruct.(sfactNames{sfactCount})(2).(fieldCount{fldC}).STDs;
            datastruct.(sfactNames{sfactCount})(2).(fieldCount{fldC}).powerSpectrum=[]; % this field should be deleted 
            switch plotType
                case 'bars'
                    figNameadd='_barplots';
                    errorbar(means,stds,'linewidth',1.4,'Color',lineCol(fldC,:))
                case 'shades'
                    figNameadd='_shades';
                    alpha=0.14;
                    stdShade(datastruct.(sfactNames{sfactCount})(1).(fieldCount{fldC}),alpha,lineCol(fldC,:));
                    xlim([1 length(datastruct.(sfactNames{sfactCount})(1).allThE_V)]);
            end
            hold on; grid on
            %xSpan=[round(-length(means)/2):1:round(length(means)/2)];
        end
            if sfactCount==1
                title('Network activity with original connectivity probabilities','Interpreter','none', 'fontsize', 21);
            else
                perc=round(sFactVector(sfactCount)*100);
                title(sprintf('Probabilities of %s connection downscaled to %d%%',variedProj,perc),'Interpreter','none', 'fontsize', 18);
            end
            
     if strcmp(plotType,'bars')==1 || strcmp(plotType,'shades')==1
        ylabel({'Event-triggered average';'spike # per population'}, 'fontsize', 15)
        xlabel('Event-time window', 'fontsize', 16)
        yl=ylim;
        ylim([yl(1) yl(2)]);
        %pk=findpeaks(sortedThStruct.(sfactNames{sfactCount})(2).all_ThE_V.means,'SortStr','descend','NPeak',1);
        border=find(datastruct.(sfactNames{sfactCount})(2).all_ThE_V.means >7); % when thalamic spiking exceeds 7 spikes
        bdr=border(1);
        line([bdr bdr], [yl(1) yl(2)],'Color','black','LineWidth',3);
        text(bdr, yl(2)*0.9,'\fontsize{14} \bf Event onset \rightarrow','Interpreter','tex','HorizontalAlignment','right')
        xtickArray=[bdr-10, bdr-5, bdr-2.5, bdr, bdr+2.5, bdr+5, bdr+10];
        xtickLabels=["-20 ms","-10 ms","-5 ms",0,"+5 ms","+10 ms","+20 ms"];
        set(gca,'XTick',xtickArray,'XTickLabels',xtickLabels,'FontSize',14);
        xtickangle(45);
     end

    end % sfact
    splt = subplot(rws,2,2);
    legd=imread([num2str(figurine) '.png']);
    imagesc(legd);
    set(gca,'xtick',[],'xticklabel',[],'ytick',[],'yticklabel',[]);
    title('Population color codes and varied projection (red)','FontSize',16);
    pos1 = get(splt, 'Position'); % gives the position of current sub-plot
    new_pos1 = pos1 + [0.07 -0.03 -0.15 0.07]; % [x1 y1 x2 y2]
    set(splt, 'Position', new_pos1) % set new position of current sub - plot
    
    if saveFig==1
        figName=[figName figNameadd];
        %savefig(figName);
        set(gcf, 'Position', get(0, 'Screensize'));
        saveas(gcf, [figName '.png']);
    end
end

%% plot ETA peaks
function plotETApeaks(datastruct,figs,pnum,projection)
 % RGB palette:
 lineCol=[0.0000 0.4470 0.7410;... % blue,      l2E
          0.8500 0.3250 0.0980;... % orange,    l2I
          0.9290 0.6940 0.1250;... % yellow,    l3E
          0.4940 0.1840 0.5560;... % purple,    l3I
          0.4660 0.6740 0.1880;... % green,     l4E
          0.3010 0.7450 0.9330;... % light blue,l4I
          0.6350 0.0780 0.1840;... % bordeaux,  Th
               ];
   if pnum<=12;set(0,'CurrentFigure',figs(1)); subplot(4,3,pnum); hold on; grid on; end
   if (12<pnum)&&(pnum<=24); set(0,'CurrentFigure',figs(2)); sub=pnum-12; subplot(4,3,sub); hold on; grid on; end
   if pnum>24; set(0,'CurrentFigure',figs(3)); sub=pnum-24; subplot(2,3,sub); hold on; grid on; end
   
   for sfactCount=1:numel(fields(datastruct)) % how many scaling factors
       sfactNames=fieldnames(datastruct);
       fieldCount=fieldnames(datastruct.(sfactNames{sfactCount})); % how many populations
       for fldC=1:length(fieldCount) % population
           eta=datastruct.(sfactNames{sfactCount})(2).(fieldCount{fldC}).means;
           minPeakHeight=mean(eta)*2.8;
           maxPeaks=1;
           [pvalue,ptime]=findpeaks(eta,'minpeakheight',minPeakHeight,'NPeak',maxPeaks);
           if isempty(pvalue); pvalue=NaN; ptime=NaN; end % introduce NaNs if there are no peaks found
           peakValues(sfactCount,fldC)=pvalue;
           peakTimings(sfactCount,fldC)=ptime;
       end
   end
   k=[1:3:numel(fields(datastruct))*3]; % shades of grey
   for pops=1:size(peakValues,2)
       for sfs=1:size(peakValues,1)
        plot(peakTimings(sfs,pops),peakValues(sfs,pops),'o','MarkerSize',14,'MarkerEdgeColor',lineCol(pops,:),'MarkerFaceColor',[0 0 0]+0.05*k(sfs));
       end
   end
   title(sprintf('C%d: %s',pnum,projection));
   xlim([1 length(eta)])
   ylabel('Number of spikes', 'fontsize', 16)
   xlabel('Peak timing (ms)', 'fontsize', 16)
   yl=ylim;
   ylim([yl(1) yl(2)]);
   border=find(datastruct.(sfactNames{sfactCount})(2).all_ThE_V.means >5); % when thalamic spiking exceeds 7 spikes
   bdr=border(1);
   line([bdr bdr], [yl(1) yl(2)],'Color','black','LineWidth',3);
   text(bdr, yl(2)*0.9,'\fontsize{14} \bf Event onset \rightarrow','Interpreter','tex','HorizontalAlignment','right')
   xtickArray=[bdr-10, bdr-5, bdr-2.5, bdr, bdr+2.5, bdr+5, bdr+10];
   xtickLabels=["-20","-10","-5",0,"+5","+10","+20"];
   set(gca,'XTick',xtickArray,'XTickLabels',xtickLabels,'FontSize',18);
   xtickangle(45);
end
