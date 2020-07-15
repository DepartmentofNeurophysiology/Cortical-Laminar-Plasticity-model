function MultiplePlotsOverview(sFact,MeansMatrix,StdsMatrix,RawForShade,ProjNum,ProjName,FigName,Visibility,SaveFig)
% This function plots extensive overview consisting multiple plot-types to
% inspect changes to the simulated network.
    % MeansMatrix: rows are mean FR per sFact; columns are PopName
    % StdsMatrix: rows are stds per sFact; columns are PopName
%% population labels:
 % RGB palette:
 LineCol=[0.0000 0.4470 0.7410;... % blue,      l2E
          0.8500 0.3250 0.0980;... % orange,    l2I
          0.9290 0.6940 0.1250;... % yellow,    l3E
          0.4940 0.1840 0.5560;... % purple,    l3I
          0.4660 0.6740 0.1880;... % green,     l4E
          0.3010 0.7450 0.9330;... % light blue,l4I
          0.6350 0.0780 0.1840;... % bordeaux,  Th
               ];
 PopName=["l2E","l2I","l3E","l3I","l4E","l4I"]; % no "ThE"
%% process input arguments
meanFRs=MeansMatrix(:,1:end-1); % exclude last column (where ThE data is)
stdsFRs=StdsMatrix(:,1:end-1); % exclude last column (where ThE data is)

%% plots
   % normalise data
    for nor=1:size(meanFRs,2)
        normalised(:,nor)=meanFRs(:,nor)./meanFRs(find(sFact==1),nor); % value where sf=1
    end
    
    %% subplot1: graphical representation of the network
    ff=figure('Name',FigName,'Visible',Visibility); 
    subplot(3,6,[1.2 1.9])
    hold on
    x_val=1:length(sFact);
    y_val=NaN(length(sFact),length(PopName));
    bar(x_val,y_val);
    title('Varied projection(s): in red', 'Fontsize', 18);
    set(gca, 'XTickLabel',[],'YTickLabel',[],'YDir','reverse');
    legend(PopName,'Location', 'eastoutside')
    % load pic
    pic_name=sprintf('%d.png', ProjNum);
    pic=imread(pic_name);
    imshow(pic,'XData',[0 5793]);
    hold off
    
    %% subplot2: normalised values for change in mean firing rates
    subplot(3,6,[3 4 5.6])
    fig_title1=sprintf('Normalised mean FRs upon the change in %s Pconn',ProjName);
    plot(x_val,ones(length(sFact)),'k','LineWidth',3); 
    hold on; grid on
    thr1=9; % set the threshold above which 2nd yaxis is going to be introduced (value 9 was chosen after inspecting the figure)
    if  any(normalised(:)>thr1)==1 % make two y axes if necessary
        for clm_find=1:size(normalised,2) 
            check1=find(normalised(:,clm_find)>thr1, 1); % check if there is a value bigger than 9
            if isempty(check1)==1 % if column does not have values > 9, plot them on the left axis
                yyaxis left
                plot(x_val,normalised(:,clm_find),'marker','o','color',LineCol(clm_find,:),'LineStyle','-','LineWidth',2);
                ylabel({'Normalised FRs'; '(REGULAR LINES)'},'FontSize',14);
            else % if column does have values > 9, plot them on the right y axis
                yyaxis right
                plot(x_val,normalised(:,clm_find),'marker','o','color',LineCol(clm_find,:),'LineStyle',':','LineWidth',2);
                ylabel({'Normalised FRs'; '(DOTTED LINES)'},'FontSize',14);
            end
        end 
    else % if there is no value >thr1, plot using only one y axis
        plot(x_val,normalised,'marker','o','LineWidth',2)
        ylabel('Normalised FRs','FontSize',14);
    end
    title(fig_title1,'FontSize',18);
    xlabel('Scaling factors','FontSize',14);
    set(gca, 'XDir','normal', 'XTickLabel', sFact);
    hold off

    %% subplot3: change in mean firing rates
    subplot(3,6,[7 8 9]); 
    hold on; grid on
    fig_title2=sprintf('Mean FRs with STD (shade): change in %s Pconn',ProjName);
    filNames=fieldnames(RawForShade); % get fields for easier indexing in for-loop
    alpha=0.3; % transparency factor
    for sh=1:numel(fieldnames(RawForShade))
        stdShade(getfield(RawForShade,char(filNames(sh))),alpha,LineCol(sh,:));
    end
    hold off; grid off
    title(fig_title2,'FontSize',14);
    xlabel('Scaling factors','FontSize',14);
    ylabel('mean single cell FR (in Hz)','FontSize',14);
    set(gca, 'XDir','normal', 'XTickLabel', sFact);
    
