class ReportPolicy < ApplicationPolicy
  def view?
    user.admin? || user.auditor?
  end

  %w(card_allocation? transactions? services? clinics?).each do |method|
    alias_method method.to_sym, :view?
  end
end

