~victor = SynthDef(\langspil, {
	var pups = SoundIn.ar(~pup_buses);
	var amp = Lag.ar(Amplitude.ar(pups), 3);
	var limit = \limit.kr(0.25, 3);
	var gain = AnalogIn.kr(0)*4.096/3.3;
	
	var signal = gain * LPF.ar(HPF.ar(Mix.ar(
        FreqShift.ar(pups, \shift.kr(-5e0, 0.3)/(1e2*amp+1)),
                ),30),700
        	);

	signal = Limiter.ar(signal, limit, 1e-3);

	~output.(signal);
    
}).play;