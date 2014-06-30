class CardPolicy < ApplicationPolicy
  def manage?
    user.admin? || (user.site_manager? && 
                    record.patient.present? && record.patient.site.manager == user)
  end

  %w(start_validity? set_expiration?).each do |method|
    alias_method method.to_sym, :manage?
  end
end

