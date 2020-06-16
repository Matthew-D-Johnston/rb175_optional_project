##### RB175 Networked Applications > Optional Projects

---

## Project Plan

### The Idea

I want to create an app that will help with my work as a writer at Investopedia. A number of my assignments involve taking pre-given data or retrieving data from a website and then outputting that data in a standard format.  

What I want from this app is to be able to input some variables (the parts of the output that actually do change) and then have the app essentially do all the work of collecting and manipulating the data, and then outputting in the standard format.

So there are two different types of stories that will require two separate implementations: 1) a Top Stocks story; and 2) a Top ETFs story. Thus, there should be a home page that gives the user the option to choose what type of story they want to create.

---

### Top Stocks

#### Description:

For this type of story, I am usually given data for nine stocks, which are separated into three groups ("value", "growth", and "momentum") of three. The data is already separated but it is given to me as an image file. Thus, I take these images and extract the data from them using a site that employs Optimal Character Recognition software ([here](https://www.onlineocr.net/)).  

For starters, I will need to create a separate `data` folder to store the `.xlsx` files. My app will extract data from these files. I will need to have a page that allows for the input of the variable data. When this data is input and then submitted, the app should render a page with the outline of the story, including all the requisite data, formatted in the appropriate way.

Here is the variable data that needs to be input:

* Type of stocks (e.g. "Financial", "Consumer Staples", "Marijuana", etc.)
* Time period (e.g. "Q3 2020", "June 2020", etc.)
* Whether the story is an *earnings* story or a *sales* story.
* The Sector Index (e.g. "Consumer Staples Select Sector", etc.)
* The Sector Index Return (e.g., 6.6%, 10.4%, -5.4%, etc.)
* The S&P 500 Return (e.g. 7.3%, 2.1%, -4.5%)
* The name of the value stocks file (e.g. pharma_value.xlsx)
* The name of the growth stocks file (e.g. pharma_growth.xlsx)
* The name of the momentum stocks file (e.g. pharma_momentum.xlsx)

Also, the app should contain a database of company descriptions that can be updated to add more companies over time. These company descriptions are used within the story based on the data contained in the `.xlsx` files.

---

### Top ETF

#### Description:

---

### Implementation: 

#### Home Page

The home page should give the user an option to choose between a Top Stocks story or a Top ETF story.  

Steps:

* Create a `home.erb` view template in a `views` directory within the project's main directory.

* Within the `writer.app`, add a `get "/"` route that will render the `home.erb` view template.

* The `home.erb` view template should include a welcome message, a message telling the user to choose between a Top Stocks story or a Top ETF story. Each option should direct the user to a different page.

  ```erb
  <h3>Welcome!</h3>
  <p>What type of story would you like to write? (Choose one and press the appropriate button).</p>
  <form class="inline" method="get" action="/stocks">
    <button type="submit">Top Stocks</button>
  </form>
  <form class="inline" method="get" action="/etfs">
    <button type="submit">Top ETFs</button>
  </form>
  ```

* The `get "/"` route looks like this:

  ```ruby
  get "/" do
    erb :home
  end
  ```

#### Top Stocks Input Page

* Create a `get "/stocks"`route.

* This route will need to render a `stocks.erb` view template that will allow for field submission of the appropriate variables. At the end of the submission fields there should be a submit button to send the data and which should direct the user to a page that will render the story in the appropriate format.

  ```ruby
  get "/stocks" do
    erb :stocks
  end
  ```

* It should also include a button asking the user if they want to update the company description database with a new company and its description.

* Here are the submission fields we will need:

  * Type of stocks (e.g. "Financial", "Consumer Staples", "Marijuana", etc.)
  * Time period (e.g. "Q3 2020", "June 2020", etc.)
  * Whether the story is an *earnings* story or a *sales* story.
  * The Sector Index (e.g. "Consumer Staples Select Sector", etc.)
  * The Sector Index Return (e.g., 6.6%, 10.4%, -5.4%, etc.)
  * The S&P 500 Return (e.g. 7.3%, 2.1%, -4.5%)

  ```erb
  <h2>Top Stocks</h2>
  <form method="post" action="/stocks">
    <div>
      <label for="type"> Type:
        <input name="type" id="type" />
      </label>
    </div>
    <div>
      <label for="period"> Period:
        <input name="period" id="period" />
      </label>
    </div>
    <div>
      <label for="earn_or_sales"> Earnings/Sales:
        <input name="earn_or_sales" id="earn_or_sales" />
      </label>
    </div>
    <div>
      <label for="sector_index"> Sector Index:
        <input name="sector_index" id="sector_index" />
      </label>
    </div>
    <div>
      <label for="index_return"> Index Return:
        <input name="index_return" id="index_return" />
      </label>
    </div>
    <div>
      <label for="sp500_return"> S&P 500 Return:
        <input name="sp500_return" id="sp500_return" />
      </label>
    </div>
    <button type="submit">Submit</button>
  </form>
  <p>Or, update the Company Description database.</p>
  <form class="inline" method="get" action="/update">
    <button type="submit">Update Database</button>
  </form>
  ```


#### Posting Top Stocks Data

* Add a `post "/stocks"` route.

* Add a `configure` method to the `writer.rb` file in order to enable sessions.

* Within the `post "/stocks"` route, assign the submitted data stored in the `params` hash to the `sessions` hash.

  ```ruby
  # ...
  
  configure do
    enable :sessions
    set :session_secret, 'super secret'
  end
  
  # ...
  
  post "/stocks" do
    session[:type] = params[:type]
    session[:period] = params[:period]
    session[:earn_or_sales] = params[:earn_or_sales]
    session[:sector_index] = params[:sector_index]
    session[:index_return] = params[:index_return]
    session[:sp500_return] = session[:sp500_return]
  
    redirect "/stock_story"
  end
  ```

#### Top Stocks Story Page

* Add a `get "stock_story"` route to the `writer.rb` file.

* This route will need to render a `stock_story.erb` view template, which will contain the html of the formatted output for the story.

* The template will be divided into 6 different sections: 1) headings; 2) tickers; 3) intro; 4) value; 5) growth; and 6) momentum.

