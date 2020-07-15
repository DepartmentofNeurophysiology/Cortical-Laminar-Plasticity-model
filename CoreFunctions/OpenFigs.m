%% Script for opening Figs 
% figs are in g-drive:
%PathToData='/Volumes/GoogleDrive/Moj disk/Teas Simulations/simulations/VeryNew (late Feb 2020)/results';

% set params:
figToOpen='Overview'; % type of figure // options: psthRaster, Overview
    fPar=1;    % synapse strength // options: 0.10,0.25
    sPar=12;     % which projection // options: [1:1:28]
    tPar=1;     % scaling factors  // options: index of wanted sFact=[1, 0.75, 0.5, 0.25, 0.1];
    qPar=2;     % which sim-repeat // options: [1:1:5]

params=[fPar,sPar,tPar,qPar];
% load:
OpFigure(figToOpen,params)

%% load figure with default visibility
function OpFigure(figType,params)
    switch figType
        case 'psthRaster'
            figgyName=sprintf('sStr0%dProj%dResSf%dRep%d%s',params(1),params(2),params(3),params(4),figType);
            figgyName=[figgyName '.fig'];
        case 'Overview'
            params(3)=5; % my error while naming
            figgyName=sprintf('sStr0%dProj%dResSf%d%s',params(1),params(2),params(3),figType);
            figgyName=[figgyName '.fig'];
    end
    open(figgyName)
    set(gcf,'visible','on')
end