module PatientsHelper
  def patient_path(patient)
    site_mentor_path(patient.site.id, patient.mentor_id) + "##{patient.id}"
  end
end
