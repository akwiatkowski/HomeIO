# Some other constants

class MetarConstants
  # filename
  #CONFIG_TYPE = 'metar'
  CONFIG_TYPE = 'MetarLogger'

  # czyste logi
  METAR_LOG_DIR = "metar_log"

  # type when is just downloaded
  METAR_CODE_JUST_DOWNLOADED = :fresh
  # type when is loaded from raw logs
  METAR_CODE_RAW_LOGS = :archived

end
