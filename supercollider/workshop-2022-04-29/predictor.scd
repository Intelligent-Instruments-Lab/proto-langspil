~victor = SynthDef(\langspil, {
	var src = Mix.ar(SoundIn.ar(~pup_buses));
	var gain = AnalogIn.kr(0)*4.096/3.3;
	var limit = \limit.kr(2e-1, 3);

    var lr = \lr.kr(1e-3);
    var reg = \reg.kr(1e-5);
    var halluc = \halluc.kr(0, 0.1);
    
    var signal, pred, resid, spars, idx;
    # pred, resid, spars, idx = Predictor.ar(src, K2A.ar(lr), K2A.ar(reg), K2A.ar(halluc));
	signal = Limiter.ar(resid*gain, limit, 1e-3);
	
	~output.(signal);
}).play.run(false);