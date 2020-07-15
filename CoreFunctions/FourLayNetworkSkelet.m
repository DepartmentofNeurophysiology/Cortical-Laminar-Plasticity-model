%------------------------------------------------------------------
% FOUR LAYERED THALAMO-CORTICAL NETWORK WITH HODGKIN-HUXLEY CELLS
% compatible with DynaSim toolbox
%------------------------------------------------------------------
function SpikingNetwork=FourLayNetworkSkelet(E_cellnum,I_cellnum,Th_cellnum, time, SynParams, ThParamVec)
% cell numbers
Ne=E_cellnum; % excitatory cortical
Ni=I_cellnum; % inhibitory cortical
Nt=Th_cellnum; % thalamic cells

% define time
tspan = [time(1) time(end)];     % time span [begin end], ms
dt = 0.01;           % fixed time step, ms

act=getfield(SynParams,'act');   % whether to vary synapse or not
sf=getfield(SynParams,'sf');    % scaling factor for varying synapse
vary=getfield(SynParams,'vary');  % which aspect of synapse to vary (pconn or nb)

%----------------------------
% params for REGULAR SPIKING
%----------------------------
% equations and params are from RS.pop by DynaSim, but I added some noise to disable uniform spiking:
RSeqns={'dV/dt=(Iapp+@current+noise*randn(1, Npop))./Cm; V(0)=-65; gNaF=200; gKDR=20; gAR=25; Iapp=0; noise=40;'};  
Cm=.9; Eleak=-70; gleak=1;
E_NaF=50; E_KDR=-95; E_AR=-35; 
NaF_V0=34.5; NaF_V1=59.4; NaF_d1=10.7; NaF_V2=33.5; NaF_d2=15; NaF_c0=.15; NaF_c1=1.15; 
KDR_V1=29.5; KDR_d1=10; KDR_V2=10; KDR_d2=10;
AR_V12=-87.5; AR_k=-5.5; c_ARaM=1.75; c_ARbM=.5; AR_L=1; AR_R=1;

L2.populations(1).name='E'; % excitatory, regular spiking
L2.populations(end).size=Ne;
L2.populations(end).equations=RSeqns;
L2.populations(end).mechanism_list={'iNaF','iKDR','iAR','ileak'};
L2.populations(end).parameters={'Cm',Cm,'Eleak',Eleak,'gleak', gleak,'E_NaF',E_NaF,'E_KDR',E_KDR,'E_AR',E_AR,...
                                'NaF_V0',NaF_V0,'NaF_V1',NaF_V1,'NaF_d1',NaF_d1,'NaF_V2',NaF_V2,'NaF_d2',NaF_d2,'NaF_c0',NaF_c0,'NaF_c1',NaF_c1,...
                                'KDR_V1',KDR_V1,'KDR_d1',KDR_d1,'KDR_V2',KDR_V2,'KDR_d2',KDR_d2,...
                                'AR_V12',AR_V12,'AR_k',AR_k','c_ARaM',c_ARaM,'c_ARbM',c_ARbM,'AR_L',AR_L,'AR_R',AR_R...
                                };
                            
%--------------------------
% params for FAST SPIKING
%--------------------------
% equations and params are from FS.pop by DynaSim, but I added some noise to disable uniform spiking:
FSeqns={'dV/dt=(Iapp+@current+shift+noise*randn(1, Npop))./Cm; V(0)=-65; shift=-10; noise=10;' % shift prevents baseline spiking
        'gNaF=200; gKDR=20; Iapp=0;'};
Cm=.9; Eleak=-65; gleak=1;  
E_NaF=50; NaF_V0=38; NaF_V1=58.3; NaF_d1=6.7; NaF_V2=37; NaF_d2=15; NaF_c0=.15; NaF_c1=1.15;
E_KDR=-100; KDR_V1=27; KDR_d1=11.5; KDR_V2=10; KDR_d2=10;

L2.populations(end+1).name='I'; % inhibitory, fast spiking
L2.populations(end).size=Ni;
L2.populations(end).equations=FSeqns;
L2.populations(end).mechanism_list={'iNaF','iKDR','ileak'};
L2.populations(end).parameters={'Cm', Cm, 'Eleak', Eleak, 'gleak', gleak,...
                                'E_NaF',E_NaF,'NaF_V0',NaF_V0,'NaF_V1',NaF_V1,'NaF_d1',NaF_d1,'NaF_V2',NaF_V2,'NaF_d2',NaF_d2,'NaF_c0',NaF_c0,'NaF_c1',NaF_c1,...
                                'E_KDR',E_KDR,'KDR_V1',KDR_V1,'KDR_d1',KDR_d1,'KDR_V2',KDR_V2,'KDR_d2',KDR_d2...
                                };
