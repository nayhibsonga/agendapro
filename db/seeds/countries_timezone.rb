###############################
#       Pagina de datos       #
# http://www.timeanddate.com/ #
###############################

chile = Country.find_by(name: 'Chile')
if chile.present?
  chile.update(
    timezone_name: 'CLT',
    timezone_offset: -3
  )
  puts "Chile updated"
end

colombia = Country.find_by(name: 'Colombia')
if colombia.present?
  colombia.update(
    timezone_name: 'COT',
    timezone_offset: -5
  )
  puts "Colombia updated"
end

panama = Country.find_by(name: 'Panamá')
if panama.present?
  panama.update(
    timezone_name: 'EST',
    timezone_offset: -5
  )
  puts "Panamá updated"
end

venezuela = Country.find_by(name: 'Venezuela')
if venezuela.present?
  venezuela.update(
    timezone_name: 'VET',
    timezone_offset: -4.5
  )
  puts "Venezuela updated"
end

guatemala = Country.find_by(name: 'Guatemala')
if guatemala.present?
  guatemala.update(
    timezone_name: 'CST',
    timezone_offset: -6
  )
  puts "Guatemala updated"
end
