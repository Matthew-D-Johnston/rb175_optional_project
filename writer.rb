require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "yaml"
require "roo"

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

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

def load_company_descriptions
  descriptions_path = if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/company_descriptions.yml", __FILE__)
  else
    File.expand_path("../company_descriptions.yml", __FILE__)
  end
  YAML.load_file(descriptions_path)
end

def write_company_descriptions(companies)
  descriptions_path = if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/company_descriptions.yml", __FILE__)
  else
    File.expand_path("../company_descriptions.yml", __FILE__)
  end

  File.open(descriptions_path, "w") { |file| file.write(companies.to_yaml) }
end

def load_xlsx_file(file)
  file_path = File.join(data_path, file)
  file_workbook = Roo::Spreadsheet.open(file_path)
end

def stock_data(file, rank)
  workbook = load_xlsx_file(file)
  stock_data = workbook.row(rank)
  stock_hash = {}
  stock_hash[:ticker] = stock_data[0]
  if stock_data[1] =~ /(Inc|Corp|Co|Ltd)$/
    stock_hash[:name] = stock_data[1] + '.'
  else
    stock_hash[:name] = stock_data[1]
  end
  stock_hash[:price] = '%.2f' % stock_data[2]
  stock_hash[:market_cap] = stock_data[3].to_f.round(1)
  stock_hash[:special] = stock_data[4].to_f.round(1)
  stock_hash
end

def group_stock_data(file)
  { stock_1: stock_data(file, 1),
    stock_2: stock_data(file, 2),
    stock_3: stock_data(file, 3)
  }
end

def unique_tickers(value, growth, momentum)
  tickers = []
  value.each { |_, data| tickers << data[:ticker] }
  growth.each { |_, data| tickers << data[:ticker] }
  momentum.each { |_, data| tickers << data[:ticker] }
  tickers.uniq
end

get "/" do
  erb :home
end

get "/stocks" do
  erb :stocks
end

get "/stock_story" do
  @value_stocks = group_stock_data("value.xlsx")
  @growth_stocks = group_stock_data("growth.xlsx")
  @momentum_stocks = group_stock_data("momentum.xlsx")
  @tickers = unique_tickers(@value_stocks, @growth_stocks, @momentum_stocks)

  erb :stock_story
end

get "/update" do
  erb :update
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

post "/update" do
  company_name = params[:name].gsub(" ", "_")
  company_description = params[:description]

  companies = load_company_descriptions
  companies[company_name] = company_description
  write_company_descriptions(companies)

  session[:message] = "Database has been updated with a description for #{params[:name]}"
  redirect "/update"
end

