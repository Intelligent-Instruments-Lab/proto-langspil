// depends on FluCoMa.
// there is currently not a quark, it must be installed into the
// SC extensions directory:
// https://github.com/flucoma/flucoma-sc/releases
Platform.userExtensionDir;

(
//details of your audio interface here
s.options.numInputBusChannels = 5;
s.options.numOutputBusChannels = 1;

// stereo room + 3 pickups + out to tranducer
~room_buses = [3,4];
~pup_buses = [0,1,2]; 
~output_bus = 0;

s.options.blockSize = 4;
s.options.sampleRate = 96000;

s.boot;

MIDIIn.connectAll;
)

s.quit

MIDIFunc.trace


(
~rec_channels = 1 + ~room_buses.size + ~pup_buses.size;
~record_bus = Bus.audio(s, ~rec_channels);

~monitor_mappings = (
    (~room_buses ++ ~pup_buses) + s.options.numOutputBusChannels
    ++ [~output_bus]).collect{
    arg bus, idx; bus -> (idx + ~record_bus.index)
};
~monitors = ~monitor_mappings.collect{
    arg evt; Monitor.new.play(evt.key, 1, evt.value)}
)

s.record(bus:~record_bus, numChannels:~rec_channels);
s.stopRecording

(
~fsaa  = { arg in, freq=0.0, phase=0.0, mul=1.0, add=0.0;
    var hcutoff = (SampleRate.ir/2 - freq.max(0))/2;
    var lcutoff = ((0.0 - freq.min(0))*2).max(20);
    FreqShift.ar(
        BHiPass4.ar(BLowPass4.ar(in, hcutoff), lcutoff),
        freq, phase, mul, add);
};

~synth = SynthDef(\langspil_combined, { arg
    shift_onsets = 7,
    shift_hz = 0,
    shift_ratio = 0,
    hz_mix = 0,
    ratio_mix = 0,
    onsets_mix = 1,
    center_freqs = #[100, 200, 400],
    pitch_lag = 3,
    low_pass = 1500,
    drive = 1,
    thresh = 1e-2,
    gain = 0,
    comp_exponent = 1;

    var att = 3e-2;
    var rel = 1e-1;

    var pup1 = SoundIn.ar(~pup_buses[0]);
    var pup2 = SoundIn.ar(~pup_buses[1]);
    var pup3 = SoundIn.ar(~pup_buses[2]);

    var pups = [pup1, pup2/4, pup3] * drive;
    var f0_raw = Pitch.kr(pups, 200, 30, 3000,
        clar:1, ampThreshold:1e-4, execFreq:200).flop;
    var f0s = Lag.ar(K2A.ar(f0_raw[0].log), pitch_lag).exp;

    var purity = f0_raw[1];

    var filt = LPF.ar(pups, low_pass);

    var amps = Amplitude.ar(pups, att, rel);

    var onsets = Decay.ar(FluidAmpSlice.ar(pups,
        fastRampUp: 30, fastRampDown: 9600, slowRampUp: 19200,
        slowRampDown: 19200, onThreshold: 15, offThreshold: 3,
        floor: -70, minSliceLength: 960, highPassFreq: 100
    ), 3).pow(0.25);

    var comp = filt / ((amps/thresh).pow(comp_exponent) + thresh) * 3e-2;

    var ratio_shift = ~fsaa.(comp,
        shift_ratio*f0s
        *(f0s - center_freqs / center_freqs * 10).clip(-1, 1));

    var hz_shift = FreqShift.ar(comp, shift_hz);

    var up_shift = FreqShift.ar(comp, shift_onsets*onsets);
    var down_shift = FreqShift.ar(comp, 0-shift_onsets*2.log*onsets);
    var onsets_shift = up_shift + down_shift / 2 * onsets;

    var premix = (
        (ratio_shift*ratio_mix) +
        (hz_shift*hz_mix) +
        (onsets_shift* onsets_mix));

    var mix = HPF.ar(Mix.ar(premix), 20) * gain;

    // f0s.poll(5, \f0);
    // purity.poll(5, \purity);
    // amps.poll(5, \amp);
    // onsets.poll(5, \onsets);

    Out.ar(~output_bus, mix);
}).play;
)


~synth.set(\gain, 0)

(
//S1
// no feedback
// reacts to playing
~synth.set(
    \shift_onsets, 7,
    \shift_hz, 0,
    \shift_ratio, 0,
    \hz_mix, 0,
    \ratio_mix, 0,
    \onsets_mix, 1,
    \pitch_lag, 1,
    \drive, 2,
    \gain, 6,
    \thresh, 1e-1,
    \comp_exponent, 1,
    \low_pass, 5000
))

(
//S2
//transparent feedback
~synth.set(
    \shift_onsets, 5,
    \shift_hz, 0,
    \shift_ratio, 0,
    \hz_mix, 1,
    \ratio_mix, 0,
    \onsets_mix, 0.5,
    \pitch_lag, 3,
    \drive, 1,
    \gain, 6,
    \thresh, 1e-1,
    \comp_exponent, 0.7,
    \low_pass, 1500
)
)

(
//S3
// plays itself but can be influenced and controlled to a degree
~synth.set(
    \shift_onsets, 3,
    \shift_hz, -1e-2,
    \shift_ratio, 1/2,
    \hz_mix, 0.5,
    \ratio_mix, 0.5,
    \onsets_mix, 0.2,
    \pitch_lag, 3,
    \drive, 1,
    \gain, 6,
    \thresh, 3e-2,
    \comp_exponent, 1,
    \low_pass, 1500
))

(
//S4
//when untouched, plays itself
//when strings are muted, becomes uncontrollable
//when strings are plucked, goes dead
~synth.set(
    \shift_hz, 1e-1,
    \shift_ratio, 1/3,
    \hz_mix, 0.5,
    \ratio_mix, 0.5,
    \onsets_mix, 0,
    \pitch_lag, 0.1,
    \drive, 1e1,
    \gain, 6,
    \thresh, 1e-2,
    \comp_exponent, 2,
    \low_pass, 1500
))