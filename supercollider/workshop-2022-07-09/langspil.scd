// run this block to redfine the synth
(
~synth.free;
~synth = SynthDef(\langspil, { arg
    // add new control parameters here
    // these are the default values when you run the synth
    // and can be set individually with a line of code (see bottom of file)
    limit = 0.25,
    low_pass = 1200,
    high_pass = 10,
    mod_index = 0.0005,
    drive = 1,
    delay_time = 0.3,
    decay_time = 10;

    // leave this alone -- this is gain from the pedal
    var gain = AnalogIn.kr(0)*4.096/3.3 * drive;
    // leave this alone -- sound i nfrom the pickups
    // this makes an array of 3 signals
    var pups = SoundIn.ar(~pup_buses);

    /////////
    // define synth here

    // var roll = [pups[2], pups[1], pups[0]];
    var roll = [pups[1], pups[2], pups[0]];

    // var roll_mod = LPF.ar(roll.abs, 30);
    var roll_mod = Limiter.ar(LPF.ar(roll, 100)*30)+1;

    // var mod = pups * roll + (pups/30);
    var mod = DelayC.ar(pups, 0.5, (roll_mod)*mod_index);

    var filt = LPF.ar(mod, low_pass);

    var mix = gain * HPF.ar(filt, high_pass);

    mix = mix + CombC.ar(mix, 10, delay_time, decay_time);


    // leave this alone -- sends "mix" to the output and though a limiter
    mix = Limiter.ar(mix, limit, 0.001);
    ~output.(mix);
}).play;
)


// then you can build presets in a block like this:
(
~synth.set(\low_pass, 900);
~synth.set(\mod_index, 0.001);
~synth.set(\drive, 0.1);
~synth.set(\limit, 0.25);
~synth.set(\delay_time, 0.3);
)


