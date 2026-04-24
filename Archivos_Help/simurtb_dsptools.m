%% Digital Signal Processing 
% Simurtools Toolbox(TM) include tools to help in some specific tasks of DSP.
% They are an addition to the DSP Toolbox of matlab.
%
% <<impetus.png>>

%% Special tools
% General purpose tools, for any signal

%%
%
% * <buscamaximos.html buscamaximos: seeks all the maxims of a signal>
% * <buscamaximosth.html buscamaximosth: search for all maxima that exceed a threshold>
% * cumcamsimp: numerical integration of cavalieri-simpson
% * datacrop: interactive tool to cut a signal


%% Double integral variations
% They are normally used to double integrate an acceleration and obtain a displacement.
%
% <<cumsum.png>>
%
% More info: Accelerometry-Based Distance Estimation for Ambulatory Human Motion Analysis, 
% Alvarez J., Alvarez D., Lopez A., Sensors n.18, 4441, 10.3390/s18124441. (2018) 
%

%%
%
% * <dinteg_cms.html dinteg_cms: direct doble cumsum method (CMS method)> 
% * <dinteg_lri.html dinteg_lri: lineal resetting mechanism (LRI method)>
% * <dinteg_msi.html dinteg_msi: an integration with mean subtraction (MSI method)> 
% * <dinteg_ofi.html dinteg_ofi: the optimally filtered integration (OFI method)>
% * <dinteg_ddi.html dinteg_ddi: de-drifted integration (DDI method)>
% * doble_cumsum_zijlstra: integration with Zijsltra method
%