* **The headings section:**

  ```erb
  <div class="headings">
    <h2>Headings</h2>
    <ul>
      <li><b>HEADING:</b> Top <%= session[:type] %> Stocks for <%= session[:period] %></li>
      <li><b>SUBHEADING:</b> Top <%= session[:type] %> Stocks for <%= session[:period] %></li>
      <li><b>SOCIAL TITLE:</b></li>
      <li><b>META TITLE:</b> Top <%= session[:type] %> Stocks for <%= session[:period] %></li>
      <li><b>META DESCRIPTION:</b> These are the <%= session[:type].downcase %> stocks with the best value, fastest growth, and most momentum for <%= session[:period] %>.</li>
    </ul>
  </div>
  ```

* **The tickers section:** we will save this section for later as it will rely on files derived from the company data.

* **The intro section:**

  * We need to introduce some `helpers` methods in our `writer.rb` file.

  * The method specific to the intro section is a `compare_performance` method, which will compare the return of the sector index with that of the S&P 500 and return a string phrase that is appropriate for whichever return is greater or if they are equal.

  * We also need a `date` method, which will depend on a `months` method.

    ```ruby
    # ...
    
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
    ```

  * And the html for the view template:

    ```erb
    <div class="intro">
      <h2>Intro</h2>
      <p>
        <%= session[:type] %> stocks, as represented by the <%= session[:sector_index] %>, have <%= compare_performance %> the broader market, providing investors with a total return of <%= session[:index_return] %> compared to the S&P 500's total return of <%= session[:sp500_return] %> over the past 12 months (YCharts. "Financial Data," Accessed <%= date[:month][0..2] %>. <%= date[:day] %>, <%= date[:year] %>.). These market performance numbers and the statistics in the tables below are as of <%= date[:month] %> <%= date[:day] %>.
      </p>
      <p>
        <% if session[:earn_or_sales] == "E" %>
          Here are the top 3 <%= session[:type].downcase %> stocks with the best value, the fastest earnings growth, and the most momentum.
        <% else %>
          Here are the top 3 <%= session[:type].downcase %> stocks with the best value, the fastest sales growth, and the most momentum.
        <% end %>
      </p>
    </div>
    ```

* **The value section:** We will be able to complete some of this, but there is some that will have to wait till we have implemented the data collection.

  ```erb
  <div class="value">
    <h2>Best Value <%= session[:type] %> Stocks</h2>
    <div class="value_intro">
      <p>
        <% if session[:earn_or_sales] == "E" %>
          These are the <%= session[:type].downcase %> stocks with the lowest 12-month trailing price-to-earnings (P/E) ratio. Because profits can be returned to shareholders in the form of dividends and buybacks, a low P/E ratio shows you’re paying less for each dollar of profit generated.
        <% else %>
          These are the <%= session[:type].downcase %> stocks with the lowest 12-month trailing price-to-sales (P/S) ratio. For young companies that have not reached profitability, this can provide an idea of how much business you’re getting for each dollar invested.
        <% end %>
      </p>
    </div>
    <div class="table">
      <p>Company 1</p>
      <p>Company 2</p>
      <p>Company 3</p>
    </div>
    <div class="bullets">
      <ul>
        <li><b>Company 1:</b></li>
        <li><b>Company 2:</b></li>
        <li><b>Company 3:</b></li>
      </ul>
    </div>
  </div>
  ```

