~b0 = Buffer.read(s, "/Users/quannham/Desktop/drive-download-20220516T055420Z-001/signal-2022-05-14-11-07-47-020.wav");

~b1 = Buffer.read(s, "/Users/quannham/Desktop/drive-download-20220516T055420Z-001/signal-2022-05-14-11-29-25-417.wav");

~b2 = Buffer.read(s, "/Users/quannham/Desktop/stuff/music/sounds/oklou-boiler-room/night1.wav");

~b3 = Buffer.read(s, "/Users/quannham/Desktop/stuff/music/sounds/oklou-boiler-room/night2.wav");

~b4 = Buffer.read(s, "/Users/quannham/Desktop/stuff/music/sounds/oklou-boiler-room/night3.wav");


~b5 = Buffer.read(s, "/Users/quannham/Desktop/stuff/music/sounds/oklou-boiler-room/night4.wav");


~b6 = Buffer.read(s, "/Users/quannham/Desktop/stuff/music/sounds/oklou-boiler-room/night5.wav");

~b0.query;

~b1.query;

SynthDef(\playbuf, {
	|amp=1, out=0, buf, pan|
	var sig;
	sig = PlayBuf.ar(1, buf);
	sig = sig * amp;
	Out.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

x = Synth.new(\playbuf, [\buf, ~b6.bufnum, \amp, 1]);

x.free;

s.freeAll;