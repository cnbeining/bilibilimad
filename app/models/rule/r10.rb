class Rule::R10 < Result

  E_S = 100

   def self.version
       self.to_s.split('::R').last.to_f / 10
   end

  def get_ranking_point
    click.to_f / part + stow * stow_revised - [yb * 100 + tj, 20000].min
  end

  def point
    get_ranking_point
  end

  def self.get_stow_revised stow
    if stow <= 100
      E_S
    else
      fixed = (E_S*100 + 20*(stow - 100))/stow.to_f
      format("%.2f", fixed).to_f
    end
  end

  def stow_revised
    self.class.get_stow_revised stow
  end
end
