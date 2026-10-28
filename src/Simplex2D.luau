--!strict
--!optimize 2
--!native

--	||	Yuri Yves 			||	--

----------------------------------
--	::	Constants			::	--
----------------------------------

const NOISE_SEED: number	= 0x98a2ff1b

const SQRT3: number			= math.sqrt(3)
const F2: number			= 0.5 * (SQRT3 - 1)
const G2: number			= (3 - SQRT3) / 6
const G2X2: number			= 2 * G2

----------------------------------
--	::	Buffers				::	--
----------------------------------

const PERMBUFFER: buffer	= buffer.create(0x200)

----------------------------------
--	::	Private				::	--
----------------------------------

const RNG: Random			= Random.new(NOISE_SEED)

for i = 0, 0xFF do
	const J: number			= RNG:NextInteger(0, i)
	const V: number			= buffer.readu8(PERMBUFFER, J)
	buffer.writeu8(PERMBUFFER, i, V)
	buffer.writeu8(PERMBUFFER, J, i)
end

buffer.copy(PERMBUFFER, 0x100, PERMBUFFER, 0, 0x100)

----------------------------------
--	::	Return				::	--
----------------------------------

return function(x: number, y: number): number	
	const SUMFACTOR		= (x + y) * F2
	
	const i, j			= (x + SUMFACTOR) // 1, (y + SUMFACTOR) // 1
	
	const RETFACTOR		= (i + j) * G2
	
	const x0, y0		= x - (i - RETFACTOR), y - (j - RETFACTOR)
	
	local i1, j1		= 0x0, 0x1
	
	if x0 > y0 then i1, j1	= 1, 0 end
	
	const x1, y1		= x0 - i1 + G2, y0 - j1 + G2
	const x2, y2		= x0 - 1 + G2X2, y0 - 1 + G2X2
	
	const GI, GJ		= i % 0x100, j % 0x100
	
	local N0, N1, N2	= 0, 0, 0
	const T0, T1, T2	= 0.5 - (x0 * x0 + y0 * y0), 0.5 - (x1 * x1 + y1 * y1), 0.5 - (x2 * x2 + y2 * y2)
	
	if T0 >= 0 then
		const Hash		= buffer.readu8(PERMBUFFER, GI + buffer.readu8(PERMBUFFER, GJ)) % 8
		local D: number	= 0
		if Hash < 4 then
			D			= (if Hash % 2 == 0 then x0 else -x0) + (if Hash < 2 then y0 else -y0)
		else
			const H4	= Hash - 4
			D			= if H4 < 2 then (if H4 == 0 then x0 else -x0) else (if H4 == 2 then y0 else -y0)
		end
		N0				= (T0 ^ 2) ^ 2 * D
	end
	
	if T1 >= 0 then
		const Hash		= buffer.readu8(PERMBUFFER, GI + i1 + buffer.readu8(PERMBUFFER, GJ + j1)) % 8
		local D: number	= 0
		if Hash < 4 then
			D			= (if Hash % 2 == 0 then x1 else -x1) + (if Hash < 2 then y1 else -y1)
		else
			const H4	= Hash - 4
			D			= if H4 < 2 then (if H4 == 0 then x1 else -x1) else (if H4 == 2 then y1 else -y1)
		end
		N1				= (T1 ^ 2) ^ 2 * D
	end
	
	if T2 >= 0 then
		const Hash		= buffer.readu8(PERMBUFFER, GI + 1 + buffer.readu8(PERMBUFFER, GJ + 1)) % 8
		local D: number	= 0
		if Hash < 4 then
			D			= (if Hash % 2 == 0 then x2 else -x2) + (if Hash < 2 then y2 else -y2)
		else
			const H4	= Hash - 4
			D			= if H4 < 2 then (if H4 == 0 then x2 else -x2) else (if H4 == 2 then y2 else -y2)
		end
		N2				= (T2 ^ 2) ^ 2 * D
	end
	
	return 0x46 * (N0 + N1 + N2)
end