* **The growth section: **We will be able to complete some of this, but there is some that will have to wait till we have implemented the data collection.

  ```erb
  <div class="growth">
    <h2>Fastest Growing <%= session[:type] %> Stocks</h2>
    <div class="growth_intro">
      <p>
        <% if session[:earn_or_sales] == "E" %>
          These are the <%= session[:type].downcase %> stocks with the highest year-over-year (YOY) earnings per share (EPS) growth for the most recent quarter. Rising earnings show that a company’s business is growing and is generating more money that it can reinvest or return to shareholders.
        <% else %>
          These are the <%= session[:type].downcase %> stocks with the highest year over year (YOY) sales growth for the most recent quarter. Rising sales show that a company’s business is growing. This is often used to measure growth of young companies that have not yet reached profitability.
        <% end %>
      </p>
    </div>
    <div class="table">
      <p>Company 1</p>
      <p>Company 2</p>
      <p>Company 3</p>
    </div>
    <div class="bullets">
      <ul>
        <li><b>Company 1:</b></li>
        <li><b>Company 2:</b></li>
        <li><b>Company 3:</b></li>
      </ul>
    </div>
  </div>
  ```

* **The momentum section: **We will be able to complete some of this, but there is some that will have to wait till we have implemented the data collection.

  ```erb
  <div class="momentum">
    <h2><%= session[:type] %> Stocks with the Most Momentum</h2>
    <div class="momentum_intro">
      <p>
        These are the <%= session[:type].downcase %> stocks that had the highest total return over the last 12 months.
      </p>
    </div>
    <div class="table">
      <p>Company 1</p>
      <p>Company 2</p>
      <p>Company 3</p>
    </div>
    <div class="bullets">
      <ul>
        <li><b>Company 1:</b></li>
        <li><b>Company 2:</b></li>
        <li><b>Company 3:</b></li>
      </ul>
    </div>
  </div>
  ```

#### Update to Include Hyperlinks to YCharts

* Update each of the value, growth, and momentum sections of the `stock_story.erb` view template with the following code below the three companies listed in the `<div class="table">` section.

  ```erb
  <p><em>Source: <a href="https://ycharts.com/">YCharts</a></em></p>
  ```

* Also, update the Intro section with:

  ```erb
  Ycharts. "<a href="https://ycharts.com/">Financial Data</a>,"
  ```

#### Company Database

* Now, we need to create a new file in our project directory that will act as the database containing company descriptions.

* Require "yaml" in the main `writer.rb` program file.

* Create a method in the `writer.rb` program file that will load the `company_descriptions.yml` file.

  ```ruby
  def load_company_descriptions
    descriptions_path = if ENV["RACK_ENV"] == "test"
    	File.expand_path("../test/company_descriptions.yml", __FILE__)
  	else
    	File.expand_path("../company_descriptions.yml", __FILE__)
  	end
  	YAML.load_file(descriptions_path)
  end
  ```

* Now create a method that will write company descriptions to our `company_descriptions.yml` file.

  ```ruby
  def write_company_descriptions(companies)
    descriptions_path = if ENV["RACK_ENV"] == "test"
    	File.expand_path("../test/company_descriptions.yml", __FILE__)
  	else
    	File.expand_path("../company_descriptions.yml", __FILE__)
  	end
  
  	File.open(descriptions_path, "w") { |file| file.write(companies.to_yaml) }
  end
  ```

* Now, create a `get "update"` route in the `writer.rb` file.

* This route should render an `update.erb` views template with two fields for inputting data: 1) a field for the company name; and 2) a field for the company description. These fields should be followed by a Submit button.

  ```erb
  <h2>Top Stocks: Company Description Database Update</h2>
  <% if session[:message] %>
    <p class="message"><%= session.delete(:message) %></p>
  <% end %>
  <form method="post" action="/update">
    <div>
      <p>
        <label for="name"> <b>Company Name:</b>
          <input name="name" id="name" />
        </label>
      </p>
    </div>
    <div>
      <p>
        <label for="description"> <b>Company Description:</b>
        </label>
      </p>
      <p>
        <textarea name="description" id="description" rows="6" cols="80"></textarea>
      </p>
      </p>
    </div>
    <button type="submit">Submit</button>
  </form>
  ```

