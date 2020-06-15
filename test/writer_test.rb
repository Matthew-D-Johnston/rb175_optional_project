ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require "fileutils"

require_relative "../writer"

class WriterTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def session
    last_request.env["rack.session"]
  end

  def create_document(name, content = "")
    File.open(File.join(data_path, name), "w") do |file|
      file.write(content)
    end
  end

  def test_home
    get "/"

    assert_equal(200, last_response.status)
    assert_equal("text/html;charset=utf-8", last_response["Content-Type"])
    assert_includes(last_response.body, "Welcome")
    assert_includes(last_response.body, "press the appropriate button")
  end

  def test_top_stocks_page
    get "/stocks"

    assert_equal(200, last_response.status)
    assert_includes(last_response.body, "Top Stocks")
    assert_includes(last_response.body, "Sector Index")
    assert_includes(last_response.body, "Company Description database")
  end

  def test_stock_data_sumbission
    post "/stocks", {type: "Type"}

    assert_equal(302, last_response.status)

    skip
    
    get "/stock_story"

    assert_equal(200, last_response.status)
    assert_includes(last_response.body, "Headings")
    assert_includes(last_response.body, "Best Value")
    assert_includes(last_response.body, "Fastest Growing")
    assert_includes(last_response.body, "Most Momentum")
  end

  def test_company_update_page
    get "/update"

    assert_equal(200, last_response.status)
    assert_includes(last_response.body, "Database Update")
    assert_includes(last_response.body, "Company Name")
    assert_includes(last_response.body, "Company Description")
  end

  def test_company_description_database_updated
    create_document("company_descriptions.yml")

    post "/update", name: "My Company", description: "My Company makes things."

    assert_includes(session[:message], "Database has been updated")
  end
end