%--------------------------------------------------------------------------  
% FORM POPULATIONS
%--------------------------------------------------------------------------  
% rename pops:
oldname1=L2.populations(1).name; % 'E'
oldname2=L2.populations(2).name; % 'I'
id2='l2'; % new prefix
L2=dsApplyModifications(L2,{oldname1,'name',[id2 oldname1]; oldname2,'name',[id2 oldname2]}); % l2E, l2I
% connect populations in L2 layer:
% params for synaptic connections (Huang,C.(2016))
l2ee_tau1 = normrnd(15.7,4.5);   l2ee_tau2 = normrnd(0.7,0.2); % E to E
l2ei_tau1 = normrnd(15.25,5.78); l2ei_tau2 = normrnd(2.32,1.00); % E to I
l2ie_tau1 = normrnd(43.1,10.2);  l2ie_tau2 = normrnd(3.5,1.4); % I to E
l2ii_tau1 = normrnd(15.8,6.0);   l2ii_tau2 = normrnd(1.8,0.6); % I to I

% calculate connectivity matrices: 
    % conmat=ConnMx(activity, layer, vary, Npre, Npost, Pconn, Nb, sf)
l2EEnetcon=ConnMx(ActSyn('l2ee',act),'intrahom',vary,Ne,Ne,ConnMxParam('l2ee','pconn'),ConnMxParam('l2ee','nb'),sf); % l2E to l2E % removed autoptic
l2EInetcon=ConnMx(ActSyn('l2ei',act),'intrahet',vary,Ne,Ni,ConnMxParam('l2ei','pconn'),ConnMxParam('l2ei','nb'),sf); % l2E to l2I
l2IEnetcon=ConnMx(ActSyn('l2ie',act),'intrahet',vary,Ni,Ne,ConnMxParam('l2ie','pconn'),ConnMxParam('l2ie','nb'),sf); % l2I to l2E 
l2IInetcon=ConnMx(ActSyn('l2ii',act),'intrahom',vary,Ni,Ni,ConnMxParam('l2ii','pconn'),ConnMxParam('l2ii','nb'),sf); % l2I to l2I % removed autoptic

% connect populations in L2 layer 
L2.connections(1).direction='l2E->l2E'; % E to E
L2.connections(end).mechanism_list={'iAMPA'};
L2.connections(end).parameters={'tauAMPA',l2ee_tau1,'tauAMPAr',l2ee_tau2,'netcon',l2EEnetcon}; 
L2.connections(end+1).direction='l2E->l2I'; % E to I
L2.connections(end).mechanism_list={'iAMPA'};
L2.connections(end).parameters={'tauAMPA',l2ei_tau1,'tauAMPAr',l2ei_tau2,'netcon',l2EInetcon}; 
L2.connections(end+1).direction='l2I->l2E'; % I to E
L2.connections(end).mechanism_list={'iGABAa'};
L2.connections(end).parameters={'tauGABA',l2ie_tau1,'tauGABAr',l2ie_tau2,'netcon',l2IEnetcon}; 
L2.connections(end+1).direction='l2I->l2I'; % I to I
L2.connections(end).mechanism_list={'iGABAa'};
L2.connections(end).parameters={'tauGABA',l2ii_tau1,'tauGABAr',l2ii_tau2,'netcon',l2IInetcon}; 
L2=dsCheckSpecification(L2); 

%------------------------------
% MAKE CORTICAL LAYERS (l3, l4)
%------------------------------
oldname11=L2.populations(1).name; % 'l2E'
oldname22=L2.populations(2).name; % 'l2I'
id3='l3'; % layer 3
L3=dsApplyModifications(L2,{oldname11,'name',[id3 'E']; oldname22,'name',[id3 'I']}); % l3E, l3I
id4='l4'; % layer 4
L4=dsApplyModifications(L2,{oldname11,'name',[id4 'E']; oldname22,'name',[id4 'I']}); % l4E, l4I

% modify layers with params from Huang,C.(2016)
    % l3 modifications: connection params
