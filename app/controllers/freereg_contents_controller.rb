class FreeregContentsController < ApplicationController
  skip_before_filter :require_login
  
  def index
    
    redirect_to :action => :new
  end
  

  def show

   @county = params[:id]
   @chapman_code = ChapmanCode.values_at( @county)
   @places = Places.where(:data_present => true).all.order_by(place_name: 1).page(page) if @county == 'all'
   @places = Place.where(:chapman_code => @chapman_code, :data_present => true).all.order_by(place_name: 1).page(params[:page])  unless @county == 'all'
   session[:page] = request.original_url
   session[:county] = @county
   session[:county_id]  = params[:id]
 
  end
  def show_place
     @place = Place.find(params[:id])
     @county =  @place.county
     @country = @place.country
     @place_name = @place.place_name
     @names = @place.get_alternate_place_names
     @stats = @place.data_contents   
     @county_id =  session[:county_id]
     session[:place] = @place_name
     session[:place_id] = @place._id
    
    
   
  end

  def show_church
     @church = Church.find(params[:id])
     @stats = @church.data_contents 
     @place_name = @church.place.place_name
     @place = @church.place
     @county = @place.county
     @church_name = @church.church_name
     @county_id =  session[:county_id]
     @registers = Register.where(:church_id => params[:id]).order_by(:record_types.asc, :register_type.asc, :start_year.asc).all
  end

  def show_register
     @register = Register.find(params[:id])
     @church  = @register.church
     @place = @church.place
     @county = @place.county
     session[:county] = @county
     @files_id = Array.new
     @place_name = @place.place_name
     session[:place] = @place_name
     session[:place_id] = @place._id
     @county_id =  session[:county_id]
     session[:register_id] = params[:id]
     @register_name = @register.register_name 
     @register_name = @register.alternate_register_name if @register_name.nil?
     session[:register_name] = @register_name
     @church = @church.church_name
     individual_files = Freereg1CsvFile.where(:register_id =>params[:id]).order_by(:record_types.asc, :start_year.asc).all
     @files = Freereg1CsvFile.combine_files(individual_files)
    

  end
  
  def show_decade
    @files_id = session[:files]
    @register_id = session[:register_id]
     @register_name =  session[:register_name] 
       @county_id =  session[:county_id]
       individual_files = Freereg1CsvFile.where(:register_id => @register_id).order_by(:record_types.asc, :start_year.asc).all
       @files = Freereg1CsvFile.combine_files(individual_files)
       @files.each do |my_file|
         @record_type = RecordType.display_name(my_file.record_type)
         if @record_type == params[:id] then
            @decade = my_file.daterange
          end
       end
     @record_type = params[:id]  
     @place = Place.find(session[:place_id])
     @church  = session[:church]
     @place_name = session[:place]
     @county = session[:county]
   end

end
