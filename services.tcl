# =====================================================================
# Script Name: services_manager.tcl
# Description: Perintah channel (.ns, .cs, .ms) untuk akses services DALnet 
#              (Khusus Admin/Owner, Hanya di #channel)
# =====================================================================

namespace eval servicesmgr {
    # Tentukan channel tujuan untuk notice services
    variable target_chan "#channel"
    
    # Domain services (Sesuai update terbaru DALnet)
    variable svc_domain "services.dal.net"

    # Variabel untuk cooldown anti-duplikasi notice
    variable last_notice ""
    variable last_time 0

    # Bind Public Commands khusus Admin/Owner (flag m = Master, n = Owner)
    bind pub m|n .ns [namespace current]::cmd_nickserv
    bind pub m|n .cs [namespace current]::cmd_chanserv
    bind pub m|n .ms [namespace current]::cmd_memoserv

    # Bind untuk menangkap semua notice yang masuk ke bot dari services
    bind notc - * [namespace current]::handle_notice

    # Fungsi helper untuk validasi channel
    proc check_chan {chan} {
        variable target_chan
        if {[string tolower $chan] ne [string tolower $target_chan]} {
            return 0
        }
        return 1
    }

    # Handler untuk perintah .ns (NickServ)
    proc cmd_nickserv {nick uhost hand chan text} {
        if {![check_chan $chan]} { return 0 }
        
        variable svc_domain
        if {[string trim $text] eq ""} {
            putserv "PRIVMSG $chan :Gunakan: .ns <perintah> (Contoh: .ns info namakamu)"
            return
        }
        putserv "PRIVMSG NickServ@$svc_domain :$text"
    }

    # Handler untuk perintah .cs (ChanServ)
    proc cmd_chanserv {nick uhost hand chan text} {
        if {![check_chan $chan]} { return 0 }
        
        variable svc_domain
        if {[string trim $text] eq ""} {
            putserv "PRIVMSG $chan :Gunakan: .cs <perintah> (Contoh: .cs info #channel)"
            return
        }
        putserv "PRIVMSG ChanServ@$svc_domain :$text"
    }

    # Handler untuk perintah .ms (MemoServ)
    proc cmd_memoserv {nick uhost hand chan text} {
        if {![check_chan $chan]} { return 0 }
        
        variable svc_domain
        if {[string trim $text] eq ""} {
            putserv "PRIVMSG $chan :Gunakan: .ms <perintah> (Contoh: .ms READ ALL)"
            return
        }
        putserv "PRIVMSG MemoServ@$svc_domain :$text"
    }

    # Handler untuk menangkap dan meneruskan notice dengan filter duplikasi
    proc handle_notice {nick uhost hand text dest} {
        variable target_chan
        variable last_notice
        variable last_time
        
        # Filter: Jika pesan sama persis dan datang dalam waktu < 2 detik, abaikan
        set now [unixtime]
        if {$text eq $last_notice && ($now - $last_time) < 2} {
            return 0
        }
        
        # Simpan state untuk perbandingan berikutnya
        set last_notice $text
        set last_time $now

        set message "$text"
        set max_length 400

        if {[string length $message] > $max_length} {
            set chunks [split_text $message $max_length]
            set delay 0
            foreach chunk $chunks {
                utimer $delay [list puthelp "PRIVMSG $target_chan :$chunk"]
                incr delay 1
            }
        } else {
            puthelp "PRIVMSG $target_chan :$message"
        }
    }

    # Fungsi helper untuk memecah teks panjang
    proc split_text {str len} {
        set result {}
        while {[string length $str] > 0} {
            lappend result [string range $str 0 [expr {$len - 1}]]
            set str [string range $str $len end]
        }
        return $result
    }
}

putlog "Loaded: Services Manager (Admin Only) by ktgDALnet 2026."