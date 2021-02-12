# Thalamocortical model (N4)

Model of the canonical thalamocortical Th --> L4 --> L2/3 pathway in rodent primary somatosensory cortex (S1). This four-layered feedforward model network serves as a tool for investigating robustness of stimuli representation in S1 after deprivation of various synaptic projection types. Synaptic deprivation was introduced as decreased probability of forming projections between neurons.

Model is made using DynaSim, a Matlab-based toolbox for modeling and simulating neural systems (Sherfey et al., 2018). It is based on the model by Soplata et al. (2017), but was adjusted to account for active whisking behaviour rather than a unconsious state: a dual  Poisson mechanism was introduced as the input to the VPM neurons and connection strengths were adapted. 

Visit the DynaSim page here: https://github.com/DynaSim/DynaSim.git

The simulation results can be found here: https://drive.google.com/drive/folders/19uNPbgVgDMHRvwGoTfga9nTGK7YVT_fI

----------------------------------
## References 
Sherfey, J. S., Soplata, A. E., Ardid, S., Roberts, E. A., Stanley, D. A., Pittman-Polletta, B. R., & Kopell, N. J. (2018). 
DynaSim: A MATLAB Toolbox for Neural Modeling and Simulation. Frontiers in Neuroinformatics. https://doi.org/10.3389/fninf.2018.00010

Soplata, Austin E., Michelle M. McCarthy, Jason Sherfey, Shane Lee, Patrick L. Purdon, Emery N. Brown, and N J Kopell. (2017). Thalamocortical Control of Propofol Phase-Amplitude Coupling. PLoS Computational Biology. https://doi.org/10.1371/journal.pcbi.1005879
