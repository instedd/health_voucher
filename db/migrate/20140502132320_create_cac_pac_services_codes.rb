class CreateCacPacServicesCodes < ActiveRecord::Migration
  def up
    connection.execute "UPDATE services SET description = 'CAC – Medical Safe abortion (TOP) - mifepristone and misoprostol (MA)', " +
      "short_description = 'CAC Medical' WHERE code = '71'"
    connection.execute "UPDATE services SET description = 'CAC – Surgical Safe abortion (TOP) - vacuum aspiration (MVA)/surgical', " +
      "short_description = 'CAC Surgical' WHERE code = '72'"
    connection.execute "INSERT INTO services " +
      "(service_type, description, short_description, code, created_at, updated_at) VALUES " +
      "('primary', 'PAC – Medical Incomplete abortion (PAC) - misoprostol (MPAC)', 'PAC Medical', '73', NOW(), NOW())"
    connection.execute "INSERT INTO services " +
      "(service_type, description, short_description, code, created_at, updated_at) VALUES " +
      "('primary', 'PAC – Surgical Incomplete abortion (PAC) - vacuum aspiration (MVA)/surgical', 'PAC Surgical', '74', NOW(), NOW())"
  end

  def down
  end
end

