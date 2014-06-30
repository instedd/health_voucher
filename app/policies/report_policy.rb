class ReportPolicy < ApplicationPolicy
  def view?
    user.admin? || user.auditor?
  end

  %i(card_allocation? transactions? services? clinics?).each do |method|
    alias_method method, :view?
  end
end

