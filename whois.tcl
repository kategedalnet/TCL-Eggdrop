# =====================================================================
# MASTER TCL SCRIPT - EGGDROP BOT (Ultra Clean Whois Framework)
# created by ktgDALnet 2026
# =====================================================================

# --- 1. CONFIGURATION OWNER ---
set bot_owner_nick "nick"
set bot_owner_pass "password"

# --- 2. BINDINGS / COMMANDS ---
bind pub -|- .auth    pub:auth_owner
bind pub -|- .help    pub:help_menu
bind pub -|- .id      pub:whois_idle
bind pub -|- .w       pub:server_whois
bind pub -|- .whois   pub:server_whois

# Bind raw lengkap referensi lanjutan untuk .w / .whois
bind raw - 311 raw:whois_311
bind raw - 312 raw:whois_312
bind raw - 319 raw:whois_319
bind raw - 317 raw:whois_317
bind raw - 313 raw:whois_multi
bind raw - 310 raw:whois_multi
bind raw - 335 raw:whois_multi
bind raw - 301 raw:whois_301
bind raw - 671 raw:whois_multi
bind raw - 320 raw:whois_multi
bind raw - 330 raw:whois_multi
bind raw - 401 raw:whois_401
bind raw - 307 raw:whois_307
bind raw - 318 raw:whois_318

# Bind raw khusus untuk .id (idle & signon mandiri)
bind raw - 317 raw:catch_whois_idle

# Variabel penyimpan sesi login owner & buffer sementara
array set owner_session {}
array set whois_target  {}
array set whois_channel {}
array set full_whois_buf {}
array set full_whois_chan {}

# --- 3. SYSTEM AUTHENTICATION ---
proc pub:auth_owner {nick host handle channel text} {
    global bot_owner_nick bot_owner_pass owner_session
    
    set pass_input [string trim [lindex [split $text] 0]]
    
    if {[string tolower $nick] ne [string tolower $bot_owner_nick]} {
        putserv "PRIVMSG $channel :Maaf $nick, Anda bukan owner yang terdaftar!"
        return
    }
    
    if {$pass_input eq $bot_owner_pass} {
        set owner_session($nick) 1
        putserv "PRIVMSG $channel :Autentikasi berhasil! Selamat datang Masta $bot_owner_nick, akses penuh diberikan."
    } else {
        putserv "PRIVMSG $channel :Password salah! Autentikasi gagal."
    }
}

proc is_owner_authed {nick} {
    global bot_owner_nick owner_session
    if {[string tolower $nick] ne [string tolower $bot_owner_nick]} {
        return 0
    }
    if {[info exists owner_session($nick)] && $owner_session($nick) == 1} {
        return 1
    }
    return 0
}

# --- 4. COMMAND HELP MENU ---
proc pub:help_menu {nick host handle channel text} {
    putserv "PRIVMSG $channel :=== DAFTAR PERINTAH BOT (KTG TOOLS) ==="
    putserv "PRIVMSG $channel :• .auth <password> - Autentikasi sebagai owner bot"
    putserv "PRIVMSG $channel :• .help - Menampilkan menu bantuan ini"
    putserv "PRIVMSG $channel :• .id <nickname> - Mengecek global idle & signon user (Khusus Owner)"
    putserv "PRIVMSG $channel :• .w / .whois <nickname> - Full WHOIS server IRC advanced dengan anti-flood (Khusus Owner)"
    putserv "PRIVMSG $channel :=========================================="
}

# --- 5. SCRIPT .ID (Global Idle & Sign On Khusus) ---
proc pub:whois_idle {nick host handle channel text} {
    if {![is_owner_authed $nick]} {
        putserv "PRIVMSG $channel :Akses ditolak! Silakan ketik .auth <password> terlebih dahulu."
        return
    }
    
    set target [string trim [lindex [split $text] 0]]
    if {$target eq ""} { set target $nick }
    
    global whois_target whois_channel
    set whois_target([string tolower $target]) $nick
    set whois_channel([string tolower $target]) $channel
    
    putserv "WHOIS $target $target"
}

proc raw:catch_whois_idle {from key text} {
    global whois_target whois_channel
    
    set target [lindex [split $text] 1]
    set idle_secs [lindex [split $text] 2]
    set signon_ts [lindex [split $text] 3]
    
    set target_lower [string tolower $target]
    
    if {[info exists whois_channel($target_lower)]} {
        set channel $whois_channel($target_lower)
        set idle_str [format_duration $idle_secs]
        set sign_on_str [clock format $signon_ts -format "%a %b %d %H:%M:%S %Y" -gmt 1]
        
        putserv "PRIVMSG $channel :$target has been idle $idle_str, signed on $sign_on_str"
        
        unset whois_target($target_lower)
        unset whois_channel($target_lower)
    }
}

# --- 6. SCRIPT .W / .WHOIS (Advanced Server Info dengan Referensi Lengkap) ---
proc pub:server_whois {nick host handle channel text} {
    if {![is_owner_authed $nick]} {
        putserv "PRIVMSG $channel :Akses ditolak! Silakan ketik .auth <password> terlebih dahulu."
        return
    }
    
    set target [string trim [lindex [split $text] 0]]
    if {$target eq ""} { set target $nick }
    
    global full_whois_buf full_whois_chan
    set t_low [string tolower $target]
    
    set full_whois_buf($t_low) ""
    set full_whois_chan($t_low) $channel
    
    putserv "WHOIS $target $target"
}