l3EEnetcon=ConnMx(ActSyn('l3ee',act),'intrahom',vary,Ne,Ne,ConnMxParam('l3ee','pconn'),ConnMxParam('l3ee','nb'),sf); % l3E to l3E
l3EInetcon=ConnMx(ActSyn('l3ei',act),'intrahet',vary,Ne,Ni,ConnMxParam('l3ei','pconn'),ConnMxParam('l3ei','nb'),sf); % l3E to l3I
l3IEnetcon=ConnMx(ActSyn('l3ie',act),'intrahet',vary,Ni,Ne,ConnMxParam('l3ie','pconn'),ConnMxParam('l3ie','nb'),sf); % l3I to l3E
l3IInetcon=ConnMx(ActSyn('l3ii',act),'intrahom',vary,Ni,Ni,ConnMxParam('l3ii','pconn'),ConnMxParam('l3ii','nb'),sf); % l3I to l3I

% values are the same as in l2 to l2 synapses:
l3ee_tau1 = normrnd(15.7,4.5);   l3ee_tau2 = normrnd(0.7,0.2); % E to E
l3ei_tau1 = normrnd(15.25,5.78); l3ei_tau2 = normrnd(2.32,1.00); % E to I
l3ie_tau1 = normrnd(43.1,10.2);  l3ie_tau2 = normrnd(3.5,1.4); % I to E
l3ii_tau1 = normrnd(15.8,6.0);   l3ii_tau2 = normrnd(1.8,0.6); % I to I

modifsl3={'l3E->l3E','tauAMPA',l3ee_tau1;'l3E->l3E','tauAMPAr',l3ee_tau2;'l3E->l3E','netcon',l3EEnetcon;...
          'l3E->l3I','tauAMPA',l3ei_tau1;'l3E->l3I','tauAMPAr',l3ei_tau2;'l3E->l3I','netcon',l3EInetcon;...
          'l3I->l3E','tauGABA',l3ie_tau1;'l3I->l3E','tauGABAr',l3ie_tau2;'l3I->l3E','netcon',l3IEnetcon;...
          'l3I->l3I','tauGABA',l3ii_tau1;'l3I->l3I','tauGABAr',l3ii_tau2;'l3I->l3I','netcon',l3IInetcon...
          };
L3=dsApplyModifications(L3,modifsl3);

    % l4 modifications: connection params
l4EEnetcon=ConnMx(ActSyn('l4ee',act),'intrahom',vary,Ne,Ne,ConnMxParam('l4ee','pconn'),ConnMxParam('l4ee','nb'),sf); % l4E to l4E % removed autoptic
l4EInetcon=ConnMx(ActSyn('l4ei',act),'intrahet',vary,Ne,Ni,ConnMxParam('l4ei','pconn'),ConnMxParam('l4ei','nb'),sf); % l4E to l4I
l4IEnetcon=ConnMx(ActSyn('l4ie',act),'intrahet',vary,Ni,Ne,ConnMxParam('l4ie','pconn'),ConnMxParam('l4ie','nb'),sf); % l4I to l4E
l4IInetcon=ConnMx(ActSyn('l4ii',act),'intrahom',vary,Ni,Ni,ConnMxParam('l4ii','pconn'),ConnMxParam('l4ii','nb'),sf); % l4I to l4E

l4ee_tau1 = normrnd(12.3,2.2);  l4ee_tau2 = normrnd(0.88,0.26); % E to E
l4ei_tau1 = normrnd(4.9,1.9);   l4ei_tau2 = normrnd(0.37,0.11); % E to I
l4ie_tau1 = normrnd(24.0,10.8); l4ie_tau2 = normrnd(1.5,0.7); % I to E
l4ii_tau1 = normrnd(15.8,6.0);  l4ii_tau2 = normrnd(1.8,0.6); % I to I

modifsl4={'l4E->l4E','tauAMPA',l4ee_tau1;'l4E->l4E','tauAMPAr',l4ee_tau2;'l4E->l4E','netcon',l4EEnetcon;...
          'l4E->l4I','tauAMPA',l4ei_tau1;'l4E->l4I','tauAMPAr',l4ei_tau2;'l4E->l4I','netcon',l4EInetcon;...
          'l4I->l4E','tauGABA',l4ie_tau1;'l4I->l4E','tauGABAr',l4ie_tau2;'l4I->l4E','netcon',l4IEnetcon;...
          'l4I->l4I','tauGABA',l4ii_tau1;'l4I->l4I','tauGABAr',l4ii_tau2;'l4I->l4I','netcon',l4IInetcon;... 
        };
