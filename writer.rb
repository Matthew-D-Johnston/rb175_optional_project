require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

configure do
  enable :sessions
  set :session_secret, 'super secret'
end

helpers do
  def compare_performance
    difference = (session[:index_return].to_f - session[:sp500_return].to_f).to_i

    if difference > 0
      "outperformed"
    elsif difference < 0
      "underperformed"
    else
      "on par with"
    end
  end

  def months
    { 1 => 'January', 2 => 'February', 3 => 'March',
      4 => 'April', 5 => 'May', 6 => 'June',
      7 => 'July', 8 => 'August', 9 => 'September',
      10 => 'October', 11 => 'November', 12 => 'December'
    }
  end

  def date
    date = Time.now
    day = date.day
    month = months[date.month]
    year = date.year
    { day: "#{day}", month: "#{month}", year: "#{year}" }
  end
end

get "/" do
  erb :home
end

get "/stocks" do
  erb :stocks
end

get "/stock_story" do
  erb :stock_story
end

post "/stocks" do
  session[:type] = params[:type]
  session[:period] = params[:period]
  session[:earn_or_sales] = params[:earn_or_sales]
  session[:sector_index] = params[:sector_index]
  session[:index_return] = params[:index_return]
  session[:sp500_return] = params[:sp500_return]

  redirect "/stock_story"
end