proc raw:whois_311 {from key text} {
    global full_whois_buf full_whois_chan
    set target [lindex [split $text] 1]
    set user [lindex [split $text] 2]
    set host [lindex [split $text] 3]
    set realname [string range [string trimleft [lindex [split $text : ] end]] 0 end]
    
    set t_low [string tolower $target]
    if {[info exists full_whois_chan($t_low)]} {
        lappend full_whois_buf($t_low) "PRIVMSG $full_whois_chan($t_low) :$target is $user@$host * $realname"
    }
}

proc raw:whois_312 {from key text} {
    global full_whois_buf full_whois_chan
    set target [lindex [split $text] 1]
    set server [lindex [split $text] 2]
    set desc [string range [string trimleft [lindex [split $text : ] end]] 0 end]
    
    set t_low [string tolower $target]
    if {[info exists full_whois_chan($t_low)]} {
        lappend full_whois_buf($t_low) "PRIVMSG $full_whois_chan($t_low) :$target using $server $desc"
    }
}

proc raw:whois_319 {from key text} {
    global full_whois_buf full_whois_chan
    set target [lindex [split $text] 1]
    set chans [string range [string trimleft [lindex [split $text : ] end]] 0 end]
    
    set t_low [string tolower $target]
    if {[info exists full_whois_chan($t_low)]} {
        lappend full_whois_buf($t_low) "PRIVMSG $full_whois_chan($t_low) :$target on $chans"
    }
}

proc raw:whois_317 {from key text} {
    global full_whois_buf full_whois_chan
    set target [lindex [split $text] 1]
    set idle_secs [lindex [split $text] 2]
    set signon_ts [lindex [split $text] 3]
    
    set t_low [string tolower $target]
    if {[info exists full_whois_chan($t_low)]} {
        set idle_str [format_duration $idle_secs]
        set sign_on_str [clock format $signon_ts -format "%a %b %d %H:%M:%S %Y" -gmt 1]
        lappend full_whois_buf($t_low) "PRIVMSG $full_whois_chan($t_low) :$target has been idle $idle_str, signed on $sign_on_str"
    }
}

proc raw:whois_multi {from key text} {
    global full_whois_buf full_whois_chan
    set target [lindex [split $text] 1]
    set info_msg [string range [string trimleft [lindex [split $text : ] end]] 0 end]
    
    set t_low [string tolower $target]
    if {[info exists full_whois_chan($t_low)]} {
        if {$key eq "671"} {
            lappend full_whois_buf($t_low) "PRIVMSG $full_whois_chan($t_low) :$target is using a secure connection (SSL)"
        } elseif {$key eq "330"} {
            lappend full_whois_buf($t_low) "PRIVMSG $full_whois_chan($t_low) :$target has identified for this nick"
        } else {
            lappend full_whois_buf($t_low) "PRIVMSG $full_whois_chan($t_low) :$target $info_msg"
        }
    }
}

proc raw:whois_301 {from key text} {
    global full_whois_buf full_whois_chan
    set target [lindex [split $text] 1]
    set away_msg [string range [string trimleft [lindex [split $text : ] end]] 0 end]
    
    set t_low [string tolower $target]
    if {[info exists full_whois_chan($t_low)]} {
        lappend full_whois_buf($t_low) "PRIVMSG $full_whois_chan($t_low) :$target is away: $away_msg"
    }
}

proc raw:whois_307 {from key text} {
    global full_whois_buf full_whois_chan
    set target [lindex [split $text] 1]
    
    set t_low [string tolower $target]
    if {[info exists full_whois_chan($t_low)]} {
        lappend full_whois_buf($t_low) "PRIVMSG $full_whois_chan($t_low) :$target has identified for this nick"
    }
}

proc raw:whois_401 {from key text} {
    global full_whois_buf full_whois_chan
    set target [lindex [split $text] 1]
    
    set t_low [string tolower $target]
    if {[info exists full_whois_chan($t_low)]} {
        lappend full_whois_buf($t_low) "PRIVMSG $full_whois_chan($t_low) :No such nick/channel: $target"
    }
}

proc raw:whois_318 {from key text} {
    global full_whois_buf full_whois_chan
    set target [lindex [split $text] 1]
    
    set t_low [string tolower $target]
    if {[info exists full_whois_buf($t_low)]} {
        lappend full_whois_buf($t_low) "PRIVMSG $full_whois_chan($t_low) :$target End of /WHOIS list."
        send_whois_delayed $full_whois_buf($t_low) 0
        
        unset full_whois_buf($t_low)
        unset full_whois_chan($t_low)
    }
}

proc send_whois_delayed {lines index} {
    if {$index < [llength $lines]} {
        putserv [lindex $lines $index]
        incr index
        utimer 1 [list send_whois_delayed $lines $index]
    }
}

# --- 7. FUNGSI BANTU (HELPER) ---
proc format_duration {seconds} {
    set days [expr {$seconds / 86400}]
    set hours [expr {($seconds % 86400) / 3600}]
    set minutes [expr {($seconds % 3600) / 60}]
    set secs [expr {$seconds % 60}]
    
    set res ""
    if {$days > 0} { append res "$days hari " }
    if {$hours > 0 || $days > 0} { append res "$hours jam " }
    if {$minutes > 0 || $hours > 0 || $days > 0} { append res "$minutes menit " }
    append res "$secs detik"
    return [string trim $res]
}

putlog "Whois.tcl by ktgDALnet 2026 Loaded."