L4=dsApplyModifications(L4,modifsl4); 

%--------------------------------------------------------------------------
% NOTA BENE:
% "Neither local inhibitory interneurones in the VPM (Barbaresi et al. 1986) 
% nor recurrent connections between VPM cells have been observed" (Brecht
% and B. Sakmann, 2007). 
%--------------------------------------------------------------------------
%% MAKE A THALAMIC LAYER:
    % there are no Inhibitory population in Th 
    % this population presents neurons of VPM thalamic nucleus
    
% this is adopted from: Dynasim > Thalamus_models > tcre_run_script.m (but
% only the TC population and TC->TC connections)
Th.populations(1).name='ThE';
Th.populations(end).size=Nt;
Th.populations(end).equations={'dV/dt=@current+Iapp'};
Th.populations(end).mechanism_list={'iNaChing2010TC','iKChing2010TC',...
                                   'CaBufferChing2010TC','iTChing2010TC',...
                                   'iHChing2010TC','iLeakChing2010TC',...
                                   'iKLeakChing2010TC'};
Th.populations(end).parameters={'Iapp',0,'gH',0.001};

ThalPoissParams=ThalParams(ThParamVec); % user sets up parameters to govern thalamic activity 
% output: ThalPoissParams=[CorrRate, CorrPconn, UncorrRate, UncorrPconn, gSyn];

% connect thalamic relay-cells:
Th.connections(1).direction='ThE->ThE';
Th.connections(end).mechanism_list={'iPoissonSpiketrainCorr','iPoissonSpiketrainUncorr'};
Th.connections(end).parameters={'g_esyn',ThalPoissParams(5),...
                                'corr_rate',ThalPoissParams(1),'uncorr_rate',ThalPoissParams(3),...
                                'corr_prob_cxn',ThalPoissParams(2),'uncorr_prob_cxn',ThalPoissParams(4),...
                                'T',tspan(end),'tau_i',10,'jitter_stddev',500};

%--------------------------------------------------------------------------
%% make 4-layered network
Network=dsCombineSpecifications(L2,L3,L4,Th);

% make connectivity matrices for inter-layer connections: netcon=ConnMx(activity,layer,vary,Npre,Npost,va,Nb)
    % Th -> L4
thl4EEnetcon=ConnMx(ActSyn('thl4e',act),'trans',vary,Nt,Ne,ConnMxParam('thl4e','pconn'),ConnMxParam('thl4e','nb'),sf); 
thl4EInetcon=ConnMx(ActSyn('thl4i',act),'trans',vary,Nt,Ni,ConnMxParam('thl4i','pconn'),ConnMxParam('thl4i','nb'),sf); 
    % L4 -> L3
l4l3EEnetcon=ConnMx(ActSyn('l4el3e',act),'trans',vary,Ne,Ne,ConnMxParam('l4el3e','pconn'),ConnMxParam('l4el3e','nb'),sf);
l4l3EInetcon=ConnMx(ActSyn('l4el3i',act),'trans',vary,Ne,Ni,ConnMxParam('l4el3i','pconn'),ConnMxParam('l4el3i','nb'),sf);
l4l3IEnetcon=ConnMx(ActSyn('l4il3e',act),'trans',vary,Ni,Ne,ConnMxParam('l4il3e','pconn'),ConnMxParam('l4il3e','nb'),sf);
    % L3 -> L2
l3l2EEnetcon=ConnMx(ActSyn('l3el2e',act),'trans',vary,Ne,Ne,ConnMxParam('l3el2e','pconn'),ConnMxParam('l3el2e','nb'),sf);
l3l2EInetcon=ConnMx(ActSyn('l3el2i',act),'trans',vary,Ne,Ni,ConnMxParam('l3el2i','pconn'),ConnMxParam('l3el2i','nb'),sf);
l3l2IEnetcon=ConnMx(ActSyn('l3il2e',act),'trans',vary,Ni,Ne,ConnMxParam('l3il2e','pconn'),ConnMxParam('l3il2e','nb'),sf);
l3l2IInetcon=ConnMx(ActSyn('l3il2i',act),'trans',vary,Ni,Ni,ConnMxParam('l3il2i','pconn'),ConnMxParam('l3il2i','nb'),sf);

%-----------------------------------------------------------------------------------------------------------
% params from Huang,C.(2016):
    % thalamic to l4
