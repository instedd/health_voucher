class CardPolicy < ApplicationPolicy
  def manage?
    user.admin? || (user.site_manager? && 
                    record.patient.present? && record.patient.site.manager == user)
  end

  %i(start_validity? set_expiration?).each do |method|
    alias_method method, :manage?
  end
end

