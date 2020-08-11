require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"
require "yaml"
require "roo"
require "nokogiri"
require "open-uri"
require "bcrypt"

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

  def etf_holdings_sentence(etf)
    holding_1 = session[etf][:etf_holdings][0]
    holding_2 = session[etf][:etf_holdings][1]
    holding_3 = session[etf][:etf_holdings][2]

    company_database = load_company_descriptions("etf_company_descriptions")

    holdings_phrase = []

    [holding_1, holding_2, holding_3].each do |holding|
      company_description = ""
      if company_database.key?(holding[0].gsub(" ", "_"))
        company_description = company_database[holding[0].gsub(" ", "_")]
      else
        company_description = "a ..."
      end

      company = ""
      if holding[0] =~ /(Inc|Corp|Co|Ltd)$/
        company = "#{holding[0]}."
      else
        company = holding[0]
      end
      ticker = holding[1]
      holdings_phrase << "#{company} (#{ticker}), #{company_description}"
    end

    "The fund's top three holdings include #{holdings_phrase[0]}; #{holdings_phrase[1]}; and #{holdings_phrase[2]}."
  end
end

def data_path
  if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end

def load_company_descriptions(file)
  descriptions_path = if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/#{file}.yml", __FILE__)
  else
    File.expand_path("../#{file}.yml", __FILE__)
  end
  YAML.load_file(descriptions_path)
end

def write_company_descriptions(companies, file)
  descriptions_path = if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/#{file}.yml", __FILE__)
  else
    File.expand_path("../#{file}.yml", __FILE__)
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
  stk_name = stock_data[1]
  
  if stock_data[1] =~ /(Inc|Corp|Co|Ltd)$/
    stock_hash[:name] = stk_name + '.'
  else
    stock_hash[:name] = stk_name
  end
  stock_hash[:ticker] = stock_data[0]
  stock_hash[:price] = '%.2f' % stock_data[2]
  stock_hash[:market_cap] = stock_data[3].to_f.round(1)
  case file
  when "value.xlsx" then stock_hash[:ratio] = stock_data[4].to_f.round(1)
  when "growth.xlsx" then stock_hash[:growth] = (stock_data[4].to_f * 100).round(1)
  when "momentum.xlsx" then stock_hash[:return] = (stock_data[4].to_f * 100).round(1)
  end
  stock_hash[:description] = load_company_descriptions("company_descriptions")[stk_name.gsub(" ", "_")]
  stock_hash
end

def company_data(file, rank)
  workbook = load_xlsx_file(file)
  comp_data = workbook.row(rank)
  
  company_hash = {}
  company_name = comp_data[1]
  
  if comp_data[1] =~ /(Inc|Corp|Co|Ltd)$/
    company_hash[:name] = company_name + '.'
  else
    company_hash[:name] = company_name
  end
  company_hash[:ticker] = comp_data[0]
  company_hash[:revenue] = comp_data[2].to_f.round(1)
  
  revenue_units = comp_data[2].chars.last
  case revenue_units
  when 'M' then company_hash[:revenue_units] = 'million'
  when 'B' then company_hash[:revenue_units] = 'billion'
  when 'T' then company_hash[:revenue_units] = 'trillion'
  end

  net_income = comp_data[3].to_f.round(1)
  if net_income < 0
    company_hash[:net_income] = "-$#{net_income * -1}"
  else
    company_hash[:net_income] = "$#{net_income}"
  end

  net_income_units = comp_data[3].chars.last
  case net_income_units
  when 'M' then company_hash[:net_income_units] = 'million'
  when 'B' then company_hash[:net_income_units] = 'billion'
  when 'T' then company_hash[:net_income_units] = 'trillion'
  end

  company_hash[:market_cap] = comp_data[4].to_f.round(1)

  market_cap_units = comp_data[4].chars.last
  case market_cap_units
  when 'M' then company_hash[:market_cap_units] = 'million'
  when 'B' then company_hash[:market_cap_units] = 'billion'
  when 'T' then company_hash[:market_cap_units] = 'trillion'
  end

  company_hash[:returns] = (comp_data[5].to_f * 100).round(1)
  #company_hash[:pe_ratio] = comp_data[6].to_f.round(1)
  company_hash[:exchange] = comp_data[6].gsub(/ Markets/, '')
  company_hash[:rank] = rank
  company_hash[:description] = load_company_descriptions("company_descriptions")[company_name.gsub(" ", "_")]
  
  company_hash
end

def group_stock_data(file)
  { stock_1: stock_data(file, 1),
    stock_2: stock_data(file, 2),
    stock_3: stock_data(file, 3)
  }
