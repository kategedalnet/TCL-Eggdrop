# =====================================================================
# TCL FILE-BASED ROTATING AUTO IDENTIFY - DALNET (Persistent State)
# =====================================================================

# --- KONFIGURASI FILE & TARGET ---
set nick_file       "scripts/nicks.txt"
set index_file      "scripts/last_index.txt"
set nickserv_target "NickServ@services.dal.net"
set target_channel  "#channel"

# --- FUNGSI MEMBACA & MENYIMPAN INDEKS TERAKHIR ---
proc get_saved_index {} {
    global index_file
    if {[file exists $index_file]} {
        set fp [open $index_file r]
        set data [string trim [read $fp]]
        close $fp
        if {[string is integer $data]} {
            return $data
        }
    }
    return 0
}

proc save_current_index {idx} {
    global index_file
    set fp [open $index_file w]
    puts $fp $idx
    close $fp
}

# --- PROSES UTAMA IDENTIFY BERGILIRAN ---
proc do_rotating_identify {} {
    global nick_file nickserv_target target_channel
    
    # Mengecek apakah file nicks.txt ada
    if {![file exists $nick_file]} {
        putlog "Auto Identify Error: File $nick_file tidak ditemukan!"
        return
    }
    
    # Membaca isi file nick
    set fp [open $nick_file r]
    set file_data [read $fp]
    close $fp
    
    set accounts {}
    foreach line [split $file_data "\n"] {
        set clean_line [string trim $line]
        if {$clean_line ne "" && ![string match "#*" $clean_line]} {
            lappend accounts $clean_line
        }
    }
    
    set total_accounts [llength $accounts]
    if {$total_accounts == 0} {
        putlog "Auto Identify Warning: File $nick_file kosong."
        return
    }
    
    # Ambil indeks terakhir yang tersimpan dari file
    set current_account_index [get_saved_index]
    
    if {$current_account_index >= $total_accounts} {
        set current_account_index 0
    }
    
    # Mengambil baris akun saat ini
    set current_line [lindex $accounts $current_account_index]
    set nick [lindex [split $current_line] 0]
    set pass [lindex [split $current_line] 1]
    
    if {$nick ne "" && $pass ne ""} {
        # Mengirim perintah identify ke NickServ
        putserv "PRIVMSG $nickserv_target :IDENTIFY $nick $pass"
        
        # Pengaman karakter kurung siku
        #set open_bracket "\x5B"
        #set close_bracket "\x5D"
        
        # Kirim ke channel #kopet tanpa warna
        putserv "PRIVMSG $target_channel :\00314Password accepted for \002\00364$nick\003\002"
    }
    
    # Hitung indeks berikutnya dan simpan permanen ke file state
    set next_index [expr {($current_account_index + 1) % $total_accounts}]
    save_current_index $next_index
}
# --- PEMBERSIH TIMER LAMA (ANTI-TUMPANG TINDIH) ---
foreach tid [utimers] {
    if {[lindex $tid 1] eq "schedule_rotating_identify"} {
        catch {killutimer [lindex $tid 0]}
    }
}

# --- TIMER 3 MENIT PER GILIRAN ---
proc schedule_rotating_identify {} {
    do_rotating_identify
    # 180 detik = 3 menit
    utimer 86400 [list schedule_rotating_identify]
}

# Memulai timer pertama kali setelah bot aktif (jeda 15 detik)
utimer 15 [list schedule_rotating_identify]

putlog "Tcl Rotating Auto Identify by ktgDALnet 2026 Loaded."