* Add a `post "/update"` route to the `writer.rb` file.

  ```ruby
  post "/update" do
    company_name = params[:name].gsub(" ", "_")
    company_description = params[:description]
  
    companies = load_company_descriptions
    companies[company_name] = company_description
    write_company_descriptions(companies)
  
    session[:message] = "Database has been updated with a description for #{params[:name]}"
    redirect "/update"
  end
  ```

#### Add a `layout.erb` template view

* This will include the link to the `css` style sheet and allow for flash messages.

  ```erb
  <html>
    <title>Writer</title>
    <link href="/writer.css" rel="stylesheet" type="text/css" />
    <body>
      <% if session[:message] %>
        <p class="message"><%= session.delete(:message) %></p>
      <% end %>
      <%= yield %>
    </body>
  </html>
  ```

#### Incorporating Stock Data from Excel Files

* Add a method to the `writer.rb` file that will load the company data from the `xlsx` file.

* Each file will continue three rows corresponding to three different stocks.

* In each row will be five columns:

  * For value stocks:
    * name
    * ticker
    * price
    * market cap
    * P/E or P/S ratio
  * For growth stocks:
    * name
    * ticker
    * price
    * market cap
    * EPS growth or Sales growth
  * For momentum stocks:
    * name
    * ticker
    * price
    * market cap
    * total return

* The data should be structured in hashes, one for each row/company. The hashes will have to have an order, however, because the data is ranked. An example thus, would be

  ```ruby
  value1 = { name: "Domino's Pizza", ticker: DPZ, price: 25.43, market_cap: 10.4, ratio: 4.6 }
  value2 = { name: ...., ratio: 5.8 }
  value3 = { name: ...., ratio: 7.3 }
  ```

* Here are the new methods:

  ```ruby
  def load_xlsx_file(file)
    file_path = File.join(data_path, file)
    file_workbook = Roo::Spreadsheet.open(file_path)
  end
  
  def stock_data(file, rank)
    workbook = load_xlsx_file(file)
    stock_data = workbook.row(rank)
    stock_hash = {}
    stock_hash[:ticker] = stock_data[0]
    stock_hash[:name] = stock_data[1]
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
  ```

* And we now update the `get "/stock_story"` route:

  ```ruby
  get "/stock_story" do
    @value_stocks = group_stock_data("value.xlsx")
    @growth_stocks = group_stock_data("growth.xlsx")
    @momentum_stocks = group_stock_data("momentum.xlsx")
    @tickers = unique_tickers(@value_stocks, @growth_stocks, @momentum_stocks)
  
    erb :stock_story
  end
  ```