%  % below code is for previous bar plot  
%     bar(x_val,meanFRs,'EdgeColor','none');
%     title(fig_title2,'FontSize',14);
%     %legend(PopName,'Location', 'eastoutside')
%     xlabel('Scaling factors','FontSize',14);      % double line?
%     ylabel('average FR (in Hz)','FontSize',14);
%     set(gca, 'XDir','normal', 'XTickLabel', sFact); 
%     xlabel('Scaling factors','FontSize',14);
%     ylim([0, max(meanFRs(:))+3]); % so there is a bit space on top
%     thr2=18; % set the threshold above which the yaxis is going to be cut 
%              % (I got the thr value after inspecting the figure)
%     breakyaxis([thr2, max(meanFRs(:))]); % this is a more rigorous method than the one below
%     
%     
    % break y axis if necessary (THIS CODE DOES THE JOB MORE EFFICIENTLY BECAUSE YOU
    % DONT LOSE AS MUCH PEAKS, BUT SOMETIMES THE BREAK IS TOO SMALL):
    
%     if  any(meanFRs(:)>thr)==1 % check if there is any value bigger than 500
%         for clm_sort=1:size(meanFRs,2) 
%             check2=find(meanFRs(:,clm_sort)>thr); % check in which column is this value
%             if ~isempty(check2)==1 % if column contains values > thr
%                col=sort(meanFRs(:,clm_sort));
%                [rw3,clm3]=find(col>thr,1,'first'); % find the first value bigger than thr
%                first=col(rw3,clm3);
%                [rw4,clm4]=find(col>first,1,'first'); % find a second value bigger than thr
%                second=col(rw4,clm4);
%                breakyaxis([thr, second]) % break axis from thr to the second biggest value over thr
%                % works well, but it messes up the legend and x axis; 
%                % that's why i have only one legend at the beginning
%             end
%         end
%     end
        
    %% subplot4: heatmap of normalised values
    subplot(3,6,[10.2 11.7])
    fig_title3='Heatmap of normalised FRs values';
    heatmap(PopName,sFact,normalised,'FontSize',12,'Colormap',parula);
    title(fig_title3);
    xlabel('Neuronal populations');
    ylabel('Scaling factors');
    
    %% subplots5-10: change in mean firing rate for specific population
    for ii=1:size(meanFRs,2)
        barColorMap = lines(size(meanFRs,2));
        subplot(3,6,12+ii)
        fig_title4=sprintf('Mean FRs of %s',PopName(ii));
        handleToThisBarSeries(ii) = bar(x_val,meanFRs(:,ii),'EdgeColor','none');
        set(handleToThisBarSeries(ii), 'FaceColor', barColorMap(ii,:));
        set(gca, 'XDir','normal', 'XTickLabel', sFact);
%         if any(meanFRs(:,ii)>thr2)==1
%            hold on
%            fivehundredline=ones(1,length(sFact)).*thr2; % five hundred line to see where the plot was cut
%            plot(x_val,fivehundredline,'k','LineWidth',2);
%         end
        title(fig_title4,'FontSize',18);
        xlabel('Scaling factors','FontSize',14);
        xtickangle(45);
        ylabel('Firing rate (in Hz)','FontSize',14);
        hold on
        errorbar(x_val,meanFRs(:,ii),stdsFRs(:,ii),'o')
        hold off
    end

%% save figure
    if SaveFig==1 
       savefig(ff,FigName)
    end
end