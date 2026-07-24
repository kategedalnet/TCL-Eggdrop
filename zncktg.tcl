# ==============================================================================
# ZNC Management 2026 by ktgDALnet - Complete Edition 
# ==============================================================================

set scriptname "ZNC Management by ktgDALnet"
set scriptversion "2026"
set scriptdebug 0

# --- LOAD CONFIGURATION FROM SYSTEM ENVIRONMENT (.PROFILE) ---
proc znc:loadEnv {varName defaultVal} {
    global env
    if {[info exists env($varName)]} {
        return $env($varName)
    }
    return $defaultVal
}

set scriptCommandPrefix "!"
set zncprefix "*"
set znchost         [znc:loadEnv "ZNC_HOST" "your.znc.host"]
set zncNonSSLPort     [znc:loadEnv "ZNC_PORT" "your.znc.port"]
set zncnetworkname    [znc:loadEnv "ZNC_NETWORK" "destination.Network(DALnet,EFNet,etc"]
set zncircserver     [znc:loadEnv "ZNC_IRC_SERVER" "destination.server"]
set zncircserverport [znc:loadEnv "ZNC_IRC_PORT" "destination.port"]
set zncPublicChannel [znc:loadEnv "ZNC_PUBLIC_CHAN" "#chan"]
set zncAdminChannel  [znc:loadEnv "ZNC_ADMIN_CHAN" "#chan"]

# --- TEMPLATE: 10 BINDHOST LIST CONFIGURATION ---
# Daftar bindhost yang bisa dipilih secara otomatis (acak)
set zncBindHostList {
    "bind.host1"
    "bind.host2"
    "bind.host3"
}

# SMTP Gmail & Curl Config from Environment
set zncMailMethod    "smtp"
set zncSmtpHost      [znc:loadEnv "ZNC_SMTP_HOST" "smtp.gmail.com"]
set zncSmtpPort      [znc:loadEnv "ZNC_SMTP_PORT" "587"]
set zncSmtpUser      [znc:loadEnv "ZNC_SMTP_USER" ""]
set zncSmtpPass      [znc:loadEnv "ZNC_SMTP_PASS" ""]
set zncAdminMail     [znc:loadEnv "ZNC_ADMIN_MAIL" ""]
set zncCurlPath      [znc:loadEnv "ZNC_CURL_PATH" "/usr/local/bin/curl"]

set zncPasswordSecurityLevel 3
set zncPasswordLength 16
setudef flag znc

array set zncIpTracker {}
array set zncDailyTracker {}

# --- HELPER: NOTICE, PM, & CP ---
proc znc:notice {target text} {
    putquick "NOTICE $target :$text"
}

proc znc:msg {target text} {
    putquick "PRIVMSG $target :$text"
}

proc znc:cp {cmd} {
    global zncprefix
    putquick "PRIVMSG ${zncprefix}controlpanel :$cmd"
}

# --- HELPER: AUTO UPDATE CHANNEL TOPIC BASED ON PENDING QUEUE ---
proc znc:updateTopic {} {
    global zncPublicChannel
    
    set count 0
    foreach u [userlist] {
        if {[matchattr $u C]} {
            incr count
        }
    }
    
    set topicText "40Welcome 52to #your.channel 64ZNC Request List  52($count unconfirm)"
    if {[validchan $zncPublicChannel]} {
        putserv "TOPIC $zncPublicChannel :$topicText"
    }
}

# --- SEND EMAIL VIA CURL SMTP WITH LOGGING CAPTURE ---
proc znc:mail:send {from toList subject body} {
    global zncSmtpHost zncSmtpPort zncSmtpUser zncSmtpPass zncCurlPath scriptname znchost
    
    if {$zncSmtpUser ne ""} {
        set from $zncSmtpUser
    } elseif {$from eq ""} {
        set from "znc-bot@$znchost"
    }

    set mailFile "/tmp/znc_mail_[pid]_[clock milliseconds].eml"
    if {[catch {
        set fd [open $mailFile w]
        puts $fd "From: $from"
        puts $fd "To: [join $toList {, }]"
        puts $fd "Subject: $subject"
        puts $fd "MIME-Version: 1.0"
        puts $fd "Content-Type: text/plain; charset=UTF-8"
        puts $fd ""
        puts $fd $body
        close $fd
    } err]} {
        putlog "$scriptname: Failed to write temporary email file: $err"
        return
    }

    set cmd [list $zncCurlPath -S --mail-from $from]
    foreach addr $toList { lappend cmd --mail-rcpt $addr }
    if {$zncSmtpUser ne ""} {
        lappend cmd --user ${zncSmtpUser}:$zncSmtpPass
    }
    lappend cmd --ssl-reqd --upload-file $mailFile "smtp://${zncSmtpHost}:${zncSmtpPort}"

    if {[catch {
        set result [exec {*}$cmd 2>@1]
        file delete -force $mailFile
        putlog "$scriptname: Email successfully sent to [join $toList {, }]"
    } err]} {
        file delete -force $mailFile
        putlog "$scriptname: SMTP Error Failed -> $err"
    }
}

