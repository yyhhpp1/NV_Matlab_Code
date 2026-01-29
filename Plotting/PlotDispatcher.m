function PlotDispatcher(plotting_method, handles, raw_j)

switch plotting_method
    case 'ESR'
        ave_ax_plot_esr(handles, raw_j);
    case 'Rabi'
        raw_ax_plot_general(handles, raw_j)
        ave_ax_plot_rabi(handles, raw_j);
    case 'ctr2_dvd_ctr1'
        raw_ax_plot_general(handles, raw_j)
        ave_ax_plot_ctr2_dvd_ctr1(handles, raw_j);
    case 'T1_S00_S01'
        raw_ax_plot_general(handles, raw_j)
        ave_ax_plot_T1_S00_S01(handles, raw_j);
    case 'T1_S00_S01_S10'
        raw_ax_plot_T1_S00_S01_S10(handles, raw_j)
        ave_ax_plot_T1_S00_S01_S10(handles, raw_j);
    otherwise
        raw_ax_plot_general(handles, raw_j)
        ave_ax_plot_general(handles, raw_j);
end