class Freecen1FixedDatEntry
  include Mongoid::Document
  field :piece_number, type: Integer
  field :district_name, type: String
  field :subplaces, type: Array
  field :parish_number, type: Integer
  field :suffix, type: String
  belongs_to :freecen1_fixed_dat_file
  has_one :freecen_piece
end