// define+create synth which goes in the feedback loop
// defaults here are what will run on boot on the bela
~synth = SynthDef(\langspil, { arg
    shift_onsets = 7,
    shift_hz = -3e-2,
    shift_ratio = 0,
    hz_mix = 1,
    ratio_mix = 0,
    onsets_mix = 1,
    center_freqs = #[100, 200, 400],
    pitch_lag = 3,
    low_pass = 700,
    high_pass = 10,
    drive = 2e-1,
    thresh = 1e-2,
    comp_exponent = 1;

    var att = 3e-2;
    var rel = 1e-1;

    var pups = SoundIn.ar(~pup_buses) * drive;

    var filt = LPF.ar(pups, low_pass);

    var amps = Amplitude.ar(filt, att, rel);

    var chain = FFT(LocalBuf(128), pups);
    var onsets = Decay.ar(T2A.ar(Onsets.kr(chain,
        threshold: 0.5, odftype: \wphase,
        relaxtime: 1, floor: 0.1,
        mingap: 10, medianspan: 11,
    )), 3).pow(0.25);

    var comp = filt / ((amps/thresh).pow(comp_exponent) + thresh);

    var mcomp = Mix.ar(comp);

    var hz_shift = FreqShift.ar(mcomp, shift_hz);

    var onsets_shift = FreqShift.ar(Mix.ar(comp*onsets), shift_onsets + Mix.ar(onsets));

    var premix = (
        (hz_shift*hz_mix) +
        (onsets_shift* onsets_mix));

    var mix = HPF.ar(premix, high_pass) * \gain.kr(4, 3);

    // amps.poll(5, \amp);
    // onsets.poll(5, \onsets);

    Out.ar(~output_bus, mix);
}).play;