end

def group_company_data(file)
  { company_1: company_data(file, 1),
    company_2: company_data(file, 2),
    company_3: company_data(file, 3),
    company_4: company_data(file, 4),
    company_5: company_data(file, 5),
    company_6: company_data(file, 6),
    company_7: company_data(file, 7),
    company_8: company_data(file, 8),
    company_9: company_data(file, 9),
    company_10: company_data(file, 10)
  }
end

def unique_tickers(value, growth, momentum)
  tickers = []
  value.each { |_, data| tickers << data[:ticker] }
  growth.each { |_, data| tickers << data[:ticker] }
  momentum.each { |_, data| tickers << data[:ticker] }
  tickers.uniq
end

def change_duplicate_stock_description(value, growth, momentum)
  tickers = []

  value.each do |_, data|
    tickers << data[:ticker]
  end

  growth.each do |_, data|
    if tickers.include?(data[:ticker])
      data[:description] = "See above for company description."
    else
      tickers << data[:ticker]
    end
  end

  momentum.each do |_, data|
    if tickers.include?(data[:ticker])
      data[:description] = "See above for company description."
    else
      tickers << data[:ticker]
    end
  end
end

def month_name_long_form(month)
  long_form = ""
  case month
  when "Jan" then long_form = "January"
  when "Feb" then long_form = "February"
  when "Mar" then long_form = "March"
  when "Apr" then long_form = "April"
  when "May" then long_form = "May"
  when "Jun" then long_form = "June"
  when "Jul" then long_form = "July"
  when "Aug" then long_form = "August"
  when "Sep" then long_form = "September"
  when "Oct" then long_form = "October"
  when "Nov" then long_form = "November"
  when "Dec" then long_form = "December"
  end
  long_form
end

def etf_data_urls(ticker)
  { profile: "https://etfdb.com/etf/#{ticker}/#etf-ticker-profile",
    dividend: "https://etfdb.com/etf/#{ticker}/#etf-ticker-valuation-dividend",
    performance: "https://etfdb.com/etf/#{ticker}/#performance",
    holdings: "https://etfdb.com/etf/#{ticker}/#holdings"
  }
end

def extract_etf_html_data(ticker, type)
  url = etf_data_urls(ticker)[type]
  doc = Nokogiri::HTML(open(url))
end

def etf_profile_data(ticker)
  doc = extract_etf_html_data(ticker, :profile)
  
  title_arr = doc.css("h1[class='data-title']").text.split("\n")
  title_arr.delete("")
  data_array = doc.css('div.mm-main-container').css('div.col-sm-6').css('li').text.split("\n")
  data_array.delete("")

  profile_data = {}
  profile_data[:ticker] = title_arr[0]
  profile_data[:name] = title_arr[1]

  data_array.each_with_index do |elem, idx|
    case elem
    when "Issuer"
      profile_data[:issuer] = data_array[idx + 1]
    when "Expense Ratio"
      profile_data[:exp_ratio] = data_array[idx + 1]
    when "Inception"
      date = data_array[idx + 1]
      month, day, year = date.split
      date = "#{month_name_long_form(month)} #{day} #{year}"
      profile_data[:date] = date
    when "AUM"
      aum = data_array[idx + 1]
      amount, letter = aum.split
      profile_data[:aum] = "#{amount} million" if letter == "M"
      profile_data[:aum] = "#{amount} billion" if letter == "B"
    when "3 Month Avg. Volume"
      profile_data[:volume] = data_array[idx + 1]
    end
  end

  profile_data
end

def etf_dividend_data(ticker)
  doc = extract_etf_html_data(ticker, :dividend)
  data_array = doc.css('div.row.relative-metric-m-top').text.split("\n")
  data_array.delete("")
  dividend_data = {}

  data_array.each_with_index do |elem, idx|
    dividend_data[:div_yield] = data_array[idx + 1] if elem == "Annual Dividend Yield"
  end

  dividend_data
end

def etf_performance_data(ticker)
  doc = extract_etf_html_data(ticker, :performance)
  data_array = doc.css('div.col-xs-6.col-md-3.col-lg-3').text.split("\n")
  data_array.delete("")
  performance_data = {}

  data_array.each_with_index do |elem, idx|
    if elem == "1 Year Return"
      yr_return = data_array[idx - 1].to_f.round(1)
      performance_data[:one_yr_return] = "#{yr_return}%"
    end
  end

  performance_data
end