# --- GENERATE RANDOM PASSWORD ---
proc znc:randpw {level len} {
    set pool {0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z}
    set poolLen [llength $pool]
    set out ""
    for {set i 0} {$i < $len} {incr i} {
        append out [lindex $pool [expr {int(rand()*$poolLen)}]]
    }
    return $out
}

# --- 1. JOIN EVENT: SEND NOTICE & SYNC TOPIC ---
proc znc:join:notice {nick host handle chan} {
    global zncPublicChannel scriptCommandPrefix
    if {[string equal -nocase $chan $zncPublicChannel]} {
        znc:notice $nick "Welcome to $zncPublicChannel! If you want to request a ZNC account, please type ${scriptCommandPrefix}request in the ZNC channel or PM the bot."
        znc:updateTopic
    }
}
bind join -|- * znc:join:notice

# --- HELP COMMAND (!help) ---
proc znc:user:helpCore {target} {
    global scriptCommandPrefix
    znc:msg $target "=== ZNC Request Commands (Available in Bot PM) ==="
    znc:msg $target "${scriptCommandPrefix}request <username> <email> - Request a new ZNC account."
    znc:msg $target "verify <username> <code> - Verify your account using the code sent to your email."
    znc:msg $target "${scriptCommandPrefix}status <username> - Check your ZNC account application status."
    znc:msg $target "${scriptCommandPrefix}help - Show this help menu."
    znc:msg $target "${scriptCommandPrefix}admin - Show admin command list."
}

