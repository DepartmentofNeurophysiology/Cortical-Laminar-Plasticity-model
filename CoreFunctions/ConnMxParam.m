function ParamValue=ConnMxParam(projection, type)
% function outputs value for either the number of boutons (nb) or connectivity
% probability (pconn) for a specific projection
synstr=0.10; % this is the reduction factor of the synaptic strength

    switch type
        case 'pconn'
            fval=1;
        case 'nb'
            fval=2;
        otherwise
            disp('Error in providing input variables in ConnMxParam')
    end
  
p.l2ee=[0.10, 3 *synstr]; % [Pconn, nb]
p.l2ei=[0.65, 10 *synstr];% [Pconn, nb]
p.l2ie=[0.60, 6 *synstr]; % [Pconn, nb]
p.l2ii=[0.55, 10 *synstr];% [Pconn, nb]

p.l3ee=[0.10, 3 *synstr]; % [Pconn, nb]
p.l3ei=[0.65, 10 *synstr];% [Pconn, nb]
p.l3ie=[0.60, 6 *synstr]; % [Pconn, nb]
p.l3ii=[0.55, 10 *synstr];% [Pconn, nb]

p.l4ee=[0.06, 3 *synstr]; % [Pconn, nb]
p.l4ei=[0.43, 8 *synstr]; % [Pconn, nb]
p.l4ie=[0.44, 14 *synstr];% [Pconn, nb]
p.l4ii=[0.55, 10 *synstr];% [Pconn, nb]

p.thl4e=[0.43, 7 *synstr];   % [Pconn, nb]
p.thl4i=[0.5, 9 *synstr];    % [Pconn, nb]

p.l4el3e=[0.12, 5 *synstr];  % [Pconn, nb]
p.l4el3i=[0.2, 3 *synstr];   % [Pconn, nb]
p.l4il3e=[0.44, 15 *synstr]; % [Pconn, nb]

p.l3el2e=[0.10, 3 *synstr];  % [Pconn, nb]
p.l3el2i=[0.65, 10 *synstr]; % [Pconn, nb]
p.l3il2e=[0.60, 6 *synstr];  % [Pconn, nb]
p.l3il2i=[0.55, 10 *synstr]; % [Pconn, nb]

    params=getfield(p,projection);
    ParamValue=params(fval);
end