def etf_holdings_data(ticker)
  doc = extract_etf_html_data(ticker, :holdings)

  holdings = []
  8.upto(10) do |num|
    holding = doc.css("tr")[num].text.split("\n")
    holding.delete("")
    holding_elements = holding[0].split
    holding_elements.pop
    ticker = holding_elements.shift
    company = holding_elements.join(" ")
    holdings << [company, ticker]
  end

  holdings_data = { etf_holdings: holdings }
end

def combined_etf_data(ticker)
  h1 = etf_profile_data(ticker)
  h2 = etf_dividend_data(ticker)
  h3 = etf_performance_data(ticker)
  h4 = etf_holdings_data(ticker)

  h1.merge(h2).merge(h3).merge(h4)
end

def load_admin_credentials
  credentials_path = if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/admin.yml", __FILE__)
  else
    File.expand_path("../admin.yml", __FILE__)
  end
  YAML.load_file(credentials_path)
end

def valid_credentials?(username, password)
  credentials = load_admin_credentials

  if credentials.key?(username)
    bcrypt_password = BCrypt::Password.new(credentials[username])
    bcrypt_password == password
  else
    false
  end
end

def remove_corporate_name_ending(name)
  name.gsub(/( Corp.| Inc.| Co.| PLC| Ltd.| LLC)/, "")
end

get "/" do
  erb :home
end

get "/stocks" do
  erb :stocks
end

get "/stock_story" do
  @value = group_stock_data("value.xlsx")
  @growth = group_stock_data("growth.xlsx")
  @momentum = group_stock_data("momentum.xlsx")
  @tickers = unique_tickers(@value, @growth, @momentum)

  change_duplicate_stock_description(@value, @growth, @momentum)

  erb :stock_story
end

get "/update" do  
  erb :update
end

get "/etf_update" do
  erb :etf_update
end

get "/shareholders" do
  erb :shareholders
end

get "/etfs" do
  erb :etfs
end

get "/etf_story" do
  erb :etf_story
end

get "/signin" do
  erb :signin
end

get "/earnings" do
  erb :earnings
end

get "/biggest_companies" do
  erb :biggest_companies
end

get "/earnings_story" do
  @full_name = session[:name]
  @nick_name = session[:name].split[0]
  @ticker = session[:ticker]
  @quarter = session[:quarter]
  @year = session[:year]
  @eps_estimate = session[:eps_estimate]
  @eps_year_ago = session[:eps_year_ago]
  @report_year = session[:report_year]
  @report_month = session[:report_month]
  @report_day = session[:report_day]
  @aft_bef = session[:aft_bef]
  @open_close = session[:open_close]
  
  erb :earnings_story
end

get "/shareholders_story" do
  @name = session[:name]
  @nick_name = session[:nick_name]
  @ticker = session[:ticker]
  @revenue= session[:revenue]
  @net_income = session[:net_income]
  @market_cap = session[:market_cap]
  @date = session[:date]
  @month, @day, @year = @date.split
  @month = @month[0..2]

  @ind_sh_1 = session[:ind_sh_1]
  @tsh_1 = session[:tsh_1]
  @pso_1 = session[:pso_1]

  @ind_sh_2 = session[:ind_sh_2]
  @tsh_2 = session[:tsh_2]
  @pso_2 = session[:pso_2]

  @ind_sh_3 = session[:ind_sh_3]
  @tsh_3 = session[:tsh_3]
  @pso_3 = session[:pso_3]

  @inst_sh_1 = session[:inst_sh_1]
  @inst_1_nick_name = remove_corporate_name_ending(@inst_sh_1)
  @sh_1 = session[:sh_1]
  @os_1 = session[:os_1]
  @source_1 = session[:source_1]
  @sd_1 = session[:sd_1]

  @inst_sh_2 = session[:inst_sh_2]
  @inst_2_nick_name = remove_corporate_name_ending(@inst_sh_2)
  @sh_2 = session[:sh_2]
  @os_2 = session[:os_2]
  @source_2 = session[:source_2]
  @sd_2 = session[:sd_2]

  @inst_sh_3 = session[:inst_sh_3]
  @inst_3_nick_name = remove_corporate_name_ending(@inst_sh_3)
  @sh_3 = session[:sh_3]
  @os_3 = session[:os_3]
  @source_3 = session[:source_3]
  @sd_3 = session[:sd_3]


  erb :shareholders_story
end

get "/biggest_companies_story" do
  @all_companies = group_company_data("top_10.xlsx")
  @company_1 = @all_companies[:company_1]
  @company_2 = @all_companies[:company_2]
  @company_3 = @all_companies[:company_3]
  @company_4 = @all_companies[:company_4]
  @company_5 = @all_companies[:company_5]
  @company_6 = @all_companies[:company_6]
  @company_7 = @all_companies[:company_7]
  @company_8 = @all_companies[:company_8]
  @company_9 = @all_companies[:company_9]
  @company_10 = @all_companies[:company_10]

  erb :biggest_companies_story