# --- REQUEST CORE LOGIC (BYPASS LIMIT FOR ADMINS) ---
proc znc:user:requestCore {nick host handle chan arg} {
    global zncPublicChannel scriptCommandPrefix zncAdminMail scriptname zncnetworkname zncIpTracker zncDailyTracker

    set arg [string trim $arg]
    
    if {![string equal -nocase $chan $zncPublicChannel] && $chan ne $nick} {
        znc:msg $nick "The ${scriptCommandPrefix}request command can only be used in channel $zncPublicChannel or via PM."
        return
    }

    # Cek apakah user yang request adalah Admin (memiliki flag n, m, atau Y)
    set isAdmin [matchattr [nick2hand $nick] "n|m|Y"]

    # Jika BUKAN admin, jalankan batasan IP dan limit harian
    if {!$isAdmin} {
        set ip [lindex [split $host @] 1]
        if {$ip eq ""} {
            set ip $host
        }

        if {[info exists zncIpTracker($ip)]} {
            znc:msg $nick "Access Denied: Your IP address ($ip) has already reached the maximum limit of 1 ZNC account request."
            return
        }

        set today [clock format [clock seconds] -format "%Y%m%d"]
        if {![info exists zncDailyTracker($today)]} {
            set zncDailyTracker($today) 0
        }

        if {$zncDailyTracker($today) >= 5} {
            znc:msg $nick "Daily Limit Reached: The maximum limit of 5 ZNC requests for today has been reached. Please try again tomorrow."
            return
        }
    }

    if {$arg eq ""} {
        znc:msg $nick "How to request ZNC: Type ${scriptCommandPrefix}request <username> <your@email.com>"
        znc:msg $nick "Username rules: Max 16 characters, starts with a letter, allows underscore (_), but forbids %, $, or *."
        return
    }

    set parts [regexp -all -inline {\S+} $arg]
    set user [string trim [lindex $parts 0]]
    set email [string trim [lindex $parts 1]]

    if {$user eq "" || $email eq ""} {
        znc:msg $nick "Invalid format! Type ${scriptCommandPrefix}request <username> <email>"
        znc:msg $nick "Available Bot PM Commands: ${scriptCommandPrefix}help, ${scriptCommandPrefix}request, ${scriptCommandPrefix}status, ${scriptCommandPrefix}admin"
        return
    }

    if {![regexp {^[A-Za-z][A-Za-z0-9_]{1,15}$} $user]} {
        znc:msg $nick "Invalid username! Maximum 16 characters, must start with a letter, can use underscore (_) but cannot contain characters like %, $, or *."
        return
    }

    if {![regexp {^[^@[:space:]]+@[^@[:space:]]+\.[A-Za-z]{2,}$} $email]} {
        znc:msg $nick "Invalid email format."
        return
    }

    if {![adduser $user]} {
        znc:msg $nick "That username is already registered in the bot system!"
        return
    }

    # Catat tracker IP & harian HANYA JIKA BUKAN admin
    if {!$isAdmin} {
        set zncIpTracker($ip) 1
        incr zncDailyTracker($today)
    }

    set vcode [znc:randpw 3 12]

    setuser $user COMMENT $email
    setuser $user XTRA vcode $vcode
    setuser $user XTRA realnick $nick
    chattr $user +C

    # Auto-update channel topic when a new request comes in
    znc:updateTopic

    set subject "ZNC Request Verification Code"
    set body "Hello $user,\n\nThank you for requesting a ZNC account.\n\nYour verification code is: $vcode\n\nTo verify, please type the following command in the bot's PM:\nverify $user $vcode\n(or use !verify $user $vcode)\n\nRegards,\n$scriptname"

    znc:mail:send $zncAdminMail [list $email] $subject $body

    if {$isAdmin} {
        znc:msg $nick "Admin bypass active: Request for '$user' successfully processed without limits."
    }
    
    znc:msg $nick "Your request is being processed. Please check your email as the verification code has been sent there."
    znc:msg $nick "Available PM Commands you can use now: ${scriptCommandPrefix}help, ${scriptCommandPrefix}status $user, ${scriptCommandPrefix}request"
}

# --- STATUS COMMAND CORE (!status) ---
proc znc:user:statusCore {nick arg} {
    global scriptCommandPrefix

    set user [string trim [lindex [regexp -all -inline {\S+} $arg] 0]]
    if {$user eq ""} {
        znc:msg $nick "Syntax: ${scriptCommandPrefix}status <username>"
        return
    }

    if {[matchattr $user C]} {
        set vcode [getuser $user XTRA vcode]
        if {$vcode eq ""} {
            znc:msg $nick "Status for '$user': verify OK - Confirm Pending"
        } else {
            znc:msg $nick "Status for '$user': verify Pending - Confirm Pending"
        }
    } elseif {[validuser $user]} {
        znc:msg $nick "Status for '$user': verify OK - Confirm OK"
    } else {
        znc:msg $nick "Status for '$user': No active application or user not found."
    }
}

# --- ADMIN COMMAND LIST CORE (!admin) ---
proc znc:admin:helpCore {nick} {
    global scriptCommandPrefix
    if {![matchattr [nick2hand $nick] "n|m|Y"]} {
        znc:msg $nick "Permission Denied: This command is restricted to admins."
        return
    }
    znc:msg $nick "=== ZNC Admin Commands ==="
    znc:msg $nick "${scriptCommandPrefix}confirm <username> - Confirm and provision a verified ZNC account."
    znc:msg $nick "${scriptCommandPrefix}deny <username> - Deny and cancel a ZNC account request."
    znc:msg $nick "${scriptCommandPrefix}deluser <username> - Delete an existing ZNC user."
    znc:msg $nick "${scriptCommandPrefix}luu - List all unconfirmed pending users."
    znc:msg $nick "${scriptCommandPrefix}admins - List online administrators."
    znc:msg $nick "${scriptCommandPrefix}topic <teks> - Set custom channel topic."
}

