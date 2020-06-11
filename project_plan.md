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

#### Top Stocks Page

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

* 