end

post "/signout" do
  session.delete(:admin)
  session[:message] = "You are no longer signed in as the system administrator."
  redirect "/"
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
  if session[:admin]
    company_name = params[:name].gsub(" ", "_")
    company_description = params[:description]

    companies = load_company_descriptions("company_descriptions")
    companies[company_name] = company_description
    write_company_descriptions(companies, "company_descriptions")

    session[:message] = "Database has been updated with a description for #{params[:name]}"
    redirect "/update"
  else
    session[:message] = "You are not signed in. You may not update the database."
    redirect "/update"
  end
end

post "/etfs" do
  session[:type] = params[:type]
  session[:period] = params[:period]
  session[:num_etfs] = params[:num_etfs]

  session[:sector_index] = params[:sector_index]
  session[:sector_performance] = params[:sector_performance]
  session[:market_index] = params[:market_index]
  session[:market_performance] = params[:market_performance]

  ticker_1 = params[:etf_1]
  ticker_2 = params[:etf_2]
  ticker_3 = params[:etf_3]

  session[:etf_1] = combined_etf_data(ticker_1)
  session[:etf_2] = combined_etf_data(ticker_2)
  session[:etf_3] = combined_etf_data(ticker_3)

  redirect "/etf_story"
end

post "/signin" do
  if valid_credentials?(params[:admin], params[:password])
    session[:admin] = params[:admin]
    session[:message] = "You are now signed in as the system administrator."
    redirect "/"
  else
    session[:message] = "Sign in failed. Incorrect password or username."
    status 422
    erb :signin
  end
end

post "/etf_update" do
  if session[:admin]
    company_name = params[:name].gsub(" ", "_")
    company_description = params[:description]

    companies = load_company_descriptions("etf_company_descriptions")
    companies[company_name] = company_description
    write_company_descriptions(companies, "etf_company_descriptions")

    session[:message] = "Database has been updated with a description for #{params[:name]}"
    redirect "/etf_update"
  else
    session[:message] = "You are not signed in. You may not update the database."
    redirect "/etf_update"
  end
end

post "/earnings" do
  session[:name] = params[:name]
  session[:ticker] = params[:ticker]
  session[:quarter] = params[:quarter]
  session[:year] = params[:year].to_i
  session[:eps_estimate] = params[:eps_estimate]
  session[:eps_year_ago] = params[:eps_year_ago]
  session[:report_year] = params[:report_year]
  session[:report_month] = params[:report_month]
  session[:report_day] = params[:report_day]
  session[:aft_bef] = params[:aft_bef]
  session[:open_close] = params[:open_close]

  redirect "/earnings_story"
end

post "/shareholders" do
  session[:name] = params[:name]
  session[:nick_name] = params[:nick_name]
  session[:ticker] = params[:ticker]

  session[:revenue] = params[:revenue]
  session[:net_income] = params[:net_income]
  session[:market_cap] = params[:market_cap]
  session[:date] = params[:date]

  session[:ind_sh_1] = params[:ind_sh_1]
  session[:tsh_1] = params[:tsh_1]
  session[:pso_1] = params[:pso_1]

  session[:ind_sh_2] = params[:ind_sh_2]
  session[:tsh_2] = params[:tsh_2]
  session[:pso_2] = params[:pso_2]

  session[:ind_sh_3] = params[:ind_sh_3]
  session[:tsh_3] = params[:tsh_3]
  session[:pso_3] = params[:pso_3]

  session[:inst_sh_1] = params[:inst_sh_1]
  session[:sh_1] = params[:sh_1]
  session[:os_1] = params[:os_1]
  session[:source_1] = params[:source_1]
  session[:sd_1] = params[:sd_1]

  session[:inst_sh_2] = params[:inst_sh_2]
  session[:sh_2] = params[:sh_2]
  session[:os_2] = params[:os_2]
  session[:source_2] = params[:source_2]
  session[:sd_2] = params[:sd_2]

  session[:inst_sh_3] = params[:inst_sh_3]
  session[:sh_3] = params[:sh_3]
  session[:os_3] = params[:os_3]
  session[:source_3] = params[:source_3]
  session[:sd_3] = params[:sd_3]

  redirect "/shareholders_story"
end

post "/biggest_companies" do
  session[:type] = params[:type]

  redirect "/biggest_companies_story"
end