# --- VERIFICATION STAGE CORE (verify / !verify) ---
proc znc:user:verifyCore {nick arg} {
    global zncAdminChannel scriptCommandPrefix

    set arg [string trim $arg]
    set parts [regexp -all -inline {\S+} $arg]
    set inputUser [string trim [lindex $parts 0]]
    set inputCode [string trim [lindex $parts 1]]

    if {$inputUser eq "" || $inputCode eq ""} {
        znc:msg $nick "Invalid format! Type verify <username> <code> to the bot's PM."
        return
    }

    if {![matchattr $inputUser C]} {
        znc:msg $nick "No pending request found for username '$inputUser' or it has already been verified."
        return
    }

    set correctCode [getuser $inputUser XTRA vcode]
    if {$correctCode eq ""} {
        znc:msg $nick "Verification code not found or session expired. Please request a new account."
        return
    }

    if {[string equal $inputCode $correctCode]} {
        setuser $inputUser XTRA vcode ""
        setuser $inputUser XTRA realnick $nick

        if {[validchan $zncAdminChannel]} {
            putserv "PRIVMSG $zncAdminChannel :\002\[ZNC VERIFICATION\]\002 User \002$nick\002 (Username: \002$inputUser\002) has been verified. Please type \002${scriptCommandPrefix}confirm $inputUser\002 or \002${scriptCommandPrefix}deny $inputUser\002."
        }

        znc:msg $nick "Verification Successful! The ZNC request for username '$inputUser' has been forwarded to the Admin."
    } else {
        znc:msg $nick "Wrong verification code! Please check your email again."
    }
}

# --- ADMIN COMMAND: DENY CORE (!deny) ---
proc znc:admin:denyCore {requester chan arg} {
    global zncAdminChannel scriptCommandPrefix zncAdminMail zncnetworkname scriptname

    if {![string equal -nocase $chan $zncAdminChannel] && $chan ne $requester} {
        znc:msg $requester "The ${scriptCommandPrefix}deny command must be executed in the admin channel $zncAdminChannel."
        return
    }

    set user [string trim [lindex [regexp -all -inline {\S+} $arg] 0]]
    if {$user eq ""} {
        znc:msg $requester "Syntax: ${scriptCommandPrefix}deny <username>"
        return
    }

    if {[matchattr $user C]} {
        set email [getuser $user COMMENT]

        if {$email ne ""} {
            set subject "\[ZNC\] Account Request Denied"
            set body "Hello $user,\n\nSorry, your ZNC account request on the $zncnetworkname network was not approved by the Admin.\n\nRegards,\n$scriptname"
            znc:mail:send $zncAdminMail [list $email] $subject $body
        }

        deluser $user
        
        # Auto-update channel topic after deny
        znc:updateTopic

        znc:msg $requester "ZNC request for user '$user' has been cancelled/denied successfully."
    } else {
        znc:msg $requester "User '$user' not found in the queue list."
    }
}

