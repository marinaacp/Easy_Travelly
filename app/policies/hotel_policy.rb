class HotelPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end

  def new?
    owner?
  end

  def create?
    owner?
  end

  private

  def owner?
    record.trip.user == user
  end
end
