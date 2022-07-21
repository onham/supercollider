{   var dif, sig, f, curveA, curveB, filterA, filterB, local, local0, local1, gendy, inA, inB, pink;
	gendy =  Gendy1.kr(0.1)!2;
	pink = PinkNoise.kr()!2;
	local = LocalIn.kr(2, 1);
	local0 = local[0];
	local1 = local[1];
	f = 0.01;
	curveA = 0.6;
	curveB = 0.4;
	dif = ( Blip.ar(f, 11)-(13*Blip.ar(f, 11, 1/13)) );
	sig = Limiter.ar(8999999 * LeakDC.ar(dif));
	sig = BandSplitter2.ar(sig, 6000 * ((local0).range(0.01, 2)) );
	inA = sig[0];
	inB = sig[1];
	inB = DelayN.ar(inB, 0.5, gendy.range(0, 0.5));
	LocalOut.kr(sig);
	//twinpeak ala hordijk
	filterA = SVF.ar(
		(inA+(curveA *inB)),
		10000 * ((5*local0).range(0.01, 2)) ,
		0.3 * pink.lag(0.5).range(1, 1.1)
	);
	filterB = SVF.ar(
		(-1)*(inB+(curveB * inA)),
		800 * ((4*local1).range(0.01, 2)),
		0.9 * pink.lag(0.5).range(1, 1.1)
	);
	sig = LeakDC.ar(Limiter.ar((filterA+filterB)/2.5));
	}.play;


{(Crackle.ar(SinOsc.kr(0.02).range(0.4, 2))!2/30)}.play;

~phi = (5.sqrt + 1) /2;

{{(Crackle.ar(SinOsc.kr(0.02*(5.sqrt + 1)).range(0.4, 2))/20)}!2}.play;

s.freeAll;