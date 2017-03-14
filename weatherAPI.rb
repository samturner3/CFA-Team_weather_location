
require 'forecast_io'
require 'google_maps_service'
require 'terminal-table'

ForecastIO.api_key = '200241aa2eca57d1b162699565137181'
# Setup API keys
@gmaps = GoogleMapsService::Client.new(key: 'AIzaSyDtMxX6mnJqcKsqyrHqTXPMCcOMTfmXqAU')
@currentlyIn = nil

@cities = { "Sydney" => [-33.8688,151.2093],
  "Melbourne" => [-37.8136,144.9631],
  "Perth" => [-31.9505,115.8605],
  "Cairns" => [-16.9186,145.7781],
  "Adelaide" => [-34.9285,138.6007],
  "Brisbane" => [-27.4698,153.0251],
  "Canberra" => [-35.2809,149.1300],
  "Gold Coast" => [-28.0167,153.4000]
 }

####Classes#####

class CurrentLocation
  def initialize() #input lat and long, output current temp
    # @userInput = userInput
    # @formattedAddress = formattedAddress
  end
  def askLocation()
    puts "Hi, please enter your current location within Australia"
    userInput = gets.chomp
  end
  attr_accessor :userInput

end

class GoogleAddress #Input: user entered location. Output: google formatted address (hash)
    def initialize()
      # @locationInput = locationInput
      @locationOutput = locationOutput
    end

    attr_accessor :locationInput, :locationOutput
end

class CurrentTemp
  def initialize() #input lat and long, output current temp
    # @lat = lat
    # @long = long
  end
  def getCurrentTemp(hash)

      lat_long = extractLatLong(hash)
      puts "Getting Forcast ..."
      forecast = ForecastIO.forecast(lat_long[0],lat_long[1])
      temp = forecast[:currently][:temperature]
      celtemp = (5*(Float(temp) - 32))/9 #return temp in C
      puts "Caculating Current Temp ..."
      return '%.2f' % celtemp
  end
  def extractLatLong(hash) #get the lat and long from the hash
        puts "Extracting Lat and Long ..."
    lat = hash[0][:geometry][:location][:lat]
    long = hash[0][:geometry][:location][:lng]
    return [lat, long]
  end
  attr_accessor :lat, :long

end


####Methods#####

def getCurrentTemp_raw(lat, long)

    puts "Getting Forcast ..."
    forecast = ForecastIO.forecast(lat,long)
    temp = forecast[:currently][:temperature]
    celtemp = (5*(Float(temp) - 32))/9 #return temp in C
    puts "Caculating Current Temp ..."
    return '%.2f' % celtemp
end

def getFormattedAddress(locationInput) #input address or place, output location hash
  puts locationInput
  puts "Validating inputted address ..."
  hash = @gmaps.geocode(locationInput)
  puts "found #{hash[0][:formatted_address]}"
  @currentlyIn = hash[0][:formatted_address]

  if is_within_australia_check(hash)
    return [true, hash]
  else
    return [false, hash]
  end
end

def is_within_australia_check(hash)
  puts "Checking address is within Australia ..."
  puts "Country Short Name: #{hash[0][:address_components][2][:short_name]}"

  if hash[0][:address_components][2][:short_name] == "AU"

    puts "IN AUS"

    return true
  else

    puts "NOT IN AUS"

    return false
  end
end

def askUserToSeeMoreCitites
  puts "Would you like to see the current temp for all major cities y/n?"
  user_decision = gets.chomp
  if user_decision == 'y'
    return true
  elsif user_decision == 'n'
    return false
  else
    puts "input not reconised"
    askUserToSeeMoreCitites()
  end
end

def directionsToCity(input)
  city = @cities.keys[input]
  route = @gmaps.directions(@currentlyIn,city,alternatives: false)
  hash = route[0]
  status = route[1]

  if hash.nil?
    puts "error, empty"
    exit
  end

  legs = hash[:legs]
  steps = legs[0][:steps]

  steps.each do |x|
     output = x[:html_instructions]
     puts output.gsub(/<\/?[^>]*>/, "")
  end


end


def askUserToTravel()
  puts "Would you like to see directions to one of these cities y/n?"
  user_decision = gets.chomp
  if user_decision == 'y'
    puts "Which city would you like directions to?"
    @cities.each_with_index do |(key,value),index|
      puts "#{index+1} #{key}"
    end
    puts "type the number of the city you would like directions to"
    input = gets.chomp.to_i
    length = @cities.length.to_i
      if input.between?(1,length)
        directionsToCity(input)
      else
        puts "wrong input"
        askUserToTravel()
      end
  elsif user_decision == 'n'
    exit
  else
    puts "input not reconised"
    askUserToTravel()
  end
end

def listCities()

  rows = []
  rows << ['Number', 'Location', 'Temp']
  rows << :separator
  @cities.each_with_index do |(key,value),index|

    temp = getCurrentTemp_raw(value[0], value[1])

    # puts "#{key}: #{temp}
    # "
    rows << [index+1, key, temp] #display row by row
  end

  table = Terminal::Table.new :rows => rows

end

#####MAIN PROGRAM########
user_input = CurrentLocation.new.askLocation()
puts "User Input Returned:#{user_input}"

formatted_address = getFormattedAddress(user_input)

  if formatted_address[0] == false
    puts "Address not within Australia. Please try again.
    "
    user_input = CurrentLocation.new.askLocation()
  else
    temp = CurrentTemp.new.getCurrentTemp(formatted_address[1])
  end

  puts temp
  if askUserToSeeMoreCitites()
    puts listCities()
  else
    exit
  end

askUserToTravel()
