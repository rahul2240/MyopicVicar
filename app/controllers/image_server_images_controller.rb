class ImageServerImagesController < ApplicationController
  require 'userid_role'
 
  skip_before_filter :require_login, only: [:show]

  def destroy
    display_info
    image_server_image = ImageServerImage.where(:id=>params[:id]).first
    return_location = image_server_image.image_server_group
#    image_server_image.destroy

#    flash[:notice] = 'Deletion of image"'+image_server_image[:image_set]+'_'+image_server_image[:seq]+'.jpg" was successful'
    flash[:notice] = 'Deletion of image is not supported currently'
    redirect_to image_server_image_path(return_location)
  end

  def detail
    display_info
    @image = ImageServerImage.collection.aggregate([
                {'$match'=>{"_id"=>BSON::ObjectId.from_string(params[:id])}},
                {'$lookup'=>{from: "image_server_groups", localField: "image_server_group_id", foreignField: "_id", as: "image_group"}}, 
                {'$unwind'=>"$image_group"}
             ]).first
  end

  def display_info
    @register = Register.find(:id=>session[:register_id])
    @register_type = RegisterType.display_name(@register.register_type)
    @church = Church.find(session[:church_id])
    @church_name = session[:church_name]
    @county =  session[:county]
    @place_name = session[:place_name]
    @place = @church.place #id?
    @county =  @place.county
    @place_name = @place.place_name
    @user = cookies.signed[:userid]
    @source = Source.find(:id=>session[:source_id])
    @group = ImageServerGroup.find(:id=>session[:image_server_group_id])
  end

  def edit
    display_info

    @image_server_image = ImageServerImage.id(params[:id]).first
    image_server_group = @image_server_image.image_server_group
    get_sorted_group_name(image_server_group.source_id)

    if @image_server_image.nil?
      flash[:notice] = 'Attempted to edit a non_esxistent image file'
      redirect_to :back
      return
    end
  end

  def get_sorted_group_name(source_id)    # get hash key=image_server_group_id, val=ig, sorted by ig
    ig_array = ImageServerGroup.where(:source_id=>source_id).pluck(:id, :group_name)
    @group_name = Hash[ig_array.map {|key,value| [key,value]}]
    @group_name = @group_name.sort_by{|key,value| value.downcase}.to_h
  end

  def index
    @is_image = IsImage.where(:source_id => @source_id).all.order_by(group_name: 1)
  end

  def move
    display_info

    @image_server_group = ImageServerGroup.id(params[:id]).first
    get_sorted_group_name(@image_server_group[:source_id])

    @image_server_image = ImageServerImage.where(:image_server_group_id=>params[:id]).first
#    @test = ImageServerImage.where(:image_server_group_id=>params[:id])
    seq = ImageServerImage.where(:image_server_group_id=>params[:id]).pluck(:seq, :image_set)

    myseq = Hash.new{|h,k| h[k] = []}
    @images = Hash[seq.map {|k,v| [k, myseq[k] = v.to_s+'_'+k.to_s]}]   #get new hash key=:seq, val=:image_set+:seq

    if @image_server_image.nil?
      flash[:notice] = 'Attempted to edit a non_esxistent image file'
      redirect_to :back
      return
    end
  end

  def new      
    get_user_info_from_userid
    @county =  session[:county]
    @place_name = session[:place_name]
    @church_name =  session[:church_name]
    @place = Place.find(session[:place_id])
    @church = Church.find(session[:church_id])
    @register = Register.new
  end

  def show
    session[:image_server_group_id] = params[:id]
    display_info

    @image_server_image = ImageServerImage.where(:image_server_group_id=>params[:id])
    @image_server_group = ImageServerGroup.where(:id=>session[:image_server_group_id]).first

    if @image_server_image.empty?
      flash[:notice] = 'No Images under Image Group "'+@image_server_group.group_name.to_s+'"'
      redirect_to image_server_group_path(@image_server_group.source)
    else
      flash.clear
    end
  end

  def update
    case params[:image_server_image][:seq].class.to_s
      when 'String'
        seq = [] << params[:image_server_image][:seq]     # from edit.html.erb
      when 'Array'
        seq = params[:image_server_image][:seq]           # from move.html.erb
    end

    image_server_group = ImageServerGroup.where(:id=>params[:image_server_image][:image_server_group_id]).first
    image_server_image = ImageServerImage.where(:image_server_group_id=>params[:image_server_image][:orig_image_server_group_id], :seq=>{'$in'=>seq})

    if image_server_image.nil?
      flash[:notice] = 'Image "'+params[:image_server_image][:image_set]+'_'+params[:image_server_image][:seq].to_s+'.jpg" does not exist'
      redirect_to image_server_group_path(return_location)
    else
      image_server_image.where(:image_server_group_id=>params[:image_server_image][:orig_image_server_group_id], :seq=>{'$in'=>seq}).update_all(:image_server_group_id=>params[:image_server_image][:image_server_group_id])
      flash[:notice] = 'Update of the Image file(s) was successful'
      redirect_to image_server_image_path(image_server_group)
    end
  end

  private
  def image_server_image_params
    params.require(:image_server_image).permit!
  end

end
