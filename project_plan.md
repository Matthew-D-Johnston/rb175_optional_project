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

#### Company Database

