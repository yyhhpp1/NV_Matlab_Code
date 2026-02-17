# Instruction For Agent

## Current experimental flow

    - Run seuqence according to the order in cfg:
        - for example {'Presets', 'ESR', 'Rabi', 'ESR2', 'Rabi2', 'T00', 'T11'}
    - The behvaior of each sequence is mainly defined in cfg but with the ability to do futher customization in the T1_SemiAuto_Program.m function.

## What I want to add

    - On top of the current experimental flow, add another layer of automation
    - Context: in the NV experiment, I want to measure the T1 behvaior at different B field and temperature. At a specific B and T, I would run the sequences which has already be implemented semi automatically in the current experiemtn flow (ESR to find frequence, Rabi to find pi time, T1 sequence to find single and double quantum relaxation rates). 
    - The other layer of automation would be to change the B and T according to some schedule then run a the list of sequences to find the T1 behavior. 
    - For example:
        For a list of (Ti, Bi)
            1. Set the temperature to Ti
            2. Set the B field to Bi
            3. Run the experimental flow to find T1 behavior
    - How to set temperature and B field SAFELY is not fully implemented yet and will be done in a later instruction. For now, assume there are functions <set_temperature> and <set_magnetic_fields>.

## Specific intructions to agent

    - On top of the AutoRunSequence_v2, add another layer of automation as outlined in this file.
