require "rails_helper"

RSpec.describe Factura, type: :model do
  it "is valid with fecha_factura" do
    factura = build(:factura)

    expect(factura).to be_valid
  end

  it "requires fecha_factura" do
    factura = build(:factura, fecha_factura: nil)

    expect(factura).not_to be_valid
  end
end
