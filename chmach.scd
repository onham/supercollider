(
SynthDef(\ChMach, { | f=440, width = 0.5, modFreq = 1, aTime = 5, rTime = 5, filter = 2, filterQ = 0, pan = 0.5, detune=0, voice=0, sustain=0, rate=0 |

	var env = EnvGen.ar(Env([0.01,1,0.01],[aTime, rTime], 'exp'), doneAction:2);

	var primes = [2, 3, 5];
	var trig = Impulse.ar(30.0/primes/sustain);
	var phase = Phasor.kr(trig, 1.0/primes/ControlRate.ir);

	var r = primes/8;
	var i = TIRand.kr(0, 2, SinOsc.kr(sustain/8).dup(8));
	var d = Rand(1.6*i - detune, 1.7*i + detune).round(0.25);

    var input = SinOsc.ar(f * (1..primes.size)*[1+(detune/12),1-(detune/12)] / 2.0, phase)
	* LPF.ar(Vibrato.ar(f*r*d,rate), voice.linexp(0,2,30,18000));
	var theSine = SinOsc.ar(f);

    // Emulate six unsynched LFOs driving six comparators for a multi-pulse chorus
	var oscs = 6;
	var scaler = 1/oscs;

	var lfo1 = LFTri.ar(modFreq*1.51);
	var lfo2 = LFTri.ar(modFreq*1.11);
	var lfo3 = LFTri.ar(modFreq*1.31);
	var lfo4 = LFTri.ar(modFreq*0.71);
	var lfo5 = LFTri.ar(modFreq*0.61);
	var lfo6 = LFTri.ar(modFreq*0.51);

	var comp1 = input > lfo1;
	var comp2 = input > lfo2;
	var comp3 = input > lfo3;
	var comp4 = input > lfo4;
	var comp5 = input > lfo5;
	var comp6 = input > lfo6;

	var output = scaler*(comp1+comp2+comp3+comp4+comp5+comp6);

	//Add a hint of fundamental for body
    output = output+0.001*theSine;

	output = 0.01*LeakDC.ar(output, 0.9995);

	//Doubled Moog with overdrive.
	//Mmmm yeah.
	output = MoogFF.ar(output.tanh*20.0, (f*filter)+LFNoise2.ar(1, 400, 1), LFNoise2.ar(0,3.5, 0));
	output = MoogFF.ar(output*2, f*LFNoise2.kr(0.2, 6, 4), 0.5);

	output = env * output.tanh;

	Out.ar(0, Pan2.ar(output, pan));
	Out.ar(16, Pan2.ar(output, pan));
	Out.ar(18, Pan2.ar(output, pan));

}).add;
);
