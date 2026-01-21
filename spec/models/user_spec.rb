require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it { should validate_presence_of(:username) }
  it do
    create(:user)
    should validate_uniqueness_of(:username)
  end
end
