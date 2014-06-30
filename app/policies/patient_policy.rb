class PatientPolicy < ApplicationPolicy
  def manage?
    user.admin? || (user.site_manager? && record.site.manager == user)
  end

  %w(assign_card? unassign_card? deactivate_card? destroy?).each do |method|
    alias_method method.to_sym, :manage?
  end
end

