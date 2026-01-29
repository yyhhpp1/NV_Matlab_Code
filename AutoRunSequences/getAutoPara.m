function seq = getAutoPara()

%seq1
seq{1}.name = 'f_XY8_fdc';
seq{1}.interval = '4';
seq{1}.FROM1 = '1';
seq{1}.TO1 = '160';
seq{1}.SweepNPoints= '21';

seq{numel(seq)+1}.name = 'f_XY8_fdc';
seq{numel(seq)}.interval = '6';
seq{numel(seq)}.FROM1 = '1';
seq{numel(seq)}.TO1 = '120';
seq{numel(seq)}.SweepNPoints= '21';

seq{numel(seq)+1}.name = 'f_XY8_fdc';
seq{numel(seq)}.interval = '8';
seq{numel(seq)}.FROM1 = '1';
seq{numel(seq)}.TO1 = '100';
seq{numel(seq)}.SweepNPoints= '21';

seq{numel(seq)+1}.name = 'f_XY8_fdc';
seq{numel(seq)}.interval = '10';
seq{numel(seq)}.FROM1 = '1';
seq{numel(seq)}.TO1 = '80';
seq{numel(seq)}.SweepNPoints= '21';

seq{numel(seq)+1}.name = 'f_XY8_fdc';
seq{numel(seq)}.interval = '12';
seq{numel(seq)}.FROM1 = '1';
seq{numel(seq)}.TO1 = '60';
seq{numel(seq)}.SweepNPoints= '11';
end

