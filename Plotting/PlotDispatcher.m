function PlotDispatcher(plotting_method, handles, raw_j)

switch plotting_method
    case 'ESR'
        ave_ax_plot_esr(handles, raw_j);
    case 'Rabi'
        raw_ax_plot_general(handles, raw_j)
        ave_ax_plot_rabi(handles, raw_j);
    otherwise
        raw_ax_plot_general(handles, raw_j)
        ave_ax_plot_rabi(handles, raw_j);
end