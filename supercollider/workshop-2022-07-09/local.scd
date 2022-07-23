// this file is for connecting to the Bela SC server and running sclang commands on e.g. a laptop

//connect to bela
(
Server.default = s = Server("belaServer", NetAddr("192.168.7.2", 57110));
s.options.maxLogins = 4; // should match the settings on the Bela
s.initTree;
s.startAliveThread;
)

//alternatively: local setup
(
~pup_buses = [0,1,2];
// output to transducer
~output = {arg signal;
	Out.ar(~output_bus, [signal, 0-signal])
};
};s.options.sampleRate = 48000;
s.options.blockSize = 16;
)

// s.waitForBoot({this.executeFile("langspil.scd")});

//===============================================

// control synth on the Bela from here:

~synth.set(\gain, 0)

~synth.free