* Now, update the `stock_story.erb` view template.

  ```erb
  <div class="headings">
    <h2>Headings</h2>
    <ul>
      <li><b>HEADING:</b> Top <%= session[:type] %> Stocks for <%= session[:period] %></li>
      <li><b>SUBHEADING:</b> Top <%= session[:type] %> Stocks for <%= session[:period] %></li>
      <li><b>SOCIAL TITLE:</b></li>
      <li><b>META TITLE:</b> Top <%= session[:type] %> Stocks for <%= session[:period] %></li>
      <li><b>META DESCRIPTION:</b> These are the <%= session[:type].downcase %> stocks with the best value, fastest growth, and most momentum for <%= session[:period] %>.</li>
    </ul>
  </div>
  
  <div class="tickers">
    <h2>Tickers</h2>
    <ul>
      <% @tickers.each do |ticker| %>
      <li><%= ticker %></li>
      <% end %>
    </ul>
  </div>
  
  <div class="intro">
    <h2>Intro</h2>
    <p>
      <%= session[:type] %> stocks, as represented by the <%= session[:sector_index] %>, have <%= compare_performance %> the broader market, providing investors with a total return of <%= session[:index_return] %> compared to the S&P 500's total return of <%= session[:sp500_return] %> over the past 12 months (YCharts. "<a href="https://ycharts.com/">Financial Data</a>," Accessed <%= date[:month][0..2] %>. <%= date[:day] %>, <%= date[:year] %>.). These market performance numbers and the statistics in the tables below are as of <%= date[:month] %> <%= date[:day] %>.
    </p>
    <p>
      <% if session[:earn_or_sales] == "E" %>
        Here are the top 3 <%= session[:type].downcase %> stocks with the best value, the fastest earnings growth, and the most momentum.
      <% else %>
        Here are the top 3 <%= session[:type].downcase %> stocks with the best value, the fastest sales growth, and the most momentum.
      <% end %>
    </p>
  </div>
  
  <div class="value">
    <h2>Best Value <%= session[:type] %> Stocks</h2>
    <div class="value_intro">
      <p>
        <% if session[:earn_or_sales] == "E" %>
          These are the <%= session[:type].downcase %> stocks with the lowest 12-month trailing price-to-earnings (P/E) ratio. Because profits can be returned to shareholders in the form of dividends and buybacks, a low P/E ratio shows you’re paying less for each dollar of profit generated.
        <% else %>
          These are the <%= session[:type].downcase %> stocks with the lowest 12-month trailing price-to-sales (P/S) ratio. For young companies that have not reached profitability, this can provide an idea of how much business you’re getting for each dollar invested.
        <% end %>
      </p>
    </div>
    <div class="table">
      <% if session[:earn_or_sales] == "E" %>
        <p> Price    Market Cap ($...)    12-Month Trailing P/E Ratio</p>
      <% else %>
        <p> Price    Market Cap ($...)    12-Month Trailing P/S Ratio</p>
      <% end %>
      <% @value_stocks.each do |_, data| %>
        <p>
          <%= data[:name] %>
          (<%= data[:ticker] %>)
          <%= data[:price] %>
          <%= data[:market_cap] %>
          <%= data[:special] %>
        </p>
      <% end %>
      <p><em>Source: <a href="https://ycharts.com/">YCharts</a></em></p>
    </div>
    <div class="bullets">
      <ul>
        <li><b>Company 1:</b></li>
        <li><b>Company 2:</b></li>
        <li><b>Company 3:</b></li>
      </ul>
    </div>
  </div>
  
  <div class="growth">
    <h2>Fastest Growing <%= session[:type] %> Stocks</h2>
    <div class="growth_intro">
      <p>
        <% if session[:earn_or_sales] == "E" %>
          These are the <%= session[:type].downcase %> stocks with the highest year-over-year (YOY) earnings per share (EPS) growth for the most recent quarter. Rising earnings show that a company’s business is growing and is generating more money that it can reinvest or return to shareholders.
        <% else %>
          These are the <%= session[:type].downcase %> stocks with the highest year over year (YOY) sales growth for the most recent quarter. Rising sales show that a company’s business is growing. This is often used to measure growth of young companies that have not yet reached profitability.
        <% end %>
      </p>
    </div>
    <div class="table">
      <% if session[:earn_or_sales] == "E" %>
        <p> Price    Market Cap ($...)    EPS Growth(%)</p>
      <% else %>
        <p> Price    Market Cap ($...)    Revenue Growth(%)</p>
      <% end %>
      <% @growth_stocks.each do |_, data| %>
        <p>
          <%= data[:name] %>
          (<%= data[:ticker] %>)
          <%= data[:price] %>
          <%= data[:market_cap] %>
          <%= data[:special] %>
        </p>
      <% end %>
      <p><em>Source: <a href="https://ycharts.com/">YCharts</a></em></p>
    </div>
    <div class="bullets">
      <ul>
        <li><b>Company 1:</b></li>
        <li><b>Company 2:</b></li>
        <li><b>Company 3:</b></li>
      </ul>
    </div>
  </div>
  
  <div class="momentum">
    <h2><%= session[:type] %> Stocks with the Most Momentum</h2>
    <div class="momentum_intro">
      <p>
        These are the <%= session[:type].downcase %> stocks that had the highest total return over the last 12 months.
      </p>
    </div>
    <div class="table">
      <p> Price    Market Cap ($...)   12-Month Trailing Total Return (%)</p>
      <% @momentum_stocks.each do |_, data| %>
        <p>
          <%= data[:name] %>
          (<%= data[:ticker] %>)
          <%= data[:price] %>
          <%= data[:market_cap] %>
          <%= data[:special] %>
        </p>
      <% end %>
      <p>S&P 500 N/A N/A <%= session[:sp500_return].gsub("%", "") %></p>
      <p><%= session[:sector_index] %> N/A N/A <%= session[:index_return].gsub("%", "") %></p>
      <p><em>Source: <a href="https://ycharts.com/">YCharts</a></em></p>
    </div>
    <div class="bullets">
      <ul>
        <li><b>Company 1:</b></li>
        <li><b>Company 2:</b></li>
        <li><b>Company 3:</b></li>
      </ul>
    </div>
  </div>
  ```

