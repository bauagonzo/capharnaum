#!/usr/bin/env ruby
require 'net/http'
require 'uri'
require 'nokogiri'
require 'yaml'
require 'awesome_print'

cache = File.dirname(__FILE__) + "/.#{File.basename($0,'.rb')}.jobs.cache"
begin
  jobs = YAML::load(File.open(cache))
  jobs = [] unless jobs.is_a?(Array)   # Be sure file is not corrupted
rescue Errno::ENOENT
  jobs = []
end

url = "https://recrutement.proservia.fr/public/index.php?a=annonce"
uri = URI.parse(url)
request = Net::HTTP::Post.new(uri)
request.set_form_data(
    "a" => "annonce",
    "localisation[]" => "11570431072",
)

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(request)
end

html_doc = Nokogiri::HTML(response.body)

html_doc.css(".listcv [class*='row']").each do |j|
  x = j.css('td')
  job = { date: x[0].text, title: x[1].text, location: x[2].text }
  unless jobs.include?(job)
    print "🌟"
    jobs << job
  end
  ap job
end
File.open(cache, 'w') {|f| f.write(YAML.dump(jobs)) }
