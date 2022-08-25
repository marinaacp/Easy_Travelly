class BookingPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end

  def edit?
    owner?
  end

  def update?
    owner?
  end

  private

  def owner?
    record.trip.user == user
  end
end
