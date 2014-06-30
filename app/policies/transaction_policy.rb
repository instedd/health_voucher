class TransactionPolicy < ApplicationPolicy
  def index?
    user.admin? || user.auditor?
  end

  def update_status?
    user.admin?
  end
end


