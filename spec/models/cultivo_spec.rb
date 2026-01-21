require 'rails_helper'

RSpec.describe Cultivo, type: :model do
  it { should validate_presence_of(:nombre) }
  it { should validate_uniqueness_of(:nombre) }
end
