banks = [[1, "Banco Chile - CityBank"],
[12, "Banco Del Estado"],
[14, "Banco Scotia Sud Americano"],
[27, "Corpbanca"],
[28, "Banco Bice"],
[37, "Banco Santander Santiago"],
[39, "Banco Itau"],
[16, "Banco Credito"],
[46, "ABM Amor Bank (Chile)"],
[49, "Banco Security"],
[51, "Banco Falabella"],
[504, "Banco Bilbao Vizcaya Argentaria, Chile"],
[507, "Banco del Desarrollo"],
[0, "Otro"]
]

banks.each do |arr|

	bank = Bank.new
	bank.code = arr[0]
	bank.name = arr[1]
	bank.save
	puts "Bank saved"

end