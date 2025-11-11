function varargout = SequencePool(varargin)
global gmSEQ
if isfield(gmSEQ,'CHN')&& ~isequal(varargin{1},'PBDictionary')
    gmSEQ=rmfield(gmSEQ,'CHN');
end
if isfield(gmSEQ,'bLiO') && ~isequal(varargin{1},'PBDictionary')
    gmSEQ=rmfield(gmSEQ,'bLiO');
end
switch varargin{1}
    case 'PopulateSeq'
        varargout{1} = PopulateSeq();
%     case 'Rabi'
%         Rabi();
%     case 'RabiQ'
%         RabiQ();
%     case 'Rabi+ctr2'
%         RabiCtr2();
%     case 'Ramsey'
%         Ramsey();
    case 'ENDOR_Rabi'
        ENDOR_Rabi();
    case 'wait_Rabi'
        wait_Rabi();
    case 'ENDOR_ODMR'
        ENDOR_ODMR();
    case 'Reference_ODMR'
        Reference_ODMR();
    case 'CW_pulsed_noMW'
        CW_pulsed_noMW();
    case 'CW_pulsed_MW'
        CW_pulsed_MW();
    case 'CW_pulsed_MWonoff'
        CW_pulsed_MWonoff(); 
    case 'pulsed'
        pulsed();
    case 'pulsed_MW'
        pulsed_MW(); 
    case 'pulsed_MWoffon'
        pulsed_MWoffon();
    case 'pulsed_MWoffon2'
        pulsed_MWoffon2(); 
    case 'pulsed_MWoffon3'
        pulsed_MWoffon3();        
    case 'Reference_timescan'
        Reference_timescan();
    case 'cool_timescan'
        cool_timescan();
    case 'cool_timescan_MWpulse'
        cool_timescan_MWpulse();
    case 'cool_timescan_timetagger'
        cool_timescan_timetagger();
    case 'cool_timescan_timetagger_pol'
        cool_timescan_timetagger_pol();
    case 'Ramsey_2Counter'
        Ramsey_2Counter();
    case 'RamseyAWG_2Counter'
        RamseyAWG_2Counter();
    case 'T1_Zero'
        T1_Zero();
    case 'cool_T1'
        cool_T1();
    case 'DQ_3'
        DQ_3();
    case 'cool_T1_bright'
        cool_T1_bright();
    case 'cool_T1_dark'
        cool_T1_dark();
    case 'cool_T1_3'
        cool_T1_3();
    case 'Null_Measure'
        Null_Measure();
    case 'T1_2AWG'
        T1_2AWG();
    case 'T1AWG_Zero'
        T1AWG_Zero();
    case 'AOM Delay'
        AOMDelay();
%     case 'Optimize_Ctr'
%        Optimize_Ctr();
%     case 'NV_Polarization'
%         NV_Polarization();
%     case 'Echo'
%        Echo();
    case 'Echo_2Counter'
       Echo_2Counter();
    case 'EchoAWG_2Counter'
       EchoAWG_2Counter();
    case 'XY8_SwpN_2Counter'
       XY8_SwpN_2Counter();
    case 'XY8_SwpT_2Counter'
       XY8_SwpT_2Counter();
    case 'XY8_SwpN_2Counter_fixed_v2'
       XY8_SwpN_2Counter_fixed_v2();
    case 'XY8_SwpN_2Counter_fixed_v2_ctrgatedur_opt'
       XY8_SwpN_2Counter_fixed_v2_ctrgatedur_opt();
    case 'XY8_SwpN_2Counter_fixed_v3'
       XY8_SwpN_2Counter_fixed_v3();
    case 'DROIDN12_fixed_v2'
       DROIDN12_fixed_v2();
    case 'DROIDN12_fixed_ctrgate_opt'
       DROIDN12_fixed_ctrgate_opt();
%     case 'Echo_2Counter_P1mix'
%        Echo_2Counter_P1mix();
%     case 'Echo_2Counter_NoP1mix'
%        Echo_2Counter_NoP1mix();
%     case 'Echo Quadrature Pi'
%         EchoQ();
    case 'ESR'
        ESR();
%     case 'T1'
%         T1();
    case 'ODMR'
        ODMR();
    case 'ODMR_tscan'
        ODMR_tscan();
    case 'ODMR_tscan_noAWG'
        ODMR_tscan_noAWG()
    case 'ODMR_DriveN'
        ODMR_DriveN();
    case 'cool_ODMR'
        cool_ODMR();
    case 'cool_ODMR_Switch2'
        cool_ODMR_Switch2();
    case 'testAWG_ODMR'
        testAWG_ODMR();
%    case 'ODMR_P1MWOn'
%        ODMR_P1MWOn();
%     case 'CPMG-N'
%         CPMGN();
%    case 'T1JC'
%        T1JC();
     case 'PBDictionary'
         varargout{1}=PBDictionary(varargin{2});
%     case 'CtrDur'
%         CtrDur();
    case 'RabiAPDI'
        RabiAPDI();
    case 'RabiAPDI_AWG2'
        RabiAPDI_AWG2();
    case 'Rabi_OptimizeCtrDelay'
        Rabi_OptimizeCtrDelay();
    case 'RabiAWG'
        RabiAWG();
    case 'RabiGaussian'
        RabiGaussian();
    case 'RabiOptimizeCtrGate'
        RabiOptimizeCtrGate();
    case 'OptimizeCtrDelay'
        OptimizeCtrDelay();
%     case 'RabiAPD_P1MWOn'
%         RabiAPD_P1MWOn();
    case 'hBN_polarization'
        hBN_polarization();
    case 'OptDetectWindow'
        OptDetectWindow();
    case 'RabiAPDQ'
        RabiAPDQ();
%     case 'Counter calibration'
%         CtrCal();
%     case 'T1PolarP1'
%         T1PolarP1();
%     case 'T1PolarP1_Pi'
%         T1PolarP1_Pi();
%     case 'T1PolarP1_Linear_varyT'
%         T1PolarP1_Linear_varyT();
%     case 'T1PolarP1_AfterPolarWait'
%         T1PolarP1_AfterPolarWait();
%     case 'T1PolarP1_RotateP1'
%         T1PolarP1_RotateP1();
%     case 'MeasureCounts'
%         MeasureCounts();
    case 'DEER'
        DEER();
    case 'DEER_Rabi'
        DEER_Rabi();
    case 'DEER_Echo'
        DEER_Echo();
    case 'DEER_XY8N'
        DEER_XY8N();
    case 'SpinLocking'
        SpinLocking();
    case 'SpecialCooling'
        SpecialCooling();
%     case 'SpecialCooling_FixN'
%         SpecialCooling_FixN();
%     case 'SpecialCooling2'
%         SpecialCooling2();
%     case 'SpecialCooling2_FixN'
%         SpecialCooling2_FixN();
%     case 'SpecialCooling2_FixN_MeasSeparate'
%         SpecialCooling2_FixN_MeasSeparate();
%     case 'SpecialCooling2_FixN_SpinLockingMeasure'
%         SpecialCooling2_FixN_SpinLockingMeasure();
%     case 'Cooling_SpinLocking'
%         Cooling_SpinLocking();
    case 'NVdensity_SpinLocking'
        NVdensity_SpinLocking();
    case 'NVdensity_SpinLocking_SwpFreq'
        NVdensity_SpinLocking_SwpFreq();
    case 'NVdensity_SpinLocking_SwpPow'
        NVdensity_SpinLocking_SwpPow();
%     case 'Ramsey_FlipP1'
%         Ramsey_FlipP1();
%     case 'Ramsey_FlipP1_SweepP1Pow'
%         Ramsey_FlipP1_SweepP1Pow();
%     case 'T1PolarP1_SpinDiffusion'
%         T1PolarP1_SpinDiffusion();   
    case 'T1PolarP1_SpinDiff_2Counter'
        T1PolarP1_SpinDiff_2Counter();
%     case 'T1PolarP1_SpinDiffusion_SpeedupP1Mix'
%         T1PolarP1_SpinDiffusion_SpeedupP1Mix();
    case 'T1PolarP1_SpinDiffusion_SpeedupP1Mix_LeeGoldBurg'
        T1PolarP1_SpinDiffusion_SpeedupP1Mix_LeeGoldBurg();
    case 'Pulse_ESR'
        Pulse_ESR();
%     case 'T1PolarP1_SpeedupP1Mix'
%         T1PolarP1_SpeedupP1Mix()
    case 'T1PolarP1_SpeedupP1Mix_2Counter'
        T1PolarP1_SpeedupP1Mix_2Counter();
    case 'T1PolarP1_SpeedupP1Mix_2Counter_Plus1'
        T1PolarP1_SpeedupP1Mix_2Counter_Plus1();
    case 'T1PolarP1_SpeedupP1Mix_2Counter_Minus1'
        T1PolarP1_SpeedupP1Mix_2Counter_Minus1();
    case 'T1PolarP1_RotP1_2Counter_Shelve'
        T1PolarP1_RotP1_2Counter_Shelve();
    case 'T1PolarP1_2Counter_Shelve'
        T1PolarP1_2Counter_Shelve();
    case 'SpinDiffuse_2Counter_Shelve'
        SpinDiffuse_2Counter_Shelve();
    case 'SpinDiffuse_2Counter_Shelve_Ramsey'
        SpinDiffuse_2Counter_Shelve_Ramsey();
    case 'SpinDiffuse_2Counter_Shelve_Echo'
        SpinDiffuse_2Counter_Shelve_Echo();
    case 'SpinDiffuse_2Counter_Shelve_FM'
        SpinDiffuse_2Counter_Shelve_FM();
    case 'SpinDiffuse_2Counter_Shelve_FM_SwpN'
        SpinDiffuse_2Counter_Shelve_FM_SwpN();
    case 'SpinDiffuse_2Counter_Shelve_FM_Sym_SwpN'
        SpinDiffuse_2Counter_Shelve_FM_Sym_SwpN();
%     case 'SpinDiffuse_2Counter_Shelve_FM_fxTau'
%         SpinDiffuse_2Counter_Shelve_FM_fxTau();
    case 'SpinDiffuse_2Counter_Shelve_CPMG8_SwpN'
        SpinDiffuse_2Counter_Shelve_CPMG8_SwpN();
%     case 'T1PolarP1_RotP1_2Counter_Plus1'
%         T1PolarP1_RotP1_2Counter_Plus1();
%     case 'T1PolarP1_SpeedupP1Mix_4Counter'
%         T1PolarP1_SpeedupP1Mix_4Counter();
    case 'T1PolarP1_2Counter_2ndMWdrive'
        T1PolarP1_2Counter_2ndMWdrive();
    case 'T1PolarP1_2Counter_2ndMWdrive_SwpFreq'
        T1PolarP1_2Counter_2ndMWdrive_SwpFreq();
    case 'T1PolarP1_2Counter_2ndMWdriveLaser'
        T1PolarP1_2Counter_2ndMWdriveLaser();
    case 'T1Polar_4Counter_FlipOffP1'
        T1Polar_4Counter_FlipOffP1();
    case 'T1PolarP1_4Counter_LaserPow'
        T1PolarP1_4Counter_LaserPow();
    case 'T1Polar_2ndMWDrive_FlipOffP1'
        T1Polar_2ndMWDrive_FlipOffP1();
    case 'T1Polar_2ndMWDriveLaser_FlipOffP1'
        T1Polar_2ndMWDriveLaser_FlipOffP1();
    case 'SpinDiff_shelve_2ndMWdrive'
        SpinDiff_shelve_2ndMWdrive();
    case 'SpinDiff_shelve_2ndMWdrive_after_td'
        SpinDiff_shelve_2ndMWdrive_after_td();
    case 'SpinDiff_shelve_2ndMWdrive_AllON'
        SpinDiff_shelve_2ndMWdrive_AllON();
    case 'SpinDiff_shelve_2ndMWdrive_LateON'
        SpinDiff_shelve_2ndMWdrive_LateON();
    case 'SpinDiff_shelve_2ndMWdrive_AfterLaserON'
        SpinDiff_shelve_2ndMWdrive_AfterLaserON();
%     case 'T1PolarP1_RotP1_2Counter'
%         T1PolarP1_RotP1_2Counter();
%     case 'T1PolarP1_RotP1_2ndMWdrive'
%         T1PolarP1_RotP1_2ndMWdrive();       
    case 'TestCharge_2Counter'
        TestCharge_2Counter();
    case 'T1PolarP1_SpeedupP1Mix_RotateP1'
        T1PolarP1_SpeedupP1Mix_RotateP1();
%     case 'T1PolarP1_FCB_2Counter'
%         T1PolarP1_FCB_2Counter();    
%     case 'T1PolarP1_SpeedupP1Mix_LeeGoldBurg'
%         T1PolarP1_SpeedupP1Mix_LeeGoldBurg();
    case 'RabiAPDI_2ndMW'
        RabiAPDI_2ndMW();
    case 'RabiAPDI_3rdMW'
        RabiAPDI_3rdMW();
    case 'RabiAPDQ_2ndMW'
        RabiAPDQ_2ndMW();
    case 'ODMR_2ndMW'
        ODMR_2ndMW();
    case 'Select Sequence'
        return
        
end

function StrL = PopulateSeq
StrL{1} = 'Select Sequence';
% StrL{numel(StrL)+1}='Rabi';
%StrL{numel(StrL)+1}='Ramsey';
StrL{numel(StrL)+1}='ENDOR_Rabi';
StrL{numel(StrL)+1}='wait_Rabi';
StrL{numel(StrL)+1}='ENDOR_ODMR';
StrL{numel(StrL)+1}='Reference_ODMR';
StrL{numel(StrL)+1}='CW_pulsed_noMW';
StrL{numel(StrL)+1}='CW_pulsed_MW';
StrL{numel(StrL)+1}='CW_pulsed_MWonoff';
StrL{numel(StrL)+1}='pulsed';
StrL{numel(StrL)+1}='pulsed_MW';
StrL{numel(StrL)+1}='pulsed_MWoffon';
StrL{numel(StrL)+1}='pulsed_MWoffon2';
StrL{numel(StrL)+1}='pulsed_MWoffon3';
StrL{numel(StrL)+1}='Reference_timescan';
StrL{numel(StrL)+1}='cool_timescan';
StrL{numel(StrL)+1}='cool_timescan_MWpulse';
StrL{numel(StrL)+1}='cool_timescan_timetagger';
StrL{numel(StrL)+1}='cool_timescan_timetagger_pol';
StrL{numel(StrL)+1}='Ramsey_2Counter';
StrL{numel(StrL)+1}='RamseyAWG_2Counter';
StrL{numel(StrL)+1}='T1AWG_Zero';
StrL{numel(StrL)+1}='T1_Zero';
StrL{numel(StrL)+1}='cool_T1';
StrL{numel(StrL)+1}='DQ_3';
StrL{numel(StrL)+1}='cool_T1_bright';
StrL{numel(StrL)+1}='cool_T1_dark';
StrL{numel(StrL)+1}='cool_T1_3';
StrL{numel(StrL)+1}='Null_Measure';
StrL{numel(StrL)+1}='T1_2AWG';
StrL{numel(StrL)+1}='ODMR';
StrL{numel(StrL)+1}='ODMR_tscan';
StrL{numel(StrL)+1}='ODMR_tscan_noAWG';
StrL{numel(StrL)+1}='ODMR_DriveN';
StrL{numel(StrL)+1}='cool_ODMR';
StrL{numel(StrL)+1}='cool_ODMR_Switch2';
StrL{numel(StrL)+1}='testAWG_ODMR';
% StrL{numel(StrL)+1}='ODMR_P1MWOn';
StrL{numel(StrL)+1}='ESR';
% StrL{numel(StrL)+1}='CPMG-T';
% StrL{numel(StrL)+1}='CPMG-N';
StrL{numel(StrL)+1}='AOM Delay';
StrL{numel(StrL)+1}='Optimize_Ctr';
StrL{numel(StrL)+1}='NV_Polarization';
% StrL{numel(StrL)+1}='Q';
% StrL{numel(StrL)+1}='Echo';
StrL{numel(StrL)+1}='Echo_2Counter';
StrL{numel(StrL)+1}='EchoAWG_2Counter';
StrL{numel(StrL)+1}='XY8_SwpN_2Counter';
StrL{numel(StrL)+1}='XY8_SwpT_2Counter';
StrL{numel(StrL)+1}='XY8_SwpN_2Counter_fixed_v2';
StrL{numel(StrL)+1}='XY8_SwpN_2Counter_fixed_v2_ctrgatedur_opt';
StrL{numel(StrL)+1}='XY8_SwpN_2Counter_fixed_v3';
StrL{numel(StrL)+1}='DROIDN12_fixed_v2';
StrL{numel(StrL)+1}='DROIDN12_fixed_ctrgate_opt';
% StrL{numel(StrL)+1}='Echo_2Counter_P1mix';
% StrL{numel(StrL)+1}='Echo_2Counter_NoP1mix';
% StrL{numel(StrL)+1}='Echo Quadrature Pi';
% StrL{numel(StrL)+1}='T1';
% StrL{numel(StrL)+1}='RabiQ';
% StrL{numel(StrL)+1}='Rabi+ctr2';
% StrL{numel(StrL)+1}='T1JC';
% StrL{numel(StrL)+1}='CtrDur';
StrL{numel(StrL)+1}='RabiAPDI';
StrL{numel(StrL)+1}='RabiAPDI_AWG2';
StrL{numel(StrL)+1}='RabiGaussian';
StrL{numel(StrL)+1}='RabiOptimizeCtrGate';
StrL{numel(StrL)+1}='OptimizeCtrDelay';
StrL{numel(StrL)+1}='RabiAWG';
StrL{numel(StrL)+1}='Rabi_OptimizeCtrDelay';
StrL{numel(StrL)+1}='hBN_polarization';
StrL{numel(StrL)+1}='RabiAPDQ';
StrL{numel(StrL)+1}='OptDetectWindow';
StrL{numel(StrL)+1}='SpinLocking';
StrL{numel(StrL)+1}='SpecialCooling';
% StrL{numel(StrL)+1}='SpecialCooling_FixN';
% StrL{numel(StrL)+1}='SpecialCooling2';
% StrL{numel(StrL)+1}='SpecialCooling2_FixN';
% StrL{numel(StrL)+1}='SpecialCooling2_FixN_MeasSeparate';
% StrL{numel(StrL)+1}='SpecialCooling2_FixN_SpinLockingMeasure';
% StrL{numel(StrL)+1}='Cooling_SpinLocking';
StrL{numel(StrL)+1}='NVdensity_SpinLocking';
StrL{numel(StrL)+1}='NVdensity_SpinLocking_SwpFreq';
StrL{numel(StrL)+1}='NVdensity_SpinLocking_SwpPow';
% StrL{numel(StrL)+1}='RabiAPDIn';
% StrL{numel(StrL)+1}='RabiAPDQn';
% StrL{numel(StrL)+1}='Counter calibration';
% StrL{numel(StrL)+1}='T1PolarP1';
% StrL{numel(StrL)+1}='T1PolarP1_Linear_varyT';
% StrL{numel(StrL)+1}='T1PolarP1_AfterPolarWait';
% StrL{numel(StrL)+1}='T1PolarP1_Pi';
% StrL{numel(StrL)+1}='MeasureCounts';
StrL{numel(StrL)+1}='DEER';
StrL{numel(StrL)+1}='DEER_Rabi';
StrL{numel(StrL)+1}='DEER_Echo';
StrL{numel(StrL)+1}='DEER_XY8N';
StrL{numel(StrL)+1}='Ramsey_FlipP1';
StrL{numel(StrL)+1}='Ramsey_FlipP1_SweepP1Pow';
StrL{numel(StrL)+1}='T1PolarP1_RotateP1';
% StrL{numel(StrL)+1}='T1PolarP1_SpinDiffusion';
StrL{numel(StrL)+1}='T1PolarP1_SpinDiff_2Counter';
StrL{numel(StrL)+1}='T1PolarP1_SpinDiffusion_SpeedupP1Mix';
StrL{numel(StrL)+1}='T1PolarP1_SpinDiffusion_SpeedupP1Mix_LeeGoldBurg';
StrL{numel(StrL)+1}='Pulse_ESR';
% StrL{numel(StrL)+1}='T1PolarP1_SpeedupP1Mix';
StrL{numel(StrL)+1}='T1PolarP1_SpeedupP1Mix_2Counter';
StrL{numel(StrL)+1}='T1PolarP1_SpeedupP1Mix_2Counter_Plus1';
StrL{numel(StrL)+1}='T1PolarP1_SpeedupP1Mix_2Counter_Minus1';
StrL{numel(StrL)+1}='T1PolarP1_RotP1_2Counter_Shelve';
StrL{numel(StrL)+1}='T1PolarP1_2Counter_Shelve';
StrL{numel(StrL)+1}='SpinDiffuse_2Counter_Shelve';
StrL{numel(StrL)+1}='SpinDiffuse_2Counter_Shelve_Ramsey';
StrL{numel(StrL)+1}='SpinDiffuse_2Counter_Shelve_Echo';
StrL{numel(StrL)+1}='SpinDiffuse_2Counter_Shelve_FM';
StrL{numel(StrL)+1}='SpinDiffuse_2Counter_Shelve_FM_SwpN';
StrL{numel(StrL)+1}='SpinDiffuse_2Counter_Shelve_FM_Sym_SwpN';
%StrL{numel(StrL)+1}='SpinDiffuse_2Counter_Shelve_FM_fxTau';
StrL{numel(StrL)+1}='SpinDiffuse_2Counter_Shelve_CPMG8_SwpN';
% StrL{numel(StrL)+1}='T1PolarP1_RotP1_2Counter_Plus1';
% StrL{numel(StrL)+1}='T1PolarP1_SpeedupP1Mix_4Counter';
StrL{numel(StrL)+1}='T1PolarP1_2Counter_2ndMWdrive';
StrL{numel(StrL)+1}='T1PolarP1_2Counter_2ndMWdrive_SwpFreq';
StrL{numel(StrL)+1}='T1PolarP1_2Counter_2ndMWdriveLaser';
StrL{numel(StrL)+1}='T1Polar_4Counter_FlipOffP1';
StrL{numel(StrL)+1}='T1Polar_2ndMWDrive_FlipOffP1';
StrL{numel(StrL)+1}='T1Polar_2ndMWDriveLaser_FlipOffP1';
StrL{numel(StrL)+1}='T1PolarP1_4Counter_LaserPow';
StrL{numel(StrL)+1}='SpinDiff_shelve_2ndMWdrive';
StrL{numel(StrL)+1}='SpinDiff_shelve_2ndMWdrive_after_td';
StrL{numel(StrL)+1}='SpinDiff_shelve_2ndMWdrive_AllON';
StrL{numel(StrL)+1}='SpinDiff_shelve_2ndMWdrive_LateON';
StrL{numel(StrL)+1}='SpinDiff_shelve_2ndMWdrive_AfterLaserON';
% StrL{numel(StrL)+1}='T1PolarP1_RotP1_2Counter';
% StrL{numel(StrL)+1}='T1PolarP1_RotP1_2ndMWdrive';
StrL{numel(StrL)+1}='TestCharge_2Counter';
StrL{numel(StrL)+1}='T1PolarP1_SpeedupP1Mix_RotateP1';
% StrL{numel(StrL)+1}='T1PolarP1_FCB_2Counter';
StrL{numel(StrL)+1}='T1PolarP1_SpeedupP1Mix_LeeGoldBurg';
StrL{numel(StrL)+1}='RabiAPDI_2ndMW';
StrL{numel(StrL)+1}='RabiAPDQ_2ndMW';
StrL{numel(StrL)+1}='ODMR_2ndMW';
StrL{numel(StrL)+1}='RabiAPDI_3rdMW';

function RabiAPDI

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to ''; 'None';%
gSG.bModSrc='External';

gSG2.bOn = 0;
gSG2.bMod='';

AfterPi = 500; %originally 500, preston
AfterLaser = 1000;
  
%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[gmSEQ.readout-gmSEQ.CtrGateDur-1000 gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')||strcmp(gmSEQ.meas,'Scope')
    gmSEQ.CHN(1).DT=[1000 1000];
end
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=gmSEQ.readout+AfterLaser;%% ejd 11/10/2022  gmSEQ.readout+AfterLaser;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=500;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout 3000];

% by zhelun, Jan/17/2023
% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[100];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi+2000];

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+AfterLaser];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200];

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500];

buffer = 100; %200 -> 100 --> 20 --> 50 4/25 WJ
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); %zhelun 2022/11/11
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+AfterLaser-buffer]; %% ejd was -20
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m+2*buffer]; % Temporary use only
% switch to control pulses.
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=gmSEQ.readout+AfterLaser -20;
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=gmSEQ.m + 40;

% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B = [0 gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % gSG.Freq = NV resonang frequeincy, gSG.SGbasefreq = f
    %disp([num2str(gSG.SGbasefreq), ', ', num2str(gSG.Freq), ', ', num2str((gSG.SGbasefreq-gSG.Freq)/1e9)])
    % 2022/11/10 for debugging
    C = [0 gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B = [0 gmSEQ.m 0 pi/2 gSG.IQVoltage1];
    C = [0 gmSEQ.m 0 0 0];
end
    Length2 = gmSEQ.m+1000; % ns
    clkRate2 = 2e9; % 2GHz
    % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
    % 560ns)
    Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
%     chaseFunctionPool('stopChase', 2); pause(0.3);
%     chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
%     chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
%     chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
%     chaseFunctionPool('CreateSingleSegment',2, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
%     % Function name, AWG #, Channel #, Total number of the points of the
%     % sequence, time of the sequence repeat, 
%     chaseFunctionPool('CreateSingleSegment',2, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
%     chaseFunctionPool('runChase', 2, 'false'); pause(0.2);
    %%% FUCK YUANQI
    chaseFunctionPool('stopChase', 1); pause(0.5);
    chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.5);
    chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
    chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
    % Function name, AWG #, Channel #, Total number of the points of the
    % sequence, time of the sequence repeat, 
    chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
    chaseFunctionPool('runChase', 1, 'false'); 
  

ApplyDelays();

function RabiAPDI_AWG2

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG2: signal generator 2
gSG2.bOn = 1; %second SG is not on
gSG2.ACmod = 1;
gSG.bOn = 0; %first SG off, 4/24/23 WJ 

gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq

gSG2.bMod='IQ';% if totally off, change to ''; 'None';%
gSG2.bModSrc='External';

AfterPi = 500; %originally 500, preston
AfterLaser = 1000;
  
%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[gmSEQ.readout-gmSEQ.CtrGateDur-1000 gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')||strcmp(gmSEQ.meas,'Scope')
    gmSEQ.CHN(1).DT=[1000 1000];
end
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG2'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=gmSEQ.readout+AfterLaser;%% ejd 11/10/2022  gmSEQ.readout+AfterLaser;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=500;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout 2000];

buffer = 100;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); %zhelun 2022/11/11
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+AfterLaser-buffer]; %% ejd was -20
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m+2*buffer]; % Temporary use only

% for MW_AWG
if gSG2.ACmod % in AC modulation mode
    B = [0 gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % gSG.Freq = NV resonang frequeincy, gSG.SGbasefreq = f
    C = [0 gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B = [0 gmSEQ.m 0 pi/2 gSG.IQVoltage1];
    C = [0 gmSEQ.m 0 0 0];
end
    Length2 = gmSEQ.m+1000; % ns
    clkRate2 = 2e9; % 2GHz
    % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
    % 560ns)
    Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
    %%% FUCK YUANQI
    chaseFunctionPool('stopChase', 2); pause(0.5);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.5);
    chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
    chaseFunctionPool('CreateSingleSegment',2, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
    % Function name, AWG #, Channel #, Total number of the points of the
    % sequence, time of the sequence repeat, 
    chaseFunctionPool('CreateSingleSegment',2, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
    chaseFunctionPool('runChase', 2, 'false'); 
  

ApplyDelays();

function RabiOptimizeCtrGate

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to '';%FUCK
gSG.bModSrc='External';

gSG2.bOn = 0;
gSG2.bMod = ''; %WL, 10/17/24


AfterPi = 500; %originally 500, preston
AfterLaser = 1000;
  
%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[gmSEQ.readout-gmSEQ.m-1000 gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.m gmSEQ.m];
elseif strcmp(gmSEQ.meas,'APD')||strcmp(gmSEQ.meas,'Scope')
    gmSEQ.CHN(1).DT=[1000 1000];
end
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=gmSEQ.readout+AfterLaser;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=500;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout 10000];

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+AfterLaser];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200];

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500];

buffer = 100; %WL 10/17/24, was 20 ns before
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+AfterLaser-buffer];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+2*buffer]; % FUCK. Temporarily use only
% switch to control pulses.
% gmSEQ.CHN(numel(gmSEQ.CHN)).T= gmSEQ.readout+AfterLaser;
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m];

% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % gSG.Freq = NV resonang frequeincy, gSG.SGbasefreq = f
    C = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C = [0 gmSEQ.pi 0 0 0];
end
    % Length2 = gmSEQ.m+1000; % ns
    Length2 = gmSEQ.pi + 1000; %WL 10/17/24
    clkRate2 = 2e9; % 2GHz
    % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
    % 560ns)
    Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
%     chaseFunctionPool('stopChase', 2); pause(0.3);
%     chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
%     chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
%     chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
%     chaseFunctionPool('CreateSingleSegment',2, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
%     % Function name, AWG #, Channel #, Total number of the points of the
%     % sequence, time of the sequence repeat, 
%     chaseFunctionPool('CreateSingleSegment',2, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
%     chaseFunctionPool('runChase', 2, 'false'); pause(0.2);
    %%% FUCK YUANQI
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
    chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
    % Function name, AWG #, Channel #, Total number of the points of the
    % sequence, time of the sequence repeat, 
    chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
    chaseFunctionPool('runChase', 1, 'false'); pause(0.2);
  

ApplyDelays();

function RabiGaussian

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to '';%FUCK
gSG.bModSrc='External';

gSG2.bOn = 0;

pulsesigma = ceil(gmSEQ.pi*0.4); %equivalent area as a rectangular pulse
AfterPi = 500; %originally 500, preston
AfterLaser = 1000;
  
%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[gmSEQ.readout-gmSEQ.CtrGateDur-1000 gmSEQ.readout+AfterLaser+pulsesigma*12+AfterPi];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')||strcmp(gmSEQ.meas,'Scope')
    gmSEQ.CHN(1).DT=[1000 1000];
end
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=gmSEQ.readout+AfterLaser;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=200;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+AfterLaser+pulsesigma*12+AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout 2000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+AfterLaser-20-pulsesigma*2];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[pulsesigma*5+60]; % FUCK. Temporarily use only
% switch to control pulses.


% should go in with 6 arguments as center, sigma, cutoff, sine-freq, sine-phase, ampl.

% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B = [0 pulsesigma 3 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gmSEQ.m]; % gSG.Freq = NV resonance frequeincy, gSG.SGbasefreq = f
    C = [0 pulsesigma 3 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gmSEQ.m];
else
    B = [0 pulsesigma 3 0 pi/2 gmSEQ.m];
    C = [0 pulsesigma 3 0 0 0];
end
    Length2 = pulsesigma*10+150; % ns
    clkRate2 = 2e9; % 2GHz
    % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
    % 560ns)
    Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"

    %%% FUCK YUANQI
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
    chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
    % Function name, AWG #, Channel #, Total number of the points of the
    % sequence, time of the sequence repeat, 
    chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
    chaseFunctionPool('runChase', 1, 'false'); pause(0.2);
  

ApplyDelays();

function RabiAWG

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to '';%FUCK
gSG.bModSrc='External';

gSG2.bOn = 0;


AfterPi = 500; %originally 500, preston
AfterLaser = 1000;
  
%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[gmSEQ.readout-gmSEQ.CtrGateDur-1000 gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')||strcmp(gmSEQ.meas,'Scope')
    gmSEQ.CHN(1).DT=[1000 1000];
end
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=gmSEQ.readout+AfterLaser;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=500;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout 2000];

    B = [0 gmSEQ.m gSG.Freq/1e9 0 gSG.IQVoltage1]; % gSG.Freq = NV resonang frequeincy, gSG.SGbasefreq = f
    C = [0 gmSEQ.m gSG.Freq/1e9 pi/2 gSG.IQVoltage1];

    Length2 = gmSEQ.m+1000; % ns
    clkRate2 = 2e9; % 2GHz
    % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
    % 560ns)
    Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
    chaseFunctionPool('stopChase', 1); pause(0.1);
    chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.1);
    chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.1);
    chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.1);
    chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
    % Function name, AWG #, Channel #, Total number of the points of the
    % sequence, time of the sequence repeat, 
    chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
    chaseFunctionPool('runChase', 1, 'false'); pause(0.1);
  

ApplyDelays();

function OptimizeCtrDelay
global gmSEQ gSG gSG2
gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq
gSG.bMod='IQ';% if totally off, change to '';%FUCK
gSG.bModSrc='External';

gSG2.bOn = 0;

length = 10000;

gmSEQ.CHN(1).PBN=PBDictionary('dummy');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[0 length];
gmSEQ.CHN(1).DT=[50 50];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=length/2;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=1500;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=length/2+round(gmSEQ.m);
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=500;

if gSG.first
    B = [0 1000 0.2 0 gSG.IQVoltage1];
    C = [0 100 0 0 0];
    
    Length2 = 1200;
    clkRate2 = 2e9;
    % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
    % 560ns)
    Total2 = ceil(Length2*clkRate2/1e9/16)*16;
    chaseFunctionPool('stopChase', 1); pause(0.3); % changed from 2 AWG to 1
    chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt');
    chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt');
    chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
    chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
    chaseFunctionPool('runChase', 1, 'false'); pause(0.2);
    
    disp('I am Uploading!')

end


ApplyDelays();

function Rabi_OptimizeCtrDelay

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to '';%FUCK
gSG.bModSrc='External';

gSG2.bOn = 0;

AfterPi = 500; %originally 500, preston
AfterLaser = 1000;

withDrive = 0;
  
%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[gmSEQ.readout-gmSEQ.CtrGateDur-1000 gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi+gmSEQ.m];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')||strcmp(gmSEQ.meas,'Scope')
    gmSEQ.CHN(1).DT=[1000 1000];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout 2000];

disp('hi3');

if withDrive
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=gmSEQ.readout+AfterLaser;
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=500;

    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+AfterLaser-20]; %buffer 20 --> 100; WL 12/18/24
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m+40]; % FUCK. Temporarily use only


    try
        if gSG.first
            % for MW_AWG
            if gSG.ACmod % in AC modulation mode
                B = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % gSG.Freq = NV resonang frequeincy, gSG.SGbasefreq = f
                C = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
            else
                B = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
                C = [0 gmSEQ.pi 0 0 0];
            end
                Length2 = gmSEQ.m+1000; % ns
                clkRate2 = 2e9; % 2GHz
                % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
                % 560ns)
                Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
                chaseFunctionPool('stopChase', 1); pause(0.3);
                chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
                chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
                chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
                chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
                % Function name, AWG #, Channel #, Total number of the points of the
                % sequence, time of the sequence repeat, 
                chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
                chaseFunctionPool('runChase', 1, 'false'); pause(0.2);
        end
    catch
        disp('oops!')
    end
end

  

ApplyDelays();

function T1AWG_Zero

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod = '';

gSG2.bOn = 0;


AfterPi = 500; %originally 500, preston
BetweenSequence = 1000;
ReadoutLength = 2000;
Pulse2Start = BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+BetweenSequence;

%gmSEQ.To is the "To" value in the "From to To" section of the GUI
%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T=[BetweenSequence+gmSEQ.readout-gmSEQ.CtrGateDur-1000 BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi Pulse2Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000 Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi];
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
% Pi pulse after 
gmSEQ.CHN(numel(gmSEQ.CHN)).T=Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=500;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi Pulse2Start Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout ReadoutLength gmSEQ.readout ReadoutLength];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[100 100];

    
try
    if gSG.first
        disp('UPLLOADING TO AWG,,,,...')
        B = [0 gmSEQ.pi gSG.Freq/1e9 0 gSG.IQVoltage1]; % gSG.Freq = NV resonance frequeincy, gSG.SGbasefreq = f

        Length2 = gmSEQ.pi+1000; % ns
        clkRate2 = 2e9; % 2GHz
        % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
        % 560ns)
        Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
        chaseFunctionPool('stopChase', 1); pause(0.1);
        chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.1);
        chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.1);
        chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
        % Function name, AWG #, Channel #, Total number of the points of the
        % sequence, time of the sequence repeat, 
        chaseFunctionPool('runChase', 1, 'false'); pause(0.1);
    end
catch
    disp('oops!')
end
  

ApplyDelays();

function T1_Zero

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to '';%FUCK
gSG.bModSrc='External';

gSG2.bOn = 0;


AfterPi = 500; %originally 500, preston
BetweenSequence = 1000;
ReadoutLength = 2000;
Pulse2Start = BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+BetweenSequence;

%gmSEQ.To is the "To" value in the "From to To" section of the GUI
%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T=[BetweenSequence+gmSEQ.readout-gmSEQ.CtrGateDur-1000 BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi Pulse2Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000 Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi]; % 11/10/2022 Added
% gmSEQ.CHN(1).T=[BetweenSequence+gmSEQ.readout-gmSEQ.CtrGateDur-1000 BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi+20 Pulse2Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000 Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+23]; % 11/10/2022 Added
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
% Pi pulse after 
gmSEQ.CHN(numel(gmSEQ.CHN)).T=Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi; % ejd added + 1200 11/10/2022 % removed 11/10/2022
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=gmSEQ.pi + 1000;

bufferTime = 20;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); % MW switch on
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
% Pi pulse after 
gmSEQ.CHN(numel(gmSEQ.CHN)).T=Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime; % -40 to -3000 11/10/2022
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=gmSEQ.pi + 2*bufferTime;% +0 to +6000 11/10/2022

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi Pulse2Start Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi]; % 11/10/2022 Added
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi Pulse2Start Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+10]; % 11/10/2022 Added
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout ReadoutLength gmSEQ.readout ReadoutLength];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+30];
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+30];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[100 100];

% 11/10/2022 Added for debugging
% test1 = horzcat(gmSEQ.CHN(1).T,gmSEQ.CHN(1).T+gmSEQ.CHN(1).DT);
% test2 = horzcat(gmSEQ.CHN(2).T,gmSEQ.CHN(2).T+gmSEQ.CHN(2).DT);
% test3 = horzcat(gmSEQ.CHN(3).T,gmSEQ.CHN(3).T+gmSEQ.CHN(3).DT);
% test4 = horzcat(gmSEQ.CHN(4).T,gmSEQ.CHN(4).T+gmSEQ.CHN(4).DT);
% test5 = horzcat(gmSEQ.CHN(5).T,gmSEQ.CHN(5).T+gmSEQ.CHN(5).DT);
% test = horzcat(test1,test2,test3,test4,test5);
% disp(gmSEQ.CHN(1))
% disp(gmSEQ.CHN(2))
% disp(gmSEQ.CHN(3))
% disp(gmSEQ.CHN(4))
% disp(gmSEQ.CHN(5))
% disp(sort(test))
% 
% disp('Over')

try
    if gSG.first
        disp('UPLLOADING TO AWG!')
        
        if gSG.ACmod % in AC modulation mode
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % X pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1] 
        else
            C_1 = [0 gmSEQ.pi 0 0 gSG.IQVoltage1] % gSG.Freq = NV resonance frequeincy, gSG.SGbasefreq = f
            C_2 = [0 gmSEQ.pi 0 0+pi/2 0]
        end

        Length2 = gmSEQ.pi+1000; % ns
        clkRate2 = 2e9; % 2GHz
        % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
        % 560ns)
        Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
        chaseFunctionPool('stopChase', 1); pause(0.1);
        chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.1);
        chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.1);
        chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.1);
        chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
        chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
        % Function name, AWG #, Channel #, Total number of the points of the
        % sequence, time of the sequence repeat, 
        chaseFunctionPool('runChase', 1, 'false'); pause(0.1);
        
     
    end
catch
    disp('oops!')
end
ApplyDelays();

function cool_T1

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to '';%FUCK
gSG.bModSrc='External';

gSG2.bOn = 0;

AfterPi = 55; %originally 500, ejd
BetweenSequence = 1000;
ReadoutLength = 2000;
Pulse2Start = BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+BetweenSequence;

%gmSEQ.To is the "To" value in the "From to To" section of the GUI
%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=4;

ctrOffset = -200;
gmSEQ.CHN(1).T=[BetweenSequence+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi-1000,...
    Pulse2Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi-1000]; % 11/10/2022 Added
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur]; 

triglen = 35;

PIoffset = 0;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
%%% ejd edit start 11/15/22
if gmSEQ.m < 525
    offset = 10;
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; %ejd changed from 3 to 2
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi, Pulse2Start+gmSEQ.readout-gmSEQ.pi-1000];%, Pulse2Start+gmSEQ.m+gmSEQ.readout-gmSEQ.pi-0-triglen];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+triglen, gmSEQ.pi+triglen];
else
    offset = 10;
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi, Pulse2Start+gmSEQ.readout-gmSEQ.pi-1000, Pulse2Start+gmSEQ.m+gmSEQ.readout-gmSEQ.pi-1000];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+triglen, gmSEQ.pi+triglen, gmSEQ.pi+triglen];
end

bufferTime = 40;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); % MW switch on

if gmSEQ.m < 200
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi-bufferTime, Pulse2Start+gmSEQ.readout-1000-gmSEQ.pi-bufferTime+PIoffset];%, Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime-0];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi + 2*bufferTime, 2*gmSEQ.pi + 2*bufferTime + gmSEQ.m + 100];%, gmSEQ.pi + 2*bufferTime];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;    
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi-bufferTime, Pulse2Start+gmSEQ.readout-1000-gmSEQ.pi-bufferTime, Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime-1000];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength-BetweenSequence];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+30];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[100 100];

try
    if true %gSG.first
        disp('UPLLOADING TO AWG!')
        disp(gmSEQ.m)
        %[start, end, Freq, phase, Amp]
        
        if gSG.ACmod % in AC modulation mode
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 1st X pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];

            if gmSEQ.m < 525
                D_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
                    gmSEQ.m+gmSEQ.pi gmSEQ.m+2*gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 2nd and 3rd X pulse
                D_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
                    gmSEQ.m+gmSEQ.pi gmSEQ.m+2*gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
                Length2 = gmSEQ.pi+150; % original +1000 ns
                clkRate2 = 2e9; % 2GHz
                Length3 = gmSEQ.pi+gmSEQ.m+150; % original +1000 ns
                Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
                Total3 = ceil(Length3*clkRate2/1e9/16)*16; % total number of points need "16x integer"
                chaseFunctionPool('stopChase', 1); pause(0.1);
                chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.1);
                chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length3, 'wave_AWG2_ch3.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length3, 'wave_AWG2_ch4.txt'); pause(0.3);
                chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', ...
                 'wave_AWG2_ch1.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch3.txt', Total3, 1, 1); % I port, C1 and D1
                pause(0.5);
                chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt',...
                'wave_AWG2_ch2.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch4.txt', Total3, 1, 1); % Q port, C2 and D2
                pause(0.5);

                chaseFunctionPool('CreateSegments', 1, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false'); pause(1);
                chaseFunctionPool('CreateSegments', 1, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false'); pause(1);
                chaseFunctionPool('runChase', 1, 'false');
                
            else
                D_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 2nd X pulse
                D_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];

                E_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 3rd X pulse
                E_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];  
                Length2 = gmSEQ.pi+150; % original +1000 ns
                clkRate2 = 2e9; % 2GHz
                Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
                chaseFunctionPool('stopChase', 1); pause(0.1);
                chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.1);
                chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2, 'wave_AWG2_ch3.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2, 'wave_AWG2_ch4.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', E_1, clkRate2/10^9, Length2, 'wave_AWG2_ch5.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', E_2, clkRate2/10^9, Length2, 'wave_AWG2_ch6.txt'); pause(0.3);
                chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', ...
                 'wave_AWG2_ch1.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch3.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch5.txt', Total2, 1, 1); % I port, C1 and D1
                pause(0.5);
                chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt',...
                'wave_AWG2_ch2.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch4.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch6.txt', Total2, 1, 1); % Q port, C2 and D2
                pause(0.5);

                chaseFunctionPool('CreateSegments', 1, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false'); pause(1);
                chaseFunctionPool('CreateSegments', 1, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false'); pause(1);
                chaseFunctionPool('runChase', 1, 'false');
            end
        
        else
            C_1 = [0 gmSEQ.pi 0 0 gSG.IQVoltage1] % gSG.Freq = NV resonance frequeincy, gSG.SGbasefreq = f
            C_2 = [0 gmSEQ.pi 0 0+pi/2 0]
                                               
            D_1 = [0 gmSEQ.pi 0 0 gSG.IQVoltage1] % gSG.Freq = NV resonance frequeincy, gSG.SGbasefreq = f
            D_2 = [0 gmSEQ.pi 0 0+pi/2 0]
            
            E_1 = [0 gmSEQ.pi 0 0 gSG.IQVoltage1] % gSG.Freq = NV resonance frequeincy, gSG.SGbasefreq = f
            E_2 = [0 gmSEQ.pi 0 0+pi/2 0]
            warning('need AC modulation, stop !');
        end
    end
catch
    disp('oops!')
end
ApplyDelays();

function cool_T1_bright

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to ''
gSG.bModSrc='External';

gSG2.bOn = 0;

AfterPi = 55; %originally 500, ejd
BetweenSequence = 1000; %1000 => 3000, WJ 3/7/24
ReadoutLength = 2000;
ctrOffset = -200;
triglen = 35;
offset = 10;
bufferTime = 40;

%gmSEQ.To is the "To" value in the "From to To" section of the GUI
%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[BetweenSequence+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi-1000]; % 11/10/2022 Added
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur]; 

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength-BetweenSequence];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+30];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[100 100];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); % MW switch on
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi-bufferTime;%, Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime-0];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.pi + 2*bufferTime; 

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1; 
gmSEQ.CHN(numel(gmSEQ.CHN)).T= offset + BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.pi+triglen;

try
    if gSG.first
        disp('UPLLOADING TO AWG!')
        
        if gSG.ACmod % in AC modulation mode
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % X pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1]; 
        else
            C_1 = [0 gmSEQ.pi 0 0 gSG.IQVoltage1]; % gSG.Freq = NV resonance frequeincy, gSG.SGbasefreq = f
            C_2 = [0 gmSEQ.pi 0 0+pi/2 0];
        end

        Length2 = gmSEQ.pi+150; %+150 ns
        clkRate2 = 2e9; % 2GHz
        % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
        % 560ns)
        Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
        chaseFunctionPool('stopChase', 1); pause(0.1);
        chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.1);
        chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.1);
        chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.1);
        chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
        chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
        % Function name, AWG #, Channel #, Total number of the points of the
        % sequence, time of the sequence repeat, 
        chaseFunctionPool('runChase', 1, 'false'); pause(0.1);
        
     
    end
catch
    disp('oops!')
end

ApplyDelays();

function cool_T1_dark

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to '';%FUCK
gSG.bModSrc='External';

gSG2.bOn = 0;

AfterPi = 55; %originally 500, ejd
BetweenSequence = 1000;
ReadoutLength = 2000;
Pulse2Start = BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+BetweenSequence;

%gmSEQ.To is the "To" value in the "From to To" section of the GUI
%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=4;

ctrOffset = -200;
gmSEQ.CHN(1).T=[BetweenSequence+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi-1000,...
    Pulse2Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi-1000]; % 11/10/2022 Added
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur]; 

triglen = 35;

PIoffset = 0;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
%%% ejd edit start 11/15/22
if gmSEQ.m < 525
    offset = 10;
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; %ejd changed from 3 to 2
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi, Pulse2Start+gmSEQ.readout-gmSEQ.pi-1000];%, Pulse2Start+gmSEQ.m+gmSEQ.readout-gmSEQ.pi-0-triglen];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+triglen, gmSEQ.pi+triglen];
else
    offset = 10;
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
    %gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi, Pulse2Start+gmSEQ.readout-gmSEQ.pi-1000, Pulse2Start+gmSEQ.m+gmSEQ.readout-gmSEQ.pi-1000];
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi+gmSEQ.m, BetweenSequence+gmSEQ.readout-gmSEQ.pi-1000, Pulse2Start+gmSEQ.readout-gmSEQ.pi-1000];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+triglen, gmSEQ.pi+triglen, gmSEQ.pi+triglen];
end

bufferTime = 40;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); % MW switch on

if gmSEQ.m < 200
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi-bufferTime, Pulse2Start+gmSEQ.readout-1000-gmSEQ.pi-bufferTime];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[2*gmSEQ.pi + 2*bufferTime + gmSEQ.m + 100 ,gmSEQ.pi + 2*bufferTime];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;    
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi-bufferTime, BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi-bufferTime+gmSEQ.m, Pulse2Start+gmSEQ.readout-gmSEQ.pi-bufferTime-1000];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength-BetweenSequence];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+30];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[100 100];

try
    if true %gSG.first
        disp('UPLLOADING TO AWG!')
        disp(gmSEQ.m)
        %[start, end, Freq, phase, Amp]
        
        if gSG.ACmod % in AC modulation mode
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 1st X pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];

            if gmSEQ.m < 525
                D_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
                    gmSEQ.m+gmSEQ.pi gmSEQ.m+2*gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 2nd and 3rd X pulse
                D_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
                    gmSEQ.m+gmSEQ.pi gmSEQ.m+2*gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
                Length2 = gmSEQ.pi+150; % original +1000 ns
                clkRate2 = 2e9; % 2GHz
                Length3 = gmSEQ.pi+gmSEQ.m+150; % original +1000 ns
                Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
                Total3 = ceil(Length3*clkRate2/1e9/16)*16; % total number of points need "16x integer"
                chaseFunctionPool('stopChase', 1); pause(0.1);
                chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.1);
                chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length3, 'wave_AWG2_ch1.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length3, 'wave_AWG2_ch2.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch3.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch4.txt'); pause(0.3);
                chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', ...
                 'wave_AWG2_ch1.txt', Total3, 1, 1, ...
                 'wave_AWG2_ch3.txt', Total2, 1, 1); % I port, C1 and D1
                pause(0.5);
                chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt',...
                'wave_AWG2_ch2.txt', Total3, 1, 1, ...
                 'wave_AWG2_ch4.txt', Total2, 1, 1); % Q port, C2 and D2
                pause(0.5);

                chaseFunctionPool('CreateSegments', 1, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false'); pause(1);
                chaseFunctionPool('CreateSegments', 1, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false'); pause(1);
                chaseFunctionPool('runChase', 1, 'false');
                
            else
                D_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 2nd X pulse
                D_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];

                E_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 3rd X pulse
                E_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];  
                Length2 = gmSEQ.pi+150; % original +1000 ns
                clkRate2 = 2e9; % 2GHz
                Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
                chaseFunctionPool('stopChase', 1); pause(0.1);
                chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.1);
                chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2, 'wave_AWG2_ch3.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2, 'wave_AWG2_ch4.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', E_1, clkRate2/10^9, Length2, 'wave_AWG2_ch5.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', E_2, clkRate2/10^9, Length2, 'wave_AWG2_ch6.txt'); pause(0.3);
                chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', ...
                 'wave_AWG2_ch1.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch3.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch5.txt', Total2, 1, 1); % I port, C1 and D1
                pause(0.5);
                chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt',...
                'wave_AWG2_ch2.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch4.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch6.txt', Total2, 1, 1); % Q port, C2 and D2
                pause(0.5);

                chaseFunctionPool('CreateSegments', 1, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false'); pause(1);
                chaseFunctionPool('CreateSegments', 1, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false'); pause(1);
                chaseFunctionPool('runChase', 1, 'false');
            end
        
        else
            warning('need AC modulation, stop !');
        end
    end
catch
    disp('oops!')
end
ApplyDelays();

function cool_T1_3

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to ''
gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq

gSG2.bMod='IQ';
gSG2.bModSrc='External';

AfterPi = 55; %originally 500, ejd
BetweenSequence = 1000;
ReadoutLength = 2000;
Pulse2Start = BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+BetweenSequence;
Pulse3Start = Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+BetweenSequence;

%gmSEQ.To is the "To" value in the "From to To" section of the GUI
%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=6;

ctrOffset = -200;
gmSEQ.CHN(1).T=[BetweenSequence+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi-1000,...
    Pulse2Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi-985,...
    Pulse3Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, Pulse3Start+gmSEQ.readout+gmSEQ.m+AfterPi-985];
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur]; %4/26/23 WJ: -990 --> -1000 for 4rd, 6th pulses

triglen = 35;

PIoffset = 0;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
%%% ejd edit start 11/15/22
if gmSEQ.m < 525
    offset = 10;
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; 
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi,...
        Pulse2Start+gmSEQ.readout-gmSEQ.pi-1000,...
        Pulse3Start+gmSEQ.readout-gmSEQ.pi-1000];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+triglen, gmSEQ.pi+triglen, gmSEQ.pi+triglen];
else
    offset = 10;
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi,...
        Pulse2Start+gmSEQ.readout-gmSEQ.pi-1000, Pulse2Start+gmSEQ.m+gmSEQ.readout-gmSEQ.pi-990,...
        Pulse3Start+gmSEQ.readout-gmSEQ.pi-1000]; %3rd T -1000-> -990 4/29/23, WJ
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+triglen, gmSEQ.pi+triglen, gmSEQ.pi+triglen, gmSEQ.pi+triglen];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG2'); % AWG2 pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1; 
gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [Pulse3Start+gmSEQ.readout-gmSEQ.pi-1000]; %ejd1 6.6.23 -1000
% if gmSEQ.m < 525
%     gmSEQ.CHN(numel(gmSEQ.CHN)).T=Pulse3Start+gmSEQ.readout-gmSEQ.pi-1000%gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [Pulse3Start+gmSEQ.readout-gmSEQ.pi-1020]; %ejd 6.6.23 -1000 --> -1020
% else
%     gmSEQ.CHN(numel(gmSEQ.CHN)).T=Pulse3Start+gmSEQ.readout-gmSEQ.pi-1000%gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [Pulse3Start+gmSEQ.readout-gmSEQ.pi-1320]; %ejd 6.6.23 -1000 --> -1320
% end
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+triglen];

bufferTime = 40; % original 40 --> 50 5/4/23/WJ
bufferTime2 = 40; %50 --> 40 --> 50 4/28/23 WJ

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); % MW switch on

if gmSEQ.m < 200
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi-bufferTime,...
        Pulse2Start+gmSEQ.readout-1000-gmSEQ.pi-bufferTime,...
        Pulse3Start+gmSEQ.readout-1000-gmSEQ.pi-bufferTime];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi + 2*bufferTime, 2*gmSEQ.pi + 2*bufferTime + gmSEQ.m + 100, 2*gmSEQ.pi + 2*bufferTime + gmSEQ.m + 100];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=5;    
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi-bufferTime,...
        Pulse2Start+gmSEQ.readout-1000-gmSEQ.pi-bufferTime, Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime-990,...
        Pulse3Start+gmSEQ.readout-1000-gmSEQ.pi-bufferTime, Pulse3Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime2-990]; %WJ, 4/29/23 3rd, 5th time -1000 -> -990 due to disagreement of the buffer time
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime2]; % change last 2* to 4*, Jan/18/2023 by zzl  % change last buffer time 2-> buffer time 4/28/23 WJ
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[Pulse3Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength-BetweenSequence];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Pulse3Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+30];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[100 100];

%WJ 04/27/23; duplicate ctr0 for monitoring
% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6;
% 
% ctrOffset = -200;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi-1000,...
%     Pulse2Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi-985,...
%     Pulse3Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, Pulse3Start+gmSEQ.readout+gmSEQ.m+AfterPi-985];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur]; 

AWG2delay=-2; %5-->0 4/20/23 WJ 

try
    if true %gSG.first
        disp('UPLLOADING TO AWG!')
        disp(gmSEQ.m)
        %[start, end, Freq, phase, Amp]
        
        if gSG.ACmod % in AC modulation mode
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 1st X pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
            
            F_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 4th X pulse
            F_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
            
            G_1 = [0 0+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 0;...
                gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage2]; % 5th +1 X pulse, with 1st pulse being 0 amplitude
            G_2 = [0 0+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 0;...
                gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage2];  

          % ejd 6.6.23
%             G_1 = [0 0+gmSEQ.pi-AWG2delay+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 0;...
%                 0+gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage2]; % 5th +1 X pulse, with 1st pulse being 0 amplitude
%             G_2 = [0 0+gmSEQ.pi-AWG2delay+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 0;...
%                 0+gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage2];  

%2nd entry gmSEQ.m --> gmSEQ.pi-AWG2delay+gmSEQ.m 4/20/23 WJ
%             G_1 = [0 gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 0;... 
%                 0+gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage2]; % 5th +1 X pulse, with 1st pulse being 0 amplitude
%             G_2 = [0 gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 0;...
%                 0+gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage2];
            
            
            if gmSEQ.m < 525
                D_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
                    gmSEQ.m+gmSEQ.pi gmSEQ.m+2*gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 2nd and 3rd X pulse
                D_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
                    gmSEQ.m+gmSEQ.pi gmSEQ.m+2*gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
                Length2 = gmSEQ.pi+150; % original +1000 ns
                clkRate2 = 2e9; % 2GHz
                Length3 = gmSEQ.pi+gmSEQ.m+150; % original +1000 ns
                Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
                Total3 = ceil(Length3*clkRate2/1e9/16)*16; % total number of points need "16x integer"
                chaseFunctionPool('stopChase', 1); pause(0.1);
                chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.1);
                chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length3, 'wave_AWG2_ch3.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length3, 'wave_AWG2_ch4.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', F_1, clkRate2/10^9, Length2, 'wave_AWG2_ch7.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', F_2, clkRate2/10^9, Length2, 'wave_AWG2_ch8.txt'); pause(0.3);
                chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', ...
                 'wave_AWG2_ch1.txt', Total2, 1, 1,...
                 'wave_AWG2_ch3.txt', Total3, 1, 1,...
                 'wave_AWG2_ch7.txt', Total2, 1, 1); % I port, C1 and D1 and F1
                pause(0.5);
                chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt',...
                 'wave_AWG2_ch2.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch4.txt', Total3, 1, 1,...
                 'wave_AWG2_ch8.txt', Total2, 1, 1); % Q port, C2 and D2 and F2
                pause(0.5);
                chaseFunctionPool('CreateSegments', 1, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false'); pause(1);
                chaseFunctionPool('CreateSegments', 1, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false'); pause(1);
                chaseFunctionPool('runChase', 1, 'false');
                
                chaseFunctionPool('stopChase', 2); pause(0.5);
                chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.5);
                chaseFunctionPool('createWaveform', G_1, clkRate2/10^9, Length3, 'wave_AWG2_ch9.txt'); pause(0.5);
                chaseFunctionPool('createWaveform', G_2, clkRate2/10^9, Length3, 'wave_AWG2_ch10.txt'); pause(0.5);
                chaseFunctionPool('CreateSingleSegment',2, 1, Total3, 1, 2047, 2047, 'wave_AWG2_ch9.txt', 1); pause(0.5);
                chaseFunctionPool('CreateSingleSegment',2, 2, Total3, 1, 2047, 2047, 'wave_AWG2_ch10.txt', 1); pause(0.5);
                chaseFunctionPool('runChase', 2, 'false');
                
            else
                D_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 2nd X pulse
                D_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];

                E_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 3rd X pulse
                E_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];  
                Length2 = gmSEQ.pi+150; % original +1000 ns
                clkRate2 = 2e9; % 2GHz
                Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
                Length3 = gmSEQ.pi+gmSEQ.m+150; % original +1000 ns
                Total3 = ceil(Length3*clkRate2/1e9/16)*16; % total number of points need "16x integer"
                chaseFunctionPool('stopChase', 1); pause(0.1);
                chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.1);
                chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2, 'wave_AWG2_ch3.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2, 'wave_AWG2_ch4.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', E_1, clkRate2/10^9, Length2, 'wave_AWG2_ch5.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', E_2, clkRate2/10^9, Length2, 'wave_AWG2_ch6.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', F_1, clkRate2/10^9, Length2, 'wave_AWG2_ch7.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', F_2, clkRate2/10^9, Length2, 'wave_AWG2_ch8.txt'); pause(0.3);
                chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', ...
                 'wave_AWG2_ch1.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch3.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch5.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch7.txt', Total2, 1, 1); % I port, C1 and D1 and E1 and F1
                pause(0.5);
                chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt',...
                 'wave_AWG2_ch2.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch4.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch6.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch8.txt', Total2, 1, 1); % Q port, C2 and D2 and E2 and F2
                pause(0.5);
                chaseFunctionPool('CreateSegments', 1, 1, 4, 2047, 2047, 'SegStruct_ch1.txt', 'false'); pause(1);
                chaseFunctionPool('CreateSegments', 1, 2, 4, 2047, 2047, 'SegStruct_ch2.txt', 'false'); pause(1);
                chaseFunctionPool('runChase', 1, 'false');
                
                chaseFunctionPool('stopChase', 2); pause(0.5);
                chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.5);
                chaseFunctionPool('createWaveform', G_1, clkRate2/10^9, Length3, 'wave_AWG2_ch9.txt'); pause(0.5);
                chaseFunctionPool('createWaveform', G_2, clkRate2/10^9, Length3, 'wave_AWG2_ch10.txt'); pause(0.5);
                chaseFunctionPool('CreateSingleSegment',2, 1, Total3, 1, 2047, 2047, 'wave_AWG2_ch9.txt', 1); pause(0.5);
                chaseFunctionPool('CreateSingleSegment',2, 2, Total3, 1, 2047, 2047, 'wave_AWG2_ch10.txt', 1); pause(0.5);
                chaseFunctionPool('runChase', 2, 'false');
            end
        
        else
            warning('need AC modulation, stop !');
        end
    end
catch
    disp('oops!')
end
ApplyDelays();

function DQ_3

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to ''
gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq

gSG2.bMod='IQ';
gSG2.bModSrc='External';

AfterPi = 500; %originally 500, ejd
BetweenSequence = 1000;
ReadoutLength = 2000;
%Pulse1Start = BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+BetweenSequence;
Pulse2Start = BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+BetweenSequence;
Pulse3Start = Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+BetweenSequence;

%gmSEQ.To is the "To" value in the "From to To" section of the GUI
%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=6;

ctrOffset = 0;
gmSEQ.CHN(1).T=[BetweenSequence+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi+15,...
    Pulse2Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+15,...
    Pulse3Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, Pulse3Start+gmSEQ.readout+gmSEQ.m+AfterPi+15];
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur]; %4/26/23 WJ: -990 --> -1000 for 4rd, 6th pulses

triglen = 35;

PIoffset = 0;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
%%% ejd edit start 11/15/22
if gmSEQ.m < 525
    offset = 10;
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; 
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [BetweenSequence+gmSEQ.m+gmSEQ.readout-gmSEQ.pi,...
        Pulse2Start+gmSEQ.readout-gmSEQ.pi,...
        Pulse3Start+gmSEQ.readout-gmSEQ.pi];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+triglen, gmSEQ.pi+triglen, gmSEQ.pi+triglen];
else
    offset = 10;
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [BetweenSequence+gmSEQ.m+gmSEQ.readout-gmSEQ.pi,...
        Pulse2Start+gmSEQ.readout-gmSEQ.pi, Pulse2Start+gmSEQ.m+gmSEQ.readout-gmSEQ.pi,...
        Pulse3Start+gmSEQ.readout-gmSEQ.pi]; %3rd T -1000-> -990 4/29/23, WJ
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+triglen, gmSEQ.pi+triglen, gmSEQ.pi+triglen, gmSEQ.pi+triglen];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG2'); % AWG2 pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1; 
gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [Pulse3Start+gmSEQ.readout-gmSEQ.pi]; %ejd1 6.6.23 -1000
% if gmSEQ.m < 525
%     gmSEQ.CHN(numel(gmSEQ.CHN)).T=Pulse3Start+gmSEQ.readout-gmSEQ.pi-1000%gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [Pulse3Start+gmSEQ.readout-gmSEQ.pi-1020]; %ejd 6.6.23 -1000 --> -1020
% else
%     gmSEQ.CHN(numel(gmSEQ.CHN)).T=Pulse3Start+gmSEQ.readout-gmSEQ.pi-1000%gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [Pulse3Start+gmSEQ.readout-gmSEQ.pi-1320]; %ejd 6.6.23 -1000 --> -1320
% end
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+triglen];

bufferTime = 40; % original 40 --> 50 5/4/23/WJ
bufferTime2 = 40; %50 --> 40 --> 50 4/28/23 WJ

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); % MW switch on

if gmSEQ.m < 200
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime,...
        Pulse2Start+gmSEQ.readout-gmSEQ.pi-bufferTime,...
        Pulse3Start+gmSEQ.readout-gmSEQ.pi-bufferTime];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi + 2*bufferTime, 2*gmSEQ.pi + 2*bufferTime + gmSEQ.m + 100, 2*gmSEQ.pi + 2*bufferTime + gmSEQ.m + 100];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=5;    
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime,...
        Pulse2Start+gmSEQ.readout-gmSEQ.pi-bufferTime, Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime,...
        Pulse3Start+gmSEQ.readout-gmSEQ.pi-bufferTime, Pulse3Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime2]; %WJ, 4/29/23 3rd, 5th time -1000 -> -990 due to disagreement of the buffer time
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime2]; % change last 2* to 4*, Jan/18/2023 by zzl  % change last buffer time 2-> buffer time 4/28/23 WJ
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi+15 Pulse2Start Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+15 Pulse3Start Pulse3Start+gmSEQ.readout+gmSEQ.m+AfterPi+15];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout ReadoutLength gmSEQ.readout ReadoutLength gmSEQ.readout ReadoutLength];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Pulse3Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+30];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[100 100];

%WJ 04/27/23; duplicate ctr0 for monitoring
% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6;
% 
% ctrOffset = -200;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi-1000,...
%     Pulse2Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi-985,...
%     Pulse3Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, Pulse3Start+gmSEQ.readout+gmSEQ.m+AfterPi-985];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur]; 

AWG2delay=-2; %5-->0 4/20/23 WJ 

try
    if true %gSG.first
        disp('UPLLOADING TO AWG!')
        disp(gmSEQ.m)
        %[start, end, Freq, phase, Amp]
        
        if gSG.ACmod % in AC modulation mode
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 1st X pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
            
            F_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 4th X pulse
            F_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
            
            G_1 = [0 0+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 0;...
                gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage2]; % 5th +1 X pulse, with 1st pulse being 0 amplitude
            G_2 = [0 0+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 0;...
                gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage2];  

          % ejd 6.6.23
%             G_1 = [0 0+gmSEQ.pi-AWG2delay+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 0;...
%                 0+gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage2]; % 5th +1 X pulse, with 1st pulse being 0 amplitude
%             G_2 = [0 0+gmSEQ.pi-AWG2delay+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 0;...
%                 0+gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage2];  

%2nd entry gmSEQ.m --> gmSEQ.pi-AWG2delay+gmSEQ.m 4/20/23 WJ
%             G_1 = [0 gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 0;... 
%                 0+gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage2]; % 5th +1 X pulse, with 1st pulse being 0 amplitude
%             G_2 = [0 gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 0;...
%                 0+gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage2];
            
            
            if gmSEQ.m < 525
                D_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
                    gmSEQ.m+gmSEQ.pi gmSEQ.m+2*gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 2nd and 3rd X pulse
                D_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
                    gmSEQ.m+gmSEQ.pi gmSEQ.m+2*gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
                Length2 = gmSEQ.pi+150; % original +1000 ns
                clkRate2 = 2e9; % 2GHz
                Length3 = gmSEQ.pi+gmSEQ.m+150; % original +1000 ns
                Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
                Total3 = ceil(Length3*clkRate2/1e9/16)*16; % total number of points need "16x integer"
                chaseFunctionPool('stopChase', 1); pause(0.1);
                chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.1);
                chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length3, 'wave_AWG2_ch3.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length3, 'wave_AWG2_ch4.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', F_1, clkRate2/10^9, Length2, 'wave_AWG2_ch7.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', F_2, clkRate2/10^9, Length2, 'wave_AWG2_ch8.txt'); pause(0.3);
                chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', ...
                 'wave_AWG2_ch1.txt', Total2, 1, 1,...
                 'wave_AWG2_ch3.txt', Total3, 1, 1,...
                 'wave_AWG2_ch7.txt', Total2, 1, 1); % I port, C1 and D1 and F1
                pause(0.5);
                chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt',...
                 'wave_AWG2_ch2.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch4.txt', Total3, 1, 1,...
                 'wave_AWG2_ch8.txt', Total2, 1, 1); % Q port, C2 and D2 and F2
                pause(0.5);
                chaseFunctionPool('CreateSegments', 1, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false'); pause(1);
                chaseFunctionPool('CreateSegments', 1, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false'); pause(1);
                chaseFunctionPool('runChase', 1, 'false');
                
                chaseFunctionPool('stopChase', 2); pause(0.5);
                chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.5);
                chaseFunctionPool('createWaveform', G_1, clkRate2/10^9, Length3, 'wave_AWG2_ch9.txt'); pause(0.5);
                chaseFunctionPool('createWaveform', G_2, clkRate2/10^9, Length3, 'wave_AWG2_ch10.txt'); pause(0.5);
                chaseFunctionPool('CreateSingleSegment',2, 1, Total3, 1, 2047, 2047, 'wave_AWG2_ch9.txt', 1); pause(0.5);
                chaseFunctionPool('CreateSingleSegment',2, 2, Total3, 1, 2047, 2047, 'wave_AWG2_ch10.txt', 1); pause(0.5);
                chaseFunctionPool('runChase', 2, 'false');
                
            else
                D_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 2nd X pulse
                D_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];

                E_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 3rd X pulse
                E_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];  
                Length2 = gmSEQ.pi+150; % original +1000 ns
                clkRate2 = 2e9; % 2GHz
                Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
                Length3 = gmSEQ.pi+gmSEQ.m+150; % original +1000 ns
                Total3 = ceil(Length3*clkRate2/1e9/16)*16; % total number of points need "16x integer"
                chaseFunctionPool('stopChase', 1); pause(0.1);
                chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.1);
                chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2, 'wave_AWG2_ch3.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2, 'wave_AWG2_ch4.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', E_1, clkRate2/10^9, Length2, 'wave_AWG2_ch5.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', E_2, clkRate2/10^9, Length2, 'wave_AWG2_ch6.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', F_1, clkRate2/10^9, Length2, 'wave_AWG2_ch7.txt'); pause(0.3);
                chaseFunctionPool('createWaveform', F_2, clkRate2/10^9, Length2, 'wave_AWG2_ch8.txt'); pause(0.3);
                chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', ...
                 'wave_AWG2_ch1.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch3.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch5.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch7.txt', Total2, 1, 1); % I port, C1 and D1 and E1 and F1
                pause(0.5);
                chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt',...
                 'wave_AWG2_ch2.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch4.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch6.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch8.txt', Total2, 1, 1); % Q port, C2 and D2 and E2 and F2
                pause(0.5);
                chaseFunctionPool('CreateSegments', 1, 1, 4, 2047, 2047, 'SegStruct_ch1.txt', 'false'); pause(1);
                chaseFunctionPool('CreateSegments', 1, 2, 4, 2047, 2047, 'SegStruct_ch2.txt', 'false'); pause(1);
                chaseFunctionPool('runChase', 1, 'false');
                
                chaseFunctionPool('stopChase', 2); pause(0.5);
                chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.5);
                chaseFunctionPool('createWaveform', G_1, clkRate2/10^9, Length3, 'wave_AWG2_ch9.txt'); pause(0.5);
                chaseFunctionPool('createWaveform', G_2, clkRate2/10^9, Length3, 'wave_AWG2_ch10.txt'); pause(0.5);
                chaseFunctionPool('CreateSingleSegment',2, 1, Total3, 1, 2047, 2047, 'wave_AWG2_ch9.txt', 1); pause(0.5);
                chaseFunctionPool('CreateSingleSegment',2, 2, Total3, 1, 2047, 2047, 'wave_AWG2_ch10.txt', 1); pause(0.5);
                chaseFunctionPool('runChase', 2, 'false');
            end
        
        else
            warning('need AC modulation, stop !');
        end
    end
catch
    disp('oops!')
end

ApplyDelays();

% function DQ_3
% 
% global gmSEQ gSG gSG2
% % gmSEQ: seqeuence, data, parameters
% % gSG: signal generator
% 
% gSG.bfixedPow=1; % fix microwave power
% gSG.bfixedFreq=1; % fix microwave ferq
% 
% gSG.bMod='IQ';% if totally off, change to ''
% gSG.bModSrc='External';
% 
% gSG2.bOn = 1;
% gSG2.bfixedPow=1; % fix microwave power
% gSG2.bfixedFreq=1; % fix microwave ferq
% 
% gSG2.bMod='IQ';
% gSG2.bModSrc='External';
% 
% AfterPi = 500; %originally 500, ejd
% BetweenSequence = 1000;
% ReadoutLength = 2000;
% Pulse2Start = BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+BetweenSequence;
% 
% %gmSEQ.To is the "To" value in the "From to To" section of the GUI
% %%%%% Fixed sequence length %%%%%%
% gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
% gmSEQ.CHN(1).NRise=4;
% 
% ctrOffset = 0;
% gmSEQ.CHN(1).T=[BetweenSequence+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi+15,...
%     Pulse2Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+15];
% gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur]; %4/26/23 WJ: -990 --> -1000 for 4rd, 6th pulses
% 
% triglen = 35;
% 
% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
% %%% ejd edit start 11/15/22
% if gmSEQ.m < 525
%     offset = 10;
%     gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; 
%     gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [BetweenSequence+gmSEQ.readout-gmSEQ.pi,...
%         Pulse2Start+gmSEQ.readout-gmSEQ.pi];
%     gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+triglen, gmSEQ.pi+triglen];
% else
%     offset = 10;
%     gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
%     gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [BetweenSequence+gmSEQ.readout-gmSEQ.pi, BetweenSequence+gmSEQ.m+gmSEQ.readout-gmSEQ.pi,...
%         Pulse2Start+gmSEQ.readout-gmSEQ.pi]; %3rd T -1000-> -990 4/29/23, WJ
%     gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+triglen, gmSEQ.pi+triglen, gmSEQ.pi+triglen];
% end
% 
% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG2'); % AWG2 pulse trigger
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1; 
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [Pulse2Start+gmSEQ.readout-gmSEQ.pi]; %ejd1 6.6.23 -1000
% % if gmSEQ.m < 525
% %     gmSEQ.CHN(numel(gmSEQ.CHN)).T=Pulse3Start+gmSEQ.readout-gmSEQ.pi-1000%gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [Pulse3Start+gmSEQ.readout-gmSEQ.pi-1020]; %ejd 6.6.23 -1000 --> -1020
% % else
% %     gmSEQ.CHN(numel(gmSEQ.CHN)).T=Pulse3Start+gmSEQ.readout-gmSEQ.pi-1000%gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [Pulse3Start+gmSEQ.readout-gmSEQ.pi-1320]; %ejd 6.6.23 -1000 --> -1320
% % end
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+triglen];
% 
% bufferTime = 40; % original 40 --> 50 5/4/23/WJ
% bufferTime2 = 40; %50 --> 40 --> 50 4/28/23 WJ
% 
% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); % MW switch on
% 
% if gmSEQ.m < 200
%     gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%     gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout-gmSEQ.pi-bufferTime,...
%         Pulse2Start+gmSEQ.readout-gmSEQ.pi-bufferTime];
%     gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[2*gmSEQ.pi + 2*bufferTime + gmSEQ.m + 100, 2*gmSEQ.pi + 2*bufferTime + gmSEQ.m + 100];
% else
%     gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;    
%     gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout-gmSEQ.pi-bufferTime, BetweenSequence+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime,...
%         Pulse2Start+gmSEQ.readout-gmSEQ.pi-bufferTime, Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime2]; %WJ, 4/29/23 3rd, 5th time -1000 -> -990 due to disagreement of the buffer time
%     gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime2]; % change last 2* to 4*, Jan/18/2023 by zzl  % change last buffer time 2-> buffer time 4/28/23 WJ
% end
% 
% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
% % gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
% % gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence];
% % gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength-BetweenSequence];
% % gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% % gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence Pulse2Start];
% % gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout gmSEQ.readout];
% % gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% % gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi+15 Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+15];
% % gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[ReadoutLength ReadoutLength];
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi+15 Pulse2Start Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+15];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout ReadoutLength gmSEQ.readout ReadoutLength];
% 
% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+30];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[100 100];
% 
% %WJ 04/27/23; duplicate ctr0 for monitoring
% % gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
% % gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6;
% % 
% % ctrOffset = -200;
% % gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi-1000,...
% %     Pulse2Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi-985,...
% %     Pulse3Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, Pulse3Start+gmSEQ.readout+gmSEQ.m+AfterPi-985];
% % gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur]; 
% 
% AWG2delay=-2; %5-->0 4/20/23 WJ 
% 
% try
%     if true %gSG.first
%         disp('UPLLOADING TO AWG!')
%         disp(gmSEQ.m)
%         %[start, end, Freq, phase, Amp]
%         
%         if gSG.ACmod % in AC modulation mode
%            
%             F_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 4th X pulse
%             F_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
%             
%             G_1 = [0 0+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 0;...
%                 gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage2]; % 5th +1 X pulse, with 1st pulse being 0 amplitude
%             G_2 = [0 0+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 0;...
%                 gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage2];  
% 
%           % ejd 6.6.23
% %             G_1 = [0 0+gmSEQ.pi-AWG2delay+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 0;...
% %                 0+gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage2]; % 5th +1 X pulse, with 1st pulse being 0 amplitude
% %             G_2 = [0 0+gmSEQ.pi-AWG2delay+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 0;...
% %                 0+gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage2];  
% 
% %2nd entry gmSEQ.m --> gmSEQ.pi-AWG2delay+gmSEQ.m 4/20/23 WJ
% %             G_1 = [0 gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 0;... 
% %                 0+gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage2]; % 5th +1 X pulse, with 1st pulse being 0 amplitude
% %             G_2 = [0 gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 0;...
% %                 0+gmSEQ.pi-AWG2delay+gmSEQ.m gmSEQ.pi-AWG2delay+gmSEQ.DEERpi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage2];
%             
%             
%             if gmSEQ.m < 525
%                 D_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
%                     gmSEQ.m+gmSEQ.pi gmSEQ.m+2*gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 2nd and 3rd X pulse
%                 D_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
%                     gmSEQ.m+gmSEQ.pi gmSEQ.m+2*gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
%                 Length2 = gmSEQ.pi+150; % original +1000 ns
%                 clkRate2 = 2e9; % 2GHz
%                 Length3 = gmSEQ.pi+gmSEQ.m+150; % original +1000 ns
%                 Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
%                 Total3 = ceil(Length3*clkRate2/1e9/16)*16; % total number of points need "16x integer"
%                 chaseFunctionPool('stopChase', 1); pause(0.1);
%                 chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.1);
%                 chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length3, 'wave_AWG2_ch3.txt'); pause(0.3);
%                 chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length3, 'wave_AWG2_ch4.txt'); pause(0.3);
%                 chaseFunctionPool('createWaveform', F_1, clkRate2/10^9, Length2, 'wave_AWG2_ch7.txt'); pause(0.3);
%                 chaseFunctionPool('createWaveform', F_2, clkRate2/10^9, Length2, 'wave_AWG2_ch8.txt'); pause(0.3);
%                 chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', ...
%                  'wave_AWG2_ch3.txt', Total3, 1, 1,...
%                  'wave_AWG2_ch7.txt', Total2, 1, 1); % I port, C1 and D1 and F1
%                 pause(0.5);
%                 chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt',...
%                  'wave_AWG2_ch4.txt', Total3, 1, 1,...
%                  'wave_AWG2_ch8.txt', Total2, 1, 1); % Q port, C2 and D2 and F2
%                 pause(0.5);
%                 chaseFunctionPool('CreateSegments', 1, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false'); pause(1);
%                 chaseFunctionPool('CreateSegments', 1, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false'); pause(1);
%                 chaseFunctionPool('runChase', 1, 'false');
%                 
%                 chaseFunctionPool('stopChase', 2); pause(0.5);
%                 chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.5);
%                 chaseFunctionPool('createWaveform', G_1, clkRate2/10^9, Length3, 'wave_AWG2_ch9.txt'); pause(0.5);
%                 chaseFunctionPool('createWaveform', G_2, clkRate2/10^9, Length3, 'wave_AWG2_ch10.txt'); pause(0.5);
%                 chaseFunctionPool('CreateSingleSegment',2, 1, Total3, 1, 2047, 2047, 'wave_AWG2_ch9.txt', 1); pause(0.5);
%                 chaseFunctionPool('CreateSingleSegment',2, 2, Total3, 1, 2047, 2047, 'wave_AWG2_ch10.txt', 1); pause(0.5);
%                 chaseFunctionPool('runChase', 2, 'false');
%                 
%             else
%                 D_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 2nd X pulse
%                 D_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
% 
%                 E_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 3rd X pulse
%                 E_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];  
%                 Length2 = gmSEQ.pi+150; % original +1000 ns
%                 clkRate2 = 2e9; % 2GHz
%                 Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
%                 Length3 = gmSEQ.pi+gmSEQ.m+150; % original +1000 ns
%                 Total3 = ceil(Length3*clkRate2/1e9/16)*16; % total number of points need "16x integer"
%                 chaseFunctionPool('stopChase', 1); pause(0.1);
%                 chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.1);
%                 chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2, 'wave_AWG2_ch3.txt'); pause(0.3);
%                 chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2, 'wave_AWG2_ch4.txt'); pause(0.3);
%                 chaseFunctionPool('createWaveform', E_1, clkRate2/10^9, Length2, 'wave_AWG2_ch5.txt'); pause(0.3);
%                 chaseFunctionPool('createWaveform', E_2, clkRate2/10^9, Length2, 'wave_AWG2_ch6.txt'); pause(0.3);
%                 chaseFunctionPool('createWaveform', F_1, clkRate2/10^9, Length2, 'wave_AWG2_ch7.txt'); pause(0.3);
%                 chaseFunctionPool('createWaveform', F_2, clkRate2/10^9, Length2, 'wave_AWG2_ch8.txt'); pause(0.3);
%                 chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', ...
%                  'wave_AWG2_ch3.txt', Total2, 1, 1, ...
%                  'wave_AWG2_ch5.txt', Total2, 1, 1, ...
%                  'wave_AWG2_ch7.txt', Total2, 1, 1); % I port, C1 and D1 and E1 and F1
%                 pause(0.5);
%                 chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt',...
%                  'wave_AWG2_ch4.txt', Total2, 1, 1, ...
%                  'wave_AWG2_ch6.txt', Total2, 1, 1, ...
%                  'wave_AWG2_ch8.txt', Total2, 1, 1); % Q port, C2 and D2 and E2 and F2
%                 pause(0.5);
%                 chaseFunctionPool('CreateSegments', 1, 1, 4, 2047, 2047, 'SegStruct_ch1.txt', 'false'); pause(1);
%                 chaseFunctionPool('CreateSegments', 1, 2, 4, 2047, 2047, 'SegStruct_ch2.txt', 'false'); pause(1);
%                 chaseFunctionPool('runChase', 1, 'false');
%                 
%                 chaseFunctionPool('stopChase', 2); pause(0.5);
%                 chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.5);
%                 chaseFunctionPool('createWaveform', G_1, clkRate2/10^9, Length3, 'wave_AWG2_ch9.txt'); pause(0.5);
%                 chaseFunctionPool('createWaveform', G_2, clkRate2/10^9, Length3, 'wave_AWG2_ch10.txt'); pause(0.5);
%                 chaseFunctionPool('CreateSingleSegment',2, 1, Total3, 1, 2047, 2047, 'wave_AWG2_ch9.txt', 1); pause(0.5);
%                 chaseFunctionPool('CreateSingleSegment',2, 2, Total3, 1, 2047, 2047, 'wave_AWG2_ch10.txt', 1); pause(0.5);
%                 chaseFunctionPool('runChase', 2, 'false');
%             end
%         
%         else
%             warning('need AC modulation, stop !');
%         end
%     end
% catch
%     disp('oops!')
% end
% ApplyDelays();

function Null_Measure

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to '';%FUCK
gSG.bModSrc='External';

gSG2.bOn = 0;

AfterPi = 55; %originally 500, ejd
BetweenSequence = 1000;
ReadoutLength = 2000;
Pulse2Start = BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+BetweenSequence;

%gmSEQ.To is the "To" value in the "From to To" section of the GUI
%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=4;

ctrOffset = -200;
gmSEQ.CHN(1).T=[BetweenSequence+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi-1000,...
    Pulse2Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi-1000]; % 11/10/2022 Added
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur]; 

bufferTime = 40;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); % MW switch on

if gmSEQ.m < 200
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi-bufferTime, Pulse2Start+gmSEQ.readout-1000-gmSEQ.pi-bufferTime];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi + 2*bufferTime, 2*gmSEQ.pi + 2*bufferTime + gmSEQ.m + 100];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;    
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi-bufferTime, Pulse2Start+gmSEQ.readout-1000-gmSEQ.pi-bufferTime, Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime-1000];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength-BetweenSequence];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+30];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[100 100];

ApplyDelays();

function T1_2AWG

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to '';%FUCK
gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq

gSG2.bMod='IQ';
gSG2.bModSrc='External';

AfterPi = 55; %originally 500, ejd
BetweenSequence = 1000;
ReadoutLength = 2000;
Pulse2Start = BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+BetweenSequence;

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=4;
ctrOffset = -200;
gmSEQ.CHN(1).T=[BetweenSequence+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, BetweenSequence+gmSEQ.readout+gmSEQ.m+AfterPi-1000,...
    Pulse2Start+gmSEQ.readout-gmSEQ.CtrGateDur-1000+ctrOffset, Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi-1000]; % 11/10/2022 Added
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur]; 

triglen = 35;

PIoffset = 0;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
offset = 10;
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; %ejd changed from 3 to 2
gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi, Pulse2Start+gmSEQ.readout-gmSEQ.pi-1000];%, Pulse2Start+gmSEQ.m+gmSEQ.readout-gmSEQ.pi-0-triglen];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+triglen, gmSEQ.pi+triglen];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG2'); % AWG2 pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1; %ejd changed from 3 to 1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=offset + [Pulse2Start+gmSEQ.readout-gmSEQ.DEERpi-1000]; %zz 11/29/22 change the AWG2 trigger to the same as 2nd AWG1 trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+triglen];%, gmSEQ.pi+triglen];

bufferTime = 40;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); % MW switch on
if gmSEQ.m < 200
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi-bufferTime, Pulse2Start+gmSEQ.readout-1000-gmSEQ.DEERpi-bufferTime];%, Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime-0];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi + 2*bufferTime, 2*gmSEQ.pi + 2*bufferTime + gmSEQ.m + 100];%, gmSEQ.pi + 2*bufferTime];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;    
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence+gmSEQ.readout-1000-gmSEQ.pi-bufferTime, Pulse2Start+gmSEQ.readout-1000-gmSEQ.pi-bufferTime, Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.DEERpi-bufferTime-1000];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi + 2*bufferTime, gmSEQ.pi + 2*bufferTime, gmSEQ.DEERpi + 2*bufferTime];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[BetweenSequence];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength-BetweenSequence];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Pulse2Start+gmSEQ.readout+gmSEQ.m+AfterPi+ReadoutLength+30];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[100 100];

try
    if true 
        disp('UPLOADING TO AWG!')
        disp(gmSEQ.m)
        %[start, end, Freq, phase, Amp]
        
        if gSG.ACmod % in AC modulation mode
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 1st Pi X pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];

            D_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 2nd X pulse
            D_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];

            E_1 = [0 gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 0;...
                0+gmSEQ.m gmSEQ.pi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % 3rd X pulse, with 1st pulse being 0 amplitude
            E_2 = [0 gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 0;...
                0+gmSEQ.m gmSEQ.pi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];  
            
            Length2 = gmSEQ.pi+150; % original +1000 ns
            clkRate2 = 2e9; % 2GHz
            Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
            chaseFunctionPool('stopChase', 1); pause(0.5);
            chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.5);
            chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
            chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
            chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2, 'wave_AWG2_ch3.txt'); pause(0.5);
            chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2, 'wave_AWG2_ch4.txt'); pause(0.5);
            chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', ...
                 'wave_AWG2_ch1.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch3.txt', Total2, 1, 1); % I port, C1 and D1, AWG1
            pause(0.5);
            chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt',...
                'wave_AWG2_ch2.txt', Total2, 1, 1, ...
                 'wave_AWG2_ch4.txt', Total2, 1, 1); % Q port, C2 and D2, AWG1
            pause(0.5);
            chaseFunctionPool('CreateSegments', 1, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false'); pause(0.5);
            chaseFunctionPool('CreateSegments', 1, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false'); pause(0.5);
            chaseFunctionPool('runChase', 1, 'false');
            
            % create the wave for 2nd AWG, cardNum=2 now
            Length3 = gmSEQ.pi+gmSEQ.m+150; % original +1000 ns
            Total3 = ceil(Length3*clkRate2/1e9/16)*16; % total number of points need "16x integer"
            chaseFunctionPool('stopChase', 2); pause(0.5);
            chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.5);
            chaseFunctionPool('createWaveform', E_1, clkRate2/10^9, Length3, 'wave_AWG2_ch5.txt'); pause(0.5);
            chaseFunctionPool('createWaveform', E_2, clkRate2/10^9, Length3, 'wave_AWG2_ch6.txt'); pause(0.5);
            chaseFunctionPool('CreateSingleSegment',2, 1, Total3, 1, 2047, 2047, 'wave_AWG2_ch5.txt', 1); pause(0.5);
            chaseFunctionPool('CreateSingleSegment',2, 2, Total3, 1, 2047, 2047, 'wave_AWG2_ch6.txt', 1); pause(0.5);
            chaseFunctionPool('runChase', 2, 'false');
        
        else
            warning('need AC modulation, stop! There are not anything uploaded to AWG!');
        end
    end
catch
    disp('oops!')
end
ApplyDelays();

function ENDOR_Rabi

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to '';
gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=0; % fix microwave ferq

gSG2.bMod='';

AfterPi = 100;
AfterLaser = 1000;

maxRFLength = gmSEQ.To;

% gmSEQ.m : variable timing value
t_firstPi = gmSEQ.readout + AfterLaser;
t_rf = t_firstPi + AfterPi;
t_secondPi = t_rf + maxRFLength + AfterPi; % 1000 is just a placeholder for the max rf drive length
t_readout = t_secondPi + AfterPi;

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[gmSEQ.readout-gmSEQ.CtrGateDur-1000 t_readout];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')||strcmp(gmSEQ.meas,'Scope')
    gmSEQ.CHN(1).DT=[1000 1000];
end
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [t_firstPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 t_readout];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout 2000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[t_firstPi-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+40+t_secondPi-t_rf];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= t_rf;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.m;

try
    if gSG.first
        disp('UPLLOADING TO AWG,,,,...')
        % for MW_AWG
        if gSG.ACmod % in AC modulation mode
            % C_1 = [start, end, Freq, phase, Amp]
            % C_2 = [start, end, Freq, phase+pi/2, Amp] quadruture
            % phase = 0 --> +X pulse; pi/2 --> +Y, pi --> -X;  3*pi/2 --> -Y
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
                   AfterPi+maxRFLength+AfterPi AfterPi+maxRFLength+AfterPi+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % X pi pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
                   AfterPi+maxRFLength+AfterPi AfterPi+maxRFLength+AfterPi+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
        else
            C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1;...
                   AfterPi+maxRFLength+AfterPi AfterPi+maxRFLength+AfterPi+gmSEQ.pi 0 0 gSG.IQVoltage1];
            C_2 = [0 gmSEQ.pi 0 0 0;...
                   AfterPi+maxRFLength+AfterPi AfterPi+maxRFLength+AfterPi+gmSEQ.pi 0 0 0];
        end

            Length2_2 = round(gmSEQ.pi+1000);
            clkRate2 = 2e9;

            Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;

            chaseFunctionPool('stopChase', 1); pause(0.3);
            chaseFunctionPool('setClkRate',1, clkRate2); pause(0.3);
            chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
            chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);

            chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1); % I port, C1
            pause(0.5);
            chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1); % Q port, C2
            pause(0.5);

            chaseFunctionPool('CreateSegments', 1, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
            pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
            chaseFunctionPool('CreateSegments', 1, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
            pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
            chaseFunctionPool('runChase', 1, 'false');
    end
catch
    disp('oops!')
end

ApplyDelays();

function ENDOR_ODMR

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to '';
gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=0; % fix microwave ferq
gSG2.bMod='';

AfterPi = 300;
AfterLaser = 1000;

maxRFLength = gmSEQ.DEERpi + 500;

% gmSEQ.m : variable timing value
t_firstPi = gmSEQ.readout + AfterLaser;
t_rf = t_firstPi + AfterPi;
t_secondPi = t_rf + maxRFLength + AfterPi; % 1000 is just a placeholder for the max rf drive length
t_readout = t_secondPi + gmSEQ.pi + AfterPi;

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[gmSEQ.readout-gmSEQ.CtrGateDur-1000 t_readout];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')||strcmp(gmSEQ.meas,'Scope')
    gmSEQ.CHN(1).DT=[1000 1000];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 t_readout];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout 2000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [t_firstPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[t_firstPi-30];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[AfterPi+maxRFLength+AfterPi+gmSEQ.pi+250];

% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[t_firstPi-30 t_secondPi-30];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+50 gmSEQ.pi+50];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= t_rf;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.DEERpi;

%gSG.first = 1; %% ejd edit 
try
    if gSG.first
        disp('UPLOADING TO AWG...!')
        % for MW_AWG
        if gSG.ACmod % in AC modulation mode
            % C_1 = [start, end, Freq, phase, Amp]
            % C_2 = [start, end, Freq, phase+pi/2, Amp] quadruture
            % phase = 0 --> +X pulse; pi/2 --> +Y, pi --> -X;  3*pi/2 --> -Y
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
                   AfterPi+maxRFLength+AfterPi AfterPi+maxRFLength+AfterPi+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % X pi pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
                   AfterPi+maxRFLength+AfterPi AfterPi+maxRFLength+AfterPi+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
        else
            C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1;...
                   AfterPi+maxRFLength+AfterPi AfterPi+maxRFLength+AfterPi+gmSEQ.pi 0 0 gSG.IQVoltage1];
            C_2 = [0 gmSEQ.pi 0 0 0;...
                   AfterPi+maxRFLength+AfterPi AfterPi+maxRFLength+AfterPi+gmSEQ.pi 0 0 0];
        end

            Length2_2 = round(gmSEQ.pi+1000);
            clkRate2 = 2e9;

            Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;

            chaseFunctionPool('stopChase', 1); pause(0.3);
            chaseFunctionPool('setClkRate',1, clkRate2); pause(0.3);
            chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
            chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);

            chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1); % I port, C1
            pause(0.5);
            chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1); % Q port, C2
            pause(0.5);

            chaseFunctionPool('CreateSegments', 1, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
            pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
            chaseFunctionPool('CreateSegments', 1, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
            pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
            chaseFunctionPool('runChase', 1, 'false');
    end
catch
    disp('oops!')
end

ApplyDelays();

function wait_Rabi

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to '';
gSG.bModSrc='External';

gSG2.bOn = 0;

AfterPi = 100;
AfterLaser = 1000;

maxRFLength = gmSEQ.DEERpi;

% gmSEQ.m : variable timing value
t_firstPi = gmSEQ.readout + AfterLaser;
t_rf = t_firstPi + AfterPi;
t_secondPi = t_rf + maxRFLength + AfterPi; % 1000 is just a placeholder for the max rf drive length
t_readout = t_secondPi + gmSEQ.m + gmSEQ.pi + AfterPi;

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[gmSEQ.readout-gmSEQ.CtrGateDur-1000 t_readout];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')||strcmp(gmSEQ.meas,'Scope')
    gmSEQ.CHN(1).DT=[1000 1000];
end
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [t_firstPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 t_readout];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout 2000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[t_firstPi-30];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+500+AfterPi+maxRFLength+AfterPi+gmSEQ.m];
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[t_firstPi-30 t_secondPi-50];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+50 gmSEQ.m+gmSEQ.pi+100];



        disp('UPLOADING TO AWG,,,.!')
        % for MW_AWG
        if gSG.ACmod % in AC modulation mode
            % C_1 = [start, end, Freq, phase, Amp]
            % C_2 = [start, end, Freq, phase+pi/2, Amp] quadruture
            % phase = 0 --> +X pulse; pi/2 --> +Y, pi --> -X;  3*pi/2 --> -Y
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
                   AfterPi+maxRFLength+AfterPi AfterPi+maxRFLength+AfterPi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % X pi pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
                   AfterPi+maxRFLength+AfterPi AfterPi+maxRFLength+AfterPi+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
        else
            C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1;...
                   AfterPi+maxRFLength+AfterPi AfterPi+maxRFLength+AfterPi+gmSEQ.m 0 0 gSG.IQVoltage1];
            C_2 = [0 gmSEQ.pi 0 0 0;...
                   AfterPi+maxRFLength+AfterPi AfterPi+maxRFLength+AfterPi+gmSEQ.m 0 0 0];
        end

        
        Length2 = AfterPi+maxRFLength+AfterPi+gmSEQ.To+500; % ns
        clkRate2 = 2e9; % 2GHz
        % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
        % 560ns)
        Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"

        %%% FUCK YUANQI
        chaseFunctionPool('stopChase', 1); pause(0.3);
        chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
        chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
        chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
        chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
        % Function name, AWG #, Channel #, Total number of the points of the
        % sequence, time of the sequence repeat, 
        chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
        chaseFunctionPool('runChase', 1, 'false'); pause(0.2);



ApplyDelays();

function Reference_ODMR

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to '';
gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=0; % fix microwave ferq
gSG2.bMod='';

AfterPi = 300;
AfterLaser = 1000;

maxRFLength = 3000;

% gmSEQ.m : variable timing value
t_firstPi = gmSEQ.readout + AfterLaser;
t_rf = t_firstPi + AfterPi;
t_secondPi = t_rf + maxRFLength + AfterPi; % 1000 is just a placeholder for the max rf drive length
t_readout = t_secondPi + AfterPi;

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout-gmSEQ.CtrGateDur-1000 t_readout];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')||strcmp(gmSEQ.meas,'Scope')
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [t_rf t_readout+1000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [gmSEQ.DEERpi gmSEQ.DEERpi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[t_readout+10000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[100];


if gSG.first
    B = [0 gmSEQ.readout 0.2 0 gSG.IQVoltage1;...
        t_readout t_readout+1000 0.2 0 gSG.IQVoltage2];
    C = [0 100 0 0 0];
    
    Length2 = t_readout+1500;
    clkRate2 = 2e9;
    % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
    % 560ns)
    Total2 = ceil(Length2*clkRate2/1e9/16)*16;
    chaseFunctionPool('stopChase', 1); pause(0.3); % changed from 2 AWG to 1
    chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt');
    chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt');
    chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
    chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
    chaseFunctionPool('runChase', 1, 'false'); pause(0.2);
    
    disp('I am Uploading!!')
    
  

end
ApplyDelays();

function CW_pulsed_noMW

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq
gSG.bMod='';% if totally off, change to ''; Going to MWSwitch
%gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq
gSG2.bMod='';

% gmSEQ.m : variable timing value
BetweenSequence = 1000;
t_CW = gmSEQ.readout; %CW laser t duration
dt_CW_pulsed = 1000; %time difference between the CW & pulsed AOM
t_pulsed = gmSEQ.CtrGateDur; %pulsed laser t duration
EndTime = 10000; %wait time after each sequence


%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0'); %not required, just to give the signal
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + gmSEQ.m; %t_ReferenceGate+1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= 500;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM'); %CW AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= t_CW;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2'); %pulsed AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + t_CW + dt_CW_pulsed; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= t_pulsed;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3'); %Time tagger trig = pulsed AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + t_CW + dt_CW_pulsed; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= t_pulsed;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0, BetweenSequence + t_CW + dt_CW_pulsed + t_pulsed + EndTime]; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[20, 20];

ApplyDelays();

function CW_pulsed_MW

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq
gSG.bMod='IQ';% if totally off, change to ''
gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq
gSG2.bMod='';

% gmSEQ.m : variable timing value
BetweenSequence = 1000;
t_CW = gmSEQ.readout; %CW laser t duration
dt_CW_MW = gmSEQ.DEERpi; %time difference between the CW & pi pulse AWG trig
bufferTime = 70; %MWswitch buffertime
triglen = 35; %MW AWG trigger length
dt_CW_pulsed = 1000; %time difference between the CW & pulsed AOM
t_pulsed = gmSEQ.CtrGateDur; %pulsed laser t duration
EndTime = 10000; %wait time after each sequence


%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0'); %not required, just to give the signal
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + gmSEQ.m; %t_ReferenceGate+1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= 500;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM'); %CW AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= t_CW;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2'); %pulsed AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + t_CW + dt_CW_pulsed; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= t_pulsed;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3'); %Time tagger trig = pulsed AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + t_CW + dt_CW_pulsed; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= t_pulsed;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0, BetweenSequence + t_CW + dt_CW_pulsed + t_pulsed + EndTime]; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[20, 20];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); % MW switch on
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + t_CW + dt_CW_MW -gmSEQ.pi - bufferTime;%, Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime-0];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.pi + 2*bufferTime; 

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1; 
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + t_CW + dt_CW_MW -gmSEQ.pi;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.pi+triglen;

try
    if true %gSG.first
        disp('UPLLOADING TO AWG!')
        
        if gSG.ACmod % in AC modulation mode
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % X pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1]; 
        else
            C_1 = [0 gmSEQ.pi 0 0 gSG.IQVoltage1]; % gSG.Freq = NV resonance frequeincy, gSG.SGbasefreq = f
            C_2 = [0 gmSEQ.pi 0 0+pi/2 0];
        end

        Length2 = gmSEQ.pi+1000; %+150 ns
        clkRate2 = 2e9; % 2GHz
        % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
        % 560ns)
        Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
        chaseFunctionPool('stopChase', 1); pause(0.3);
        chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
        chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
        chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
        chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
        chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
        % Function name, AWG #, Channel #, Total number of the points of the
        % sequence, time of the sequence repeat, 
        chaseFunctionPool('runChase', 1, 'false');
        
     
    end
catch
    disp('oops!')
end

ApplyDelays();

function CW_pulsed_MWonoff

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq
gSG.bMod='IQ';% if totally off, change to ''
gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq
gSG2.bMod='';

% gmSEQ.m : variable timing value
BetweenSequence = 10000;
t_CW = gmSEQ.readout; %CW laser t duration
dt_CW_MW = gmSEQ.DEERpi; %time difference between the CW & pi pulse AWG trig
bufferTime = 50; %MWswitch buffertime
triglen = 35; %MW AWG trigger length
dt_CW_pulsed = 1000; %time difference between the CW & pulsed AOM
t_pulsed = gmSEQ.CtrGateDur; %pulsed laser t duration
nextdelay = 50;
nexttime = 20;


%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0'); %not required, just to give the signal
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence*0.5 + gmSEQ.m; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= 500;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM'); %CW AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [BetweenSequence*0.5, BetweenSequence*1.5 + t_CW + dt_CW_pulsed + t_pulsed]; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [t_CW, t_CW];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2'); %pulsed AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [BetweenSequence*0.5 + t_CW + dt_CW_pulsed, BetweenSequence*1.5 + t_CW*2 + dt_CW_pulsed*2 + t_pulsed];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [t_pulsed, t_pulsed];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3'); %Time tagger next CH
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [BetweenSequence*0.5 + t_CW + dt_CW_pulsed - nextdelay, BetweenSequence*0.5 + t_CW + dt_CW_pulsed + t_pulsed + nextdelay, BetweenSequence*1.5 + t_CW*2 + dt_CW_pulsed*2 + t_pulsed - nextdelay, BetweenSequence*1.5 + t_CW*2 + dt_CW_pulsed*2 + 2*t_pulsed + nextdelay]; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [nexttime, nexttime, nexttime, nexttime];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q_2'); %Time tagger sync CH
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= 0; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= 20;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0, BetweenSequence*2 + t_CW*2 + dt_CW_pulsed*2 + 2*t_pulsed - 20]; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[20, 20];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); % MW switch on
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence*1.5 + 2*t_CW + dt_CW_pulsed + t_pulsed + dt_CW_MW -gmSEQ.pi - bufferTime;%, Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime-0];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.pi + 2*bufferTime; 

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1; 
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence*1.5 + 2*t_CW + dt_CW_pulsed + t_pulsed + dt_CW_MW -gmSEQ.pi;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.pi+triglen;

try
    if true %gSG.first
        disp('UPLLOADING TO AWG!')
        
        if gSG.ACmod % in AC modulation mode
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % X pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1]; 
        else
            C_1 = [0 gmSEQ.pi 0 0 gSG.IQVoltage1]; % gSG.Freq = NV resonance frequeincy, gSG.SGbasefreq = f
            C_2 = [0 gmSEQ.pi 0 0+pi/2 0];
        end

        Length2 = gmSEQ.pi+1000; %+150 ns
        clkRate2 = 2e9; % 2GHz
        % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
        % 560ns)
        Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
        chaseFunctionPool('stopChase', 1); pause(0.3);
        chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
        chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
        chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
        chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
        chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
        % Function name, AWG #, Channel #, Total number of the points of the
        % sequence, time of the sequence repeat, 
        chaseFunctionPool('runChase', 1, 'false');
        
     
    end
catch
    disp('oops!')
end

ApplyDelays();

function pulsed_MW

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq
gSG.bMod='IQ';% if totally off, change to ''
gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq
gSG2.bMod='';

% gmSEQ.m : variable timing value
BetweenSequence = 200;
dt_pulsed_MW = gmSEQ.DEERpi; %time difference between the pulsed & pi pulse AWG trig
bufferTime = 70; %MWswitch buffertime
triglen = 35; %MW AWG trigger length
dt_pulsed = 1000; %time difference between the pulsed AOMs
t_pulsed = gmSEQ.CtrGateDur; %pulsed laser t duration
EndTime = 0; %wait time after each sequence


%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0'); %not required, just to give the signal
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + gmSEQ.m; %t_ReferenceGate+1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= 500;

%gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2'); %pulsed AOM
%gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T= [BetweenSequence, BetweenSequence + t_pulsed + dt_pulsed]; 
%gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [t_pulsed, t_pulsed];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2'); %pulsed AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= t_pulsed;

%gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3'); %Time tagger trig = pulsed AOM
%gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + t_pulsed + dt_pulsed; 
%gmSEQ.CHN(numel(gmSEQ.CHN)).DT= t_pulsed;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q_2'); %Time tagger trig = pulsed AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= 1000;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3'); %Time tagger trig = pulsed AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + 1000; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= 1000;

%gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
%gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0, BetweenSequence + 2*t_pulsed + dt_pulsed + EndTime]; 
%gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[20, 20];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0, BetweenSequence + t_pulsed + dt_pulsed_MW + bufferTime + 300]; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[20, 20];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); % MW switch on
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + t_pulsed + dt_pulsed_MW -gmSEQ.pi - bufferTime;%, Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime-0];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.pi + 2*bufferTime; 

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1; 
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + t_pulsed + dt_pulsed_MW -gmSEQ.pi;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.pi+triglen;

try
    if true %gSG.first
        disp('UPLLOADING TO AWG!')
        
        if gSG.ACmod % in AC modulation mode
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % X pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1]; 
        else
            C_1 = [0 gmSEQ.pi 0 0 gSG.IQVoltage1]; % gSG.Freq = NV resonance frequeincy, gSG.SGbasefreq = f
            C_2 = [0 gmSEQ.pi 0 0+pi/2 0];
        end

        Length2 = gmSEQ.pi+1000; %+150 ns
        clkRate2 = 2e9; % 2GHz
        % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
        % 560ns)
        Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
        chaseFunctionPool('stopChase', 1); pause(0.3);
        chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
        chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
        chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
        chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
        chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
        % Function name, AWG #, Channel #, Total number of the points of the
        % sequence, time of the sequence repeat, 
        chaseFunctionPool('runChase', 1, 'false');
        
     
    end
catch
    disp('oops!')
end

ApplyDelays();

function pulsed

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq
gSG.bMod='';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq
gSG2.bMod='';

% gmSEQ.m : variable timing value
BetweenSequence = 200;
dt_pulsed_MW = gmSEQ.DEERpi; %time difference between the pulsed & pi pulse AWG trig
bufferTime = 70; %MWswitch buffertime
t_pulsed = gmSEQ.CtrGateDur; %pulsed laser t duration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0'); %not required, just to give the signal
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + gmSEQ.m; %t_ReferenceGate+1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= 500;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2'); %pulsed AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= t_pulsed;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q_2'); %Time tagger trig = pulsed AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= 1000;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3'); %Time tagger trig = pulsed AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + 1000; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= 1000;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0, BetweenSequence + t_pulsed + dt_pulsed_MW + bufferTime + 300]; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[20, 20];

ApplyDelays();

function pulsed_MWoffon

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq
gSG.bMod='IQ';% if totally off, change to ''
gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq
gSG2.bMod='';

% gmSEQ.m : variable timing value
%offset = 0; %additional wait time if needed between each sequence
BetweenSequence = gmSEQ.DEERpi; %spacing between sequences
t_pulsed = gmSEQ.readout; %pulsed laser AOM duration
BetweenMWoffon = gmSEQ.DEERpi; %time difference between the MWoff - MWon pulsed laser pulses
bufferTime = 40; %MWswitch buffertime, usually 40 ns
triglen = 35; %MW AWG trigger length
dt_pulsed_MW = gmSEQ.CtrGateDur; %time differnce between the pulsed AOM - MW pi pulse
trigoff = 0; %offset for the time tagger trig if needed

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0'); %not required, just to give the signal
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + gmSEQ.m; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= 100;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy'); %total sequence t = 0 define
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [0, BetweenSequence + t_pulsed + BetweenMWoffon + t_pulsed]; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [20, 20];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2'); %pulsed AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [BetweenSequence, BetweenSequence + t_pulsed + BetweenMWoffon]; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [t_pulsed, t_pulsed];

%gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3'); %Time tagger trig for MW off
%gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 1;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence - trigoff; 
%gmSEQ.CHN(numel(gmSEQ.CHN)).DT= t_pulsed;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q_2'); %Time tagger trig for MW on
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + t_pulsed + BetweenMWoffon - trigoff; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= 20;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); % MW switch on
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + t_pulsed + dt_pulsed_MW  -gmSEQ.pi - bufferTime;%, Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime-0];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.pi + 2*bufferTime; 

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 1; 
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + t_pulsed + dt_pulsed_MW -gmSEQ.pi;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.pi+triglen;

try
    if true %gSG.first
        disp('UPLLOADING TO AWG!')
        
        if gSG.ACmod % in AC modulation mode
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % X pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1]; 
        else
            C_1 = [0 gmSEQ.pi 0 0 gSG.IQVoltage1]; % gSG.Freq = NV resonance frequeincy, gSG.SGbasefreq = f
            C_2 = [0 gmSEQ.pi 0 0+pi/2 0];
        end

        Length2 = gmSEQ.pi+1000; %+150 ns
        clkRate2 = 2e9; % 2GHz
        % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
        % 560ns)
        Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
        chaseFunctionPool('stopChase', 1); pause(0.3);
        chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
        chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
        chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
        chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
        chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
        % Function name, AWG #, Channel #, Total number of the points of the
        % sequence, time of the sequence repeat, 
        chaseFunctionPool('runChase', 1, 'false');
        
     
    end
catch
    disp('oops!')
end

ApplyDelays();

function pulsed_MWoffon2

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq
gSG.bMod='IQ';% if totally off, change to ''
gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq
gSG2.bMod='';

% gmSEQ.m : variable timing value
%offset = 0; %additional wait time if needed between each sequence
BetweenSequence = gmSEQ.DEERpi; %spacing between MW on & off sequences
t_pulsed = gmSEQ.readout; %pulsed laser AOM duration
bufferTime = 50; %MWswitch buffertime, usually 40 ns
triglen = 35; %MW AWG trigger length
dt_pulsed_MW = gmSEQ.CtrGateDur; %time differnce between the pulsed AOM - MW pi pulse
nextdelay = 50; %offset for the time tagger next channel if needed
nexttime = 20; %pulse length for the next channel
inttime = 1000; %integration time for time tagger

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0'); %not required, just to give the signal
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence*0.5 + gmSEQ.m; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= 100;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy'); %total sequence t = 0 define
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [0, BetweenSequence*2 + t_pulsed*2 - 20]; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [20, 20];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2'); %pulsed AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [BetweenSequence*0.5, BetweenSequence*1.5 + t_pulsed]; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [t_pulsed, t_pulsed];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3'); %Time tagger next channel
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [BetweenSequence*0.5 - nextdelay, BetweenSequence*0.5 + inttime + nextdelay, BetweenSequence*1.5 + t_pulsed - nextdelay, BetweenSequence*1.5 + t_pulsed + inttime + nextdelay]; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [nexttime, nexttime, nexttime, nexttime];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q_2'); %Time tagger sync channel
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= 0; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= 20;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); % MW switch on
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence*0.5 + t_pulsed + dt_pulsed_MW  -gmSEQ.pi - bufferTime;%, Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime-0];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.pi + 2*bufferTime; 

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 1; 
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence*0.5 + t_pulsed + dt_pulsed_MW -gmSEQ.pi;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.pi+triglen;

try
    if true %gSG.first
        disp('UPLLOADING TO AWG!')
        
        if gSG.ACmod % in AC modulation mode
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % X pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1]; 
        else
            C_1 = [0 gmSEQ.pi 0 0 gSG.IQVoltage1]; % gSG.Freq = NV resonance frequeincy, gSG.SGbasefreq = f
            C_2 = [0 gmSEQ.pi 0 0+pi/2 0];
        end

        Length2 = gmSEQ.pi+1000; %+150 ns
        clkRate2 = 2e9; % 2GHz
        % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
        % 560ns)
        Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
        chaseFunctionPool('stopChase', 1); pause(0.3);
        chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
        chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
        chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
        chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
        chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
        % Function name, AWG #, Channel #, Total number of the points of the
        % sequence, time of the sequence repeat, 
        chaseFunctionPool('runChase', 1, 'false');
        
     
    end
catch
    disp('oops!')
end

ApplyDelays();

function pulsed_MWoffon3

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq
gSG.bMod='IQ';% if totally off, change to ''
gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq
gSG2.bMod='';

% gmSEQ.m : variable timing value
%offset = 0; %additional wait time if needed between each sequence
BetweenSequence = gmSEQ.DEERpi; %spacing between MW on & off sequences
t_pulsed = gmSEQ.readout; %pulsed laser AOM duration
bufferTime = 40; %MWswitch buffertime, usually 40 ns
triglen = 35; %MW AWG trigger length
dt_pulsed_MW = gmSEQ.CtrGateDur; %time differnce between the pulsed AOM - MW pi pulse
nextdelay = 0; %offset for the time tagger next channel if needed
nexttime = 20; %pulse length for the next channel

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0'); %not required, just to give the signal
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence + gmSEQ.m; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= 100;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy'); %total sequence t = 0 define
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [0, BetweenSequence*2 + t_pulsed*2 - 20]; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [20, 20];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2'); %pulsed AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [BetweenSequence*0.5, BetweenSequence*1.5 + t_pulsed]; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [t_pulsed, t_pulsed];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3'); %Time tagger next channel
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [BetweenSequence*0.5 - nextdelay, BetweenSequence*1.5 + t_pulsed - nextdelay]; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [nexttime, nexttime];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q_2'); %Time tagger sync channel
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= 0; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= 20;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); % MW switch on
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence*0.5 + t_pulsed + dt_pulsed_MW  -gmSEQ.pi - bufferTime;%, Pulse2Start+gmSEQ.readout+gmSEQ.m-gmSEQ.pi-bufferTime-0];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.pi + 2*bufferTime; 

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 1; 
gmSEQ.CHN(numel(gmSEQ.CHN)).T= BetweenSequence*0.5 + t_pulsed + dt_pulsed_MW -gmSEQ.pi;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.pi+triglen;

try
    if true %gSG.first
        disp('UPLLOADING TO AWG!')
        
        if gSG.ACmod % in AC modulation mode
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % X pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1]; 
        else
            C_1 = [0 gmSEQ.pi 0 0 gSG.IQVoltage1]; % gSG.Freq = NV resonance frequeincy, gSG.SGbasefreq = f
            C_2 = [0 gmSEQ.pi 0 0+pi/2 0];
        end

        Length2 = gmSEQ.pi+1000; %+150 ns
        clkRate2 = 2e9; % 2GHz
        % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
        % 560ns)
        Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
        chaseFunctionPool('stopChase', 1); pause(0.3);
        chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
        chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
        chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
        chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
        chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
        % Function name, AWG #, Channel #, Total number of the points of the
        % sequence, time of the sequence repeat, 
        chaseFunctionPool('runChase', 1, 'false');
        
     
    end
catch
    disp('oops!')
end

ApplyDelays();

function cool_timescan

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='';% if totally off, change to ''; Going to MWSwitch
%gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq
gSG2.bMod='';

AfterPi = 300;
AfterLaser = 1000;

% gmSEQ.m : variable timing value
t_LaserEnd = gmSEQ.readout + gmSEQ.CtrGateDur * 2 + AfterPi;
t_ReferenceGate = gmSEQ.readout + gmSEQ.CtrGateDur + 50 - 500;


%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.m t_ReferenceGate+1500]; %t_ReferenceGate+1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= 1500; %0 --> 1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= t_LaserEnd;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= t_LaserEnd+50+1500; %t_LaserEnd+50 --> t_LaserEnd+50+1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.DEERpi;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[t_LaserEnd+gmSEQ.DEERpi+50000]; %600+30000 -> 50000 WL 5/12/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[20];

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q_2'); %for monitoring ctr gate WL 5/18/23
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.m t_ReferenceGate+1500]; %t_ReferenceGate+1500 WL 5/15/23
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

% if gSG.first
%     B = [0 t_LaserEnd 0.2 0 gSG.IQVoltage1];
%     C = [0 100 0 0 0];
%     
%     Length2 = t_LaserEnd+1500;
%     clkRate2 = 2e9;
%     % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
%     % 560ns)
%     Total2 = ceil(Length2*clkRate2/1e9/16)*16;
%     chaseFunctionPool('stopChase', 1); pause(0.3); % changed from 2 AWG to 1
%     chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
%     chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt');
%     chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt');
%     chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
%     chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
%     chaseFunctionPool('runChase', 1, 'false'); pause(0.2);
%     
%     disp('I am Uploading!!')
% end
ApplyDelays();

function cool_timescan_timetagger

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='';% if totally off, change to ''; Going to MWSwitch
%gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq
gSG2.bMod='';

AfterPi = 300;
AfterLaser = 1000;

% gmSEQ.m : variable timing value
t_LaserEnd = gmSEQ.readout + gmSEQ.CtrGateDur * 2 + AfterPi;
t_ReferenceGate = gmSEQ.readout + gmSEQ.CtrGateDur + 50 - 500;


%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.m t_ReferenceGate+1500]; %t_ReferenceGate+1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= 5000; %0 --> 1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= t_LaserEnd;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3'); %sync to AOM
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= 4000; %0 --> 1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= t_LaserEnd;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2'); %next
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [0, 5000 + t_LaserEnd - 50]; %t_LaserEnd+50 --> t_LaserEnd+50+1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [gmSEQ.DEERpi, gmSEQ.DEERpi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy'); %sync
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[t_LaserEnd+gmSEQ.DEERpi+50000]; %600+30000 -> 50000 WL 5/12/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[20];

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q_2'); %for monitoring ctr gate WL 5/18/23
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.m t_ReferenceGate+1500]; %t_ReferenceGate+1500 WL 5/15/23
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

% if gSG.first
%     B = [0 t_LaserEnd 0.2 0 gSG.IQVoltage1];
%     C = [0 100 0 0 0];
%     
%     Length2 = t_LaserEnd+1500;
%     clkRate2 = 2e9;
%     % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
%     % 560ns)
%     Total2 = ceil(Length2*clkRate2/1e9/16)*16;
%     chaseFunctionPool('stopChase', 1); pause(0.3); % changed from 2 AWG to 1
%     chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
%     chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt');
%     chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt');
%     chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
%     chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
%     chaseFunctionPool('runChase', 1, 'false'); pause(0.2);
%     
%     disp('I am Uploading!!')
% end
ApplyDelays();

function cool_timescan_timetagger_pol

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='';% if totally off, change to ''; Going to MWSwitch
%gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq
gSG2.bMod='';

AfterPi = 300;
AfterLaser = 1000;

% gmSEQ.m : variable timing value
t_LaserEnd = gmSEQ.readout + gmSEQ.CtrGateDur * 2 + AfterPi;
t_ReferenceGate = gmSEQ.readout + gmSEQ.CtrGateDur + 50 - 500;


%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.m t_ReferenceGate+1500]; %t_ReferenceGate+1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [600, t_LaserEnd+gmSEQ.DEERpi+50000-35000]; %0 --> 1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [t_LaserEnd, 35000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3'); %sync to AOM, start
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= 100; %0 --> 1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= t_LaserEnd;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2'); %next
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= [0, 1000 + t_LaserEnd - 50]; %t_LaserEnd+50 --> t_LaserEnd+50+1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [gmSEQ.DEERpi, gmSEQ.DEERpi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy'); %sync
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[t_LaserEnd+gmSEQ.DEERpi+50000]; %600+30000 -> 50000 WL 5/12/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[20];

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q_2'); %for monitoring ctr gate WL 5/18/23
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.m t_ReferenceGate+1500]; %t_ReferenceGate+1500 WL 5/15/23
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

% if gSG.first
%     B = [0 t_LaserEnd 0.2 0 gSG.IQVoltage1];
%     C = [0 100 0 0 0];
%     
%     Length2 = t_LaserEnd+1500;
%     clkRate2 = 2e9;
%     % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
%     % 560ns)
%     Total2 = ceil(Length2*clkRate2/1e9/16)*16;
%     chaseFunctionPool('stopChase', 1); pause(0.3); % changed from 2 AWG to 1
%     chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
%     chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt');
%     chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt');
%     chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
%     chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
%     chaseFunctionPool('runChase', 1, 'false'); pause(0.2);
%     
%     disp('I am Uploading!!')
% end
ApplyDelays();

function cool_timescan_Ncounters

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='';% if totally off, change to ''; Going to MWSwitch
%gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq
gSG2.bMod='';

AfterPi = 300;
AfterLaser = 1000;

% gmSEQ.m : variable timing value
t_LaserEnd = gmSEQ.readout + gmSEQ.CtrGateDur * 2 + AfterPi;
t_ReferenceGate = gmSEQ.readout + gmSEQ.CtrGateDur + 50 - 500;

%ctr gate arrays
ctrN = 10; %number of countergate pulses for the signal
ctrS = 0; %initial time of the counter gate pulses
ctrE = 6000; %final time of the counter gate pulses

ctrT = [round(linspace(ctrS,ctrE,ctrN)) t_ReferenceGate+1500];
ctrDT = zeros(1,ctrN+1);
ctrDT(1:end) = gmSEQ.CtrGateDur;


%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= ctrN + 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= ctrT; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= ctrDT;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= 1500; %0 --> 1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= t_LaserEnd;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[t_LaserEnd+gmSEQ.DEERpi+50000]; %600+30000 -> 50000 WL 5/12/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[20];

ApplyDelays();

function cool_timescan_MWpulse

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq
gSG.bMod='IQ';% if totally off, change to '';%FUCK
gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq
gSG2.bMod='';

AfterPi = 300;
AfterLaser = 1000;

% gmSEQ.m : variable timing value
t_LaserEnd = gmSEQ.readout + gmSEQ.CtrGateDur * 2 + AfterPi;
t_ReferenceGate = gmSEQ.readout + gmSEQ.CtrGateDur + 50 - 500;


%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.m t_ReferenceGate+1500]; %t_ReferenceGate+1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q_2'); %for monitoring ctr gate WL 5/18/23
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.m t_ReferenceGate+1500]; %t_ReferenceGate+1500 WL 5/15/23
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

triglen = 30;
offset = 10;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1; 
gmSEQ.CHN(numel(gmSEQ.CHN)).T = offset + gmSEQ.m + gmSEQ.CtrGateDur;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = gmSEQ.pi+triglen;

bufferTime = 50; 

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1'); % MW switch on
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = offset + gmSEQ.m + gmSEQ.CtrGateDur-bufferTime;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = gmSEQ.pi + 2*bufferTime;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= 1500; %0 --> 1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= t_LaserEnd;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= t_LaserEnd+50+1500; %t_LaserEnd+50 --> t_LaserEnd+50+1500 WL 5/15/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.DEERpi;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[t_LaserEnd+gmSEQ.DEERpi+50000]; %600+30000 -> 50000 WL 5/12/23
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[20];

try
    if gSG.first
        disp('UPLLOADING TO AWG!')
        
        if gSG.ACmod % in AC modulation mode
            C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % X pulse
            C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1]; 
        else
            C_1 = [0 gmSEQ.pi 0 0 gSG.IQVoltage1]; % gSG.Freq = NV resonance frequeincy, gSG.SGbasefreq = f
            C_2 = [0 gmSEQ.pi 0 0+pi/2 0];
        end

        Length2 = gmSEQ.pi+1000; % ns
        clkRate2 = 2e9; % 2GHz
        % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
        % 560ns)
        Total2 = ceil(Length2*clkRate2/1e9/16)*16; % total number of points need "16x integer"
        chaseFunctionPool('stopChase', 1); pause(0.1);
        chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.1);
        chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.1);
        chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.1);
        chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
        chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
        % Function name, AWG #, Channel #, Total number of the points of the
        % sequence, time of the sequence repeat, 
        chaseFunctionPool('runChase', 1, 'false'); pause(0.1);
        
     
    end
catch
    disp('oops!')
end

ApplyDelays();

function Reference_timescan

global gmSEQ gSG gSG2
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';% if totally off, change to '';
gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq
gSG2.bMod='';

AfterPi = 300;
AfterLaser = 1000;

maxRFLength = 3000;

% gmSEQ.m : variable timing value
t_firstPi = gmSEQ.m + AfterLaser;
t_rf = t_firstPi + AfterPi;
t_secondPi = t_rf + maxRFLength + AfterPi; % 1000 is just a placeholder for the max rf drive length
t_readout = t_secondPi + AfterPi;

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.m-gmSEQ.CtrGateDur-50 t_readout];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 t_readout];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m 600];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= t_rf;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.DEERpi;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[t_readout+600+20000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[20];

ApplyDelays();

function hBN_polarization

global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

if strcmp(gmSEQ.meas,'APD') 
    gmSEQ.CtrGateDur = 1000;
end

Wait_p = 0.02e6;
% 
AfterPi = 500; % before laser detection
AfterLaser = 1000; % 
Detect_Window = 5000;
PulseGap = 30;
initial_wait = 1000;
%SpinLockGap = 2;
%%%%% Fixed sequence length %%%%%%

gmSEQ.m = ceil(gmSEQ.m/2)*2;

% A = [0 gmSEQ.readout 0 pi/2 0.7; ...
%     gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];
% [
% Length1 = gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+1000;
% clkRate1 = 1e9; pause(0.1);
% % used to be 0.05e9
% % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% % 560ns)
% Total1 = ceil(Length1*clkRate1/1e9/16)*16;
% chaseFunctionPool('stopChase',1); pause(0.1);
% chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
% chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
% chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
% pause(1);
% chaseFunctionPool('runChase',1,'false');


gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=6;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for the Chong sequence
gmSEQ.CHN(1).T = [initial_wait initial_wait+gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi initial_wait+gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi+1000+AfterLaser+gmSEQ.To+AfterPi ...
                  initial_wait+gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi+1000+AfterLaser+gmSEQ.To+AfterPi+gmSEQ.readout+initial_wait ...
                  initial_wait+gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi+1000+AfterLaser+gmSEQ.To+AfterPi+gmSEQ.readout+initial_wait+gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi ...
                  initial_wait+gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi+1000+AfterLaser+gmSEQ.To+AfterPi+gmSEQ.readout+initial_wait+gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi+1000+AfterLaser+gmSEQ.To+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout 1000 gmSEQ.readout gmSEQ.readout 1000 gmSEQ.readout];


% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% %gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-gmSEQ.CtrGateDur-1000 gmSEQ.CHN(1).T(3) gmSEQ.CHN(1).T(4)+gmSEQ.readout-gmSEQ.CtrGateDur-1000 gmSEQ.CHN(1).T(6)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; 
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[initial_wait+gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi+1000+AfterLaser-20 gmSEQ.CHN(1).T(4)+gmSEQ.readout+AfterLaser-20 ...
                               gmSEQ.CHN(1).T(5)+1000+AfterLaser-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m+40 gmSEQ.pi+40 gmSEQ.m+40]; % the trigger is open for these last two pulses


Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi);


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(6)+gmSEQ.readout-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[initial_wait+gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi+1000+AfterLaser gmSEQ.CHN(1).T(4)+gmSEQ.readout+AfterLaser]; % first is only rabi, second is pi+rabi
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[7000 gmSEQ.pi+AfterPi+1000+AfterLaser+gmSEQ.To+AfterPi+1000];

% for MW_AWG
if gSG.ACmod % in AC modulation mode

    % C_1 = [start, end, Freq, phase, Amp]
    % C_2 = [start, end, Freq, phase+pi/2, Amp]
    % phase = 0 --> +X pulse; pi/2 --> +Y, pi --> -X;  3*pi/2 --> -Y
    C_1 = [0 gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % X pulse
    C_2 = [0 gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
    
    
    D_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;... % X pulse
        gmSEQ.pi+AfterPi+1000+AfterLaser gmSEQ.pi+AfterPi+1000+AfterLaser+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
        gmSEQ.pi+AfterPi+1000+AfterLaser gmSEQ.pi+AfterPi+1000+AfterLaser+gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
%     end
else
    % never use without AC modulation
    C_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.halfpi 0 0 0;...
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    
    
    D_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.halfpi 0 0 0;...
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1; ...
        gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];

end

    Length2_2 = round(gmSEQ.m+1000); % this is good to go, length of first MW pulse +1000
    Length2_3 = round(gmSEQ.pi+AfterPi+1000+AfterLaser+gmSEQ.m+1000); % will I get a warning if this is still outputting signal?
    clkRate2 = 2e9;

 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1); % I port, C1 and D1
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch2_seg3.txt', Total2_3, 1, 1); % Q port, C2 and D2
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


ApplyDelays();

function RabiAPDQ
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

AfterPi = 1000; AfterLaser = 1000;

%
A = [0 gmSEQ.readout 0 pi/2 0.7; ...
    gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi+2000 0 pi/2 0.7];

Length = gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi+2000+gmSEQ.CtrGateDur+200;
clkRate = 0.05e9; pause(0.1); 
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total = ceil(Length*clkRate/1e9/16)*16;
chaseFunctionPool('stopChase', 1); pause(0.1);
chaseFunctionPool('setClkRate', 1, clkRate); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate/10^9, Length, 'wave_ch1.txt'); pause(0.1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase', 1, 'false');
  
%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=3;
gmSEQ.CHN(1).T=[gmSEQ.readout-gmSEQ.CtrGateDur-100 gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi+1000+1000+gmSEQ.CtrGateDur+200+1000];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')
    gmSEQ.CHN(1).DT=[1000 1000 1000];
end
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=gmSEQ.readout+AfterLaser;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=200;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout 2000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 100];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+AfterLaser-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m+100];

% for 2nd MW
if gSG.ACmod % in AC modulation mode
    B = [0 gmSEQ.m (gSG.Freq-gSG.SGbasefreq)/1e9 0 gSG.IQVoltage1];
    C = [0 gmSEQ.m (gSG.Freq-gSG.SGbasefreq)/1e9 pi/2 gSG.IQVoltage1];
else
    B = [0 gmSEQ.m 0 0 0];
    C = [0 gmSEQ.m 0 pi/2 gSG.IQVoltage1];
    
end
    Length2 = gmSEQ.m+1000;
    clkRate2 = 2e9; pause(0.1); 
    % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
    % 560ns)
    
    
    Total2 = ceil(Length2*clkRate2/1e9/16)*16;
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
    chaseFunctionPool('CreateSingleSegment',2, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
    chaseFunctionPool('CreateSingleSegment',2, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
    chaseFunctionPool('runChase', 2, 'false'); pause(0.2);


ApplyDelays();

function RabiAPDI_2ndMW
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

AfterPi = 500; AfterLaser = 2000;

%
% A = [0 gmSEQ.readout 0 pi/2 0.7; ...
%     gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi+2000 0 pi/2 0.7];
% 
% Length1 = gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi+2000+gmSEQ.CtrGateDur+200;
% 
% clkRate1 = 1e9;
% % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% % 560ns)
% Total1 = ceil(Length1*clkRate1/1e9/16)*16;
% chaseFunctionPool('stopChase', 1); pause(0.3);
% chaseFunctionPool('setClkRate', 1, clkRate1); pause(0.3);
% chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(0.5);
% chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
% pause(1);
% chaseFunctionPool('runChase', 1, 'false'); pause(0.2);
  
%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=3;
gmSEQ.CHN(1).T=[gmSEQ.readout-gmSEQ.CtrGateDur-1000 gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi+1000+1000+gmSEQ.CtrGateDur+200+1000];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')||strcmp(gmSEQ.meas,'Scope')
    gmSEQ.CHN(1).DT=[1000 1000 1000];
end
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=gmSEQ.readout+AfterLaser;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=500;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout 2000];

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+AfterLaser];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200];

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m+40];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m+40];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m];


% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B = [0 gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C = [0 gmSEQ.m (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B = [0 gmSEQ.m 0 pi/2 gSG.IQVoltage1];
    C = [0 gmSEQ.m 0 0 0];
end
    Length2 = gmSEQ.m+1000;
    clkRate2 = 2e9;
    % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
    % 560ns)
    Total2 = ceil(Length2*clkRate2/1e9/16)*16;
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
    chaseFunctionPool('CreateSingleSegment',2, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
    chaseFunctionPool('CreateSingleSegment',2, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
    chaseFunctionPool('runChase', 2, 'false'); pause(0.2);

ApplyDelays();

function RabiAPDQ_2ndMW
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=3;
gmSEQ.CHN(1).T=[gmSEQ.readout+100+gmSEQ.To+100 gmSEQ.readout+100+gmSEQ.To+100+10000+1000 gmSEQ.readout+100+gmSEQ.To+100+10000+1000+gmSEQ.CtrGateDur+200+1000];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')
    gmSEQ.CHN(1).DT=[1000 1000 1000];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=gmSEQ.readout+100;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=gmSEQ.m;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+100+gmSEQ.To+100 gmSEQ.readout+100+gmSEQ.To+100+10000+1000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout 10000 gmSEQ.CtrGateDur+200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 100];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];

ApplyDelays();

function RabiAPDI_3rdMW
global gmSEQ gSG3 gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

SignalGeneratorFunctionPool3('WritePow');
SignalGeneratorFunctionPool3('WriteFreq');
gSG3.bOn=1; SignalGeneratorFunctionPool3('RFOnOff');

AfterLaser = 1000;
AfterPi = 100;

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=3;
gmSEQ.CHN(1).T=[gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi+10000+1000 gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi+10000+1000+gmSEQ.CtrGateDur+200+1000];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')
    gmSEQ.CHN(1).DT=[1000 1000 1000];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=gmSEQ.readout+AfterLaser;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=gmSEQ.m;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.To+AfterPi+10000+1000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout 10000 gmSEQ.CtrGateDur+200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+1000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=gmSEQ.readout+1000-50;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=gmSEQ.m+100;

ApplyDelays();

function OptDetectWindow

global gmSEQ gSG
% gmSEQ: seqeuence, data, parameters
% gSG: signal generator

gSG.bfixedPow=1; % fix microwave power
gSG.bfixedFreq=1; % fix microwave ferq

gSG.bMod='IQ';
gSG.bModSrc='External';

AfterPi = 500; AfterLaser = 2000;

%%%%% Jon and Alex write something new %%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0'); % detection window
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi+gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi];
if strcmp(gmSEQ.meas,'SPCM') % we don't want it like this how to sweep!
    gmSEQ.CHN(1).DT=[gmSEQ.m gmSEQ.m];
else strcmp(gmSEQ.meas,'APD')
    gmSEQ.CHN(1).DT=[1000 1000];
end
    
% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG'); % AWG pulse trigger
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=gmSEQ.readout+AfterLaser;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=500;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi+40];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi+gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout gmSEQ.readout gmSEQ.readout];

%%%%%%%%%%%%%%%%%%%%%%%%
% for MW_AWG
if gSG.ACmod % in AC modulation mode
    % start_time end_time Freq Phase Amp
    B = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % gSG.Freq = NV resonang frequeincy, gSG.SGbasefreq = f0
    C = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C = [0 gmSEQ.pi 0 0 0];
end
    Length2 = gmSEQ.m+1000;
    clkRate2 = 2e9; % 2GHz
    % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
    % 560ns)
    Total2 = ceil(Length2*clkRate2/1e9/16)*16;
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
    chaseFunctionPool('CreateSingleSegment', 1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
    chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
    chaseFunctionPool('runChase', 1, 'false'); pause(0.2);

ApplyDelays();

function SpinLocking
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% gmSEQ.Diffwait

% SignalGeneratorFunctionPool2('WritePow');
% SignalGeneratorFunctionPool2('WriteFreq');
% gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

%LockingAmp = 0.4;

%mwlength=gmSEQ.m;
Wait_p = 20e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 30;
SpinLockGap = 2;

A = [0 gmSEQ.readout 0 pi/2 0.7; ...
    gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];


Length1 = gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;


gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--------------------------------------
% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-50 ...
      gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+100 ...
    gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+100];

% 

Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi+2*SpinLockGap+gmSEQ.m+PulseGap+gmSEQ.pi);


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];



% for MW_AWG
if gSG.ACmod % in AC modulation mode

else

    
    C_1 = [0 gmSEQ.pi/2 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2 0 3*pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi/2 0 0 0;...
           gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+gmSEQ.m 0 pi/2 gSG.IQVoltage1*gmSEQ.LockingAmp];
       
    D_1 = [0 gmSEQ.pi/2 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2 0 3*pi/2 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.pi/2 0 0 0;...
           gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+gmSEQ.m 0 pi/2 gSG.IQVoltage1*gmSEQ.LockingAmp;...
           gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
end
    %Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+1000);
    Length2_3 = round(gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+1000);
    clkRate2 = 2e9;

    %Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    %chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    %chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
        'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1, ...
        'wave_AWG2_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');

  
ApplyDelays();

function SpecialCooling
global gmSEQ gSG
gSG.bfixedPow = 1;
gSG.bfixedFreq = 1;
gSG.bMod = 'IQ';
gSG.bModSrc = 'External';
chaseFunctionPool('setClkRate', 2, gSG.AWGClockRate * 1e9); pause(0.1);
% If PL signal is collected via APD.
if strcmp(gmSEQ.meas,'APD') 
    gmSEQ.CtrGateDur = 1000;
end

gmSEQ.m = round(gmSEQ.m);
% Cooling sequence [pi/2_x->[t1(Omega_y) -> t2(-Omega_y)]^{N_0}]^{Cooling cycle}...

Wait_p = 10e6; % to wait for P1 to be fully unpolarized again
AfterPi = 2000;
AfterLaser = 2000;
Detect_Window = 5000;
PulseGap = 30;
SpinLockGap = 0; % The gap (in ns) between t1(Omega) and t2(-Omega).

SingleLen_C = 2 * SpinLockGap + gmSEQ.SLockT1 + gmSEQ.SLockT2; % Length of cooling segment [t1(Omega_y) -> t2(-Omega_y)]
LockLenCool = gmSEQ.LockN0 * SingleLen_C;

SingleLen_M = 1*(2*SpinLockGap+gmSEQ.SLockT1_M + gmSEQ.SLockT2_M); % Length of measuring segment [t1(Omega_y) -> t2(-Omega_y)]
LockLenMeasure = gmSEQ.m * SingleLen_M;

AfterLock = 1000;
Cooling_Readout = gmSEQ.Coolreadout;

CoolCycleT = Cooling_Readout + AfterLaser + gmSEQ.halfpi + LockLenCool + AfterLock;
CoolCycleT = ceil(CoolCycleT * gSG.AWGClockRate / 16) / (gSG.AWGClockRate / 16);

%% Pulse Blaster
%%% AOM
% Cooling
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise = 2 * (2 + gmSEQ.CoolCycle);
    gmSEQ.CHN(1).T = [];
    gmSEQ.CHN(1).DT = [];
    for n = 1 : gmSEQ.CoolCycle
        gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T, Wait_p + (n - 1) * CoolCycleT];
        gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT, Cooling_Readout];
    end
% Cooling - Measurement
    gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T, ...
        Wait_p + gmSEQ.CoolCycle * CoolCycleT + gmSEQ.CoolWait, ...
        Wait_p + gmSEQ.CoolCycle * CoolCycleT + gmSEQ.CoolWait ...
            + gmSEQ.readout + AfterLaser + gmSEQ.halfpi + LockLenMeasure ...
            + SpinLockGap + gmSEQ.halfpi + PulseGap + gmSEQ.pi+ AfterPi];
    gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT, gmSEQ.readout, Detect_Window]; 
% Differential Cooling
    Start_Sig_D = Wait_p + gmSEQ.CoolCycle * CoolCycleT + gmSEQ.CoolWait ...
        + gmSEQ.readout + AfterLaser + gmSEQ.halfpi + LockLenMeasure ...
        + SpinLockGap + gmSEQ.halfpi + PulseGap + gmSEQ.pi + AfterPi ...
        + Detect_Window + Wait_p;
    for n = 1 : gmSEQ.CoolCycle
        gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T, Start_Sig_D + (n - 1) * CoolCycleT];
        gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT, Cooling_Readout];
    end
% Differential Cooling - Measurement
    gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T, ...
        Start_Sig_D + gmSEQ.CoolCycle * CoolCycleT + gmSEQ.CoolWait, ...
        Start_Sig_D + gmSEQ.CoolCycle  *CoolCycleT + gmSEQ.CoolWait ...
            + gmSEQ.readout + AfterLaser + gmSEQ.halfpi + LockLenMeasure ...
            + SpinLockGap + gmSEQ.halfpi + PulseGap + gmSEQ.pi + AfterPi];
    gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT, gmSEQ.readout, Detect_Window];

%%% APD
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(1).T(gmSEQ.CoolCycle + 1) + gmSEQ.readout - gmSEQ.CtrGateDur - 1000, ...
    gmSEQ.CHN(1).T(gmSEQ.CoolCycle + 2), ...
    gmSEQ.CHN(1).T(2 * gmSEQ.CoolCycle + 3) + gmSEQ.readout - gmSEQ.CtrGateDur - 1000, ...
    gmSEQ.CHN(1).T(2 * gmSEQ.CoolCycle + 4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = repelem(gmSEQ.CtrGateDur, 1, 4);

% Note that for sequence length ~ 2ms / 20ms, the timing difference between
% PulseBlaster and AWG is ~ 10ns / 100ns

% MW Switch
% Cooling -> Cooling - Measurement
gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 2 + 2 * gmSEQ.CoolCycle;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [];
for n = 1 : gmSEQ.CoolCycle
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Wait_p + (n - 1) * CoolCycleT + Cooling_Readout + AfterLaser - 50]; % double the buffer around IQ.
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
        gmSEQ.halfpi + LockLenCool + 100];
end
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
    Wait_p + gmSEQ.CoolCycle * CoolCycleT + gmSEQ.CoolWait + gmSEQ.readout + AfterLaser - 50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
    gmSEQ.halfpi + LockLenMeasure + SpinLockGap + gmSEQ.halfpi + 100];
% Differential Cooling -> Differential Cooling - Measurement
for n = 1 : gmSEQ.CoolCycle
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Start_Sig_D + (n - 1) * CoolCycleT + Cooling_Readout + AfterLaser - 50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
        gmSEQ.halfpi + LockLenCool + 100];
end
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
    Start_Sig_D + gmSEQ.CoolCycle * CoolCycleT + gmSEQ.CoolWait + gmSEQ.readout + AfterLaser - 50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
    gmSEQ.halfpi + LockLenMeasure + SpinLockGap + gmSEQ.halfpi + PulseGap + gmSEQ.pi + 100];

%%% Dummy 1: to check the total length of the sequence.
Max_length = 2 * Wait_p + 2 * gmSEQ.CoolCycle * CoolCycleT ...
    + 2 * gmSEQ.CoolWait + 2 * gmSEQ.readout + 2 * Detect_Window ...
    + 2 * (AfterLaser + AfterPi + gmSEQ.halfpi + LockLenMeasure + SpinLockGap + gmSEQ.halfpi + PulseGap + gmSEQ.pi);
gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [0, Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [200, 200];

%%% AWG Trigger
% Each repeatition of the segement need one trigger, a total of 2 *
% (CoolCycle + 1) triggers are needed.
% Cooling -> Cooling - Measurement
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN = PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2 + gmSEQ.CoolCycle * 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [];
for n = 1 : gmSEQ.CoolCycle
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ... 
    Wait_p + (n - 1) * CoolCycleT + Cooling_Readout + AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, 500];
end
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
    Wait_p + gmSEQ.CoolCycle * CoolCycleT + gmSEQ.CoolWait + gmSEQ.readout + AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, 500];
% Differential Cooling -> Differential Cooling - Measurement
for n = 1:gmSEQ.CoolCycle
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
    Start_Sig_D + (n - 1) * CoolCycleT + Cooling_Readout + AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, 500];
end
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
    Start_Sig_D + gmSEQ.CoolCycle * CoolCycleT + gmSEQ.CoolWait + gmSEQ.readout + AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, 500]; 

%% AWG
%%% Initialization
chaseFunctionPool('stopChase', 2)
%%% Generating wave form
if gSG.ACmod
    WaveForm_1I = [];
    WaveForm_1Q = [];
%%%% Cooling / Heating Waveforms.
% |gmSEQ.CoolSwitch| controls whether cooling / heating is turned on. 
    if gmSEQ.CoolSwitch == 1 % Cooling
        WaveForm_1I = [WaveForm_1I; ...
            0, gmSEQ.halfpi, (gSG.SGbasefreq-gSG.Freq)/1e9, 0, gSG.IQVoltage1]; % The 1st pi/2_x pulse.
        WaveForm_1Q = [WaveForm_1Q; ...
            0, gmSEQ.halfpi, (gSG.SGbasefreq-gSG.Freq)/1e9, pi / 2, gSG.IQVoltage2];
    elseif gmSEQ.CoolSwitch == 2 % Heating
        WaveForm_1I = [WaveForm_1I; ...
            0, gmSEQ.halfpi, (gSG.SGbasefreq-gSG.Freq)/1e9, pi, gSG.IQVoltage1];
        WaveForm_1Q = [WaveForm_1Q; ...
            0, gmSEQ.halfpi, (gSG.SGbasefreq-gSG.Freq)/1e9, pi + pi / 2, gSG.IQVoltage2];
    elseif gmSEQ.CoolSwitch == 0 % Nothing
        WaveForm_1I = [WaveForm_1I; ...
            0, gmSEQ.halfpi, 0, 0, 0];
        WaveForm_1Q = [WaveForm_1Q; ...
            0, gmSEQ.halfpi, 0, 0, 0];
    end
    
    for n = 1 : gmSEQ.LockN0 % add segments of [t1(Omega_y) -> t2(-Omega_y)]
       WaveForm_1I = [WaveForm_1I; ...
           gmSEQ.halfpi + (n - 1) * SingleLen_C + SpinLockGap, ...
               gmSEQ.halfpi + (n - 1) * SingleLen_C + SpinLockGap + gmSEQ.SLockT1, ...
               (gSG.SGbasefreq-gSG.Freq)/1e9, ...
               pi / 2, ...
               gSG.IQVoltage1 * gmSEQ.SAmp1; ...
           gmSEQ.halfpi + (n - 1) * SingleLen_C + SpinLockGap + gmSEQ.SLockT1 + SpinLockGap, ...
               gmSEQ.halfpi + (n - 1) * SingleLen_C + SpinLockGap + gmSEQ.SLockT1 + SpinLockGap + gmSEQ.SLockT2, ...
               (gSG.SGbasefreq-gSG.Freq)/1e9, ...
               3 * pi / 2, ...
               gSG.IQVoltage1 * gmSEQ.SAmp2];
       WaveForm_1Q = [WaveForm_1Q; ...
           gmSEQ.halfpi + (n - 1) * SingleLen_C + SpinLockGap, ...
               gmSEQ.halfpi + (n - 1) * SingleLen_C + SpinLockGap + gmSEQ.SLockT1, ...
               (gSG.SGbasefreq-gSG.Freq)/1e9, ...
               pi / 2 + pi / 2, ...
               gSG.IQVoltage2 * gmSEQ.SAmp1; ...
           gmSEQ.halfpi + (n - 1) * SingleLen_C + SpinLockGap + gmSEQ.SLockT1 + SpinLockGap, ...
               gmSEQ.halfpi + (n - 1) * SingleLen_C + SpinLockGap + gmSEQ.SLockT1 + SpinLockGap + gmSEQ.SLockT2, ...
               (gSG.SGbasefreq-gSG.Freq)/1e9, ...
               3 * pi / 2 + pi / 2, ...
               gSG.IQVoltage2 * gmSEQ.SAmp2];     
    end
    WaveForm_1Length = ceil((gmSEQ.halfpi + LockLenCool + 1000) / (16 / gSG.AWGClockRate)) ...
        *(16 / gSG.AWGClockRate);
    WaveForm_1PointNum = WaveForm_1Length * gSG.AWGClockRate;
%%%% Measuring Waveforms.    
    WaveForm_2I = [0, gmSEQ.halfpi, (gSG.SGbasefreq-gSG.Freq)/1e9, 0, gSG.IQVoltage1]; 
    WaveForm_2Q = [0, gmSEQ.halfpi, (gSG.SGbasefreq-gSG.Freq)/1e9, pi/2, gSG.IQVoltage2];    
    for n = 1 : gmSEQ.m  % add segments of [t1(Omega_y) -> t2(-Omega_y)]
        WaveForm_2I = [WaveForm_2I; ...
           gmSEQ.halfpi + (n - 1) * SingleLen_M + SpinLockGap, ...
               gmSEQ.halfpi + (n - 1) * SingleLen_M + SpinLockGap + gmSEQ.SLockT1_M, ...
               (gSG.SGbasefreq-gSG.Freq)/1e9, ...
               pi / 2, gSG.IQVoltage1 * gmSEQ.SAmp1_M;...
           gmSEQ.halfpi + (n - 1) * SingleLen_M + SpinLockGap + gmSEQ.SLockT1_M + SpinLockGap, ...
               gmSEQ.halfpi + (n - 1) * SingleLen_M + SpinLockGap + gmSEQ.SLockT1_M + SpinLockGap + gmSEQ.SLockT2_M, ...
               (gSG.SGbasefreq-gSG.Freq)/1e9, ...
               3 * pi / 2, ...
               gSG.IQVoltage1 * gmSEQ.SAmp2_M];
        WaveForm_2Q = [WaveForm_2Q; ...
           gmSEQ.halfpi + (n - 1) * SingleLen_M + SpinLockGap, ...
               gmSEQ.halfpi + (n - 1) * SingleLen_M + SpinLockGap + gmSEQ.SLockT1_M, ...
               (gSG.SGbasefreq-gSG.Freq)/1e9, ...
               pi / 2 + pi / 2, gSG.IQVoltage2*gmSEQ.SAmp1_M;...
           gmSEQ.halfpi + (n - 1) * SingleLen_M + SpinLockGap + gmSEQ.SLockT1_M + SpinLockGap, ...
               gmSEQ.halfpi + (n - 1) * SingleLen_M + SpinLockGap + gmSEQ.SLockT1_M + SpinLockGap + gmSEQ.SLockT2_M, ...
               (gSG.SGbasefreq-gSG.Freq)/1e9, ...
               3 * pi / 2 + pi / 2, ...
               gSG.IQVoltage2 * gmSEQ.SAmp2_M];   
    end
    WaveForm_2I = [WaveForm_2I; ...
        gmSEQ.halfpi + gmSEQ.m * SingleLen_M + SpinLockGap, ...
            gmSEQ.halfpi + gmSEQ.m * SingleLen_M + SpinLockGap + gmSEQ.halfpi,...
            (gSG.SGbasefreq-gSG.Freq)/1e9, ...
            2 * pi / 2, ...
            gSG.IQVoltage1];
    WaveForm_2Q = [WaveForm_2Q; ...
        gmSEQ.halfpi + gmSEQ.m * SingleLen_M + SpinLockGap, ...
            gmSEQ.halfpi + gmSEQ.m * SingleLen_M + SpinLockGap + gmSEQ.halfpi,...
            (gSG.SGbasefreq-gSG.Freq)/1e9, ...
            2 * pi / 2 + pi / 2, ...
            gSG.IQVoltage2];
    
%%%% Differential Measuring Waveforms. Just add another pi_y pulse at the
%%%% end.
    WaveForm_3I = [WaveForm_2I; ...
        gmSEQ.halfpi + gmSEQ.m * SingleLen_M + SpinLockGap + gmSEQ.halfpi + PulseGap, ...
            gmSEQ.halfpi + gmSEQ.m * SingleLen_M + SpinLockGap + gmSEQ.halfpi + PulseGap + gmSEQ.pi, ...
            (gSG.SGbasefreq-gSG.Freq)/1e9, ...
            pi / 2, gSG.IQVoltage1];
    WaveForm_3Q = [WaveForm_2Q; ...
        gmSEQ.halfpi + gmSEQ.m * SingleLen_M + SpinLockGap + gmSEQ.halfpi + PulseGap, ...
            gmSEQ.halfpi + gmSEQ.m * SingleLen_M + SpinLockGap + gmSEQ.halfpi + PulseGap + gmSEQ.pi, ...
            (gSG.SGbasefreq-gSG.Freq)/1e9, ...
            pi / 2 + pi / 2, gSG.IQVoltage2]; 
    
    WaveForm_2Length = ceil((gmSEQ.halfpi + LockLenMeasure + SpinLockGap + gmSEQ.halfpi + PulseGap + gmSEQ.pi + 1000) / (16 / gSG.AWGClockRate)) ...
        * (16 / gSG.AWGClockRate);
    WaveForm_2PointNum = WaveForm_2Length * gSG.AWGClockRate;
    WaveForm_3Length = WaveForm_2Length;
    WaveForm_3PointNum = WaveForm_2PointNum;
    
else
    questdlg('Only AC mnodulation works for now, please check AC modulation~',...
        'Heating / Cooling Sequence', 'Cancel');
end
%%% Create Wave Form Text Files
chaseFunctionPool('createWaveform', WaveForm_1I, gSG.AWGClockRate, WaveForm_1Length, 'SpecialCooling_I_seg1.txt'); pause(0.5);
chaseFunctionPool('createWaveform', WaveForm_1Q, gSG.AWGClockRate, WaveForm_1Length, 'SpecialCooling_Q_seg1.txt'); pause(0.5);
chaseFunctionPool('createWaveform', WaveForm_2I, gSG.AWGClockRate, WaveForm_2Length, 'SpecialCooling_I_seg2.txt'); pause(0.5);
chaseFunctionPool('createWaveform', WaveForm_2Q, gSG.AWGClockRate, WaveForm_2Length, 'SpecialCooling_Q_seg2.txt'); pause(0.5);
chaseFunctionPool('createWaveform', WaveForm_3I, gSG.AWGClockRate, WaveForm_3Length, 'SpecialCooling_I_seg3.txt'); pause(0.5);
chaseFunctionPool('createWaveform', WaveForm_3Q, gSG.AWGClockRate, WaveForm_3Length, 'SpecialCooling_Q_seg3.txt'); pause(0.5);
%%% Create Wave Form Structs -> Pass Segments to AWG
if gmSEQ.CoolCycle == 0
    chaseFunctionPool('createSegStruct', 'SpecialCooling_SegStruct_I.txt', ...
        'SpecialCooling_I_seg2.txt', WaveForm_2PointNum, 1, 1, ...
        'SpecialCooling_I_seg3.txt', WaveForm_3PointNum, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SpecialCooling_SegStruct_Q.txt', ...
        'SpecialCooling_Q_seg2.txt', WaveForm_2PointNum, 1, 1, ...
        'SpecialCooling_Q_seg3.txt', WaveForm_3PointNum, 1, 1);
    pause(0.5);
    chaseFunctionPool('CreateSegments', 2, 1, ...
        2, ...
        2047, 2047, 'SpecialCooling_SegStruct_I.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, ...
        2, ...
        2047, 2047, 'SpecialCooling_SegStruct_Q.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');
elseif gmSEQ.CoolCycle == 1
    chaseFunctionPool('createSegStruct', 'SpecialCooling_SegStruct_I.txt', ...
        'SpecialCooling_I_seg1.txt', WaveForm_1PointNum, 1, 1, ...
        'SpecialCooling_I_seg2.txt', WaveForm_2PointNum, 1, 1, ...
        'SpecialCooling_I_seg1.txt', WaveForm_1PointNum, 1, 1, ...
        'SpecialCooling_I_seg3.txt', WaveForm_3PointNum, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SpecialCooling_SegStruct_Q.txt', ...
        'SpecialCooling_Q_seg1.txt', WaveForm_1PointNum, 1, 1, ...
        'SpecialCooling_Q_seg2.txt', WaveForm_2PointNum, 1, 1, ...
        'SpecialCooling_Q_seg1.txt', WaveForm_1PointNum, 1, 1, ...
        'SpecialCooling_Q_seg3.txt', WaveForm_3PointNum, 1, 1);
    pause(0.5);
    chaseFunctionPool('CreateSegments', 2, 1, ...
        4, ...
        2047, 2047, 'SpecialCooling_SegStruct_I.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, ...
        4, ...
        2047, 2047, 'SpecialCooling_SegStruct_Q.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');
else
chaseFunctionPool('createSegStruct', 'SpecialCooling_SegStruct_I.txt', ...
    'SpecialCooling_I_seg1.txt', WaveForm_1PointNum, 1, 1, ... % The first repeatition cannot be looped and must be triggered, so must be left out.
    'SpecialCooling_I_seg1.txt', WaveForm_1PointNum, gmSEQ.CoolCycle - 1, 1, ...
    'SpecialCooling_I_seg2.txt', WaveForm_2PointNum, 1, 1, ...
    'SpecialCooling_I_seg1.txt', WaveForm_1PointNum, 1, 1, ... % This one just to make sure things are symmetric.
    'SpecialCooling_I_seg1.txt', WaveForm_1PointNum, gmSEQ.CoolCycle - 1, 1, ...
    'SpecialCooling_I_seg3.txt', WaveForm_3PointNum, 1, 1);
pause(0.5);
chaseFunctionPool('createSegStruct', 'SpecialCooling_SegStruct_Q.txt', ...
    'SpecialCooling_Q_seg1.txt', WaveForm_1PointNum, 1, 1, ... 
    'SpecialCooling_Q_seg1.txt', WaveForm_1PointNum, gmSEQ.CoolCycle - 1, 1, ...
    'SpecialCooling_Q_seg2.txt', WaveForm_2PointNum, 1, 1, ...
    'SpecialCooling_Q_seg1.txt', WaveForm_1PointNum, 1, 1, ...
    'SpecialCooling_Q_seg1.txt', WaveForm_1PointNum, gmSEQ.CoolCycle - 1, 1, ...
    'SpecialCooling_Q_seg3.txt', WaveForm_3PointNum, 1, 1);
pause(0.5);    
chaseFunctionPool('CreateSegments', 2, 1, ...
    6, ...
    2047, 2047, 'SpecialCooling_SegStruct_I.txt', 'false');
pause(3); % this pause seems to be important, otherwise the loading is not right occassionally
chaseFunctionPool('CreateSegments', 2, 2, ...
    6, ...
    2047, 2047, 'SpecialCooling_SegStruct_Q.txt', 'false');
pause(3); % this pause seems to be important, otherwise the loading is not right occassionally
%%% Run AWG.
chaseFunctionPool('runChase', 2, 'false');

end
ApplyDelays();  

function SpecialCooling2_FixN_MeasSeparate

% In this sequence, the measurement sequence still use special cooling2,but
% has its own parameter sets

global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% Sequence t1(Omega) - t2(-Omega) - t1 - t2 ...

% SignalGeneratorFunctionPool2('WritePow');
% SignalGeneratorFunctionPool2('WriteFreq');
% gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

PulseN = gmSEQ.m;
if PulseN>50000
   warning('Too many pulses? check the code');
   PulseN = 1;
end
    
Wait_p = 3e6; % to wait for P1 to be fully unpolarized again

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 30;
SpinLockGap = 2;

SingleLen_C = 1*(2*SpinLockGap+gmSEQ.SLockT1 + gmSEQ.SLockT2);
LockLenCool = gmSEQ.LockingPulseN0*SingleLen_C;

SingleLen_M = 1*(2*SpinLockGap+gmSEQ.SLockT1_M + gmSEQ.SLockT2_M);
LockLenMeasure = PulseN*SingleLen_M;

LockingNum = gmSEQ.LockingNum;
AfterLock = 500;

Cooling_Readout = gmSEQ.Coolreadout;

CoolCycleT = Cooling_Readout+AfterLaser+gmSEQ.halfpi+LockLenCool+AfterLock;
waveformPath= 'D:\MATLAB_Code\MATLAB_Code_2AWG\mytoolboxes\dax22000_user_sw\dax22000_user_sw\waveform';

%%% start Laser pulse sequence

% Measurement sequence
    A1 = [0 gmSEQ.readout 0 pi/2 0.7; ...
    gmSEQ.readout+AfterLaser+gmSEQ.halfpi+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.halfpi+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];
% Cooling sequence   
    A2 = [0 Cooling_Readout 0 pi/2 0.7];
    
    Length1_A1 = round(gmSEQ.readout+AfterLaser+gmSEQ.halfpi+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+1000);
    Length1_A2 = round(Cooling_Readout+1000);
    
    clkRate1 = 0.05e9; pause(0.1);

    Total1_A1 = ceil(Length1_A1*clkRate1/1e9/16)*16;
    Total1_A2 = ceil(Length1_A2*clkRate1/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate', 1, clkRate1); pause(0.3);
    chaseFunctionPool('createWaveform', A1, clkRate1/10^9, Length1_A1, 'wave_AWG1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', A2, clkRate1/10^9, Length1_A2, 'wave_AWG1_seg2.txt'); pause(0.5);
    
    % create the segment using a for loop
    Laser_Cooling_Struct = [{'createSegStruct'}, {'AWG1_SegStruct_ch1.txt'}];
    for zz = 1:LockingNum
       Laser_Cooling_Struct = [Laser_Cooling_Struct, {'wave_AWG1_seg2.txt'}, {Total1_A2}, {1}, {1}];
    end
    Laser_Cooling_Struct = [Laser_Cooling_Struct, {'wave_AWG1_seg1.txt'}, {Total1_A1}, {1}, {1}];
    
    
    filename= fullfile(waveformPath,Laser_Cooling_Struct{2});
            fid= fopen(filename,'w');
            for zz = 1:(length(Laser_Cooling_Struct)-2)/4
                if zz ~= (length(Laser_Cooling_Struct)-2)/4
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct{4*(zz-1)+3}),Laser_Cooling_Struct{4*(zz-1)+4},Laser_Cooling_Struct{4*(zz-1)+5},Laser_Cooling_Struct{4*(zz-1)+6});
                else
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct{4*(zz-1)+3}), Laser_Cooling_Struct{4*(zz-1)+4},Laser_Cooling_Struct{4*(zz-1)+5},Laser_Cooling_Struct{4*(zz-1)+6});
                end
            end
            fclose(fid);

    pause(0.5);

    
    chaseFunctionPool('CreateSegments', 1, 1, LockingNum+1, 2047, 2047, 'AWG1_SegStruct_ch1.txt', 'false');
    pause(2); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 1, 'false');
    
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=2*(2+LockingNum);

    gmSEQ.CHN(1).T = [];
    gmSEQ.CHN(1).DT = [];
    for kkk = 1:LockingNum
        gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Wait_p+(kkk-1)*CoolCycleT];
        gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT Cooling_Readout];
    end
    gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Wait_p+LockingNum*CoolCycleT+gmSEQ.CoolWait Wait_p+LockingNum*CoolCycleT+gmSEQ.CoolWait+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi];
    gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];
    
    Start_Sig_D = Wait_p+LockingNum*CoolCycleT+gmSEQ.CoolWait+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;
    
    for kkk = 1:LockingNum
        gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D+(kkk-1)*CoolCycleT];
        gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT Cooling_Readout];
    end
    gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D+LockingNum*CoolCycleT+gmSEQ.CoolWait Start_Sig_D+LockingNum*CoolCycleT+gmSEQ.CoolWait+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi];
    gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2+2*LockingNum;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [];
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+(kkk-1)*CoolCycleT];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 1000];
    end
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+LockingNum*CoolCycleT+gmSEQ.CoolWait];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 1000];
    
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+(kkk-1)*CoolCycleT];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 1000];
    end
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+LockingNum*CoolCycleT+gmSEQ.CoolWait];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 1000];
    
    
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(LockingNum+1)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(LockingNum+2) gmSEQ.CHN(1).T(2*LockingNum+3)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(2*LockingNum+4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--------------------------------------
% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 2 + 2*LockingNum; % use 8 pi/2 P1 pulse spacing 10us away to mix P1

if LockingNum == 0
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p++gmSEQ.CoolWait+gmSEQ.readout+AfterLaser-50 ...
    gmSEQ.CHN(1).T(3)++gmSEQ.CoolWait+gmSEQ.readout+AfterLaser-50];

    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+100 ...
    gmSEQ.halfpi+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+100];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[];
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+(kkk-1)*CoolCycleT+Cooling_Readout+AfterLaser-50];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.halfpi+LockLenCool+100];
    end
    
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+LockingNum*CoolCycleT+gmSEQ.CoolWait+gmSEQ.readout+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.halfpi+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+100];
    
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+(kkk-1)*CoolCycleT+Cooling_Readout+AfterLaser-50];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.halfpi+LockLenCool+100];
    end
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+LockingNum*CoolCycleT+gmSEQ.CoolWait+gmSEQ.readout+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.halfpi+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+100];
       
    
end
% 

Max_length = 2*Wait_p + 2*LockingNum*CoolCycleT + 2*gmSEQ.CoolWait+ 2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.halfpi+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi);


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2+2*LockingNum;

gmSEQ.CHN(numel(gmSEQ.CHN)).T=[];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[];
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+(kkk-1)*CoolCycleT+Cooling_Readout+AfterLaser];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 500];
    end
    
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+LockingNum*CoolCycleT+gmSEQ.CoolWait+gmSEQ.readout+AfterLaser];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 500];
    
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+(kkk-1)*CoolCycleT+Cooling_Readout+AfterLaser];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 500];
    end
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+LockingNum*CoolCycleT+gmSEQ.CoolWait+gmSEQ.readout+AfterLaser];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 500];
       

% for MW_AWG
if gSG.ACmod % in AC modulation mode

else
    
    % cooling sequence
    
    % only removing the initial pi pulses in cooling
    if gmSEQ.CoolSwitch == 0
    B_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1*0];
    elseif gmSEQ.CoolSwitch == 1 % cooling
    B_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1];    
    elseif gmSEQ.CoolSwitch == 2 % heating
    B_1 = [0 gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];    
    end
    B_2 = [0 gmSEQ.halfpi 0 0 0];
    for zzz = 1:gmSEQ.LockingPulseN0
       %B_1 = [B_1];
      
       B_2 = [B_2; ...
           gmSEQ.halfpi+(zzz-1)*SingleLen_C+SpinLockGap gmSEQ.halfpi+(zzz-1)*SingleLen_C+SpinLockGap+gmSEQ.SLockT1 0 pi/2 gSG.IQVoltage1*gmSEQ.SAmp1; ...
           gmSEQ.halfpi+(zzz-1)*SingleLen_C+SpinLockGap+gmSEQ.SLockT1+SpinLockGap gmSEQ.halfpi+(zzz-1)*SingleLen_C+SpinLockGap+gmSEQ.SLockT1+SpinLockGap+gmSEQ.SLockT2 0 3*pi/2 gSG.IQVoltage1*gmSEQ.SAmp2];
    end
  

    % measuring sequence Bright signal
    

    C_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1]; 
    C_2 = [0 gmSEQ.halfpi 0 0 0];
    for zzz = 1:PulseN
             
       C_2 = [C_2; ...
           gmSEQ.halfpi+(zzz-1)*SingleLen_M+SpinLockGap gmSEQ.halfpi+(zzz-1)*SingleLen_M+SpinLockGap+gmSEQ.SLockT1_M 0 pi/2 gSG.IQVoltage1*gmSEQ.SAmp1_M; ...
           gmSEQ.halfpi+(zzz-1)*SingleLen_M+SpinLockGap+gmSEQ.SLockT1_M+SpinLockGap gmSEQ.halfpi+(zzz-1)*SingleLen_M+SpinLockGap+gmSEQ.SLockT1_M+SpinLockGap+gmSEQ.SLockT2_M 0 3*pi/2 gSG.IQVoltage1*gmSEQ.SAmp2_M];
          
    end
    
            C_1 = [C_1;...
          gmSEQ.halfpi+PulseN*SingleLen_M+SpinLockGap gmSEQ.halfpi+PulseN*SingleLen_M+SpinLockGap+gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];
      
    % measuring sequence Dark signal
    D_1 = C_1;
    D_2 = [C_2;
           gmSEQ.halfpi+PulseN*SingleLen_M+SpinLockGap+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+PulseN*SingleLen_M+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    
end

    Length2_1 = round(gmSEQ.halfpi+LockLenCool+SpinLockGap+1000);
    Length2_2 = round(gmSEQ.halfpi+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    Length2_3 = round(gmSEQ.halfpi+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
     
        % create the segment using a for loop
    Laser_Cooling_Struct_MWch1 = [{'createSegStruct'}, {'AWG2_SegStruct_ch1.txt'}];
    Laser_Cooling_Struct_MWch2 = [{'createSegStruct'}, {'AWG2_SegStruct_ch2.txt'}];
    for zz = 1:LockingNum
       Laser_Cooling_Struct_MWch1 = [Laser_Cooling_Struct_MWch1, {'wave_AWG2_ch1_seg1.txt'}, {Total2_1}, {1}, {1}];
       Laser_Cooling_Struct_MWch2 = [Laser_Cooling_Struct_MWch2, {'wave_AWG2_ch2_seg1.txt'}, {Total2_1}, {1}, {1}];
    end
    Laser_Cooling_Struct_MWch1 = [Laser_Cooling_Struct_MWch1, {'wave_AWG2_ch1_seg2.txt'}, {Total2_2}, {1}, {1}];
    Laser_Cooling_Struct_MWch2 = [Laser_Cooling_Struct_MWch2, {'wave_AWG2_ch2_seg2.txt'}, {Total2_2}, {1}, {1}];
    
    for zz = 1:LockingNum
       Laser_Cooling_Struct_MWch1 = [Laser_Cooling_Struct_MWch1, {'wave_AWG2_ch1_seg1.txt'}, {Total2_1}, {1}, {1}];
       Laser_Cooling_Struct_MWch2 = [Laser_Cooling_Struct_MWch2, {'wave_AWG2_ch2_seg1.txt'}, {Total2_1}, {1}, {1}];
    end
    Laser_Cooling_Struct_MWch1 = [Laser_Cooling_Struct_MWch1, {'wave_AWG2_ch1_seg3.txt'}, {Total2_3}, {1}, {1}];
    Laser_Cooling_Struct_MWch2 = [Laser_Cooling_Struct_MWch2, {'wave_AWG2_ch2_seg3.txt'}, {Total2_3}, {1}, {1}]; 
    
    %waveformPath= 'D:\MATLAB_Code\MATLAB_Code_2AWG\mytoolboxes\dax22000_user_sw\dax22000_user_sw\waveform';
    filename= fullfile(waveformPath,Laser_Cooling_Struct_MWch1{2});
            fid= fopen(filename,'w');
            for zz = 1:(length(Laser_Cooling_Struct_MWch1)-2)/4
                if zz ~= (length(Laser_Cooling_Struct_MWch1)-2)/4
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct_MWch1{4*(zz-1)+3}),Laser_Cooling_Struct_MWch1{4*(zz-1)+4},Laser_Cooling_Struct_MWch1{4*(zz-1)+5},Laser_Cooling_Struct_MWch1{4*(zz-1)+6});
                else
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct_MWch1{4*(zz-1)+3}),Laser_Cooling_Struct_MWch1{4*(zz-1)+4},Laser_Cooling_Struct_MWch1{4*(zz-1)+5},Laser_Cooling_Struct_MWch1{4*(zz-1)+6});
                end
            end
            fclose(fid);
            
     filename= fullfile(waveformPath,Laser_Cooling_Struct_MWch2{2});
            fid= fopen(filename,'w');
            for zz = 1:(length(Laser_Cooling_Struct_MWch2)-2)/4
                if zz ~= (length(Laser_Cooling_Struct_MWch2)-2)/4
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct_MWch2{4*(zz-1)+3}),Laser_Cooling_Struct_MWch2{4*(zz-1)+4},Laser_Cooling_Struct_MWch2{4*(zz-1)+5},Laser_Cooling_Struct_MWch2{4*(zz-1)+6});
                else
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct_MWch2{4*(zz-1)+3}),Laser_Cooling_Struct_MWch2{4*(zz-1)+4},Laser_Cooling_Struct_MWch2{4*(zz-1)+5},Laser_Cooling_Struct_MWch2{4*(zz-1)+6});
                end
            end
            fclose(fid);
    

    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 2*LockingNum+2, 2047, 2047, 'AWG2_SegStruct_ch1.txt', 'false');
    pause(2); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 2*LockingNum+2, 2047, 2047, 'AWG2_SegStruct_ch2.txt', 'false');
    pause(2); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');
    pause(1);
ApplyDelays();    


function SpecialCooling2_FixN_SpinLockingMeasure
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% Sequence t1(Omega) - t2(-Omega) - t1 - t2 ...

% SignalGeneratorFunctionPool2('WritePow');
% SignalGeneratorFunctionPool2('WriteFreq');
% gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

% PulseN = gmSEQ.m;
% if PulseN>50000
%    warning('Too many pulses? check the code');
%    PulseN = 1;
% end
    
Wait_p = 15e6; % to wait for P1 to be fully unpolarized again

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 30;
SpinLockGap = 2;

SingleLen = 1*(2*SpinLockGap+gmSEQ.SLockT1 + gmSEQ.SLockT2);
LockLenMeasure = gmSEQ.m;
LockLenCool = gmSEQ.LockingPulseN0*SingleLen;

LockingNum = gmSEQ.LockingNum;
AfterLock = 500;

Cooling_Readout = gmSEQ.Coolreadout;

CoolCycleT = Cooling_Readout+AfterLaser+gmSEQ.halfpi+LockLenCool+AfterLock;
waveformPath= 'D:\MATLAB_Code\MATLAB_Code_2AWG\mytoolboxes\dax22000_user_sw\dax22000_user_sw\waveform';

%%% start Laser pulse sequence

% Measurement sequence
    A1 = [0 gmSEQ.readout 0 pi/2 0.7; ...
    gmSEQ.readout+AfterLaser+gmSEQ.halfpi+SpinLockGap+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.halfpi+SpinLockGap+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];
% Cooling sequence   
    A2 = [0 Cooling_Readout 0 pi/2 0.7];
    
    Length1_A1 = round(gmSEQ.readout+AfterLaser+gmSEQ.halfpi+SpinLockGap+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+1000);
    Length1_A2 = round(Cooling_Readout+1000);
    
    clkRate1 = 0.05e9; pause(0.1);

    Total1_A1 = ceil(Length1_A1*clkRate1/1e9/16)*16;
    Total1_A2 = ceil(Length1_A2*clkRate1/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate', 1, clkRate1); pause(0.3);
    chaseFunctionPool('createWaveform', A1, clkRate1/10^9, Length1_A1, 'wave_AWG1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', A2, clkRate1/10^9, Length1_A2, 'wave_AWG1_seg2.txt'); pause(0.5);
    
    % create the segment using a for loop
    Laser_Cooling_Struct = [{'createSegStruct'}, {'AWG1_SegStruct_ch1.txt'}];
    for zz = 1:LockingNum
       Laser_Cooling_Struct = [Laser_Cooling_Struct, {'wave_AWG1_seg2.txt'}, {Total1_A2}, {1}, {1}];
    end
    Laser_Cooling_Struct = [Laser_Cooling_Struct, {'wave_AWG1_seg1.txt'}, {Total1_A1}, {1}, {1}];
    
    
    filename= fullfile(waveformPath,Laser_Cooling_Struct{2});
            fid= fopen(filename,'w');
            for zz = 1:(length(Laser_Cooling_Struct)-2)/4
                if zz ~= (length(Laser_Cooling_Struct)-2)/4
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct{4*(zz-1)+3}),Laser_Cooling_Struct{4*(zz-1)+4},Laser_Cooling_Struct{4*(zz-1)+5},Laser_Cooling_Struct{4*(zz-1)+6});
                else
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct{4*(zz-1)+3}), Laser_Cooling_Struct{4*(zz-1)+4},Laser_Cooling_Struct{4*(zz-1)+5},Laser_Cooling_Struct{4*(zz-1)+6});
                end
            end
            fclose(fid);

    pause(0.5);

    
    chaseFunctionPool('CreateSegments', 1, 1, LockingNum+1, 2047, 2047, 'AWG1_SegStruct_ch1.txt', 'false');
    pause(2); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 1, 'false');
    
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=2*(2+LockingNum);

    gmSEQ.CHN(1).T = [];
    gmSEQ.CHN(1).DT = [];
    for kkk = 1:LockingNum
        gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Wait_p+(kkk-1)*CoolCycleT];
        gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT Cooling_Readout];
    end
    gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Wait_p+LockingNum*CoolCycleT Wait_p+LockingNum*CoolCycleT+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+SpinLockGap+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi];
    gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];
    
    Start_Sig_D = Wait_p+LockingNum*CoolCycleT+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+SpinLockGap+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;
    
    for kkk = 1:LockingNum
        gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D+(kkk-1)*CoolCycleT];
        gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT Cooling_Readout];
    end
    gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D+LockingNum*CoolCycleT Start_Sig_D+LockingNum*CoolCycleT+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+SpinLockGap+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi];
    gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2+2*LockingNum;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [];
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+(kkk-1)*CoolCycleT];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 1000];
    end
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+LockingNum*CoolCycleT];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 1000];
    
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+(kkk-1)*CoolCycleT];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 1000];
    end
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+LockingNum*CoolCycleT];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 1000];
    
    
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(LockingNum+1)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(LockingNum+2) gmSEQ.CHN(1).T(2*LockingNum+3)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(2*LockingNum+4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--------------------------------------
% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 2 + 2*LockingNum; % use 8 pi/2 P1 pulse spacing 10us away to mix P1

if LockingNum == 0
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-50 ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-50];

    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+SpinLockGap+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+100 ...
    gmSEQ.halfpi+SpinLockGap+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+100];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[];
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+(kkk-1)*CoolCycleT+Cooling_Readout+AfterLaser-50];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.halfpi+LockLenCool+100];
    end
    
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+LockingNum*CoolCycleT+gmSEQ.readout+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.halfpi+SpinLockGap+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+100];
    
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+(kkk-1)*CoolCycleT+Cooling_Readout+AfterLaser-50];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.halfpi+LockLenCool+100];
    end
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+LockingNum*CoolCycleT+gmSEQ.readout+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.halfpi+SpinLockGap+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+100];
       
    
end
% 

Max_length = 2*Wait_p + 2*LockingNum*CoolCycleT +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.halfpi+SpinLockGap+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi);


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2+2*LockingNum;

gmSEQ.CHN(numel(gmSEQ.CHN)).T=[];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[];
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+(kkk-1)*CoolCycleT+Cooling_Readout+AfterLaser];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 500];
    end
    
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+LockingNum*CoolCycleT+gmSEQ.readout+AfterLaser];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 500];
    
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+(kkk-1)*CoolCycleT+Cooling_Readout+AfterLaser];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 500];
    end
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+LockingNum*CoolCycleT+gmSEQ.readout+AfterLaser];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 500];
       

% for MW_AWG
if gSG.ACmod % in AC modulation mode

else
    
    % cooling sequence
    
    % only removing the initial pi pulses in cooling
    if gmSEQ.CoolSwitch == 0
    B_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1*0];
    elseif gmSEQ.CoolSwitch == 1 % cooling
    B_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1];    
    elseif gmSEQ.CoolSwitch == 2 % heating
    B_1 = [0 gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];    
    end
    B_2 = [0 gmSEQ.halfpi 0 0 0];
    for zzz = 1:gmSEQ.LockingPulseN0
       %B_1 = [B_1];
      
       B_2 = [B_2; ...
           gmSEQ.halfpi+(zzz-1)*SingleLen+SpinLockGap gmSEQ.halfpi+(zzz-1)*SingleLen+SpinLockGap+gmSEQ.SLockT1 0 pi/2 gSG.IQVoltage1*gmSEQ.SAmp1; ...
           gmSEQ.halfpi+(zzz-1)*SingleLen+SpinLockGap+gmSEQ.SLockT1+SpinLockGap gmSEQ.halfpi+(zzz-1)*SingleLen+SpinLockGap+gmSEQ.SLockT1+SpinLockGap+gmSEQ.SLockT2 0 3*pi/2 gSG.IQVoltage1*gmSEQ.SAmp2];
    end
  

    % measuring sequence Bright signal
    

    C_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1]; 
    C_2 = [0 gmSEQ.halfpi 0 0 0;...
        gmSEQ.halfpi+SpinLockGap gmSEQ.halfpi+SpinLockGap+gmSEQ.m 0 pi/2 gSG.IQVoltage1*gmSEQ.LockingAmp];


    C_1 = [C_1;...
          gmSEQ.halfpi+SpinLockGap+gmSEQ.m+SpinLockGap gmSEQ.halfpi+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];
   
    % measuring sequence Dark signal
    D_1 = C_1;
    D_2 = [C_2;
           gmSEQ.halfpi+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    
end

    Length2_1 = round(gmSEQ.halfpi+LockLenCool+SpinLockGap+1000);
    Length2_2 = round(gmSEQ.halfpi+SpinLockGap+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    Length2_3 = round(gmSEQ.halfpi+SpinLockGap+LockLenMeasure+SpinLockGap+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
     
        % create the segment using a for loop
    Laser_Cooling_Struct_MWch1 = [{'createSegStruct'}, {'AWG2_SegStruct_ch1.txt'}];
    Laser_Cooling_Struct_MWch2 = [{'createSegStruct'}, {'AWG2_SegStruct_ch2.txt'}];
    for zz = 1:LockingNum
       Laser_Cooling_Struct_MWch1 = [Laser_Cooling_Struct_MWch1, {'wave_AWG2_ch1_seg1.txt'}, {Total2_1}, {1}, {1}];
       Laser_Cooling_Struct_MWch2 = [Laser_Cooling_Struct_MWch2, {'wave_AWG2_ch2_seg1.txt'}, {Total2_1}, {1}, {1}];
    end
    Laser_Cooling_Struct_MWch1 = [Laser_Cooling_Struct_MWch1, {'wave_AWG2_ch1_seg2.txt'}, {Total2_2}, {1}, {1}];
    Laser_Cooling_Struct_MWch2 = [Laser_Cooling_Struct_MWch2, {'wave_AWG2_ch2_seg2.txt'}, {Total2_2}, {1}, {1}];
    
    for zz = 1:LockingNum
       Laser_Cooling_Struct_MWch1 = [Laser_Cooling_Struct_MWch1, {'wave_AWG2_ch1_seg1.txt'}, {Total2_1}, {1}, {1}];
       Laser_Cooling_Struct_MWch2 = [Laser_Cooling_Struct_MWch2, {'wave_AWG2_ch2_seg1.txt'}, {Total2_1}, {1}, {1}];
    end
    Laser_Cooling_Struct_MWch1 = [Laser_Cooling_Struct_MWch1, {'wave_AWG2_ch1_seg3.txt'}, {Total2_3}, {1}, {1}];
    Laser_Cooling_Struct_MWch2 = [Laser_Cooling_Struct_MWch2, {'wave_AWG2_ch2_seg3.txt'}, {Total2_3}, {1}, {1}]; 
    
    %waveformPath= 'D:\MATLAB_Code\MATLAB_Code_2AWG\mytoolboxes\dax22000_user_sw\dax22000_user_sw\waveform';
    filename= fullfile(waveformPath,Laser_Cooling_Struct_MWch1{2});
            fid= fopen(filename,'w');
            for zz = 1:(length(Laser_Cooling_Struct_MWch1)-2)/4
                if zz ~= (length(Laser_Cooling_Struct_MWch1)-2)/4
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct_MWch1{4*(zz-1)+3}),Laser_Cooling_Struct_MWch1{4*(zz-1)+4},Laser_Cooling_Struct_MWch1{4*(zz-1)+5},Laser_Cooling_Struct_MWch1{4*(zz-1)+6});
                else
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct_MWch1{4*(zz-1)+3}),Laser_Cooling_Struct_MWch1{4*(zz-1)+4},Laser_Cooling_Struct_MWch1{4*(zz-1)+5},Laser_Cooling_Struct_MWch1{4*(zz-1)+6});
                end
            end
            fclose(fid);
            
     filename= fullfile(waveformPath,Laser_Cooling_Struct_MWch2{2});
            fid= fopen(filename,'w');
            for zz = 1:(length(Laser_Cooling_Struct_MWch2)-2)/4
                if zz ~= (length(Laser_Cooling_Struct_MWch2)-2)/4
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct_MWch2{4*(zz-1)+3}),Laser_Cooling_Struct_MWch2{4*(zz-1)+4},Laser_Cooling_Struct_MWch2{4*(zz-1)+5},Laser_Cooling_Struct_MWch2{4*(zz-1)+6});
                else
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct_MWch2{4*(zz-1)+3}),Laser_Cooling_Struct_MWch2{4*(zz-1)+4},Laser_Cooling_Struct_MWch2{4*(zz-1)+5},Laser_Cooling_Struct_MWch2{4*(zz-1)+6});
                end
            end
            fclose(fid);
    

    pause(1);
    
    chaseFunctionPool('CreateSegments', 2, 1, 2*LockingNum+2, 2047, 2047, 'AWG2_SegStruct_ch1.txt', 'false');
    pause(2); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 2*LockingNum+2, 2047, 2047, 'AWG2_SegStruct_ch2.txt', 'false');
    pause(2); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');
    pause(1);

ApplyDelays();    

% New sequence: Break the cooling cycles into segments on AWG
function Cooling_SpinLocking
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% gmSEQ.Diffwait

% SignalGeneratorFunctionPool2('WritePow');
% SignalGeneratorFunctionPool2('WriteFreq');
% gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

LockingNum = gmSEQ.LockingNum;
LockingAmp = gmSEQ.LockingAmp;
LockingT = gmSEQ.LockingT;
AfterLock = 500;

MeasureAmp = gmSEQ.MeasureAmp;

Cooling_Readout = gmSEQ.Coolreadout;

%mwlength=gmSEQ.m;
Wait_p = 10e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 500;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 30;
SpinLockGap = 2;

A = [0 0 0 0 0];

CoolCycleT = Cooling_Readout + AfterLaser+gmSEQ.pi/2+SpinLockGap+LockingT+AfterLock;
waveformPath= 'D:\MATLAB_Code\MATLAB_Code_2AWG\mytoolboxes\dax22000_user_sw\dax22000_user_sw\waveform';


if LockingNum == 0
A = [0 gmSEQ.readout 0 pi/2 0.7; ...
    gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

    Length1 = gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+1000;

    clkRate1 = 0.05e9; pause(0.1);
    % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
    % 560ns)
    Total1 = ceil(Length1*clkRate1/1e9/16)*16;
    chaseFunctionPool('stopChase',1); pause(0.1);
    chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
    chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_AWG1.txt'); pause(1);
    chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_AWG1.txt', 1);
    pause(1);
    chaseFunctionPool('runChase',1,'false');
    
else
    A1 = [0 gmSEQ.readout 0 pi/2 0.7; ...
    gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];
    
    A2 = [0 Cooling_Readout 0 pi/2 0.7];
    
    Length1_A1 = round(gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+1000);
    Length1_A2 = round(Cooling_Readout+1000);
    
    clkRate1 = 0.05e9; pause(0.1);

    Total1_A1 = ceil(Length1_A1*clkRate1/1e9/16)*16;
    Total1_A2 = ceil(Length1_A2*clkRate1/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate', 1, clkRate1); pause(0.3);
    chaseFunctionPool('createWaveform', A1, clkRate1/10^9, Length1_A1, 'wave_AWG1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', A2, clkRate1/10^9, Length1_A2, 'wave_AWG1_seg2.txt'); pause(0.5);
    
    % create the segment using a for loop
    Laser_Cooling_Struct = [{'createSegStruct'}, {'AWG1_SegStruct_ch1.txt'}];
    for zz = 1:LockingNum
       Laser_Cooling_Struct = [Laser_Cooling_Struct, {'wave_AWG1_seg2.txt'}, {Total1_A2}, {1}, {1}];
    end
    Laser_Cooling_Struct = [Laser_Cooling_Struct, {'wave_AWG1_seg1.txt'}, {Total1_A1}, {1}, {1}];
    
    
    filename= fullfile(waveformPath,Laser_Cooling_Struct{2});
            fid= fopen(filename,'w');
            for zz = 1:(length(Laser_Cooling_Struct)-2)/4
                if zz ~= (length(Laser_Cooling_Struct)-2)/4
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct{4*(zz-1)+3}),Laser_Cooling_Struct{4*(zz-1)+4},Laser_Cooling_Struct{4*(zz-1)+5},Laser_Cooling_Struct{4*(zz-1)+6});
                else
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct{4*(zz-1)+3}), Laser_Cooling_Struct{4*(zz-1)+4},Laser_Cooling_Struct{4*(zz-1)+5},Laser_Cooling_Struct{4*(zz-1)+6});
                end
            end
            fclose(fid);
    
    
    % chaseFunctionPool(Laser_Cooling_Struct);
      % chaseFunctionPool('createSegStruct', 'AWG1_SegStruct_ch1.txt', Cooling_Struct, ...
      % 'wave_AWG1_seg1.txt', Total1_A1, 1, 1);
    pause(0.5);

    
    chaseFunctionPool('CreateSegments', 1, 1, LockingNum+1, 2047, 2047, 'AWG1_SegStruct_ch1.txt', 'false');
    pause(2); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 1, 'false');
    
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
end



%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=2*(2+LockingNum);

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

if LockingNum == 0
% Pulse for first T1 measurement
    gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi];
    gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];

    Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

    gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi];
    gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];
else
    gmSEQ.CHN(1).T = [];
    gmSEQ.CHN(1).DT = [];
    for kkk = 1:LockingNum
        gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Wait_p+(kkk-1)*CoolCycleT];
        gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT Cooling_Readout];
    end
    gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Wait_p+LockingNum*CoolCycleT Wait_p+LockingNum*CoolCycleT+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi];
    gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];
    
    Start_Sig_D = Wait_p+LockingNum*CoolCycleT+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;
    
    for kkk = 1:LockingNum
        gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D+(kkk-1)*CoolCycleT];
        gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT Cooling_Readout];
    end
    gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D+LockingNum*CoolCycleT Start_Sig_D+LockingNum*CoolCycleT+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi];
    gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];

end


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2+2*LockingNum;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [];
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+(kkk-1)*CoolCycleT];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 1000];
    end
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+LockingNum*CoolCycleT];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 1000];
    
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+(kkk-1)*CoolCycleT];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 1000];
    end
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+LockingNum*CoolCycleT];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 1000];
    
    
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(LockingNum+1)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(LockingNum+2) gmSEQ.CHN(1).T(2*LockingNum+3)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(2*LockingNum+4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--------------------------------------
% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 2 + 2*LockingNum; % use 8 pi/2 P1 pulse spacing 10us away to mix P1

if LockingNum == 0
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-50 ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-50];

    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+100 ...
    gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+100];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[];
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+(kkk-1)*CoolCycleT+Cooling_Readout+AfterLaser-50];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.pi/2+SpinLockGap+LockingT+100];
    end
    
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+LockingNum*CoolCycleT+gmSEQ.readout+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+100];
    
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+(kkk-1)*CoolCycleT+Cooling_Readout+AfterLaser-50];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.pi/2+SpinLockGap+LockingT+100];
    end
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+LockingNum*CoolCycleT+gmSEQ.readout+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+100];
       
    
end
% 

Max_length = 2*Wait_p + 2*LockingNum*CoolCycleT +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi+2*SpinLockGap+gmSEQ.m+PulseGap+gmSEQ.pi);


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2+2*LockingNum;

gmSEQ.CHN(numel(gmSEQ.CHN)).T=[];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[];
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+(kkk-1)*CoolCycleT+Cooling_Readout+AfterLaser];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 500];
    end
    
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Wait_p+LockingNum*CoolCycleT+gmSEQ.readout+AfterLaser];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 500];
    
    for kkk = 1:LockingNum
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+(kkk-1)*CoolCycleT+Cooling_Readout+AfterLaser];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 500];
    end
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T Start_Sig_D+LockingNum*CoolCycleT+gmSEQ.readout+AfterLaser];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT 500];
       



% for MW_AWG
if gSG.ACmod % in AC modulation mode

    
else
    
    % Cooling Sequence
    B_1 = [0 gmSEQ.pi/2 0 pi/2 gSG.IQVoltage1*gmSEQ.CoolSwitch];
    B_2 = [0 gmSEQ.pi/2 0 0 0;...
           gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+LockingT 0 pi/2 gSG.IQVoltage1*LockingAmp*gmSEQ.CoolSwitch];
    
    % Signal Bright measurement
    C_1 = [0 gmSEQ.pi/2 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2 0 3*pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi/2 0 0 0;...
           gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+gmSEQ.m 0 pi/2 gSG.IQVoltage1*MeasureAmp];
   
       
    % Signal Dark measurement 
    D_1 = [0 gmSEQ.pi/2 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2 0 3*pi/2 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.pi/2 0 0 0;...
           gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+gmSEQ.m 0 pi/2 gSG.IQVoltage1*MeasureAmp;...
           gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];     
end

    Length2_1 = round(gmSEQ.pi/2+SpinLockGap+LockingT+1000);
    Length2_2 = round(gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+1000);
    Length2_3 = round(gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
     
        % create the segment using a for loop
    Laser_Cooling_Struct_MWch1 = [{'createSegStruct'}, {'AWG2_SegStruct_ch1.txt'}];
    Laser_Cooling_Struct_MWch2 = [{'createSegStruct'}, {'AWG2_SegStruct_ch2.txt'}];
    for zz = 1:LockingNum
       Laser_Cooling_Struct_MWch1 = [Laser_Cooling_Struct_MWch1, {'wave_AWG2_ch1_seg1.txt'}, {Total2_1}, {1}, {1}];
       Laser_Cooling_Struct_MWch2 = [Laser_Cooling_Struct_MWch2, {'wave_AWG2_ch2_seg1.txt'}, {Total2_1}, {1}, {1}];
    end
    Laser_Cooling_Struct_MWch1 = [Laser_Cooling_Struct_MWch1, {'wave_AWG2_ch1_seg2.txt'}, {Total2_2}, {1}, {1}];
    Laser_Cooling_Struct_MWch2 = [Laser_Cooling_Struct_MWch2, {'wave_AWG2_ch2_seg2.txt'}, {Total2_2}, {1}, {1}];
    
    for zz = 1:LockingNum
       Laser_Cooling_Struct_MWch1 = [Laser_Cooling_Struct_MWch1, {'wave_AWG2_ch1_seg1.txt'}, {Total2_1}, {1}, {1}];
       Laser_Cooling_Struct_MWch2 = [Laser_Cooling_Struct_MWch2, {'wave_AWG2_ch2_seg1.txt'}, {Total2_1}, {1}, {1}];
    end
    Laser_Cooling_Struct_MWch1 = [Laser_Cooling_Struct_MWch1, {'wave_AWG2_ch1_seg3.txt'}, {Total2_3}, {1}, {1}];
    Laser_Cooling_Struct_MWch2 = [Laser_Cooling_Struct_MWch2, {'wave_AWG2_ch2_seg3.txt'}, {Total2_3}, {1}, {1}]; 
    
    %waveformPath= 'D:\MATLAB_Code\MATLAB_Code_2AWG\mytoolboxes\dax22000_user_sw\dax22000_user_sw\waveform';
    filename= fullfile(waveformPath,Laser_Cooling_Struct_MWch1{2});
            fid= fopen(filename,'w');
            for zz = 1:(length(Laser_Cooling_Struct_MWch1)-2)/4
                if zz ~= (length(Laser_Cooling_Struct_MWch1)-2)/4
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct_MWch1{4*(zz-1)+3}),Laser_Cooling_Struct_MWch1{4*(zz-1)+4},Laser_Cooling_Struct_MWch1{4*(zz-1)+5},Laser_Cooling_Struct_MWch1{4*(zz-1)+6});
                else
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct_MWch1{4*(zz-1)+3}),Laser_Cooling_Struct_MWch1{4*(zz-1)+4},Laser_Cooling_Struct_MWch1{4*(zz-1)+5},Laser_Cooling_Struct_MWch1{4*(zz-1)+6});
                end
            end
            fclose(fid);
            
     filename= fullfile(waveformPath,Laser_Cooling_Struct_MWch2{2});
            fid= fopen(filename,'w');
            for zz = 1:(length(Laser_Cooling_Struct_MWch2)-2)/4
                if zz ~= (length(Laser_Cooling_Struct_MWch2)-2)/4
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct_MWch2{4*(zz-1)+3}),Laser_Cooling_Struct_MWch2{4*(zz-1)+4},Laser_Cooling_Struct_MWch2{4*(zz-1)+5},Laser_Cooling_Struct_MWch2{4*(zz-1)+6});
                else
                    fprintf(fid,'%s %i %i %i\r\n',fullfile(waveformPath,Laser_Cooling_Struct_MWch2{4*(zz-1)+3}),Laser_Cooling_Struct_MWch2{4*(zz-1)+4},Laser_Cooling_Struct_MWch2{4*(zz-1)+5},Laser_Cooling_Struct_MWch2{4*(zz-1)+6});
                end
            end
            fclose(fid);
    
    
    %chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
    %    'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
    %    'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1);
    %pause(0.5);
    %chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
    %    'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1, ...
    %    'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 2*LockingNum+2, 2047, 2047, 'AWG2_SegStruct_ch1.txt', 'false');
    pause(2); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 2*LockingNum+2, 2047, 2047, 'AWG2_SegStruct_ch2.txt', 'false');
    pause(2); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');

  
ApplyDelays();

function NVdensity_SpinLocking
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% gmSEQ.Diffwait

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

T0 = gmSEQ.m;
Wait_p = 2e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 30;
SpinLockGap = 2;

A = [0 gmSEQ.readout 0 pi/2 0.7; ...
    gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];


Length1 = gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;


gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--------------------------------------
% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=18; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    Wait_p+gmSEQ.readout+AfterLaser-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+100];

% 

Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi+2*SpinLockGap+T0+PulseGap+gmSEQ.pi);


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500 500];

%%%%%%
% Add in second Microwave
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap-50 ...
    Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap-50 ];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m+100 gmSEQ.m+100];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap ...
    Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap ];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m gmSEQ.m];



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1*0.7;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
    
    C_2 = [0 gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1*0.7;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 3*pi/2 gSG.IQVoltage1];

    D_1 = [0 gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1*0.7;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    D_2 = [0 gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1*0.7;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 3*pi/2 gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
 
else
    
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi/2 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 0 3*pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi/2 0 0 0;...
           gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 0 pi/2 gSG.IQVoltage1*0.7];
       
    D_1 = [0 gmSEQ.pi/2 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 0 3*pi/2 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.pi/2 0 0 0;...
           gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 0 pi/2 gSG.IQVoltage1*0.7;...
           gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+1000);
    Length2_3 = round(gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 4, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 4, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


    
ApplyDelays();

function NVdensity_SpinLocking_SwpFreq
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% gmSEQ.Diffwait

gSG2.Freq = gmSEQ.m*1e9;
SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

T0 = 100000;
Wait_p = 2e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 30;
SpinLockGap = 2;

A = [0 gmSEQ.readout 0 pi/2 0.7; ...
    gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];


Length1 = gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;


gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--------------------------------------
% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=18; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    Wait_p+gmSEQ.readout+AfterLaser-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+100];

% 

Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi+2*SpinLockGap+T0+PulseGap+gmSEQ.pi);


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500 500];

%%%%%%
% Add in second Microwave
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap-50 ...
    Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap-50 ];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[T0+100 T0+100];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap ...
    Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap ];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[T0 T0];



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1*0.7;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
    
    C_2 = [0 gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1*0.7;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 3*pi/2 gSG.IQVoltage1];

    D_1 = [0 gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1*0.7;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    D_2 = [0 gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1*0.7;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 3*pi/2 gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
 
else
    
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi/2 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 0 3*pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi/2 0 0 0;...
           gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 0 pi/2 gSG.IQVoltage1*0.7];
       
    D_1 = [0 gmSEQ.pi/2 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 0 3*pi/2 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.pi/2 0 0 0;...
           gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 0 pi/2 gSG.IQVoltage1*0.7;...
           gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+1000);
    Length2_3 = round(gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 4, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 4, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');

ApplyDelays();

function NVdensity_SpinLocking_SwpPow
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% gmSEQ.Diffwait

gSG2.Pow = gmSEQ.m;
SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

T0 = 100000;
Wait_p = 2e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 30;
SpinLockGap = 2;

A = [0 gmSEQ.readout 0 pi/2 0.7; ...
    gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];


Length1 = gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;


gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%--------------------------------------
% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=18; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    Wait_p+gmSEQ.readout+AfterLaser-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+100];

% 

Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi+2*SpinLockGap+T0+PulseGap+gmSEQ.pi);


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500 500];

%%%%%%
% Add in second Microwave
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap-50 ...
    Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap-50 ];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[T0+100 T0+100];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap ...
    Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap ];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[T0 T0];



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1*0.7;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
    
    C_2 = [0 gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1*0.7;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 3*pi/2 gSG.IQVoltage1];

    D_1 = [0 gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1*0.7;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    D_2 = [0 gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1*0.7;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 (gSG.SGbasefreq-gSG.Freq)/1e9 3*pi/2 gSG.IQVoltage1;...
        gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
 
else
    
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi/2 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 0 3*pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi/2 0 0 0;...
           gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 0 pi/2 gSG.IQVoltage1*0.7];
       
    D_1 = [0 gmSEQ.pi/2 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2 0 3*pi/2 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.pi/2 0 0 0;...
           gmSEQ.pi/2+SpinLockGap gmSEQ.pi/2+SpinLockGap+T0 0 pi/2 gSG.IQVoltage1*0.7;...
           gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+1000);
    Length2_3 = round(gmSEQ.pi/2+SpinLockGap+T0+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 4, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 4, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');

ApplyDelays();

function RabiAPD_P1MWOn
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

HPSG = visa('agilent', 'GPIB0::19::INSTR');
    fclose(HPSG);
    fopen(HPSG);
    fprintf(HPSG, '%s', 'RF0');
    AA = ['CW ', num2str(gSG.Freq2), 'GZ'];
    fprintf(HPSG, '%s', AA);
    AA = ['PL', num2str(gSG.Pow2), 'dm'];
    fprintf(HPSG, '%s', AA);
    fprintf(HPSG, '%s', 'RF1');
    pause(0.5);
    fclose(HPSG);

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=3;
gmSEQ.CHN(1).T=[gmSEQ.readout+100+gmSEQ.To+50 gmSEQ.readout+100+gmSEQ.To+50+10000+1000 gmSEQ.readout+100+gmSEQ.To+50+10000+1000+gmSEQ.CtrGateDur+200+1000];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')
    gmSEQ.CHN(1).DT=[1000 1000 1000];
end
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=gmSEQ.readout+100;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=gmSEQ.m;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+100+gmSEQ.To+50 gmSEQ.readout+100+gmSEQ.To+50+10000+1000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout 10000 gmSEQ.CtrGateDur+200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 100];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('DEERPulse');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+100];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.To];

ApplyDelays();

function CtrDur
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=1100+gmSEQ.pi;

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[100 100+gmSEQ.readout+mwlength];
gmSEQ.CHN(1).DT=[gmSEQ.readout gmSEQ.readout];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)-100 gmSEQ.CHN(1).T(2)-100];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m gmSEQ.m];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2)-gmSEQ.pi-100];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi];

ApplyDelays();

function T1JC
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;

% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=6;
% minimum 1us between laser pulses. 500ns after pi pulse before detection
% edit by Chong 2/20/2017

% gmSEQ.CHN(1).T=[1500+mwlength 1000+mwlength+gmSEQ.readout+1000+mwlength+gmSEQ.pi+500 1000+mwlength+gmSEQ.readout+1000+mwlength+gmSEQ.pi+500+gmSEQ.readout+1000];
% gmSEQ.CHN(1).DT=[gmSEQ.readout gmSEQ.readout gmSEQ.CtrGateDur+200];
AfterPi = 50;
Wait_p = 5e6;
% Swtich detection window 1 and 2
gmSEQ.CHN(1).T=[0 gmSEQ.readout+1000+mwlength+gmSEQ.pi+AfterPi ...
    gmSEQ.readout+1000+mwlength+gmSEQ.pi+300+gmSEQ.readout+Wait_p gmSEQ.readout+1000+mwlength+gmSEQ.pi+AfterPi+gmSEQ.readout+Wait_p+gmSEQ.readout+1000+mwlength+gmSEQ.pi+AfterPi ...
    gmSEQ.readout+1000+mwlength+gmSEQ.pi+300+gmSEQ.readout+Wait_p+gmSEQ.readout+1000+mwlength+gmSEQ.pi+AfterPi+gmSEQ.readout+Wait_p gmSEQ.readout+1000+mwlength+gmSEQ.pi+AfterPi+gmSEQ.readout+Wait_p+gmSEQ.readout+1000+mwlength+gmSEQ.pi+AfterPi+gmSEQ.readout+Wait_p+gmSEQ.readout+2000];
gmSEQ.CHN(1).DT=[gmSEQ.readout gmSEQ.readout gmSEQ.readout gmSEQ.readout gmSEQ.readout gmSEQ.readout];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(4) gmSEQ.CHN(1).T(6)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 20e6];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];

ApplyDelays();

% Add by Chong on 3/1/2017
function T1PolarP1
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 5e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=(gmSEQ.PulseNum+2)*2+2;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

AfterPi = 50;
AfterLaser = 0;

for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T (kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout 20000];

Start_Sig_D = gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;
for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T Start_Sig_D+(kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout 20000];

Start_Ref = Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Ref Start_Ref+5000+2000];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT 5000 5000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(gmSEQ.PulseNum+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+5000+10000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi];

if (gmSEQ.bSweep3)
    Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To3+1e6;
elseif (gmSEQ.bSweep2)
    Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To2+1e6;
else
    Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To+1e6;
end

% Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*mwlength+0.5e6;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];

ApplyDelays();

% T1PolarP1 measurement for spin -1 state
function T1PolarP1_Pi
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 5e6; % to wait for P1 to be fully unpolarized again
AfterPi = 50;
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=(gmSEQ.PulseNum+2)*2+2;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T (kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+1000+gmSEQ.pi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.readout];

Start_Sig_D = gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+1000+gmSEQ.pi+mwlength+gmSEQ.pi+AfterPi+gmSEQ.readout+Wait_p;
for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T Start_Sig_D+(kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+1000+gmSEQ.pi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.readout];

Start_Ref = Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+1000+gmSEQ.pi+mwlength+gmSEQ.pi+AfterPi+gmSEQ.readout+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Ref Start_Ref+gmSEQ.readout+2000];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.readout];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(gmSEQ.PulseNum+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+gmSEQ.readout+5000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(gmSEQ.PulseNum+1)+gmSEQ.readout+1000 gmSEQ.CHN(1).T(2*gmSEQ.PulseNum+3)+gmSEQ.readout+1000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi gmSEQ.pi gmSEQ.pi];

if (gmSEQ.bSweep2)
    Max_length = 2*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To2+1e6;
elseif (gmSEQ.bSweep3)
    Max_length = 2*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To3+1e6;
else
    Max_length = 2*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To+1e6;
end
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];

ApplyDelays();

function T1PolarP1_RotateP1
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 5e6; % to wait for P1 to be fully unpolarized again
AfterLaser = 0;
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=(gmSEQ.PulseNum+2)*2+2;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

AfterPi = 50;

for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T (kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout 20000];

Start_Sig_D = gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;
for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T Start_Sig_D+(kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout 20000];

Start_Ref = Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+1e6;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Ref Start_Ref+5000+2000];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT 5000 5000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(gmSEQ.PulseNum+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+5000+5000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(gmSEQ.PulseNum+1)+gmSEQ.readout-1000-gmSEQ.P1Pulse gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+1)+1)+gmSEQ.readout-1000-gmSEQ.P1Pulse gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse gmSEQ.P1Pulse gmSEQ.pi];
% 
if (gmSEQ.bSweep3)
    Max_length = 2*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To3+1e6;
elseif (gmSEQ.bSweep2)
    Max_length = 2*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To2+1e6;
else
    Max_length = 2*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To+1e6;
end

% Max_length = 2*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*mwlength+1.5e6;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];

ApplyDelays();

function T1PolarP1_SpinDiffusion
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 5e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=(gmSEQ.PulseNum+2)*2+2+2;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

AfterPi = 50;

for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T (kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait+gmSEQ.Repolarize+1000+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.Repolarize gmSEQ.readout];

Start_Sig_D = gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait+gmSEQ.Repolarize+1000+mwlength+gmSEQ.pi+AfterPi+gmSEQ.readout+Wait_p;
for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T Start_Sig_D+(kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait+gmSEQ.Repolarize+1000+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.Repolarize gmSEQ.readout];

Start_Ref = Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+1000+mwlength+gmSEQ.pi+AfterPi+gmSEQ.readout+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Ref Start_Ref+gmSEQ.readout+2000];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.readout];



gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(gmSEQ.PulseNum+2+1) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2+2)+gmSEQ.readout+5000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi];

if (gmSEQ.bSweep2)
    Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 4*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To2+2*(gmSEQ.Diffwait+gmSEQ.Repolarize)+0.2e6;
else
    Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 4*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To+2*(gmSEQ.Diffwait+gmSEQ.Repolarize)+0.2e6;
end
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];

ApplyDelays();

function T1PolarP1_SpinDiffusion_SpeedupP1Mix
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=(gmSEQ.PulseNum+2)*2+2+2;
gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

AfterPi = 50;
AfterLaser = 0;

for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T (kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait+gmSEQ.Repolarize+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.Repolarize 20000];

Start_Sig_D = gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait+gmSEQ.Repolarize+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;

for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T Start_Sig_D+(kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait+gmSEQ.Repolarize+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.Repolarize 20000];

Start_Ref = Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait+gmSEQ.Repolarize+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Ref Start_Ref+5000+2000];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT 5000 5000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=13; % use 4 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2)+1)+20000+5000 gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2)+1)+20000+5000+10000 gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2)+1)+20000+5000+10000+10000 gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2)+1)+20000+5000+10000+10000+10000 ...
    gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)-gmSEQ.pi-AfterPi ...
    gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000+10000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000+10000+10000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000+10000+10000+10000 ...
    gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+4)+20000+5000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+4)+20000+5000+10000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+4)+20000+5000+10000+10000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+4)+20000+5000+10000+10000+10000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.pi gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(gmSEQ.PulseNum+2+1) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2+2)+5000+10000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

% if (gmSEQ.bSweep3)
%     Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To3+0.1e6+2*(gmSEQ.Diffwait+gmSEQ.Repolarize);
% elseif (gmSEQ.bSweep2)
%     Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To2+0.1e6+2*(gmSEQ.Diffwait+gmSEQ.Repolarize);
% else
%     Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To+0.1e6+2*(gmSEQ.Diffwait+gmSEQ.Repolarize);
% end

Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 20000*4 + 6000 + 2*gmSEQ.pi + 2*mwlength+0.1e6;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];

ApplyDelays();

function T1PolarP1_SpinDiff_2Counter
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 2e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=6;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

AfterPi = 20;
AfterLaser = 0;

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+gmSEQ.Diffwait Wait_p+gmSEQ.readout+gmSEQ.Diffwait+gmSEQ.Repolarize+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout gmSEQ.Repolarize 20000];

Start_Sig_D = Wait_p+gmSEQ.readout+gmSEQ.Diffwait+gmSEQ.Repolarize+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+gmSEQ.Diffwait Start_Sig_D+gmSEQ.readout+gmSEQ.Diffwait+gmSEQ.Repolarize+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.Repolarize 20000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(3) gmSEQ.CHN(1).T(6)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=9; % use 4 pi/2 P1 pulse spacing 10us away to mix P1
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 5000+10000 5000+10000+10000 5000+10000+10000+10000 ...
%     gmSEQ.CHN(1).T(3)+20000+5000 gmSEQ.CHN(1).T(1*(3))+20000+5000+10000 gmSEQ.CHN(1).T(1*(3))+20000+5000+10000+10000 gmSEQ.CHN(1).T(1*(3))+20000+5000+10000+10000+10000 ...
%     gmSEQ.CHN(1).T(6)-gmSEQ.pi-AfterPi];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.pi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 5000+10000 5000+10000+10000 5000+10000+10000+10000 5000+40000 5000+50000 5000+60000 5000+70000 ...
    gmSEQ.CHN(1).T(3)+20000+5000 gmSEQ.CHN(1).T(1*(3))+20000+5000+10000 gmSEQ.CHN(1).T(1*(3))+20000+5000+20000 gmSEQ.CHN(1).T(1*(3))+20000+5000+30000 ...
    gmSEQ.CHN(1).T(1*(3))+20000+5000+40000 gmSEQ.CHN(1).T(1*(3))+20000+5000+50000 gmSEQ.CHN(1).T(1*(3))+20000+5000+60000 gmSEQ.CHN(1).T(1*(3))+20000+5000+70000 ...
    gmSEQ.CHN(1).T(6)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) ...
    gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) ...
    gmSEQ.pi];


Max_length = 2*Wait_p + 2*gmSEQ.readout + 20000*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi) + 2*mwlength + 2*(gmSEQ.Diffwait+gmSEQ.Repolarize)-200;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

ApplyDelays();

function T1PolarP1_SpinDiffusion_SpeedupP1Mix_LeeGoldBurg
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

HPSG = visa('agilent', 'GPIB0::19::INSTR');
    fclose(HPSG);
    fopen(HPSG);
    fprintf(HPSG, '%s', 'RF0');
    AA = ['CW ', num2str(gSG.Freq2), 'GZ'];
    fprintf(HPSG, '%s', AA);
    AA = ['PL', num2str(gSG.Pow2), 'dm'];
    fprintf(HPSG, '%s', AA);
    fprintf(HPSG, '%s', 'RF1');
    pause(0.5);
    fclose(HPSG);

mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=(gmSEQ.PulseNum+2)*2+2+2;
gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

AfterPi = 50;
AfterLaser = 0;

for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T (kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait+gmSEQ.Repolarize+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.Repolarize 20000];

Start_Sig_D = gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait+gmSEQ.Repolarize+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;

for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T Start_Sig_D+(kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait+gmSEQ.Repolarize+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.Repolarize 20000];

Start_Ref = Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.Diffwait+gmSEQ.Repolarize+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Ref Start_Ref+5000+2000];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT 5000 5000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=13; % use 4 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2)+1)+20000+5000 gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2)+1)+20000+5000+10000 gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2)+1)+20000+5000+10000+10000 gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2)+1)+20000+5000+10000+10000+10000 ...
    gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)-gmSEQ.pi-AfterPi ...
    gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000+10000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000+10000+10000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000+10000+10000+10000 ...
    gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+4)+20000+5000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+4)+20000+5000+10000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+4)+20000+5000+10000+10000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+4)+20000+5000+10000+10000+10000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.pi gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('DEERPulse');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 4 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[floor((gmSEQ.Diffwait)/(gmSEQ.P1Pulse*2/(1.5)^0.5))*(gmSEQ.P1Pulse*2/(1.5)^0.5) floor((gmSEQ.Diffwait)/(gmSEQ.P1Pulse*2/(1.5)^0.5))*(gmSEQ.P1Pulse*2/(1.5)^0.5)];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(gmSEQ.PulseNum+2+1) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2+2)+5000+10000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

% if (gmSEQ.bSweep3)
%     Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To3+0.1e6+2*(gmSEQ.Diffwait+gmSEQ.Repolarize);
% elseif (gmSEQ.bSweep2)
%     Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To2+0.1e6+2*(gmSEQ.Diffwait+gmSEQ.Repolarize);
% else
%     Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To+0.1e6+2*(gmSEQ.Diffwait+gmSEQ.Repolarize);
% end

Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 20000*4 + 6000 + 2*gmSEQ.pi + 2*mwlength+0.1e6+2*(gmSEQ.Diffwait+gmSEQ.Repolarize);

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];

ApplyDelays();

function T1PolarP1_Linear_varyT
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 5e6; % to wait for P1 to be fully unpolarized again
AfterPi = 50;
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=(gmSEQ.PulseNum+2)*2+2;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T (kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)+(kk-1)*(kk-2)/2*gmSEQ.tP1PolarStep];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end

Polar1_End = (gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout)+(gmSEQ.PulseNum)*(gmSEQ.PulseNum-1)/2*gmSEQ.tP1PolarStep; % Linear increment of tP1Polar


% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Polar1_End Polar1_End+gmSEQ.readout+1000+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.readout];

Start_Sig_D = Polar1_End+gmSEQ.readout+1000+mwlength+gmSEQ.pi+AfterPi+gmSEQ.readout+Wait_p;

for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T Start_Sig_D+(kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)+(kk-1)*(kk-2)/2*gmSEQ.tP1PolarStep];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end

Polar2_End = Start_Sig_D+(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout)+(gmSEQ.PulseNum)*(gmSEQ.PulseNum-1)/2*gmSEQ.tP1PolarStep;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Polar2_End Polar2_End+gmSEQ.readout+1000+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.readout];


Start_Ref = Polar2_End+gmSEQ.readout+1000+mwlength+gmSEQ.pi+AfterPi+gmSEQ.readout+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Ref Start_Ref+gmSEQ.readout+2000];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.readout];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(gmSEQ.PulseNum+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi];

if (gmSEQ.bSweep2)
    Max_length = 3*Wait_p + 2*((gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout)+(gmSEQ.PulseNum)*(gmSEQ.PulseNum-1)/2*gmSEQ.tP1PolarStep) + 6*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To2+1e6;
else
    Max_length = 3*Wait_p + 2*((gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout)+(gmSEQ.PulseNum)*(gmSEQ.PulseNum-1)/2*gmSEQ.tP1PolarStep) + 6*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To+1e6;
end
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];

ApplyDelays();

function T1PolarP1_AfterPolarWait
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 5e6; % to wait for P1 to be fully unpolarized again
AfterPi = 50;
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=(gmSEQ.PulseNum+2)*2+2;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T (kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.tP1AfterPolarWait gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.tP1AfterPolarWait+gmSEQ.readout+1000+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.readout];

Start_Sig_D = gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.tP1AfterPolarWait+gmSEQ.readout+1000+mwlength+gmSEQ.pi+AfterPi+gmSEQ.readout+Wait_p;
for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T Start_Sig_D+(kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.tP1AfterPolarWait Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.tP1AfterPolarWait+gmSEQ.readout+1000+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.readout];

Start_Ref = Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.tP1AfterPolarWait+gmSEQ.readout+1000+mwlength+gmSEQ.pi+AfterPi+gmSEQ.readout+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Ref Start_Ref+gmSEQ.readout+2000];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout gmSEQ.readout];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(gmSEQ.PulseNum+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi];

if (gmSEQ.bSweep2)
    Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 6*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To2+1e6;
else
    Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 6*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To+1e6;
end
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];

ApplyDelays();

function RabiQ
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=1;
gmSEQ.CHN(1).T=gmSEQ.readout+gmSEQ.To+1100;
gmSEQ.CHN(1).DT=gmSEQ.CtrGateDur;
gmSEQ.CHN(2).PBN=PBDictionary('ctr1');
gmSEQ.CHN(2).NRise=1;
gmSEQ.CHN(2).T=gmSEQ.readout+gmSEQ.To+1100+gmSEQ.readout-gmSEQ.CtrGateDur-200;
gmSEQ.CHN(2).DT=gmSEQ.CtrGateDur;
gmSEQ.CHN(3).PBN=PBDictionary('Q');
gmSEQ.CHN(3).NRise=1;
gmSEQ.CHN(3).T=gmSEQ.readout+1050;
gmSEQ.CHN(3).DT=gmSEQ.m;
gmSEQ.CHN(4).PBN=PBDictionary('AOM');
gmSEQ.CHN(4).NRise=2;
gmSEQ.CHN(4).T=[0 gmSEQ.readout+gmSEQ.To+1100];
gmSEQ.CHN(4).DT=[gmSEQ.readout gmSEQ.readout];
ApplyDelays();

function AOMDelay
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

gmSEQ.CHN(1).PBN=PBDictionary('ctr0'); % Counter
gmSEQ.CHN(1).NRise=1;
gmSEQ.CHN(1).T=gmSEQ.m;
gmSEQ.CHN(1).DT=gmSEQ.CtrGateDur;

gmSEQ.CHN(2).PBN=PBDictionary('AOM'); % Laser
gmSEQ.CHN(2).NRise=1;
gmSEQ.CHN(2).T=[3000];
gmSEQ.CHN(2).DT=[gmSEQ.readout-6000];

gmSEQ.CHN(3).PBN=PBDictionary('dummy'); 
gmSEQ.CHN(3).NRise=2;
gmSEQ.CHN(3).T=[0 12000]; %[0 6000-100]
gmSEQ.CHN(3).DT=[100 100];

ApplyNoDelays;

function Optimize_Ctr
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

CtrWindow=gmSEQ.m;

% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=3;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

AfterPi = 100;
AfterLaser = 1000;  % apply pulse to mix spin

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [0 gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi+gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout gmSEQ.readout gmSEQ.readout];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[CtrWindow CtrWindow];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi];

Max_length = gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi+gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi+gmSEQ.readout;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

ApplyDelays();

function NV_Polarization
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

LaserPumping=gmSEQ.m;

% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

AfterPi = 100;
AfterLaser = 1000;
Wait_p = 50000; % For NV to depolarize

SigD_Start = LaserPumping+AfterLaser+gmSEQ.pi+AfterPi+10000+Wait_p;

gmSEQ.CHN(1).T = [0 LaserPumping+AfterLaser+gmSEQ.pi+AfterPi SigD_Start SigD_Start+LaserPumping+AfterLaser+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [LaserPumping 10000 LaserPumping 10000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[SigD_Start-Wait_p+2000 SigD_Start+LaserPumping+AfterLaser SigD_Start+LaserPumping+AfterLaser+gmSEQ.pi+AfterPi+10000+2000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi/2 gmSEQ.pi gmSEQ.pi/2];

Max_length =  2*(LaserPumping+AfterLaser+gmSEQ.pi+AfterPi+10000+Wait_p);

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

ApplyDelays();

function CtrCal
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[2000+gmSEQ.m 2000+gmSEQ.m+gmSEQ.readout+1000];
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(2).PBN=PBDictionary('AOM');
gmSEQ.CHN(2).NRise=2;
gmSEQ.CHN(2).T=[2000 2000+gmSEQ.readout+1000];
gmSEQ.CHN(2).DT=[gmSEQ.readout gmSEQ.readout];

gmSEQ.CHN(3).PBN=PBDictionary('dummy');
gmSEQ.CHN(3).NRise=1;
gmSEQ.CHN(3).T=0;
gmSEQ.CHN(3).DT=10;

gmSEQ.CHN(4).PBN=PBDictionary('I');
gmSEQ.CHN(4).NRise=1;
gmSEQ.CHN(4).T=2000-50-gmSEQ.pi+500;
gmSEQ.CHN(4).DT=gmSEQ.pi;
ApplyNoDelays;

function Ramsey
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

AfterPi = 1000;
% 
WaitTime = 1e5;
Detect_Pulse = 5e3;
%%%%% Fixed sequence length %%%%%%
% if (gmSEQ.bSweep3 == 1)
% Sig_D_start = gmSEQ.readout+1000+gmSEQ.pi*2+2*gmSEQ.m+15+gmSEQ.pi+AfterPi+(2*gmSEQ.To3-2*gmSEQ.m)+Detect_Pulse+WaitTime;
% Ref_start = Sig_D_start + gmSEQ.readout + 1000+gmSEQ.pi*2+2*gmSEQ.m+15+gmSEQ.pi+AfterPi+(2*gmSEQ.To3-2*gmSEQ.m)+Detect_Pulse+WaitTime;
% elseif (gmSEQ.bSweep2 == 1)
%     Sig_D_start = gmSEQ.readout+1000+gmSEQ.pi*2+2*gmSEQ.m+15+gmSEQ.pi+AfterPi+(2*gmSEQ.To2-2*gmSEQ.m)+Detect_Pulse+WaitTime;
% Ref_start = Sig_D_start + gmSEQ.readout + 1000+gmSEQ.pi*2+2*gmSEQ.m+15+gmSEQ.pi+AfterPi+(2*gmSEQ.To2-2*gmSEQ.m)+Detect_Pulse+WaitTime;
% else
%      Sig_D_start = gmSEQ.readout+1000+gmSEQ.pi*2+2*gmSEQ.m+15+gmSEQ.pi+AfterPi+(2*gmSEQ.To-2*gmSEQ.m)+Detect_Pulse+WaitTime;
% Ref_start = Sig_D_start + gmSEQ.readout + 1000+gmSEQ.pi*2+2*gmSEQ.m+15+gmSEQ.pi+AfterPi+(2*gmSEQ.To-2*gmSEQ.m)+Detect_Pulse+WaitTime;   
% end

Sig_D_start = gmSEQ.readout+1000+gmSEQ.pi+gmSEQ.m+12+gmSEQ.pi+AfterPi+Detect_Pulse+WaitTime;
Ref_start = Sig_D_start + gmSEQ.readout + 1000+gmSEQ.pi+gmSEQ.m+12+gmSEQ.pi+AfterPi+Detect_Pulse+WaitTime;

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T=[Sig_D_start-Detect_Pulse-WaitTime Ref_start-Detect_Pulse-WaitTime Ref_start+gmSEQ.readout+2000 Ref_start+gmSEQ.readout+2000+gmSEQ.readout+2000];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')
    gmSEQ.CHN(1).DT=[1000 1000 1000 1000];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+1000 gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.m ...
    Sig_D_start+gmSEQ.readout+1000 Sig_D_start+gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.m];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi/2 gmSEQ.pi/2 gmSEQ.pi/2 gmSEQ.pi/2];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Sig_D_start+gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.m+gmSEQ.pi/2+12];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Sig_D_start-Detect_Pulse-WaitTime Sig_D_start Ref_start-Detect_Pulse-WaitTime Ref_start Ref_start+gmSEQ.readout+2000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout Detect_Pulse gmSEQ.readout Detect_Pulse gmSEQ.readout gmSEQ.readout];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+2200+gmSEQ.pi*2+2*gmSEQ.To+2200+2*gmSEQ.readout+2000+gmSEQ.readout+3*WaitTime];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];


ApplyDelays();

function RamseyAWG_2Counter
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

disp('edited!')

Wait_p = 1000; % was 0.05e6; changed by preston 6/22
AfterPi = 500;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 30;
mwgap = 0;

%%%%% Fixed sequence length %%%%%%
m_float = gmSEQ.m;
gmSEQ.m = ceil(gmSEQ.m/2)*2;

% laser pulse control
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];
% 4 pulses, polarize and readout for signal bright, and repeat for signal
% dark
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap+gmSEQ.pi/2+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];
Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap+gmSEQ.pi/2+AfterPi+Detect_Window+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap+gmSEQ.pi/2+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];

% counter -> four counters, two signals and two references for b and d
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi+2*mwgap+gmSEQ.m+PulseGap+gmSEQ.pi);

% not sure what dummy is for
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

% this triggers the pulse sequence, so when it hits, it sends the pulse
% sequence defined below through to the sample

% it doesn't really matter how long this lasts, since its just a trigger;
% the pulse sequence is determined by the AWG code below
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500];

    % pi/2 X pulse, then pi/2 -X pulse
    C_1 = [0 gmSEQ.pi/2 gSG.Freq/1e9 0 gSG.IQVoltage1;...
           gmSEQ.pi/2+mwgap+m_float+mwgap gmSEQ.pi/2+mwgap+m_float+mwgap+gmSEQ.pi/2 gSG.Freq/1e9 pi gSG.IQVoltage1];
    
    % pi/2 X pulse, then pi/2 X pulse
    D_1 = [0 gmSEQ.pi/2 gSG.Freq/1e9 0 gSG.IQVoltage1;...
           gmSEQ.pi/2+mwgap+m_float+mwgap gmSEQ.pi/2+mwgap+m_float+mwgap+gmSEQ.pi/2 gSG.Freq/1e9 0 gSG.IQVoltage1];

    Length2_2 = round(gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+1000);
    Length2_3 = round(gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+1000);
    clkRate2 = 2e9;

 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);

    
    chaseFunctionPool('CreateSegments', 1, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 1, 'false');


ApplyDelays();
%%%
function Ramsey_2Counter
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

%Wait_p = 0.05e6; %0.05 e6 --> 1000, WL 04/18/23
Wait_p = 1000;
AfterPi = 500;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 30;
mwgap = 0;
%%%%% Fixed sequence length %%%%%%

%A = [0 gmSEQ.readout 0 pi/2 0.7; ...
%    gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

%Length1 = gmSEQ.readout+AfterLaser+gmSEQ.pi/2+SpinLockGap+gmSEQ.m+SpinLockGap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+1000;
%clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
%Total1 = ceil(Length1*clkRate1/1e9/16)*16;
%chaseFunctionPool('stopChase',1); pause(0.1);
%chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
%chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
%chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
%pause(1);
%chaseFunctionPool('runChase',1,'false');

% laser pulse control
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];
% 4 pulses, polarize and readout for signal bright, and repeat for signal
% dark
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap+gmSEQ.pi/2+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];
Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap+gmSEQ.pi/2+AfterPi+Detect_Window+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap+gmSEQ.pi/2+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];

% below is commented out because we only have one AWG

%gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
%gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
%gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

% counter -> four counters, two signals and two references for b and d
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-1000 gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

% switch, just needs to be open when you want MW pulses to come through
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');

% here we keep the switch open for the whole pulse sequence since they're
% short
if gmSEQ.m <200
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % here the time between the pulses is short
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20 ...
     gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap+gmSEQ.pi/2+40 ...
    gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap+gmSEQ.pi/2+mwgap+gmSEQ.pi+40];

% here the time is longer so open and close
else
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % here the time between the pulses isn't as short so can seperate
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20 Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap-20 ...
     gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-20 gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi/2+40 gmSEQ.pi/2+40 ...
    gmSEQ.pi/2+40 gmSEQ.pi/2+PulseGap+gmSEQ.pi+40];

end

Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi+2*mwgap+gmSEQ.m+PulseGap+gmSEQ.pi);

% not sure what dummy is for
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

% this triggers the pulse sequence, so when it hits, it sends the pulse
% sequence defined below through to the sample

% it doesn't really matter how long this lasts, since its just a trigger;
% the pulse sequence is determined by the AWG code below
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500];

% Here we define the pulse sequence
if gSG.ACmod % in AC modulation mode
   
    C_1 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;... % X pulse
           gmSEQ.halfpi+mwgap+gmSEQ.m+mwgap gmSEQ.halfpi+mwgap+gmSEQ.m+mwgap+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1]; % -X
    C_2 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
           gmSEQ.halfpi+mwgap+gmSEQ.m+mwgap gmSEQ.halfpi+mwgap+gmSEQ.m+mwgap+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi+pi/2 gSG.IQVoltage1];
    
    D_1 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;... % X pulse
        gmSEQ.halfpi+mwgap+gmSEQ.m+mwgap gmSEQ.halfpi+mwgap+gmSEQ.m+mwgap+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % do another X pulse here
    D_2 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
        gmSEQ.halfpi+mwgap+gmSEQ.m+mwgap gmSEQ.halfpi+mwgap+gmSEQ.m+mwgap+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
    
else
    
    C_1 = [0 gmSEQ.pi/2 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap+gmSEQ.pi/2 0 3*pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi/2 0 0 0];
    
    
    D_1 = [0 gmSEQ.pi/2 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap+gmSEQ.pi/2 0 3*pi/2 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.pi/2 0 0 0;...
        gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap+gmSEQ.pi/2+mwgap gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap+gmSEQ.pi/2+mwgap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
end

    Length2_2 = round(gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+1000);
    Length2_3 = round(gmSEQ.pi/2+mwgap+gmSEQ.m+mwgap+gmSEQ.pi/2+PulseGap+gmSEQ.pi+1000);
    clkRate2 = 2e9;

 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 1, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 1, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 1, 'false');


ApplyDelays();

function ramsay_jon
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

if strcmp(gmSEQ.meas,'APD') 
    gmSEQ.CtrGateDur = 1000;
end

Wait_p = 0.02e6;
AfterPi = 500; % before laser detection
AfterLaser = 1000; % 
Detect_Window = 5000;
PulseGap = 30;
%%%%% Fixed sequence length %%%%%%

% rise times for laser 
gmSEQ.m = ceil(gmSEQ.m/2)*2;
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];
% signal bright
% initial pulse to polarize, readout pulse
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];

% signal dark
% repolarization pulse, then readout pulse
Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];

% detection window
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-gmSEQ.CtrGateDur-1000 gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-gmSEQ.CtrGateDur-1000 gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
if gmSEQ.m <200
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; 
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20 ...
     gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi+40 ...
    gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+40];
else
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6; 
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20 Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2-20 Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2-20 ...
     gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-20 gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2-20 gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+40 gmSEQ.pi+40 gmSEQ.halfpi+40 ...
     gmSEQ.halfpi+40 gmSEQ.pi+40 gmSEQ.halfpi+40]; % so here you are just leaving the switch on for both the last two pulses. It was gmSEQ.halfpi+PulseGap+gmSEQ.pi+40, changed to what it is now since only 6 pulses

end
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = ceil(gmSEQ.CHN(numel(gmSEQ.CHN)).DT/2)*2;
% 

Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi);


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[7000 7000];

% for MW_AWG
if gSG.ACmod % in AC modulation mode


    % C_1 = [start, end, Freq, phase, Amp]
    % C_2 = [start, end, Freq, phase+pi/2, Amp]
    % phase = 0 --> +X pulse; pi/2 --> +Y, pi --> -X;  3*pi/2 --> -Y
    C_1 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;... % X pulse
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1; ... % Y pulse
        gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1]; % -X
    C_2 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1; ...
        gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi+pi/2 gSG.IQVoltage1];
    
    
    D_1 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;... % X pulse
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1; ... % Y pulse
        gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % do another X pulse here
    D_2 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1; ...
        gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
%     end
else

    C_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.halfpi 0 0 0;...
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    
    
    D_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.halfpi 0 0 0;...
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1; ...
        gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
%     end
end

    Length2_2 = round(gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    Length2_3 = round(gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    clkRate2 = 2e9;

 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate',1, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1); % I port, C1 and D1
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch2_seg3.txt', Total2_3, 1, 1); % Q port, C2 and D2
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 1, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 1, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 1, 'false');


ApplyDelays();


function RabiCtr2
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% %%%% Fixed sequence length, IDENTICAL DUTY CYCLE %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=3;
gmSEQ.CHN(1).T=[gmSEQ.readout+gmSEQ.To+1100 gmSEQ.readout+gmSEQ.To+1100+1000+1000+gmSEQ.readout+gmSEQ.To+1100 gmSEQ.readout+gmSEQ.To+1100+1000+1000+gmSEQ.readout+gmSEQ.To+1100+1000+1000+gmSEQ.readout+gmSEQ.To+1100];
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
gmSEQ.CHN(2).PBN=PBDictionary('ctr1');
gmSEQ.CHN(2).NRise=1;
gmSEQ.CHN(2).T=gmSEQ.readout+gmSEQ.To+1100+1000+1000+gmSEQ.readout+gmSEQ.To+1100;
gmSEQ.CHN(2).DT=gmSEQ.CtrGateDur;
gmSEQ.CHN(3).PBN=PBDictionary('I');
%gmSEQ.CHN(3).NRise=1;
gmSEQ.CHN(3).NRise=2;
% gmSEQ.CHN(3).T=[gmSEQ.readout+gmSEQ.To+1100+1000+1000+gmSEQ.readout+gmSEQ.To+1100+1000+1000+gmSEQ.readout+gmSEQ.To+1100-gmSEQ.pi-50];
gmSEQ.CHN(3).T=[gmSEQ.readout+1050 gmSEQ.readout+gmSEQ.To+1100+1000+1000+gmSEQ.readout+gmSEQ.To+1100+1000+1000+gmSEQ.readout+1050];
% gmSEQ.CHN(3).DT=[gmSEQ.pi];
gmSEQ.CHN(3).DT=[gmSEQ.m gmSEQ.pi];
gmSEQ.CHN(4).PBN=PBDictionary('AOM');
gmSEQ.CHN(4).NRise=6;
gmSEQ.CHN(4).T=[0 gmSEQ.readout+gmSEQ.To+1100 gmSEQ.readout+gmSEQ.To+1100+1000+1000 gmSEQ.readout+gmSEQ.To+1100+1000+1000+gmSEQ.readout+gmSEQ.To+1100 gmSEQ.readout+gmSEQ.To+1100+1000+1000+gmSEQ.readout+gmSEQ.To+1100+1000+1000 gmSEQ.readout+gmSEQ.To+1100+1000+1000+gmSEQ.readout+gmSEQ.To+1100+1000+1000+gmSEQ.readout+gmSEQ.To+1100];
gmSEQ.CHN(4).DT=[gmSEQ.readout 1000 gmSEQ.readout 1000 gmSEQ.readout 1000];
gmSEQ.CHN(5).PBN=PBDictionary('ctr2');
gmSEQ.CHN(5).NRise=1;
gmSEQ.CHN(5).T=gmSEQ.readout+gmSEQ.To+1100+1000+1000+gmSEQ.readout+gmSEQ.To+1100+1000+1000+gmSEQ.readout+gmSEQ.To+1100;
gmSEQ.CHN(5).DT=gmSEQ.CtrGateDur;
ApplyDelays();

function Echo
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% HPSG = visa('agilent', 'GPIB0::19::INSTR');
%     fopen(HPSG);
%     fprintf(HPSG, '%s', 'RF0');
%     AA = ['CW ', num2str(gSG.Freq2), 'GZ'];
%     fprintf(HPSG, '%s', AA);
%     AA = ['PL', num2str(gSG.Pow2), 'dm'];
%     fprintf(HPSG, '%s', AA);
%     fprintf(HPSG, '%s', 'RF1');
%     pause(0.5);
%     fclose(HPSG);
    
AfterPi = 1000;
WaitTime = 1e5;
Detect_Pulse = 5e3;

%%%%% Fixed sequence length %%%%%%
% if (gmSEQ.bSweep3 == 1)
% Sig_D_start = gmSEQ.readout+1000+gmSEQ.pi*2+2*gmSEQ.m+15+gmSEQ.pi+AfterPi+(2*gmSEQ.To3-2*gmSEQ.m)+Detect_Pulse+WaitTime;
% Ref_start = Sig_D_start + gmSEQ.readout + 1000+gmSEQ.pi*2+2*gmSEQ.m+15+gmSEQ.pi+AfterPi+(2*gmSEQ.To3-2*gmSEQ.m)+Detect_Pulse+WaitTime;
% elseif (gmSEQ.bSweep2 == 1)
%     Sig_D_start = gmSEQ.readout+1000+gmSEQ.pi*2+2*gmSEQ.m+15+gmSEQ.pi+AfterPi+(2*gmSEQ.To2-2*gmSEQ.m)+Detect_Pulse+WaitTime;
% Ref_start = Sig_D_start + gmSEQ.readout + 1000+gmSEQ.pi*2+2*gmSEQ.m+15+gmSEQ.pi+AfterPi+(2*gmSEQ.To2-2*gmSEQ.m)+Detect_Pulse+WaitTime;
% else
%      Sig_D_start = gmSEQ.readout+1000+gmSEQ.pi*2+2*gmSEQ.m+15+gmSEQ.pi+AfterPi+(2*gmSEQ.To-2*gmSEQ.m)+Detect_Pulse+WaitTime;
% Ref_start = Sig_D_start + gmSEQ.readout + 1000+gmSEQ.pi*2+2*gmSEQ.m+15+gmSEQ.pi+AfterPi+(2*gmSEQ.To-2*gmSEQ.m)+Detect_Pulse+WaitTime;   
% end

Sig_D_start = gmSEQ.readout+1000+gmSEQ.pi*2+2*gmSEQ.m+20+gmSEQ.pi+AfterPi+Detect_Pulse+WaitTime;
Ref_start = Sig_D_start + gmSEQ.readout + 1000+gmSEQ.pi*2+2*gmSEQ.m+20+gmSEQ.pi+AfterPi+Detect_Pulse+WaitTime;

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T=[Sig_D_start-(Detect_Pulse+WaitTime) Ref_start-(Detect_Pulse+WaitTime) Ref_start+gmSEQ.readout+2000 Ref_start+gmSEQ.readout+2000+gmSEQ.readout+2000];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')
    gmSEQ.CHN(1).DT=[1000 1000 1000 1000];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+1000 gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.m+gmSEQ.pi+gmSEQ.m ...
    Sig_D_start+gmSEQ.readout+1000 Sig_D_start+gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.m+gmSEQ.pi+gmSEQ.m];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi/2 gmSEQ.pi/2 gmSEQ.pi/2 gmSEQ.pi/2];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.m ...
    Sig_D_start+gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.m Sig_D_start+gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.m+gmSEQ.pi+gmSEQ.m+gmSEQ.pi/2+20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi gmSEQ.pi gmSEQ.pi];

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('DEERPulse');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.m+gmSEQ.pi/2-gmSEQ.DEERpi/2 ...
% Sig_D_start+gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.m+gmSEQ.pi/2-gmSEQ.DEERpi/2];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Sig_D_start-(Detect_Pulse+WaitTime) Sig_D_start Ref_start-(Detect_Pulse+WaitTime) Ref_start Ref_start+gmSEQ.readout+2000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout Detect_Pulse gmSEQ.readout Detect_Pulse gmSEQ.readout gmSEQ.readout];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+2200+gmSEQ.pi*4+4*gmSEQ.To+2200+2*gmSEQ.readout+2000+gmSEQ.readout+3*WaitTime];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[20 20];


ApplyDelays();

function Echo_2Counter
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

if strcmp(gmSEQ.meas,'APD') 
    gmSEQ.CtrGateDur = 1000;
end

Wait_p = 0.02e6;
% 
AfterPi = 500; % before laser detection
AfterLaser = 1000; % 
Detect_Window = 5000;
PulseGap = 30;
%SpinLockGap = 2;
%%%%% Fixed sequence length %%%%%%

gmSEQ.m = ceil(gmSEQ.m/2)*2;

% A = [0 gmSEQ.readout 0 pi/2 0.7; ...
%     gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];
% [
% Length1 = gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+1000;
% clkRate1 = 1e9; pause(0.1);
% % used to be 0.05e9
% % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% % 560ns)
% Total1 = ceil(Length1*clkRate1/1e9/16)*16;
% chaseFunctionPool('stopChase',1); pause(0.1);
% chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
% chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
% chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
% pause(1);
% chaseFunctionPool('runChase',1,'false');


gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;


gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];


% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% %gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-gmSEQ.CtrGateDur-1000 gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-gmSEQ.CtrGateDur-1000 gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
if gmSEQ.m <200
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; 
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20 ...
     gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+40 ...
    gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+40];
else
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6; 
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20 Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2-20 Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2-20 ...
     gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-20 gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2-20 gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+40 gmSEQ.pi+40 gmSEQ.halfpi+40 ...
     gmSEQ.halfpi+40 gmSEQ.pi+40 gmSEQ.halfpi+40]; % so here you are just leaving the switch on for both the last two pulses. It was gmSEQ.halfpi+PulseGap+gmSEQ.pi+40, changed to what it is now since only 6 pulses

end
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = ceil(gmSEQ.CHN(numel(gmSEQ.CHN)).DT/2)*2;
% 

Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi);


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[7000 7000];

% for MW_AWG
if gSG.ACmod % in AC modulation mode
    
%     if gmSEQ.m ==0
%     C_1 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
%         gmSEQ.halfpi gmSEQ.halfpi+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
%     C_2 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
%         gmSEQ.halfpi gmSEQ.halfpi+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi+pi/2 gSG.IQVoltage1];
%     
%     
%     D_1 = [C_1;...
%           gmSEQ.halfpi+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.halfpi+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
%     D_2 = [C_2;...
%           gmSEQ.halfpi+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.halfpi+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1];
%     
%     else




%% ejd edit 11/27/2021
%     % C_1 = [start, end, Freq, phase, Amp]
%     % C_2 = [start, end, Freq, phase+pi/2, Amp]
%     % phase = 0 --> +X pulse; pi/2 --> +Y, pi --> -X;  3*pi/2 --> -Y
        % start regular spin echo comment back in 4/4/2022 ejd
    C_1 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;... % X pulse
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1; ... % Y pulse
        gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1]; % -X
    C_2 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1; ...
        gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi+pi/2 gSG.IQVoltage1];
    
    
    D_1 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;... % X pulse
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1; ... % Y pulse
        gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % do another X pulse here
    D_2 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1; ...
        gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
    % end regular spin echo comment back in 4/4/2022 ejd
% %     end
    % C_1 = [start, end, Freq, phase, Amp]
    % C_2 = [start, end, Freq, phase+pi/2, Amp]
    % phase = 0 --> +X pulse; pi/2 --> +Y, pi --> -X;  3*pi/2 --> -Y

    
%     
%     %start ejd comment out 4/4/2022
%     C_1 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;... % X pulse
%         gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1; ... % X pulse
%         gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1]; % -X
%     C_2 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
%         gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1; ...
%         gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi+pi/2 gSG.IQVoltage1];
%     
%     
%     D_1 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;... % X pulse
%         gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1; ... % X pulse
%         gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1]; % do another X pulse here
%     D_2 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
%         gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1; ...
%         gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
%     %end ejd comment out 4/4/2022
%     end

%% end ejd edit 11/27/2021



else
%     if gmSEQ.m ==0
%     C_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1;...
%            gmSEQ.halfpi gmSEQ.halfpi+gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];
%     C_2 = [0 gmSEQ.halfpi 0 0 0];
%     
%     
%     D_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1;...
%            gmSEQ.halfpi gmSEQ.halfpi+gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];
%     D_2 = [0 gmSEQ.halfpi 0 0 0;...
%          gmSEQ.halfpi+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.halfpi+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
%     else
    C_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.halfpi 0 0 0;...
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    
    
    D_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.halfpi 0 0 0;...
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1; ...
        gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
%     end
end

    Length2_2 = round(gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    Length2_3 = round(gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    clkRate2 = 2e9;

 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate',1, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', ...
        'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1); % I port, C1 and D1
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt',...
        'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch2_seg3.txt', Total2_3, 1, 1); % Q port, C2 and D2
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 1, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 1, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 1, 'false');


ApplyDelays();

function EchoAWG_2Counter
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='';

disp('new!')

Wait_p = 1000; %used to be 0.02e6
% 
AfterPi = 500; % before laser detection
AfterLaser = 500; % was 1000
Detect_Window = 5000;
PulseGap = 30;
Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

%%%%% Fixed sequence length %%%%%%
m_nonint = gmSEQ.m;
gmSEQ.m = ceil(gmSEQ.m/2)*2;


gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];
% Pulse for first T2 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];

%Second T2 measurement
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-gmSEQ.CtrGateDur-1000 gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-gmSEQ.CtrGateDur-1000 gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi);


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500];

    C_1 = [0 gmSEQ.halfpi gSG.Freq/1e9 0 gSG.IQVoltage1;... %pi/2 X
           gmSEQ.halfpi+m_nonint/2 gmSEQ.halfpi+m_nonint/2+gmSEQ.pi gSG.Freq/1e9 pi/2 gSG.IQVoltage1;... %pi Y
           gmSEQ.halfpi+m_nonint/2+gmSEQ.pi+m_nonint/2 gmSEQ.halfpi+m_nonint/2+gmSEQ.pi+m_nonint/2+gmSEQ.halfpi gSG.Freq/1e9 0 gSG.IQVoltage1]; %pi/2 X
    
    D_1 = [0 gmSEQ.halfpi gSG.Freq/1e9 0 gSG.IQVoltage1;... %pi/2 X
           gmSEQ.halfpi+m_nonint/2 gmSEQ.halfpi+m_nonint/2+gmSEQ.pi gSG.Freq/1e9 pi/2 gSG.IQVoltage1;... %pi Y
           gmSEQ.halfpi+m_nonint/2+gmSEQ.pi+m_nonint/2 gmSEQ.halfpi+m_nonint/2+gmSEQ.pi+m_nonint/2+gmSEQ.halfpi gSG.Freq/1e9 pi gSG.IQVoltage1]; %pi/2 -X


    Length2_2 = round(gmSEQ.halfpi+m_nonint/2+gmSEQ.pi+m_nonint/2+gmSEQ.halfpi+500);
    Length2_3 = round(gmSEQ.halfpi+m_nonint/2+gmSEQ.pi+m_nonint/2+gmSEQ.halfpi+500);
    clkRate2 = 2e9;

 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate',1, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1); % I port, C1 and D1
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 1, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 1, 'false');


ApplyDelays();

function XY8_SwpN_2Counter
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

if strcmp(gmSEQ.meas,'APD') 
    gmSEQ.CtrGateDur = 1000;
end

Wait_p = 0.02e+6; %0.5e6; WL 080124
% 
AfterPi = 550; %2000; WL 080124
AfterLaser = 1000; %0.1e6; WL 080124
Detect_Window = 5000;
PulseGap = 30;
%SpinLockGap = 2;
%%%%% Fixed sequence length %%%%%%

%gmSEQ.t %
XY8Num = round(gmSEQ.m); % number of single pi pulses

% make it to integer number of 8
% if gmSEQ.m>16
%     XY8Num = ceil(gmSEQ.m/8)*8; % number of single pi pulses
% else
%     XY8Num = round(gmSEQ.m);
% end



XY8Length = XY8Num*(gmSEQ.XY8t+gmSEQ.pi);

% A = [0 gmSEQ.readout 0 pi/2 0.7; ...
%     gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];
% 
% Length1 = gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+1000;
% clkRate1 = 1e9; pause(0.1);
% % used to be 0.05e9
% % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% % 560ns)
% Total1 = ceil(Length1*clkRate1/1e9/16)*16;
% chaseFunctionPool('stopChase',1); pause(0.1);
% chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
% chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
% chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
% pause(1);
% chaseFunctionPool('runChase',1,'false');


gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;


gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];


% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% %gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-1000-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-1000-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
if XY8Num == 0
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20 ...
     gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+gmSEQ.halfpi+40 ...
    gmSEQ.halfpi+gmSEQ.halfpi+PulseGap+gmSEQ.pi+40];
else
if gmSEQ.XY8t <160
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20 ...
     gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+40 ...
    gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+40];
else
    
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2*(XY8Num+2); % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+40];
for zz = 1:XY8Num
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.pi+40];
end
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.halfpi+40];

gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Start_Sig_D+gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.halfpi+40];
for zz = 1:XY8Num
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.pi+40];
end

gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.halfpi+PulseGap+gmSEQ.pi+40];

end
end
%%%%%%%%%%%%%%%%%%%%%%

Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi);


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[550 550];

% for MW_AWG
if gSG.ACmod % in AC modulation mode
    C_1 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    if XY8Num>0
%         for zz = 1:XY8Num
%             if ( (mod(zz,8) == 1) || (mod(zz,8) == 3) || (mod(zz,8) == 6) || (mod(zz,8) == 0)) % X pulse
%                 C_1 = [C_1; ...
%                     gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
%                 C_2 = [C_2; ...
%                     gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
%             else % Y pulse
%                 C_1 = [C_1; ...
%                     gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
%                 C_2 = [C_2; ...
%                     gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1];
%             end
%         end

        for zz = 1:XY8Num %WL 7/31/24
            if ( (mod(zz,8) == 1) || (mod(zz,8) == 3) || (mod(zz,8) == 6) || (mod(zz,8) == 0)) % Y pulse
                C_1 = [C_1; ...
                    gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
                C_2 = [C_2; ...
                    gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1];
            else % X pulse
                C_1 = [C_1; ...
                    gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
                C_2 = [C_2; ...
                    gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
            end
        end
        
        %determine final pi/2 pulse's phase
        
         D_1 = [C_1;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
         D_2 = [C_2;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
         C_1 = [C_1;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
         C_2 = [C_2;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi+pi/2 gSG.IQVoltage1];       
        
    else
        D_1 = [C_1; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
        D_2 = [C_2; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
        
        C_1 = [C_1; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
        C_2 = [C_2; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi+pi/2 gSG.IQVoltage1];
    end           
        
%         if ( (mod(zz,8) == 1) || (mod(zz,8) == 2) || (mod(zz,8) == 6) || (mod(zz,8) == 7) ) % X pulse
%             C_1 = [C_1;...
%                 gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
%             C_2 = [C_2;...
%                 gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
%         else % -X pulse
%             C_1 = [C_1;...
%                 gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
%             C_2 = [C_2;...
%                 gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi+pi/2 gSG.IQVoltage1];       
%         end
%     else
%         C_1 = [C_1; ...
%             gmSEQ.halfpi 2*gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
%         C_2 = [C_2; ...
%             gmSEQ.halfpi 2*gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi+pi/2 gSG.IQVoltage1];
%     end
%     
%     D_1 = [C_1; ...
%             gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
%     D_2 = [C_2; ...
%             gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1];   
%         
else
    
    C_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.halfpi 0 0 0];
    
    if XY8Num>0
    for zz = 1:XY8Num
        if ( (mod(zz,8) == 1) || (mod(zz,8) == 3) || (mod(zz,8) == 6) || (mod(zz,8) == 0)) % X pulse
            C_1 = [C_1; ...
                gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
            C_2 = [C_2; ...
                gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi 0 0 0];
        else % Y pulse
            C_1 = [C_1; ...
                gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi 0 0 0];
            C_2 = [C_2; ...
                gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
        end
    end
    
    % determine final pi/2 pulse's phase
    if ( (mod(zz,8) == 1) || (mod(zz,8) == 2) || (mod(zz,8) == 6) || (mod(zz,8) == 7)) % X pulse
        C_1 = [C_1;...
            gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1];
        C_2 = [C_2;...
            gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi 0 0 0];
    else % -X pulse
        C_1 = [C_1;...
            gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi 0 3/2*pi gSG.IQVoltage1];
        C_2 = [C_2;...
            gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi 0 0 0];       
    end
    
    else
        C_1 = [C_1; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi 0 3/2*pi gSG.IQVoltage1];
        C_2 = [C_2; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi 0 0 0];
    end
    
    D_1 = [C_1; ...
            gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap+gmSEQ.pi 0 0 0];
    D_2 = [C_2; ...
            gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];   
end
        
        

    Length2_2 = round(gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    Length2_3 = round(gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    clkRate2 = 2e9;

 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


ApplyDelays();

function XY8_SwpT_2Counter
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

Wait_p = 0.02e6;
% 
AfterPi = 550; %WL 080124 2000
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 30;
%SpinLockGap = 2;
%%%%% Fixed sequence length %%%%%%

%gmSEQ.XY8Num % number of single pi pulses
gmSEQ.m = ceil(gmSEQ.m/2)*2; % gmSEQ.m is tau, XY8 is tau/2 - tau - tau - tau - tau - tau - tau - tau - tau/2

% legnth of the waits and pis. If you have 8 pis the 7 taus, 2 tau/2
XY8Length = gmSEQ.XY8Num*(gmSEQ.pi) + (gmSEQ.XY8Num)*gmSEQ.m;

% A = [0 gmSEQ.readout 0 pi/2 0.7; ...
%     gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];
% 
% Length1 = gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+1000;
% clkRate1 = 1e9; pause(0.1);
% % used to be 0.05e9
% % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% % 560ns)
% Total1 = ceil(Length1*clkRate1/1e9/16)*16;
% chaseFunctionPool('stopChase',1); pause(0.1);
% chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
% chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
% chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
% pause(1);
% chaseFunctionPool('runChase',1,'false');
% 

% Laser
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=4; % 4 for initialize bright, readout bright, repeat for dark
gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];
Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+AfterPi+Detect_Window+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];

% Laser AWG - presently we do not have one 
% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% %gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

% Open up the SPCM and count some photons
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-2000 gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-2000 gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

% This is microwave switch, needs to be open for AWG defined sequence to
% pass through
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');

% If tau is short, just leave it open the whole XY8 time
if gmSEQ.m <120
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20 ...
     gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+40 ...
    gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+40];

% If tau is long then open and close it
else  
% open number of xy8 pulses plus two for pi/2
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2*(gmSEQ.XY8Num+2); 
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+40];

% for each XY8 pulse, add on another opening of the switch for pi amount,
% but spaced by m
for zz = 1:gmSEQ.XY8Num
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.pi+40];
end
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.halfpi+40];

gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Start_Sig_D+gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.halfpi+40];
for zz = 1:gmSEQ.XY8Num
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.pi+40];
end

gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.halfpi+40];

end
%%%%%%%%%%%%%%%%%%%%%%

Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi);

% I don't know what this does
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

% This triggers sends the AWG pulse through
% Just do it at the start of each sequence
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[100 100];

% for MW_AWG. I (Jon) will always be operating in AC mod mode
if gSG.ACmod % in AC modulation mode
    % start with X pulse for pi/2
    C_1 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    % then add X Y X Y Y X Y X
%     for zz = 1:gmSEQ.XY8Num
%         if ( (mod(zz,8) == 1) || (mod(zz,8) == 3) || (mod(zz,8) == 6) || (mod(zz,8) == 0)) % X pulse
%             C_1 = [C_1; ...
%                 gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
%             C_2 = [C_2; ...
%                 gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
%         else % Y pulse
%             C_1 = [C_1; ...
%                 gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
%             C_2 = [C_2; ...
%                 gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1];
%         end
%     end

    % WL 07/31/24 add Y X Y X X Y X Y
    
    for zz = 1:gmSEQ.XY8Num
        if ( (mod(zz,8) == 1) || (mod(zz,8) == 3) || (mod(zz,8) == 6) || (mod(zz,8) == 0)) % Y pulse
            C_1 = [C_1; ...
                gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
            C_2 = [C_2; ...
                gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1];
        else % X pulse
            C_1 = [C_1; ...
                gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
            C_2 = [C_2; ...
                gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
        end
    end
    
    % For dark sequence, do another X at the end
    D_1 = [C_1; ...
            gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi) gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    D_2 = [C_2; ...
            gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi) gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];  
        
    % to finish bright, do a -X
    C_1 = [C_1; ...
            gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi) gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
    C_2 = [C_2; ...
            gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi) gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi+pi/2 gSG.IQVoltage1];
    
    % determine final pi/2 pulse's phase
    %if ( (mod(zz,8) == 1) || (mod(zz,8) == 2) || (mod(zz,8) == 6) || (mod(zz,8) == 7)) % X pulse
       % C_1 = [C_1;...
          %  gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi) gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
       % C_2 = [C_2;...
           % gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi) gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
   % else % -X pulse
       % C_1 = [C_1;...
            %gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi) gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
        %C_2 = [C_2;...
            %gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi) gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi+pi/2 gSG.IQVoltage1];       
    %end
    
   % D_1 = [C_1; ...
            %gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    %D_2 = [C_2; ...
           % gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1];   
    
    
else
    % always use AC if you are going to use DC then you'll have to rewrite
    % the code
    C_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.halfpi 0 0 0];
    for zz = 1:gmSEQ.XY8Num
        if ( (mod(zz,8) == 1) || (mod(zz,8) == 3) || (mod(zz,8) == 6) || (mod(zz,8) == 0)) % X pulse
            C_1 = [C_1; ...
                gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
            C_2 = [C_2; ...
                gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2+gmSEQ.pi 0 0 0];
        else % Y pulse
            C_1 = [C_1; ...
                gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2+gmSEQ.pi 0 0 0];
            C_2 = [C_2; ...
                gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.m+gmSEQ.pi)+gmSEQ.m/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
        end
    end
    
    % determine final pi/2 pulse's phase
    %if ( (mod(zz,8) == 1) || (mod(zz,8) == 2) || (mod(zz,8) == 6) || (mod(zz,8) == 7)) % X pulse
        %C_1 = [C_1;...
            %gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi) gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1];
        %C_2 = [C_2;...
            %gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi) gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi 0 0 0];
    %else % -X pulse
        %C_1 = [C_1;...
            %gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi) gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi 0 3/2*pi gSG.IQVoltage1];
        %C_2 = [C_2;...
            %gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi) gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi 0 0 0];       
    %end
    
    D_1 = [C_1; ...
            gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi) gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi 0 0 gSG.IQVoltage1]; % for dark, do another X
    D_2 = [C_2; ...
            gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.XY8Num*(gmSEQ.m+gmSEQ.pi)+gmSEQ.halfpi+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];   
end
        
        

    Length2_2 = round(gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+1000);
    Length2_3 = round(gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+1000);
    clkRate2 = 2e9;

 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 1, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 1, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 1, 'false');


ApplyDelays();

function XY8_SwpN_2Counter_fixed_v2 %Reginald, 9/6/24
%Same as XY8_SwpN_2Counter except swapping variable XY8length to fixed TempTau1
%in AOM and CTR0
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

gSG2.bOn = 0;
gSG2.bMod='';

% gmSEQ.halfpi = gmSEQ.pi2;
% gSG.IQVoltage1 = gSG.AWGAmp;
gmSEQ.TempTau0 = gmSEQ.XY8t; %TempTau0 is the pulse interval length; 
gmSEQ.TempTau1 = gmSEQ.DEERpi; %TempTau1 is the fixed length between first and last half pi

%gSG.AWGClockRate = 2; % in GHz. Yuanqi; WL: maybe not necessary for ours? 
gSG.AWGFreq = (gSG.SGbasefreq-gSG.Freq)/1e9;
gSG.AWGAmp = gSG.IQVoltage1; 

if strcmp(gmSEQ.meas,'APD') 
    gmSEQ.CtrGateDur = 1000;
end
Wait_p = 0.2e5;
AfterLaser = 1000;
Detect_Window = 5000;
AfterPi = 500; %500 in our Rabi case; 200 --> 500, WL 12/19/24
XY8Num = round(gmSEQ.m); % number of single pi pulses
XY8Length = XY8Num*(gmSEQ.TempTau0+gmSEQ.pi); % TempTau0 is the pulse interval length
if XY8Length > gmSEQ.TempTau1 % TempTau1 is the fixed length between first and last half pi 
    warning('TempTau1 is shorter than Pulse Length. Please input a longer TempTau1');
end
if strcmp(gmSEQ.meas,'APD') 
    gmSEQ.CtrGateDur = 1000;
end
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];
% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];
Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi+Detect_Window+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-1000-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-1000-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [Wait_p+gmSEQ.readout+AfterLaser-100, Start_Sig_D+gmSEQ.readout+AfterLaser-100]; %switch buffer time = 25 -> 50; 100 in our Rabi case; 50 --> 100, WL 12/19/24
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+200 gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+200];
%%%%%%%%%%%%%%%%%%%%%%
Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi);
Max_length2 = gmSEQ.CHN(1).T(4) + Detect_Window;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length2-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[250 250];
% for MW_AWG
if gSG.ACmod % in AC modulation mode ==> WL: gSG.ACmod
    %phase = 0 --> +X; pi/2 --> +Y; pi --> -X; 3*pi/2 --> -Y
    C_1 = [0 gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.AWGAmp]; %+X pulse 0 / +Y pulse pi/2
    C_2 = [0 gmSEQ.halfpi gSG.AWGFreq pi/2 + pi/2 gSG.AWGAmp];
    
    if XY8Num>0
        for zz = 1:XY8Num
            if ( (mod(zz,8) == 1) || (mod(zz,8) == 3) || (mod(zz,8) == 6) || (mod(zz,8) == 0)) %Y pulse pi/2 / X pulse 0 
                C_1 = [C_1; ...
                    gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi gSG.AWGFreq 0 gSG.IQVoltage1];
                C_2 = [C_2; ...
                    gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi gSG.AWGFreq pi/2 gSG.IQVoltage1]; 
            else %X pulse 0 / Y pulse pi /2 
                C_1 = [C_1; ...
                    gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi gSG.AWGFreq pi/2 gSG.IQVoltage1];
                C_2 = [C_2; ...
                    gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi gSG.AWGFreq pi/2 + pi/2 gSG.IQVoltage1]; 
            end
        end
        
        
                % determine final pi/2 pulse's phase
        if ( (mod(zz,8) == 2) || (mod(zz,8) == 3) || (mod(zz,8) == 5) || (mod(zz,8) == 6) ) %-X pulse pi / -Y pulse 3*pi/2
            D_1 = [C_1;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi gSG.AWGFreq 3*pi/2 gSG.IQVoltage1]; 
            D_2 = [C_2;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi gSG.AWGFreq 0 gSG.IQVoltage1]; 
        else %X pulse 0 / Y pulse pi/2
            D_1 = [C_1;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.IQVoltage1];
            D_2 = [C_2;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi gSG.AWGFreq pi/2 + pi/2 gSG.IQVoltage1];       
        end
        % determine final pi/2 pulse's phase
        if ( (mod(zz,8) == 2) || (mod(zz,8) == 3) || (mod(zz,8) == 5) || (mod(zz,8) == 6) ) % X pulse 0 / Y pulse pi/2
            C_1 = [C_1;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.IQVoltage1];
            C_2 = [C_2;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi gSG.AWGFreq pi/2 + pi/2 gSG.IQVoltage1];
        else % -X pulse / -Y pulse 
            C_1 = [C_1;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi gSG.AWGFreq 3*pi/2 gSG.IQVoltage1];
            C_2 = [C_2;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi gSG.AWGFreq 0 gSG.IQVoltage1];       
        end
    else
        D_1 = [C_1; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.IQVoltage1]; %X 0 / Y pi/2
        D_2 = [C_2; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq pi/2 + pi/2 gSG.IQVoltage1];
        
        C_1 = [C_1; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq 3*pi/2 gSG.IQVoltage1]; %-X pi / -Y 3*pi/2
        C_2 = [C_2; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq 0 gSG.IQVoltage1];
    end
    
%     D_1 = [C_1; ...
%             gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap+gmSEQ.pi gSG.AWGFreq 0 gSG.IQVoltage1];
%     D_2 = [C_2; ...
%             gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap+gmSEQ.pi gSG.AWGFreq -pi/2 gSG.IQVoltage1];   
%     
    
else
%DC modulation
end
        
        
    Length2_2 = round(gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+1000);
    Length2_3 = round(gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+1000);
    clkRate2 = 2e9;
 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', C_1, gSG.AWGClockRate, Length2_2, 'wave_AWG_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, gSG.AWGClockRate, Length2_2, 'wave_AWG_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, gSG.AWGClockRate, Length2_3, 'wave_AWG_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, gSG.AWGClockRate, Length2_3, 'wave_AWG_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG_ch2_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 1, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 1, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 1, 'false');
ApplyDelays();

function XY8_SwpN_2Counter_fixed_v2_ctrgatedur_opt 
%Same as XY8_SwpN_2Counter except swapping variable XY8length to fixed TempTau1
%in AOM and CTR0
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

gSG2.bOn = 0;
gSG2.bMod='';

% gmSEQ.halfpi = gmSEQ.pi2;
% gSG.IQVoltage1 = gSG.AWGAmp;
gmSEQ.TempTau0 = gmSEQ.XY8t; %TempTau0 is the pulse interval length; 
gmSEQ.TempTau1 = gmSEQ.DEERpi; %TempTau1 is the fixed length between first and last half pi

%gSG.AWGClockRate = 2; % in GHz. Yuanqi; WL: maybe not necessary for ours? 
gSG.AWGFreq = (gSG.SGbasefreq-gSG.Freq)/1e9;
gSG.AWGAmp = gSG.IQVoltage1; 

if strcmp(gmSEQ.meas,'APD') 
    gmSEQ.CtrGateDur = 1000;
end
Wait_p = 0.2e5;
AfterLaser = 1000;
Detect_Window = 5000;
AfterPi = 500; %2000 in our t-variation case; 500 for Rabi; 200 --> 500, WL 12/18/24 
XY8Num = 8; % number of single pi pulses
XY8Length = XY8Num*(gmSEQ.TempTau0+gmSEQ.pi); % TempTau0 is the pulse interval length
if XY8Length > gmSEQ.TempTau1 % TempTau1 is the fixed length between first and last half pi 
    warning('TempTau1 is shorter than Pulse Length. Please input a longer TempTau1');
end
if strcmp(gmSEQ.meas,'APD') 
    gmSEQ.CtrGateDur = 1000;
end
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];
% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];
Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi+Detect_Window+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-1000-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-1000-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m gmSEQ.m gmSEQ.m gmSEQ.m];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [Wait_p+gmSEQ.readout+AfterLaser-100, Start_Sig_D+gmSEQ.readout+AfterLaser-100]; %switch buffer time = 25 -> 50; 100 for Rabi; buffer time 50 --> 100, WL 12/18/24
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+200 gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+200];
%%%%%%%%%%%%%%%%%%%%%%
Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi);
Max_length2 = gmSEQ.CHN(1).T(4) + Detect_Window;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length2-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[250 250];
% for MW_AWG
if gSG.ACmod % in AC modulation mode ==> WL: gSG.ACmod
    %phase = 0 --> +X; pi/2 --> +Y; pi --> -X; 3*pi/2 --> -Y
    C_1 = [0 gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.AWGAmp]; %+X pulse 0 / +Y pulse pi/2
    C_2 = [0 gmSEQ.halfpi gSG.AWGFreq pi/2 + pi/2 gSG.AWGAmp];
    
    if XY8Num>0
        for zz = 1:XY8Num
            if ( (mod(zz,8) == 1) || (mod(zz,8) == 3) || (mod(zz,8) == 6) || (mod(zz,8) == 0)) %Y pulse pi/2 / X pulse 0 
                C_1 = [C_1; ...
                    gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi gSG.AWGFreq 0 gSG.IQVoltage1];
                C_2 = [C_2; ...
                    gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi gSG.AWGFreq pi/2 gSG.IQVoltage1]; 
            else %X pulse 0 / Y pulse pi /2 
                C_1 = [C_1; ...
                    gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi gSG.AWGFreq pi/2 gSG.IQVoltage1];
                C_2 = [C_2; ...
                    gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi gSG.AWGFreq pi/2 + pi/2 gSG.IQVoltage1]; 
            end
        end
        
        
                % determine final pi/2 pulse's phase
        if ( (mod(zz,8) == 2) || (mod(zz,8) == 3) || (mod(zz,8) == 5) || (mod(zz,8) == 6) ) %-X pulse pi / -Y pulse 3*pi/2
            D_1 = [C_1;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi gSG.AWGFreq 3*pi/2 gSG.IQVoltage1]; 
            D_2 = [C_2;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi gSG.AWGFreq 0 gSG.IQVoltage1]; 
        else %X pulse 0 / Y pulse pi/2
            D_1 = [C_1;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.IQVoltage1];
            D_2 = [C_2;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi gSG.AWGFreq pi/2 + pi/2 gSG.IQVoltage1];       
        end
        % determine final pi/2 pulse's phase
        if ( (mod(zz,8) == 2) || (mod(zz,8) == 3) || (mod(zz,8) == 5) || (mod(zz,8) == 6) ) % X pulse 0 / Y pulse pi/2
            C_1 = [C_1;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.IQVoltage1];
            C_2 = [C_2;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi gSG.AWGFreq pi/2 + pi/2 gSG.IQVoltage1];
        else % -X pulse / -Y pulse 
            C_1 = [C_1;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi gSG.AWGFreq 3*pi/2 gSG.IQVoltage1];
            C_2 = [C_2;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi gSG.AWGFreq 0 gSG.IQVoltage1];       
        end
    else
        D_1 = [C_1; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.IQVoltage1]; %X 0 / Y pi/2
        D_2 = [C_2; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq pi/2 + pi/2 gSG.IQVoltage1];
        
        C_1 = [C_1; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq 3*pi/2 gSG.IQVoltage1]; %-X pi / -Y 3*pi/2
        C_2 = [C_2; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq 0 gSG.IQVoltage1];
    end
    
%     D_1 = [C_1; ...
%             gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap+gmSEQ.pi gSG.AWGFreq 0 gSG.IQVoltage1];
%     D_2 = [C_2; ...
%             gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap+gmSEQ.pi gSG.AWGFreq -pi/2 gSG.IQVoltage1];   
%     
    
else
%DC modulation
end
        
        
    Length2_2 = round(gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+1000);
    Length2_3 = round(gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+1000);
    clkRate2 = 2e9;
 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', C_1, gSG.AWGClockRate, Length2_2, 'wave_AWG_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, gSG.AWGClockRate, Length2_2, 'wave_AWG_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, gSG.AWGClockRate, Length2_3, 'wave_AWG_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, gSG.AWGClockRate, Length2_3, 'wave_AWG_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG_ch2_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 1, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 1, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 1, 'false');
ApplyDelays();


function XY8_SwpN_2Counter_fixed_v3 %WL, 9/6/24
%Same as XY8_SwpN_2Counter except swapping variable XY8length to fixed TempTau1
%in AOM and CTR0
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% gmSEQ.halfpi = gmSEQ.pi2;
% gSG.IQVoltage1 = gSG.AWGAmp;
gmSEQ.TempTau0 = gmSEQ.XY8t; %TempTau0 is the pulse interval length; 
gmSEQ.TempTau1 = gmSEQ.DEERpi; %TempTau1 is the fixed length between first and last half pi

%gSG.AWGClockRate = 2; % in GHz. Yuanqi; WL: maybe not necessary for ours? 
gSG.AWGFreq = (gSG.SGbasefreq-gSG.Freq)/1e9;
gSG.AWGAmp = gSG.IQVoltage1; 

if strcmp(gmSEQ.meas,'APD') 
    gmSEQ.CtrGateDur = 1000;
end
Wait_p = 0.2e5;
AfterLaser = 1000;
Detect_Window = 5000;
AfterPi = 200; %2000 in our t-variation case
XY8Num = round(gmSEQ.m); % number of refocusing pi pulses
XY8Length = XY8Num*(gmSEQ.TempTau0+gmSEQ.pi); % single XY8 cycle length except the pi/2 pulses; TempTau0 is the pulse interval length
if XY8Length > gmSEQ.TempTau1 % TempTau1 is the fixed length between first and last half pi to take account of the T1 effect
    warning('TempTau1 is shorter than Pulse Length. Please input a longer TempTau1');
end
if strcmp(gmSEQ.meas,'APD') 
    gmSEQ.CtrGateDur = 1000;
end
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];
% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];
Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi+Detect_Window+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-1000-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-1000-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [Wait_p+gmSEQ.readout+AfterLaser-50, Start_Sig_D+gmSEQ.readout+AfterLaser-50]; %MW buffer: 25 --> 50
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+100 gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+100];
%%%%%%%%%%%%%%%%%%%%%%
Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi);
Max_length2 = gmSEQ.CHN(1).T(4) + Detect_Window;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length2-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[250 250];
% for MW_AWG

if gSG.ACmod % in AC modulation mode ==> WL: gSG.ACmod
    %phase = 0 --> +X; pi/2 --> +Y; pi --> -X; 3*pi/2 --> -Y
    
    if XY8Num>0
        
        XY8Cyc = XY8Num/8; % number of XY8 cycles 
        Cyc = (gmSEQ.pi + gmSEQ.TempTau0)*8; % single XY8 cycle length
        
        WaveForm_1I = zeros(2 + 8*XY8Cyc, 5);
        WaveForm_1I(1, :) = [0 gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.AWGAmp]; % Y pulse
        
        for i = 1:XY8Cyc
            WaveForm_1I(1 + (i-1)*8 + 1, :) = [gmSEQ.halfpi+gmSEQ.TempTau0/2+(i-1+0/8)*Cyc gmSEQ.halfpi+gmSEQ.TempTau0/2+(i-1+0/8)*Cyc+gmSEQ.pi gSG.AWGFreq 0 gSG.AWGAmp]; % pi_x
            WaveForm_1I(1 + (i-1)*8 + 2, :) = [gmSEQ.halfpi+gmSEQ.TempTau0/2+(i-1+1/8)*Cyc gmSEQ.halfpi+gmSEQ.TempTau0/2+(i-1+1/8)*Cyc+gmSEQ.pi gSG.AWGFreq pi/2 gSG.AWGAmp]; % pi_y
            WaveForm_1I(1 + (i-1)*8 + 3, :) = [gmSEQ.halfpi+gmSEQ.TempTau0/2+(i-1+2/8)*Cyc gmSEQ.halfpi+gmSEQ.TempTau0/2+(i-1+2/8)*Cyc+gmSEQ.pi gSG.AWGFreq 0 gSG.AWGAmp]; % pi_x
            WaveForm_1I(1 + (i-1)*8 + 4, :) = [gmSEQ.halfpi+gmSEQ.TempTau0/2+(i-1+3/8)*Cyc gmSEQ.halfpi+gmSEQ.TempTau0/2+(i-1+3/8)*Cyc+gmSEQ.pi gSG.AWGFreq pi/2 gSG.AWGAmp]; % pi_y
            WaveForm_1I(1 + (i-1)*8 + 5, :) = [gmSEQ.halfpi+gmSEQ.TempTau0/2+(i-1+4/8)*Cyc gmSEQ.halfpi+gmSEQ.TempTau0/2+(i-1+4/8)*Cyc+gmSEQ.pi gSG.AWGFreq pi/2 gSG.AWGAmp]; % pi_y
            WaveForm_1I(1 + (i-1)*8 + 6, :) = [gmSEQ.halfpi+gmSEQ.TempTau0/2+(i-1+5/8)*Cyc gmSEQ.halfpi+gmSEQ.TempTau0/2+(i-1+5/8)*Cyc+gmSEQ.pi gSG.AWGFreq 0 gSG.AWGAmp]; % pi_x
            WaveForm_1I(1 + (i-1)*8 + 7, :) = [gmSEQ.halfpi+gmSEQ.TempTau0/2+(i-1+6/8)*Cyc gmSEQ.halfpi+gmSEQ.TempTau0/2+(i-1+6/8)*Cyc+gmSEQ.pi gSG.AWGFreq pi/2 gSG.AWGAmp]; % pi_y
            WaveForm_1I(1 + (i-1)*8 + 8, :) = [gmSEQ.halfpi+gmSEQ.TempTau0/2+(i-1+7/8)*Cyc gmSEQ.halfpi+gmSEQ.TempTau0/2+(i-1+7/8)*Cyc+gmSEQ.pi gSG.AWGFreq 0 gSG.AWGAmp]; % pi_x
        end 
        
        WaveForm_1I(2 + 8*XY8Cyc, :) = [gmSEQ.halfpi+XY8Length gmSEQ.halfpi+XY8Length+gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.AWGAmp]; %Y


    else
        
        WaveForm_1I = [0 gmSEQ.halfpi*2 gSG.AWGFreq 0 0];

    end
        
else
%DC modulation - need to be added

end

    WaveForm_1Q = WaveForm_1I + repmat([0 0 0 pi/2 0], size(WaveForm_1I, 1), 1);
    clkRate2 = 2e9;
    
    Length2_2 = round(gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+1000);
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    if XY8Num == 0
        WaveForm_2I = [0 gmSEQ.halfpi*2 gSG.AWGFreq 0 gSG.AWGAmp];
        WaveForm_2Q = WaveForm_2I + repmat([0 0 0 pi/2 0], size(WaveForm_2I, 1), 1);
        Length2_3 = round(gmSEQ.halfpi+gmSEQ.halfpi+1000);
        Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    else
        WaveForm_2I = WaveForm_1I;
        WaveForm_2I(size(WaveForm_1I, 1), 4) = WaveForm_1I(size(WaveForm_1I, 1), 4) + pi; % Differential measurement
        WaveForm_2Q = WaveForm_1Q;
        WaveForm_2Q(size(WaveForm_1I, 1), 4) = WaveForm_1Q(size(WaveForm_1I, 1), 4) + pi; % Differential measurement
        Length2_3 = round(gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+1000);
        Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    end
    
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', WaveForm_1I, gSG.AWGClockRate, Length2_2, 'wave_AWG_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', WaveForm_1Q, gSG.AWGClockRate, Length2_2, 'wave_AWG_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', WaveForm_2I, gSG.AWGClockRate, Length2_3, 'wave_AWG_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', WaveForm_2Q, gSG.AWGClockRate, Length2_3, 'wave_AWG_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG_ch2_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 1, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 1, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 1, 'false');
ApplyDelays();

function DROIDN12_fixed_v2 %Wonjae, 11/28/24
% Same as DROIDN12 except swapping variable DROIDNLength to fixed TempTau1 in
% AOM and ctr0
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';
gSG2.bOn = 0;
gSG2.bMod='';
%gmSEQ.halfpi = gmSEQ.pi2;
%gSG.IQVoltage1 = gSG.AWGAmp;
%gSG.AWGClockRate = 2; % in GHz. Yuanqi
gmSEQ.TempTau0 = gmSEQ.XY8t; %TempTau0 is the pulse interval length;
gmSEQ.TempTau1 = gmSEQ.DEERpi; %TempTau1 is the fixed length between polarization & detection pulses to account of the T1 relaxation effect on T2
gSG.AWGFreq = (gSG.SGbasefreq-gSG.Freq)/1e9;
gSG.AWGAmp = gSG.IQVoltage1; 
if strcmp(gmSEQ.meas,'APD') 
    gmSEQ.CtrGateDur = 1000;
end
Wait_p = 0.3e5;
AfterLaser = 1000;
Detect_Window = 5000;
AfterPi = 200;
DROIDNNum = round(gmSEQ.m); % number of single DROIDN12 cycle 
N12Length = 12*(gmSEQ.TempTau0+gmSEQ.pi); % single DROIDN12 cycle length; TempTau0 is the pulse interval length
DROIDNLength = DROIDNNum*N12Length; % Total Pulse Length
if DROIDNLength > gmSEQ.TempTau1 
    warning('TempTau1 is shorter than Pulse Length. Please input a longer TempTau1');
end
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];
% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];
Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi+Detect_Window+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-1000-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-1000-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
if mod(gmSEQ.pi, 2) == 0
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [Wait_p+gmSEQ.readout+AfterLaser-50, Start_Sig_D+gmSEQ.readout+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.halfpi+DROIDNLength+gmSEQ.halfpi+100 gmSEQ.halfpi+DROIDNLength+gmSEQ.halfpi+100];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [Wait_p+gmSEQ.readout+AfterLaser-50, Start_Sig_D+gmSEQ.readout+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.halfpi+DROIDNLength+gmSEQ.halfpi+101 gmSEQ.halfpi+DROIDNLength+gmSEQ.halfpi+101];
end
%%%%%%%%%%%%%%%%%%%%%%
Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.halfpi+DROIDNLength+gmSEQ.halfpi);
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[250 250]; %200 --> 250, 12/10/24, WL
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1900 1900]; %1900
% for MW_AWG
if gSG.ACmod % in AC modulation mode
    %phase = 0 --> +X; pi/2 --> +Y; pi --> -X; 3*pi/2 --> -Y
    C_1 = zeros(DROIDNNum*15+2,5); %15 rows in a 12-pulse DROID / 2 is first and last pi/2 pulse
    C_2 = zeros(DROIDNNum*15+2,5);
    D_1 = zeros(DROIDNNum*15+2,5);
    D_2 = zeros(DROIDNNum*15+2,5);
    C_1(1,:) = [0 gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.AWGAmp]; % + Y
    C_2(1,:) = [0 gmSEQ.halfpi gSG.AWGFreq pi gSG.AWGAmp];
    
    if DROIDNNum>0
        for zz = 1:DROIDNNum
            StartTime = (zz-1)*N12Length + gmSEQ.halfpi; %N12 zz-th cycle start time 
            StartRow = (zz-1)*15 + 1; %Start from (StartRow + 1) ;-)
            for kk = 1:3
                    C_1(StartRow+(kk-1)*5+1,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0) StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi gSG.AWGFreq 0 gSG.AWGAmp]; %1: X
                    C_2(StartRow+(kk-1)*5+1,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0) StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi gSG.AWGFreq pi/2 gSG.AWGAmp];
                    C_1(StartRow+(kk-1)*5+2,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp]; %2: X
                    C_2(StartRow+(kk-1)*5+2,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.AWGAmp];
                    C_1(StartRow+(kk-1)*5+3,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.halfpi StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.halfpi+gmSEQ.halfpi gSG.AWGFreq 3*pi/2 gSG.AWGAmp]; %3: -Y
                    C_2(StartRow+(kk-1)*5+3,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.halfpi StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.halfpi+gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp];
                    C_1(StartRow+(kk-1)*5+4,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi gSG.AWGFreq pi gSG.AWGAmp]; %4: -X
                    C_2(StartRow+(kk-1)*5+4,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi gSG.AWGFreq 3*pi/2 gSG.AWGAmp];
                    C_1(StartRow+(kk-1)*5+5,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi gSG.AWGFreq pi gSG.AWGAmp]; %5: -X
                    C_2(StartRow+(kk-1)*5+5,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi gSG.AWGFreq 3*pi/2 gSG.AWGAmp];
            end
        end %last pi/2 pulses 
            D_1 = [C_1(1:end-1,:);...
                StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0/2 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0/2+gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.AWGAmp]; %Y, dark
            D_2 = [C_2(1:end-1,:);...
                StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0/2 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0/2+gmSEQ.halfpi gSG.AWGFreq pi gSG.AWGAmp];
            C_1(end,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0/2 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0/2+gmSEQ.halfpi gSG.AWGFreq 3*pi/2 gSG.AWGAmp]; %-Y, bright
            C_2(end,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0/2 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0/2+gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp];
    else %DROIDNum = 0 case 
        D_1 = [C_1(1,:); ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.AWGAmp]; %Y, dark
        D_2 = [C_2(1,:); ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq pi gSG.AWGAmp];
        
        C_1 = [C_1(1,:); ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq 3*pi/2 gSG.AWGAmp]; %-Y, bright
        C_2 = [C_2(1,:); ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp];
    end
else
%DC modulation
end
%%%%
    Length2_2 = round(gmSEQ.halfpi+DROIDNLength+gmSEQ.halfpi+1000);
    Length2_3 = round(gmSEQ.halfpi+DROIDNLength+gmSEQ.halfpi+1000);
    clkRate2 = 2e9;
 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', C_1, gSG.AWGClockRate, Length2_2, 'wave_AWG_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, gSG.AWGClockRate, Length2_2, 'wave_AWG_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, gSG.AWGClockRate, Length2_3, 'wave_AWG_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, gSG.AWGClockRate, Length2_3, 'wave_AWG_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG_ch2_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 1, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 1, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 1, 'false');
ApplyDelays();

function DROIDN12_fixed_ctrgate_opt %Wonjae, 11/28/24
% Same as DROIDN12 except swapping variable DROIDNLength to fixed TempTau1 in
% AOM and ctr0
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';
gSG2.bOn = 0;
gSG2.bMod='';
%gmSEQ.halfpi = gmSEQ.pi2;
%gSG.IQVoltage1 = gSG.AWGAmp;
%gSG.AWGClockRate = 2; % in GHz. Yuanqi
gmSEQ.TempTau0 = gmSEQ.XY8t; %TempTau0 is the pulse interval length;
gmSEQ.TempTau1 = gmSEQ.DEERpi; %TempTau1 is the fixed length between polarization & detection pulses to account of the T1 relaxation effect on T2
gSG.AWGFreq = (gSG.SGbasefreq-gSG.Freq)/1e9;
gSG.AWGAmp = gSG.IQVoltage1; 
if strcmp(gmSEQ.meas,'APD') 
    gmSEQ.CtrGateDur = 1000;
end
Wait_p = 0.3e5;
AfterLaser = 1000;
Detect_Window = 5000;
AfterPi = 200;
DROIDNNum = 1; % number of single DROIDN12 cycle 
N12Length = 12*(gmSEQ.TempTau0+gmSEQ.pi); % single DROIDN12 cycle length; TempTau0 is the pulse interval length
DROIDNLength = DROIDNNum*N12Length; % Total Pulse Length
if DROIDNLength > gmSEQ.TempTau1 
    warning('TempTau1 is shorter than Pulse Length. Please input a longer TempTau1');
end
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];
% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];
Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi+Detect_Window+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-1000-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-1000-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m gmSEQ.m gmSEQ.m gmSEQ.m];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
if mod(gmSEQ.pi, 2) == 0
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [Wait_p+gmSEQ.readout+AfterLaser-50, Start_Sig_D+gmSEQ.readout+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.halfpi+DROIDNLength+gmSEQ.halfpi+100 gmSEQ.halfpi+DROIDNLength+gmSEQ.halfpi+100];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [Wait_p+gmSEQ.readout+AfterLaser-50, Start_Sig_D+gmSEQ.readout+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.halfpi+DROIDNLength+gmSEQ.halfpi+101 gmSEQ.halfpi+DROIDNLength+gmSEQ.halfpi+101];
end
%%%%%%%%%%%%%%%%%%%%%%
Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.halfpi+DROIDNLength+gmSEQ.halfpi);
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[2000 2000];
% for MW_AWG
if gSG.ACmod % in AC modulation mode
    %phase = 0 --> +X; pi/2 --> +Y; pi --> -X; 3*pi/2 --> -Y
    C_1 = zeros(DROIDNNum*15+2,5); %15 rows in a 12-pulse DROID / 2 is first and last pi/2 pulse
    C_2 = zeros(DROIDNNum*15+2,5);
    D_1 = zeros(DROIDNNum*15+2,5);
    D_2 = zeros(DROIDNNum*15+2,5);
    C_1(1,:) = [0 gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.AWGAmp]; % + Y
    C_2(1,:) = [0 gmSEQ.halfpi gSG.AWGFreq pi gSG.AWGAmp];
    
    if DROIDNNum>0
        for zz = 1:DROIDNNum
            StartTime = (zz-1)*N12Length + gmSEQ.halfpi; %N12 zz-th cycle start time 
            StartRow = (zz-1)*15 + 1; %Start from (StartRow + 1) ;-)
            for kk = 1:3
                    C_1(StartRow+(kk-1)*5+1,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0) StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi gSG.AWGFreq 0 gSG.AWGAmp]; %1: X
                    C_2(StartRow+(kk-1)*5+1,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0) StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi gSG.AWGFreq pi/2 gSG.AWGAmp];
                    C_1(StartRow+(kk-1)*5+2,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp]; %2: X
                    C_2(StartRow+(kk-1)*5+2,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.AWGAmp];
                    C_1(StartRow+(kk-1)*5+3,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.halfpi StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.halfpi+gmSEQ.halfpi gSG.AWGFreq 3*pi/2 gSG.AWGAmp]; %3: -Y
                    C_2(StartRow+(kk-1)*5+3,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.halfpi StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.halfpi+gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp];
                    C_1(StartRow+(kk-1)*5+4,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi gSG.AWGFreq pi gSG.AWGAmp]; %4: -X
                    C_2(StartRow+(kk-1)*5+4,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi gSG.AWGFreq 3*pi/2 gSG.AWGAmp];
                    C_1(StartRow+(kk-1)*5+5,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi gSG.AWGFreq pi gSG.AWGAmp]; %5: -X
                    C_2(StartRow+(kk-1)*5+5,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi gSG.AWGFreq 3*pi/2 gSG.AWGAmp];
            end
        end %last pi/2 pulses 
            D_1 = [C_1(1:end-1,:);...
                StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0/2 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0/2+gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.AWGAmp]; %Y, dark
            D_2 = [C_2(1:end-1,:);...
                StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0/2 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0/2+gmSEQ.halfpi gSG.AWGFreq pi gSG.AWGAmp];
            C_1(end,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0/2 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0/2+gmSEQ.halfpi gSG.AWGFreq 3*pi/2 gSG.AWGAmp]; %-Y, bright
            C_2(end,:) = [StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0/2 StartTime+gmSEQ.TempTau0/2+(kk-1)*4*(gmSEQ.pi+gmSEQ.TempTau0)+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0+gmSEQ.pi+gmSEQ.TempTau0/2+gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp];
    else %DROIDNum = 0 case 
        D_1 = [C_1(1,:); ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.AWGAmp]; %Y, dark
        D_2 = [C_2(1,:); ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq pi gSG.AWGAmp];
        
        C_1 = [C_1(1,:); ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq 3*pi/2 gSG.AWGAmp]; %-Y, bright
        C_2 = [C_2(1,:); ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp];
    end
else
%DC modulation
end
%%%%
    Length2_2 = round(gmSEQ.halfpi+DROIDNLength+gmSEQ.halfpi+1000);
    Length2_3 = round(gmSEQ.halfpi+DROIDNLength+gmSEQ.halfpi+1000);
    clkRate2 = 2e9;
 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 1); pause(0.3);
    chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', C_1, gSG.AWGClockRate, Length2_2, 'wave_AWG_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, gSG.AWGClockRate, Length2_2, 'wave_AWG_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, gSG.AWGClockRate, Length2_3, 'wave_AWG_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, gSG.AWGClockRate, Length2_3, 'wave_AWG_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG_ch2_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 1, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 1, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 1, 'false');
ApplyDelays();


function Echo_2Counter_P1mix
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% HPSG = visa('agilent', 'GPIB0::19::INSTR');
%     fclose(HPSG);
%     fopen(HPSG);
%     fprintf(HPSG, '%s', 'RF0');
%     AA = ['CW ', num2str(gSG.Freq2), 'GZ'];
%     fprintf(HPSG, '%s', AA);
%     AA = ['PL', num2str(gSG.Pow2), 'dm'];
%     fprintf(HPSG, '%s', AA);
%     fprintf(HPSG, '%s', 'RF1');
%     pause(0.5);
%     fclose(HPSG);

mwlength=gmSEQ.m;
Wait_p = 0.5e5; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

AfterLaser = 1000;
AfterPi = 1000;

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+2*mwlength+2*gmSEQ.pi+20+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout 20000];

Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+2*mwlength+2*gmSEQ.pi+20+gmSEQ.pi+AfterPi+20000+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+2*mwlength+2*gmSEQ.pi+20+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout 20000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=5;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+mwlength+gmSEQ.pi+mwlength...
    Start_Sig_D+gmSEQ.readout+AfterLaser Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+mwlength+gmSEQ.pi+mwlength...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi/2 gmSEQ.pi/2 gmSEQ.pi/2 gmSEQ.pi/2 ...
    gmSEQ.pi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+mwlength Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+mwlength];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.pi gmSEQ.pi];

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('DEERPulse');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=18;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T = [5000 5000+10000 5000+20000 5000+30000 5000+40000 5000+50000 5000+60000 5000+70000 ...
%     Wait_p+gmSEQ.readout-2000 ...
% gmSEQ.CHN(1).T(2)+20000+5000 gmSEQ.CHN(1).T(2)+20000+5000+10000 gmSEQ.CHN(1).T(2)+20000+5000+20000 gmSEQ.CHN(1).T(1*(2))+20000+5000+30000 ...
%     gmSEQ.CHN(1).T(2)+20000+5000+40000 gmSEQ.CHN(1).T(2)+20000+5000+50000 gmSEQ.CHN(1).T(2)+20000+5000+60000 gmSEQ.CHN(1).T(2)+20000+5000+70000 ...
%     Start_Sig_D+gmSEQ.readout-2000];

% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 ...
%     gmSEQ.P1Pulse/2 ...
%     gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 ...
%     gmSEQ.P1Pulse/2];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 20000*2 + 2*(AfterLaser+20+AfterPi+3*gmSEQ.pi) + 4*mwlength-200;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

ApplyDelays();

function Echo_2Counter_NoP1mix
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% HPSG = visa('agilent', 'GPIB0::19::INSTR');
%     fclose(HPSG);
%     fopen(HPSG);
%     fprintf(HPSG, '%s', 'RF0');
%     AA = ['CW ', num2str(gSG.Freq2), 'GZ'];
%     fprintf(HPSG, '%s', AA);
%     AA = ['PL', num2str(gSG.Pow2), 'dm'];
%     fprintf(HPSG, '%s', AA);
%     fprintf(HPSG, '%s', 'RF1');
%     pause(0.5);
%     fclose(HPSG);

mwlength=gmSEQ.m;
Wait_p = 2e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

AfterLaser = 1000;

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+2*mwlength+2*gmSEQ.pi+20+gmSEQ.pi+100];
gmSEQ.CHN(1).DT = [gmSEQ.readout 20000];

Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+2*mwlength+2*gmSEQ.pi+20+gmSEQ.pi+100+20000+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+2*mwlength+2*gmSEQ.pi+20+gmSEQ.pi+100];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout 20000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=7; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+mwlength Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+mwlength+gmSEQ.pi+mwlength...
    Start_Sig_D+gmSEQ.readout+AfterLaser Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+mwlength Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.pi/2+mwlength+gmSEQ.pi+mwlength...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-100];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi/2 gmSEQ.pi gmSEQ.pi/2 gmSEQ.pi/2 gmSEQ.pi gmSEQ.pi/2 ...
    gmSEQ.pi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('DEERPulse');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=16;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [5000 5000+10000 5000+20000 5000+30000 5000+40000 5000+50000 5000+60000 5000+70000 ...
gmSEQ.CHN(1).T(2)+20000+5000 gmSEQ.CHN(1).T(2)+20000+5000+10000 gmSEQ.CHN(1).T(2)+20000+5000+20000 gmSEQ.CHN(1).T(1*(2))+20000+5000+30000 ...
    gmSEQ.CHN(1).T(2)+20000+5000+40000 gmSEQ.CHN(1).T(2)+20000+5000+50000 gmSEQ.CHN(1).T(2)+20000+5000+60000 gmSEQ.CHN(1).T(2)+20000+5000+70000];

gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 ...
    gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 20000*2 + 2*(AfterLaser+120+3*gmSEQ.pi) + 4*mwlength-200;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

ApplyDelays();

function DEER_Echo
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

AfterPi = 2000;
AfterLaser = 0.1e6;
PulseGap = 30;
Wait_p = 1e6;
Detect_Window = 5000;
%%%%% Fixed sequence length %%%%%%

gmSEQ.DEERt = ceil(gmSEQ.m/2)*2;
Sig_D_start = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T=[Wait_p+gmSEQ.readout-1000-gmSEQ.CtrGateDur, Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi, ...
    Sig_D_start+gmSEQ.readout-1000-gmSEQ.CtrGateDur, Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')
    gmSEQ.CHN(1).DT=[1000 1000 1000 1000];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [Wait_p, Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi, ...
    Sig_D_start, Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.readout Detect_Window gmSEQ.readout Detect_Window];
%

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser, ...
    Sig_D_start+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[10500 10500];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
if gmSEQ.DEERt/2 < 200
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20, Sig_D_start+gmSEQ.readout+AfterLaser-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+40, ... 
    gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+40];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20, Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2-20,  Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2-20, ...
        Sig_D_start+gmSEQ.readout+AfterLaser-20, Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2-20,  Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+40, gmSEQ.pi+40, gmSEQ.halfpi+40, ... 
    gmSEQ.halfpi+40, gmSEQ.pi+40, gmSEQ.halfpi+PulseGap+gmSEQ.pi+40];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi/2-gmSEQ.DEERpi/2-20, ...
Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi/2-gmSEQ.DEERpi/2-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+40 gmSEQ.DEERpi+40];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[50 50];

% for MW_AWG
if gSG.ACmod % in AC modulation mode
    
    C_1 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        gmSEQ.halfpi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1; ...
        gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
    C_2 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
        gmSEQ.halfpi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1; ...
        gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi+pi/2 gSG.IQVoltage1];
    
    
    D_1 = [C_1;...
          gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    D_2 = [C_2;...
          gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1];
    
else

    C_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.halfpi 0 0 0;...
        gmSEQ.halfpi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    
    
    D_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.halfpi 0 0 0;...
        gmSEQ.halfpi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1; ...
        gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
end

    Length2_2 = round(gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    Length2_3 = round(gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    clkRate2 = 2e9;
 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');
    
ApplyDelays();

function DEER_XY8N
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

if strcmp(gmSEQ.meas,'APD') 
    gmSEQ.CtrGateDur = 1000;
end

Wait_p = 0.5e6;
% 
AfterPi = 2000;
AfterLaser = 0.1e6;
Detect_Window = 5000;
PulseGap = 30;
%SpinLockGap = 2;
%%%%% Fixed sequence length %%%%%%

%gmSEQ.XY8t %
XY8Num = round(gmSEQ.m); % number of single pi pulses

% make it to integer number of 8
% if gmSEQ.m>16
%     XY8Num = ceil(gmSEQ.m/8)*8; % number of single pi pulses
% else
%     XY8Num = round(gmSEQ.m);
% end



XY8Length = XY8Num*(gmSEQ.XY8t+gmSEQ.pi);

% A = [0 gmSEQ.readout 0 pi/2 0.7; ...
%     gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];
% 
% Length1 = gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+1000;
% clkRate1 = 1e9; pause(0.1);
% % used to be 0.05e9
% % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% % 560ns)
% Total1 = ceil(Length1*clkRate1/1e9/16)*16;
% chaseFunctionPool('stopChase',1); pause(0.1);
% chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
% chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
% chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
% pause(1);
% chaseFunctionPool('runChase',1,'false');


gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;


gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];


% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% %gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-1000-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-1000-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
if XY8Num == 0
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20 ...
     gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+gmSEQ.halfpi+40 ...
    gmSEQ.halfpi+gmSEQ.halfpi+PulseGap+gmSEQ.pi+40];
else
if gmSEQ.XY8t <160
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20 ...
     gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+40 ...
    gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+40];
else
    
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2*(XY8Num+2); % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+40];
for zz = 1:XY8Num
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.pi+40];
end
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.halfpi+40];

gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Start_Sig_D+gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.halfpi+40];
for zz = 1:XY8Num
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.pi+40];
end

gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
        Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+XY8Length-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.halfpi+PulseGap+gmSEQ.pi+40];

end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
if XY8Num == 0
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20 ...
     gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[0 0];
else
if gmSEQ.XY8t <160
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2-20 ...
         gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[XY8Length-1*gmSEQ.XY8t-gmSEQ.pi+gmSEQ.DEERpi+40 ...
        XY8Length-1*gmSEQ.XY8t-gmSEQ.pi+gmSEQ.DEERpi+40];
else
    
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2*(XY8Num);
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[];
    for zz = 1:XY8Num
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2-20];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.DEERpi+40];
    end

    for zz = 1:XY8Num
        gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2-20];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT, gmSEQ.DEERpi+40];
    end

end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if XY8Num>0
    Num8Pulse = floor(XY8Num/8);
    
    %%% for P1 X pulse
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
    
    if (mod(XY8Num,8)==1) || (mod(XY8Num,8)==2)
        gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2*(Num8Pulse*4+1); % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    elseif (mod(XY8Num,8)==3) || (mod(XY8Num,8)==4) || (mod(XY8Num,8)==5)
        gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2*(Num8Pulse*4+2);
    elseif (mod(XY8Num,8)==6) || (mod(XY8Num,8)==7)
        gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2*(Num8Pulse*4+3);
    else % (mod(XY8Num,8)==0)
        gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2*(Num8Pulse*4+0);
    end
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = []; 
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [];
    for zz = 1:Num8Pulse
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(8*gmSEQ.XY8t+8*gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(8*gmSEQ.XY8t+8*gmSEQ.pi)+2*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(8*gmSEQ.XY8t+8*gmSEQ.pi)+5*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(8*gmSEQ.XY8t+8*gmSEQ.pi)+7*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
            gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];
    end
    
    if (mod(XY8Num,8)==1) || (mod(XY8Num,8)==2)
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
                gmSEQ.DEERpi];
    elseif (mod(XY8Num,8)==3) || (mod(XY8Num,8)==4) || (mod(XY8Num,8)==5)
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+2*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
                gmSEQ.DEERpi gmSEQ.DEERpi];
    elseif (mod(XY8Num,8)==6) || (mod(XY8Num,8)==7)
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+2*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+5*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
                gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];
    end
    % signal dark start
    for zz = 1:Num8Pulse
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(8*gmSEQ.XY8t+8*gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(8*gmSEQ.XY8t+8*gmSEQ.pi)+2*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(8*gmSEQ.XY8t+8*gmSEQ.pi)+5*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(8*gmSEQ.XY8t+8*gmSEQ.pi)+7*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
            gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];
    end
    
    if (mod(XY8Num,8)==1) || (mod(XY8Num,8)==2)
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
                gmSEQ.DEERpi];
    elseif (mod(XY8Num,8)==3) || (mod(XY8Num,8)==4) || (mod(XY8Num,8)==5)
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+2*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
                gmSEQ.DEERpi gmSEQ.DEERpi];
    elseif (mod(XY8Num,8)==6) || (mod(XY8Num,8)==7)
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+2*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+5*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
                gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];
    end

    
    %%% for P1 Y pulse
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q_2');
    if (mod(XY8Num,8)==0) || (mod(XY8Num,8)==1)
        gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2*(Num8Pulse*4+0);
    elseif (mod(XY8Num,8)==2) || (mod(XY8Num,8)==3)
        gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2*(Num8Pulse*4+1); % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    elseif (mod(XY8Num,8)==4) 
        gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2*(Num8Pulse*4+2);
    elseif (mod(XY8Num,8)==5) || (mod(XY8Num,8)==6)
        gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2*(Num8Pulse*4+3);
    elseif (mod(XY8Num,8)==7)
        gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2*(Num8Pulse*4+4);
    end
    gmSEQ.CHN(numel(gmSEQ.CHN)).T = []; 
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [];
    for zz = 1:Num8Pulse
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(8*gmSEQ.XY8t+8*gmSEQ.pi)+1*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(8*gmSEQ.XY8t+8*gmSEQ.pi)+3*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(8*gmSEQ.XY8t+8*gmSEQ.pi)+4*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(8*gmSEQ.XY8t+8*gmSEQ.pi)+6*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
            gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];
    end
    
    if (mod(XY8Num,8)==2) || (mod(XY8Num,8)==3)
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+1*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
                gmSEQ.DEERpi];
    elseif (mod(XY8Num,8)==4)
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+1*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+3*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
                gmSEQ.DEERpi gmSEQ.DEERpi];
    elseif (mod(XY8Num,8)==5) || (mod(XY8Num,8)==6)
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+1*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+3*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+4*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
                gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];
    elseif (mod(XY8Num,8) == 7)
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+1*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+3*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+4*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+6*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
                gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];
    end
    % signal dark start
    for zz = 1:Num8Pulse
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(8*gmSEQ.XY8t+8*gmSEQ.pi)+1*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(8*gmSEQ.XY8t+8*gmSEQ.pi)+3*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(8*gmSEQ.XY8t+8*gmSEQ.pi)+4*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+(zz-1)*(8*gmSEQ.XY8t+8*gmSEQ.pi)+6*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
            gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];
    end
    
    if (mod(XY8Num,8)==2) || (mod(XY8Num,8)==3)
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+1*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
                gmSEQ.DEERpi];
    elseif (mod(XY8Num,8)==4)
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+1*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+3*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
                gmSEQ.DEERpi gmSEQ.DEERpi];
    elseif (mod(XY8Num,8)==5) || (mod(XY8Num,8)==6)
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+1*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+3*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+4*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
                gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];
    elseif (mod(XY8Num,8) == 7)
        gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(numel(gmSEQ.CHN)).T, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+1*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+3*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+4*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
            Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+Num8Pulse*(8*gmSEQ.XY8t+8*gmSEQ.pi)+6*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
        gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CHN(numel(gmSEQ.CHN)).DT, ...
                gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];
    end
end


%%%%%%%%%%%%%%%%%%%%%%

Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi);


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[540 540];

% for MW_AWG
if gSG.ACmod % in AC modulation mode
    C_1 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    if XY8Num>0
        for zz = 1:XY8Num
            if ( (mod(zz,8) == 1) || (mod(zz,8) == 3) || (mod(zz,8) == 6) || (mod(zz,8) == 0)) % X pulse
                C_1 = [C_1; ...
                    gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
                C_2 = [C_2; ...
                    gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
            else % Y pulse
                C_1 = [C_1; ...
                    gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
                C_2 = [C_2; ...
                    gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1];
            end
        end


        % determine final pi/2 pulse's phase
        if ( (mod(zz,8) == 1) || (mod(zz,8) == 2) || (mod(zz,8) == 6) || (mod(zz,8) == 7) ) % X pulse
            C_1 = [C_1;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
            C_2 = [C_2;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1];
        else % -X pulse
            C_1 = [C_1;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
            C_2 = [C_2;...
                gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi+pi/2 gSG.IQVoltage1];       
        end
    else
        C_1 = [C_1; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
        C_2 = [C_2; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi+pi/2 gSG.IQVoltage1];
    end
    % note this +4 is due to cross-effect of the amplifier
    D_1 = [C_1; ...
            gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap+gmSEQ.pi+4 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    D_2 = [C_2; ...
            gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap+gmSEQ.pi+4 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1];   
    
    
else
    
    C_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.halfpi 0 0 0];
    
    if XY8Num>0
    for zz = 1:XY8Num
        if ( (mod(zz,8) == 1) || (mod(zz,8) == 3) || (mod(zz,8) == 6) || (mod(zz,8) == 0)) % X pulse
            C_1 = [C_1; ...
                gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
            C_2 = [C_2; ...
                gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi 0 0 0];
        else % Y pulse
            C_1 = [C_1; ...
                gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi 0 0 0];
            C_2 = [C_2; ...
                gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2 gmSEQ.halfpi+(zz-1)*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.XY8t/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
        end
    end
    
    % determine final pi/2 pulse's phase
    if ( (mod(zz,8) == 1) || (mod(zz,8) == 2) || (mod(zz,8) == 6) || (mod(zz,8) == 7)) % X pulse
        C_1 = [C_1;...
            gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1];
        C_2 = [C_2;...
            gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi 0 0 0];
    else % -X pulse
        C_1 = [C_1;...
            gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi 0 3/2*pi gSG.IQVoltage1];
        C_2 = [C_2;...
            gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi) gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi 0 0 0];       
    end
    
    else
        C_1 = [C_1; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi 0 3/2*pi gSG.IQVoltage1];
        C_2 = [C_2; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi 0 0 0];
    end
    
    D_1 = [C_1; ...
            gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap+gmSEQ.pi 0 0 0];% note this +4 is due to cross-effect of the amplifier
    D_2 = [C_2; ...
            gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+XY8Num*(gmSEQ.XY8t+gmSEQ.pi)+gmSEQ.halfpi+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];   
end
        
        

    Length2_2 = round(gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    Length2_3 = round(gmSEQ.halfpi+XY8Length+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    clkRate2 = 2e9;

 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


ApplyDelays();

function Ramsey_FlipP1
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

HPSG = visa('agilent', 'GPIB0::19::INSTR');
    fclose(HPSG);
    fopen(HPSG);
    fprintf(HPSG, '%s', 'RF0');
    AA = ['CW ', num2str(gSG.Freq2), 'GZ'];
    fprintf(HPSG, '%s', AA);
    AA = ['PL', num2str(gSG.Pow2), 'dm'];
    fprintf(HPSG, '%s', AA);
    fprintf(HPSG, '%s', 'RF1');
    pause(0.5);
    fclose(HPSG);

AfterPi = 50;
Detect_Pulse = 5e3;
WaitTime = 1e5;

%%%%% Fixed sequence length %%%%%%
Sig_D_start = gmSEQ.readout+1000+gmSEQ.pi+gmSEQ.DEERpi+2*gmSEQ.m+12+gmSEQ.pi+AfterPi+Detect_Pulse+WaitTime;
Ref_start = Sig_D_start + gmSEQ.readout + 1000+gmSEQ.pi+gmSEQ.DEERpi+2*gmSEQ.m+12+gmSEQ.pi+AfterPi+Detect_Pulse+WaitTime;



gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T=[Sig_D_start-(Detect_Pulse+WaitTime) Ref_start-(Detect_Pulse+WaitTime) Ref_start+gmSEQ.readout+2000 Ref_start+gmSEQ.readout+2000+gmSEQ.readout+2000];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')
    gmSEQ.CHN(1).DT=[1000 1000 1000 1000];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+1000 gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.m+gmSEQ.DEERpi+gmSEQ.m ...
    Sig_D_start+gmSEQ.readout+1000 Sig_D_start+gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.m+gmSEQ.DEERpi+gmSEQ.m];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi/2 gmSEQ.pi/2 gmSEQ.pi/2 gmSEQ.pi/2];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Sig_D_start+gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.m+gmSEQ.DEERpi+gmSEQ.m+gmSEQ.pi/2+12];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('DEERPulse');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.m ...
Sig_D_start+gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.m];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Sig_D_start-(Detect_Pulse+WaitTime) Sig_D_start Ref_start-(Detect_Pulse+WaitTime) Ref_start Ref_start+gmSEQ.readout+2000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout Detect_Pulse gmSEQ.readout Detect_Pulse gmSEQ.readout gmSEQ.readout];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+2200+gmSEQ.pi*4+4*gmSEQ.To+2200+2*gmSEQ.readout+2000+gmSEQ.readout+3*WaitTime];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];


ApplyDelays();

function Ramsey_FlipP1_SweepP1Pow
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

HPSG = visa('agilent', 'GPIB0::19::INSTR');
    fclose(HPSG);
    fopen(HPSG);
    fprintf(HPSG, '%s', 'RF0');
    AA = ['CW ', num2str(gSG.Freq2), 'GZ'];
    fprintf(HPSG, '%s', AA);
    AA = ['PL', num2str(gmSEQ.m), 'dm'];
    fprintf(HPSG, '%s', AA);
    fprintf(HPSG, '%s', 'RF1');
    pause(0.5);
    fclose(HPSG);

AfterPi = 50;
Detect_Pulse = 5e3;
WaitTime = 1e5;

%%%%% Fixed sequence length %%%%%%
Sig_D_start = gmSEQ.readout+1000+gmSEQ.pi+gmSEQ.DEERpi+2*gmSEQ.DEERt+12+gmSEQ.pi+AfterPi+Detect_Pulse+WaitTime;
Ref_start = Sig_D_start + gmSEQ.readout + 1000+gmSEQ.pi+gmSEQ.DEERpi+2*gmSEQ.DEERt+12+gmSEQ.pi+AfterPi+Detect_Pulse+WaitTime;

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T=[Sig_D_start-(Detect_Pulse+WaitTime) Ref_start-(Detect_Pulse+WaitTime) Ref_start+gmSEQ.readout+2000 Ref_start+gmSEQ.readout+2000+gmSEQ.readout+2000];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')
    gmSEQ.CHN(1).DT=[1000 1000 1000 1000];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+1000 gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.DEERt+gmSEQ.DEERpi+gmSEQ.DEERt ...
    Sig_D_start+gmSEQ.readout+1000 Sig_D_start+gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.DEERt+gmSEQ.DEERpi+gmSEQ.DEERt];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi/2 gmSEQ.pi/2 gmSEQ.pi/2 gmSEQ.pi/2];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Sig_D_start+gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.DEERt+gmSEQ.DEERpi+gmSEQ.DEERt+gmSEQ.pi/2+12];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('DEERPulse');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.DEERt ...
Sig_D_start+gmSEQ.readout+1000+gmSEQ.pi/2+gmSEQ.DEERt];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Sig_D_start-(Detect_Pulse+WaitTime) Sig_D_start Ref_start-(Detect_Pulse+WaitTime) Ref_start Ref_start+gmSEQ.readout+2000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout Detect_Pulse gmSEQ.readout Detect_Pulse gmSEQ.readout gmSEQ.readout];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.readout+2200+gmSEQ.pi*4+4*gmSEQ.To+2200+2*gmSEQ.readout+2000+gmSEQ.readout+3*WaitTime];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];


ApplyDelays();


function DEER
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

gSG2.Freq = gmSEQ.m*1e9;
SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

AfterPi = 1000;
AfterLaser = 2000;
PulseGap = 30;
Wait_p = 0.03e6;
Detect_Window = 5000;
%%%%% Fixed sequence length %%%%%%

Sig_D_start = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T=[Wait_p+gmSEQ.readout-1000-gmSEQ.CtrGateDur, Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi, ...
    Sig_D_start+gmSEQ.readout-1000-gmSEQ.CtrGateDur, Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')
    gmSEQ.CHN(1).DT=[1000 1000 1000 1000];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [Wait_p, Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi, ...
    Sig_D_start, Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.readout Detect_Window gmSEQ.readout Detect_Window];
%

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser, ...
    Sig_D_start+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
if gmSEQ.DEERt/2 < 200
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20, Sig_D_start+gmSEQ.readout+AfterLaser-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+40, ... 
    gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+40];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20, Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2-20,  Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2-20, ...
        Sig_D_start+gmSEQ.readout+AfterLaser-20, Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2-20,  Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+40, gmSEQ.pi+40, gmSEQ.halfpi+40, ... 
    gmSEQ.halfpi+40, gmSEQ.pi+40, gmSEQ.halfpi+PulseGap+gmSEQ.pi+40];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi/2-gmSEQ.DEERpi/2-20, ...
Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi/2-gmSEQ.DEERpi/2-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+40 gmSEQ.DEERpi+40];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[50 50];

% for MW_AWG
if gSG.ACmod % in AC modulation mode
    
    C_1 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        gmSEQ.halfpi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1; ...
        gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
    C_2 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
        gmSEQ.halfpi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1; ...
        gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi+pi/2 gSG.IQVoltage1];
    
    
    D_1 = [C_1;...
          gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    D_2 = [C_2;...
          gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1];
    
else

    C_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.halfpi 0 0 0;...
        gmSEQ.halfpi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    
    
    D_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.halfpi 0 0 0;...
        gmSEQ.halfpi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1; ...
        gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
end

    Length2_2 = round(gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    Length2_3 = round(gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    clkRate2 = 2e9;

 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


ApplyDelays();

function DEER_Rabi
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

gSG2.Pow = gmSEQ.m;
SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

AfterPi = 2000;
AfterLaser = 2000;
PulseGap = 30;
Wait_p = 0.1e6;
Detect_Window = 5000;
%%%%% Fixed sequence length %%%%%%

Sig_D_start = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T=[Wait_p+gmSEQ.readout-1000-gmSEQ.CtrGateDur, Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi, ...
    Sig_D_start+gmSEQ.readout-1000-gmSEQ.CtrGateDur, Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')
    gmSEQ.CHN(1).DT=[1000 1000 1000 1000];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [Wait_p, Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi, ...
    Sig_D_start, Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.readout Detect_Window gmSEQ.readout Detect_Window];
%

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser, ...
    Sig_D_start+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
if gmSEQ.DEERt/2 < 200
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20, Sig_D_start+gmSEQ.readout+AfterLaser-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+40, ... 
    gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+40];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20, Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2-20,  Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2-20, ...
        Sig_D_start+gmSEQ.readout+AfterLaser-20, Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2-20,  Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+40, gmSEQ.pi+40, gmSEQ.halfpi+40, ... 
    gmSEQ.halfpi+40, gmSEQ.pi+40, gmSEQ.halfpi+PulseGap+gmSEQ.pi+40];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi/2-gmSEQ.DEERpi/2-20, ...
Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi/2-gmSEQ.DEERpi/2-20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+40 gmSEQ.DEERpi+40];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi/2-gmSEQ.DEERpi/2, ...
Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi/2-gmSEQ.DEERpi/2];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+AfterPi+Detect_Window-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[50 50];

% for MW_AWG
if gSG.ACmod % in AC modulation mode
    
    C_1 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        gmSEQ.halfpi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1; ...
        gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
    C_2 = [0 gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 0+pi/2 gSG.IQVoltage1;...
        gmSEQ.halfpi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1; ...
        gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi (gSG.SGbasefreq-gSG.Freq)/1e9 pi+pi/2 gSG.IQVoltage1];
    
    
    D_1 = [C_1;...
          gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    D_2 = [C_2;...
          gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2+pi/2 gSG.IQVoltage1];
    
else

    C_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.halfpi 0 0 0;...
        gmSEQ.halfpi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    
    
    D_1 = [0 gmSEQ.halfpi 0 pi/2 gSG.IQVoltage1;...
           gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi 0 3*pi/2 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.halfpi 0 0 0;...
        gmSEQ.halfpi+gmSEQ.DEERt/2 gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi 0 pi/2 gSG.IQVoltage1; ...
        gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
end

    Length2_2 = round(gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    Length2_3 = round(gmSEQ.halfpi+gmSEQ.DEERt/2+gmSEQ.pi+gmSEQ.DEERt/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000);
    clkRate2 = 2e9;
 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG2_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');
    
ApplyDelays();

function EchoQ
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

%%%% Variable sequence length ctr 2%%%%%%
precess=gmSEQ.m+1100+2*(gmSEQ.pi);
readout1=gmSEQ.readout-(gmSEQ.CtrGateDur+200);
readout2=gmSEQ.CtrGateDur+200;
readoutTot=readout1+readout2+200;

gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=3;
gmSEQ.CHN(1).T=[precess precess+readout1+200 precess+readoutTot+1100+gmSEQ.pi];
gmSEQ.CHN(1).DT=[readout1 readout2 gmSEQ.readout];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=gmSEQ.CHN(1).T;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[1050 1050+(gmSEQ.pi)*3/2+gmSEQ.m precess+readoutTot+1050];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[(gmSEQ.pi)/2 (gmSEQ.pi)/2 gmSEQ.pi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=1050+gmSEQ.pi/2+gmSEQ.m/2;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=gmSEQ.pi;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=0;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=10;
ApplyDelays();

function ESR
global gSG gmSEQ gSG2 %ejd 7/20/23
gSG2.bMod='Dummy';
gSG2.bOn = 0;

gSG.bfixedPow=1;
gSG.bfixedFreq=0;
gSG.bMod='Sweep';
gSG.bModSrc='External';
gSG.sweepRate=10; %% sweep rate Originally 10
gmSEQ.bLiO=1;
gmSEQ.ctrN=1;
% dummy sequence for DrawSequence
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=1;
gmSEQ.CHN(1).T=0;
gmSEQ.CHN(1).DT=1;

gmSEQ.CHN(2).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(2).NRise=1;
gmSEQ.CHN(2).T=0;
gmSEQ.CHN(2).DT=1;

function pbn = PBDictionary(type)
switch type
    case 'ctr0'
        pbn=6;
    case 'MW_AWG'
        pbn=0;
    case 'MWswitch1'
        pbn=1;
    case 'AOM'
        pbn=5;
    case 'I_2' 
        pbn=3;        
    case 'Q_2' 
        pbn=4;
    case 'LaserAWG' %'MWswitch3' 4/20/23 WJ
        pbn=10; %pbn=2 --> pbn=10 4/20/23 WJ
    case 'MWswitch2'
        pbn = 8;
    case 'I_3'
        pbn = 9;
    case 'MW_AWG2' %'MWswitch3' --> 'LaserAWG' 4/20/23 WJ
        pbn = 2; %pbn=10 --> pbn=2 4/20/23 WJ
%     case 'ScopeTrig'
%         pbn = 7;
    case 'dummy' %this is used to maintain a given duty cycle
        pbn=7;
end

function ApplyDelays
global gmSEQ

if strcmp(gmSEQ.meas,'SPCM')
    aom_delay=700; %600; % WJ 4/25/2023 500 --> 700 11/21
    %aom_delay=1200;%+28; % Preston with move of AOM; 
    Detection_delay = 0;
    %AWG_delay = 1150+970; % for 50MHz sampling rate
    AWG_delay = 75+1200; % Laser AWG, for 1GHz sampling rate
    DEER_delay = 0;
    MW_delay = 50; %WJ 4/25/23 50 --> 50 + 10 or 15; %ejd 11/10/2022 removed +1210 %50+1210; % preston 9/27/2022
    %MW_delay = 50; % 50ns delay for the MW AWG @ 2Gs/s sampling rate
elseif strcmp(gmSEQ.meas,'APD')||strcmp(gmSEQ.meas,'Scope')
    aom_delay=1200;
    Detection_delay = -450;
   % AWG_delay = 1150+970;
    AWG_delay = 75+1200;
    DEER_delay = 0;
    MW_delay = 50;
end

% if strcmp(gmSEQ.meas,'APD')
%     ApplyScopeTrig;
% end
    
for i=1:numel(gmSEQ.CHN)
    if gmSEQ.CHN(i).PBN==PBDictionary('AOM')
        gmSEQ.CHN(i).Delays=ones(1,2)*aom_delay;
    elseif gmSEQ.CHN(i).PBN==PBDictionary('ctr0')
        gmSEQ.CHN(i).Delays=ones(1,2)*Detection_delay;
    elseif gmSEQ.CHN(i).PBN==PBDictionary('LaserAWG')
        gmSEQ.CHN(i).Delays=ones(1,2)*AWG_delay;
    elseif gmSEQ.CHN(i).PBN==PBDictionary('I_2')
        gmSEQ.CHN(i).Delays=ones(1,2)*DEER_delay;
    elseif gmSEQ.CHN(i).PBN==PBDictionary('Q_2')
        gmSEQ.CHN(i).Delays=ones(1,2)*DEER_delay;
    elseif gmSEQ.CHN(i).PBN==PBDictionary('MW_AWG')
        gmSEQ.CHN(i).Delays=ones(1,2)*MW_delay;
    elseif gmSEQ.CHN(i).PBN==PBDictionary('MW_AWG2')
        gmSEQ.CHN(i).Delays=ones(1,2)*MW_delay;
    else
        gmSEQ.CHN(i).Delays=zeros(1,2);
    end
    
end


function ApplyScopeTrig
    global gmSEQ
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ScopeTrig');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=0;
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=1000;

function ApplyNoDelays
global gmSEQ
for i=1:numel(gmSEQ.CHN)
    gmSEQ.CHN(i).Delays=zeros(1,max(2,gmSEQ.CHN(i).NRise));
end

function T1
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

%%%%% Fixed sequence length %%%%%%
% gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
% gmSEQ.CHN(1).NRise=1;
% gmSEQ.CHN(1).T=gmSEQ.readout+gmSEQ.m;
% gmSEQ.CHN(1).DT=gmSEQ.CtrGateDur;
% gmSEQ.CHN(2).PBN=PBDictionary('ctr1');
% gmSEQ.CHN(2).NRise=1;
% gmSEQ.CHN(2).T=gmSEQ.readout+gmSEQ.m+gmSEQ.readout-gmSEQ.CtrGateDur;
% gmSEQ.CHN(2).DT=gmSEQ.CtrGateDur;
% gmSEQ.CHN(3).PBN=PBDictionary('AOM');
% gmSEQ.CHN(3).NRise=2;
% gmSEQ.CHN(3).T=[0 gmSEQ.readout+gmSEQ.m];
% gmSEQ.CHN(3).DT=[gmSEQ.readout gmSEQ.readout];
% gmSEQ.CHN(4).PBN=PBDictionary('dummy');
% gmSEQ.CHN(4).NRise=1;
% gmSEQ.CHN(4).T=(gmSEQ.readout)*2+gmSEQ.To-20;
% gmSEQ.CHN(4).DT=20;
% ApplyDelays();

%%%%% Variable sequence length%%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=3;
gmSEQ.CHN(1).T=[gmSEQ.readout+gmSEQ.m gmSEQ.readout+gmSEQ.m+1000+1000+gmSEQ.readout+1000+gmSEQ.pi gmSEQ.readout+gmSEQ.m+1000+1000+gmSEQ.readout+1000+gmSEQ.pi+1000+1000+gmSEQ.readout+1000+gmSEQ.pi + 500];
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
gmSEQ.CHN(2).PBN=PBDictionary('AOM');
% gmSEQ.CHN(2).NRise=6;
% gmSEQ.CHN(2).T=[0 gmSEQ.readout+gmSEQ.m gmSEQ.readout+gmSEQ.m+1000+1000 gmSEQ.readout+gmSEQ.m+1000+1000+gmSEQ.readout+gmSEQ.m gmSEQ.readout+gmSEQ.m+1000+1000+gmSEQ.readout+gmSEQ.m+1000+1000 gmSEQ.readout+gmSEQ.m+1000+1000+gmSEQ.readout+gmSEQ.m+1000+1000+gmSEQ.readout+gmSEQ.m];
% gmSEQ.CHN(2).DT=[gmSEQ.readout 1000 gmSEQ.readout 1000 gmSEQ.readout 1000];
gmSEQ.CHN(2).NRise=6;
gmSEQ.CHN(2).T=[0 gmSEQ.readout+gmSEQ.m gmSEQ.readout+gmSEQ.m+1000+1000 gmSEQ.readout+gmSEQ.m+1000+1000+gmSEQ.readout+1000+gmSEQ.pi gmSEQ.readout+gmSEQ.m+1000+1000+gmSEQ.readout+1000+gmSEQ.pi+1000+1000 gmSEQ.readout+gmSEQ.m+1000+1000+gmSEQ.readout+1000+gmSEQ.pi+1000+1000+gmSEQ.readout+1000+gmSEQ.pi + 500];
gmSEQ.CHN(2).DT=[gmSEQ.readout 1000 gmSEQ.readout 1000 gmSEQ.readout 1000];
gmSEQ.CHN(3).PBN=PBDictionary('I');
gmSEQ.CHN(3).NRise=1;
gmSEQ.CHN(3).T=gmSEQ.readout+gmSEQ.m+1000+1000+gmSEQ.readout+1000+gmSEQ.pi+1000+1000+gmSEQ.readout+1000-50;
gmSEQ.CHN(3).DT=gmSEQ.pi;
ApplyDelays();

function ODMR_P1MWOn
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=0;
gSG.bMod='IQ';
gSG.bModSrc='External';

HPSG = visa('agilent', 'GPIB0::19::INSTR');
    fclose(HPSG);
    fopen(HPSG);
    fprintf(HPSG, '%s', 'RF0');
    AA = ['CW ', num2str(gSG.Freq2), 'GZ'];
    fprintf(HPSG, '%s', AA);
    AA = ['PL', num2str(gSG.Pow2), 'dm'];
    fprintf(HPSG, '%s', AA);
    fprintf(HPSG, '%s', 'RF1');
    pause(0.5);
    fclose(HPSG);
    
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=3;
gmSEQ.CHN(1).T=[gmSEQ.readout+150+gmSEQ.pi gmSEQ.readout+150+gmSEQ.pi+gmSEQ.readout+1000 gmSEQ.readout+150+gmSEQ.pi+gmSEQ.readout+1000+5000+2000];
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
gmSEQ.CHN(2).PBN=PBDictionary('AOM');
gmSEQ.CHN(2).NRise=3;
gmSEQ.CHN(2).T=[0 gmSEQ.readout+150+gmSEQ.pi gmSEQ.readout+150+gmSEQ.pi+gmSEQ.readout+1000];
gmSEQ.CHN(2).DT=[gmSEQ.readout gmSEQ.readout 5000];
gmSEQ.CHN(3).PBN=PBDictionary('I');
gmSEQ.CHN(3).NRise=1;
gmSEQ.CHN(3).T=[gmSEQ.readout+100];
gmSEQ.CHN(3).DT=[gmSEQ.pi];

gmSEQ.CHN(4).PBN=PBDictionary('dummy');
gmSEQ.CHN(4).NRise=2;
gmSEQ.CHN(4).T=[0 100];
gmSEQ.CHN(4).DT=[50 50];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('DEERPulse');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.readout];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[100+gmSEQ.pi+100];

ApplyDelays();

function ODMR
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=0;
gSG.bMod='IQ';
gSG.bModSrc='External';

gSG2.bfixedFreq=1; % if == 1, means No second MW on

AfterLaser = 2000;
AfterPi = 500;

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[gmSEQ.readout-gmSEQ.CtrGateDur-1000 gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(2).PBN=PBDictionary('AOM');
gmSEQ.CHN(2).NRise=2;
gmSEQ.CHN(2).T=[0 gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi];
gmSEQ.CHN(2).DT=[gmSEQ.readout 3000];

gmSEQ.CHN(3).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(3).NRise=1;
gmSEQ.CHN(3).T=[gmSEQ.readout+AfterLaser-50];
gmSEQ.CHN(3).DT=[gmSEQ.pi+100];

gmSEQ.CHN(4).PBN=PBDictionary('dummy');
gmSEQ.CHN(4).NRise=1;
gmSEQ.CHN(4).T=[gmSEQ.readout+AfterLaser];
gmSEQ.CHN(4).DT=[500];

gmSEQ.CHN(5).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(5).NRise=1;
gmSEQ.CHN(5).T=[gmSEQ.readout+AfterLaser];
gmSEQ.CHN(5).DT=[500];

try
    if gSG.first
        disp('UPLLOADING TO AWG,,,,...')
    % for MW_AWG
    % [start, end, Freq, phase, Amp]
        B = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
        C = [0 gmSEQ.pi 0 0 0];

        Length2 = gmSEQ.pi+1000;
        clkRate2 = 2e9;
        % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
        % 560ns)
        Total2 = ceil(Length2*clkRate2/1e9/16)*16;
        chaseFunctionPool('stopChase', 1); pause(0.3); % changed from 2 AWG to 1
        chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
        chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt');
        chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt');
        chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
        chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
        chaseFunctionPool('runChase', 1, 'false'); pause(0.2);  
    end
catch
    disp('oops!')
end

ApplyDelays();

function ODMR_tscan
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=0;
gSG.bMod='IQ';
gSG.bModSrc='External';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq
gSG2.bMod='';

AfterLaser = 100; %in case AOM delay = 500 ns is not enough
AfterPi = 550;
laserT = 40000;
waitT = 50000;
buffer = 50; 

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[laserT+AfterLaser+gmSEQ.pi+AfterPi+200 laserT+AfterLaser+gmSEQ.pi+AfterPi+gmSEQ.readout-gmSEQ.CtrGateDur-700];
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(2).PBN=PBDictionary('AOM');
gmSEQ.CHN(2).NRise=2;
gmSEQ.CHN(2).T=[0 laserT+AfterLaser+gmSEQ.pi+AfterPi];
gmSEQ.CHN(2).DT=[laserT gmSEQ.readout];

gmSEQ.CHN(3).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(3).NRise=1;
gmSEQ.CHN(3).T=[laserT+AfterLaser-buffer];
gmSEQ.CHN(3).DT=[gmSEQ.pi+2*buffer];

gmSEQ.CHN(4).PBN=PBDictionary('dummy');
gmSEQ.CHN(4).NRise=1;
gmSEQ.CHN(4).T=[laserT+AfterLaser+gmSEQ.pi+AfterPi+gmSEQ.readout+waitT];
gmSEQ.CHN(4).DT=[500];

gmSEQ.CHN(5).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(5).NRise=1;
gmSEQ.CHN(5).T=[laserT+AfterLaser];
gmSEQ.CHN(5).DT=[500];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2'); %RF pulse for nuclear spin depolarization 
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= laserT+AfterLaser+gmSEQ.pi+AfterPi+gmSEQ.readout+50; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.DEERpi;

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q_2'); %ctr0 monitoring  
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T= [laserT+AfterLaser+gmSEQ.pi+AfterPi laserT+AfterLaser+gmSEQ.pi+AfterPi+gmSEQ.readout-gmSEQ.CtrGateDur-700];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [gmSEQ.CtrGateDur gmSEQ.CtrGateDur];


try
    if gSG.first
        disp('UPLLOADING TO AWG,,,,...')
    % for MW_AWG
    % [start, end, Freq, phase, Amp]
        B = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
        C = [0 gmSEQ.pi 0 0 0];

        Length2 = gmSEQ.pi+1000;
        clkRate2 = 2e9;
        % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
        % 560ns)
        Total2 = ceil(Length2*clkRate2/1e9/16)*16;
        chaseFunctionPool('stopChase', 1); pause(0.3); % changed from 2 AWG to 1
        chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
        chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt');
        chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt');
        chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
        chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
        chaseFunctionPool('runChase', 1, 'false'); pause(0.2);  
    end
catch
    disp('oops!')
end

ApplyDelays();

function ODMR_tscan_noAWG
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=0;
gSG.bMod='';

gSG2.bOn = 1;
gSG2.bfixedPow=1; % fix microwave power
gSG2.bfixedFreq=1; % fix microwave ferq
gSG2.bMod='';

AfterLaser = 100; %in case AOM delay = 500 ns is not enough
AfterPi = 550;
laserT = 5000;
waitT = 50000;
buffer = 50; 

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[laserT+AfterLaser+gmSEQ.pi+AfterPi+200 laserT+AfterLaser+gmSEQ.pi+AfterPi+gmSEQ.readout-gmSEQ.CtrGateDur-700];
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(2).PBN=PBDictionary('AOM');
gmSEQ.CHN(2).NRise=2;
gmSEQ.CHN(2).T=[0 laserT+AfterLaser+gmSEQ.pi+AfterPi];
gmSEQ.CHN(2).DT=[laserT gmSEQ.readout];

gmSEQ.CHN(3).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(3).NRise=1;
gmSEQ.CHN(3).T=[laserT+AfterLaser];
gmSEQ.CHN(3).DT=[gmSEQ.pi];

gmSEQ.CHN(4).PBN=PBDictionary('dummy');
gmSEQ.CHN(4).NRise=1;
gmSEQ.CHN(4).T=[laserT+AfterLaser+gmSEQ.pi+AfterPi+gmSEQ.readout+waitT];
gmSEQ.CHN(4).DT=[500];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2'); %RF pulse for nuclear spin depolarization 
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T= laserT+AfterLaser+gmSEQ.pi+AfterPi+gmSEQ.readout+50; 
gmSEQ.CHN(numel(gmSEQ.CHN)).DT= gmSEQ.DEERpi;

% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q_2'); %ctr0 monitoring  
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T= [laserT+AfterLaser+gmSEQ.pi+AfterPi laserT+AfterLaser+gmSEQ.pi+AfterPi+gmSEQ.readout-gmSEQ.CtrGateDur-700];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT= [gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

ApplyDelays();

function cool_ODMR_Switch2
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=0;
gSG.bMod='';
gSG.bModSrc='ESR';
gSG2.bfixedFreq=1;

% dummy sequence for DrawSequence
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=1;
gmSEQ.CHN(1).T=0;
gmSEQ.CHN(1).DT=50000;

gmSEQ.CHN(2).PBN=PBDictionary('ctr0');
gmSEQ.CHN(2).NRise=2;
gmSEQ.CHN(2).T=[24 (50000-gmSEQ.CtrGateDur-12)];
gmSEQ.CHN(2).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(3).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(3).NRise=1;
gmSEQ.CHN(3).T=12;
gmSEQ.CHN(3).DT=gmSEQ.CtrGateDur;

ApplyDelays();

function cool_ODMR
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=0;
gSG.bMod='';
gSG.bModSrc='ESR';
gSG2.bfixedFreq=1; %we aren't using SG2
gSG2.bMod=''; %we aren't using SG2

% dummy sequence for DrawSequence
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=1;
gmSEQ.CHN(1).T=0;
gmSEQ.CHN(1).DT=50000;

gmSEQ.CHN(2).PBN=PBDictionary('ctr0');
gmSEQ.CHN(2).NRise=2;
gmSEQ.CHN(2).T=[24 (50000-gmSEQ.CtrGateDur-12)];
gmSEQ.CHN(2).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(3).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(3).NRise=1;
gmSEQ.CHN(3).T=12;
gmSEQ.CHN(3).DT=gmSEQ.CtrGateDur;

ApplyDelays();

function testAWG_ODMR
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=0;
gSG.bMod='IQ';
gSG.bModSrc='External';
gSG2.bfixedFreq=1;

% dummy sequence for DrawSequence
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=1;
gmSEQ.CHN(1).T=0;
gmSEQ.CHN(1).DT=50000;

gmSEQ.CHN(2).PBN=PBDictionary('ctr0');
gmSEQ.CHN(2).NRise=2;
gmSEQ.CHN(2).T=[24 (50000-gmSEQ.CtrGateDur-12)];
gmSEQ.CHN(2).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(3).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(3).NRise=2;
gmSEQ.CHN(3).T=[12 (50000-gmSEQ.CtrGateDur-24)];
gmSEQ.CHN(3).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(4).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(4).NRise=1;
gmSEQ.CHN(4).T=18;
gmSEQ.CHN(4).DT=500;
disp('goofy')
try
    if gSG.first
        disp('UPLOADING TO AWG,,,,...')
    % for MW_AWG
    % [start, end, Freq, phase, Amp]
        B = [0 gmSEQ.CtrGateDur 0 pi/2 gSG.IQVoltage1];
        C = [0 gmSEQ.CtrGateDur 0 0 0];

        Length2 = gmSEQ.CtrGateDur;
        clkRate2 = 2e9;
        % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
        % 560ns)
        Total2 = ceil(Length2*clkRate2/1e9/16)*16;
        chaseFunctionPool('stopChase', 1); pause(0.3); % changed from 2 AWG to 1
        chaseFunctionPool('setClkRate', 1, clkRate2); pause(0.3);
        chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt');
        chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt');
        chaseFunctionPool('CreateSingleSegment',1, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
        chaseFunctionPool('CreateSingleSegment',1, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
        chaseFunctionPool('runChase', 1, 'false'); pause(0.2);
    end
catch
    disp('oops!')
end

ApplyDelays();

function ODMR_DriveN
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=0;
gSG.bMod='IQ';
gSG.bModSrc='External';

gSG2.bfixedFreq=1;  

% Could not set to IQ mode when Freq is low as nuclear driving

% for 2nd MW
% gSG2.bMod='IQ';
% gSG2.bModSrc='External';
%         
% SignalGeneratorFunctionPool2('SetMod');
% pause(0.05);
SignalGeneratorFunctionPool2('WritePow');
pause(0.05);
SignalGeneratorFunctionPool2('WriteFreq');
pause(0.05);
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');
pause(0.05);


AfterLaser = 1000;
AfterPi = 400;
AfterNDrive = 400;

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[gmSEQ.readout-gmSEQ.CtrGateDur gmSEQ.readout+AfterLaser+gmSEQ.DEERpi+AfterNDrive+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(2).PBN=PBDictionary('AOM');
gmSEQ.CHN(2).NRise=2;
gmSEQ.CHN(2).T=[0 gmSEQ.readout+AfterLaser+gmSEQ.DEERpi+AfterNDrive+gmSEQ.pi+AfterPi];
gmSEQ.CHN(2).DT=[gmSEQ.readout 3000];

gmSEQ.CHN(3).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(3).NRise=1;
gmSEQ.CHN(3).T=[gmSEQ.readout+AfterLaser+gmSEQ.DEERpi+AfterNDrive-50];
gmSEQ.CHN(3).DT=[gmSEQ.pi+100];

gmSEQ.CHN(4).PBN=PBDictionary('dummy');
gmSEQ.CHN(4).NRise=1;
gmSEQ.CHN(4).T=[gmSEQ.readout+AfterLaser];
gmSEQ.CHN(4).DT=[500];

gmSEQ.CHN(5).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(5).NRise=1;
gmSEQ.CHN(5).T=[gmSEQ.readout+AfterLaser];
gmSEQ.CHN(5).DT=[gmSEQ.DEERpi];

% gmSEQ.CHN(6).PBN=PBDictionary('I_2');
% gmSEQ.CHN(6).NRise=1;
% gmSEQ.CHN(6).T=[gmSEQ.readout+AfterLaser];
% gmSEQ.CHN(6).DT=[gmSEQ.DEERpi];

gmSEQ.CHN(6).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(6).NRise=1;
gmSEQ.CHN(6).T=[gmSEQ.readout+AfterLaser+gmSEQ.DEERpi+AfterNDrive];
gmSEQ.CHN(6).DT=[500];

% for MW_AWG

    B = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C = [0 gmSEQ.pi 0 0 0];

    Length2 = gmSEQ.pi+1000;
    clkRate2 = 2e9;
    % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
    % 560ns)
    Total2 = ceil(Length2*clkRate2/1e9/16)*16;
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt');
    chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt');
    chaseFunctionPool('CreateSingleSegment',2, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
    chaseFunctionPool('CreateSingleSegment',2, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
    chaseFunctionPool('runChase', 2, 'false'); pause(0.2);

ApplyDelays();


function ODMR_2ndMW
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=0;
gSG.bMod='IQ';
gSG.bModSrc='External';

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

AfterLaser = 2000;
AfterPi = 2000;

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T=[gmSEQ.readout-gmSEQ.CtrGateDur gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(2).PBN=PBDictionary('AOM');
gmSEQ.CHN(2).NRise=2;
gmSEQ.CHN(2).T=[0 gmSEQ.readout+AfterLaser+gmSEQ.pi+AfterPi];
gmSEQ.CHN(2).DT=[gmSEQ.readout 3000];

gmSEQ.CHN(3).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(3).NRise=1;
gmSEQ.CHN(3).T=[gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(3).DT=[gmSEQ.pi+40];

gmSEQ.CHN(4).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(4).NRise=1;
gmSEQ.CHN(4).T=[gmSEQ.readout+AfterLaser-20];
gmSEQ.CHN(4).DT=[gmSEQ.m+40];

gmSEQ.CHN(5).PBN=PBDictionary('I_2');
gmSEQ.CHN(5).NRise=1;
gmSEQ.CHN(5).T=[gmSEQ.readout+AfterLaser];
gmSEQ.CHN(5).DT=[gmSEQ.m];


gmSEQ.CHN(6).PBN=PBDictionary('dummy');
gmSEQ.CHN(6).NRise=1;
gmSEQ.CHN(6).T=[gmSEQ.readout+AfterLaser];
gmSEQ.CHN(6).DT=[500];

gmSEQ.CHN(7).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(7).NRise=1;
gmSEQ.CHN(7).T=[gmSEQ.readout+AfterLaser];
gmSEQ.CHN(7).DT=[500];

% for MW_AWG

    B = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C = [0 gmSEQ.pi 0 0 0];

    Length2 = gmSEQ.pi+1000;
    clkRate2 = 2e9;
    % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
    % 560ns)
    Total2 = ceil(Length2*clkRate2/1e9/16)*16;
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B, clkRate2/10^9, Length2, 'wave_AWG2_ch1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C, clkRate2/10^9, Length2, 'wave_AWG2_ch2.txt'); pause(0.5);
    chaseFunctionPool('CreateSingleSegment',2, 1, Total2, 1, 2047, 2047, 'wave_AWG2_ch1.txt', 1); pause(1);
    chaseFunctionPool('CreateSingleSegment',2, 2, Total2, 1, 2047, 2047, 'wave_AWG2_ch2.txt', 1); pause(1);
    chaseFunctionPool('runChase', 2, 'false'); pause(0.2);

ApplyDelays();

function Pulse_ESR
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=0;
gSG.bMod='IQ';
gSG.bModSrc='External';

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=1;
gmSEQ.CHN(1).T=[8000];
gmSEQ.CHN(1).DT=[1000];
gmSEQ.CHN(2).PBN=PBDictionary('AOM');
gmSEQ.CHN(2).NRise=1;
gmSEQ.CHN(2).T=[0];
gmSEQ.CHN(2).DT=[10000];
gmSEQ.CHN(3).PBN=PBDictionary('I');
gmSEQ.CHN(3).NRise=1;
gmSEQ.CHN(3).T=[0];
gmSEQ.CHN(3).DT=[10000];

gmSEQ.CHN(4).PBN=PBDictionary('dummy');
gmSEQ.CHN(4).NRise=2;
gmSEQ.CHN(4).T=[0 100];
gmSEQ.CHN(4).DT=[50 50];

ApplyDelays();

function CPMGN %not really CPMGN, just testing
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';
% gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
% gmSEQ.CHN(1).NRise=1;
% gmSEQ.CHN(1).T=10000;
% gmSEQ.CHN(1).DT=gmSEQ.CtrGateDur;
% gmSEQ.CHN(2).PBN=PBDictionary('ctr1');
% gmSEQ.CHN(2).NRise=1;
% gmSEQ.CHN(2).T=10000;
% gmSEQ.CHN(2).DT=gmSEQ.CtrGateDur;
% gmSEQ.CHN(3).PBN=PBDictionary('AOM');
% gmSEQ.CHN(3).NRise=1;
% gmSEQ.CHN(3).T=[0];
% gmSEQ.CHN(3).DT=[(gmSEQ.readout)*2];
% gmSEQ.CHN(4).PBN=PBDictionary('ctr2');
% gmSEQ.CHN(4).NRise=1;
% gmSEQ.CHN(4).T=10000;
% gmSEQ.CHN(4).DT=gmSEQ.CtrGateDur;
% ApplyDelays();
gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=3;
gmSEQ.CHN(1).T=[10000 13000 16000];
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
gmSEQ.CHN(2).PBN=PBDictionary('AOM');
gmSEQ.CHN(2).NRise=1;
gmSEQ.CHN(2).T=[0];
gmSEQ.CHN(2).DT=[(gmSEQ.readout)*2];
ApplyDelays();

function ApplyAPDGate()
global gmSEQ
if strcmp(gmSEQ.readout,'APD')
    NCHN=numel(gmSEQ.CHN)+1;
    gmSEQ.CHN(NCHN).PBN=PBDictionary('APDGate');
    CHNctr0=0;
    for i=1:numel(gmSEQ.CHN) %find which CHN is ctr0
        if gmSEQ.CHN(i).PBN==PBDictionary('ctr0')
            CHNctr0=i;
            break
        end
    end
    gmSEQ.CHN(NCHN).T=gmSEQ.CHN(CHNctr0).T;
    gmSEQ.CHN(NCHN).DT=gmSEQ.CHN(CHNctr0).DT;
end

function MeasureCounts
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 1e6; % to let the charge to be stable
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=2;
gmSEQ.CHN(1).T = [0 Wait_p+gmSEQ.readout]; gmSEQ.CHN(1).DT =[gmSEQ.readout gmSEQ.readout];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur];

Max_length = Wait_p+2*gmSEQ.readout+0.1e6;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];

ApplyDelays();

% Apply P1 pi/2 to destroy the P1 polarization information

function T1PolarP1_SpeedupP1Mix_2Counter
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 0.08e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

% AfterPi = 100;
AfterPi = 1000;
AfterLaser = 2000;
Detect_Window = 5000;
% 
% 
% A = [0 gmSEQ.readout 0 pi/2 0.7; ...
%     gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
%     gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];
% 
% Length1 = gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
% clkRate1 = 0.05e9; pause(0.1);
% % delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% % 560ns)
% Total1 = ceil(Length1*clkRate1/1e9/16)*16;
% chaseFunctionPool('stopChase', 1); pause(0.1);
% chaseFunctionPool('setClkRate', 1, clkRate1); pause(0.1);
% chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
% chaseFunctionPool('CreateSingleSegment', 1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
% pause(1);
% chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];

Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];


Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500];



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');

ApplyDelays();

function T1PolarP1_4Counter_LaserPow
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 12000;

LaserVolt = 0.45; LaserDetect = 0.7;

A = [0 gmSEQ.readout 0 pi/2 LaserVolt;...
    gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 LaserDetect];

Length1 = gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase', 1); pause(0.1);
chaseFunctionPool('setClkRate', 1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment', 1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];

Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(2)+10000 gmSEQ.CHN(1).T(4) gmSEQ.CHN(1).T(4)+10000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];


Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500];



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');

ApplyDelays();

function T1Polar_4Counter_FlipOffP1
global gmSEQ gSG gSG3
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

SignalGeneratorFunctionPool3('WritePow');
pause(0.05);
SignalGeneratorFunctionPool3('WriteFreq');
pause(0.05);
gSG3.bOn=1; SignalGeneratorFunctionPool3('RFOnOff');
pause(0.05);

mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;


A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase', 1); pause(0.1);
chaseFunctionPool('setClkRate', 1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment', 1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];

Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];


Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500];

if gmSEQ.m > 201000
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+200000-50 Start_Sig_D+gmSEQ.readout+1000+200000-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+200000 Start_Sig_D+gmSEQ.readout+1000+200000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi];
end

% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');

ApplyDelays();

function T1Polar_2ndMWDrive_FlipOffP1
global gmSEQ gSG gSG3 gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

SignalGeneratorFunctionPool3('WritePow');
pause(0.05);
SignalGeneratorFunctionPool3('WriteFreq');
pause(0.05);
gSG3.bOn=1; SignalGeneratorFunctionPool3('RFOnOff');
pause(0.05);

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

mwlength=gmSEQ.m;
Wait_p = 3e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;

T0 = 50000;


A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.54;...
    gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase', 1); pause(0.1);
chaseFunctionPool('setClkRate', 1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment', 1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];

Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];


Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500];


if gmSEQ.m <= T0
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+AfterLaser-50 Start_Sig_D+gmSEQ.readout+1000+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m gmSEQ.m];

    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+AfterLaser Start_Sig_D+gmSEQ.readout+1000+AfterLaser];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m-100 gmSEQ.m-100];

elseif gmSEQ.m <= T0+50+gmSEQ.DEERpi+50
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+AfterLaser-50 Start_Sig_D+gmSEQ.readout+1000+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[T0 T0];

    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+AfterLaser Start_Sig_D+gmSEQ.readout+1000+AfterLaser];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[T0-100 T0-100];

elseif gmSEQ.m > T0+50+gmSEQ.DEERpi+50
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+AfterLaser-50 Wait_p+gmSEQ.readout+1000+AfterLaser+T0+50+gmSEQ.DEERpi ...
        Start_Sig_D+gmSEQ.readout+1000+AfterLaser-50 Start_Sig_D+gmSEQ.readout+1000+AfterLaser+T0+50+gmSEQ.DEERpi];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[T0+100 gmSEQ.m-T0-50-gmSEQ.DEERpi-50-100+100 T0+100 gmSEQ.m-T0-50-gmSEQ.DEERpi-50-100+100];

    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+AfterLaser Wait_p+gmSEQ.readout+1000+AfterLaser+T0+50+gmSEQ.DEERpi+50 ...
        Start_Sig_D+gmSEQ.readout+1000+AfterLaser Start_Sig_D+gmSEQ.readout+1000+AfterLaser+T0+50+gmSEQ.DEERpi+50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[T0 gmSEQ.m-T0-50-gmSEQ.DEERpi-50-100 T0 gmSEQ.m-T0-50-gmSEQ.DEERpi-50-100];

    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+AfterLaser+T0 ...
        Start_Sig_D+gmSEQ.readout+1000+AfterLaser+T0];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+AfterLaser+T0+50 ...
        Start_Sig_D+gmSEQ.readout+1000+AfterLaser+T0+50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi];

end



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');

ApplyDelays();

function T1Polar_2ndMWDriveLaser_FlipOffP1
global gmSEQ gSG gSG3 gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

SignalGeneratorFunctionPool3('WritePow');
pause(0.05);
SignalGeneratorFunctionPool3('WriteFreq');
pause(0.05);
gSG3.bOn=1; SignalGeneratorFunctionPool3('RFOnOff');
pause(0.05);

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

mwlength=gmSEQ.m;
Wait_p = 5e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;

A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.54;...
    gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase', 1); pause(0.1);
chaseFunctionPool('setClkRate', 1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment', 1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];

Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];


Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500];

if gmSEQ.m<=100+gmSEQ.DEERpi+70+100
% Drive During Laser
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p-50 Start_Sig_D-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout+1000+AfterLaser+100 gmSEQ.readout+1000+AfterLaser+100];

    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout+1000+AfterLaser gmSEQ.readout+1000+AfterLaser];
    
elseif gmSEQ.m>100+gmSEQ.DEERpi+70+100
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p-50 Wait_p+gmSEQ.readout+1000+AfterLaser+(100+gmSEQ.DEERpi+70)-50 ...
        Start_Sig_D-50 Start_Sig_D+gmSEQ.readout+1000+AfterLaser+(100+gmSEQ.DEERpi+70)-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout+1000+AfterLaser+100 gmSEQ.m-(100+gmSEQ.DEERpi+70+100)+100 ...
        gmSEQ.readout+1000+AfterLaser+100 gmSEQ.m-(100+gmSEQ.DEERpi+70+100)+100];

    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+(100+gmSEQ.DEERpi+70) ...
        Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+(100+gmSEQ.DEERpi+70)];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout+1000+AfterLaser gmSEQ.m-(100+gmSEQ.DEERpi+70+100) ...
        gmSEQ.readout+1000+AfterLaser gmSEQ.m-(100+gmSEQ.DEERpi+70+100)];
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+AfterLaser+100-50 ...
        Start_Sig_D+gmSEQ.readout+1000+AfterLaser+100-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+AfterLaser+100 ...
        Start_Sig_D+gmSEQ.readout+1000+AfterLaser+100];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi];

end



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');

ApplyDelays();

function T1PolarP1_SpeedupP1Mix_2Counter_Plus1
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;


A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+mwlength+gmSEQ.DEERpi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+mwlength+gmSEQ.DEERpi+AfterPi+Detect_Window 0 pi/2 0.7];

Length = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+mwlength+gmSEQ.DEERpi+AfterPi+Detect_Window+1000;
clkRate = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total = ceil(Length*clkRate/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate/10^9, Length, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase', 1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+mwlength+gmSEQ.DEERpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];

Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+mwlength+gmSEQ.DEERpi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+mwlength+gmSEQ.DEERpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=16; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 5000+10000 5000+20000 5000+30000 5000+40000 5000+50000 5000+60000 5000+70000 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000 gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+30000 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+40000 gmSEQ.CHN(1).T(2)+Detect_Window+5000+50000 gmSEQ.CHN(1).T(2)+Detect_Window+5000+60000 gmSEQ.CHN(1).T(2)+Detect_Window+5000+70000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 ...
    gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(4)-gmSEQ.DEERpi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+2*gmSEQ.DEERpi) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+10000-50 5000+20000-50 5000+30000-50 5000+40000-50 5000+50000-50 5000+60000-50 5000+70000-50 ...
    gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+30000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+40000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+50000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+60000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+70000-50 ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(4)-gmSEQ.DEERpi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
  gmSEQ.DEERpi+100 ...  
gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];

ApplyDelays();

function T1PolarP1_SpeedupP1Mix_2Counter_Minus1
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;


A = [0 gmSEQ.readout 0 pi/2 0.7; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.pi+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.pi+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length = gmSEQ.readout+1000+AfterLaser+gmSEQ.pi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total = ceil(Length*clkRate/1e9/16)*16;
chaseFunctionPool('stopChase', 1); pause(0.1);
chaseFunctionPool('setClkRate', 1, clkRate); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate/10^9, Length, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.pi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];

Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.pi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.pi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 5000+10000 5000+20000 5000+30000 5000+40000 5000+50000 5000+60000 5000+70000 gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000 gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+30000 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+40000 gmSEQ.CHN(1).T(2)+Detect_Window+5000+50000 gmSEQ.CHN(1).T(2)+Detect_Window+5000+60000 gmSEQ.CHN(1).T(2)+Detect_Window+5000+70000 ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 ...
    gmSEQ.pi ...
    gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 ...
    gmSEQ.pi gmSEQ.pi];


% gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi gmSEQ.pi gmSEQ.pi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+2*gmSEQ.pi) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=gmSEQ.CHN(4).T-50;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=gmSEQ.CHN(4).DT+100;

ApplyDelays();

function T1PolarP1_RotP1_2Counter_Shelve
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% gmSEQ.Diffwait

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 50;

A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.P1Pulse+PulseGap+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.P1Pulse+PulseGap+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.P1Pulse+PulseGap+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.P1Pulse+PulseGap+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.P1Pulse+PulseGap+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.P1Pulse+PulseGap+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse+100 ...
    gmSEQ.pi+100];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.P1Pulse+PulseGap ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.P1Pulse+PulseGap];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.P1Pulse+PulseGap+2*gmSEQ.DEERpi+gmSEQ.pi+PulseGap) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

if gmSEQ.P1Pulse<40
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+PulseGap+gmSEQ.P1Pulse+PulseGap+gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+PulseGap+gmSEQ.P1Pulse+PulseGap+gmSEQ.DEERpi+100];

    else
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.P1Pulse+PulseGap-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.P1Pulse+PulseGap-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];   
end

if gmSEQ.m>1000
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=5; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000 Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap ...
    Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.P1Pulse+PulseGap+gmSEQ.DEERpi+gmSEQ.m];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500 500 500];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap ...
        gmSEQ.CHN(1).T(2)+Detect_Window+5000 Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500 500];
end


% for MW_AWG

if (gmSEQ.m > 3000)
        D_1 = [0 gmSEQ.P1Pulse 0 pi/2 gSG.IQVoltage1];
        D_2 = [0 gmSEQ.P1Pulse 0 0 0];

        B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
            5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
            10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
            15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
            20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
            25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
            30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
            35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
        B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];

        C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
        C_2 = [0 gmSEQ.pi 0 0 0];
    
    Length2_0 = round(gmSEQ.P1Pulse+1000);
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;
    
    Total2_0 = ceil(Length2_0*clkRate2/1e9/16)*16;
    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_0, 'wave_AWG2_ch1_seg0.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_0, 'wave_AWG2_ch2_seg0.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 5, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 5, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');
    
    else
        B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
            5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
            10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
            15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
            20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
            25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
            30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
            35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
        B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
        
        C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
        C_2 = [0 gmSEQ.pi 0 0 0];
        
        D_1 = [0 gmSEQ.P1Pulse 0 pi/2 gSG.IQVoltage1;...
               gmSEQ.P1Pulse+PulseGap+gmSEQ.DEERpi+gmSEQ.m gmSEQ.P1Pulse+PulseGap+gmSEQ.DEERpi+gmSEQ.m+gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
        D_2 = [0 gmSEQ.pi 0 0 0];
        
        
        
        Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
        Length2_2 = round(gmSEQ.pi+1000);
        Length2_3 = round(gmSEQ.P1Pulse+PulseGap+gmSEQ.DEERpi+gmSEQ.m+gmSEQ.pi+1000);
        
        clkRate2 = 2e9;

        Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
        Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
        Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
        
        chaseFunctionPool('stopChase', 2); pause(0.3);
        chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
        chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
        chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
        chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
        chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
        chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_3, 'wave_AWG2_ch1_seg3.txt'); pause(0.5);
        chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_3, 'wave_AWG2_ch2_seg3.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1, 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1, 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 4, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 4, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');
end

    
ApplyDelays();

function T1PolarP1_2Counter_Shelve
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;


A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+30+gmSEQ.P1Pulse+30+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+30+gmSEQ.P1Pulse+30+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+30+gmSEQ.P1Pulse+30+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total = ceil(Length*clkRate/1e9/16)*16;
chaseFunctionPool('stopChase', 1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate/10^9, Length, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+30+gmSEQ.P1Pulse+30+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];

Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+30+gmSEQ.P1Pulse+30+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+30+gmSEQ.P1Pulse+30+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 5000+10000 5000+20000 5000+30000 5000+40000 5000+50000 5000+60000 5000+70000 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000 gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+30000 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+40000 gmSEQ.CHN(1).T(2)+Detect_Window+5000+50000 gmSEQ.CHN(1).T(2)+Detect_Window+5000+60000 gmSEQ.CHN(1).T(2)+Detect_Window+5000+70000 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 ...
    gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 ...
    gmSEQ.pi];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+30+gmSEQ.P1Pulse+30 ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+30+gmSEQ.P1Pulse+30];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+2*gmSEQ.DEERpi+gmSEQ.pi+gmSEQ.P1Pulse+30+30) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

if mwlength>120
    
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+10000-50 5000+20000-50 5000+30000-50 5000+40000-50 5000+50000-50 5000+60000-50 5000+70000-50 ...
    gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+30000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+40000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+50000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+60000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+70000-50 ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
  gmSEQ.DEERpi+30+gmSEQ.P1Pulse+30+gmSEQ.DEERpi+100 ...  
gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
gmSEQ.DEERpi+30+gmSEQ.P1Pulse+30+gmSEQ.DEERpi+100 gmSEQ.pi+100];

else
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=18; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+10000-50 5000+20000-50 5000+30000-50 5000+40000-50 5000+50000-50 5000+60000-50 5000+70000-50 ...
    gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+30000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+40000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+50000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+60000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+70000-50 ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
  gmSEQ.DEERpi+30+gmSEQ.P1Pulse+30+gmSEQ.DEERpi+100 ...  
gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
gmSEQ.DEERpi+30+gmSEQ.P1Pulse+30+gmSEQ.DEERpi+mwlength+gmSEQ.pi+100];
    
end

ApplyDelays();

function SpinDiffuse_2Counter_Shelve
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% gmSEQ.Diffwait

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 30;

A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.Diffwait+2*gmSEQ.DEERpi+gmSEQ.pi+PulseGap) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

if gmSEQ.Diffwait<100
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100];

    else
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500];



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


    
ApplyDelays();

function SpinDiffuse_2Counter_Shelve_Ramsey
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% gmSEQ.Diffwait

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

T1_0 = 30000; % fixing, for T1 measurement
T0 = 3000; % t_R + t = T0
gmSEQ.Diffwait = T0;

% mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 50;


A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

% 
if (gmSEQ.m < 120)
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-gmSEQ.m-gmSEQ.P1Pulse/2-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-gmSEQ.m-gmSEQ.P1Pulse/2-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+gmSEQ.m+gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+gmSEQ.m+gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=21; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-gmSEQ.m-gmSEQ.P1Pulse/2-50 ...
    Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-gmSEQ.m-gmSEQ.P1Pulse/2-50 ...
    Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];
end
% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.Diffwait+2*gmSEQ.DEERpi+gmSEQ.pi+PulseGap) + 2*T1_0;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

if gmSEQ.Diffwait<100
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100];

    else
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];   
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=5; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-gmSEQ.m-gmSEQ.P1Pulse/2 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000 Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-gmSEQ.m-gmSEQ.P1Pulse/2 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500 500 500];



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    D_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m gmSEQ.P1Pulse/2+gmSEQ.m+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
    D_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m gmSEQ.P1Pulse/2+gmSEQ.m+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 3*pi/2 gSG.IQVoltage1];
    
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    D_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m gmSEQ.P1Pulse/2+gmSEQ.m+gmSEQ.P1Pulse/2 0 3*pi/2 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_0 = round(gmSEQ.P1Pulse/2+gmSEQ.m+gmSEQ.P1Pulse/2+1000);
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_0 = ceil(Length2_0*clkRate2/1e9/16)*16;
    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_0, 'wave_AWG2_ch1_seg0.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_0, 'wave_AWG2_ch2_seg0.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 5, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 5, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


    
ApplyDelays();

function SpinDiffuse_2Counter_Shelve_Echo
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% gmSEQ.Diffwait

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

T1_0 = 30000; % fixing, for T1 measurement
T0 = 3000; % t_R + t = T0
gmSEQ.Diffwait = T0;

% mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 50;


A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

% 
if (gmSEQ.m < 300)
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-gmSEQ.m/2-gmSEQ.P1Pulse-gmSEQ.m/2-gmSEQ.P1Pulse/2-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-gmSEQ.m/2-gmSEQ.P1Pulse-gmSEQ.m/2-gmSEQ.P1Pulse/2-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+gmSEQ.m+gmSEQ.P1Pulse/2+gmSEQ.P1Pulse+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+gmSEQ.m+gmSEQ.P1Pulse/2+gmSEQ.P1Pulse+100 ...
    gmSEQ.pi+100];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=23; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-gmSEQ.m/2-gmSEQ.P1Pulse-gmSEQ.m/2-gmSEQ.P1Pulse/2-50 ...
    Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-gmSEQ.m/2-gmSEQ.P1Pulse-50 ...
    Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-gmSEQ.m/2-gmSEQ.P1Pulse-gmSEQ.m/2-gmSEQ.P1Pulse/2-50 ...
    Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-gmSEQ.m/2-gmSEQ.P1Pulse-50 ...
    Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];
end
% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.Diffwait+2*gmSEQ.DEERpi+gmSEQ.pi+PulseGap) + 2*T1_0;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

if gmSEQ.Diffwait<100
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100];

    else
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];   
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=5; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-gmSEQ.m-gmSEQ.P1Pulse/2-gmSEQ.P1Pulse ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000 Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse/2-gmSEQ.m-gmSEQ.P1Pulse/2-gmSEQ.P1Pulse gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500 500 500];



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    D_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1; ...
        gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
    D_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1; ...
        gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 3*pi/2 gSG.IQVoltage1];

    
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    D_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2+gmSEQ.P1Pulse/2 0 3*pi/2 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.P1Pulse/2 0 0 0;...
        gmSEQ.P1Pulse/2+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse 0 pi/2 gSG.IQVoltage1];
    
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_0 = round(gmSEQ.P1Pulse/2+gmSEQ.m+gmSEQ.P1Pulse/2+gmSEQ.P1Pulse+1000);
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_0 = ceil(Length2_0*clkRate2/1e9/16)*16;
    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_0, 'wave_AWG2_ch1_seg0.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_0, 'wave_AWG2_ch2_seg0.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 5, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 5, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


    
ApplyDelays();

function SpinDiffuse_2Counter_Shelve_FM
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% gmSEQ.Diffwait

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

T1_0 = 10000; % fixing, for T1 measurement
T0 = 5000; % t_R + t = T0
gmSEQ.Diffwait = T0;
PulseSpace = 2; % spacing between pi/2 pulse

% mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 100;


A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

% 

    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse*13-gmSEQ.m*12-PulseSpace*13-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse*13-gmSEQ.m*12-PulseSpace*13-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse*13+gmSEQ.m*12+PulseSpace*13+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse*13+gmSEQ.m*12+PulseSpace*13+100 ...
    gmSEQ.pi+100];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.Diffwait+2*gmSEQ.DEERpi+gmSEQ.pi+PulseGap) + 2*T1_0;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

if gmSEQ.Diffwait<100
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100];

    else
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];   
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=5; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse*13-gmSEQ.m*12-PulseSpace*13 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000 Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse*13-gmSEQ.m*12-PulseSpace*13 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500 500 500];



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    D_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1; ...
        gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
    D_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1; ...
        gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 3*pi/2 gSG.IQVoltage1];

    
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    % All waveform needs to start with 0ns !!!
    % gmSEQ.m is single tau, total sequence has 12*tau
    D_1 = [0 gmSEQ.P1Pulse 0 0 0; ...
        2*gmSEQ.P1Pulse+2*gmSEQ.m+PulseSpace*2 2.5*gmSEQ.P1Pulse+2*gmSEQ.m+PulseSpace*2 0 pi/2 gSG.IQVoltage1;...
        4*gmSEQ.P1Pulse+4*gmSEQ.m+PulseSpace*4 4.5*gmSEQ.P1Pulse+4*gmSEQ.m+PulseSpace*4 0 pi/2 gSG.IQVoltage1;...
        6*gmSEQ.P1Pulse+6*gmSEQ.m+PulseSpace*6 6.5*gmSEQ.P1Pulse+6*gmSEQ.m+PulseSpace*6 0 pi/2 gSG.IQVoltage1;...
        8*gmSEQ.P1Pulse+8*gmSEQ.m+PulseSpace*8 8.5*gmSEQ.P1Pulse+8*gmSEQ.m+PulseSpace*8 0 pi/2 gSG.IQVoltage1;...
        10*gmSEQ.P1Pulse+10*gmSEQ.m+PulseSpace*10 10.5*gmSEQ.P1Pulse+10*gmSEQ.m+PulseSpace*10 0 3*pi/2 gSG.IQVoltage1;...
        12*gmSEQ.P1Pulse+12*gmSEQ.m+PulseSpace*12 12.5*gmSEQ.P1Pulse+12*gmSEQ.m+PulseSpace*12 0 pi/2 gSG.IQVoltage1];
    
    D_2 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m gmSEQ.P1Pulse+gmSEQ.m 0 3*pi/2 gSG.IQVoltage1;...
        gmSEQ.P1Pulse+gmSEQ.m+PulseSpace gmSEQ.P1Pulse+gmSEQ.m+PulseSpace+gmSEQ.P1Pulse/2 0 3*pi/2 gSG.IQVoltage1; ...
        3*gmSEQ.P1Pulse/2+2*gmSEQ.m+PulseSpace  2*gmSEQ.P1Pulse+2*gmSEQ.m+PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        2.5*gmSEQ.P1Pulse+3*gmSEQ.m+PulseSpace*2 3*gmSEQ.P1Pulse+3*gmSEQ.m+PulseSpace*2 0 3*pi/2 gSG.IQVoltage1;...
        3*gmSEQ.P1Pulse+3*gmSEQ.m+PulseSpace*3 3.5*gmSEQ.P1Pulse+3*gmSEQ.m+PulseSpace*3 0 3*pi/2 gSG.IQVoltage1;...
        3.5*gmSEQ.P1Pulse+4*gmSEQ.m+PulseSpace*3 4*gmSEQ.P1Pulse+4*gmSEQ.m+PulseSpace*3 0 3*pi/2 gSG.IQVoltage1; ...
        4.5*gmSEQ.P1Pulse+5*gmSEQ.m+PulseSpace*4 5*gmSEQ.P1Pulse+5*gmSEQ.m+PulseSpace*4 0 3*pi/2 gSG.IQVoltage1; ...
        5*gmSEQ.P1Pulse+5*gmSEQ.m+PulseSpace*5 5.5*gmSEQ.P1Pulse+5*gmSEQ.m+PulseSpace*5 0 3*pi/2 gSG.IQVoltage1; ...
        5.5*gmSEQ.P1Pulse+6*gmSEQ.m+PulseSpace*5 6*gmSEQ.P1Pulse+6*gmSEQ.m+PulseSpace*5 0 3*pi/2 gSG.IQVoltage1; ...
        6.5*gmSEQ.P1Pulse+7*gmSEQ.m+PulseSpace*6 7*gmSEQ.P1Pulse+7*gmSEQ.m+PulseSpace*6 0 pi/2 gSG.IQVoltage1; ...
        7*gmSEQ.P1Pulse+7*gmSEQ.m+PulseSpace*7 7.5*gmSEQ.P1Pulse+7*gmSEQ.m+PulseSpace*7 0 pi/2 gSG.IQVoltage1; ...
        7.5*gmSEQ.P1Pulse+8*gmSEQ.m+PulseSpace*7 8*gmSEQ.P1Pulse+8*gmSEQ.m+PulseSpace*7 0 pi/2 gSG.IQVoltage1; ...
        8.5*gmSEQ.P1Pulse+9*gmSEQ.m+PulseSpace*8 9*gmSEQ.P1Pulse+9*gmSEQ.m+PulseSpace*8 0 3*pi/2 gSG.IQVoltage1; ...
        9*gmSEQ.P1Pulse+9*gmSEQ.m+PulseSpace*9 9.5*gmSEQ.P1Pulse+9*gmSEQ.m+PulseSpace*9 0 3*pi/2 gSG.IQVoltage1; ...
        9.5*gmSEQ.P1Pulse+10*gmSEQ.m+PulseSpace*9 10*gmSEQ.P1Pulse+10*gmSEQ.m+PulseSpace*9 0 3*pi/2 gSG.IQVoltage1; ...
        10.5*gmSEQ.P1Pulse+11*gmSEQ.m+PulseSpace*10 11*gmSEQ.P1Pulse+11*gmSEQ.m+PulseSpace*10 0 pi/2 gSG.IQVoltage1; ...
        11*gmSEQ.P1Pulse+11*gmSEQ.m+PulseSpace*11 11.5*gmSEQ.P1Pulse+11*gmSEQ.m+PulseSpace*11 0 pi/2 gSG.IQVoltage1; ...
        11.5*gmSEQ.P1Pulse+12*gmSEQ.m+PulseSpace*11 12*gmSEQ.P1Pulse+12*gmSEQ.m+PulseSpace*11 0 pi/2 gSG.IQVoltage1; ...
        12.5*gmSEQ.P1Pulse+12*gmSEQ.m+PulseSpace*13 13*gmSEQ.P1Pulse+12*gmSEQ.m+PulseSpace*13 0 pi/2 gSG.IQVoltage1];

    
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_0 = round(gmSEQ.P1Pulse*13+gmSEQ.m*12+PulseSpace*13+1000);
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_0 = ceil(Length2_0*clkRate2/1e9/16)*16;
    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_0, 'wave_AWG2_ch1_seg0.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_0, 'wave_AWG2_ch2_seg0.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 5, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 5, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


    
ApplyDelays();


function SpinDiffuse_2Counter_Shelve_FM_SwpN
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% gmSEQ.Diffwait

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

T1_0 = 10000; % fixing, for T1 measurement
T0 = 15000; % t_R + t = T0
gmSEQ.Diffwait = T0;
PulseSpace = 2; % spacing between pi/2 pulse
tau = 10;
PulseN = gmSEQ.m;

if (PulseN*(gmSEQ.P1Pulse*12+tau*12+PulseSpace*12)>0.9*T0)
    warning('Sequence length exceeds diffusion wait');
    PulseN = 0;
end


Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 100;


A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

% 

    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse-PulseSpace-(gmSEQ.P1Pulse*12+tau*12+PulseSpace*12)*PulseN-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse-PulseSpace-(gmSEQ.P1Pulse*12+tau*12+PulseSpace*12)*PulseN-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse+PulseSpace+(gmSEQ.P1Pulse*12+tau*12+PulseSpace*12)*PulseN+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse+PulseSpace+(gmSEQ.P1Pulse*12+tau*12+PulseSpace*12)*PulseN+100 ...
    gmSEQ.pi+100];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.Diffwait+2*gmSEQ.DEERpi+gmSEQ.pi+PulseGap) + 2*T1_0;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

if gmSEQ.Diffwait<100
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100];

    else
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];   
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=5; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse-PulseSpace-(gmSEQ.P1Pulse*12+tau*12+PulseSpace*12)*PulseN ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000 Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse-PulseSpace-(gmSEQ.P1Pulse*12+tau*12+PulseSpace*12)*PulseN gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500 500 500];



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    D_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1; ...
        gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
    D_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1; ...
        gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 3*pi/2 gSG.IQVoltage1];

    
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    % All waveform needs to start with 0ns !!!
    % gmSEQ.m is single tau, total sequence has 12*tau
    
    D_1 = [0 gmSEQ.P1Pulse/2 0 0 0];
    D_2 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];

    if (PulseN == 0)
       Timing = 0.5*gmSEQ.P1Pulse+PulseSpace;
    end
for kkk = 1:PulseN
    Timing = 0.5*gmSEQ.P1Pulse+(kkk-1)*(12*tau+12*gmSEQ.P1Pulse+12*PulseSpace);
    D_1 = [D_1; ...
        Timing+1.5*gmSEQ.P1Pulse+2*tau+PulseSpace*2 Timing+2*gmSEQ.P1Pulse+2*tau+PulseSpace*2 0 pi/2 gSG.IQVoltage1;...
        Timing+3.5*gmSEQ.P1Pulse+4*tau+PulseSpace*4 Timing+4*gmSEQ.P1Pulse+4*tau+PulseSpace*4 0 pi/2 gSG.IQVoltage1;...
        Timing+5.5*gmSEQ.P1Pulse+6*tau+PulseSpace*6 Timing+6*gmSEQ.P1Pulse+6*tau+PulseSpace*6 0 pi/2 gSG.IQVoltage1;...
        Timing+7.5*gmSEQ.P1Pulse+8*tau+PulseSpace*8 Timing+8*gmSEQ.P1Pulse+8*tau+PulseSpace*8 0 pi/2 gSG.IQVoltage1;...
        Timing+9.5*gmSEQ.P1Pulse+10*tau+PulseSpace*10 Timing+10*gmSEQ.P1Pulse+10*tau+PulseSpace*10 0 3*pi/2 gSG.IQVoltage1;...
        Timing+11.5*gmSEQ.P1Pulse+12*tau+PulseSpace*12 Timing+12*gmSEQ.P1Pulse+12*tau+PulseSpace*12 0 pi/2 gSG.IQVoltage1];
    
    D_2 = [D_2; ...
        Timing+tau Timing+0.5*gmSEQ.P1Pulse+tau 0 3*pi/2 gSG.IQVoltage1;...
        Timing+0.5*gmSEQ.P1Pulse+tau+PulseSpace Timing+1*gmSEQ.P1Pulse+tau+PulseSpace 0 3*pi/2 gSG.IQVoltage1; ...
        Timing+1*gmSEQ.P1Pulse+2*tau+PulseSpace  Timing+1.5*gmSEQ.P1Pulse+2*tau+PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+2*gmSEQ.P1Pulse+3*tau+PulseSpace*2 Timing+2.5*gmSEQ.P1Pulse+3*tau+PulseSpace*2 0 3*pi/2 gSG.IQVoltage1;...
        Timing+2.5*gmSEQ.P1Pulse+3*tau+PulseSpace*3 Timing+3*gmSEQ.P1Pulse+3*tau+PulseSpace*3 0 3*pi/2 gSG.IQVoltage1;...
        Timing+3*gmSEQ.P1Pulse+4*tau+PulseSpace*3 Timing+3.5*gmSEQ.P1Pulse+4*tau+PulseSpace*3 0 3*pi/2 gSG.IQVoltage1; ...
        Timing+4*gmSEQ.P1Pulse+5*tau+PulseSpace*4 Timing+4.5*gmSEQ.P1Pulse+5*tau+PulseSpace*4 0 3*pi/2 gSG.IQVoltage1; ...
        Timing+4.5*gmSEQ.P1Pulse+5*tau+PulseSpace*5 Timing+5*gmSEQ.P1Pulse+5*tau+PulseSpace*5 0 3*pi/2 gSG.IQVoltage1; ...
        Timing+5*gmSEQ.P1Pulse+6*tau+PulseSpace*5 Timing+5.5*gmSEQ.P1Pulse+6*tau+PulseSpace*5 0 3*pi/2 gSG.IQVoltage1; ...
        Timing+6*gmSEQ.P1Pulse+7*tau+PulseSpace*6 Timing+6.5*gmSEQ.P1Pulse+7*tau+PulseSpace*6 0 pi/2 gSG.IQVoltage1; ...
        Timing+6.5*gmSEQ.P1Pulse+7*tau+PulseSpace*7 Timing+7*gmSEQ.P1Pulse+7*tau+PulseSpace*7 0 pi/2 gSG.IQVoltage1; ...
        Timing+7*gmSEQ.P1Pulse+8*tau+PulseSpace*7 Timing+7.5*gmSEQ.P1Pulse+8*tau+PulseSpace*7 0 pi/2 gSG.IQVoltage1; ...
        Timing+8*gmSEQ.P1Pulse+9*tau+PulseSpace*8 Timing+8.5*gmSEQ.P1Pulse+9*tau+PulseSpace*8 0 3*pi/2 gSG.IQVoltage1; ...
        Timing+8.5*gmSEQ.P1Pulse+9*tau+PulseSpace*9 Timing+9*gmSEQ.P1Pulse+9*tau+PulseSpace*9 0 3*pi/2 gSG.IQVoltage1; ...
        Timing+9*gmSEQ.P1Pulse+10*tau+PulseSpace*9 Timing+9.5*gmSEQ.P1Pulse+10*tau+PulseSpace*9 0 3*pi/2 gSG.IQVoltage1; ...
        Timing+10*gmSEQ.P1Pulse+11*tau+PulseSpace*10 Timing+10.5*gmSEQ.P1Pulse+11*tau+PulseSpace*10 0 pi/2 gSG.IQVoltage1; ...
        Timing+10.5*gmSEQ.P1Pulse+11*tau+PulseSpace*11 Timing+11*gmSEQ.P1Pulse+11*tau+PulseSpace*11 0 pi/2 gSG.IQVoltage1; ...
        Timing+11*gmSEQ.P1Pulse+12*tau+PulseSpace*11 Timing+11.5*gmSEQ.P1Pulse+12*tau+PulseSpace*11 0 pi/2 gSG.IQVoltage1];
end
    if mod(PulseN,2) == 0
        D_2 = [D_2;...
            Timing+12*gmSEQ.P1Pulse+12*tau+PulseSpace*13 Timing+12.5*gmSEQ.P1Pulse+12*tau+PulseSpace*13 0 3*pi/2 gSG.IQVoltage1];
    else
        D_2 = [D_2;...
            Timing+12*gmSEQ.P1Pulse+12*tau+PulseSpace*13 Timing+12.5*gmSEQ.P1Pulse+12*tau+PulseSpace*13 0 pi/2 gSG.IQVoltage1];
    end
    
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_0 = round((gmSEQ.P1Pulse*12+gmSEQ.m*12+PulseSpace*12)*PulseN+gmSEQ.P1Pulse+PulseSpace+1000);
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_0 = ceil(Length2_0*clkRate2/1e9/16)*16;
    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_0, 'wave_AWG2_ch1_seg0.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_0, 'wave_AWG2_ch2_seg0.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 5, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 5, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


    
ApplyDelays();

function SpinDiffuse_2Counter_Shelve_FM_Sym_SwpN
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% gmSEQ.Diffwait

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

T1_0 = 10000; % fixing, for T1 measurement
T0 = 30000; % t_R + t = T0
gmSEQ.Diffwait = T0;
PulseSpace = 2; % spacing between pi/2 pulse
tau = 10;
PulseN = gmSEQ.m;

FM_total = PulseN*(gmSEQ.P1Pulse*48+tau*48+PulseSpace*48);

if (FM_total>0.9*T0)
    warning('Sequence length exceeds diffusion wait');
    PulseN = 0;
end


Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 100;

A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

% 

    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse-PulseSpace-FM_total-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse-PulseSpace-FM_total-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse+PulseSpace+FM_total+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse+PulseSpace+FM_total+100 ...
    gmSEQ.pi+100];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.Diffwait+2*gmSEQ.DEERpi+gmSEQ.pi+PulseGap) + 2*T1_0;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

if gmSEQ.Diffwait<100
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100];

    else
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];   
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=5; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse-PulseSpace-FM_total ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000 Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse-PulseSpace-FM_total gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500 500 500];



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    D_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1; ...
        gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
    D_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1; ...
        gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 3*pi/2 gSG.IQVoltage1];

    
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    % All waveform needs to start with 0ns !!!
    % gmSEQ.m is single tau, total sequence has 12*tau
    
    D_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.P1Pulse/2 0 0 0];

    if (PulseN == 0)
       Timing = 0.5*gmSEQ.P1Pulse+PulseSpace;
    end
for kkk = 1:PulseN
    Timing = 0.5*gmSEQ.P1Pulse+(kkk-1)*(48*tau+48*gmSEQ.P1Pulse+48*PulseSpace);
    D_1 = [D_1; ...
        Timing+tau Timing+0.5*gmSEQ.P1Pulse+tau 0 pi/2 gSG.IQVoltage1;...
        Timing+0.5*gmSEQ.P1Pulse+tau+PulseSpace Timing+1*gmSEQ.P1Pulse+tau+PulseSpace 0 pi/2 gSG.IQVoltage1;...
        Timing+1*gmSEQ.P1Pulse+2*tau+PulseSpace Timing+1.5*gmSEQ.P1Pulse+2*tau+PulseSpace 0 pi/2 gSG.IQVoltage1;...
        Timing+2*gmSEQ.P1Pulse+3*tau+2*PulseSpace Timing+2.5*gmSEQ.P1Pulse+3*tau+2*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+2.5*gmSEQ.P1Pulse+3*tau+3*PulseSpace Timing+3*gmSEQ.P1Pulse+3*tau+3*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+3*gmSEQ.P1Pulse+4*tau+3*PulseSpace Timing+3.5*gmSEQ.P1Pulse+4*tau+3*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+3.5*gmSEQ.P1Pulse+4*tau+4*PulseSpace Timing+4*gmSEQ.P1Pulse+4*tau+4*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+4*gmSEQ.P1Pulse+5*tau+4*PulseSpace Timing+4.5*gmSEQ.P1Pulse+5*tau+4*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+4.5*gmSEQ.P1Pulse+5*tau+5*PulseSpace Timing+5*gmSEQ.P1Pulse+5*tau+5*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+5*gmSEQ.P1Pulse+6*tau+5*PulseSpace Timing+5.5*gmSEQ.P1Pulse+6*tau+5*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+6*gmSEQ.P1Pulse+7*tau+6*PulseSpace Timing+6.5*gmSEQ.P1Pulse+7*tau+6*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+6.5*gmSEQ.P1Pulse+7*tau+7*PulseSpace Timing+7*gmSEQ.P1Pulse+7*tau+7*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+7*gmSEQ.P1Pulse+8*tau+7*PulseSpace Timing+7.5*gmSEQ.P1Pulse+8*tau+7*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+7.5*gmSEQ.P1Pulse+8*tau+8*PulseSpace Timing+8*gmSEQ.P1Pulse+8*tau+8*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+8*gmSEQ.P1Pulse+9*tau+8*PulseSpace Timing+8.5*gmSEQ.P1Pulse+9*tau+8*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+8.5*gmSEQ.P1Pulse+9*tau+9*PulseSpace Timing+9*gmSEQ.P1Pulse+9*tau+9*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+9*gmSEQ.P1Pulse+10*tau+9*PulseSpace Timing+9.5*gmSEQ.P1Pulse+10*tau+9*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+10*gmSEQ.P1Pulse+11*tau+10*PulseSpace Timing+10.5*gmSEQ.P1Pulse+11*tau+10*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+10.5*gmSEQ.P1Pulse+11*tau+11*PulseSpace Timing+11*gmSEQ.P1Pulse+11*tau+11*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+11*gmSEQ.P1Pulse+12*tau+11*PulseSpace Timing+11.5*gmSEQ.P1Pulse+12*tau+11*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+11.5*gmSEQ.P1Pulse+12*tau+12*PulseSpace Timing+12*gmSEQ.P1Pulse+12*tau+12*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+13.5*gmSEQ.P1Pulse+14*tau+14*PulseSpace Timing+14*gmSEQ.P1Pulse+14*tau+14*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+17.5*gmSEQ.P1Pulse+18*tau+18*PulseSpace Timing+18*gmSEQ.P1Pulse+18*tau+18*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+21.5*gmSEQ.P1Pulse+22*tau+22*PulseSpace Timing+22*gmSEQ.P1Pulse+22*tau+22*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+25*gmSEQ.P1Pulse+26*tau+25*PulseSpace Timing+25.5*gmSEQ.P1Pulse+26*tau+25*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+29*gmSEQ.P1Pulse+30*tau+29*PulseSpace Timing+29.5*gmSEQ.P1Pulse+30*tau+29*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+33*gmSEQ.P1Pulse+34*tau+33*PulseSpace Timing+33.5*gmSEQ.P1Pulse+34*tau+33*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+35*gmSEQ.P1Pulse+36*tau+35*PulseSpace Timing+35.5*gmSEQ.P1Pulse+36*tau+35*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+35.5*gmSEQ.P1Pulse+36*tau+36*PulseSpace Timing+36*gmSEQ.P1Pulse+36*tau+36*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+36*gmSEQ.P1Pulse+37*tau+36*PulseSpace Timing+36.5*gmSEQ.P1Pulse+37*tau+36*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+36.5*gmSEQ.P1Pulse+37*tau+37*PulseSpace Timing+37*gmSEQ.P1Pulse+37*tau+37*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...        
        Timing+37.5*gmSEQ.P1Pulse+38*tau+38*PulseSpace Timing+38*gmSEQ.P1Pulse+38*tau+38*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+38*gmSEQ.P1Pulse+39*tau+38*PulseSpace Timing+38.5*gmSEQ.P1Pulse+39*tau+38*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+38.5*gmSEQ.P1Pulse+39*tau+39*PulseSpace Timing+39*gmSEQ.P1Pulse+39*tau+39*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+39*gmSEQ.P1Pulse+40*tau+39*PulseSpace Timing+39.5*gmSEQ.P1Pulse+40*tau+39*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+39.5*gmSEQ.P1Pulse+40*tau+40*PulseSpace Timing+40*gmSEQ.P1Pulse+40*tau+40*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+40*gmSEQ.P1Pulse+41*tau+40*PulseSpace Timing+40.5*gmSEQ.P1Pulse+41*tau+40*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+40.5*gmSEQ.P1Pulse+41*tau+41*PulseSpace Timing+41*gmSEQ.P1Pulse+41*tau+41*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+41.5*gmSEQ.P1Pulse+42*tau+42*PulseSpace Timing+42*gmSEQ.P1Pulse+42*tau+42*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+42*gmSEQ.P1Pulse+43*tau+42*PulseSpace Timing+42.5*gmSEQ.P1Pulse+43*tau+42*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+42.5*gmSEQ.P1Pulse+43*tau+43*PulseSpace Timing+43*gmSEQ.P1Pulse+43*tau+43*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+43*gmSEQ.P1Pulse+44*tau+43*PulseSpace Timing+43.5*gmSEQ.P1Pulse+44*tau+43*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+43.5*gmSEQ.P1Pulse+44*tau+44*PulseSpace Timing+44*gmSEQ.P1Pulse+44*tau+44*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+44*gmSEQ.P1Pulse+45*tau+44*PulseSpace Timing+44.5*gmSEQ.P1Pulse+45*tau+44*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+44.5*gmSEQ.P1Pulse+45*tau+45*PulseSpace Timing+45*gmSEQ.P1Pulse+45*tau+45*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+45.5*gmSEQ.P1Pulse+46*tau+46*PulseSpace Timing+46*gmSEQ.P1Pulse+46*tau+46*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+46*gmSEQ.P1Pulse+47*tau+46*PulseSpace Timing+46.5*gmSEQ.P1Pulse+47*tau+46*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+46.5*gmSEQ.P1Pulse+47*tau+47*PulseSpace Timing+47*gmSEQ.P1Pulse+47*tau+47*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        
        ];
    
    D_2 = [D_2; ...
        Timing+1.5*gmSEQ.P1Pulse+2*tau+2*PulseSpace Timing+2*gmSEQ.P1Pulse+2*tau+2*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+5.5*gmSEQ.P1Pulse+6*tau+6*PulseSpace Timing+6*gmSEQ.P1Pulse+6*tau+6*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+9.5*gmSEQ.P1Pulse+10*tau+10*PulseSpace Timing+10*gmSEQ.P1Pulse+10*tau+10*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+12*gmSEQ.P1Pulse+13*tau+12*PulseSpace Timing+12.5*gmSEQ.P1Pulse+13*tau+12*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+12.5*gmSEQ.P1Pulse+13*tau+13*PulseSpace Timing+13*gmSEQ.P1Pulse+13*tau+13*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+13*gmSEQ.P1Pulse+14*tau+13*PulseSpace Timing+13.5*gmSEQ.P1Pulse+14*tau+13*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+14*gmSEQ.P1Pulse+15*tau+14*PulseSpace Timing+14.5*gmSEQ.P1Pulse+15*tau+14*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+14.5*gmSEQ.P1Pulse+15*tau+15*PulseSpace Timing+15*gmSEQ.P1Pulse+15*tau+15*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+15*gmSEQ.P1Pulse+16*tau+15*PulseSpace Timing+15.5*gmSEQ.P1Pulse+16*tau+15*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+15.5*gmSEQ.P1Pulse+16*tau+16*PulseSpace Timing+16*gmSEQ.P1Pulse+16*tau+16*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+16*gmSEQ.P1Pulse+17*tau+16*PulseSpace Timing+16.5*gmSEQ.P1Pulse+17*tau+16*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+16.5*gmSEQ.P1Pulse+17*tau+17*PulseSpace Timing+17*gmSEQ.P1Pulse+17*tau+17*PulseSpace 0 3*pi/2 gSG.IQVoltage1;... 
        Timing+17*gmSEQ.P1Pulse+18*tau+17*PulseSpace Timing+17.5*gmSEQ.P1Pulse+18*tau+17*PulseSpace 0 3*pi/2 gSG.IQVoltage1;... 
        Timing+18*gmSEQ.P1Pulse+19*tau+18*PulseSpace Timing+18.5*gmSEQ.P1Pulse+19*tau+18*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+18.5*gmSEQ.P1Pulse+19*tau+19*PulseSpace Timing+19*gmSEQ.P1Pulse+19*tau+19*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+19*gmSEQ.P1Pulse+20*tau+19*PulseSpace Timing+19.5*gmSEQ.P1Pulse+20*tau+19*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+19.5*gmSEQ.P1Pulse+20*tau+20*PulseSpace Timing+20*gmSEQ.P1Pulse+20*tau+20*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+20*gmSEQ.P1Pulse+21*tau+20*PulseSpace Timing+20.5*gmSEQ.P1Pulse+21*tau+20*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+20.5*gmSEQ.P1Pulse+21*tau+21*PulseSpace Timing+21*gmSEQ.P1Pulse+21*tau+21*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+21*gmSEQ.P1Pulse+22*tau+21*PulseSpace Timing+21.5*gmSEQ.P1Pulse+22*tau+21*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+22*gmSEQ.P1Pulse+23*tau+22*PulseSpace Timing+22.5*gmSEQ.P1Pulse+23*tau+22*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+22.5*gmSEQ.P1Pulse+23*tau+23*PulseSpace Timing+23*gmSEQ.P1Pulse+23*tau+23*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+23*gmSEQ.P1Pulse+24*tau+23*PulseSpace Timing+23.5*gmSEQ.P1Pulse+24*tau+23*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+23.5*gmSEQ.P1Pulse+24*tau+24*PulseSpace Timing+24*gmSEQ.P1Pulse+24*tau+24*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+24*gmSEQ.P1Pulse+25*tau+24*PulseSpace Timing+24.5*gmSEQ.P1Pulse+25*tau+24*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+24.5*gmSEQ.P1Pulse+25*tau+25*PulseSpace Timing+25*gmSEQ.P1Pulse+25*tau+25*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+25.5*gmSEQ.P1Pulse+26*tau+26*PulseSpace Timing+26*gmSEQ.P1Pulse+26*tau+26*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+26*gmSEQ.P1Pulse+27*tau+26*PulseSpace Timing+26.5*gmSEQ.P1Pulse+27*tau+26*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+26.5*gmSEQ.P1Pulse+27*tau+27*PulseSpace Timing+27*gmSEQ.P1Pulse+27*tau+27*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+27*gmSEQ.P1Pulse+28*tau+27*PulseSpace Timing+27.5*gmSEQ.P1Pulse+28*tau+27*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+27.5*gmSEQ.P1Pulse+28*tau+28*PulseSpace Timing+28*gmSEQ.P1Pulse+28*tau+28*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+28*gmSEQ.P1Pulse+29*tau+28*PulseSpace Timing+28.5*gmSEQ.P1Pulse+29*tau+28*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+28.5*gmSEQ.P1Pulse+29*tau+29*PulseSpace Timing+29*gmSEQ.P1Pulse+29*tau+29*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+29.5*gmSEQ.P1Pulse+30*tau+30*PulseSpace Timing+30*gmSEQ.P1Pulse+30*tau+30*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+30*gmSEQ.P1Pulse+31*tau+30*PulseSpace Timing+30.5*gmSEQ.P1Pulse+31*tau+30*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+30.5*gmSEQ.P1Pulse+31*tau+31*PulseSpace Timing+31*gmSEQ.P1Pulse+31*tau+31*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+31*gmSEQ.P1Pulse+32*tau+31*PulseSpace Timing+31.5*gmSEQ.P1Pulse+32*tau+31*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+31.5*gmSEQ.P1Pulse+32*tau+32*PulseSpace Timing+32*gmSEQ.P1Pulse+32*tau+32*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+32*gmSEQ.P1Pulse+33*tau+32*PulseSpace Timing+32.5*gmSEQ.P1Pulse+33*tau+32*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+32.5*gmSEQ.P1Pulse+33*tau+33*PulseSpace Timing+33*gmSEQ.P1Pulse+33*tau+33*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+33.5*gmSEQ.P1Pulse+34*tau+34*PulseSpace Timing+34*gmSEQ.P1Pulse+34*tau+34*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+34*gmSEQ.P1Pulse+35*tau+34*PulseSpace Timing+34.5*gmSEQ.P1Pulse+35*tau+34*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+34.5*gmSEQ.P1Pulse+35*tau+35*PulseSpace Timing+35*gmSEQ.P1Pulse+35*tau+35*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+37*gmSEQ.P1Pulse+38*tau+37*PulseSpace Timing+37.5*gmSEQ.P1Pulse+38*tau+37*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+41*gmSEQ.P1Pulse+42*tau+41*PulseSpace Timing+41.5*gmSEQ.P1Pulse+42*tau+41*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+45*gmSEQ.P1Pulse+46*tau+45*PulseSpace Timing+45.5*gmSEQ.P1Pulse+46*tau+45*PulseSpace 0 1*pi/2 gSG.IQVoltage1;...
        Timing+47*gmSEQ.P1Pulse+48*tau+47*PulseSpace Timing+47.5*gmSEQ.P1Pulse+48*tau+47*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        Timing+47.5*gmSEQ.P1Pulse+48*tau+48*PulseSpace Timing+48*gmSEQ.P1Pulse+48*tau+48*PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        ];
end

        D_1 = [D_1;...
            Timing+48*gmSEQ.P1Pulse+48*tau+PulseSpace*49 Timing+48.5*gmSEQ.P1Pulse+48*tau+PulseSpace*49 0 3*pi/2 gSG.IQVoltage1];

    
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_0 = round(FM_total+gmSEQ.P1Pulse+PulseSpace+1000);
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_0 = ceil(Length2_0*clkRate2/1e9/16)*16;
    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_0, 'wave_AWG2_ch1_seg0.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_0, 'wave_AWG2_ch2_seg0.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 5, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 5, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


    
ApplyDelays();

function SpinDiffuse_2Counter_Shelve_FM_fxTau
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% gmSEQ.Diffwait

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

T1_0 = gmSEQ.m; % fixing, for T1 measurement
T0 = 3000; % t_R + t = T0
gmSEQ.Diffwait = T0;
PulseSpace = 2; % spacing between pi/2 pulse

tau_space = 2;

% mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 100;


A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

% 

    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse*13-tau_space*12-PulseSpace*13-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse*13-tau_space*12-PulseSpace*13-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse*13+tau_space*12+PulseSpace*13+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse*13+tau_space*12+PulseSpace*13+100 ...
    gmSEQ.pi+100];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.Diffwait+2*gmSEQ.DEERpi+gmSEQ.pi+PulseGap) + 2*gmSEQ.m;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

if gmSEQ.Diffwait<100
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100];

    else
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];   
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=5; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse*13-tau_space*12-PulseSpace*13 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000 Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse*13-tau_space*12-PulseSpace*13 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500 500 500];



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    D_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1; ...
        gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
    D_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1; ...
        gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 3*pi/2 gSG.IQVoltage1];

    
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    % tau_space is single tau, total sequence has 12*tau
    D_1 = [0 gmSEQ.P1Pulse 0 0 0;...
        2*gmSEQ.P1Pulse+2*tau_space+PulseSpace*2 2.5*gmSEQ.P1Pulse+2*tau_space+PulseSpace*2 0 pi/2 gSG.IQVoltage1;...
        4*gmSEQ.P1Pulse+4*tau_space+PulseSpace*4 4.5*gmSEQ.P1Pulse+4*tau_space+PulseSpace*4 0 pi/2 gSG.IQVoltage1;...
        6*gmSEQ.P1Pulse+6*tau_space+PulseSpace*6 6.5*gmSEQ.P1Pulse+6*tau_space+PulseSpace*6 0 pi/2 gSG.IQVoltage1;...
        8*gmSEQ.P1Pulse+8*tau_space+PulseSpace*8 8.5*gmSEQ.P1Pulse+8*tau_space+PulseSpace*8 0 pi/2 gSG.IQVoltage1;...
        10*gmSEQ.P1Pulse+10*tau_space+PulseSpace*10 10.5*gmSEQ.P1Pulse+10*tau_space+PulseSpace*10 0 3*pi/2 gSG.IQVoltage1;...
        12*gmSEQ.P1Pulse+12*tau_space+PulseSpace*12 12.5*gmSEQ.P1Pulse+12*tau_space+PulseSpace*12 0 pi/2 gSG.IQVoltage1];
    
    D_2 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+tau_space gmSEQ.P1Pulse+tau_space 0 3*pi/2 gSG.IQVoltage1;...
        gmSEQ.P1Pulse+tau_space+PulseSpace gmSEQ.P1Pulse+tau_space+PulseSpace+gmSEQ.P1Pulse/2 0 3*pi/2 gSG.IQVoltage1; ...
        3*gmSEQ.P1Pulse/2+2*tau_space+PulseSpace  2*gmSEQ.P1Pulse+2*tau_space+PulseSpace 0 3*pi/2 gSG.IQVoltage1;...
        2.5*gmSEQ.P1Pulse+3*tau_space+PulseSpace*2 3*gmSEQ.P1Pulse+3*tau_space+PulseSpace*2 0 3*pi/2 gSG.IQVoltage1;...
        3*gmSEQ.P1Pulse+3*tau_space+PulseSpace*3 3.5*gmSEQ.P1Pulse+3*tau_space+PulseSpace*3 0 3*pi/2 gSG.IQVoltage1;...
        3.5*gmSEQ.P1Pulse+4*tau_space+PulseSpace*3 4*gmSEQ.P1Pulse+4*tau_space+PulseSpace*3 0 3*pi/2 gSG.IQVoltage1; ...
        4.5*gmSEQ.P1Pulse+5*tau_space+PulseSpace*4 5*gmSEQ.P1Pulse+5*tau_space+PulseSpace*4 0 3*pi/2 gSG.IQVoltage1; ...
        5*gmSEQ.P1Pulse+5*tau_space+PulseSpace*5 5.5*gmSEQ.P1Pulse+5*tau_space+PulseSpace*5 0 3*pi/2 gSG.IQVoltage1; ...
        5.5*gmSEQ.P1Pulse+6*tau_space+PulseSpace*5 6*gmSEQ.P1Pulse+6*tau_space+PulseSpace*5 0 3*pi/2 gSG.IQVoltage1; ...
        6.5*gmSEQ.P1Pulse+7*tau_space+PulseSpace*6 7*gmSEQ.P1Pulse+7*tau_space+PulseSpace*6 0 pi/2 gSG.IQVoltage1; ...
        7*gmSEQ.P1Pulse+7*tau_space+PulseSpace*7 7.5*gmSEQ.P1Pulse+7*tau_space+PulseSpace*7 0 pi/2 gSG.IQVoltage1; ...
        7.5*gmSEQ.P1Pulse+8*tau_space+PulseSpace*7 8*gmSEQ.P1Pulse+8*tau_space+PulseSpace*7 0 pi/2 gSG.IQVoltage1; ...
        8.5*gmSEQ.P1Pulse+9*tau_space+PulseSpace*8 9*gmSEQ.P1Pulse+9*tau_space+PulseSpace*8 0 3*pi/2 gSG.IQVoltage1; ...
        9*gmSEQ.P1Pulse+9*tau_space+PulseSpace*9 9.5*gmSEQ.P1Pulse+9*tau_space+PulseSpace*9 0 3*pi/2 gSG.IQVoltage1; ...
        9.5*gmSEQ.P1Pulse+10*tau_space+PulseSpace*9 10*gmSEQ.P1Pulse+10*tau_space+PulseSpace*9 0 3*pi/2 gSG.IQVoltage1; ...
        10.5*gmSEQ.P1Pulse+11*tau_space+PulseSpace*10 11*gmSEQ.P1Pulse+11*tau_space+PulseSpace*10 0 pi/2 gSG.IQVoltage1; ...
        11*gmSEQ.P1Pulse+11*tau_space+PulseSpace*11 11.5*gmSEQ.P1Pulse+11*tau_space+PulseSpace*11 0 pi/2 gSG.IQVoltage1; ...
        11.5*gmSEQ.P1Pulse+12*tau_space+PulseSpace*11 12*gmSEQ.P1Pulse+12*tau_space+PulseSpace*11 0 pi/2 gSG.IQVoltage1; ...
        12.5*gmSEQ.P1Pulse+12*tau_space+PulseSpace*13 13*gmSEQ.P1Pulse+12*tau_space+PulseSpace*13 0 pi/2 gSG.IQVoltage1];
% D_1 = [0 100 0 0 0];
% 
% D_2 = [0 100 0 0 0];
    
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_0 = round(gmSEQ.P1Pulse*13+tau_space*12+PulseSpace*13+1000);
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_0 = ceil(Length2_0*clkRate2/1e9/16)*16;
    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_0, 'wave_AWG2_ch1_seg0.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_0, 'wave_AWG2_ch2_seg0.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(1);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(1);
    
    chaseFunctionPool('CreateSegments', 2, 1, 5, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 5, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


    
ApplyDelays();

function SpinDiffuse_2Counter_Shelve_CPMG8_SwpN
global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% gmSEQ.Diffwait

SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

T1_0 = 10000; % fixing, for T1 measurement
T0 = 15000; % t_R + t = T0
gmSEQ.Diffwait = T0;
PulseSpace = 2; % spacing between pi/2 pulse
tau = 10;
PulseN = gmSEQ.m;

if (PulseN*(gmSEQ.P1Pulse*8+tau*8)>0.9*T0)
    warning('Sequence length exceeds diffusion wait');
    PulseN = 0;
end


Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 100;


A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T1_0+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

% 

    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse-PulseN*(gmSEQ.P1Pulse*8+tau*8)-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse-PulseN*(gmSEQ.P1Pulse*8+tau*8)-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse+PulseN*(gmSEQ.P1Pulse*8+tau*8)+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse+PulseN*(gmSEQ.P1Pulse*8+tau*8)+100 ...
    gmSEQ.pi+100];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.Diffwait+2*gmSEQ.DEERpi+gmSEQ.pi+PulseGap) + 2*T1_0;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

if gmSEQ.Diffwait<100
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100];

    else
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];   
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=5; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse-PulseN*(gmSEQ.P1Pulse*8+tau*8) ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000 Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+gmSEQ.Diffwait-gmSEQ.P1Pulse-PulseSpace-PulseN*(gmSEQ.P1Pulse*8+tau*8) gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500 500 500];



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    D_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1; ...
        gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1];
    D_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        gmSEQ.P1Pulse/2+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse (gSG.SGbasefreq-gSG.Freq)/1e9 pi gSG.IQVoltage1; ...
        gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2 gmSEQ.P1Pulse/2+gmSEQ.m/2+gmSEQ.P1Pulse+gmSEQ.m/2+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 3*pi/2 gSG.IQVoltage1];

    
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    % All waveform needs to start with 0ns !!!
    % gmSEQ.m is single tau, total sequence has 12*tau
    
    D_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    D_2 = [0 gmSEQ.P1Pulse/2 0 0 0];

    if (PulseN == 0)
       Timing = 0.5*gmSEQ.P1Pulse;
    end
for kkk = 1:PulseN
    Timing = 0.5*gmSEQ.P1Pulse+(kkk-1)*(8*tau+8*gmSEQ.P1Pulse);
    D_1 = [D_1; ...
        Timing+0*gmSEQ.P1Pulse+0.5*tau Timing+1*gmSEQ.P1Pulse+0.5*tau 0 pi/2 gSG.IQVoltage1;...
        Timing+2*gmSEQ.P1Pulse+2.5*tau Timing+3*gmSEQ.P1Pulse+2.5*tau 0 pi/2 gSG.IQVoltage1;...
        Timing+5*gmSEQ.P1Pulse+5.5*tau Timing+6*gmSEQ.P1Pulse+5.5*tau 0 pi/2 gSG.IQVoltage1;...
        Timing+7*gmSEQ.P1Pulse+7.5*tau Timing+8*gmSEQ.P1Pulse+7.5*tau 0 pi/2 gSG.IQVoltage1;...
        ];
    
    D_2 = [D_2; ...
        Timing+1*gmSEQ.P1Pulse+1.5*tau Timing+2*gmSEQ.P1Pulse+1.5*tau 0 pi/2 gSG.IQVoltage1;...
        Timing+3*gmSEQ.P1Pulse+3.5*tau Timing+4*gmSEQ.P1Pulse+3.5*tau 0 pi/2 gSG.IQVoltage1;...
        Timing+4*gmSEQ.P1Pulse+4.5*tau Timing+5*gmSEQ.P1Pulse+4.5*tau 0 pi/2 gSG.IQVoltage1;...
        Timing+6*gmSEQ.P1Pulse+6.5*tau Timing+7*gmSEQ.P1Pulse+6.5*tau 0 pi/2 gSG.IQVoltage1;...
        ];
end
    Timing = 0.5*gmSEQ.P1Pulse+PulseN*(8*tau+8*gmSEQ.P1Pulse);
    D_1 = [D_1; ...
        Timing Timing+gmSEQ.P1Pulse/2 0 3*pi/2 gSG.IQVoltage1];
    D_2 = [D_2; ...
        Timing Timing+gmSEQ.P1Pulse/2 0 0 0];



    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_0 = round((gmSEQ.P1Pulse*8+gmSEQ.m*8)*PulseN+gmSEQ.P1Pulse+1000);
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_0 = ceil(Length2_0*clkRate2/1e9/16)*16;
    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', D_1, clkRate2/10^9, Length2_0, 'wave_AWG2_ch1_seg0.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, clkRate2/10^9, Length2_0, 'wave_AWG2_ch2_seg0.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg0.txt', Total2_0, 1, 1, ...
        'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 5, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 5, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


    
ApplyDelays();


function T1PolarP1_RotP1_2Counter
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
RepolLen = 1000;

Detect_Window = 5000;

A = [0 gmSEQ.readout+gmSEQ.P1Pulse 0 pi/2 0.54; ...
    gmSEQ.readout+gmSEQ.P1Pulse gmSEQ.readout+gmSEQ.P1Pulse+RepolLen 0 pi/2 0.7;...
    gmSEQ.readout+gmSEQ.P1Pulse+RepolLen+AfterLaser+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+gmSEQ.P1Pulse+RepolLen+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length = gmSEQ.readout+gmSEQ.P1Pulse+RepolLen+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total = ceil(Length*clkRate/1e9/16)*16;
chaseFunctionPool('stopChase'); pause(0.1);
chaseFunctionPool('setClkRate', clkRate); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate/10^9, Length, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment', 1, Total, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase','false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+gmSEQ.P1Pulse+RepolLen+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+gmSEQ.P1Pulse+RepolLen Detect_Window];
% gmSEQ.CHN(1).DT = [gmSEQ.readout 20000];


Start_Sig_D = Wait_p+gmSEQ.readout+gmSEQ.P1Pulse+RepolLen + AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+gmSEQ.P1Pulse+RepolLen+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+gmSEQ.P1Pulse+RepolLen 20000];
% gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout 20000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 4 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 5000+10000 5000+20000 5000+30000 5000+40000 5000+50000 5000+60000 5000+70000 ...
    Wait_p+gmSEQ.readout ...
    gmSEQ.CHN(1).T(2)+20000+5000 gmSEQ.CHN(1).T(2)+20000+5000+10000 gmSEQ.CHN(1).T(2)+20000+5000+20000 gmSEQ.CHN(1).T(1*(2))+20000+5000+30000 ...
    gmSEQ.CHN(1).T(2)+20000+5000+40000 gmSEQ.CHN(1).T(2)+20000+5000+50000 gmSEQ.CHN(1).T(2)+20000+5000+60000 gmSEQ.CHN(1).T(2)+20000+5000+70000 ...
    Start_Sig_D+gmSEQ.readout ...
    gmSEQ.CHN(1).T(2*(2))-gmSEQ.pi-AfterPi];

gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 ...
    gmSEQ.P1Pulse ...
    gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 ...
    gmSEQ.P1Pulse gmSEQ.pi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi) + 2*mwlength + 2*(RepolLen+gmSEQ.P1Pulse);


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+10000-50 5000+20000-50 5000+30000-50 5000+40000-50 5000+50000-50 5000+60000-50 5000+70000-50 ...
    Wait_p+gmSEQ.readout-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+30000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+40000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+50000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+60000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+70000-50 ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout-50 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
  gmSEQ.P1Pulse+100 ...  
gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
gmSEQ.P1Pulse+100 gmSEQ.pi+100];

ApplyDelays();

function T1PolarP1_RotP1_2Counter_Plus1
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

   
mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 300;
RepolLen = 1000;

A = [0 gmSEQ.readout 0 pi/2 0.46; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+20+gmSEQ.P1Pulse+20+gmSEQ.DEERpi+20+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+20+gmSEQ.P1Pulse+20+gmSEQ.DEERpi+20+mwlength+gmSEQ.pi+AfterPi+20000 0 pi/2 0.54];

Length = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+20+gmSEQ.P1Pulse+20+gmSEQ.DEERpi+20+mwlength+gmSEQ.pi+AfterPi+20000+1000;
clkRate = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total = ceil(Length*clkRate/1e9/16)*16;
chaseFunctionPool('stopChase'); pause(0.1);
chaseFunctionPool('setClkRate', clkRate); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate/10^9, Length, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment', 1, Total, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase','false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+20+gmSEQ.P1Pulse+20+gmSEQ.DEERpi+20+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 20000];
% gmSEQ.CHN(1).DT = [gmSEQ.readout 20000];


Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+20+gmSEQ.P1Pulse+20+gmSEQ.DEERpi+20+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+20+gmSEQ.P1Pulse+20+gmSEQ.DEERpi+20+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 20000];
% gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout 20000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 4 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 5000+10000 5000+20000 5000+30000 5000+40000 5000+50000 5000+60000 5000+70000 ...
    Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+20 ...
    gmSEQ.CHN(1).T(2)+20000+5000 gmSEQ.CHN(1).T(2)+20000+5000+10000 gmSEQ.CHN(1).T(2)+20000+5000+20000 gmSEQ.CHN(1).T(1*(2))+20000+5000+30000 ...
    gmSEQ.CHN(1).T(2)+20000+5000+40000 gmSEQ.CHN(1).T(2)+20000+5000+50000 gmSEQ.CHN(1).T(2)+20000+5000+60000 gmSEQ.CHN(1).T(2)+20000+5000+70000 ...
    Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+20 ...
    gmSEQ.CHN(1).T(2*(2))-gmSEQ.pi-AfterPi];
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 ...
%     gmSEQ.P1Pulse ...
%     gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 ...
%     gmSEQ.P1Pulse gmSEQ.pi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) ...
    gmSEQ.P1Pulse ...
    gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) ...
    gmSEQ.P1Pulse gmSEQ.pi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('DEERPulse');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+AfterLaser Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+20+gmSEQ.P1Pulse+20 ...
    Start_Sig_D+gmSEQ.readout+1000+AfterLaser Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+20+gmSEQ.P1Pulse+20];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 20000*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi) + 2*mwlength + 2*(1000+gmSEQ.P1Pulse+gmSEQ.DEERpi*2+20*3);


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

ApplyDelays();

function TestCharge_2Counter
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 2000;
RepolLen = 1000;

Detect_Window = 5000;

A = [0 gmSEQ.readout+gmSEQ.P1Pulse 0 pi/2 0.54; ...
    gmSEQ.readout+gmSEQ.P1Pulse gmSEQ.readout+gmSEQ.P1Pulse+RepolLen 0 pi/2 0.7;...
    gmSEQ.readout+gmSEQ.P1Pulse+RepolLen+AfterLaser+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+gmSEQ.P1Pulse+RepolLen+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length = gmSEQ.readout+gmSEQ.P1Pulse+RepolLen+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total = ceil(Length*clkRate/1e9/16)*16;
chaseFunctionPool('stopChase', 1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate/10^9, Length, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+gmSEQ.P1Pulse+RepolLen+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+gmSEQ.P1Pulse+RepolLen Detect_Window];
% gmSEQ.CHN(1).DT = [gmSEQ.readout 20000];


Start_Sig_D = Wait_p+gmSEQ.readout+gmSEQ.P1Pulse+RepolLen + AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+gmSEQ.P1Pulse+RepolLen+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+gmSEQ.P1Pulse+RepolLen 20000];
% gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout 20000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 5000+10000 5000+20000 5000+30000 5000+40000 5000+50000 5000+60000 5000+70000 ...
    gmSEQ.CHN(1).T(2)+20000+5000 gmSEQ.CHN(1).T(2)+20000+5000+10000 gmSEQ.CHN(1).T(2)+20000+5000+20000 gmSEQ.CHN(1).T(1*(2))+20000+5000+30000 ...
    gmSEQ.CHN(1).T(2)+20000+5000+40000 gmSEQ.CHN(1).T(2)+20000+5000+50000 gmSEQ.CHN(1).T(2)+20000+5000+60000 gmSEQ.CHN(1).T(2)+20000+5000+70000 ...
    gmSEQ.CHN(1).T(2*(2))-gmSEQ.pi-AfterPi];

gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 ...
    gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 ...
    gmSEQ.pi];

% Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi) + 2*mwlength + 2*(RepolLen+gmSEQ.P1Pulse);

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise= 6; 
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+gmSEQ.P1Pulse+RepolLen+100 Wait_p+gmSEQ.readout+gmSEQ.P1Pulse+RepolLen+1000 Wait_p+gmSEQ.readout+gmSEQ.P1Pulse+RepolLen+1000+700 ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+gmSEQ.P1Pulse+RepolLen+100 gmSEQ.CHN(1).T(3)+gmSEQ.readout+gmSEQ.P1Pulse+RepolLen+1000 gmSEQ.CHN(1).T(3)+gmSEQ.readout+gmSEQ.P1Pulse+RepolLen+1000+700];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[5*gmSEQ.pi/2 gmSEQ.pi/2 gmSEQ.pi/2 5*gmSEQ.pi/2 gmSEQ.pi/2 gmSEQ.pi/2];

Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi+gmSEQ.P1Pulse+RepolLen) + 2*mwlength-200;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+10000-50 5000+20000-50 5000+30000-50 5000+40000-50 5000+50000-50 5000+60000-50 5000+70000-50 ...
    Wait_p+gmSEQ.readout-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+30000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+40000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+50000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+60000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+70000-50 ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout-50 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
  gmSEQ.P1Pulse+RepolLen+AfterLaser+100 ...  
gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
gmSEQ.P1Pulse+RepolLen+AfterLaser+100 gmSEQ.pi+100];


ApplyDelays();

function T1PolarP1_FCB_2Counter
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 2e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

AfterPi = 20;
AfterLaser = 0;

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout 20000];

Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout 20000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

% gmSEQ.MREVN
% gmSEQ.MREVtau

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=8+8*gmSEQ.MREVN; % use 4 pi/2 P1 pulse spacing 10us away to mix P1

gmSEQ.CHN(numel(gmSEQ.CHN)).T = [5000 5000+10000 5000+10000+10000 5000+10000+10000+10000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2];

MREV1_start = Wait_p;
for zz = 1:gmSEQ.MREVN
    gmSEQ.CHN(numel(gmSEQ.CHN)).T =[gmSEQ.CHN(numel(gmSEQ.CHN)).T...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+gmSEQ.MREVtau ...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+11*gmSEQ.MREVtau+3.5*gmSEQ.P1Pulse ...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+13*gmSEQ.MREVtau+5*gmSEQ.P1Pulse ...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+23*gmSEQ.MREVtau+8.5*gmSEQ.P1Pulse];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT ...
        gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2];
end
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [gmSEQ.CHN(numel(gmSEQ.CHN)).T gmSEQ.CHN(1).T(2)+20000+5000 gmSEQ.CHN(1).T(2)+20000+5000+10000 gmSEQ.CHN(1).T(2)+20000+5000+10000+10000 gmSEQ.CHN(1).T(2)+20000+5000+10000+10000+10000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2];

MREV2_start = Start_Sig_D;

for zz = 1:gmSEQ.MREVN
    gmSEQ.CHN(numel(gmSEQ.CHN)).T =[gmSEQ.CHN(numel(gmSEQ.CHN)).T ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+gmSEQ.MREVtau ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+11*gmSEQ.MREVtau+3.5*gmSEQ.P1Pulse ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+13*gmSEQ.MREVtau+5*gmSEQ.P1Pulse ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+23*gmSEQ.MREVtau+8.5*gmSEQ.P1Pulse];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2];
end

if (gmSEQ.MREVN >0)
    
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=8*gmSEQ.MREVN;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [];
for zz = 1:gmSEQ.MREVN
    gmSEQ.CHN(numel(gmSEQ.CHN)).T =[gmSEQ.CHN(numel(gmSEQ.CHN)).T ...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+5*gmSEQ.MREVtau+1.5*gmSEQ.P1Pulse ...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+7*gmSEQ.MREVtau+2*gmSEQ.P1Pulse ...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+17*gmSEQ.MREVtau+6.5*gmSEQ.P1Pulse ...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+19*gmSEQ.MREVtau+7*gmSEQ.P1Pulse];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2];
end
for zz = 1:gmSEQ.MREVN
    gmSEQ.CHN(numel(gmSEQ.CHN)).T =[gmSEQ.CHN(numel(gmSEQ.CHN)).T ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+5*gmSEQ.MREVtau+1.5*gmSEQ.P1Pulse ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+7*gmSEQ.MREVtau+2*gmSEQ.P1Pulse ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+17*gmSEQ.MREVtau+6.5*gmSEQ.P1Pulse ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+19*gmSEQ.MREVtau+7*gmSEQ.P1Pulse];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2];
end

end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=12*gmSEQ.MREVN+1; % 
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [];
for zz = 1:gmSEQ.MREVN
    gmSEQ.CHN(numel(gmSEQ.CHN)).T =[gmSEQ.CHN(numel(gmSEQ.CHN)).T MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+4*gmSEQ.MREVtau+1*gmSEQ.P1Pulse ...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+10*gmSEQ.MREVtau+3*gmSEQ.P1Pulse ...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+12*gmSEQ.MREVtau+4*gmSEQ.P1Pulse ...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+16*gmSEQ.MREVtau+6*gmSEQ.P1Pulse ...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+22*gmSEQ.MREVtau+8*gmSEQ.P1Pulse ...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+24*gmSEQ.MREVtau+9*gmSEQ.P1Pulse];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse];
end
for zz = 1:gmSEQ.MREVN
    gmSEQ.CHN(numel(gmSEQ.CHN)).T =[gmSEQ.CHN(numel(gmSEQ.CHN)).T ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+4*gmSEQ.MREVtau+1*gmSEQ.P1Pulse ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+10*gmSEQ.MREVtau+3*gmSEQ.P1Pulse ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+12*gmSEQ.MREVtau+4*gmSEQ.P1Pulse ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+16*gmSEQ.MREVtau+6*gmSEQ.P1Pulse ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+22*gmSEQ.MREVtau+8*gmSEQ.P1Pulse ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+24*gmSEQ.MREVtau+9*gmSEQ.P1Pulse];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse];
end
gmSEQ.CHN(numel(gmSEQ.CHN)).T =[gmSEQ.CHN(numel(gmSEQ.CHN)).T gmSEQ.CHN(1).T(2*(2))-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.pi];

if (gmSEQ.MREVN >0)
    
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('Q_n');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=8*gmSEQ.MREVN;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [];
for zz = 1:gmSEQ.MREVN
    gmSEQ.CHN(numel(gmSEQ.CHN)).T =[gmSEQ.CHN(numel(gmSEQ.CHN)).T ...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+2*gmSEQ.MREVtau+0.5*gmSEQ.P1Pulse ...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+8*gmSEQ.MREVtau+2.5*gmSEQ.P1Pulse ...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+14*gmSEQ.MREVtau+5.5*gmSEQ.P1Pulse ...
        MREV1_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+21*gmSEQ.MREVtau+7.5*gmSEQ.P1Pulse];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2];
end
for zz = 1:gmSEQ.MREVN
    gmSEQ.CHN(numel(gmSEQ.CHN)).T =[gmSEQ.CHN(numel(gmSEQ.CHN)).T ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+2*gmSEQ.MREVtau+0.5*gmSEQ.P1Pulse ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+8*gmSEQ.MREVtau+2.5*gmSEQ.P1Pulse ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+14*gmSEQ.MREVtau+5.5*gmSEQ.P1Pulse ...
        MREV2_start+(zz-1)*(24*gmSEQ.MREVtau+10*gmSEQ.P1Pulse)+21*gmSEQ.MREVtau+7.5*gmSEQ.P1Pulse];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.CHN(numel(gmSEQ.CHN)).DT gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2];
end

end

% if (gmSEQ.bSweep3)
%     Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To3+0.1e6;
% elseif (gmSEQ.bSweep2)
%     Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To2+0.1e6;
% else
%     Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To+0.1e6;
% end

Max_length = 2*Wait_p +  2*gmSEQ.readout + 20000*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi) + 2*mwlength-200;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

ApplyDelays();


function T1PolarP1_SpeedupP1Mix_LeeGoldBurg
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

HPSG = visa('agilent', 'GPIB0::19::INSTR');
    fclose(HPSG);
    fopen(HPSG);
    fprintf(HPSG, '%s', 'RF0');
    AA = ['CW ', num2str(gSG.Freq2), 'GZ'];
    fprintf(HPSG, '%s', AA);
    AA = ['PL', num2str(gSG.Pow2), 'dm'];
    fprintf(HPSG, '%s', AA);
    fprintf(HPSG, '%s', 'RF1');
    pause(0.5);
    fclose(HPSG);

mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=(gmSEQ.PulseNum+2)*2+2;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

AfterPi = 50;
AfterLaser = 0;

for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T (kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout 20000];

Start_Sig_D = gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;
for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T Start_Sig_D+(kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout 20000];

Start_Ref = Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Ref Start_Ref+5000+2000];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT 5000 5000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(gmSEQ.PulseNum+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+5000+10000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=13; % use 4 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2))+20000+5000 gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2))+20000+5000+10000 gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2))+20000+5000+10000+10000 gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2))+20000+5000+10000+10000+10000 ...
    gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))-gmSEQ.pi-AfterPi ...
    gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))+20000+5000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))+20000+5000+10000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))+20000+5000+10000+10000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))+20000+5000+10000+10000+10000 ...
    gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000+10000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000+10000+10000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000+10000+10000+10000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.pi gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('DEERPulse');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[floor((gmSEQ.readout-1000)/(gmSEQ.P1Pulse*2/(1.5)^0.5))*(gmSEQ.P1Pulse*2/(1.5)^0.5) floor((gmSEQ.readout-1000)/(gmSEQ.P1Pulse*2/(1.5)^0.5))*(gmSEQ.P1Pulse*2/(1.5)^0.5)];


% 
% if (gmSEQ.bSweep3)
%     Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To3+0.1e6;
% elseif (gmSEQ.bSweep2)
%     Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To2+0.1e6;
% else
%     Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To+0.1e6;
% end

Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 20000*4 + 6000 + 2*gmSEQ.pi + 2*mwlength+0.03e6;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];

ApplyDelays();


function T1PolarP1_SpeedupP1Mix_RotateP1
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=(gmSEQ.PulseNum+2)*2+2;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

AfterPi = 50;
AfterLaser = 0;

for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T (kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.P1Pulse+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+gmSEQ.P1Pulse+1000 20000];

Start_Sig_D = gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.P1Pulse+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;
for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T Start_Sig_D+(kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.P1Pulse+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+gmSEQ.P1Pulse+1000 20000];

Start_Ref = Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+gmSEQ.P1Pulse+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Ref Start_Ref+5000+2000];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT 5000 5000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(gmSEQ.PulseNum+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+5000+10000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=9; % use 2 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(gmSEQ.PulseNum+1)+gmSEQ.readout ...
    gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2))+20000+5000 gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2))+20000+5000+10000 ...
    gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)-1)+gmSEQ.readout ...
    gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))-gmSEQ.pi-AfterPi gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))+20000+5000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))+20000+5000+10000 ...
    gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000+10000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse ...
    gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse gmSEQ.pi gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2];

% if (gmSEQ.bSweep3)
%     Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To3+0.1e6;
% elseif (gmSEQ.bSweep2)
%     Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To2+0.1e6;
% else
%     Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To+0.1e6;
% end

Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 20000*4 + 6000 + 2*gmSEQ.pi + 2*mwlength+0.1e6;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];

ApplyDelays();

function T1PolarP1_RotP1_2ndMWdrive
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

HPSG = visa('agilent', 'GPIB0::19::INSTR');
    fclose(HPSG);
    fopen(HPSG);
    fprintf(HPSG, '%s', 'RF0');
    AA = ['CW ', num2str(gSG.Freq2), 'GZ'];
    fprintf(HPSG, '%s', AA);
    AA = ['PL', num2str(gSG.Pow2), 'dm'];
    fprintf(HPSG, '%s', AA);
    fprintf(HPSG, '%s', 'RF1');
    pause(0.5);
    fclose(HPSG);

mwlength=gmSEQ.m;
Wait_p = 2e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

AfterPi = 100;
AfterLaser = 0;

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+gmSEQ.P1Pulse+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+gmSEQ.P1Pulse+1000 20000];
% gmSEQ.CHN(1).DT = [gmSEQ.readout 20000];

Start_Sig_D = Wait_p+gmSEQ.readout+gmSEQ.P1Pulse+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+gmSEQ.P1Pulse+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+gmSEQ.P1Pulse+1000 20000];
% gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout 20000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=19; % use 4 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 5000+10000 5000+20000 5000+30000 5000+40000 5000+50000 5000+60000 5000+70000 ...
    Wait_p+gmSEQ.readout ...
    gmSEQ.CHN(1).T(2)+20000+5000 gmSEQ.CHN(1).T(2)+20000+5000+10000 gmSEQ.CHN(1).T(2)+20000+5000+20000 gmSEQ.CHN(1).T(1*(2))+20000+5000+30000 ...
    gmSEQ.CHN(1).T(2)+20000+5000+40000 gmSEQ.CHN(1).T(2)+20000+5000+50000 gmSEQ.CHN(1).T(2)+20000+5000+60000 gmSEQ.CHN(1).T(2)+20000+5000+70000 ...
    Start_Sig_D+gmSEQ.readout ...
    gmSEQ.CHN(1).T(2*(2))-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) ...
    gmSEQ.P1Pulse ...
    gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) gmSEQ.pi/sqrt(2) ...
    gmSEQ.P1Pulse gmSEQ.pi];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('DEERPulse');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.readout-1000 gmSEQ.readout-1000];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 20000*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi) + 2*mwlength + 2*(1000+gmSEQ.P1Pulse);


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

ApplyDelays();

function T1PolarP1_SpeedupP1Mix_4Counter
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 2e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

AfterPi = 100;
AfterLaser = 0;

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout 2000];

Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi+2000+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout 2000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(2)+5000 gmSEQ.CHN(1).T(4) gmSEQ.CHN(1).T(4)+5000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 5000+10000 5000+20000 5000+30000 5000+40000 5000+50000 5000+60000 5000+70000 ...
    gmSEQ.CHN(1).T(2)+2000+5000 gmSEQ.CHN(1).T(2)+2000+5000+10000 gmSEQ.CHN(1).T(2)+2000+5000+20000 gmSEQ.CHN(1).T(1*(2))+2000+5000+30000 ...
    gmSEQ.CHN(1).T(2)+2000+5000+40000 gmSEQ.CHN(1).T(2)+2000+5000+50000 gmSEQ.CHN(1).T(2)+2000+5000+60000 gmSEQ.CHN(1).T(2)+2000+5000+70000 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 ...
    gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 ...
    gmSEQ.pi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 5000*2+2*1000 + 2*(AfterLaser+AfterPi+gmSEQ.pi) + 2*mwlength-200;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

ApplyDelays();

function T1PolarP1_2Counter_2ndMWdrive
global gmSEQ gSG gSG3
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

SignalGeneratorFunctionPool3('WritePow');
SignalGeneratorFunctionPool3('WriteFreq');
gSG3.bOn=1; SignalGeneratorFunctionPool3('RFOnOff');

mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;


A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase', 1); pause(0.1);
chaseFunctionPool('setClkRate', 1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment', 1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];

Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];

% driving of disorder
% Adding a threshold (350ns)
if gmSEQ.m > 350
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+AfterLaser+350 Start_Sig_D+gmSEQ.readout+1000+AfterLaser+350];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m-350-100 gmSEQ.m-350-100];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+AfterLaser+350-50 Start_Sig_D+gmSEQ.readout+1000+AfterLaser+350-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m-350 gmSEQ.m-350];
end

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500];



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');

ApplyDelays();

function T1PolarP1_2Counter_2ndMWdrive_SwpFreq

global gmSEQ gSG gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

% gmSEQ.Diffwait
gSG2.Freq = gmSEQ.m*1e9;


SignalGeneratorFunctionPool2('WritePow');
SignalGeneratorFunctionPool2('WriteFreq');
if (gSG2.Freq == 1.23*1e9) || (gSG2.Freq == 1.422*1e9) || (gSG2.Freq == 1.37*1e9)
    gSG2.bOn=0; SignalGeneratorFunctionPool2('RFOnOff');
else
    gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');
end

T0 = 3000;
Wait_p = 0.3e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 30;

A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+T0+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+T0+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+T0+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase', 1); pause(0.1);
chaseFunctionPool('setClkRate', 1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment', 1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+T0+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];

Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+T0+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+T0+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];


Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi) + 2*T0;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000-50 ...
    Start_Sig_D+gmSEQ.readout+1000-50 ];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[AfterLaser+T0+50 AfterLaser+T0+50];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000 ...
    Start_Sig_D+gmSEQ.readout+1000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[AfterLaser+T0-50 AfterLaser+T0-50];

% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');

ApplyDelays();

function T1PolarP1_2Counter_2ndMWdriveLaser
global gmSEQ gSG gSG3
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

SignalGeneratorFunctionPool3('WritePow');
SignalGeneratorFunctionPool3('WriteFreq');
gSG3.bOn=1; SignalGeneratorFunctionPool3('RFOnOff');

mwlength=gmSEQ.m;
Wait_p = 2e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;


A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase', 1); pause(0.1);
chaseFunctionPool('setClkRate', 1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment', 1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];

Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];

% driving of disorder
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout gmSEQ.readout];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p-50 Start_Sig_D-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout+100 gmSEQ.readout+100];


Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.pi) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500];



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');

ApplyDelays();

function SpinDiff_shelve_2ndMWdrive
global gmSEQ gSG gSG3 gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

SignalGeneratorFunctionPool3('WritePow');
pause(0.05);
SignalGeneratorFunctionPool3('WriteFreq');
pause(0.05);
gSG3.bOn=1; SignalGeneratorFunctionPool3('RFOnOff');
pause(0.05);

SignalGeneratorFunctionPool2('WritePow');
pause(0.05);
SignalGeneratorFunctionPool2('WriteFreq');
pause(0.05);
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');
pause(0.05);


mwlength=gmSEQ.m;
Wait_p = 2e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 50;

A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.Diffwait+2*gmSEQ.DEERpi+gmSEQ.pi+PulseGap) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

if gmSEQ.Diffwait<100
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100];

    else
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];   
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500];

% 3rd MW driving (driving disorder)
if (gmSEQ.Diffwait > 200)
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.Diffwait gmSEQ.Diffwait];
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.Diffwait-100 gmSEQ.Diffwait-100];
    
    else
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[0 0];
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[0 0];    
end
    



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


    
ApplyDelays();

function SpinDiff_shelve_2ndMWdrive_after_td
global gmSEQ gSG gSG3 gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

SignalGeneratorFunctionPool3('WritePow');
pause(0.05);
SignalGeneratorFunctionPool3('WriteFreq');
pause(0.05);
gSG3.bOn=1; SignalGeneratorFunctionPool3('RFOnOff');
pause(0.05);

SignalGeneratorFunctionPool2('WritePow');
pause(0.05);
SignalGeneratorFunctionPool2('WriteFreq');
pause(0.05);
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');
pause(0.05);


mwlength=gmSEQ.m;
Wait_p = 2e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 50;

A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.Diffwait+2*gmSEQ.DEERpi+gmSEQ.pi+PulseGap) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

if gmSEQ.Diffwait<100
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100];

    else
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];   
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500];

% 3rd MW driving (driving disorder)
if (gmSEQ.m > 250)
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m-100 gmSEQ.m-100];
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m-200 gmSEQ.m-200];
    
    else
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[0 0];
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[0 0];    
end
    



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


    
ApplyDelays();

function SpinDiff_shelve_2ndMWdrive_AllON
global gmSEQ gSG gSG3 gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

SignalGeneratorFunctionPool3('WritePow');
pause(0.05);
SignalGeneratorFunctionPool3('WriteFreq');
pause(0.05);
gSG3.bOn=1; SignalGeneratorFunctionPool3('RFOnOff');
pause(0.05);

SignalGeneratorFunctionPool2('WritePow');
pause(0.05);
SignalGeneratorFunctionPool2('WriteFreq');
pause(0.05);
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');
pause(0.05);


mwlength=gmSEQ.m;
Wait_p = 10e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 50;

A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.Diffwait+2*gmSEQ.DEERpi+gmSEQ.pi+PulseGap) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

if gmSEQ.Diffwait<100
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100];

    else
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];   
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500];

% 3rd MW driving (driving disorder)
if (gmSEQ.Diffwait>200)
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)-50 ...
        gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap ...
        gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi ...
        gmSEQ.CHN(1).T(3)-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi];
    
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout+1000+AfterLaser+50 gmSEQ.Diffwait gmSEQ.m ...
        gmSEQ.readout+1000+AfterLaser+50 gmSEQ.Diffwait gmSEQ.m];       
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1) ...
        gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+50 ...
        gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+50 ...
        gmSEQ.CHN(1).T(3) ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout+1000+AfterLaser-50 gmSEQ.Diffwait-100 gmSEQ.m-100 ...
        gmSEQ.readout+1000+AfterLaser-50 gmSEQ.Diffwait-100 gmSEQ.m-100];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)-50 ...
        gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi ...
        gmSEQ.CHN(1).T(3)-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout+1000+AfterLaser+50 gmSEQ.m ...
        gmSEQ.readout+1000+AfterLaser+50 gmSEQ.m];       
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1) ...
        gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+50 ...
        gmSEQ.CHN(1).T(3) ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.readout+1000+AfterLaser-50 gmSEQ.m-100 ...
        gmSEQ.readout+1000+AfterLaser-50 gmSEQ.m-100];
end
    



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


    
ApplyDelays();

function SpinDiff_shelve_2ndMWdrive_LateON
global gmSEQ gSG gSG3 gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

pause(0.05);
SignalGeneratorFunctionPool3('WritePow');
pause(0.05);
SignalGeneratorFunctionPool3('WriteFreq');
pause(0.05);
gSG3.bOn=1; SignalGeneratorFunctionPool3('RFOnOff');
pause(0.05);

SignalGeneratorFunctionPool2('WritePow');
pause(0.05);
SignalGeneratorFunctionPool2('WriteFreq');
pause(0.05);
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');
pause(0.05);

T0 = 1000000;
mwlength=gmSEQ.m;
Wait_p = 10e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 50;

A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.Diffwait+2*gmSEQ.DEERpi+gmSEQ.pi+PulseGap) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

if gmSEQ.Diffwait<100
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100];

    else
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];   
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500];

% 3rd MW driving (driving disorder)
if (gmSEQ.m>T0)
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T0-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T0-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m-T0 ...
        gmSEQ.m-T0];       
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T0 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+T0];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m-T0-100 gmSEQ.m-T0-100];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[20];       
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[20];
end
    



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


    
ApplyDelays();

function SpinDiff_shelve_2ndMWdrive_AfterLaserON
global gmSEQ gSG gSG3 gSG2
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

pause(0.1);
SignalGeneratorFunctionPool3('WritePow');
pause(0.05);
SignalGeneratorFunctionPool3('WriteFreq');
pause(0.05);
gSG3.bOn=1; SignalGeneratorFunctionPool3('RFOnOff');
pause(0.05);

SignalGeneratorFunctionPool2('WritePow');
pause(0.05);
SignalGeneratorFunctionPool2('WriteFreq');
pause(0.05);
gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');
pause(0.05);

mwlength=gmSEQ.m;
Wait_p = 4e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

AfterPi = 100;
AfterLaser = 1000;
Detect_Window = 5000;
PulseGap = 50;

A = [0 gmSEQ.readout 0 pi/2 0.54; ...
    gmSEQ.readout gmSEQ.readout+1000 0 pi/2 0.7;...
    gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window 0 pi/2 0.7];

Length1 = gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+1000;
clkRate1 = 0.05e9; pause(0.1);
% delay depends on sampling rate: roughly delay ~ 56/clkrate (0.1GHz ~
% 560ns)
Total1 = ceil(Length1*clkRate1/1e9/16)*16;
chaseFunctionPool('stopChase',1); pause(0.1);
chaseFunctionPool('setClkRate',1, clkRate1); pause(0.1);
chaseFunctionPool('createWaveform', A, clkRate1/10^9, Length1, 'wave_ch1.txt'); pause(1);
chaseFunctionPool('CreateSingleSegment',1, 1, Total1, 1, 2047, 2047, 'wave_ch1.txt', 1);
pause(1);
chaseFunctionPool('runChase',1,'false');

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=4;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout+1000 Detect_Window];


Start_Sig_D = Wait_p+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout+1000 Detect_Window];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('LaserAWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p Start_Sig_D];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 1000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[1000 gmSEQ.CtrGateDur 1000 gmSEQ.CtrGateDur];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=17; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000-50 5000+5000-50 5000+10000-50 5000+15000-50 5000+20000-50 5000+25000-50 5000+30000-50 5000+35000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+5000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+10000-50 gmSEQ.CHN(1).T(1*(2))+Detect_Window+5000+15000-50 ...
    gmSEQ.CHN(1).T(2)+Detect_Window+5000+20000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+25000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+30000-50 gmSEQ.CHN(1).T(2)+Detect_Window+5000+35000-50 ...
    gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 gmSEQ.P1Pulse/2+100 ...
    gmSEQ.pi+100];

% 
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi gmSEQ.DEERpi];

Max_length = 2*Wait_p +  2*gmSEQ.readout + 1000*2 + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.Diffwait+2*gmSEQ.DEERpi+gmSEQ.pi+PulseGap) + 2*mwlength;


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

if gmSEQ.Diffwait<100
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+100];

    else
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch2');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser-50 gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait-50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.DEERpi+100 gmSEQ.DEERpi+100 ...  
    gmSEQ.DEERpi+100 gmSEQ.DEERpi+100];   
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MW_AWG');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[5000 gmSEQ.CHN(1).T(2)+Detect_Window+5000 gmSEQ.CHN(1).T(4)-gmSEQ.pi-AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500 500];

% 3rd MW driving (driving disorder)
if (gmSEQ.Diffwait<200)
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m gmSEQ.m];       
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.m-100 gmSEQ.m-100];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWswitch3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap ...
        gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.Diffwait gmSEQ.m gmSEQ.Diffwait gmSEQ.m];       
    
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I_3');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+50 ...
        gmSEQ.CHN(1).T(1)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+50 ...
        gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap ...
    gmSEQ.CHN(1).T(3)+gmSEQ.readout+1000+AfterLaser+gmSEQ.DEERpi+PulseGap+gmSEQ.Diffwait+gmSEQ.DEERpi+50];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.Diffwait-100 gmSEQ.m-100 gmSEQ.Diffwait-100 gmSEQ.m-100];
end
    



% for MW_AWG
if gSG.ACmod % in AC modulation mode
    B_1 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
    
    C_1 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 0 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi (gSG.SGbasefreq-gSG.Freq)/1e9 pi/2 gSG.IQVoltage1];
else
    B_1 = [0 gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        5000 5000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        10000 10000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        15000 15000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        20000 20000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        25000 25000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        30000 30000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1;...
        35000 35000+gmSEQ.P1Pulse/2 0 pi/2 gSG.IQVoltage1];
    B_2 = [0 gmSEQ.P1Pulse/2 0 0 0];
    
    C_1 = [0 gmSEQ.pi 0 pi/2 gSG.IQVoltage1];
    C_2 = [0 gmSEQ.pi 0 0 0];
end
    Length2_1 = round(35000+gmSEQ.P1Pulse/2+1000);
    Length2_2 = round(gmSEQ.pi+1000);
    clkRate2 = 2e9;

    Total2_1 = ceil(Length2_1*clkRate2/1e9/16)*16;
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    
    chaseFunctionPool('stopChase', 2); pause(0.3);
    chaseFunctionPool('setClkRate', 2, clkRate2); pause(0.3);
    chaseFunctionPool('createWaveform', B_1, clkRate2/10^9, Length2_1, 'wave_AWG2_ch1_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', B_2, clkRate2/10^9, Length2_1, 'wave_AWG2_ch2_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_1, clkRate2/10^9, Length2_2, 'wave_AWG2_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, clkRate2/10^9, Length2_2, 'wave_AWG2_ch2_seg2.txt'); pause(0.5);
    
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch1_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch1_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, ...
        'wave_AWG2_ch2_seg1.txt', Total2_1, 1, 1, 'wave_AWG2_ch2_seg2.txt', Total2_2, 1, 1);
    pause(0.5);
    
    chaseFunctionPool('CreateSegments', 2, 1, 3, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', 2, 2, 3, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', 2, 'false');


    
ApplyDelays();

function T1PolarP1_SpeedupP1Mix
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

mwlength=gmSEQ.m;
Wait_p = 1e6; % to wait for P1 to be fully unpolarized again
% gmSEQ.m is the current iteration

%%%%% Fixed sequence length %%%%%%
gmSEQ.CHN(1).PBN=PBDictionary('AOM');

gmSEQ.CHN(1).NRise=(gmSEQ.PulseNum+2)*2+2;

gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];

AfterPi = 100;
AfterLaser = 0;

for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T (kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end

% Pulse for first T1 measurement
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout 20000];

Start_Sig_D = gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;
for kk = 1:gmSEQ.PulseNum
gmSEQ.CHN(1).T=[gmSEQ.CHN(1).T Start_Sig_D+(kk-1)*(gmSEQ.tP1Polar+gmSEQ.readout)];
gmSEQ.CHN(1).DT=[gmSEQ.CHN(1).DT gmSEQ.readout];
end
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout) Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout 20000];

Start_Ref = Start_Sig_D+gmSEQ.PulseNum*(gmSEQ.tP1Polar+gmSEQ.readout)+gmSEQ.readout+AfterLaser+mwlength+gmSEQ.pi+AfterPi+20000+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Ref Start_Ref+5000+2000];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT 5000 5000];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(gmSEQ.PulseNum+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2) gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+5000+10000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=13; % use 4 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2))+20000+5000 gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2))+20000+5000+10000 gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2))+20000+5000+10000+10000 gmSEQ.CHN(1).T(1*(gmSEQ.PulseNum+2))+20000+5000+10000+10000+10000 ...
    gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))-gmSEQ.pi-AfterPi ...
    gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))+20000+5000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))+20000+5000+10000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))+20000+5000+10000+10000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2))+20000+5000+10000+10000+10000 ...
    gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000+10000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000+10000+10000 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+20000+5000+10000+10000+10000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.pi gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2 gmSEQ.P1Pulse/2];

if (gmSEQ.bSweep3)
    Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To3+0.1e6;
elseif (gmSEQ.bSweep2)
    Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To2+0.1e6;
else
    Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 6000 + 2*gmSEQ.pi + 2*gmSEQ.To+0.1e6;
end

% Max_length = 3*Wait_p + 2*(gmSEQ.PulseNum)*(gmSEQ.tP1Polar+gmSEQ.readout) + 2*gmSEQ.readout + 20000*4 + 6000 + 2*gmSEQ.pi + 2*mwlength+0.1e6;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[12 12];

ApplyDelays();