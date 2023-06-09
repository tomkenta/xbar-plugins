#!/usr/bin/ruby

require 'net/http'
require 'json'
require 'time'

# your toggle API Toekn here
TOGGLE_API_TOKEN = ENV['secret']
BASE_URL = "https://api.track.toggl.com"

def get(path)
  uri = URI("#{BASE_URL}#{path}")
  req = Net::HTTP::Get.new(uri)
  req.basic_auth TOGGLE_API_TOKEN, "api_token"
  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(req)
  end
  JSON.parse(res.body)
end


def post(path,body)
    uri = URI("#{BASE_URL}#{path}")
    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = "application/json"
    req.basic_auth TOGGLE_API_TOKEN, "api_token"
    req.body = body
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    JSON.parse(res.body)
end

def patch(path)
    uri = URI("#{BASE_URL}#{path}")
    req = Net::HTTP::Patch.new(uri)
    req.basic_auth TOGGLE_API_TOKEN, "api_token"
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    JSON.parse(res.body)
end


inputArray = ARGV[0].split
description = inputArray[0]
project = inputArray[1]

me = get("/api/v9/me")
if me
  default_workspace_id = me['default_workspace_id']
  if default_workspace_id
    entry = get("/api/v9/me/time_entries/current")
    if entry
        current_entry_id = entry['id']
        patch("/api/v9/workspaces/#{default_workspace_id}/time_entries/#{current_entry_id}/stop")
    end
    projects = get("/api/v9/workspaces/#{default_workspace_id}/projects")
    projectHash = projects.map {|project| [project["name"],project["id"]]}.to_h
    bodyJson =
    {
        "billable": false,
        "created_with": "apis",
        "description": description || "" ,
        "duration": -1,
        # "duronly": false,
        #"pid": -1,
        "project_id": projectHash[project] || nil ,
        "start": Time.now.strftime("%FT%T%:z"),
        "start_date": Time.now.strftime("%F"),
        # "stop": "",
        "tag_action":"",
        "tag_ids":[],
        "tags":[],
        # "task_id":-1,
        # "tid": -1,
        # "uid": -1,
        # "user_id": -1,
        # "wid": 1,
        "workspace_id":default_workspace_id,
    }.to_json
    post("/api/v9/workspaces/#{default_workspace_id}/time_entries",bodyJson)
    print "true"
  else
    print "false"
  end
else
  print "false"
end