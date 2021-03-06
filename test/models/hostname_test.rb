require 'test_helper'

class HostnameTest < ActiveSupport::TestCase
  def setup
    ::Sunspot.session = ::Sunspot::Rails::StubSessionProxy.new(::Sunspot.session)
    setup_api_user
    @indicator1 = Indicator.create(title:"A",description:"B",indicator_type:"Benign")
    @hostname1 = Hostname.create!(hostname_raw: 'hostname 1', naming_system: 'system 2')
    @observable1 = Observable.create(indicator: @indicator1, object: @hostname1)
  end
  
  def teardown
    @observable1 = nil
    @indicator1 = nil
    @hostname1 = nil
    ::Sunspot.session = ::Sunspot.session.original_session
  end

  test "get list of indicators" do
    assert @hostname1.indicators == [@indicator1]
  end

  test "get list of observables" do
    assert @hostname1.observables == [@observable1]
  end
  
  test "total_sightings returns 0 with no sightings" do
    # No sightings
    assert_equal 0, @hostname1.total_sightings
    
    # No indicator
    hostname2 = Hostname.create!(hostname_raw: 'hostname 2', naming_system: 'system 2')
    observable2 = Observable.create!(object: hostname2)
    assert_equal 0, hostname2.total_sightings
    
    # No observable
    hostname3 = Hostname.create!(hostname_raw: 'hostname 3', naming_system: 'system 2')
    assert_equal 0, hostname3.total_sightings
  end
  
  test "total_sightings returns count from one indicator" do
    sight1 = Sighting.create(sighted_at: Time.now, description: 'Test Sighting')
    @indicator1.sightings << sight1
    
    assert_equal 1, @hostname1.total_sightings
  end
  
  test "total_sightings returns count from multiple indicators" do
    sight1 = Sighting.create(sighted_at: Time.now, description: 'Test Sighting 1')
    sight2 = Sighting.create(sighted_at: Time.now, description: 'Test Sighting 2')
    @indicator1.sightings << sight1
    @indicator1.sightings << sight2
    
    indicator2 = Indicator.create(title:"A2",description:"B2",indicator_type:"Benign")
    observable2 = Observable.create(indicator: indicator2, object: @hostname1)
    
    sight3 = Sighting.create(sighted_at: Time.now, description: 'Test Soghting 2')
    indicator2.sightings << sight3
    
    assert_equal 3, @hostname1.total_sightings
  end
end
