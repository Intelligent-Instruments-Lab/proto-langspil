~thor = SynthDef(\thor, {

	var ins = SoundIn.ar(~pup_buses);
	var gain = 1;//2*((AnalogIn.kr(0)*4.096/3.3).pow(0.5)-0.01).max(0);
	var mix = [
		LPF.ar(ins[0] * LFNoise2.ar(0.5).range(0.1, 0.4), LFNoise2.ar(0.5).range(100, 1200)), // drone 1 
		LPF.ar(ins[1] * LFNoise2.ar(0.8).range(0.1, 0.6), LFNoise2.ar(0.5).range(100, 1200)), // drone 1
		LPF.ar(ins[2] * LFNoise2.ar(1).range(0.1, 0.4), LFNoise2.ar(0.5).range(100, 600)), // melody
		AllpassC.ar(ins[0], 0.3, 0.3, 1) * LFNoise2.ar(1.5).range(0.1, 0.2), 
		AllpassC.ar(ins[1], 0.3, 0.3, 1) * LFNoise2.ar(1.5).range(0.1, 0.2),
		FreeVerb.ar(ins[2], 0.5, 0.8) * 0.4
		];
	var signal = gain*mix.sum;
	
	signal = LPF.ar(signal.softclip, 2000);
	
	signal = Limiter.ar(signal, 0.25, 0.001);
    
    ~output.(signal);

}).play.run(false);