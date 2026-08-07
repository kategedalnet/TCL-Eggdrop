# =====================================================================
# cuaca.tcl
# OpenWeather - Eggdrop 1.10.1
# Tcl 8.6.13
# Tanpa Tcllib / JSON package
#
# Command : .cuaca
# Channel : Semua channel yang bot join
# =====================================================================

# =====================================================================
# API KEY
# =====================================================================

set openweather_apikey "YOUR_API_KEY_FROM_OPENWEATHER"

# =====================================================================
# BIND
# =====================================================================

bind pub -|- .cuaca pub:cek_cuaca_warna

# =====================================================================
# JSON STRING
# =====================================================================

proc json_get_string {json key default} {

    set pattern [format {"%s"\s*:\s*"([^"]*)"} $key]

    if {[regexp -nocase $pattern $json -> value]} {
        return $value
    }

    return $default
}

# =====================================================================
# JSON NUMBER
# =====================================================================

proc json_get_number {json key default} {

    set pattern [format {"%s"[ \t]*:[ \t]*(-?[0-9]+([.][0-9]+)?)} $key]

    if {[regexp -nocase $pattern $json -> value]} {
        return $value
    }

    return $default
}

# =====================================================================
# ARAH ANGIN
# =====================================================================

proc wind_direction {deg} {

    if {$deg eq "-"} {
        return "-"
    }

    if {[catch {
        set index [expr {int(($deg + 22.5) / 45) % 8}]
    }]} {
        return "-"
    }

    set directions [list \
        "Utara" \
        "Timur Laut" \
        "Timur" \
        "Tenggara" \
        "Selatan" \
        "Barat Daya" \
        "Barat" \
        "Barat Laut" \
    ]

    return [lindex $directions $index]
}

# =====================================================================
# TERJEMAHAN KONDISI CUACA
# =====================================================================

proc translate_weather {weather} {

    switch -nocase -- $weather {

        "Clear" {
            return "Cerah"
        }

        "Clouds" {
            return "Berawan"
        }

        "Rain" {
            return "Hujan"
        }

        "Drizzle" {
            return "Gerimis"
        }

        "Thunderstorm" {
            return "Badai Petir"
        }

        "Snow" {
            return "Salju"
        }

        "Mist" {
            return "Kabut Tipis"
        }

        "Smoke" {
            return "Asap"
        }

        "Haze" {
            return "Udara Kabur"
        }

        "Dust" {
            return "Berdebu"
        }

        "Fog" {
            return "Kabut"
        }

        "Sand" {
            return "Pasir"
        }

        "Ash" {
            return "Abu Vulkanik"
        }

        "Squall" {
            return "Angin Kencang"
        }

        "Tornado" {
            return "Puting Beliung"
        }

        default {
            return $weather
        }
    }
}

# =====================================================================
# COMMAND .CUACA
# =====================================================================