# --- ADMIN COMMAND: CONFIRM CORE (!confirm) ---
proc znc:admin:confirmCore {requester chan arg} {
    global zncAdminChannel zncPublicChannel scriptCommandPrefix zncnetworkname zncircserver zncircserverport znchost zncNonSSLPort zncAdminMail scriptname zncBindHostList

    if {![string equal -nocase $chan $zncAdminChannel] && $chan ne $requester} {
        znc:msg $requester "The ${scriptCommandPrefix}confirm command must be executed in the admin channel $zncAdminChannel."
        return
    }

    set user [string trim [lindex [regexp -all -inline {\S+} $arg] 0]]
    if {$user eq ""} {
        znc:msg $requester "Syntax: ${scriptCommandPrefix}confirm <username>"
        return
    }

    if {[matchattr $user C]} {
        set pass [znc:randpw 3 16]

        znc:cp "AddUser $user $pass"
        znc:cp "Set password $user $pass"
        znc:cp "AddNetwork $user $zncnetworkname"
        znc:cp "AddServer $user $zncnetworkname $zncircserver $zncircserverport"

        znc:cp "LoadModule $user controlpanel"
        znc:cp "Set RealName $user {ZNC by ktgDALnet}"
        znc:cp "Set DenySetRealName $user true"
        znc:cp "Set QuitMsg $user {ZNC by ktgDALnet}"
        znc:cp "Set DenySetQuitMsg $user true"
        znc:cp "Set DenyAddNetwork $user true"
        znc:cp "Set DenyLoadMod $user true"
        znc:cp "Set Ident $user $user"
        znc:cp "Set DenySetIdent $user true"
        znc:cp "Set DenySetBindHost $user true"
        
        # --- TEMPLATE 10 BINDHOSTS (ACTIVE RANDOM BINDHOST) ---
         set totalBindHost [llength $zncBindHostList]
         if {$totalBindHost > 0} {
             set randomBindHost [lindex $zncBindHostList [expr {int(rand() * $totalBindHost)}]]
             znc:cp "Set BindHost $user $randomBindHost"
         }
        # -------------------------------------------------------------

        znc:cp "ADDChan $user $zncnetworkname $zncPublicChannel"
        znc:cp "LoadNetModule $user $zncnetworkname perform"

        chattr $user -C
        chattr $user +Z

        # Auto-update channel topic after successful confirm
        znc:updateTopic

        znc:msg $requester "ZNC account '$user' successfully created and confirmed!"

        set email [getuser $user COMMENT]
        set targetNick [getuser $user XTRA realnick]
        if {$targetNick eq ""} {
            set targetNick $user
        }

        if {$email ne ""} {
            set subUser "\[ZNC\] Your ZNC Account Is Now Active: $user"
            set bodyUser "Hello $user,\n\nYour ZNC account on the $zncnetworkname network has been approved and confirmed by the Admin!\n\nYour Connection Access Details:\n- Host: $znchost\n- Port: $zncNonSSLPort\n- Username: $user\n- Access Key / Password: $pass\n\nPlease use the details above for your IRC connection.\n\nRegards,\n$scriptname"
            
            znc:mail:send $zncAdminMail [list $email] $subUser $bodyUser
        }

        znc:msg $targetNick "Your ZNC account for \002$user\002 has been confirmed by the admin! Account details have been sent to your email (\002$email\002). Please check your inbox or spam folder."

    } elseif {[validuser $user]} {
        znc:msg $requester "User '$user' has already been confirmed previously."
    } else {
        znc:msg $requester "User '$user' not found in the queue."
    }
}

# --- ADMIN COMMAND: TOPIC ---
proc znc:admin:topicCore {nick host handle chan arg} {
    global scriptCommandPrefix zncPublicChannel
    if {![matchattr $handle "n|m|Y"]} {
        znc:msg $nick "Permission Denied."
        return
    }
    set arg [string trim $arg]
    if {$arg eq ""} {
        znc:msg $nick "Syntax: ${scriptCommandPrefix}topic <teks topic baru>"
        return
    }
    putserv "TOPIC $zncPublicChannel :$arg"
    znc:notice $nick "Topic changed successfully."
}

# --- OTHER UTILITY ADMIN COMMANDS ---
proc znc:admin:delUser {nick host handle chan arg} {
    set user [string trim [lindex [regexp -all -inline {\S+} $arg] 0]]
    if {$user eq ""} {
        znc:msg $nick "Syntax: !deluser <username>"
        return
    }

    znc:cp "DelUser $user"
    if {[validuser $user]} {
        deluser $user
        # Auto-update channel topic after deletion
        znc:updateTopic
        znc:msg $nick "User '$user' has been deleted from ZNC and the bot system."
    } else {
        znc:msg $nick "ZNC delete command sent for '$user', but user was not found in the bot database."
    }
}

proc znc:admin:listUnconfirmed {requester host handle chan arg} {
    set unconfirmedList {}
    foreach u [userlist] {
        if {[matchattr $u C]} {
            set email [getuser $u COMMENT]
            lappend unconfirmedList "$u ($email)"
        }
    }

    if {[llength $unconfirmedList] > 0} {
        znc:msg $requester "Pending ZNC Requests: [join $unconfirmedList ", "]"
    } else {
        znc:msg $requester "No pending ZNC requests at the moment."
    }
}

proc znc:admin:listOnlineAdmins {requester host handle chan arg} {
    set onlineAdmins {}
    foreach c [channels] {
        foreach nick [chanlist $c] {
            set uHand [nick2hand $nick]
            if {$uHand ne "*" && [matchattr $uHand "n|m"]} {
                if {[lsearch -exact $onlineAdmins "$nick ($uHand)"] == -1} {
                    lappend onlineAdmins "$nick ($uHand)"
                }
            }
        }
    }

    if {[llength $onlineAdmins] > 0} {
        znc:msg $requester "Online Admins: [join $onlineAdmins ", "]"
    } else {
        znc:msg $requester "No admins currently online."
    }
}

