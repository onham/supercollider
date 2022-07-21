(
SynthDef(\ChMach2, { | f=440, width = 0.5, modFreq = 1, aTime = 5, rTime = 5, filter = 1, filterQ = 0, pan = 0.5, detune=0, voice=0, sustain=0, rate=0, hz=440, amp=0.5, resonance=0 |

	var note=hz.cpsmidi;
	var input,input2,intro;

	var airports=[
		[5,7,4,2,0,12,7,5,7,4,2,0],
		[5,7,4,2,0,12,4,7,5,0],
		[-5,2,0,4,7,12,5,2,7,4,0,7,2,5,5,2,4,0],
		[7,7,2,4,4,4,2,0,7,0,0],
	];
	// these are some chords I made up that sound nice with it
	var planes=[
		[0,4,7,12],
		[4,7,11,16],
		[-3,0,4,7],
		[-3,0,5,9],
	];

	var env = EnvGen.ar(Env([0.01,1,0.01],[aTime, rTime], 'exp'), doneAction:2);

	var primes = [2, 3, 5];
	var trig = Impulse.ar(30.0/primes/sustain);
	var phase = Phasor.kr(trig, 1.0/primes/ControlRate.ir);

	var r = primes/8;
	var i = TIRand.kr(0, 2, SinOsc.kr(sustain/8).dup(8));
	var d = Rand(1.6*i - detune, 1.7*i + detune).round(0.25);

	var theSine = SinOsc.ar(f);

    // Emulate six unsynched LFOs driving six comparators for a multi-pulse chorus
	var oscs;
	var scaler;

	var lfo1;
	var lfo2;
	var lfo3;
	var lfo4;
	var lfo5;
	var lfo6;

	var comp1;
	var comp2;
	var comp3;
	var comp4;
	var comp5;
	var comp6;

	var output;

	var sum, temp, freq, freqmod, widthmod, outAudio;

	// setup the note change variables
	var seq,seqnote,notepulse,noterate;
	var planeseq,planenotes,planeenv,planenotechange;
	// piano stuff
	var noise, string, delaytime, lpf, noise_env,pianosnd,pianosnd2, damp_mul,pianohz,noise_hz;
	var noise_attack=0.002, noise_decay=0.06,
	tune_up = 1.0005, tune_down = 0.9996, string_decay=6.0,
	lpf_ratio=2.0, lpf_rq = 4.0, hpf_hz = 40, damp=0, damp_time=0.1;

	// chord and note changes (random)
	planenotechange=Crackle.kr(Rand(0.75,1.25))+Dust.kr(1/30);
	// planeenv=1-EnvGen.kr(Env.perc(3,10,0.9),planenotechange);
	planeenv=EnvGen.kr(Env([3,10,0.9],[aTime, rTime], 'exp'), gate:planenotechange, doneAction:2);
	planenotes=Demand.kr(TDelay.kr(planenotechange,3),0,Dxrand(planes,inf));
	notepulse=2;
	noterate=TChoose.kr(Dust.kr(notepulse)+Impulse.kr(0),[0.02,0.05,1,2,0.5,0.25,2]/2)*Rand(0.78,1.32);
	notepulse=Dust.kr(noterate);
	seq=Demand.kr(Dust.kr(0.1)+Impulse.kr(0),0,Dxrand(airports,inf));
	seqnote=Demand.kr(notepulse,0,Dseq(seq,inf));


		// bass note
	   input=SinOsc.ar((note-24).midicps,mul:SinOsc.kr(Rand(0.001,0.01)).range(0.05,0.15));
	    input=input+SinOsc.ar((note-12).midicps,mul:SinOsc.kr(Rand(0.001,0.01)).range(0.001,0.05));

    oscs = 6;
	scaler = 1/oscs;

	lfo1 = LFTri.ar(modFreq*1.51);
	lfo2 = LFTri.ar(modFreq*1.11);
	lfo3 = LFTri.ar(modFreq*1.31);
	lfo4 = LFTri.ar(modFreq*0.71);
	lfo5 = LFTri.ar(modFreq*0.61);
	lfo6 = LFTri.ar(modFreq*0.51);

	comp1 = input > lfo1;
	comp2 = input > lfo2;
	comp3 = input > lfo3;
	comp4 = input > lfo4;
	comp5 = input > lfo5;
	comp6 = input > lfo6;

	output = scaler*(comp1+comp2+comp3+comp4+comp5+comp6);

	//Add a hint of fundamental for body
    output = output+0.001*theSine;

	output = 0.01*LeakDC.ar(output, 0.9995);

	//Doubled Moog with overdrive.
	//Mmmm yeah.
	output = MoogFF.ar((output*2), (f*filter)+LFNoise2.ar(1, 400, 1), LFNoise2.ar(0,3.5, 0));
	output = MoogFF.ar(output*2, f*LFNoise2.kr(0.2, 6, 4), 0.5);

		// chords
	input=input+(planeenv*Mix.ar(Array.fill(8,{arg i;
		var snd;
		snd=output;
		snd=DelayC.ar(snd, rrand(0.01,0.03), LFNoise1.kr(Rand(5,10),0.01,0.02)/15 );
		Pan2.ar(snd,VarLag.kr(LFNoise0.kr(1/3),3,warp:\sine))/7
	})));


	input=MoogLadder.ar(input.tanh,LinExp.kr(VarLag.kr(LFNoise0.kr(1/6),6,warp:\sine),-1,1,hz*2,hz*60));
	input=input+(0.55*DynKlank.ar(`[[(note+planenotes[0]).midicps, (note+planenotes[1]).midicps, (note+planenotes[2]).midicps, (note+planenotes[3]).midicps], nil, [1, 1, 1, 1]], PinkNoise.ar([0.004, 0.004])));


	// mix between polyperc and piano sound randomly

	input=LPF.ar(input,(note+36).midicps);
	input=HPF.ar(input,120);
	input=input*EnvGen.ar(Env.new([0,0,1],[0.5,3]));
	input=FreeVerb.ar(input,0.45,2.0,0.5);
	input2=input;

	// reverb
	input = DelayN.ar(input2, 0.03, 0.03);
	input2 = CombN.ar(input2, 0.1, {Rand(0.01,0.099)}!32, 4);
	input2 = SplayAz.ar(2, input2);
	input2 = LPF.ar(input2, 1500);
	5.do{input2 = AllpassN.ar(input2, 0.1, {Rand(0.01,0.099)}!2, 3)};

	// output = Resonz.ar(output, f*r*d, 0.01 + voice.linexp(0,1,1e-3,1));

	output = HPF.ar(Limiter.ar(55 * GVerb.ar(input2, resonance.linexp(0,1,99,0.1),10) ), 30).sanitize;

	output = SplayAz.ar(primes.size, output.flat, center:LFNoise2.kr(sustain).range(0,primes.size-1));

	outAudio = RLPF.ar(output, 2400);

	output = outAudio*0.25 * env;

	Out.ar(0, Pan2.ar(output, pan));
	Out.ar(16, Pan2.ar(output, pan));
	Out.ar(18, Pan2.ar(output, pan));

}).add;
);
