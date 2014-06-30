class StatementPolicy < ApplicationPolicy
  def index?
    user.admin? || user.auditor?
  end

  def show?
    user.admin? || user.auditor?
  end

  def destroy?
    user.admin?
  end

  def toggle_status?
    user.admin?
  end

  def generate?
    user.admin?
  end

  def export?
    user.admin? || user.auditor?
  end
end