thEto4E_tau1 = normrnd(22.5,27.4); thEto4E_tau2 = normrnd(1.16,0.27); % E to E
thEto4FS_tau1 = normrnd(6.74,1.10); thEto4FS_tau2 = normrnd(0.41,0.15); % E to I
    % l4 to l23 (l4 to l3)
l4E2E_tau1 = normrnd(12.7,3.5); l4E2E_tau2 = normrnd(0.8,0.3); % E to E
l4E2I_tau1 = normrnd(15.0,8.2); l4E2I_tau2 = normrnd(0.89,0.31); % E to I
l4I2E_tau1 = normrnd(24.0,10.8); l4I2E_tau2 = normrnd(1.5,0.7); % I to E (taken from L4->L4)
    % values are the same as in l2 to l2 synapses:
l32ee_tau1 = normrnd(15.7,4.5);   l32ee_tau2 = normrnd(0.7,0.2); % E to E
l32ei_tau1 = normrnd(15.25,5.78); l32ei_tau2 = normrnd(2.32,1.00); % E to I
l32ie_tau1 = normrnd(43.1,10.2);  l32ie_tau2 = normrnd(3.5,1.4); % I to E
l32ii_tau1 = normrnd(15.8,6.0);   l32ii_tau2 = normrnd(1.8,0.6); % I to I
%-----------------------------------------------------------------------------------------------------------
% add feedforward connections (th->l4; l4->l3; l3->l2)
    % thalamic to l4
Network.connections(end+1).direction='ThE->l4E'; % ThE to l4E
Network.connections(end).mechanism_list={'iAMPA'};
Network.connections(end).parameters={'tauAMPA',thEto4E_tau1,'tauAMPAr',thEto4E_tau2,'netcon',thl4EEnetcon}; 
Network.connections(end+1).direction='ThE->l4I'; % ThE to l4I
Network.connections(end).mechanism_list={'iAMPA'};
Network.connections(end).parameters={'tauAMPA',thEto4FS_tau1,'tauAMPAr',thEto4FS_tau2,'netcon',thl4EInetcon}; 

    % l4 to l23 (l4 to l3)
Network.connections(end+1).direction='l4E->l3E'; % l4E to l3E
Network.connections(end).mechanism_list={'iAMPA'};
Network.connections(end).parameters={'tauAMPA',l4E2E_tau1,'tauAMPAr',l4E2E_tau2,'netcon',l4l3EEnetcon}; 
Network.connections(end+1).direction='l4E->l3I'; % l4E to l3I
Network.connections(end).mechanism_list={'iAMPA'};
Network.connections(end).parameters={'tauAMPA',l4E2I_tau1,'tauAMPAr',l4E2I_tau2,'netcon',l4l3EInetcon}; 
Network.connections(end+1).direction='l4I->l3E'; % l4I to l3E
Network.connections(end).mechanism_list={'iGABAa'};
Network.connections(end).parameters={'tauGABA',l4I2E_tau1,'tauGABAr',l4I2E_tau2,'netcon',l4l3IEnetcon}; 

    % l23 to l23 feedforward (l3 to l2)
Network.connections(end+1).direction='l3E->l2E'; % l3E to l2E
Network.connections(end).mechanism_list={'iAMPA'};
Network.connections(end).parameters={'tauAMPA',l32ee_tau1,'tauAMPAr',l32ee_tau2,'netcon',l3l2EEnetcon}; 
Network.connections(end+1).direction='l3E->l2I'; % l3E to l2I
Network.connections(end).mechanism_list={'iAMPA'};
Network.connections(end).parameters={'tauAMPA',l32ei_tau1,'tauAMPAr',l32ei_tau2,'netcon',l3l2EInetcon}; 
Network.connections(end+1).direction='l3I->l2E'; % l3I to l2E
Network.connections(end).mechanism_list={'iGABAa'};
Network.connections(end).parameters={'tauGABA',l32ie_tau1,'tauGABAr',l32ie_tau2,'netcon',l3l2IEnetcon}; 
Network.connections(end+1).direction='l3I->l2I'; % l3I to l2I
Network.connections(end).mechanism_list={'iGABAa'};
Network.connections(end).parameters={'tauGABA',l32ii_tau1,'tauGABAr',l32ii_tau2,'netcon',l3l2IInetcon}; 

Network=dsCheckSpecification(Network); 

%SIMULATION:
SpikingNetwork=dsSimulate(Network,'tspan',tspan,'dt',dt);
end
