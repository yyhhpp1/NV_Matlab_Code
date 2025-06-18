classdef FPGA_AWG_Client < FPGA_ABS_Client
    
    properties
        use_fpga    % bool to determine weather any of the mehods can be called
    end
    
    methods
        function obj = FPGA_AWG_Client(handles)
            % Call the superclass constructor
            
            obj = obj@FPGA_ABS_Client();
            obj.use_fpga = get(handles.use_FPGA,'Value');
        end
        
        
        % Connect to the server
        function msg = connect(obj, host, port)
            if obj.use_fpga
                try
                    obj.client_socket = tcpclient(host, port, 'Timeout', 30);
                    obj.client_socket.ByteOrder = "big-endian";
                    obj.host = host;
                    obj.port = port;
                    msg = sprintf('Connected to server %s on port %d\n', host, port);
                    fprintf('Connected to server %s on port %d\n', host, port);
                catch ME
                    msg = sprintf('Error connecting to server: %s\n', ME.message); 
                    fprintf('Error connecting to server: %s\n', ME.message);
                end
            else 
                msg = 'User chooses to not use FPGA.';
            end
        end
        
        % Properly disconnect from the server
        function msg = disconnect(obj)
            if obj.use_fpga
                if ~isempty(obj.client_socket)
                    delete(obj.client_socket); % Explicitly delete the tcpclient object
                    obj.client_socket = [];
                    msg = sprintf('Disconnected from server at %s on port %d\n', obj.host, obj.port);
                    fprintf('Disconnected from server at %s on port %d\n', obj.host, obj.port);
                end
            else
                msg = 'User chooses to not use FPGA.';
            end
        end       
        
        
        
        % Upload waveform configuration file to the server
        function msg = upload_waveform_cfg(obj, wf_cfg_path, name)
            if obj.use_fpga
                if isfile(wf_cfg_path)
                    obj.send_string("UPLOAD_WAVEFORM_CFG");
                    obj.send_string(name);
                    obj.send_file(wf_cfg_path);
                    msg = obj.receive_server_ack();
                else
                    fprintf('%s does not exist!\n', wf_cfg_path);
                    msg = sprintf('%s does not exist!\n', wf_cfg_path);
                end
            end
        end
        
        % Upload envelope data file (either i or q data)
        function msg = upload_envelope_data(obj, data_path, name)
            if obj.use_fpga
                if isfile(data_path)
                    obj.send_string("UPLOAD_ENVELOPE_DATA");
                    obj.send_string(name);
                    obj.send_file(data_path);
                    msg = obj.receive_server_ack();
                else
                    fprintf('%s does not exist!\n', data_path);
                    msg = sprintf('%s does not exist!\n', data_path);
                end
            end
        end
        
        % Upload program configuration file to the server
        function msg = upload_program(obj, prog_cfg_path, name)
            if obj.use_fpga
                if isfile(prog_cfg_path)
                    obj.send_string("UPLOAD_PROGRAM");
                    obj.send_string(name);
                    obj.send_file(prog_cfg_path);
                    msg = obj.receive_server_ack();
                else
                    fprintf('%s does not exist!\n', prog_cfg_path);
                    msg = sprintf('%s does not exist!\n', prog_cfg_path);
                end
            end
        end
        
        % Delete waveform configuration from the server
        function msg = delete_waveform_cfg(obj, name)
            if obj.use_fpga
                obj.send_string("DELETE_WAVEFORM_CFG");
                obj.send_string(name);
                msg = obj.receive_server_ack();
            end
        end
        
        % Delete ALL waveform configuration from the server
        function msg = delete_all_waveform_cfg(obj)
            if obj.use_fpga
                obj.send_string("DELETE_ALL_WAVEFORM_CFG");
                msg = obj.receive_server_ack();
            end
        end
        
        % Delete envelope data from the server
        function msg = delete_envelope_data(obj, name)
            if obj.use_fpga
                obj.send_string("DELETE_ENVELOPE_DATA");
                obj.send_string(name);
                msg = obj.receive_server_ack();
            end
        end
        
        function msg = delete_all_envelope_data(obj)
            if obj.use_fpga
                obj.send_string("DELETE_ALL_ENVELOPE_DATA");
                msg = obj.receive_server_ack();
            end
        end
        
        % Delete program from the server
        function msg = delete_program(obj, name)
            if obj.use_fpga
                obj.send_string("DELETE_PROGRAM");
                obj.send_string(name);
                msg = obj.receive_server_ack();
            end
        end
        
        % Delete program from the server
        function msg = delete_all_programs(obj)
            if obj.use_fpga
                obj.send_string("DELETE_ALL_PROGRAMS");
                msg = obj.receive_server_ack();
            end
        end
               
        % Retrieve the list of waveforms from the server
        function msg = get_waveform_lst(obj)
            if obj.use_fpga
                obj.send_string("GET_WAVEFORM_LIST");
                msg = obj.receive_server_ack();
            end
        end
        
        % Retrieve the list of envelope data from the server
        function msg = get_envelope_lst(obj)
            if obj.use_fpga
                obj.send_string("GET_ENVELOPE_LIST");
                msg= obj.receive_server_ack();
            end
        end
        
        % Retrieve the list of programs from the server
        function msg = get_program_lst(obj)
            if obj.use_fpga
                obj.send_string("GET_PROGRAM_LIST");
                msg = obj.receive_server_ack();
            end
        end
        
        % Get the state of the server
        function msg = get_state(obj)
            if obj.use_fpga
                obj.send_string("GET_STATE");
                msg = obj.receive_server_ack();
            end
        end
        
        % Set the trigger mode on the server
        function msg = set_trigger_mode(obj, trig_mode)
            if obj.use_fpga
                obj.send_string("SET_TRIGGER_MODE");
                obj.send_string(trig_mode);
                msg = obj.receive_server_ack();
            end
        end
        
        % Start a specific program on the server
        function msg = start_program(obj, name)
            if obj.use_fpga
                obj.send_string("START_PROGRAM");
                obj.send_string(name);
                msg = obj.receive_server_ack();
            end
        end
        
        % Stop the currently running program on the server
        function msg = stop_program(obj)
            if obj.use_fpga
                obj.send_string("STOP_PROGRAM");
                msg = obj.receive_server_ack();
            end
        end
    end
end
