class Location < CouchRest::ExtendedDocument  
  # Include the validation module to get access to the validation methods
  include CouchRest::Validation
  # set the auto_validation before defining the properties
  auto_validate!
  
  # Set the default database to use
  use_database TEST_SERVER.default_database
  
  # Official Schema
  property :city, :default => "Ciudad de Buenos Aires"
  property :state, :default => "Buenos Aires"
  property :zip
  
  timestamps!
  
  
end