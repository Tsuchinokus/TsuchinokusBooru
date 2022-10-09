defimpl Tsuchinokus.Attribution, for: Tsuchinokus.Reports.Report do
  def object_identifier(report) do
    to_string(report.id)
  end

  def best_user_identifier(report) do
    to_string(report.user_id || report.fingerprint || report.ip)
  end

  def anonymous?(_report) do
    false
  end
end