# --- DIRECT PM WRAPPER PROCS ---
proc znc:pm:request {nick host handle text} { znc:user:requestCore $nick $host $handle $nick $text }
proc znc:pm:verify {nick host handle text} { znc:user:verifyCore $nick $text }
proc znc:pm:status {nick host handle text} { znc:user:statusCore $nick $text }
proc znc:pm:help {nick host handle text} { znc:user:helpCore $nick }
proc znc:pm:admin {nick host handle text} { znc:admin:helpCore $nick }
proc znc:pm:confirm {nick host handle text} { znc:admin:confirmCore $nick $nick $text }
proc znc:pm:deny {nick host handle text} { znc:admin:denyCore $nick $nick $text }
proc znc:pm:deluser {nick host handle text} { znc:admin:delUser $nick $host $handle $nick $text }
proc znc:pm:luu {nick host handle text} { znc:admin:listUnconfirmed $nick $host $handle $nick $text }
proc znc:pm:admins {nick host handle text} { znc:admin:listOnlineAdmins $nick $host $handle $nick $text }

# --- PUBLIC WRAPPER PROCS ---
proc znc:pub:request {nick host handle chan arg} { znc:user:requestCore $nick $host $handle $chan $arg }
proc znc:pub:verify {nick host handle chan arg} { znc:user:verifyCore $nick $arg }
proc znc:pub:status {nick host handle chan arg} { znc:user:statusCore $nick $arg }
proc znc:pub:help {nick host handle chan arg} { znc:user:helpCore $nick }
proc znc:pub:admin {nick host handle chan arg} { znc:admin:helpCore $nick }
proc znc:pub:confirm {nick host handle chan arg} { znc:admin:confirmCore $nick $chan $arg }
proc znc:pub:deny {nick host handle chan arg} { znc:admin:denyCore $nick $chan $arg }
proc znc:pub:topic {nick host handle chan arg} { znc:admin:topicCore $nick $host $handle $chan $arg }

# --- DIRECT PM BINDINGS (Supports both with and without '!') ---
bind msg -|- "request"    znc:pm:request
bind msg -|- "!request"   znc:pm:request
bind msg -|- "verify"     znc:pm:verify
bind msg -|- "!verify"    znc:pm:verify
bind msg -|- "verification" znc:pm:verify
bind msg -|- "!verification" znc:pm:verify
bind msg -|- "status"     znc:pm:status
bind msg -|- "!status"    znc:pm:status
bind msg -|- "help"       znc:pm:help
bind msg -|- "!help"      znc:pm:help
bind msg -|- "admin"      znc:pm:admin
bind msg -|- "!admin"     znc:pm:admin
bind msg -|- "admins"     znc:pm:admins
bind msg -|- "!admins"    znc:pm:admins

bind msg Y   "confirm"    znc:pm:confirm
bind msg Y   "!confirm"   znc:pm:confirm
bind msg Y   "deny"       znc:pm:deny
bind msg Y   "!deny"      znc:pm:deny
bind msg Y   "deluser"    znc:pm:deluser
bind msg Y   "!deluser"   znc:pm:deluser
bind msg Y   "luu"        znc:pm:luu
bind msg Y   "!luu"       znc:pm:luu

# --- PUBLIC CHANNEL BINDINGS ---
set p $scriptCommandPrefix
bind pub -|- "${p}help" znc:pub:help
bind pub -|- "${p}request" znc:pub:request
bind pub -|- "${p}status" znc:pub:status
bind pub -|- "${p}admin" znc:pub:admin
bind pub -|- "${p}verify" znc:pub:verify
bind pub -|- "${p}verifikasi" znc:pub:verify
bind pub -|- "${p}admins" znc:admin:listOnlineAdmins
bind pub -|- "${p}topic"  znc:pub:topic

bind pub Y "${p}confirm" znc:pub:confirm
bind pub Y "${p}deny" znc:pub:deny
bind pub Y "${p}deluser" znc:admin:delUser
bind pub Y "${p}luu" znc:admin:listUnconfirmed

putlog "ZNC Management 2026 by ktgDALnet loaded successfully."