require 'csv'
file = File.open("/Users/andydenenberg/Downloads/quotes.csv")
data = CSV.parse(file.read)
puts
data[1..data.length].each do |s|
	lc = s[4] ? s[4] : 0
	puts "Stock.create symbol: '#{s[0]}', last_price: #{s[1]}, last_change: #{lc} "
end

