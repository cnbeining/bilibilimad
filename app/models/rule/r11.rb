class Rule::R11 < Rule::R10

  E_S = 100

  def get_ranking_point
    self[:score] = click.to_f / part + stow * stow_revised + tj_point
  end

  def tj_point
    if weekly_id
      self.class.tj_point yb, tj, click, work_id, weekly_id
    else
      self.class.tj_point yb, tj, click, work_id, Weekly.last.id + 1
    end
  end

  def self.tj_point yb, tj, click, work_id, weekly_id
    if click > 5000 && self.count(:conditions => ["work_id = ? and weekly_id < ?", work_id, weekly_id]) == 1
      first_r = self.first(:conditions => ["work_id = ? and weekly_id < ?", work_id, weekly_id])
      yb += first_r.yb
      tj += first_r.tj
    end
    0 - [[yb * 100 + tj, 21000].min - 1000, 0].max
  end
end
