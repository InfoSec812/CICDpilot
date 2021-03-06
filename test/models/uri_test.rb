require 'test_helper'

class UriTest < ActiveSupport::TestCase
  def setup
    ::Sunspot.session = ::Sunspot::Rails::StubSessionProxy.new(::Sunspot.session)
    setup_api_user
    @indicator1 = Indicator.create(title:"A",description:"B",indicator_type:"Benign")
    @uri1 = Uri.create!(uri_input:'http://www.cnn.com')
    @observable1 = Observable.create(indicator: @indicator1, object: @uri1)
  end
  
  def teardown
    @observable1 = nil
    @indicator1 = nil
    @uri1 = nil
    ::Sunspot.session = ::Sunspot.session.original_session
  end

  test "get list of indicators" do
    assert @uri1.indicators == [@indicator1]
  end

  test "get list of observables" do
    assert @uri1.observables == [@observable1]
  end
  
  test "total_sightings returns 0 with no sightings" do
    # No sightings
    assert_equal 0, @uri1.total_sightings
    
    # No indicator
    uri2 = Uri.create!(uri_input: 'http://www.cnn-2.com')
    observable2 = Observable.create!(object: uri2)
    assert_equal 0, uri2.total_sightings
    
    # No observable
    uri3 = Uri.create!(uri_input: 'http://www.cnn-3.com')
    assert_equal 0, uri3.total_sightings
  end
  
  test "total_sightings returns count from one indicator" do
    sight1 = Sighting.create(sighted_at: Time.now, description: 'Test Sighting')
    @indicator1.sightings << sight1
    
    assert_equal 1, @uri1.total_sightings
  end
  
  test "total_sightings returns count from multiple indicators" do
    sight1 = Sighting.create(sighted_at: Time.now, description: 'Test Sighting 1')
    sight2 = Sighting.create(sighted_at: Time.now, description: 'Test Sighting 2')
    @indicator1.sightings << sight1
    @indicator1.sightings << sight2
    
    indicator2 = Indicator.create(title:"A2",description:"B2",indicator_type:"Benign")
    observable2 = Observable.create(indicator: indicator2, object: @uri1)
    
    sight3 = Sighting.create(sighted_at: Time.now, description: 'Test Soghting 2')
    indicator2.sightings << sight3
    
    assert_equal 3, @uri1.total_sightings
  end
end
