/*
This is an example startup file. You can load it from your startup file
(to be found in Platform.userAppSupportDir +/+ "startup.scd")
*/


// configure the sound server: here you could add hardware specific options
// see http://doc.sccode.org/Classes/ServerOptions.html

s.options.numBuffers = 1024 * 1024;
// increase this if you need to load more samples

s.options.memSize = 8192 * 64;
// increase this if you get "alloc failed" messages

s.options.maxNodes = 1024 * 32;
// increase this if you are getting drop outs and the message "too many nodes"

s.options.numOutputBusChannels = 16;
// set this to your hardware output channel size, if necessary

s.options.numInputBusChannels = 2;

s.options.inDevice_("MacBook Pro Microphone");

s.options.outDevice_("External Headphones");
// s.options.outDevice_("BlackHole 16ch");
// ServerOptions.outDevices;


// boot the server and start SuperDirt

s.waitForBoot {
	~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels

	~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)

    ~dirt.loadSoundFiles("/Users/quannham/Desktop/stuff/music/Sophie Samples/*");
	~dirt.loadSoundFiles("/Users/quannham/Desktop/stuff/music/sounds/breaks");


// drum machines ::

	~drumMachinesDir = PathName.new("/Users/quannham/Desktop/stuff/music/sounds/tidal-drum-machines-main/machines");

//All drum machines
	~machines = ~drumMachinesDir.folders;

//Selected drum machines
/*	~machines = ['Linn9000','RolandTR909','AlesisSR16'];
	~machines.do({arg m,i; ~machines[i]=(~drumMachinesDir+/+m)}) */

	(
		~machines.do({
			arg machine;
			var folders = machine.folders;
			postln("LOADING DRUM MACHINE: "++machine.folderName);
			folders.do({
				arg folder;
				~dirt.loadSoundFiles(folder.fullPath,namingFunction: { |x| x.basename.replace("-","")});
			});
		});
	);



// synths ::

SynthDef(\quan, {
		|out, sustain=1, freq=440, speed=1, begin=0, end=1, pan, accelerate, offset|
		var tone = Pulse.ar(freq);
		var env = Line.ar(begin,end,sustain, doneAction: Done.freeSelf);
		var outAudio = tone*env;
		OffsetOut.ar(out, [outAudio,outAudio]);
	}).add;

SynthDef(\quan2, {
		|out, sustain=1, freq=440, speed=1, begin=0, end=1, pan, accelerate, offset, gate=1.0, width=0.75, clamp=1, res=1|
		var line = Line.ar(begin,end,sustain, doneAction: Done.freeSelf);
		var env = Env.new(levels: [0, 1, 0.9, 0], times: [0.1, 0.5, 1], curve: [-5, 0, -5]);
		var volume = IEnvGen.ar(env, line);
		var tone = (Pulse.ar(freq, line)+Pulse.ar(freq*1.01, line)+Pulse.ar(freq*0.99, line))/3;
		var outAudio = RLPF.ar(tone*volume, 20000*clamp*volume, res);
		OffsetOut.ar(out, DirtPan.ar(outAudio, ~dirt.numChannels, pan, volume));
	}).add;


SynthDef(\ultrasaw, {
	|out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
	var line = Line.ar(begin, end, sustain, doneAction:2);
	var env = Env([0,1,1,0],[0.001,1,0.001]);
	var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
	var freqs = {Rand(-1,1)*(freq/60)}.dup(12);
	var sound = Saw.ar((freq+freqs));
	sound = sound + Saw.ar((freq+freqs)*2);
	sound = sound + Saw.ar((freq+freqs)*0.5);
	sound = sound + Saw.ar((freq+freqs)*4);
	sound = sound + Saw.ar((freq+freqs)*0.25);
	sound = LPF.ar(sound, freq*1.5);
	sound = RLPF.ar(sound, Clip.ar(envGen*freq*48, 0, 20000), 0.5);
	Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
}).add;

SynthDef(\donk, {
    |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset|
    var line = Line.ar(begin, end, sustain, doneAction:2);
    var env = Env([0, 1, 0], [0.01, 1], curve:-3);
    var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
    var modulator = (SinOsc.ar(freq*[1.0001,0.9999]*abs(speed))*2).tanh;
    var carrier = (SinOsc.ar((freq/4)+(modulator*1000*envGen))*0.8).tanh;
    var sound = DirtPan.ar(carrier, ~dirt.numChannels, pan, envGen);
    Out.ar(out, sound);
  }).add;


MIDIClient.init;
	~midiOut = MIDIOut.newByName("IAC Driver", "Bus 1");
	~midiOut2 = MIDIOut.newByName("IAC Driver", "Bus 2");

	~dirt.soundLibrary.addMIDI(\able, ~midiOut);
	~dirt.soundLibrary.addMIDI(\able2, ~midiOut2);


    // Initialize the TidalLooper
    ~looper = TidalLooper(~dirt);


	s.latency = 3.0;
	// increase this if you get "late" messages

	// s.sync;
	// optionally: wait for samples to be read

	// ~dirt.start(57120, [0, 2, 4, 6, 8, 10, 12]);
	~dirt.start(57120, 0 ! 12);
   // start listening on port 57120, create 2 busses each sending audio to channel 0

	// optional, needed for convenient access from sclang:
	(
		~d1 = ~dirt.orbits[0]; ~d2 = ~dirt.orbits[1]; ~d3 = ~dirt.orbits[2];
		~d4 = ~dirt.orbits[3]; ~d5 = ~dirt.orbits[4]; ~d6 = ~dirt.orbits[5];
		~d7 = ~dirt.orbits[6]; ~d8 = ~dirt.orbits[7]; ~d9 = ~dirt.orbits[8];
		~d10 = ~dirt.orbits[9]; ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];
	);
};