proc pub:cek_cuaca_warna {nick uhost handle chan text} {

    global openweather_apikey

    # ---------------------------------------------------------------
    # API KEY
    # ---------------------------------------------------------------

    if {$openweather_apikey eq "" ||
        $openweather_apikey eq "API_KEY_KAMU"} {

        putserv "PRIVMSG $chan :$nick: API Key OpenWeather belum dikonfigurasi."

        return 0
    }

    # ---------------------------------------------------------------
    # NAMA KOTA
    # ---------------------------------------------------------------

    set city [string trim $text]

    if {$city eq ""} {

        putserv "PRIVMSG $chan :$nick: Gunakan: .cuaca <nama kota>"

        return 0
    }

    # ---------------------------------------------------------------
    # Encode spasi
    # ---------------------------------------------------------------

    set encoded [string map [list " " "%20"] $city]

    # ---------------------------------------------------------------
    # URL OpenWeather
    # ---------------------------------------------------------------

    set url "https://api.openweathermap.org/data/2.5/weather?q=${encoded}&appid=${openweather_apikey}&units=metric&lang=id"

    # ---------------------------------------------------------------
    # CURL
    # ---------------------------------------------------------------

    if {[catch {

        set response [exec curl -s --max-time 10 -- $url]

    } err]} {

        putlog "CUACA CURL ERROR: $err"

        putserv "PRIVMSG $chan :$nick: Gagal menghubungi OpenWeather."

        return 0
    }

    # ---------------------------------------------------------------
    # Response kosong
    # ---------------------------------------------------------------

    if {$response eq ""} {

        putserv "PRIVMSG $chan :$nick: OpenWeather tidak memberikan respons."

        return 0
    }

    # ===============================================================
    # STATUS OPENWEATHER
    # ===============================================================

    set cod [json_get_number $response "cod" "200"]

    if {$cod == 401} {

        putserv "PRIVMSG $chan :$nick: API Key OpenWeather tidak valid."

        return 0
    }

    if {$cod == 404} {

        putserv "PRIVMSG $chan :$nick: Kota '$city' tidak ditemukan."

        return 0
    }

    # ===============================================================
    # DATA KOTA
    # ===============================================================

    set name \
        [json_get_string $response "name" $city]

    set country \
        [json_get_string $response "country" "-"]

    # ===============================================================
    # KONDISI CUACA
    # ===============================================================

    set weather_main \
        [json_get_string $response "main" "-"]

    set weather_desc \
        [json_get_string $response "description" "-"]

    # ===============================================================
    # SUHU
    # ===============================================================

    set temp \
        [json_get_number $response "temp" "-"]

    set feels \
        [json_get_number $response "feels_like" "-"]

    set temp_min \
        [json_get_number $response "temp_min" "-"]

    set temp_max \
        [json_get_number $response "temp_max" "-"]

    # ===============================================================
    # KELEMBAPAN & TEKANAN
    # ===============================================================

    set humidity \
        [json_get_number $response "humidity" "-"]

    set pressure \
        [json_get_number $response "pressure" "-"]

    # ===============================================================
    # ANGIN
    # ===============================================================

    set wind_speed \
        [json_get_number $response "speed" "-"]

    set wind_deg \
        [json_get_number $response "deg" "-"]

    # ===============================================================
    # AWAN
    # ===============================================================

    set clouds \
        [json_get_number $response "all" "-"]

    # ===============================================================
    # VISIBILITY
    # ===============================================================

    set visibility \
        [json_get_number $response "visibility" "-"]

    if {$visibility ne "-"} {

        if {[catch {

            set visibility \
                [format "%.1f" [expr {$visibility / 1000.0}]]

        }]} {

            set visibility "-"
        }
    }

    # ===============================================================
    # TERJEMAHAN
    # ===============================================================

    set weather_main \
        [translate_weather $weather_main]

    # ===============================================================
    # ARAH ANGIN
    # ===============================================================

    set wind_dir \
        [wind_direction $wind_deg]

    # ===============================================================
    # IRC COLOR
    # Biru -> Hijau -> Biru -> Hijau
    # Tanpa bold
    # ===============================================================

    set c3 "\003"

    # ===============================================================
    # OUTPUT
    # ===============================================================

    set output \
        "${c3}12\[CUACA\]${c3} ${c3}03${name}, ${country}${c3}"

    append output \
        " | ${c3}12${weather_main} (${weather_desc})${c3}"

    append output \
        " | ${c3}03Suhu: ${temp}\u00B0C${c3}"

    append output \
        " | ${c3}12Terasa: ${feels}\u00B0C${c3}"

    append output \
        " | ${c3}03Min/Max: ${temp_min}/${temp_max}\u00B0C${c3}"

    append output \
        " | ${c3}12Lembap: ${humidity}%${c3}"

    append output \
        " | ${c3}03Tekanan: ${pressure} hPa${c3}"

    append output \
        " | ${c3}12Angin: ${wind_speed} m/s ${wind_dir}${c3}"

    append output \
        " | ${c3}03Awan: ${clouds}%${c3}"

    append output \
        " | ${c3}12Visibilitas: ${visibility} km${c3}"

    # ===============================================================
    # KIRIM KE CHANNEL
    # ===============================================================

    putserv "PRIVMSG $chan :$output"

    return 0
}

# =====================================================================
# LOAD
# =====================================================================

putlog "Weather TCL for eggdrop 1.10 by openweather created ktgDALnet@2026"