#### Access Company Database

* update the `stock_data(file, rank)` method in the `writer.rb` file.

  ```ruby
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
    stock_hash[:special] = stock_data[4].to_f.round(1)
    stock_hash[:description] = load_company_descriptions[stk_name.gsub(" ", "_")]
    stock_hash
  end
  ```

* Update the `stock_story.erb` view template

  ```erb
  <div class="headings">
    <h2>Headings</h2>
    <ul>
      <li><b>HEADING:</b> Top <%= session[:type] %> Stocks for <%= session[:period] %></li>
      <li><b>SUBHEADING:</b> Top <%= session[:type] %> Stocks for <%= session[:period] %></li>
      <li><b>SOCIAL TITLE:</b> <%= @value[:stock_1][:ticker] %>, <%= @growth[:stock_1][:ticker] %>, and <%= @momentum[:stock_1][:ticker] %> are top for value, growth, and momentum, respectively</li> 
      <li><b>META TITLE:</b> Top <%= session[:type] %> Stocks for <%= session[:period] %></li>
      <li><b>META DESCRIPTION:</b> These are the <%= session[:type].downcase %> stocks with the best value, fastest growth, and most momentum for <%= session[:period] %>.</li>
    </ul>
  </div>
  <div class="tickers">
    <h2>Tickers</h2>
      <% @tickers.each do |ticker| %>
      <p><%= ticker %></p>
      <% end %>
  </div>
  <div class="intro">
    <h2>Intro</h2>
    <p>
      <%= session[:type] %> stocks, as represented by the <%= session[:sector_index] %>, have <%= compare_performance %> the broader market, providing investors with a total return of <%= session[:index_return] %> compared to the S&P 500's total return of <%= session[:sp500_return] %> over the past 12 months (YCharts. "<a href="https://ycharts.com/">Financial Data</a>," Accessed <%= date[:month][0..2] %>. <%= date[:day] %>, <%= date[:year] %>.). These market performance numbers and the statistics in the tables below are as of <%= date[:month] %> <%= date[:day] %>.
    </p>
    <p>
      <% if session[:earn_or_sales] == "E" %>
        Here are the top 3 <%= session[:type].downcase %> stocks with the best value, the fastest earnings growth, and the most momentum.
      <% else %>
        Here are the top 3 <%= session[:type].downcase %> stocks with the best value, the fastest sales growth, and the most momentum.
      <% end %>
    </p>
  </div>
  <div class="value">
    <h2>Best Value <%= session[:type] %> Stocks</h2>
    <div class="value_intro">
      <p>
        <% if session[:earn_or_sales] == "E" %>
          These are the <%= session[:type].downcase %> stocks with the lowest 12-month trailing <a href="https://www.investopedia.com/terms/p/price-earningsratio.asp">price-to-earnings (P/E)</a> ratio. Because profits can be returned to shareholders in the form of dividends and buybacks, a low P/E ratio shows you’re paying less for each dollar of profit generated.
        <% else %>
          These are the <%= session[:type].downcase %> stocks with the lowest 12-month trailing <a href="https://www.investopedia.com/terms/p/price-to-salesratio.asp">price-to-sales (P/S)</a> ratio. For young companies that have not reached profitability, this can provide an idea of how much business you’re getting for each dollar invested.
        <% end %>
      </p>
    </div>
    <div class="table">
      <p>Best Value <%= session[:type] %> Stocks</p>
      <% if session[:earn_or_sales] == "E" %>
        <p> Price ($)   Market Cap ($...)    12-Month Trailing P/E Ratio</p>
      <% else %>
        <p> Price ($)   Market Cap ($...)    12-Month Trailing P/S Ratio</p>
      <% end %>
      <% @value.each do |_, data| %>
        <p>
          <%= data[:name] %>
          (<a href="https://www.investopedia.com/markets/quote?tvwidgetsymbol=<%= data[:ticker] %>"><%= data[:ticker] %></a>)
          <%= data[:price] %>
          <%= data[:market_cap] %>
          <%= data[:ratio] %>
        </p>
      <% end %>
      <p>Source: <a href="https://ycharts.com/">YCharts</a></p>
    </div>
    <div class="bullets">
      <ul>
        <% @value.each do |_, data| %>
          <li><b><%= data[:name] %>:</b> <%= data[:description] %></li>
        <% end %>
      </ul>
    </div>
  </div>
  <div class="growth">
    <h2>Fastest Growing <%= session[:type] %> Stocks</h2>
    <div class="growth_intro">
      <p>
        <% if session[:earn_or_sales] == "E" %>
          These are the <%= session[:type].downcase %> stocks with the highest year-over-year (YOY) <a href="https://www.investopedia.com/terms/e/eps.asp">earnings per share (EPS)</a> growth for the most recent quarter. Rising earnings show that a company’s business is growing and is generating more money that it can reinvest or return to shareholders.
        <% else %>
          These are the <%= session[:type].downcase %> stocks with the highest year over year (YOY) sales growth for the most recent quarter. Rising sales show that a company’s business is growing. This is often used to measure growth of young companies that have not yet reached profitability.
        <% end %>
      </p>
    </div>
    <div class="table">
      <p>Fastest Growing <%= session[:type] %> Stocks</p>
      <% if session[:earn_or_sales] == "E" %>
        <p> Price ($)   Market Cap ($...)    EPS Growth (%)</p>
      <% else %>
        <p> Price ($)   Market Cap ($...)    Revenue Growth (%)</p>
      <% end %>
      <% @growth.each do |_, data| %>
        <p>
          <%= data[:name] %>
          (<a href="https://www.investopedia.com/markets/quote?tvwidgetsymbol=<%= data[:ticker] %>"><%= data[:ticker] %></a>)
          <%= data[:price] %>
          <%= data[:market_cap] %>
          <%= data[:growth] %>
        </p>
      <% end %>
      <p>Source: <a href="https://ycharts.com/">YCharts</a></p>
    </div>
    <div class="bullets">
      <ul>
        <% @growth.each do |_, data| %>
          <li><b><%= data[:name] %>:</b> <%= data[:description] %></li>
        <% end %>
      </ul>
    </div>
  </div>
  <div class="momentum">
    <h2><%= session[:type] %> Stocks with the Most Momentum</h2>
    <div class="momentum_intro">
      <p>
        These are the <%= session[:type].downcase %> stocks that had the highest total return over the last 12 months.
      </p>
    </div>
    <div class="table">
      <p><%= session[:type] %> Stocks with the Most Momentum</p>
      <p> Price ($)    Market Cap ($...)   12-Month Trailing Total Return (%)</p>
      <% @momentum.each do |_, data| %>
        <p>
          <%= data[:name] %>
          (<a href="https://www.investopedia.com/markets/quote?tvwidgetsymbol=<%= data[:ticker] %>"><%= data[:ticker] %></a>)
          <%= data[:price] %>
          <%= data[:market_cap] %>
          <%= data[:momentum] %>
        </p>
      <% end %>
      <p>S&P 500 N/A N/A <%= session[:sp500_return].gsub("%", "") %></p>
      <p><%= session[:sector_index] %> N/A N/A <%= session[:index_return].gsub("%", "") %></p>
      <p>Source: <a href="https://ycharts.com/">YCharts</a></p>
    </div>
    <div class="bullets">
      <ul>
        <% @momentum.each do |_, data| %>
          <li><b><%= data[:name] %>:</b> <%= data[:description] %></li>
        <% end %>
      </ul>
    </div>
  </div>
  ```

