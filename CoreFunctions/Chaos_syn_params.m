% synapse params:

% parameters are saves as mean+-std; except for delay, which in the form of
% [velocity, release delay]; and the delay between a connection is
% determined as distance/velocity + release delay
% currently all distance is in microns, thus volecity is micron/ms

%% thalamic layer to layer 4
% ThE -> l4E
parathEto4E.I0 = [0.9,1.1];       
parathEto4E.tau1 = [15.5,3.1]; % decay time
parathEto4E.tau2 = [1.1,0.2]; % rise time
parathEto4E.Plas = [0.7,0.1]; % plasticity
parathEto4E.Fail = [0.05,0.02]; % failure rate
parathEto4E.Nb = 5; % number of boutons (5 vs 10)
parathEto4E.va = 0.4; % variance (up to 1)
parathEto4E.CV = [0.41,0.2]; % coeff of variation
parathEto4E.delay = [500,1.3]; % delay time

% ThE -> l4I
parathEto4FS.I0 = [2.1,1.1];       
parathEto4FS.tau1 = [8,1];
parathEto4FS.tau2 = [0.41,0.15];
parathEto4FS.Plas = [0.75,0.1];
parathEto4FS.Fail = [0.05,0.02];
parathEto4FS.Nb = 5;
parathEto4FS.va = 0.9;
parathEto4FS.CV = [0.41,0.2];
parathEto4FS.delay = [500,1.3];


%% thalamic layer to layer 23
% ThE -> l2E/l3E
parathEto4E.I0 = [0.9,1.1];       
parathEto4E.tau1 = [15.5,3.1];
parathEto4E.tau2 = [1.1,0.2];
parathEto4E.Plas = [0.7,0.1];
parathEto4E.Fail = [0.05,0.02];
parathEto4E.Nb = 5;
parathEto4E.va = 0.4;
parathEto4E.CV = [0.41,0.2];
parathEto4E.delay = [500,1.3];

% ThE -> l2I/l3I
parathEto4FS.I0 = [2.1,1.1];      
parathEto4FS.tau1 = [8,1];
parathEto4FS.tau2 = [0.41,0.15];
parathEto4FS.Plas = [0.75,0.1];
parathEto4FS.Fail = [0.05,0.02];
parathEto4FS.Nb = 5;
parathEto4FS.va = 0.9;
parathEto4FS.CV = [0.41,0.2];
parathEto4FS.delay = [500,1.3];

%% layer 4 to layer 23
% l4E -> l2E
para4E2E.I0 = [0.70,0.6];      
para4E2E.tau1 = [12.7,3.5];
para4E2E.tau2 = [0.6,0.3];
para4E2E.Plas = [0.8,0.28];
para4E2E.Fail = [0.049,0.08];
para4E2E.STD.U = [0.7,0.1];
para4E2E.STD.F = [1000,100];
para4E2E.STD.D = [800,80];
para4E2E.Nb = 5;
para4E2E.va = 0.15;
para4E2E.delay = [190, 0.4];

% l4E -> l2I
para4E2I.I0 = [1.2,1.1];       
para4E2I.tau1 = [14.7,7];
para4E2I.tau2 = [0.4,0.1];
para4E2I.Plas = [0.8,0.1];
para4E2I.Fail = [0.049,0.04];
para4E2I.STD.U = [0.7,0.1];
para4E2I.STD.F = [1000,100];
para4E2I.STD.D = [800,80];
para4E2I.Nb = 3;
para4E2I.va = 0.2;
para4E2I.delay = [190, 0.4];

% l4I -> l2E (missing data so take it from l4I -> l4E)
para4FSto4E.I0 = [1.1,0.8];      
para4FSto4E.tau1 = [24,4.8];
para4FSto4E.tau2 = [1.5,0.6];
para4FSto4E.Plas = [0.7,0.3];
para4FSto4E.Fail = [0.03,0.07];
para4FSto4E.Nb = 20;
para4FSto4E.va = -1;
para4FSto4E.CV = [0.25,0.11];
para4FSto4E.delay = [190, 0.7];


