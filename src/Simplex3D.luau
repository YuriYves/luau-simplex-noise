--!strict
--!optimize 2
--!native

--	||	Yuri Yves 			||	--

----------------------------------
--	::	Buffers				::	--
----------------------------------

const PERMBUFFER: buffer	= buffer.create(0x200)

----------------------------------
--	::	Return				::	--
----------------------------------

return function(x: number, y: number, z: number): number
	const RNG: Random		= Random.new(z)
	
	for i = 0, 0xFF do
		const J: number		= RNG:NextInteger(0, i)
		const V: number		= buffer.readu8(PERMBUFFER, J)
		buffer.writeu8(PERMBUFFER, i, V)
		buffer.writeu8(PERMBUFFER, J, i)
	end
	
	buffer.copy(PERMBUFFER, 0x100, PERMBUFFER, 0, 0x100)
	
	const SUMFACTOR		= (x + y + z) * (1 / 3)
	
	const i, j, k		= (x + SUMFACTOR) // 1, (y + SUMFACTOR) // 1, (z + SUMFACTOR) // 1
	
	const RETFACTOR		= (i + j + k) * (1 / 6)
	
	const x0, y0, z0	= x - (i - RETFACTOR), y - (j - RETFACTOR), z - (k - RETFACTOR)
	
	local i1, j1, k1	= 0x0, 0x0, 0x0
	local i2, j2, k2	= 0x0, 0x0, 0x0
	
	if x0 >= y0 then
		i2				= 1
		if y0 >= z0 then
			i1, j2		= 1, 1
		elseif x0 >= z0 then
			i1, k2		= 1, 1
		else
			k1, k2		= 1, 1
		end
	else
		j2				= 1
		if y0 < z0 then
			k1, k2		= 1, 1
		elseif x0 < z0 then
			j1, k2		= 1, 1
		else
			j1, i2		= 1, 1
		end
	end
	
	const x1, y1, z1	= x0 - i1 + (1 / 6), y0 - j1 + (1 / 6), z0 - k1 + (1 / 6)
	const x2, y2, z2	= x0 - i2 + 1 / 3, y0 - j2 + 1 / 3, z0 - k2 + 1 / 3
	const x3, y3, z3	= x0 - 0.5, y0 - 0.5, z0 - 0.5
	
	const GI, GJ, GK	= i % 0x100, j % 0x100, k % 0x100
	
	local N0, N1		= 0, 0
	local N2, N3		= 0, 0
	
	const T0, T1		= 0.6 - (x0 * x0 + y0 * y0 + z0 * z0), 0.6 - (x1 * x1 + y1 * y1 + z1 * z1)
	const T2, T3		= 0.6 - (x2 * x2 + y2 * y2 + z2 * z2), 0.6 - (x3 * x3 + y3 * y3 + z3 * z3)
	
	if T0 >= 0 then
		const Hash		= buffer.readu8(PERMBUFFER, GI + buffer.readu8(PERMBUFFER, GJ + buffer.readu8(PERMBUFFER, GK))) % 16
		const U, V		= if Hash < 8 then x0 else y0, if Hash < 4 then y0 else z0
		N0				= (T0 * T0) ^ 2 * ( (if Hash % 2 == 0 then U else -U) + (if Hash % 4 < 2 then V else -V) )
	end
	
	if T1 >= 0 then
		const Hash		= buffer.readu8(PERMBUFFER, GI + i1 + buffer.readu8(PERMBUFFER, GJ + j1 + buffer.readu8(PERMBUFFER, GK + k1))) % 16
		const U, V		= if Hash < 8 then x1 else y1, if Hash < 4 then y1 else z1
		N1				= (T1 * T1) ^ 2 * ( (if Hash % 2 == 0 then U else -U) + (if Hash % 4 < 2 then V else -V) )
	end
	
	if T2 >= 0 then
		const Hash		= buffer.readu8(PERMBUFFER, GI + i2 + buffer.readu8(PERMBUFFER, GJ + j2 + buffer.readu8(PERMBUFFER, GK + k2))) % 16
		const U, V		= if Hash < 8 then x2 else y2, if Hash < 4 then y2 else z2
		N2				= (T2 * T2) ^ 2 * ( (if Hash % 2 == 0 then U else -U) + (if Hash % 4 < 2 then V else -V) )
	end
	
	if T3 >= 0 then
		const Hash		= buffer.readu8(PERMBUFFER, GI + 1 + buffer.readu8(PERMBUFFER, GJ + 1 + buffer.readu8(PERMBUFFER, GK + 1))) % 16
		const U, V		= if Hash < 8 then x3 else y3, if Hash < 4 then y3 else z3
		N3				= (T3 * T3) ^ 2 * ( (if Hash % 2 == 0 then U else -U) + (if Hash % 4 < 2 then V else -V) )
	end
		
	return 0x20 * (N0 + N1 + N2 + N3)
end
