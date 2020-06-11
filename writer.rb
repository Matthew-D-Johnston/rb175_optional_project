require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

get "/" do
  erb :home
end

get "/stocks" do
  erb :stocks
end
