// define+create synth which goes in the feedback loop
// defaults here are what will run on boot on the bela
~synth = SynthDef(\langspil, { arg
    shift_onsets = 5,//7,
    shift_hz = -3e-2,
    hz_mix = 1,
    onsets_mix = 1,
    onsets_floor = 0.02,//0.1,
    low_pass = 1200,
    high_pass = 10,
    drive = 4,
    limit = 0.25;

    var att = 3e-2;
    var rel = 1e-1;

    var pups = SoundIn.ar(~pup_buses);

    var filt = LPF.ar(pups, low_pass);

    var amps = Amplitude.ar(filt, att, rel);

    var chain = FFT(LocalBuf(128), pups);
    var onsets = Decay.ar(T2A.ar(Onsets.kr(chain,
        threshold: 0.5, odftype: \wphase,
        relaxtime: 1, floor: onsets_floor,
        mingap: 10, medianspan: 11,
    )), 3).pow(0.25);

    var comp = Limiter.ar(filt*drive, limit, 0.001);

    var mcomp = Mix.ar(comp);

    var hz_shift = FreqShift.ar(mcomp, shift_hz);

    var onsets_shift = Mix.ar(FreqShift.ar(comp*onsets, shift_onsets * (2-onsets)));

    var premix = (
        (hz_shift*hz_mix) +
        (onsets_shift* onsets_mix));

    var mix = HPF.ar(premix, high_pass); 

    mix = Limiter.ar(mix, limit, 0.001);

    // amps.poll(5, \amp);
    // onsets.poll(5, \onsets);

    Out.ar(~output_bus, mix);
}).play;