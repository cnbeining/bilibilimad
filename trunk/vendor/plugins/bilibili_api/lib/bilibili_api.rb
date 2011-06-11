#bilibili api
module BilibiliApi
  require 'digest/md5'
  require 'net/http'
  require 'rexml/document'
  Net::HTTP.version_1_2

  def correct_bili_name?
    unless session[:bili_name]
      key = Key.find_by_controller_and_app_id params[:controller], APP_ID
      raise unless key
      if params[:uname]
        if params[:hash] == Digest::MD5.hexdigest(%!API:#{params[:uname]}:#{params[:rank]}:#{key.sec_key}!)
            session[:bili_name] = params[:uname]
            session[:bili_rank] = params[:rank]
            session[:access_key] = params[:access_key]
        else
         return render :text => "You are good person!"
        end
      else
        redirect_to %[https://secure.bilibili.us/login.php?api=#{key.url}&hash=#{key.bili_key}]
      end
    end
  end

  def limit_bili_users
    if current_bili_user
      unless session[:key_user_id] && session[:controller] == params[:controller]
        ary = KeyUser.find :all, :include => :key,
                       :conditions => ["keys.controller = ? and keys.app_id = ?", params[:controller], APP_ID]
        current_key_user_id = ary.detect{|ar| ar.access_key == bili_access_key}
        if current_key_user_id && current_key_user_id.uname == current_bili_user
          session[:key_user_id] = current_key_user_id.id
          session[:controller] = params[:controller]
        elsif current_key_user_id
          flash[:notice] = "您可能换过昵称了，请找相关人重新确认下权限"
          return render :action => "biliapis/no_allow"
        else
          current_key_user_id = ary.detect{|ar| ar.uname == current_bili_user}
          if current_key_user_id && current_key_user_id.access_key.nil?
            session[:key_user_id] = current_key_user_id.id
            session[:controller] = params[:controller]
            current_key_user_id.update_attribute :access_key, bili_access_key
          else
            return render :action => "biliapis/no_allow"
          end
        end
      end
    end
  end

  def deny_bili_users
    if current_bili_user
      ary = KeyUser.find :all, :select => "uname", :include => :key,
                       :conditions => ["keys.controller = ? and keys.app_id = ?", params[:controller], APP_ID]
      return render :action => "no_allow", :layout => "need_bili_name" if ary.collect(&:uname).include?(current_bili_user)
    end
  end

  def current_bili_user
    session[:bili_name]
  end

  def current_bili_user? uname
    uname == session[:bili_name]
  end

  def bili_rank
    session[:bili_rank]
  end

  def bili_access_key
    session[:access_key]
  end

  def logout
    reset_session
    redirect_to root_path
  end
end
