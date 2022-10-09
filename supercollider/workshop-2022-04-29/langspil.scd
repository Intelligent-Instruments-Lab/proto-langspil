(
n = 0;

this.executeFile("thor.scd"); ~thor.run(false);
this.executeFile("eydis.scd"); ~eydis.run(false);
this.executeFile("victor.scd"); ~victor.run(false);

~synths = [~thor, ~eydis, ~victor];
	
SynthDef(\click, {arg num_clicks;
	var signal = Impulse.ar(8);
	var env = EnvGen.kr(
		Env.perc(0, (num_clicks-0.5)/8, curve:\hold),
		doneAction: Done.freeSelf,
		gate: Impulse.kr(0));
	~output.(signal)
}).add;

~button_synth = SynthDef(\langspil, {
	var button = DigitalIn.kr(0);
	var trig = Trig1.kr(button, 0.2);
	// button.poll(5);
	SendReply.kr(trig, '/button');
}).play;

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