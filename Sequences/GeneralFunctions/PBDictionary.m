function pbn = PBDictionary(type)
switch type
    case 'ctr0'
        pbn=0;
%     case 'AWGTrig2'
%         pbn=1;
%     case 'AWGTrig' 
%         pbn=0;
    case 'dummy1'
        pbn=8;
    case 'GreenAOM'    % Green AOM
        pbn=7;
        %pbn=1;
    case 'RedAOM' 
        pbn=4;
    case 'MWSwitch'
        pbn=2;
    case '+X'
        pbn=5;
    case '-X'
        pbn=6;        
    case '+Y'
        pbn=7;
    case '-Y'
        pbn=15;
    case 'PD'
        pbn=14;
    case 'MWSwitch2' %changed from OrangeAOM on 6/19/2025 Haopu
        pbn=3;
    case 'MWSwitch3' 
        pbn=1;
%     case 'OrangeAOM' %changed from OrangeAOM on 6/19/2025 Haopu
%         pbn=10;
%     case 'TimeTaggerTrig'
%         pbn=9;
end