%% layer 4 to layer 4
% l4E -> l4E
para4Eto4E.I0 = [1.2,1.1];      
para4Eto4E.tau1 = [17.8,3.1];
para4Eto4E.tau2 = [0.92,0.18];
para4Eto4E.Plas = [0.65,0.15];
para4Eto4E.Fail = [0.05,0.078];
para4Eto4E.Nb = 5;
para4Eto4E.va = 0.2;
para4Eto4E.CV = [0.37, 0.16];
para4Eto4E.delay = [190, 0.4];

% l4E -> l4I
para4Eto4FS.I0 = [2.2,2.2];          
para4Eto4FS.tau1 = [7.9,1.9];
para4Eto4FS.tau2 = [0.37,0.11];
para4Eto4FS.Plas = [0.7,0.3];
para4Eto4FS.Fail = [0.03,0.08];
para4Eto4FS.Nb = 20;
para4Eto4FS.va = 0.4;
para4Eto4FS.CV = [0.27,0.13];
para4Eto4FS.delay = [190,0.3];

% l4I -> l4E
para4FSto4E.I0 = [1.1,0.8];      
para4FSto4E.tau1 = [24,4.8];
para4FSto4E.tau2 = [1.5,0.6];
para4FSto4E.Plas = [0.7,0.3];
para4FSto4E.Fail = [0.03,0.07];
para4FSto4E.Nb = 20;
para4FSto4E.va = -0.25;
para4FSto4E.CV = [0.25,0.11];
para4FSto4E.delay = [190,0.3];

% l4I -> l4I
% missing

%% layer 23 to layer 23
% l23E -> l23E
para23E2E.I0 = [0.9,0.6];      
para23E2E.tau1 = [15.7,4.5];
para23E2E.tau2 = [0.7,0.2];
para23E2E.Plas = [0.7,0.3];
para23E2E.Fail = [0.03,0.02];
para23E2E.STD.U = [0.7,0.1];
para23E2E.STD.F = [1000,100];
para23E2E.STD.D = [800,80];
para23E2E.Nb = 3;
para23E2E.va = 0.18;
para23E2E.delay = [190, 1.1];

% l23E -> l23I
para23E2BS_PV.I0 = [0.82,0.6];      % BS_PV = PV+ basket cells ?             
para23E2BS_PV.tau1 = [14,1.6];                
para23E2BS_PV.tau2 = [1.6,0.6];
para23E2BS_PV.Plas = [0.7,0.13];
para23E2BS_PV.STD.U = [0.7,0.1];
para23E2BS_PV.STD.F = [1000,100];
para23E2BS_PV.STD.D = [800,80];
para23E2BS_PV.Nb = 20;
para23E2BS_PV.va = 0.7;
para23E2BS_PV.delay = [190, 0.3];

% l23I -> l23E
para23BS_PV2E.I0 = [0.56,0.54];                     
para23BS_PV2E.tau1 = [40,9];
para23BS_PV2E.tau2 = [1.4,0.4];
para23BS_PV2E.Plas = [0.7,0.2];
para23BS_PV2E.STD.U = [0.35,0.1];
para23BS_PV2E.STD.F = [21,9];
para23BS_PV2E.STD.D = [760,200];
para23BS_PV2E.Nb = 7;
para23BS_PV2E.va = -0.5;
para23BS_PV2E.delay = [190, 0.1];

% l23I -> l23I
para23BS_PV2BS_PV.I0 = [0.56,0.5];               
para23BS_PV2BS_PV.tau1 = [16,3];
para23BS_PV2BS_PV.tau2 = [1.8,0.6];
para23BS_PV2BS_PV.Plas = [0.7,0.15];
para23BS_PV2BS_PV.STD.U = [0.35,0.1];
para23BS_PV2BS_PV.STD.F = [21,9];
para23BS_PV2BS_PV.STD.D = [760,200];
para23BS_PV2BS_PV.Nb = 5;
para23BS_PV2BS_PV.va = -0.4;
para23BS_PV2BS_PV.delay = [190, 0.7];


