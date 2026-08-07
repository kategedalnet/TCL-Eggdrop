
# =====================================================================
# TCL FILE-BASED ROTATING AUTO IDENTIFY - DALNET
# by ktg@DALnet 2026
# =====================================================================

# --- KONFIGURASI FILE & TARGET ---

set nick_file       "scripts/nicks.txt"
set index_file      "scripts/last_index.txt"
set time_file       "scripts/last_identify_time.txt"

set nickserv_target "NickServ@services.dal.net"
set target_channel  "#channel"

# 24 jam = 86400 detik
set identify_interval 86400


# =====================================================================
# FUNGSI MEMBACA & MENYIMPAN INDEKS TERAKHIR
# =====================================================================

proc get_saved_index {} {
    global index_file

    if {[file exists $index_file]} {
        set fp [open $index_file r]
        set data [string trim [read $fp]]
        close $fp

        if {[string is integer -strict $data]} {
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


# =====================================================================
# FUNGSI MEMBACA WAKTU IDENTIFY TERAKHIR
# =====================================================================

proc get_last_identify_time {} {
    global time_file

    if {[file exists $time_file]} {
        set fp [open $time_file r]
        set data [string trim [read $fp]]
        close $fp

        if {[string is integer -strict $data]} {
            return $data
        }
    }

    return 0
}


# =====================================================================
# FUNGSI MENYIMPAN WAKTU IDENTIFY TERAKHIR
# =====================================================================

proc save_last_identify_time {} {
    global time_file

    set fp [open $time_file w]
    puts $fp [clock seconds]
    close $fp
}


# =====================================================================
# PROSES UTAMA IDENTIFY BERGILIRAN
# =====================================================================

proc do_rotating_identify {} {
    global nick_file
    global nickserv_target
    global target_channel

    # ---------------------------------------------------------------
    # Cek file nicks.txt
    # ---------------------------------------------------------------

    if {![file exists $nick_file]} {
        putlog "Auto Identify Error: File $nick_file tidak ditemukan!"
        return
    }


    # ---------------------------------------------------------------
    # Baca isi nicks.txt
    # ---------------------------------------------------------------

    set fp [open $nick_file r]
    set file_data [read $fp]
    close $fp

    set accounts {}

    foreach line [split $file_data "\n"] {

        set clean_line [string trim $line]

        # Abaikan baris kosong dan komentar #
        if {$clean_line ne "" && ![string match "#*" $clean_line]} {
            lappend accounts $clean_line
        }
    }


    # ---------------------------------------------------------------
    # Cek jumlah akun
    # ---------------------------------------------------------------

    set total_accounts [llength $accounts]

    if {$total_accounts == 0} {
        putlog "Auto Identify Warning: File $nick_file kosong."
        return
    }


    # ---------------------------------------------------------------
    # Ambil index akun terakhir
    # ---------------------------------------------------------------

    set current_account_index [get_saved_index]

    if {$current_account_index < 0 || $current_account_index >= $total_accounts} {
        set current_account_index 0
    }


    # ---------------------------------------------------------------
    # Ambil akun sesuai index
    #
    # Format nicks.txt:
    #
    # nick password
    # ---------------------------------------------------------------

    set current_line [lindex $accounts $current_account_index]

    set parts [split $current_line]

    set nick [lindex $parts 0]
    set pass [lindex $parts 1]


    # ---------------------------------------------------------------
    # Cek nick dan password
    # ---------------------------------------------------------------

    if {$nick eq "" || $pass eq ""} {
        putlog "Auto Identify Error: Format akun tidak valid:"
        putlog "Auto Identify Error: $current_line"
        return
    }


    # ---------------------------------------------------------------
    # Kirim IDENTIFY ke NickServ
    # ---------------------------------------------------------------

    putserv "PRIVMSG $nickserv_target :IDENTIFY $nick $pass"


    # ---------------------------------------------------------------
    # Kirim pemberitahuan ke #kopet
    # ---------------------------------------------------------------

    putserv "PRIVMSG $target_channel :\00314Password accepted for \002\00364$nick\003\002"


    # ---------------------------------------------------------------
    # SIMPAN WAKTU IDENTIFY
    # ---------------------------------------------------------------

    save_last_identify_time

    putlog "Auto Identify: $nick telah diproses."


    # ---------------------------------------------------------------
    # Pindah ke akun berikutnya
    # ---------------------------------------------------------------

    set next_index [expr {($current_account_index + 1) % $total_accounts}]

    save_current_index $next_index

    putlog "Auto Identify: Index berikutnya = $next_index"
}


# =====================================================================
# CEK TIMER 24 JAM
# =====================================================================

proc schedule_rotating_identify {} {
    global identify_interval

    # ---------------------------------------------------------------
    # Waktu sekarang
    # ---------------------------------------------------------------

    set now [clock seconds]


    # ---------------------------------------------------------------
    # Waktu identify terakhir
    # ---------------------------------------------------------------

    set last_time [get_last_identify_time]


    # ---------------------------------------------------------------
    # Jika belum pernah identify
    # ---------------------------------------------------------------

    if {$last_time == 0} {

        putlog "Auto Identify: Belum ada waktu identify sebelumnya."
        putlog "Auto Identify: Identify pertama dalam 15 detik."

        utimer 15 [list schedule_rotating_identify]

        return
    }


    # ---------------------------------------------------------------
    # Hitung waktu yang sudah berlalu
    # ---------------------------------------------------------------

    set elapsed [expr {$now - $last_time}]


    # ---------------------------------------------------------------
    # Jika sudah 24 jam
    # ---------------------------------------------------------------

    if {$elapsed >= $identify_interval} {

        putlog "Auto Identify: Waktu 24 jam sudah tercapai."
        putlog "Auto Identify: Menjalankan identify."

        do_rotating_identify

        return
    }


    # ---------------------------------------------------------------
    # Belum 24 jam
    # ---------------------------------------------------------------

    set remaining [expr {$identify_interval - $elapsed}]

    set remaining_hours [expr {$remaining / 3600}]
    set remaining_minutes [expr {($remaining % 3600) / 60}]
    set remaining_seconds [expr {$remaining % 60}]


    putlog "Auto Identify: Belum waktunya identify."
    putlog "Auto Identify: Sisa ${remaining_hours} jam ${remaining_minutes} menit ${remaining_seconds} detik."


    # ---------------------------------------------------------------
    # Pasang timer berdasarkan sisa waktu
    # ---------------------------------------------------------------

    utimer $remaining [list schedule_rotating_identify]
}


# =====================================================================
# PEMBERSIH TIMER LAMA
# =====================================================================

foreach tid [utimers] {

    if {[lindex $tid 1] eq "schedule_rotating_identify"} {
        catch {killutimer [lindex $tid 0]}
    }
}

# Mulai pengecekan 15 detik setelah script dimuat
utimer 15 [list schedule_rotating_identify]

# =====================================================================
# START SCRIPT
# =====================================================================

putlog "========================================================"
putlog "Persistent Rotating Auto Identify loaded."
putlog "Identify interval : 24 jam"
putlog "State file        : $time_file"
putlog "Index file        : $index_file"
putlog "Autoidentify TCL for eggdrop 1.10 created ktgDALnet@2026"
putlog "========================================================"