* Update to change company description to `"See above for company description"` on the stock story page whenever there is a duplicate stock.

  ```ruby
  # ...
  
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
  
  # ...
  
  get "/stock_story" do
    @value_stocks = group_stock_data("value.xlsx")
    @growth_stocks = group_stock_data("growth.xlsx")
    @momentum_stocks = group_stock_data("momentum.xlsx")
    @tickers = unique_tickers(@value_stocks, @growth_stocks, @momentum_stocks)
    
    change_duplicate_stock_description(@value_stocks, @growth_stocks, @momentum_stocks)
  
    erb :stock_story
  end
  ```

---

### Best ETFs Stories

#### Implement ETF Data Submission Page

* Create a `get "/etfs"` route that the "Best ETFs" button on the home page will render when pushed.

  ```ruby
  get "/etfs" do
    erb :etfs
  end
  ```

* Create an `etfs.erb` view template that will render the ETF Data submission page.

  ```erb
  <h2>Best ETFs</h2>
  <form method="post" action="/stocks">
    <div>
      <label for="etf_1"> ETF 1:
        <input name="etf_1" id="etf_1" />
      </label>
    </div>
    <div>
      <label for="etf_2"> ETF 2:
        <input name="etf_2" id="etf_2" />
      </label>
    </div>
    <div>
      <label for="etf_3"> ETF 3:
        <input name="etf_3" id="etf_3" />
      </label>
    </div>
    <p>
      <button type="submit">Submit</button>
    </p>
  </form>
  <p>Or, update the ETF Company Description database.</p>
  <form class="inline" method="get" action="/etf_update">
    <button type="submit">Update Database</button>
  </form>
  ```

