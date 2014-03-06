class PlacesController < InheritedResources::Base
  rescue_from Mongoid::Errors::DeleteRestriction, :with => :record_cannot_be_deleted
  rescue_from Mongoid::Errors::Validations, :with => :record_validation_errors
  
  def index
          @chapman_code = session[:chapman_code]
          @places = Place.where( :chapman_code => @chapman_code ).all.order_by( place_name: 1)
          @county = session[:county]
          @first_name = session[:first_name]
           @user = UseridDetail.where(:userid => session[:userid]).first
  end

  def list
          
  end

  def show
    p "show"
          load(params[:id])
         
          @places = Place.where( :chapman_code => @chapman_code ).all.order_by( place_name: 1)
         
          session[:errors] = nil
          session[:form] = nil
          session[:parameters] = params
          
          @names = Array.new
         @alternate_place_names = @place.alternateplacenames.all
         p "at place"
         p  @alternate_place_names
         @alternate_place_names.each do |acn|
          name = acn.alternate_name
          @names << name
         end
         p @names
   end

  def edit
     load(params[:id])
     placenames = MasterPlaceName.where(:chapman_code => session[:chapman_code]).all.order_by(place_name: 1)
      @placenames = Array.new
        placenames.each do |placename|
          @placenames << placename.place_name
        end
  end

def new
      if session[:errors].nil?
      #coming through new for the first time so get a new instance
      @place = Place.new
      @place.chapman_code = session[:chapman_code]
      session[:form] = @place
      @county = session[:county]
      placenames = MasterPlaceName.where(:chapman_code => session[:chapman_code]).all.order_by(place_name: 1)
      @placenames = Array.new
        placenames.each do |placename|
          @placenames << placename.place_name
        end
      session[:errors] = nil
      @first_name = session[:first_name]
       @user = UseridDetail.where(:userid => session[:userid]).first
    else
     @first_name = session[:first_name]
      @place = session[:form]
      @county = session[:county]
    end
      @user = UseridDetail.where(:userid => session[:userid]).first
  end
 
def create
   session[:errors] = nil
   @user = UseridDetail.where(:userid => session[:userid]).first
   @place = Place.new
     # save place name change in Place
    @place.place_notes = params[:place][:place_notes] unless params[:place][:place_notes].nil?
    @place.place_name = params[:place][:place_name] unless params[:place][:place_name].nil?
    @place.alternate_place_name = params[:place][:alternate_place_name] unless params[:place][:alternate_place_name].nil?
    @place.chapman_code = session[:chapman_code]
     @place.alternateplacenames_attributes = [{:alternate_name => params[:place][:alternateplacename][:alternate_name]}] unless params[:place][:alternateplacename][:alternate_name] == ''
    @place.save
    flash[:notice] = 'The addition of the Place was succsessful'
   if @place.errors.any?
     session[:errors] = @place.errors.messages
     flash[:notice] = "The addition of the Place #{@place.place_name} was unsuccsessful"
     placenames = MasterPlaceName.where(:chapman_code => session[:chapman_code]).all.order_by(place_name: 1)
      @placenames = Array.new
        placenames.each do |placename|
          @placenames << placename.place_name
        end
     render :action => 'new'
     return
 else
     redirect_to places_path
 end
end

def update
    load(params[:id])
    # save place name change in Place
    
    old_place_name = @place.place_name

    @place.master_place_lon = params[:place][:master_place_lon] unless params[:place][:master_place_lon].nil?
    @place.master_place_lat = params[:place][:master_place_lat] unless params[:place][:master_place_lat].nil?
    @place.genuki_url = params[:place][:genuki_url] unless params[:place][:genuki_url].nil?
    @place.place_notes = params[:place][:place_notes] unless params[:place][:place_notes].nil?
    @place.place_name = params[:place][:place_name] unless params[:place][:place_name].nil?
    @place.alternate_place_name = params[:place][:alternate_place_name] unless params[:place][:alternate_place_name].nil?
    @place.chapman_code = session[:chapman_code]
    @place.alternateplacenames_attributes = [{:alternate_name => params[:place][:alternateplacename][:alternate_name]}] unless params[:place][:alternateplacename][:alternate_name] == ''
    @place.alternateplacenames_attributes = params[:place][:alternateplacenames_attributes] unless params[:place][:alternateplacenames_attributes].nil?
    
    @place.save
  
   if @place.errors.any? then
     session[:form] = @place
     session[:errors] = @place.errors.messages
     flash[:notice] = 'The update of the Place was unsuccsessful'
     render :action => 'edit'
     return
    end
   
   unless old_place_name == params[:place][:place_name]
  
 # save place name change in Freereg_csv_file
    my_files = Freereg1CsvFile.where(:county => session[:chapman_code], :place => old_place_name).all
    if my_files
      my_files.each do |myfile|
        myfile.place = params[:place][:place_name]
        myfile.save!
 # save place name change in Freereg_csv_entry
        myfile_id = myfile._id
        my_entries = Freereg1CsvEntry.where(:freereg1_csv_file_id => myfile_id).all
        my_entries.each do |myentries|
            myentries.place = params[:place][:place_name]
            myentries.save!
        end
      end
    else
    end
  end
    flash[:notice] = 'The update the Place was succsessful'
  redirect_to places_path(:anchor => "#{@place.id}")
  end

  
  def load(place_id)
     @user = UseridDetail.where(:userid => session[:userid]).first
   @place = Place.find(place_id)
   session[:place_id] = place_id
   @place_name = @place.place_name
   session[:place_name] = @place_name
   @county = ChapmanCode.has_key(@place.chapman_code)
   session[:county] = @county
   @first_name = session[:first_name]

  end

 def destroy
    load(params[:id])
    @place.destroy
     session[:errors] = nil
    flash[:notice] = 'The deletion of the place was successful'
    if @place.errors.any? then
     @place.errors
     session[:form] = @place
     session[:errors] = @place.errors.messages
     flash[:notice] = 'The deletion of the place was unsuccessful'
    end

    redirect_to places_path
 end

 def record_cannot_be_deleted
   flash[:notice] = 'The deletion of the place was unsuccessful because there were dependant documents; please delete them first'
   session[:errors] = 'errors'
   redirect_to places_path
 end

 def record_validation_errors
   flash[:notice] = 'The update of the children to Place with a place name change failed'
   session[:errors] = 'errors'
   redirect_to places_path
 end
end