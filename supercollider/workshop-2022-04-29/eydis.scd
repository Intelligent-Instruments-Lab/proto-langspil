// define+create synth which goes in the feedback loop
~eydis = SynthDef(\langspil, { arg
    shift_onsets = 5,//7,
    shift_hz = -3e-2,
    hz_mix = 1,
    onsets_mix = 1,
    onsets_floor = 0.02,//0.1,
    low_pass = 1200,
    high_pass = 10,
    drive = 4,
    // thresh = 2e-2,//1e-2,
    // comp_exponent = 1,
    limit = 0.25;
    var gain = AnalogIn.kr(0);

    var att = 3e-2;
    var rel = 1e-1;

    var pups = SoundIn.ar(~pup_buses);// * drive;

    var filt = LPF.ar(pups, low_pass);

    var amps = Amplitude.ar(filt, att, rel);

    var chain = FFT(LocalBuf(128), pups);
    var onsets = Decay.ar(T2A.ar(Onsets.kr(chain,
        threshold: 0.5, odftype: \wphase,
        relaxtime: 1, floor: onsets_floor,
        mingap: 10, medianspan: 11,
    )), 3).pow(0.25);

    // var comp = filt / ((amps/thresh).pow(comp_exponent) + thresh);
    var comp = Limiter.ar(filt*drive, limit, 0.001);

    var mcomp = Mix.ar(comp);

    /* var ratio_shift = ~fsaa.(comp,
    shift_ratio*f0s
    *(f0s - center_freqs / center_freqs * 10).clip(-1, 1));*/

    var hz_shift = FreqShift.ar(mcomp, shift_hz);

    /* var up_shift = FreqShift.ar(comp, shift_onsets*onsets);
    var down_shift = FreqShift.ar(comp, 0-shift_onsets*2.log*onsets);
    var onsets_shift = up_shift + down_shift / 2 * onsets;*/

    // var onsets_shift = FreqShift.ar(Mix.ar(comp*onsets), shift_onsets * (1+Mix.ar(amps)));
    // var onsets_shift = Mix.ar(FreqShift.ar(comp*onsets, shift_onsets / (amps*3000+1)));
    var onsets_shift = Mix.ar(FreqShift.ar(comp*onsets, shift_onsets * (2-onsets)));


    // var premix = hz_shift;
    var premix = (
        //     (ratio_shift*ratio_mix) +
        (hz_shift*hz_mix) +
        (onsets_shift* onsets_mix));

    // var mix = HPF.ar(Mix.ar(premix), 20) * \gain.kr(1, 3);
    var mix = HPF.ar(premix, high_pass); //* \gain.kr(4, 3);

    mix = Limiter.ar(gain*mix, limit, 0.001);

    // f0s.poll(5, \f0);
    // purity.poll(5, \purity);
    // amps.poll(5, \amp);
    // onsets.poll(5, \onsets);

    ~output.(mix);
}).play;