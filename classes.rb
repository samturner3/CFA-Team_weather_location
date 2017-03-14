require 'google_maps_service'
# require 'sanitize'


# Clean up an HTML fragment using Sanitize's permissive but safe Relaxed config.
# This also sanitizes any CSS in `<style>` elements or `style` attributes.


# Setup API keys
gmaps = GoogleMapsService::Client.new(key: 'AIzaSyDtMxX6mnJqcKsqyrHqTXPMCcOMTfmXqAU')

# Simple directions
routes = gmaps.directions(
    'Sydney, NSW, Australia',
    'Darwin, NT, Australia',
    alternatives: false)




hash = routes[0]
status = routes[1]

# puts hash.class
# puts hash.count

# puts hash.keysputs
puts hash.class

if hash.nil?
  puts "error, empty"
  exit
end

legs = hash[:legs]

steps = legs[0][:steps]

steps.each do |x|
  # output = Sanitize.fragment()
   output = x[:html_instructions]
   puts output.gsub(/<\/?[^>]*>/, "")
end

# puts str.gsub(/<\/?[^>]*>/, "")


# keys = routes.count
    # puts routes["bounds"]
    # puts "#{routes['bounds']}"
    # puts keys


    # routes.each { |x| puts "#{x}
    #
    # " }



# Class Location
#     def initialize(location)
#         @location = location
#     end
#     attr_accessor :location
#     def get_temp(location)
#
#     end
#

#input location
#return temp

#Class Temp
#input temp
#return location

#Class Direction
#input from, to
#return driections
