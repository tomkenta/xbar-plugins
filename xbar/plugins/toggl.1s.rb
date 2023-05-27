#!/usr/bin/ruby

require 'net/http'
require 'json'
require 'time'

# your toggle API Toekn here
TOGGLE_API_TOKEN = ""

def get(path)
  uri = URI("https://api.track.toggl.com#{path}")
  req = Net::HTTP::Get.new(uri)
  req.basic_auth TOGGLE_API_TOKEN, "api_token"
  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(req)
  end
  JSON.parse(res.body)
end

entry = get("/api/v9/me/time_entries/current")
if entry
  description = entry['description'] || '(no description)'
  workspace_id = entry['workspace_id']
  project_id = entry['project_id']
  interval = Time.now - Time.parse(entry['start'])
  hours = interval.floor / 3600
  minutes = ( interval.floor - hours * 3600 ) / 60
  seconds =  ( interval.floor - hours * 3600 - minutes * 60 )
  projectName = ''
  options = ''
  if project_id
    project = get("/api/v9/workspaces/#{workspace_id}/projects/#{project_id}")
    projectName = project['name']
    color = project['color']
    options += "color=#{color}"
  end
  puts "#{description} #{ projectName ? "• #{projectName} " : ""} #{"%02d" % hours}h:#{"%02d" % minutes}m:#{"%02d" % seconds} #{options.empty? ? "" : " | #{options}"}"
else
  puts 'Toggl not running | color=red'
end
