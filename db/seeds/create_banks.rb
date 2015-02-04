banks = [[code: 1, name: "Banco Chile - CityBank"],
[code: 12, name: "Banco Del Estado"],
[code: 14, name: "Banco Scotia Sud Americano"],
[code: 27, name: "Corpbanca"],
[code: 28, name: "Banco Bice"],
[code: 37, name: "Banco Santander Santiago"],
[code: 39, name: "Banco Itau"],
[code: 16, name: "Banco Credito"],
[code: 46, name: "ABM Amor Bank (Chile)"],
[code: 49, name: "Banco Security"],
[code: 51, name: "Banco Falabella"],
[code: 504, name: "Banco Bilbao Vizcaya Argentaria, Chile"],
[code: 507, name: "Banco del Desarrollo"],
[code: 0, name: "Otro"]
]

banks.each do |arr|
	bank = Bank.new
	bank.code = arr[0]
	bank.name = arr[1]
	bank.save
	puts "Bank saved"
end