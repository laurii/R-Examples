#' Weather data for yesterday
#' 
#' @param location location set by set_location
#' @param use_metric Metric or imperial units
#' @param key weather underground API key
#' @param raw if TRUE return raw httr object
#' @param message if TRUE print out requested URL
#' @param summary If TRUE return daily summary otherwise hourly data
#' @return tbl_df with date, temperature, dew point,
#'         humidity, wind speed, gust and direction, 
#'         visibility, pressure, wind chill, heat index,
#'         precipitation, condition, fog, rain, snow,
#'         hail, thunder, tornado
#' @export 
#' @examples
#' \dontrun{
#' yesterday(set_location(territory = "Hawaii", city = "Honolulu"))
#' yesterday(set_location(territory = "Iowa", city = "Iowa City"))
#' yesterday(set_location(territory = "Iraq", city = "Baghdad"))
#' yesterday(set_location(territory = "IR", city = "Tehran"), summary = TRUE)
#' }
yesterday = function(location, 
                   	 use_metric = FALSE, 
                     key = get_api_key(), 
                     raw = FALSE, 
                     message = TRUE,
                     summary = FALSE) {

  parsed_req = wunderground_request(request_type = "yesterday",
                                    location = location, 
                                    key = key,
                                    message = message)
  if(raw) {
    return(parsed_req)
  }
  stop_for_error(parsed_req)

  if(!("history" %in% names(parsed_req))) {
    stop(paste0("Cannot parse yesterday's weather information for: ", location))
  }

  hist = parsed_req$history
  suffix = ifelse(use_metric, "m", "i")
  if(summary) {
    ds = hist$dailysummary[[1]]
    df = data.frame( 
       date = as.POSIXct(
         paste0(ds$date$year, "-", ds$date$mon, "-", ds$date$mday, " ",
          ds$date$hour, ":", ds$date$min), tz = ds$date$tzname
       ),
       fog = as.numeric(ds$fog),
       rain = as.numeric(ds$rain),
       snow = as.numeric(ds$snow),
       snow_fall = as.numeric(ds[[paste0("snowfall", suffix)]]),
       mtd_snow = as.numeric(ds[[paste0("monthtodatesnowfall", suffix)]]),
       since_jul_snow = as.numeric(ds[[paste0("since1julsnowfall", suffix)]]),
       snow_depth = as.numeric(ds[[paste0("snowdepth", suffix)]]),
       hail = as.numeric(ds$hail),
       thunder = as.numeric(ds$thunder),
       tornado = as.numeric(ds$tornado),
       mean_temp = as.numeric(ds[[paste0("meantemp", suffix)]]),
       mean_dewp = as.numeric(ds[[paste0("meandewpt", suffix)]]),
       mean_pressure = as.numeric(ds[[paste0("meanpressure", suffix)]]),
       mean_wind_spd = as.numeric(ds[[paste0("meanwindspd", suffix)]]),
       mean_wind_dir = as.numeric(ds$meanwdird),
       mean_visib = as.numeric(ds[[paste0("meanvis", suffix)]]),
       humid = as.numeric(ds$humidity),
       max_temp = as.numeric(ds[[paste0("maxtemp", suffix)]]),
       min_temp = as.numeric(ds[[paste0("mintemp", suffix)]]),
       max_humid = as.numeric(ds$maxhumidity),
       min_humid = as.numeric(ds$minhumidity),
       max_dew_pt = as.numeric(ds[[paste0("maxdewpt", suffix)]]),
       min_dew_pt = as.numeric(ds[[paste0("mindewpt", suffix)]]),
       max_pressure = as.numeric(ds[[paste0("maxpressure", suffix)]]),
       min_pressure = as.numeric(ds[[paste0("minpressure", suffix)]]),
       max_wind_spd = as.numeric(ds[[paste0("maxwspd", suffix)]]),
       min_wind_spd = as.numeric(ds[[paste0("minwspd", suffix)]]),
       max_vis = as.numeric(ds[[paste0("maxvis", suffix)]]),
       min_vis = as.numeric(ds[[paste0("minvis", suffix)]]),
       gdegree = as.numeric(ds$gdegreedays),
       heating_days = as.numeric(ds$heatingdegreedays),
       cooling_days = as.numeric(ds$coolingdegreedays),
       precip = as.numeric(ds[[paste0("precip", suffix)]]),
       precip_source = ds$precipsource,
       heating_day_normal = as.numeric(ds$heatingdegreedaysnormal),
       mtd_heating_degree = as.numeric(ds$monthtodateheatingdegreedays),
       mtd_heating_degree_normal = as.numeric(ds$monthtodateheatingdegreedaysnormal),
       since_sep_heating = as.numeric(ds$since1sepheatingdegreedays), 
       since_sep_heating_normal = as.numeric(ds$since1sepheatingdegreedaysnormal),
       since_jul_heating = as.numeric(ds$since1julheatingdegreedays),
       since_jul_heating_normal = as.numeric(ds$since1julheatingdegreedaysnormal),
       cooling_degree_normal = as.numeric(ds$coolingdegreedaysnormal),
       mtd_cooling_day = as.numeric(ds$monthtodatecoolingdegreedays),
       mtd_cooling_day_normal = as.numeric(ds$monthtodatecoolingdegreedaysnormal),
       since_sep_cooling = as.numeric(ds$since1sepcoolingdegreedays),
       since_sep_cooling_normal = as.numeric(ds$since1sepcoolingdegreedaysnormal),
       since_jan_cooling = as.numeric(ds$since1jancoolingdegreedays),
       since_jan_cooling_normal = as.numeric(ds$since1jancoolingdegreedaysnormal)
    )

    return(
      dplyr::tbl_df(df)
    )
  } 

  df = lapply(hist$observations, function(x) {
    data.frame(
       date = as.POSIXct(
         paste0(x$date$year, "-", x$date$mon, "-", x$date$mday, " ",
          x$date$hour, ":", x$date$min), tz = x$date$tzname
       ),
       temp = as.numeric(x[[paste0("temp", suffix)]]),
       dew_pt = as.numeric(x[[paste0("dewpt", suffix)]]),
       hum = as.numeric(x$hum),
       wind_spd = as.numeric(x[[paste0("wspd", suffix)]]),
       wind_gust = as.numeric(x[[paste0("wgust", suffix)]]),
       dir = x$wdire,
       vis = as.numeric(x[[paste0("vis", suffix)]]),
       pressure = as.numeric(x[[paste0("pressure", suffix)]]),
       wind_chill = as.numeric(x[[paste0("windchill", suffix)]]),
       heat_index = as.numeric(x[[paste0("heatindex", suffix)]]),
       precip = as.numeric(x[[paste0("precip", suffix)]]),
       cond = x$conds,
       fog = as.numeric(x$fog),
       rain = as.numeric(x$rain),
       snow = as.numeric(x$snow),
       hail = as.numeric(x$hail),
       thunder = as.numeric(x$thunder),
       tornado = as.numeric(x$tornado),
        stringsAsFactors = FALSE
      )
  })

  encode_NA(
    dplyr::bind_rows(df)
  )
}