#### Retrieve the Data from `etfdb.com`

* Create methods in the `writer.rb` file that wil retrieve the data for the etfs.

  ```ruby
  # ...
  
  require "nokogiri"
  require "open-uri"
  
  # ...
  
  def extract_etf_html_data(ticker, type)
    url = etf_data_urls(ticker)[type]
    doc = Nokogiri::HTML(open(url))
  end
  
  def etf_profile_data(ticker)
    doc = extract_etf_html_data(ticker, :profile)
    data_array = doc.css('div.mm-main-container').css('div.col-sm-6').css('li').text.split("\n")
    data_array.delete("")
    profile_data = {}
  
    data_array.each_with_index do |elem, idx|
      case elem
      when "Issuer" then profile_data[:issuer] = data_array[idx + 1]
      when "Expense Ratio" then profile_data[:exp_ratio] = data_array[idx + 1]
      when "Inception" then profile_data[:date] = data_array[idx + 1]
      when "AUM" then profile_data[:aum] = data_array[idx + 1]
      when "3 Month Avg. Volume" then profile_data[:volume] = data_array[idx + 1]
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
      holdings << { ticker => company }
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
  ```

* Update `writer.rb` to include new routes.

  ```ruby
  # ...
  
  get "/etf_story" do
    erb :etf_story
  end
  
  # ...
  
  post "/etfs" do
    ticker_1 = params[:etf_1]
    ticker_2 = params[:etf_2]
    ticker_3 = params[:etf_3]
  
    session[:etf_1] = combined_etf_data(ticker_1)
    session[:etf_2] = combined_etf_data(ticker_2)
    session[:etf_3] = combined_etf_data(ticker_3)
  
    redirect "/etf_story"
  end
  ```

* Create an `etf_story.erb` view template.

  ```erb
  <div class="intro">
  </div>
  
  <div class="etf_1">
    <ul>
      <li>Performance over 1-Year: <%= session[:etf_1][:one_yr_return] %></li>
      <li>Expense Ratio: <%= session[:etf_1][:exp_ratio] %></li>
      <li>Annual Dividend Yield: <%= session[:etf_1][:div_yield]%></li>
      <li>3-Month Average Daily Volume: <%= session[:etf_1][:volume]%></li>
      <li>Assets Under Management: <%= session[:etf_1][:aum] %></li>
      <li>Inception Date: <%= session[:etf_1][:date] %></li>
      <li>Issuer: <%= session[:etf_1][:issuer] %></li>
    </ul>
  </div>
  
  <div class="etf_2">
    <ul>
      <li>Performance over 1-Year: <%= session[:etf_2][:one_yr_return] %></li>
      <li>Expense Ratio: <%= session[:etf_2][:exp_ratio] %></li>
      <li>Annual Dividend Yield: <%= session[:etf_2][:div_yield]%></li>
      <li>3-Month Average Daily Volume: <%= session[:etf_2][:volume]%></li>
      <li>Assets Under Management: <%= session[:etf_2][:aum] %></li>
      <li>Inception Date: <%= session[:etf_2][:date] %></li>
      <li>Issuer: <%= session[:etf_2][:issuer] %></li>
    </ul>
  </div>
  
  <div class="etf_3">
    <ul>
      <li>Performance over 1-Year: <%= session[:etf_3][:one_yr_return] %></li>
      <li>Expense Ratio: <%= session[:etf_3][:exp_ratio] %></li>
      <li>Annual Dividend Yield: <%= session[:etf_3][:div_yield]%></li>
      <li>3-Month Average Daily Volume: <%= session[:etf_3][:volume]%></li>
      <li>Assets Under Management: <%= session[:etf_3][:aum] %></li>
      <li>Inception Date: <%= session[:etf_3][:date] %></li>
      <li>Issuer: <%= session[:etf_3][:issuer] %></li>
    </ul>
  </div>
  ```

---

### Next Steps:

* Implement a company description database for the ETF stories.
* Implement an Admin signin button on the home page. This will be required to update any of the company description databases.
* Implement a way for the user to upload the `value.xlsx`, `growth.xlsx`, and `momentum.xlsx` files to the `data` directory.

#### Implement an Admin password section on the Company Database Update Page

* 