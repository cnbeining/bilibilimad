#name, wid, pa
namespace :bld do
  desc "Import scan result to database"
  task :save => :environment do
    date_now =  Time.now
    pa = ENV['pa'] ? "#{BILI_PRO_PATH}#{ENV['pa']}/" : nil
    id1 = ENV['id1'] || (YAML.load(open(File.join "#{Rails.root}/config/last.yml")) rescue 0)
    id2 = ENV['id2'] || OriScan.last.id
    except_ids = Except.all_avid rescue [-1]
    begin
      Weekly.transaction do
        weekly = Weekly.create! :name => ENV['name'], :wid => ENV['wid'], :last => Weekly.latest,
                                :index => ENV['index'] || Weekly.maximum('"index"').to_i + 1, :rule => Result.rule.version
      Result.stat(id1, id2, except_ids).each do |r|
        r.weekly_id = weekly.id
        r.save!
      end
      end
      File.open(%[#{Rails.root}/config/last.yml],"w"){ |io| YAML.dump id2.to_i,io }
    rescue
      p $!,$@
    end
    puts "#{Time.now - date_now} second complete"
  end
end
