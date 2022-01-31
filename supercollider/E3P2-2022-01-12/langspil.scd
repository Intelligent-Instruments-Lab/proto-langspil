// define+create synth which goes in the feedback loop
// defaults here are what will run on boot on the bela

~synth = SynthDef(\langspil, {

    var mix = Limiter.ar(
        FreqShift.ar(
            LPF.ar(HPF.ar(
                Mix.ar(SoundIn.ar(~pup_buses)),
                10),1500),
            \shift.kr(-3e-2, 0.3)
    ) * \drive.kr(0.7, 0.3), \limit.kr(2e-1, 3), 1e-3);

    Out.ar(~output_bus, mix);

    // Out.ar(~testbus, pups++[mix]);
}).play;