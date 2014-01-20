namespace :foo do

 desc "Process the freereg1_csv_entries and check that there is a corresponding SearchRecords document"
  # eg foo:check_search_records[100000]
  #num is the number of records to be checked
  task :check_search_records, [:num] do |t, args| 
    require 'check_search_records'
 	Mongoid.unit_of_work(disable: :all) do
      limit = args.num 
      puts "Checking the existence of search record documents for the first #{limit} freereg1_csv_entries "
  	  CheckSearchRecords.process(limit)
      puts "Completed Checking #{limit} Search records"
    end
 end

desc "Create master_place_names from gazetteer  "
task :create_master_place_names_from_gazetteer, [:type, :add_url]  => [:environment] do |t, args| 
  # if type is rebuild then the currrent collection will be deleted and a complete new collection made
  #if anything else eg add then existing entries will be skipped over and new ones added
  # if add url is set to add_url then genuki lookup happens
  require 'create_master_place_names_from_gazetteer'
  require 'master_place_name'
  type_of_build = args.type
  add_url = args.add_url
  puts "Creating Place Names Gazetteer Documents with type #{type_of_build} and url #{add_url} "
  
    CreateMasterPlaceNamesFromGazetteer.process(type_of_build,add_url)
  puts "Collection created, now creating indexes"
  MasterPlaceName.create_indexes()
  puts "Task complete."
end

desc "Add Genuki URL to master_place_names  "
task :add_genuki_url_to_master_place_name, [:type, :add_url] => [:environment]  do |t, args| 
  # if type is rebuild then the currrent collection will be deleted and a complete new collection made
  #if anything else eg add then existing entries will be skipped over and new ones added
  # if add url is set to add_url then genuki lookup happens
  require 'add_genuki_url_to_master_place_name'
   
  type_of_build = args.type
  add_url = args.add_url
  puts "Adding Genuki URL to Master Place Name Documents with type #{type_of_build} and url #{add_url} "
  
    AddGenukiUrlToMasterPlaceName.process(type_of_build,add_url)
  
  puts "Task complete."
end

desc "Add lat and lon to place documents"
task :add_lat_lon_to_place, [:type]  => [:environment] do |t, args| 
  require 'add_lat_lon_to_place'
  require 'place'
  type_of_build = args.type
  puts "Adding lat and lon to place documents #{type_of_build}"
  
    AddLatLonToPlace.process(type_of_build)

  puts "Collection modification complete, now creating indexes."

  Place.create_indexes()
  puts "Task complete."
end

desc "check place documents"
task :check_place_docs, [:type]  => [:environment] do |t, args| 
  require 'master_place_name'
  require 'check_place_records'
  require 'place'
  type_of_build = args.type
  puts "Check Place Docs in Gazetteer"
  
    CheckPlaceRecords.process(type_of_build)

  
  puts "Task complete."
end

end



  


