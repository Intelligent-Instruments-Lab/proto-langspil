~synth = SynthDef(\langspil, {

    var ins = SoundIn.ar(~pup_buses);
    var mix = [
        LPF.ar(ins[0] * LFNoise2.ar(0.5).range(0.1, 0.4), LFNoise2.ar(0.5).range(100, 1200)), // drone 1 
        LPF.ar(ins[1] * LFNoise2.ar(0.8).range(0.1, 0.6), LFNoise2.ar(0.5).range(100, 1200)), // drone 1
        LPF.ar(ins[2] * LFNoise2.ar(1).range(0.1, 0.4), LFNoise2.ar(0.5).range(100, 600)), // melody
        AllpassC.ar(ins[0], 0.3, 0.3, 1) * LFNoise2.ar(1.5).range(0.1, 0.2), 
        AllpassC.ar(ins[1], 0.3, 0.3, 1) * LFNoise2.ar(1.5).range(0.1, 0.2),
        FreeVerb.ar(ins[2], 0.5, 0.8) * 0.4
        ];

    Out.ar(~output_bus, mix.sum);

}).play;
