module ApplicationHelper
  include BilibiliApi

  #options: name, part
  def bili_video_link wid, options={}
     name = options[:name]
     part = options[:part]
     url = %[http://#{BILI_PATH}/video/av#{wid}/#{"index_#{part}.html" if part.to_i > 1}]
     link_to (name ? h(name) : "av#{wid}"), url, :target => "_blank"
  end

  def bili_mylist_link mylist_id, name=nil
     link_to (name ? h(name) : "mylist#{mylist_id}"), "http://#{BILI_PATH}/mylist#{mylist_id}", :target => "_blank"
  end
end
