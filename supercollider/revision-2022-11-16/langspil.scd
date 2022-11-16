(
n = 0;

this.executeFile("thor.scd");
this.executeFile("eydis.scd");
this.executeFile("victor.scd");

~synths = [~thor, ~eydis, ~victor];

// SynthDef(\test, {
// 	~amp_output.(PinkNoise.ar())
// 	// Out.ar(0, PinkNoise.ar!8)
// }).play;

// balance the return signal and send to output
~return_synth = SynthDef(\return, {
	~amp_output.(SoundIn.ar(~return_bus))
}).play;
	
// haptic feedback synth for button
SynthDef(\click, {arg num_clicks;
	// var signal = Impulse.ar(8);	
	var signal = Blip.ar(8, 50)/2;	
	var env = EnvGen.kr(
		Env.perc(0, (num_clicks-0.5)/8, curve:\hold),
		doneAction: Done.freeSelf,
		gate: Impulse.kr(0));
	~amp_output.(signal)
}).add;

// convert button voltage to OSC
~button_synth = SynthDef(\langspil, {
	var button = DigitalIn.kr(0);
	var trig = Trig1.kr(button, 0.2);
	// button.poll(5);
	SendReply.kr(trig, '/button');
}).play;

// handle OSC from button
OSCdef(\button_def, {
	n = n%3 + 1;
	n.postln;
    Synth(\click, [\num_clicks, n]);
    ~synths.do{arg s; s!?(_.run(false))};
    case
    {n==1}{~thor!?(_.run)}
    {n==2}{~eydis!?(_.run)}
    {n==3}{~victor!?(_.run)}
}, "/button");

)